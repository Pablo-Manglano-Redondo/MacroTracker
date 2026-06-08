create table if not exists public.professional_client_messages (
  id uuid primary key default gen_random_uuid(),
  professional_client_id uuid not null references public.professional_clients(id) on delete cascade,
  professional_id uuid not null references public.professionals(id) on delete cascade,
  client_id uuid not null references auth.users(id) on delete cascade,
  author_role text not null
    check (author_role in ('professional', 'client', 'system')),
  body text not null,
  created_at timestamptz not null default now(),
  client_read_at timestamptz,
  professional_read_at timestamptz
);

create index if not exists professional_client_messages_relationship_created_idx
  on public.professional_client_messages (professional_client_id, created_at desc);
create index if not exists professional_client_messages_client_unread_idx
  on public.professional_client_messages (client_id, client_read_at, created_at desc);
create index if not exists professional_client_messages_professional_unread_idx
  on public.professional_client_messages (professional_id, professional_read_at, created_at desc);

alter table public.professional_client_messages enable row level security;

drop policy if exists "connected participants read professional messages"
on public.professional_client_messages;
create policy "connected participants read professional messages"
on public.professional_client_messages for select
using (
  exists (
    select 1
    from public.professional_clients pc
    where pc.id = professional_client_messages.professional_client_id
      and pc.status = 'connected'
      and (
        pc.client_id = auth.uid()
        or pc.professional_id = public.current_professional_id()
      )
  )
);

drop policy if exists "professionals send messages with pro"
on public.professional_client_messages;
create policy "professionals send messages with pro"
on public.professional_client_messages for insert
with check (
  author_role in ('professional', 'system')
  and professional_id = public.current_professional_id()
  and public.current_professional_has_pro()
  and exists (
    select 1
    from public.professional_clients pc
    where pc.id = professional_client_messages.professional_client_id
      and pc.professional_id = public.current_professional_id()
      and pc.client_id = professional_client_messages.client_id
      and pc.status = 'connected'
  )
);

drop policy if exists "connected clients send own messages"
on public.professional_client_messages;
create policy "connected clients send own messages"
on public.professional_client_messages for insert
with check (
  author_role = 'client'
  and client_id = auth.uid()
  and exists (
    select 1
    from public.professional_clients pc
    where pc.id = professional_client_messages.professional_client_id
      and pc.client_id = auth.uid()
      and pc.professional_id = professional_client_messages.professional_id
      and pc.status = 'connected'
  )
);

drop policy if exists "clients mark professional messages as read"
on public.professional_client_messages;
create policy "clients mark professional messages as read"
on public.professional_client_messages for update
using (
  client_id = auth.uid()
  and exists (
    select 1
    from public.professional_clients pc
    where pc.id = professional_client_messages.professional_client_id
      and pc.client_id = auth.uid()
      and pc.status = 'connected'
  )
)
with check (
  client_id = auth.uid()
  and exists (
    select 1
    from public.professional_clients pc
    where pc.id = professional_client_messages.professional_client_id
      and pc.client_id = auth.uid()
      and pc.status = 'connected'
  )
);

alter table public.professional_clients
  add column if not exists sharing_mode text not null default 'aggregate'
    check (sharing_mode in ('aggregate'));

alter table public.professional_clients
  add column if not exists messages_enabled boolean not null default true;

drop function if exists public.accept_client_invite(text);

create function public.accept_client_invite(p_invite_code text)
returns table (
  relationship_id uuid,
  professional_id uuid,
  client_id uuid,
  professional_name text,
  connected_at timestamptz,
  consent_accepted_at timestamptz,
  sharing_mode text,
  messages_enabled boolean,
  connection_status text
)
language plpgsql security definer set search_path = public as $$
declare
  v_invite public.client_invites%rowtype;
  v_relationship public.professional_clients%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Authentication is required to accept invites';
  end if;

  select * into v_invite
  from public.client_invites
  where invite_code = upper(replace(trim(p_invite_code), ' ', ''))
    and status = 'pending'
    and expires_at > now()
  for update;

  if not found then
    raise exception 'Invite is not valid or has expired';
  end if;

  if not exists (
    select 1
    from public.professionals p
    where p.id = v_invite.professional_id
      and p.pro_status in ('trialing', 'active')
  ) then
    raise exception 'Professional subscription is not active';
  end if;

  if (
    select count(*)
    from public.professional_clients pc
    where pc.professional_id = v_invite.professional_id
      and pc.status = 'connected'
  ) >= (
    select p.client_limit
    from public.professionals p
    where p.id = v_invite.professional_id
  ) then
    raise exception 'Professional client limit reached';
  end if;

  insert into public.professional_clients (
    professional_id,
    client_id,
    status,
    consent_accepted_at,
    connected_at
  )
  values (v_invite.professional_id, auth.uid(), 'connected', now(), now())
  on conflict (professional_id, client_id) do update
    set status = 'connected',
        consent_accepted_at = excluded.consent_accepted_at,
        connected_at = excluded.connected_at,
        revoked_at = null
  returning * into v_relationship;

  update public.client_invites
  set status = 'accepted',
      accepted_by = auth.uid(),
      accepted_at = now()
  where id = v_invite.id;

  return query
  select
    v_relationship.id,
    p.id,
    auth.uid(),
    coalesce(nullif(p.business_name, ''), p.display_name),
    v_relationship.connected_at,
    v_relationship.consent_accepted_at,
    v_relationship.sharing_mode,
    v_relationship.messages_enabled,
    v_relationship.status
  from public.professionals p
  where p.id = v_invite.professional_id;
end;
$$;

grant execute on function public.accept_client_invite(text) to authenticated;
