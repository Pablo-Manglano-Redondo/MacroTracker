import { type SupabaseClient } from '@supabase/supabase-js';
import type { ProfessionalClient } from '../types/database.types';

const PAGE_SIZE = 10;

export const clientRepository = {
  listByProfessional: async (supabase: SupabaseClient, professionalId: string) => {
    const { data, error } = await supabase
      .from('professional_clients')
      .select(`
        id,
        professional_id,
        client_id,
        display_name,
        status,
        connected_at,
        sharing_mode,
        messages_enabled,
        client_shared_snapshots(*)
      `)
      .eq('professional_id', professionalId)
      .order('connected_at', { ascending: false });

    if (error) throw error;
    return data as unknown as ProfessionalClient[];
  },

  listByProfessionalPage: async (
    supabase: SupabaseClient,
    professionalId: string,
    page: number
  ) => {
    const from = page * PAGE_SIZE;
    const to = from + PAGE_SIZE - 1;

    const { data, error } = await supabase
      .from('professional_clients')
      .select(`
        id,
        professional_id,
        client_id,
        status,
        connected_at,
        sharing_mode,
        messages_enabled,
        client_shared_snapshots(*)
      `)
      .eq('professional_id', professionalId)
      .order('connected_at', { ascending: false })
      .range(from, to);

    if (error) throw error;
    return data as unknown as ProfessionalClient[];
  },

  getClientInfo: async (supabase: SupabaseClient, clientIds: string[]) => {
    if (clientIds.length === 0) return [];
    const { data, error } = await supabase.rpc('get_client_info', { client_ids: clientIds });
    if (error) throw error;
    return (data ?? []) as { id: string; email: string; display_name: string | null }[];
  },

  updateDisplayName: async (supabase: SupabaseClient, id: string, displayName: string) => {
    const { error } = await supabase
      .from('professional_clients')
      .update({ display_name: displayName || null })
      .eq('id', id);
    if (error) throw error;
  },

  getUnreadCounts: async (supabase: SupabaseClient, professionalId: string) => {
    const { data, error } = await supabase
      .from('professional_client_messages')
      .select('professional_client_id, id')
      .eq('professional_id', professionalId)
      .eq('author_role', 'client')
      .is('professional_read_at', null);

    if (error) throw error;

    const unreadMap: Record<string, number> = {};
    if (data) {
      for (const m of data) {
        unreadMap[m.professional_client_id] = (unreadMap[m.professional_client_id] ?? 0) + 1;
      }
    }
    return unreadMap;
  },
};
