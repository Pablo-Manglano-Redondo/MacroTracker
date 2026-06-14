import { type SupabaseClient } from '@supabase/supabase-js';
import type { ClientDiaryEntry } from '../types/database.types';

export const diaryRepository = {
  listByClient: async (
    supabase: SupabaseClient,
    professionalClientId: string,
  ): Promise<ClientDiaryEntry[]> => {
    const { data, error } = await supabase
      .from('client_diary_entries')
      .select('*')
      .eq('professional_client_id', professionalClientId)
      .order('entry_date', { ascending: false })
      .order('created_at', { ascending: true });
    if (error) throw error;
    return data ?? [];
  },

  listByClientAndDate: async (
    supabase: SupabaseClient,
    professionalClientId: string,
    date: string,
  ): Promise<ClientDiaryEntry[]> => {
    const { data, error } = await supabase
      .from('client_diary_entries')
      .select('*')
      .eq('professional_client_id', professionalClientId)
      .eq('entry_date', date)
      .order('created_at', { ascending: true });
    if (error) throw error;
    return data ?? [];
  },
};
