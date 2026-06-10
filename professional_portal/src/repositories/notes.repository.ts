import { type SupabaseClient } from '@supabase/supabase-js';
import type { ClientNote } from '../types/database.types';

export const notesRepository = {
  listByClient: async (supabase: SupabaseClient, professionalClientId: string) => {
    const { data, error } = await supabase
      .from('client_notes')
      .select('*')
      .eq('professional_client_id', professionalClientId)
      .order('pinned', { ascending: false })
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data as ClientNote[];
  },

  create: async (supabase: SupabaseClient, note: Partial<ClientNote>) => {
    const { data, error } = await supabase
      .from('client_notes')
      .insert(note)
      .select()
      .single();
    if (error) throw error;
    return data as ClientNote;
  },

  update: async (supabase: SupabaseClient, id: string, updates: Partial<ClientNote>) => {
    const { data, error } = await supabase
      .from('client_notes')
      .update(updates)
      .eq('id', id)
      .select()
      .single();
    if (error) throw error;
    return data as ClientNote;
  },

  remove: async (supabase: SupabaseClient, id: string) => {
    const { error } = await supabase
      .from('client_notes')
      .delete()
      .eq('id', id);
    if (error) throw error;
  },
};
