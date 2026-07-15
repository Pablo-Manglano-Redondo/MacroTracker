-- Alter professional_clients table to add avatar_url
alter table public.professional_clients
add column if not exists avatar_url text;

-- Update try_set_client_display_name trigger function to also fetch avatar_url
create or replace function public.try_set_client_display_name()
returns trigger
language plpgsql security definer
set search_path = public
as $$
begin
  if new.display_name is null then
    new.display_name := (
      select coalesce(
        nullif(u.raw_user_meta_data ->> 'full_name', ''),
        nullif(u.raw_user_meta_data ->> 'name', ''),
        nullif(u.raw_user_meta_data ->> 'preferred_name', ''),
        u.email
      )
      from auth.users u
      where u.id = new.client_id
    );
  end if;

  new.avatar_url := (
    select coalesce(
      nullif(u.raw_user_meta_data ->> 'avatar_url', ''),
      nullif(u.raw_user_meta_data ->> 'picture', '')
    )
    from auth.users u
    where u.id = new.client_id
  );
  
  return new;
end;
$$;

-- Also update existing clients' avatar_urls
update public.professional_clients
set avatar_url = (
  select coalesce(
    nullif(u.raw_user_meta_data ->> 'avatar_url', ''),
    nullif(u.raw_user_meta_data ->> 'picture', '')
  )
  from auth.users u
  where u.id = client_id
)
where avatar_url is null;

-- Create public storage bucket for client avatars if not exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('client-avatars', 'client-avatars', true)
ON CONFLICT (id) DO NOTHING;

-- RLS policies for storage.objects under the 'client-avatars' bucket
CREATE POLICY "Public select access for client avatars"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'client-avatars');

CREATE POLICY "Clients can upload their own avatars"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'client-avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Clients can update their own avatars"
  ON storage.objects FOR UPDATE
  WITH CHECK (
    bucket_id = 'client-avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Clients can delete their own avatars"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'client-avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
