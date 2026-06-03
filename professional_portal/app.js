let client;
let session;
let professional;

const $ = (id) => document.getElementById(id);

async function bootSupabase() {
  const config = window.MT_SUPABASE_CONFIG || {};
  const url = config.url || '';
  const anon = config.anonKey || '';
  if (!url || !anon) {
    alert('Missing professional_portal/config.js Supabase configuration.');
    return;
  }
  client = supabase.createClient(url, anon);
  client.auth.onAuthStateChange(async (_event, nextSession) => {
    session = nextSession;
    renderAuthState();
    if (session) await loadProfile();
  });
  const result = await client.auth.getSession();
  session = result.data.session;
  renderAuthState();
  if (session) await loadProfile();
  showCheckoutResult();
}

async function login() {
  if (!client) await bootSupabase();
  const email = $('email').value.trim();
  if (!email) {
    alert('Enter the professional email first.');
    return;
  }
  await client.auth.signInWithOtp({
    email,
    options: { emailRedirectTo: window.location.href },
  });
  alert('Magic link sent.');
}

async function signOut() {
  await client.auth.signOut();
  session = null;
  professional = null;
  renderAuthState();
}

function renderAuthState() {
  const signedIn = Boolean(session);
  $('auth-panel').hidden = signedIn;
  $('sign-out').hidden = !signedIn;
  $('profile-panel').hidden = !signedIn;
  $('profile-form-panel').hidden = !signedIn;
  $('billing-panel').hidden = !signedIn;
  $('invite-panel').hidden = !signedIn;
  $('clients-panel').hidden = !signedIn;
  $('plan-panel').hidden = !signedIn;
}

async function loadProfile() {
  const user = (await client.auth.getUser()).data.user;
  const { data } = await client
    .from('professionals')
    .select('*')
    .eq('user_id', user.id)
    .maybeSingle();
  professional = data;
  if (professional) {
    $('display-name').value = professional.display_name || '';
    $('business-name').value = professional.business_name || '';
    $('professional-title').textContent =
      professional.business_name || professional.display_name || 'Professional profile';
    $('pro-status').textContent = formatProStatus(professional.pro_status);
    $('pro-status').dataset.status = professional.pro_status;
    $('pro-limit').textContent = `${professional.client_limit || 0} client capacity`;
  } else {
    $('professional-title').textContent = 'Complete setup to unlock billing';
    $('pro-status').textContent = 'setup required';
    $('pro-status').dataset.status = 'inactive';
    $('pro-limit').textContent = 'Save a profile before checkout';
  }
  renderProGate();
  await loadClients();
}

async function saveProfile() {
  const user = (await client.auth.getUser()).data.user;
  const displayName = $('display-name').value.trim();
  if (!displayName) {
    alert('Display name is required.');
    return;
  }
  const payload = {
    user_id: user.id,
    display_name: displayName,
    business_name: $('business-name').value.trim(),
  };
  const { error } = await client
    .from('professionals')
    .upsert(payload, { onConflict: 'user_id' });
  if (error) return alert(error.message);
  await loadProfile();
  alert('Profile saved.');
}

async function createInvite() {
  if (!professional) return alert('Save your profile first.');
  if (!hasActivePro()) {
    return alert('Pro must be active to create invites.');
  }
  const code = crypto.randomUUID().slice(0, 8).toUpperCase();
  const expires = new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString();
  const { error } = await client.from('client_invites').insert({
    professional_id: professional.id,
    invite_code: code,
    expires_at: expires,
  });
  if (error) return alert(error.message);
  $('invite-output').textContent = `Invite code: ${code}`;
}

async function startCheckout(event) {
  if (!professional) return alert('Save your profile first.');
  const tier = event.currentTarget.dataset.tier || 'starter';
  setBusy(event.currentTarget, true);
  const { data, error } = await client.functions.invoke('stripe-pro-checkout', {
    body: {
      tier,
      origin: window.location.origin + window.location.pathname,
    },
  });
  setBusy(event.currentTarget, false);
  if (error) return alert(error.message);
  if (!data?.url) return alert('Stripe checkout did not return a URL.');
  window.location.href = data.url;
}

async function loadClients() {
  if (!professional) {
    $('clients').innerHTML = '<p class="muted">Save your profile to load clients.</p>';
    return;
  }
  $('clients').innerHTML = '<p class="muted">Loading connected clients...</p>';
  const { data, error } = await client
    .from('professional_clients')
    .select('id, client_id, status, connected_at, client_shared_snapshots(*)')
    .eq('professional_id', professional.id)
    .order('connected_at', { ascending: false });
  if (error) return alert(error.message);
  $('clients').innerHTML =
    (data || []).map(renderClient).join('') ||
    '<p class="muted">No connected clients yet.</p>';
}

