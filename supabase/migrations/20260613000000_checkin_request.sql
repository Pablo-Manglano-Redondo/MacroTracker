-- RPC: Professional requests a check-in from client
create or replace function public.request_client_checkin(
  p_professional_id uuid,
  p_client_id uuid,
  p_professional_client_id uuid
) returns void language plpgsql security definer set search_path = public as $$
begin
  -- Notification for professional's bell (type 'system' is valid)
  insert into public.notifications (professional_id, type, title, body, metadata)
  values (
    p_professional_id,
    'system',
    'Check-in requested',
    'A check-in request was sent to the client.',
    jsonb_build_object(
      'professional_client_id', p_professional_client_id,
      'client_id', p_client_id
    )
  );

  -- Push notification to client via existing pg_net dispatch
  perform public.dispatch_push_notification(
    p_client_id,
    'Check-in Requested',
    'Your nutritionist has requested a check-in. Please submit your weekly update.',
    jsonb_build_object('type', 'checkin_requested')
  );
end;
$$;
