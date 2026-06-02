-- Manual RLS smoke test for the professional platform.
--
-- Run this only against a staging database after applying
-- 20260601_b2b_professional_plans.sql. Replace UUID placeholders with real
-- auth.users IDs created in staging.

-- Expected users:
--   PROFESSIONAL_A_USER_ID
--   PROFESSIONAL_B_USER_ID
--   CLIENT_A_USER_ID
--   CLIENT_B_USER_ID

begin;

insert into public.professionals (
  id,
  user_id,
  display_name,
  business_name,
  pro_status,
  client_limit
) values
  ('00000000-0000-0000-0000-0000000000a1', 'PROFESSIONAL_A_USER_ID', 'Professional A', 'Studio A', 'active', 10),
  ('00000000-0000-0000-0000-0000000000b1', 'PROFESSIONAL_B_USER_ID', 'Professional B', 'Studio B', 'active', 10)
on conflict (id) do update set
  display_name = excluded.display_name,
  pro_status = excluded.pro_status,
  client_limit = excluded.client_limit;

insert into public.professional_clients (
  id,
  professional_id,
  client_id,
  status,
  consent_accepted_at
) values
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-0000000000a1', 'CLIENT_A_USER_ID', 'connected', now())
on conflict (professional_id, client_id) do update set status = 'connected';

insert into public.nutrition_plans (
  id,
  professional_id,
  client_id,
  name,
  objective,
  status
) values (
  '00000000-0000-0000-0000-0000000000d1',
  '00000000-0000-0000-0000-0000000000a1',
  'CLIENT_A_USER_ID',
  'RLS smoke plan',
  'general_fitness',
  'active'
) on conflict (id) do update set status = 'active';

-- Run each block below from an authenticated SQL session or API client with
-- the matching JWT. Expected results:
--
-- As PROFESSIONAL_A_USER_ID:
--   select count(*) from professional_clients; -- 1
--   select count(*) from nutrition_plans; -- 1
--
-- As PROFESSIONAL_B_USER_ID:
--   select count(*) from professional_clients; -- 0
--   select count(*) from nutrition_plans; -- 0
--
-- As CLIENT_A_USER_ID:
--   select count(*) from professional_clients; -- 1
--   select count(*) from nutrition_plans; -- 1
--
-- As CLIENT_B_USER_ID:
--   select count(*) from professional_clients; -- 0
--   select count(*) from nutrition_plans; -- 0

rollback;
