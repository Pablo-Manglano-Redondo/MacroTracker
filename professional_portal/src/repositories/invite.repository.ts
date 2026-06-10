import { type SupabaseClient } from '@supabase/supabase-js';
import type { ClientInvite } from '../types/database.types';

export const inviteRepository = {
  create: async (supabase: SupabaseClient, professionalId: string) => {
    const code = crypto.randomUUID().slice(0, 8).toUpperCase();
    const expiresAt = new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString();

    const { data, error } = await supabase.from('client_invites').insert({
      professional_id: professionalId,
      invite_code: code,
      expires_at: expiresAt,
    }).select().single();

    if (error) throw error;
    return data as ClientInvite;
  },

  list: async (supabase: SupabaseClient, professionalId: string) => {
    const { data, error } = await supabase
      .from('client_invites')
      .select('*')
      .eq('professional_id', professionalId)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data as ClientInvite[];
  },
};
