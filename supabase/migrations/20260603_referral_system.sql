-- Referral system for MacroTracker launch.
-- Each user gets a unique referral code. When someone redeems it,
-- both the referrer and the referee are recorded. The app grants
-- bonuses (AI trial uses, founding-member status, etc.) based on
-- rows in referral_redemptions.

create table if not exists public.referral_codes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  code text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.referral_redemptions (
  id uuid primary key default gen_random_uuid(),
  referral_code_id uuid not null references public.referral_codes(id) on delete cascade,
  referrer_user_id uuid not null references auth.users(id) on delete cascade,
  redeemer_user_id uuid not null references auth.users(id) on delete cascade,
  redeemed_at timestamptz not null default now(),
  referrer_rewarded boolean not null default false,
  redeemer_rewarded boolean not null default false,
  unique (referral_code_id, redeemer_user_id)
);

create index if not exists referral_codes_user_idx
  on public.referral_codes (user_id);
create index if not exists referral_codes_code_idx
  on public.referral_codes (code);
create index if not exists referral_redemptions_referrer_idx
  on public.referral_redemptions (referrer_user_id);
create index if not exists referral_redemptions_redeemer_idx
  on public.referral_redemptions (redeemer_user_id);

alter table public.referral_codes enable row level security;
alter table public.referral_redemptions enable row level security;

-- Users can read their own referral code.
create policy "users read own referral code"
on public.referral_codes for select
using (user_id = auth.uid());

-- Users can insert their own referral code (one per user, enforced by unique).
create policy "users create own referral code"
on public.referral_codes for insert
with check (user_id = auth.uid());

-- Anyone authenticated can look up a referral code to redeem it.
create policy "authenticated users lookup referral codes"
on public.referral_codes for select
using (auth.uid() is not null);

-- Users can see their own redemptions (as referrer or redeemer).
create policy "users read own redemptions"
on public.referral_redemptions for select
using (referrer_user_id = auth.uid() or redeemer_user_id = auth.uid());

-- Redeem a referral code. Validates that:
-- 1. The user is authenticated.
-- 2. The code exists.
-- 3. The user is not redeeming their own code.
-- 4. The user hasn't already redeemed this code.
-- Returns the redemption row.
create or replace function public.redeem_referral_code(p_code text)
returns table (
  redemption_id uuid,
  referrer_user_id uuid,
  redeemer_user_id uuid,
  redeemed_at timestamptz
)
language plpgsql security definer set search_path = public as $$
declare
  v_code public.referral_codes%rowtype;
  v_redemption public.referral_redemptions%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Authentication is required to redeem referral codes';
  end if;

  select * into v_code
  from public.referral_codes
  where code = upper(trim(p_code))
  for update;

  if not found then
    raise exception 'Referral code not found';
  end if;

  if v_code.user_id = auth.uid() then
    raise exception 'Cannot redeem your own referral code';
  end if;

  -- Insert redemption (unique constraint prevents duplicate redemptions).
  insert into public.referral_redemptions (
    referral_code_id,
    referrer_user_id,
    redeemer_user_id
  )
  values (v_code.id, v_code.user_id, auth.uid())
  returning * into v_redemption;

  return query
  select
    v_redemption.id,
    v_redemption.referrer_user_id,
    v_redemption.redeemer_user_id,
    v_redemption.redeemed_at;
end;
$$;

grant execute on function public.redeem_referral_code(text) to authenticated;

-- Get the count of successful redemptions for a referrer.
create or replace function public.get_referral_count()
returns integer
language sql stable security definer set search_path = public as $$
  select coalesce(
    (select count(*)::integer
     from public.referral_redemptions
     where referrer_user_id = auth.uid()),
    0
  )
$$;

grant execute on function public.get_referral_count() to authenticated;
