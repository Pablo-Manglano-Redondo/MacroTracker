-- Notifications table for in-app bell
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  professional_id uuid not null references public.professionals(id) on delete cascade,
  type text not null check (type in ('client_connected','snapshot_received','checkin_submitted','message_received','plan_activated','system')),
  title text not null,
  body text,
  metadata jsonb default '{}'::jsonb,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists notifications_professional_unread_idx on public.notifications (professional_id, read, created_at desc);

alter table public.notifications enable row level security;

create policy "Professionals read own notifications"
  on public.notifications for select
  using (professional_id = public.current_professional_id());

create policy "Professionals update own notifications"
  on public.notifications for update
  using (professional_id = public.current_professional_id())
  with check (professional_id = public.current_professional_id());

-- Auto-create notification when client connects
create or replace function public.notify_client_connected()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.notifications (professional_id, type, title, body, metadata)
  values (
    new.professional_id,
    'client_connected',
    'New client connected',
    'A client has accepted your invitation and connected to your practice.',
    jsonb_build_object('professional_client_id', new.id, 'client_id', new.client_id)
  );
  return new;
end;
$$;

create or replace trigger professional_clients_notify_connected
  after insert on public.professional_clients
  for each row execute function public.notify_client_connected();

-- Auto-create notification when snapshot received
create or replace function public.notify_snapshot_received()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.notifications (professional_id, type, title, body, metadata)
  values (
    new.professional_id,
    'snapshot_received',
    'Daily snapshot received',
    'A client has shared their daily nutrition snapshot.',
    jsonb_build_object('snapshot_id', new.id, 'client_id', new.client_id, 'professional_client_id', new.professional_client_id)
  );
  return new;
end;
$$;

create or replace trigger client_shared_snapshots_notify
  after insert on public.client_shared_snapshots
  for each row execute function public.notify_snapshot_received();

-- RPC: get client info (email + metadata) for a list of client UUIDs
create or replace function public.get_client_info(client_ids uuid[])
returns table (id uuid, email text, display_name text)
language sql stable security definer set search_path = auth as $$
  select
    u.id,
    u.email,
    coalesce(
      nullif(u.raw_user_meta_data ->> 'full_name', ''),
      nullif(u.raw_user_meta_data ->> 'name', ''),
      nullif(u.raw_user_meta_data ->> 'preferred_name', '')
    ) as display_name
  from auth.users u
  where u.id = any(client_ids)
$$;

-- RPC: mark notification as read
create or replace function public.mark_notification_read(p_id uuid)
returns void language sql security definer set search_path = public as $$
  update public.notifications set read = true where id = p_id;
$$;

-- RPC: mark all notifications as read for a professional
create or replace function public.mark_all_notifications_read(p_professional_id uuid)
returns void language sql security definer set search_path = public as $$
  update public.notifications set read = true
  where professional_id = p_professional_id and read = false;
$$;

-- Email notification Edge Function template (deploy separately)
-- See: supabase/functions/send-notification-email/index.ts
