create extension if not exists pgcrypto;

create table if not exists public.professionals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  display_name text not null,
  business_name text,
  verification_status text not null default 'basic'
    check (verification_status in ('basic', 'verified', 'rejected')),
  pro_status text not null default 'inactive'
    check (pro_status in ('inactive', 'trialing', 'active', 'past_due', 'canceled')),
  stripe_customer_id text,
  stripe_subscription_id text,
  client_limit integer not null default 10,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.professional_clients (
  id uuid primary key default gen_random_uuid(),
  professional_id uuid not null references public.professionals(id) on delete cascade,
  client_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'connected'
    check (status in ('connected', 'revoked', 'archived')),
  consent_accepted_at timestamptz not null default now(),
  connected_at timestamptz not null default now(),
  revoked_at timestamptz,
  unique (professional_id, client_id)
);

create table if not exists public.client_invites (
  id uuid primary key default gen_random_uuid(),
  professional_id uuid not null references public.professionals(id) on delete cascade,
  invite_code text not null unique,
  client_email text,
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'expired', 'revoked')),
  expires_at timestamptz not null default now() + interval '14 days',
  accepted_by uuid references auth.users(id),
  accepted_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.nutrition_plans (
  id uuid primary key default gen_random_uuid(),
  professional_id uuid not null references public.professionals(id) on delete cascade,
  client_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  objective text not null default 'general_fitness',
  notes text,
  status text not null default 'draft'
    check (status in ('draft', 'active', 'archived')),
  starts_on date,
  ends_on date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.nutrition_plan_days (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.nutrition_plans(id) on delete cascade,
  plan_date date,
  weekday integer check (weekday between 1 and 7),
  kcal_goal numeric not null,
  carbs_goal numeric not null,
  fat_goal numeric not null,
  protein_goal numeric not null,
  check (plan_date is not null or weekday is not null)
);

create table if not exists public.nutrition_plan_meals (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.nutrition_plans(id) on delete cascade,
  slot text not null check (slot in ('breakfast', 'lunch', 'dinner', 'snack')),
  title text not null,
  notes text,
  kcal numeric,
  carbs numeric,
  fat numeric,
  protein numeric,
  created_at timestamptz not null default now()
);

create table if not exists public.client_shared_snapshots (
  id uuid primary key default gen_random_uuid(),
  professional_client_id uuid not null references public.professional_clients(id) on delete cascade,
  professional_id uuid not null references public.professionals(id) on delete cascade,
  client_id uuid not null references auth.users(id) on delete cascade,
  snapshot_date date not null,
  kcal_actual numeric not null,
  kcal_target numeric not null,
  carbs_actual numeric not null,
  carbs_target numeric not null,
  fat_actual numeric not null,
  fat_target numeric not null,
  protein_actual numeric not null,
  protein_target numeric not null,
  meals_logged integer not null default 0,
  weight_kg numeric,
  synced_at timestamptz not null default now(),
  unique (professional_client_id, snapshot_date)
);

create index if not exists professional_clients_professional_status_idx
  on public.professional_clients (professional_id, status);
create index if not exists professional_clients_client_status_idx
  on public.professional_clients (client_id, status);
create index if not exists client_invites_professional_status_idx
  on public.client_invites (professional_id, status);
create index if not exists nutrition_plans_client_status_idx
  on public.nutrition_plans (client_id, status, created_at desc);
create index if not exists nutrition_plans_professional_client_idx
  on public.nutrition_plans (professional_id, client_id);
create index if not exists nutrition_plan_days_plan_idx
  on public.nutrition_plan_days (plan_id);
create index if not exists nutrition_plan_meals_plan_idx
  on public.nutrition_plan_meals (plan_id);
create index if not exists client_shared_snapshots_professional_date_idx
  on public.client_shared_snapshots (professional_id, snapshot_date desc);
create index if not exists client_shared_snapshots_client_date_idx
  on public.client_shared_snapshots (client_id, snapshot_date desc);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists professionals_set_updated_at on public.professionals;
create trigger professionals_set_updated_at
before update on public.professionals
for each row execute function public.set_updated_at();

drop trigger if exists nutrition_plans_set_updated_at on public.nutrition_plans;
create trigger nutrition_plans_set_updated_at
before update on public.nutrition_plans
for each row execute function public.set_updated_at();

alter table public.professionals enable row level security;
alter table public.professional_clients enable row level security;
alter table public.client_invites enable row level security;
alter table public.nutrition_plans enable row level security;
alter table public.nutrition_plan_days enable row level security;
alter table public.nutrition_plan_meals enable row level security;
alter table public.client_shared_snapshots enable row level security;

create or replace function public.current_professional_id()
returns uuid language sql stable security definer set search_path = public as $$
  select id from public.professionals where user_id = auth.uid()
$$;

create or replace function public.current_professional_has_pro()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(
    (select pro_status in ('trialing', 'active')
     from public.professionals where user_id = auth.uid()),
    false
  )
$$;

create or replace function public.current_professional_can_add_client()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(
    (
      select p.pro_status in ('trialing', 'active')
        and (
          select count(*)
          from public.professional_clients pc
          where pc.professional_id = p.id
            and pc.status = 'connected'
        ) < p.client_limit
      from public.professionals p
      where p.user_id = auth.uid()
    ),
    false
  )
$$;

create policy "professionals manage own profile"
on public.professionals for all
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "clients see own relationships"
on public.professional_clients for select
using (client_id = auth.uid() or professional_id = public.current_professional_id());

create policy "clients revoke own relationships"
on public.professional_clients for update
using (client_id = auth.uid())
with check (client_id = auth.uid());

create policy "professionals manage connected clients with pro"
on public.professional_clients for insert
with check (
  professional_id = public.current_professional_id()
  and public.current_professional_can_add_client()
);

create policy "professionals manage own invites with pro"
on public.client_invites for all
using (professional_id = public.current_professional_id())
with check (
  professional_id = public.current_professional_id()
  and public.current_professional_can_add_client()
);

create policy "plans visible to owner and connected client"
on public.nutrition_plans for select
using (
  professional_id = public.current_professional_id()
  or exists (
    select 1 from public.professional_clients pc
    where pc.professional_id = nutrition_plans.professional_id
      and pc.client_id = auth.uid()
      and pc.status = 'connected'
  )
);

create policy "professionals write plans with pro"
on public.nutrition_plans for all
using (professional_id = public.current_professional_id())
with check (
  professional_id = public.current_professional_id()
  and public.current_professional_has_pro()
);

create policy "plan days visible through plan"
on public.nutrition_plan_days for select
using (
  exists (
    select 1 from public.nutrition_plans np
    where np.id = nutrition_plan_days.plan_id
      and (
        np.professional_id = public.current_professional_id()
        or exists (
          select 1 from public.professional_clients pc
          where pc.professional_id = np.professional_id
            and pc.client_id = auth.uid()
            and pc.status = 'connected'
        )
      )
  )
);

create policy "professionals write plan days with pro"
on public.nutrition_plan_days for all
using (
  exists (
    select 1 from public.nutrition_plans np
    where np.id = nutrition_plan_days.plan_id
      and np.professional_id = public.current_professional_id()
  )
)
with check (
  public.current_professional_has_pro()
  and exists (
    select 1 from public.nutrition_plans np
    where np.id = nutrition_plan_days.plan_id
      and np.professional_id = public.current_professional_id()
  )
);

create policy "plan meals visible through plan"
on public.nutrition_plan_meals for select
using (
  exists (
    select 1 from public.nutrition_plans np
    where np.id = nutrition_plan_meals.plan_id
      and (
        np.professional_id = public.current_professional_id()
        or exists (
          select 1 from public.professional_clients pc
          where pc.professional_id = np.professional_id
            and pc.client_id = auth.uid()
            and pc.status = 'connected'
        )
      )
  )
);

create policy "professionals write plan meals with pro"
on public.nutrition_plan_meals for all
using (
  exists (
    select 1 from public.nutrition_plans np
    where np.id = nutrition_plan_meals.plan_id
      and np.professional_id = public.current_professional_id()
  )
)
with check (
  public.current_professional_has_pro()
  and exists (
    select 1 from public.nutrition_plans np
    where np.id = nutrition_plan_meals.plan_id
      and np.professional_id = public.current_professional_id()
  )
);

create policy "clients upload own aggregate snapshots"
on public.client_shared_snapshots for insert
with check (
  client_id = auth.uid()
  and exists (
    select 1 from public.professional_clients pc
    where pc.id = professional_client_id
      and pc.client_id = auth.uid()
      and pc.status = 'connected'
  )
);

create policy "clients update own aggregate snapshots"
on public.client_shared_snapshots for update
using (client_id = auth.uid())
with check (client_id = auth.uid());

create policy "professionals read connected snapshots"
on public.client_shared_snapshots for select
using (
  professional_id = public.current_professional_id()
  or client_id = auth.uid()
);

create or replace function public.accept_client_invite(p_invite_code text)
returns table (
  relationship_id uuid,
  professional_id uuid,
  client_id uuid,
  professional_name text,
  connected_at timestamptz,
  consent_accepted_at timestamptz
)
language plpgsql security definer set search_path = public as $$
#variable_conflict use_column
declare
  v_invite public.client_invites%rowtype;
  v_relationship public.professional_clients%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Authentication is required to accept invites';
  end if;

  select * into v_invite
  from public.client_invites
  where invite_code = upper(replace(trim(p_invite_code), ' ', ''))
    and status = 'pending'
    and expires_at > now()
  for update;

  if not found then
    raise exception 'Invite is not valid or has expired';
  end if;

  if not exists (
    select 1
    from public.professionals p
    where p.id = v_invite.professional_id
      and p.pro_status in ('trialing', 'active')
  ) then
    raise exception 'Professional subscription is not active';
  end if;

  if (
    select count(*)
    from public.professional_clients pc
    where pc.professional_id = v_invite.professional_id
      and pc.status = 'connected'
  ) >= (
    select p.client_limit
    from public.professionals p
    where p.id = v_invite.professional_id
  ) then
    raise exception 'Professional client limit reached';
  end if;

  -- Use SELECT followed by INSERT or UPDATE to avoid ON CONFLICT which causes parameter/variable name conflicts in PL/pgSQL
  select * into v_relationship
  from public.professional_clients pc
  where pc.professional_id = v_invite.professional_id
    and pc.client_id = auth.uid();

  if found then
    update public.professional_clients pc
    set status = 'connected',
        consent_accepted_at = now(),
        connected_at = now(),
        revoked_at = null
    where pc.id = v_relationship.id
    returning * into v_relationship;
  else
    insert into public.professional_clients (
      professional_id,
      client_id,
      status,
      consent_accepted_at,
      connected_at
    )
    values (v_invite.professional_id, auth.uid(), 'connected', now(), now())
    returning * into v_relationship;
  end if;

  update public.client_invites
  set status = 'accepted',
      accepted_by = auth.uid(),
      accepted_at = now()
  where id = v_invite.id;

  -- Assign results directly to the OUT parameters (table columns) using SELECT ... INTO to prevent RETURN QUERY ambiguity
  select
    v_relationship.id,
    p.id,
    auth.uid(),
    coalesce(nullif(p.business_name, ''), p.display_name),
    v_relationship.connected_at,
    v_relationship.consent_accepted_at
  into
    relationship_id,
    professional_id,
    client_id,
    professional_name,
    connected_at,
    consent_accepted_at
  from public.professionals p
  where p.id = v_invite.professional_id;

  return next;
end;
$$;

grant execute on function public.accept_client_invite(text) to authenticated;

create or replace function public.preview_client_invite(p_invite_code text)
returns table (
  id uuid,
  invite_code text,
  professional_id uuid,
  expires_at timestamptz,
  status text,
  professionals jsonb
)
language sql security definer set search_path = public as $$
  select
    ci.id,
    ci.invite_code,
    ci.professional_id,
    ci.expires_at,
    ci.status,
    jsonb_build_object(
      'id', p.id,
      'display_name', p.display_name,
      'business_name', p.business_name
    ) as professionals
  from public.client_invites ci
  join public.professionals p on p.id = ci.professional_id
  where ci.invite_code = upper(replace(trim(p_invite_code), ' ', ''))
    and ci.status = 'pending'
    and ci.expires_at > now()
  limit 1
$$;

grant execute on function public.preview_client_invite(text) to anon, authenticated;
