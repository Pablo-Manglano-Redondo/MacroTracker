import { type SupabaseClient } from '@supabase/supabase-js';
import type { ProfessionalClientMessage } from '../types/database.types';

export const messageRepository = {
  listByRelationship: async (supabase: SupabaseClient, professionalClientId: string) => {
    const { data, error } = await supabase
      .from('professional_client_messages')
      .select('*')
      .eq('professional_client_id', professionalClientId)
      .order('created_at', { ascending: true });

    if (error) throw error;
    return (data ?? []) as ProfessionalClientMessage[];
  },

  send: async (
    supabase: SupabaseClient,
    payload: {
      professional_client_id: string;
      professional_id: string;
      client_id: string;
      body: string;
    }
  ) => {
    const { error } = await supabase
      .from('professional_client_messages')
      .insert({
        professional_client_id: payload.professional_client_id,
        professional_id: payload.professional_id,
        client_id: payload.client_id,
        author_role: 'professional',
        body: payload.body,
      });

    if (error) throw error;
  },

  markAsRead: async (
    supabase: SupabaseClient,
    messageIds: string[],
    role: 'professional' | 'client' = 'professional'
  ) => {
    if (messageIds.length === 0) return;

    const updateField = role === 'professional' ? 'professional_read_at' : 'client_read_at';
    const { error } = await supabase
      .from('professional_client_messages')
      .update({ [updateField]: new Date().toISOString() })
      .in('id', messageIds);

    if (error) throw error;
  },

  subscribeToNewMessages: (
    supabase: SupabaseClient,
    professionalClientId: string,
    onMessage: (message: ProfessionalClientMessage) => void
  ) => {
    const channel = supabase
      .channel(`messages-relationship:${professionalClientId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'professional_client_messages',
          filter: `professional_client_id=eq.${professionalClientId}`,
        },
        (payload) => {
          onMessage(payload.new as ProfessionalClientMessage);
        }
      )
      .subscribe();

    return channel;
  },
};
