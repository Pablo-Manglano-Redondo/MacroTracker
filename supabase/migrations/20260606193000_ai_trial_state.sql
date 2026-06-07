create table if not exists public.ai_trial_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  used integer not null default 0,
  ai_meals_saved integer not null default 0,
  onboarding_bonus_granted boolean not null default false,
  share_bonus_granted boolean not null default false,
  founding_member_activated_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ai_trial_state_used_nonnegative check (used >= 0),
  constraint ai_trial_state_meals_nonnegative check (ai_meals_saved >= 0)
);

create index if not exists ai_trial_state_updated_at_idx
  on public.ai_trial_state (updated_at desc);

alter table public.ai_trial_state enable row level security;

create policy "users read own ai trial state"
on public.ai_trial_state for select
using (user_id = auth.uid());

create policy "users insert own ai trial state"
on public.ai_trial_state for insert
with check (user_id = auth.uid());

create policy "users update own ai trial state"
on public.ai_trial_state for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create or replace function public.set_ai_trial_state_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists ai_trial_state_set_updated_at
on public.ai_trial_state;

create trigger ai_trial_state_set_updated_at
before update on public.ai_trial_state
for each row
execute function public.set_ai_trial_state_updated_at();
