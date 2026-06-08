begin;

insert into auth.users (
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  is_sso_user,
  is_anonymous
)
values
  (
    '11111111-1111-1111-1111-111111111111',
    'authenticated',
    'authenticated',
    'pro.test@macrotracker.local',
    crypt('TempPass123!', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now(),
    false,
    false
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'authenticated',
    'authenticated',
    'client.test@macrotracker.local',
    crypt('TempPass123!', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now(),
    false,
    false
  )
on conflict (id) do nothing;

insert into public.professionals (
  id,
  user_id,
  display_name,
  business_name,
  verification_status,
  pro_status,
  client_limit,
  created_at,
  updated_at
)
values (
  '33333333-3333-3333-3333-333333333333',
  '11111111-1111-1111-1111-111111111111',
  'Professional Test',
  'MacroTracker Test Nutrition',
  'basic',
  'active',
  10,
  now(),
  now()
)
on conflict (id) do update
set pro_status = excluded.pro_status,
    updated_at = now();

insert into public.professional_clients (
  id,
  professional_id,
  client_id,
  status,
  consent_accepted_at,
  connected_at,
  sharing_mode,
  messages_enabled
)
values (
  '44444444-4444-4444-4444-444444444444',
  '33333333-3333-3333-3333-333333333333',
  '22222222-2222-2222-2222-222222222222',
  'connected',
  now(),
  now(),
  'aggregate',
  true
)
on conflict (professional_id, client_id) do update
set status = 'connected',
    sharing_mode = 'aggregate',
    messages_enabled = true,
    revoked_at = null;

insert into public.professional_client_messages (
  professional_client_id,
  professional_id,
  client_id,
  author_role,
  body,
  created_at
)
values
  (
    '44444444-4444-4444-4444-444444444444',
    '33333333-3333-3333-3333-333333333333',
    '22222222-2222-2222-2222-222222222222',
    'professional',
    'Plan actualizado. Revisa la vista semanal.',
    now() - interval '2 hours'
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    '33333333-3333-3333-3333-333333333333',
    '22222222-2222-2222-2222-222222222222',
    'professional',
    'Hoy prioriza adherencia y deja la cena simple.',
    now() - interval '45 minutes'
  );

commit;

select
  pc.id as relationship_id,
  p.display_name as professional_name,
  u.email as client_email,
  count(m.id)::int as message_count
from public.professional_clients pc
join public.professionals p on p.id = pc.professional_id
join auth.users u on u.id = pc.client_id
left join public.professional_client_messages m
  on m.professional_client_id = pc.id
where pc.id = '44444444-4444-4444-4444-444444444444'
group by pc.id, p.display_name, u.email;
