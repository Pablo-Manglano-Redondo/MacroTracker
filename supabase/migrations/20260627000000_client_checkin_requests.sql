alter table if exists public.client_checkins
  add column if not exists request_id uuid;

create table if not exists public.client_checkin_requests (
  id uuid primary key default gen_random_uuid(),
  professional_client_id uuid not null references public.professional_clients(id) on delete cascade,
  professional_id uuid not null references public.professionals(id) on delete cascade,
  client_id uuid not null references auth.users(id) on delete cascade,
  template_id uuid references public.checkin_templates(id) on delete set null,
  status text not null default 'pending' check (status in ('pending', 'completed', 'cancelled')),
  requested_at timestamptz not null default now(),
  completed_at timestamptz,
  completed_checkin_id uuid references public.client_checkins(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.client_checkins
  drop constraint if exists client_checkins_request_id_fkey;

alter table public.client_checkins
  add constraint client_checkins_request_id_fkey
  foreign key (request_id)
  references public.client_checkin_requests(id)
  on delete set null;

create index if not exists client_checkins_request_id_idx
  on public.client_checkins (request_id);

create unique index if not exists client_checkin_requests_one_pending_idx
  on public.client_checkin_requests (professional_client_id)
  where status = 'pending';

create index if not exists client_checkin_requests_client_status_idx
  on public.client_checkin_requests (client_id, status, requested_at desc);

create index if not exists client_checkin_requests_professional_status_idx
  on public.client_checkin_requests (professional_id, status, requested_at desc);

alter table public.client_checkin_requests enable row level security;

drop trigger if exists client_checkin_requests_set_updated_at on public.client_checkin_requests;
create trigger client_checkin_requests_set_updated_at
before update on public.client_checkin_requests
for each row execute function public.set_updated_at();

drop policy if exists "professionals read own checkin requests" on public.client_checkin_requests;
create policy "professionals read own checkin requests"
  on public.client_checkin_requests for select
  using (professional_id = public.current_professional_id());

drop policy if exists "clients read own checkin requests" on public.client_checkin_requests;
create policy "clients read own checkin requests"
  on public.client_checkin_requests for select
  using (client_id = auth.uid());

create or replace function public.complete_client_checkin_request()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_request_id uuid;
begin
  v_request_id := new.request_id;

  if v_request_id is null then
    select ccr.id
      into v_request_id
      from public.client_checkin_requests ccr
      where ccr.professional_client_id = new.professional_client_id
        and ccr.professional_id = new.professional_id
        and ccr.client_id = new.client_id
        and ccr.status = 'pending'
      order by ccr.requested_at desc
      limit 1;

    if v_request_id is not null then
      update public.client_checkins
         set request_id = v_request_id
       where id = new.id;
    end if;
  end if;

  if v_request_id is not null then
    update public.client_checkin_requests
       set status = 'completed',
           completed_at = coalesce(completed_at, new.submitted_at),
           completed_checkin_id = new.id
     where id = v_request_id
       and status = 'pending';
  end if;

  return new;
end;
$$;

drop trigger if exists client_checkins_complete_request on public.client_checkins;
create trigger client_checkins_complete_request
after insert on public.client_checkins
for each row execute function public.complete_client_checkin_request();

drop function if exists public.request_client_checkin(uuid, uuid, uuid);

create or replace function public.request_client_checkin(
  p_professional_id uuid,
  p_client_id uuid,
  p_professional_client_id uuid,
  p_template_id uuid default null
) returns public.client_checkin_requests
language plpgsql security definer set search_path = public as $$
declare
  v_request public.client_checkin_requests;
begin
  if p_professional_id <> public.current_professional_id() then
    raise exception 'not authorized';
  end if;

  if not exists (
    select 1
      from public.professional_clients pc
      where pc.id = p_professional_client_id
        and pc.professional_id = p_professional_id
        and pc.client_id = p_client_id
        and pc.status = 'connected'
  ) then
    raise exception 'client relationship not found';
  end if;

  insert into public.client_checkin_requests (
    professional_client_id,
    professional_id,
    client_id,
    template_id,
    status,
    requested_at
  )
  values (
    p_professional_client_id,
    p_professional_id,
    p_client_id,
    p_template_id,
    'pending',
    now()
  )
  on conflict (professional_client_id) where status = 'pending'
  do update set
    template_id = excluded.template_id,
    requested_at = excluded.requested_at,
    updated_at = now()
  returning * into v_request;

  insert into public.notifications (professional_id, type, title, body, metadata)
  values (
    p_professional_id,
    'system',
    'Check-in requested',
    'A check-in request was sent to the client.',
    jsonb_build_object(
      'professional_client_id', p_professional_client_id,
      'client_id', p_client_id,
      'request_id', v_request.id
    )
  );

  begin
    perform public.dispatch_push_notification(
      p_client_id,
      'Check-in Requested',
      'Your nutritionist has requested a check-in. Please submit your weekly update.',
      jsonb_build_object(
        'type', 'checkin_requested',
        'professional_client_id', p_professional_client_id,
        'request_id', v_request.id
      )
    );
  exception when others then
    null;
  end;

  return v_request;
end;
$$;

grant execute on function public.request_client_checkin(uuid, uuid, uuid, uuid) to authenticated;
