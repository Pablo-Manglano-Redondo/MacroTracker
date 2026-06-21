create table if not exists public.client_diary_entries (
  id uuid primary key default gen_random_uuid(),
  professional_client_id uuid not null references public.professional_clients(id) on delete cascade,
  professional_id uuid not null references public.professionals(id) on delete cascade,
  client_id uuid not null references auth.users(id) on delete cascade,
  entry_date date not null,
  meal_type text not null check (meal_type in ('breakfast','lunch','dinner','snack')),
  meal_name text,
  meal_brands text,
  amount numeric not null default 1,
  unit text,
  kcal numeric,
  protein numeric,
  carbs numeric,
  fat numeric,
  sugars numeric,
  fiber numeric,
  saturated_fat numeric,
  source text,
  created_at timestamptz not null default now()
);

create index if not exists client_diary_entries_lookup_idx on public.client_diary_entries (professional_client_id, entry_date desc);

alter table public.client_diary_entries enable row level security;

create policy "Professionals read client diary entries"
  on public.client_diary_entries for select
  using (professional_id = public.current_professional_id());

create policy "Clients manage own diary entries"
  on public.client_diary_entries for all
  with check (client_id = auth.uid());
