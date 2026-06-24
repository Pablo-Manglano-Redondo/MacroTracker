-- Alter professionals table to add avatar_url
ALTER TABLE public.professionals ADD COLUMN IF NOT EXISTS avatar_url text;

-- Create public storage bucket for professional avatars if not exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('professional-avatars', 'professional-avatars', true)
ON CONFLICT (id) DO NOTHING;

-- RLS policies for storage.objects under the 'professional-avatars' bucket

CREATE POLICY "Public select access for professional avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'professional-avatars');

CREATE POLICY "Professionals can upload their own avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'professional-avatars'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Professionals can update their own avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'professional-avatars'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Professionals can delete their own avatars"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'professional-avatars'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
