alter table if exists public.professionals
  add column if not exists commercial_tier text
    check (commercial_tier in ('starter', 'growth', 'studio')),
  add column if not exists billing_interval text
    check (billing_interval in ('monthly', 'annual'));

update public.professionals
set commercial_tier = case
    when client_limit >= 500 then 'studio'
    when client_limit >= 50 then 'growth'
    else 'starter'
  end
where commercial_tier is null;

update public.professionals
set billing_interval = 'monthly'
where billing_interval is null;

alter table if exists public.professionals
  alter column commercial_tier set default 'starter',
  alter column commercial_tier set not null,
  alter column billing_interval set default 'monthly',
  alter column billing_interval set not null;
