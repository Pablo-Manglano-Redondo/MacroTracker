-- Professional Recipe Library
create table if not exists public.professional_recipes (
  id uuid primary key default gen_random_uuid(),
  professional_id uuid not null references public.professionals(id) on delete cascade,
  title text not null,
  description text,
  meal_type text check (meal_type in ('breakfast','lunch','dinner','snack')),
  prep_time_min integer,
  cook_time_min integer,
  servings integer default 1,
  kcal numeric,
  protein numeric,
  carbs numeric,
  fat numeric,
  ingredients jsonb default '[]'::jsonb,
  instructions text,
  image_url text,
  source_url text,
  is_favorite boolean default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Proposed Recipes (sent to specific clients)
create table if not exists public.client_proposed_recipes (
  id uuid primary key default gen_random_uuid(),
  professional_client_id uuid not null references public.professional_clients(id) on delete cascade,
  recipe_id uuid not null references public.professional_recipes(id) on delete cascade,
  professional_id uuid not null references public.professionals(id) on delete cascade,
  client_id uuid not null references auth.users(id) on delete cascade,
  note text,
  status text not null default 'pending' check (status in ('pending','saved','declined')),
  created_at timestamptz not null default now()
);

-- Private Client Notes
create table if not exists public.client_notes (
  id uuid primary key default gen_random_uuid(),
  professional_client_id uuid not null references public.professional_clients(id) on delete cascade,
  professional_id uuid not null references public.professionals(id) on delete cascade,
  title text not null default 'Note',
  body text not null,
  category text default 'general' check (category in ('general','assessment','medical','progress','billing','other')),
  pinned boolean default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Client Progress Tracking (weight, body fat, measurements, photos)
create table if not exists public.client_progress (
  id uuid primary key default gen_random_uuid(),
  professional_client_id uuid not null references public.professional_clients(id) on delete cascade,
  professional_id uuid not null references public.professionals(id) on delete cascade,
  client_id uuid not null references auth.users(id) on delete cascade,
  record_date date not null default current_date,
  weight_kg numeric,
  body_fat_pct numeric,
  waist_cm numeric,
  hip_cm numeric,
  chest_cm numeric,
  arm_cm numeric,
  thigh_cm numeric,
  photo_urls jsonb default '[]'::jsonb,
  energy_level integer check (energy_level between 1 and 10),
  sleep_hours numeric,
  notes text,
  source text not null default 'professional' check (source in ('professional','client','sync')),
  created_at timestamptz not null default now(),
  unique (professional_client_id, record_date, source)
);

-- Weekly Check-in Forms (templates for structured check-ins)
create table if not exists public.checkin_templates (
  id uuid primary key default gen_random_uuid(),
  professional_id uuid not null references public.professionals(id) on delete cascade,
  title text not null,
  questions jsonb not null default '[]'::jsonb,
  is_default boolean default false,
  created_at timestamptz not null default now()
);

-- Check-in responses from clients
create table if not exists public.client_checkins (
  id uuid primary key default gen_random_uuid(),
  professional_client_id uuid not null references public.professional_clients(id) on delete cascade,
  template_id uuid references public.checkin_templates(id),
  professional_id uuid not null references public.professionals(id) on delete cascade,
  client_id uuid not null references auth.users(id) on delete cascade,
  answers jsonb not null default '{}'::jsonb,
  energy_level integer check (energy_level between 1 and 10),
  sleep_avg numeric,
  mood text,
  notes text,
  submitted_at timestamptz not null default now()
);

-- Plan Templates (reusable plan definitions)
create table if not exists public.plan_templates (
  id uuid primary key default gen_random_uuid(),
  professional_id uuid not null references public.professionals(id) on delete cascade,
  name text not null,
  description text,
  duration_days integer not null default 7,
  objective text default 'general_fitness',
  meals jsonb default '[]'::jsonb,
  tags text[] default '{}',
  use_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Indexes
create index if not exists professional_recipes_professional_idx on public.professional_recipes (professional_id);
create index if not exists professional_recipes_meal_type_idx on public.professional_recipes (meal_type);
create index if not exists client_proposed_recipes_client_idx on public.client_proposed_recipes (professional_client_id, status);
create index if not exists client_notes_client_idx on public.client_notes (professional_client_id, pinned desc, created_at desc);
create index if not exists client_notes_category_idx on public.client_notes (category);
create index if not exists client_progress_client_date_idx on public.client_progress (professional_client_id, record_date desc);
create index if not exists client_checkins_client_date_idx on public.client_checkins (professional_client_id, submitted_at desc);
create index if not exists plan_templates_professional_idx on public.plan_templates (professional_id);

-- Enable RLS
alter table public.professional_recipes enable row level security;
alter table public.client_proposed_recipes enable row level security;
alter table public.client_notes enable row level security;
alter table public.client_progress enable row level security;
alter table public.checkin_templates enable row level security;
alter table public.client_checkins enable row level security;
alter table public.plan_templates enable row level security;

-- RLS policies: professionals manage their own data, clients read their own
create policy "Professionals manage own recipes"
  on public.professional_recipes for all
  using (professional_id = public.current_professional_id())
  with check (professional_id = public.current_professional_id());

create policy "Professionals manage proposed recipes"
  on public.client_proposed_recipes for all
  using (professional_id = public.current_professional_id())
  with check (professional_id = public.current_professional_id());

create policy "Clients read proposed recipes"
  on public.client_proposed_recipes for select
  using (client_id = auth.uid());

create policy "Professionals manage client notes"
  on public.client_notes for all
  using (professional_id = public.current_professional_id())
  with check (professional_id = public.current_professional_id());

create policy "Professionals manage client progress"
  on public.client_progress for all
  using (professional_id = public.current_professional_id())
  with check (professional_id = public.current_professional_id());

create policy "Clients read own progress"
  on public.client_progress for select
  using (client_id = auth.uid());

create policy "Clients insert own progress"
  on public.client_progress for insert
  with check (client_id = auth.uid() and source = 'client');

create policy "Professionals manage checkin templates"
  on public.checkin_templates for all
  using (professional_id = public.current_professional_id())
  with check (professional_id = public.current_professional_id());

create policy "Professionals read client checkins"
  on public.client_checkins for select
  using (professional_id = public.current_professional_id());

create policy "Clients read own checkins"
  on public.client_checkins for select
  using (client_id = auth.uid());

create policy "Clients submit checkins"
  on public.client_checkins for insert
  with check (client_id = auth.uid());

create policy "Professionals manage plan templates"
  on public.plan_templates for all
  using (professional_id = public.current_professional_id())
  with check (professional_id = public.current_professional_id());

-- Triggers for updated_at
create trigger professional_recipes_set_updated_at
  before update on public.professional_recipes
  for each row execute function public.set_updated_at();

create trigger client_notes_set_updated_at
  before update on public.client_notes
  for each row execute function public.set_updated_at();

create trigger plan_templates_set_updated_at
  before update on public.plan_templates
  for each row execute function public.set_updated_at();

-- Function + view: client progress summary
create or replace function public.get_client_progress_summary(p_client_id uuid)
returns table (
  latest_weight numeric,
  weight_change_30d numeric,
  latest_body_fat numeric,
  checkin_count bigint,
  last_checkin timestamptz,
  recipe_count bigint,
  note_count bigint
) language sql stable security definer set search_path = public as $$
  select
    (select weight_kg from public.client_progress cp
     where cp.client_id = p_client_id
       and cp.source in ('professional','client')
     order by cp.record_date desc limit 1),
    (select weight_kg from public.client_progress cp
     where cp.client_id = p_client_id
       and cp.source in ('professional','client')
       and cp.record_date >= current_date - 30
     order by cp.record_date asc limit 1) -
    (select weight_kg from public.client_progress cp
     where cp.client_id = p_client_id
       and cp.source in ('professional','client')
     order by cp.record_date desc limit 1),
    (select body_fat_pct from public.client_progress cp
     where cp.client_id = p_client_id
     order by cp.record_date desc limit 1),
    (select count(*) from public.client_checkins cc where cc.client_id = p_client_id),
    (select max(cc.submitted_at) from public.client_checkins cc where cc.client_id = p_client_id),
    (select count(*) from public.client_proposed_recipes cpr where cpr.client_id = p_client_id),
    (select count(*) from public.client_notes cn
     join public.professional_clients pc on pc.id = cn.professional_client_id
     where pc.client_id = p_client_id)
$$;
