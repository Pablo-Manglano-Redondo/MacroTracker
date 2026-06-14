alter table public.professional_clients
  alter column sharing_mode set default 'aggregate';

update public.professional_clients
  set sharing_mode = 'aggregate'
  where sharing_mode = 'detailed';
