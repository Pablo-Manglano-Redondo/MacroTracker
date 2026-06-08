create policy "professionals mark client messages as read"
on public.professional_client_messages for update
using (
  professional_id = public.current_professional_id()
  and exists (
    select 1
    from public.professional_clients pc
    where pc.id = professional_client_messages.professional_client_id
      and pc.professional_id = public.current_professional_id()
  )
)
with check (
  professional_id = public.current_professional_id()
);
