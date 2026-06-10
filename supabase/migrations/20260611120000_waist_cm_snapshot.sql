-- Add waist_cm to client_shared_snapshots
alter table if exists public.client_shared_snapshots
  add column if not exists waist_cm numeric;

-- Update the notify_snapshot_received trigger to include waist_cm in metadata
create or replace function public.notify_snapshot_received()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.notifications (professional_id, type, title, body, metadata)
  values (
    new.professional_id,
    'snapshot_received',
    'Daily snapshot received',
    'A client has shared their daily nutrition snapshot.',
    jsonb_build_object(
      'snapshot_id', new.id,
      'client_id', new.client_id,
      'professional_client_id', new.professional_client_id,
      'weight_kg', new.weight_kg,
      'waist_cm', new.waist_cm
    )
  );
  return new;
end;
$$;
