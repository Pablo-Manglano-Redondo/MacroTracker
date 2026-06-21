-- RLS policy to allow clients to read recipes created by their connected professional
create policy "Clients read professional recipes"
  on public.professional_recipes for select
  using (
    exists (
      select 1 from public.professional_clients pc
      where pc.professional_id = professional_recipes.professional_id
        and pc.client_id = auth.uid()
        and pc.status = 'connected'
    )
  );
