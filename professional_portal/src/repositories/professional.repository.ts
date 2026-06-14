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
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      throw new Error('Auth session is missing. Sign in again before saving the profile.');
    }

    if (user.id !== payload.user_id) {
      throw new Error('Auth session is out of sync with the profile form. Sign in again and retry.');
    }

    const { error } = await supabase
      .from('professionals')
      .upsert(payload, { onConflict: 'user_id' });

    if (error) throw error;
  },
};