function renderClient(row) {
  const latest = (row.client_shared_snapshots || []).sort((a, b) =>
    String(b.snapshot_date).localeCompare(String(a.snapshot_date))
  )[0];
  const summary = latest
    ? `${escapeHtml(latest.snapshot_date)}: ${Math.round(latest.kcal_actual)} / ${Math.round(latest.kcal_target)} kcal`
    : 'No shared snapshots yet.';
  const clientId = escapeHtml(row.client_id);
  const status = escapeHtml(row.status);
  const connected = new Date(row.connected_at).toLocaleDateString();
  return `<div class="client">
    <strong>${clientId}</strong>
    <span class="muted">${status} · ${connected}</span>
    <span class="client-snapshot">${summary}</span>
    <button onclick="selectClient('${clientId}')">Create plan</button>
  </div>`;
}

function selectClient(clientId) {
  $('plan-client-id').value = clientId;
  window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
}

function showCheckoutResult() {
  const params = new URLSearchParams(window.location.search);
  const checkout = params.get('checkout');
  if (checkout === 'success') {
    alert('Checkout completed. Stripe may take a moment to update Pro status.');
    history.replaceState({}, document.title, window.location.pathname);
  }
  if (checkout === 'cancelled') {
    alert('Checkout cancelled.');
    history.replaceState({}, document.title, window.location.pathname);
  }
}

function hasActivePro() {
  return ['trialing', 'active'].includes(professional?.pro_status);
}

function renderProGate() {
  const active = hasActivePro();
  const hasProfile = Boolean(professional);
  $('create-invite').disabled = !active;
  $('create-plan').disabled = !active;
  document.querySelectorAll('.checkout').forEach((button) => {
    button.disabled = !hasProfile;
  });
  document.querySelectorAll('[data-pro-gate]').forEach((element) => {
    element.hidden = active;
    if (!active) {
      element.textContent = gateMessage(element, hasProfile);
      element.hidden = false;
    }
  });
}

async function createPlan() {
  if (!professional) return alert('Save your profile first.');
  if (!hasActivePro()) {
    return alert('Pro must be active to create plans.');
  }
  const clientId = $('plan-client-id').value.trim();
  if (!clientId) return alert('Select or paste a client ID first.');
  if (!$('plan-name').value.trim()) return alert('Plan name is required.');
  for (const inputId of ['plan-kcal', 'plan-protein', 'plan-carbs', 'plan-fat']) {
    if (Number($(inputId).value) <= 0) {
      return alert('Plan calories and macros must be greater than zero.');
    }
  }
  const { data: plan, error: planError } = await client
    .from('nutrition_plans')
    .insert({
      professional_id: professional.id,
      client_id: clientId,
      name: $('plan-name').value.trim(),
      objective: 'general_fitness',
      status: 'active',
    })
    .select('id')
    .single();
  if (planError) return alert(planError.message);

  const dayRows = [1, 2, 3, 4, 5, 6, 7].map((weekday) => ({
    plan_id: plan.id,
    weekday,
    kcal_goal: Number($('plan-kcal').value),
    protein_goal: Number($('plan-protein').value),
    carbs_goal: Number($('plan-carbs').value),
    fat_goal: Number($('plan-fat').value),
  }));
  const { error } = await client.from('nutrition_plan_days').insert(dayRows);
  if (error) return alert(error.message);
  alert('Plan published.');
}

function formatProStatus(status) {
  if (!status) return 'inactive';
  return status.replaceAll('_', ' ');
}

function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

function setBusy(button, busy) {
  if (!button) return;
  button.disabled = busy;
  button.dataset.originalText ??= button.textContent;
  button.textContent = busy ? 'Opening Stripe...' : button.dataset.originalText;
}

function gateMessage(element, hasProfile) {
  if (!hasProfile) {
    return 'Save your professional profile before billing, invites, or plans.';
  }
  return element.closest('#plan-panel')
    ? 'Pro must be trialing or active to publish plans.'
    : 'Pro must be trialing or active to create invites.';
}

$('login').addEventListener('click', login);
$('sign-out').addEventListener('click', signOut);
$('save-profile').addEventListener('click', saveProfile);
$('create-invite').addEventListener('click', createInvite);
$('refresh').addEventListener('click', loadClients);
$('create-plan').addEventListener('click', createPlan);
document.querySelectorAll('.checkout').forEach((button) => {
  button.addEventListener('click', startCheckout);
});

bootSupabase();
