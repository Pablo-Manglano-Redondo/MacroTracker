import { createClient } from '@supabase/supabase-js';
import { supabaseConfig } from '../config';

if (!supabaseConfig.url || !supabaseConfig.anonKey) {
  console.warn('Supabase configuration is missing. Ensure config.js exists or environment variables are set.');
}

export const supabase = createClient(supabaseConfig.url, supabaseConfig.anonKey);
