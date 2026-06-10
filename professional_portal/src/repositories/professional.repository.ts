import { type SupabaseClient } from '@supabase/supabase-js';
import type { Professional } from '../types/database.types';

export const professionalRepository = {
  getByUserId: async (supabase: SupabaseClient, userId: string) => {
    const { data, error } = await supabase
      .from('professionals')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    if (error) throw error;
    return data as Professional | null;
  },

  upsert: async (
    supabase: SupabaseClient,
    payload: {
      user_id: string;
      display_name: string;
      business_name?: string;
    }
  ) => {
    const { error } = await supabase
      .from('professionals')
      .upsert(payload, { onConflict: 'user_id' });

    if (error) throw error;
  },
};
