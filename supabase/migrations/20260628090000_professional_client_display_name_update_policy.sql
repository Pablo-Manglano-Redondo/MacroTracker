drop policy if exists "professionals update own client display names"
on public.professional_clients;

create policy "professionals update own client display names"
on public.professional_clients for update
using (professional_id = public.current_professional_id())
with check (professional_id = public.current_professional_id());
