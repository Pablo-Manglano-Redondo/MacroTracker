-- Device tokens for push notifications
create table if not exists public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  token text not null,
  platform text not null check (platform in ('android', 'ios')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, platform, token)
);

create index if not exists device_tokens_user_idx on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;

create policy "Users manage own device tokens"
  on public.device_tokens for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- RPC to register a device token
create or replace function public.upsert_device_token(
  p_token text,
  p_platform text
) returns void language plpgsql security definer set search_path = public as $$
begin
  insert into public.device_tokens (user_id, token, platform)
  values (auth.uid(), p_token, p_platform)
  on conflict (user_id, platform, token)
  do update set updated_at = now();
end;
$$;

-- RPC to unregister a device token
create or replace function public.delete_device_token(
  p_token text
) returns void language plpgsql security definer set search_path = public as $$
begin
  delete from public.device_tokens where user_id = auth.uid() and token = p_token;
end;
$$;

-- Function to send push notification via Edge Function
-- Called by triggers when events relevant to the mobile user occur
create or replace function public.dispatch_push_notification(
  p_user_id uuid,
  p_title text,
  p_body text default null,
  p_data jsonb default '{}'::jsonb
) returns void language plpgsql as $$
begin
  -- Calls the Edge Function via pg_net (async HTTP request)
  -- Requires: supabase add extension pg_net if not already enabled
  perform
    net.http_post(
      url := concat(current_setting('supabase_functions.public_url', true), '/send-push-notification'),
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', concat('Bearer ', current_setting('supabase_functions.service_role_key', true))
      ),
      body := jsonb_build_object(
        'user_id', p_user_id,
        'title', p_title,
        'body', p_body,
        'data', p_data
      )::text
    );
exception when others then
  -- Non-blocking: push failures must never break the DB operation
  null;
end;
$$;

-- Push notification on new professional message (to the client)
create or replace function public.notify_client_new_message()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_client_id uuid;
  v_professional_name text;
begin
  v_client_id := new.client_id;
  -- Get professional name from the relationship
  select coalesce(
    nullif(p.business_name, ''),
    nullif(p.display_name, ''),
    'Nutritionist'
  ) into v_professional_name
  from public.professionals p
  where p.id = new.professional_id;

  perform public.dispatch_push_notification(
    v_client_id,
    concat(v_professional_name, ' sent a message'),
    substring(new.body from 1 for 120),
    jsonb_build_object('type', 'new_message', 'message_id', new.id)
  );
  return new;
end;
$$;

create or replace trigger professional_client_messages_notify_client
  after insert on public.professional_client_messages
  for each row
  when (new.author_role = 'professional')
  execute function public.notify_client_new_message();

-- Push notification on new recipe proposal (to the client)
create or replace function public.notify_client_recipe_proposal()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_recipe_title text;
begin
  select title into v_recipe_title
  from public.professional_recipes
  where id = new.recipe_id;

  perform public.dispatch_push_notification(
    new.client_id,
    'New recipe proposal',
    concat('Your nutritionist suggested: ', coalesce(v_recipe_title, 'a recipe')),
    jsonb_build_object('type', 'recipe_proposal', 'proposal_id', new.id)
  );
  return new;
end;
$$;

create or replace trigger client_proposed_recipes_notify_client
  after insert on public.client_proposed_recipes
  for each row
  when (new.status = 'pending')
  execute function public.notify_client_recipe_proposal();
