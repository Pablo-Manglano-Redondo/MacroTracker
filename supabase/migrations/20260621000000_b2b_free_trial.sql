-- Alter defaults for public.professionals table to support a B2B Free Trial tier by default.
alter table if exists public.professionals
  alter column pro_status set default 'trialing',
  alter column client_limit set default 1;

-- Migrate all existing 'inactive' professionals to 'trialing' with a client limit of 1
-- so they immediately get access to the Free Trial tier.
update public.professionals
set pro_status = 'trialing',
    client_limit = 1
where pro_status = 'inactive';
