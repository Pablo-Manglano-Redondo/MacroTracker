alter table if exists public.client_checkins
  add column if not exists reviewed_at timestamptz;

create index if not exists client_checkins_professional_review_idx
  on public.client_checkins (professional_id, reviewed_at, submitted_at desc);

drop policy if exists "Professionals review own client checkins" on public.client_checkins;
create policy "Professionals review own client checkins"
  on public.client_checkins for update
  using (professional_id = public.current_professional_id())
  with check (professional_id = public.current_professional_id());

create table if not exists public.practice_alerts (
  id uuid primary key default gen_random_uuid(),
  professional_id uuid not null references public.professionals(id) on delete cascade,
  professional_client_id uuid references public.professional_clients(id) on delete set null,
  alert_type text not null check (
    alert_type in (
      'practice_blocked',
      'no_connected_clients',
      'client_without_plan',
      'stale_snapshot',
      'low_adherence',
      'unread_messages',
      'pending_checkin_review',
      'pending_invite_expiring'
    )
  ),
  severity text not null check (severity in ('critical', 'high', 'medium', 'low')),
  status text not null default 'open' check (status in ('open', 'dismissed', 'resolved')),
  title_key text,
  title text not null,
  body_key text,
  body text,
  action_kind text not null,
  action_target_tab text,
  action_payload jsonb not null default '{}'::jsonb,
  evidence jsonb not null default '{}'::jsonb,
  dedupe_key text not null,
  detected_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  unique (professional_id, dedupe_key)
);

create index if not exists practice_alerts_professional_status_idx
  on public.practice_alerts (professional_id, status);
create index if not exists practice_alerts_professional_severity_idx
  on public.practice_alerts (professional_id, severity);
create index if not exists practice_alerts_professional_client_idx
  on public.practice_alerts (professional_client_id);
create index if not exists practice_alerts_professional_detected_idx
  on public.practice_alerts (professional_id, detected_at desc);

alter table public.practice_alerts enable row level security;

drop trigger if exists practice_alerts_set_updated_at on public.practice_alerts;
create trigger practice_alerts_set_updated_at
before update on public.practice_alerts
for each row execute function public.set_updated_at();

drop policy if exists "professionals read own practice alerts" on public.practice_alerts;
create policy "professionals read own practice alerts"
on public.practice_alerts for select
using (professional_id = public.current_professional_id());

drop policy if exists "professionals insert own practice alerts" on public.practice_alerts;
create policy "professionals insert own practice alerts"
on public.practice_alerts for insert
with check (professional_id = public.current_professional_id());

drop policy if exists "professionals update own practice alerts" on public.practice_alerts;
create policy "professionals update own practice alerts"
on public.practice_alerts for update
using (professional_id = public.current_professional_id())
with check (professional_id = public.current_professional_id());

create or replace function public.practice_alert_severity_rank(p_severity text)
returns integer
language sql
immutable
as $$
  select case p_severity
    when 'critical' then 4
    when 'high' then 3
    when 'medium' then 2
    when 'low' then 1
    else 0
  end
$$;

