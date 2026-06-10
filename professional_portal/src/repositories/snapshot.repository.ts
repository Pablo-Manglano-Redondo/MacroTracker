import { type SupabaseClient } from '@supabase/supabase-js';
import type { ClientSharedSnapshot } from '../types/database.types';

export const snapshotRepository = {
  update: async (supabase: SupabaseClient, id: string, updates: Partial<ClientSharedSnapshot>) => {
    const { data, error } = await supabase
      .from('client_shared_snapshots')
      .update(updates)
      .eq('id', id)
      .select()
      .single();
    if (error) throw error;
    return data as ClientSharedSnapshot;
  },

  remove: async (supabase: SupabaseClient, id: string) => {
    const { error } = await supabase
      .from('client_shared_snapshots')
      .delete()
      .eq('id', id);
    if (error) throw error;
  },
};
