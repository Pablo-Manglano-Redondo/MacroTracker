-- Preserve accepted invite history when a client deletes their cloud account.
-- Without this, auth user deletion is blocked by client_invites.accepted_by.

alter table public.client_invites
  drop constraint if exists client_invites_accepted_by_fkey;

alter table public.client_invites
  add constraint client_invites_accepted_by_fkey
  foreign key (accepted_by)
  references auth.users(id)
  on delete set null;
