-- Update the notify_snapshot_received trigger function to fire on INSERT or UPDATE,
-- and only notify on UPDATE if the notes actually changed and are not empty.
create or replace function public.notify_snapshot_received()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if (TG_OP = 'INSERT') or (TG_OP = 'UPDATE' and coalesce(new.notes, '') <> coalesce(old.notes, '') and new.notes <> '') then
    insert into public.notifications (professional_id, type, title, body, metadata)
    values (
      new.professional_id,
      'snapshot_received',
      'Daily snapshot received',
      coalesce(
        case 
          when new.notes is not null and new.notes <> '' then new.notes
          else 'A client has shared their daily nutrition snapshot.'
        end,
        'A client has shared their daily nutrition snapshot.'
      ),
      jsonb_build_object(
        'snapshot_id', new.id,
        'client_id', new.client_id,
        'professional_client_id', new.professional_client_id,
        'weight_kg', new.weight_kg,
        'waist_cm', new.waist_cm,
        'notes', new.notes
      )
    );
  end if;
  return new;
end;
$$;

drop trigger if exists client_shared_snapshots_notify_received on public.client_shared_snapshots;

create trigger client_shared_snapshots_notify_received
  after insert or update on public.client_shared_snapshots
  for each row execute function public.notify_snapshot_received();
