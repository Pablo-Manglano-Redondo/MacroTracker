-- Add notes column to client_shared_snapshots table
alter table public.client_shared_snapshots
  add column if not exists notes text;

-- Drop the old sharing mode check constraint
alter table public.professional_clients
  drop constraint if exists professional_clients_sharing_mode_check;

-- Add new sharing mode check constraint allowing both 'aggregate' and 'detailed'
alter table public.professional_clients
  add constraint professional_clients_sharing_mode_check
  check (sharing_mode in ('aggregate', 'detailed'));

-- Alter column default to 'detailed'
alter table public.professional_clients
  alter column sharing_mode set default 'detailed';

-- Update existing records to 'detailed'
update public.professional_clients
  set sharing_mode = 'detailed'
  where sharing_mode = 'aggregate';
