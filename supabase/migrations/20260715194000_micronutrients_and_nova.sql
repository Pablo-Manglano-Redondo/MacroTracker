-- Migration: Add micronutrients, NOVA group, and quality score to diary entries

ALTER TABLE public.client_diary_entries
  ADD COLUMN IF NOT EXISTS sodium numeric,
  ADD COLUMN IF NOT EXISTS potassium numeric,
  ADD COLUMN IF NOT EXISTS calcium numeric,
  ADD COLUMN IF NOT EXISTS iron numeric,
  ADD COLUMN IF NOT EXISTS vitamin_c numeric,
  ADD COLUMN IF NOT EXISTS vitamin_d numeric,
  ADD COLUMN IF NOT EXISTS nova_group smallint,
  ADD COLUMN IF NOT EXISTS quality_score numeric;
