import { type SupabaseClient } from '@supabase/supabase-js';
import type { ClientProgress, ClientProgressSummary } from '../types/database.types';

export const progressRepository = {
  listByClient: async (supabase: SupabaseClient, professionalClientId: string) => {
    const { data, error } = await supabase
      .from('client_progress')
      .select('*')
      .eq('professional_client_id', professionalClientId)
      .order('record_date', { ascending: false });
    if (error) throw error;
    return data as ClientProgress[];
  },

  create: async (supabase: SupabaseClient, record: Partial<ClientProgress>) => {
    const { data, error } = await supabase
      .from('client_progress')
      .insert(record)
      .select()
      .single();
    if (error) throw error;
    return data as ClientProgress;
  },

  update: async (supabase: SupabaseClient, id: string, updates: Partial<ClientProgress>) => {
    const { data, error } = await supabase
      .from('client_progress')
      .update(updates)
      .eq('id', id)
      .select()
      .single();
    if (error) throw error;
    return data as ClientProgress;
  },

  remove: async (supabase: SupabaseClient, id: string) => {
    const { error } = await supabase
      .from('client_progress')
      .delete()
      .eq('id', id);
    if (error) throw error;
  },

  getSummary: async (supabase: SupabaseClient, clientId: string) => {
    const { data, error } = await supabase
      .rpc('get_client_progress_summary', { p_client_id: clientId });
    if (error) throw error;
    return data as unknown as ClientProgressSummary;
  },
};
