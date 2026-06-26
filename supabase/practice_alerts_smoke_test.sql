-- Manual smoke test for practice_alerts refresh + RLS.
--
-- Run this only against staging after applying
-- 20260626000000_practice_alerts.sql and the prior professional portal
-- migrations. Replace UUID placeholders with real auth.users ids.

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
  consent_accepted_at,
  connected_at
) values
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-0000000000a1', 'CLIENT_A_USER_ID', 'connected', now(), now())
on conflict (professional_id, client_id) do update set
  status = 'connected',
  connected_at = now();

insert into public.client_checkins (
  id,
  professional_client_id,
  professional_id,
  client_id,
  answers,
  submitted_at,
  reviewed_at
) values (
  '00000000-0000-0000-0000-0000000000d1',
  '00000000-0000-0000-0000-0000000000c1',
  '00000000-0000-0000-0000-0000000000a1',
  'CLIENT_A_USER_ID',
  '{"energy":"low"}'::jsonb,
  now(),
  null
)
on conflict (id) do update set
  submitted_at = excluded.submitted_at,
  reviewed_at = null;

-- As PROFESSIONAL_A_USER_ID:
--   select * from public.refresh_practice_alerts('00000000-0000-0000-0000-0000000000a1');
--   select alert_type, status from public.practice_alerts order by detected_at desc;
-- Expected:
--   at least pending_checkin_review and client_without_plan for Professional A.
--
-- Then mark the check-in reviewed:
--   update public.client_checkins
--   set reviewed_at = now()
--   where id = '00000000-0000-0000-0000-0000000000d1';
--   select * from public.refresh_practice_alerts('00000000-0000-0000-0000-0000000000a1');
-- Expected:
--   pending_checkin_review should become resolved, not deleted.
--
-- RLS:
-- As PROFESSIONAL_B_USER_ID:
--   select count(*) from public.practice_alerts; -- 0
-- As CLIENT_A_USER_ID:
--   select count(*) from public.practice_alerts; -- 0

rollback;