create or replace function public.upsert_practice_alert(
  p_professional_id uuid,
  p_professional_client_id uuid,
  p_alert_type text,
  p_severity text,
  p_title_key text,
  p_title text,
  p_body_key text,
  p_body text,
  p_action_kind text,
  p_action_target_tab text,
  p_action_payload jsonb,
  p_evidence jsonb,
  p_dedupe_key text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.practice_alerts (
    professional_id,
    professional_client_id,
    alert_type,
    severity,
    status,
    title_key,
    title,
    body_key,
    body,
    action_kind,
    action_target_tab,
    action_payload,
    evidence,
    dedupe_key,
    detected_at,
    updated_at,
    resolved_at
  )
  values (
    p_professional_id,
    p_professional_client_id,
    p_alert_type,
    p_severity,
    'open',
    p_title_key,
    p_title,
    p_body_key,
    p_body,
    p_action_kind,
    p_action_target_tab,
    coalesce(p_action_payload, '{}'::jsonb),
    coalesce(p_evidence, '{}'::jsonb),
    p_dedupe_key,
    now(),
    now(),
    null
  )
  on conflict (professional_id, dedupe_key) do update
  set
    professional_client_id = excluded.professional_client_id,
    alert_type = excluded.alert_type,
    severity = excluded.severity,
    title_key = excluded.title_key,
    title = excluded.title,
    body_key = excluded.body_key,
    body = excluded.body,
    action_kind = excluded.action_kind,
    action_target_tab = excluded.action_target_tab,
    action_payload = excluded.action_payload,
    evidence = excluded.evidence,
    updated_at = now(),
    resolved_at = null,
    detected_at = case
      when public.practice_alerts.status = 'resolved'
        or public.practice_alerts.resolved_at is not null
      then now()
      else public.practice_alerts.detected_at
    end,
    status = case
      when public.practice_alerts.status = 'dismissed' then 'dismissed'
      else 'open'
    end;
end;
$$;

create or replace function public.refresh_practice_alerts(p_professional_id uuid default null)
returns setof public.practice_alerts
language plpgsql
security definer
set search_path = public
as $$
declare
  v_requested_professional_id uuid;
  v_current_professional_id uuid;
  v_can_operate boolean;
  v_client_limit integer;
  v_connected_clients integer;
  v_active_dedupe_keys text[] := array[]::text[];
  v_row record;
begin
  v_current_professional_id := public.current_professional_id();

  if auth.uid() is null then
    if p_professional_id is null then
      raise exception 'Professional id is required';
    end if;
    v_requested_professional_id := p_professional_id;
  else
    if v_current_professional_id is null then
      raise exception 'Professional profile not found for current user';
    end if;

    if p_professional_id is not null and p_professional_id <> v_current_professional_id then
      raise exception 'Cannot refresh alerts for another professional';
    end if;

    v_requested_professional_id := coalesce(p_professional_id, v_current_professional_id);
  end if;

  select
    p.pro_status in ('trialing', 'active'),
    p.client_limit
  into
    v_can_operate,
    v_client_limit
  from public.professionals p
  where p.id = v_requested_professional_id;

  if not found then
    raise exception 'Professional % was not found', v_requested_professional_id;
  end if;

  select count(*)
  into v_connected_clients
  from public.professional_clients pc
  where pc.professional_id = v_requested_professional_id
    and pc.status = 'connected';

  if not v_can_operate then
    v_active_dedupe_keys := array_append(v_active_dedupe_keys, 'practice_blocked');
    perform public.upsert_practice_alert(
      v_requested_professional_id,
      null,
      'practice_blocked',
      'critical',
      'practice_alert.practice_blocked.title',
      'Practice requires billing attention',
      'practice_alert.practice_blocked.body',
      'Billing is not active, so new invites and plan operations are blocked.',
      'open_billing_panel',
      'billing-panel',
      jsonb_build_object('panel', 'billing-panel'),
      jsonb_build_object('client_limit', v_client_limit),
      'practice_blocked'
    );
  end if;

  if v_can_operate and v_connected_clients = 0 then
    v_active_dedupe_keys := array_append(v_active_dedupe_keys, 'no_connected_clients');
    perform public.upsert_practice_alert(
      v_requested_professional_id,
      null,
      'no_connected_clients',
      'medium',
      'practice_alert.no_connected_clients.title',
      'No connected clients yet',
      'practice_alert.no_connected_clients.body',
      'Invite the first client to start using the roster and follow-up workspace.',
      'open_invite_modal',
      null,
      '{}'::jsonb,
      jsonb_build_object('connected_clients', v_connected_clients),
      'no_connected_clients'
    );
  end if;

  for v_row in
    with connected_clients as (
      select
        pc.id as professional_client_id,
        pc.professional_id,
        pc.client_id,
        coalesce(nullif(pc.display_name, ''), left(pc.client_id::text, 8)) as client_label
      from public.professional_clients pc
      where pc.professional_id = v_requested_professional_id
        and pc.status = 'connected'
    ),
    latest_snapshot as (
      select distinct on (css.professional_client_id)
        css.professional_client_id,
        css.snapshot_date,
        css.synced_at
      from public.client_shared_snapshots css
      where css.professional_id = v_requested_professional_id
      order by css.professional_client_id, css.snapshot_date desc
    ),
    active_plan as (
      select distinct np.client_id
      from public.nutrition_plans np
      where np.professional_id = v_requested_professional_id
        and np.status = 'active'
    ),
    unread_messages as (
      select
        pcm.professional_client_id,
        count(*)::int as unread_count
      from public.professional_client_messages pcm
      where pcm.professional_id = v_requested_professional_id
        and pcm.author_role = 'client'
        and pcm.professional_read_at is null
      group by pcm.professional_client_id
    ),
    pending_checkins as (
      select
        cc.professional_client_id,
        count(*)::int as pending_count,
        max(cc.submitted_at) as latest_submitted_at
      from public.client_checkins cc
      where cc.professional_id = v_requested_professional_id
        and cc.reviewed_at is null
      group by cc.professional_client_id
    ),
    adherence as (
      select
        snap.professional_client_id,
        round(avg(snap.adherence_pct))::int as avg_adherence,
        max(snap.snapshot_date) as latest_snapshot_date
      from (
        select
          css.professional_client_id,
          css.snapshot_date,
          greatest(
            0,
            100 - round((abs(css.kcal_actual - css.kcal_target) / nullif(css.kcal_target, 0)) * 100)
          )::int as adherence_pct,
          row_number() over (
            partition by css.professional_client_id
            order by css.snapshot_date desc
          ) as snapshot_rank
        from public.client_shared_snapshots css
        where css.professional_id = v_requested_professional_id
          and css.kcal_target > 0
      ) snap
      where snap.snapshot_rank <= 7
      group by snap.professional_client_id
    )
    select
      cc.professional_client_id,
      cc.client_id,
      cc.client_label,
      ap.client_id is not null as has_active_plan,
      ls.snapshot_date as latest_snapshot_date,
      case
        when ls.snapshot_date is null then null
        else greatest(0, current_date - ls.snapshot_date)
      end as days_since_snapshot,
      coalesce(ad.avg_adherence, 100) as avg_adherence,
      coalesce(um.unread_count, 0) as unread_count,
      coalesce(pc.pending_count, 0) as pending_checkin_count,
      pc.latest_submitted_at
    from connected_clients cc
    left join latest_snapshot ls on ls.professional_client_id = cc.professional_client_id
    left join active_plan ap on ap.client_id = cc.client_id
    left join unread_messages um on um.professional_client_id = cc.professional_client_id
    left join pending_checkins pc on pc.professional_client_id = cc.professional_client_id
    left join adherence ad on ad.professional_client_id = cc.professional_client_id
  loop
    if not v_row.has_active_plan then
      v_active_dedupe_keys := array_append(
        v_active_dedupe_keys,
        'client_without_plan:' || v_row.professional_client_id::text
      );
      perform public.upsert_practice_alert(
        v_requested_professional_id,
        v_row.professional_client_id,
        'client_without_plan',
        'high',
        'practice_alert.client_without_plan.title',
        'Client without active plan',
        'practice_alert.client_without_plan.body',
        'Open the plan workspace and publish a plan for this client.',
        'open_client_tab',
        'plans',
        jsonb_build_object(
          'professional_client_id', v_row.professional_client_id,
          'client_id', v_row.client_id,
          'tab', 'plans'
        ),
        jsonb_build_object('client_label', v_row.client_label),
        'client_without_plan:' || v_row.professional_client_id::text
      );
    end if;

    if v_row.latest_snapshot_date is null or v_row.days_since_snapshot > 3 then
      v_active_dedupe_keys := array_append(
        v_active_dedupe_keys,
        'stale_snapshot:' || v_row.professional_client_id::text
      );
      perform public.upsert_practice_alert(
        v_requested_professional_id,
        v_row.professional_client_id,
        'stale_snapshot',
        'medium',
        'practice_alert.stale_snapshot.title',
        'Snapshot follow-up needed',
        'practice_alert.stale_snapshot.body',
        'This client has no recent shared snapshot to review.',
        'open_client_tab',
        case
          when v_row.latest_snapshot_date is null then 'summary'
          else 'diary'
        end,
        jsonb_build_object(
          'professional_client_id', v_row.professional_client_id,
          'client_id', v_row.client_id,
          'tab', case
            when v_row.latest_snapshot_date is null then 'summary'
            else 'diary'
          end
        ),
        jsonb_build_object(
          'client_label', v_row.client_label,
          'latest_snapshot_date', v_row.latest_snapshot_date,
          'days_since_snapshot', v_row.days_since_snapshot
        ),
        'stale_snapshot:' || v_row.professional_client_id::text
      );
    end if;

    if v_row.avg_adherence < 75 then
      v_active_dedupe_keys := array_append(
        v_active_dedupe_keys,
        'low_adherence:' || v_row.professional_client_id::text
      );
      perform public.upsert_practice_alert(
        v_requested_professional_id,
        v_row.professional_client_id,
        'low_adherence',
        'medium',
        'practice_alert.low_adherence.title',
        'Low adherence detected',
        'practice_alert.low_adherence.body',
        'Review the client summary to understand what is blocking adherence.',
        'open_client_tab',
        'summary',
        jsonb_build_object(
          'professional_client_id', v_row.professional_client_id,
          'client_id', v_row.client_id,
          'tab', 'summary'
        ),
        jsonb_build_object(
          'client_label', v_row.client_label,
          'avg_adherence', v_row.avg_adherence,
          'threshold', 75
        ),
        'low_adherence:' || v_row.professional_client_id::text
      );
    end if;

    if v_row.unread_count > 0 then
      v_active_dedupe_keys := array_append(
        v_active_dedupe_keys,
        'unread_messages:' || v_row.professional_client_id::text
      );
      perform public.upsert_practice_alert(
        v_requested_professional_id,
        v_row.professional_client_id,
        'unread_messages',
        'high',
        'practice_alert.unread_messages.title',
        'Unread client messages',
        'practice_alert.unread_messages.body',
        'Open the conversation and reply to clear the backlog.',
        'open_client_tab',
        'chat',
        jsonb_build_object(
          'professional_client_id', v_row.professional_client_id,
          'client_id', v_row.client_id,
          'tab', 'chat'
        ),
        jsonb_build_object(
          'client_label', v_row.client_label,
          'unread_count', v_row.unread_count
        ),
        'unread_messages:' || v_row.professional_client_id::text
      );
    end if;

    if v_row.pending_checkin_count > 0 then
      v_active_dedupe_keys := array_append(
        v_active_dedupe_keys,
        'pending_checkin_review:' || v_row.professional_client_id::text
      );
      perform public.upsert_practice_alert(
        v_requested_professional_id,
        v_row.professional_client_id,
        'pending_checkin_review',
        'high',
        'practice_alert.pending_checkin_review.title',
        'Pending check-in review',
        'practice_alert.pending_checkin_review.body',
        'Open recent check-ins and mark them as reviewed after triage.',
        'open_client_tab',
        'checkins',
        jsonb_build_object(
          'professional_client_id', v_row.professional_client_id,
          'client_id', v_row.client_id,
          'tab', 'checkins'
        ),
        jsonb_build_object(
          'client_label', v_row.client_label,
          'pending_checkin_count', v_row.pending_checkin_count,
          'latest_submitted_at', v_row.latest_submitted_at
        ),
        'pending_checkin_review:' || v_row.professional_client_id::text
      );
    end if;
  end loop;

  for v_row in
    select
      ci.id,
      ci.invite_code,
      ci.expires_at,
      extract(epoch from (ci.expires_at - now())) / 3600.0 as hours_until_expiry
    from public.client_invites ci
    where ci.professional_id = v_requested_professional_id
      and ci.status = 'pending'
      and ci.expires_at > now()
      and ci.expires_at <= now() + interval '48 hours'
  loop
    v_active_dedupe_keys := array_append(
      v_active_dedupe_keys,
      'pending_invite_expiring:' || v_row.id::text
    );
    perform public.upsert_practice_alert(
      v_requested_professional_id,
      null,
      'pending_invite_expiring',
      'low',
      'practice_alert.pending_invite_expiring.title',
      'Pending invite expires soon',
      'practice_alert.pending_invite_expiring.body',
      'Review the invite before it expires and send a new one if needed.',
      case
        when v_can_operate then 'open_invite_modal'
        else 'open_billing_panel'
      end,
      case
        when v_can_operate then null
        else 'billing-panel'
      end,
      jsonb_build_object(
        'invite_id', v_row.id,
        'invite_code', v_row.invite_code
      ),
      jsonb_build_object(
        'invite_code', v_row.invite_code,
        'expires_at', v_row.expires_at,
        'hours_until_expiry', round(v_row.hours_until_expiry)::int
      ),
      'pending_invite_expiring:' || v_row.id::text
    );
  end loop;

  update public.practice_alerts pa
  set
    status = 'resolved',
    resolved_at = now(),
    updated_at = now()
  where pa.professional_id = v_requested_professional_id
    and pa.status in ('open', 'dismissed')
    and (
      array_length(v_active_dedupe_keys, 1) is null
      or not (pa.dedupe_key = any(v_active_dedupe_keys))
    );

  return query
  select pa.*
  from public.practice_alerts pa
  where pa.professional_id = v_requested_professional_id
    and pa.status = 'open'
  order by
    public.practice_alert_severity_rank(pa.severity) desc,
    pa.detected_at desc;
end;
$$;

grant execute on function public.refresh_practice_alerts(uuid) to authenticated;
