-- Create app_feedback table
create table if not exists public.app_feedback (
  id uuid not null default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('bug', 'feature')),
  title text not null,
  description text not null,
  device_info jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone not null default now(),

  constraint app_feedback_pkey primary key (id)
);

-- Enable Row Level Security
alter table public.app_feedback enable row level security;

-- Policies
create policy "users insert own feedback"
  on public.app_feedback
  for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "users read own feedback"
  on public.app_feedback
  for select
  to authenticated
  using (user_id = auth.uid());
