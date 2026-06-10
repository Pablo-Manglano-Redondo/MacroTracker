-- Add display_name column to professional_clients (editable by professional)
alter table public.professional_clients
add column if not exists display_name text;

-- RPC: batch-fetch display names from auth.users for backfill
create or replace function public.get_client_names(client_ids uuid[])
returns table (id uuid, display_name text)
language sql stable security definer
set search_path = auth
as $$
  select
    u.id,
    coalesce(
      nullif(u.raw_user_meta_data ->> 'full_name', ''),
      nullif(u.raw_user_meta_data ->> 'name', ''),
      nullif(u.raw_user_meta_data ->> 'preferred_name', ''),
      u.email
    ) as display_name
  from auth.users u
  where u.id = any(client_ids)
$$;

-- RPC: backfill display_name for existing clients (call once after deploying)
create or replace function public.backfill_client_display_names()
returns void
language plpgsql security definer
set search_path = public
as $$
begin
  update public.professional_clients pc
  set display_name = auth_names.display_name
  from (
    select gn.id, gn.display_name
    from public.get_client_names(
      (select array_agg(pc2.client_id) from public.professional_clients pc2 where pc2.display_name is null)
    ) gn
  ) auth_names
  where pc.client_id = auth_names.id
    and pc.display_name is null;
end;
$$;

-- Trigger: auto-backfill on new connection
create or replace function public.try_set_client_display_name()
returns trigger
language plpgsql security definer
set search_path = public
as $$
begin
  if new.display_name is null then
    new.display_name := (
      select coalesce(
        nullif(u.raw_user_meta_data ->> 'full_name', ''),
        nullif(u.raw_user_meta_data ->> 'name', ''),
        nullif(u.raw_user_meta_data ->> 'preferred_name', ''),
        u.email
      )
      from auth.users u
      where u.id = new.client_id
    );
  end if;
  return new;
end;
$$;

create or replace trigger professional_clients_set_display_name
  before insert on public.professional_clients
  for each row
  execute function public.try_set_client_display_name();
