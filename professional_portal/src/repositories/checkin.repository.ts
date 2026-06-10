import { type SupabaseClient } from '@supabase/supabase-js';
import type { CheckinTemplate, ClientCheckin } from '../types/database.types';

export const checkinRepository = {
  listTemplates: async (supabase: SupabaseClient, professionalId: string) => {
    const { data, error } = await supabase
      .from('checkin_templates')
      .select('*')
      .eq('professional_id', professionalId)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data as CheckinTemplate[];
  },

  createTemplate: async (supabase: SupabaseClient, template: Partial<CheckinTemplate>) => {
    const { data, error } = await supabase
      .from('checkin_templates')
      .insert(template)
      .select()
      .single();
    if (error) throw error;
    return data as CheckinTemplate;
  },

  removeTemplate: async (supabase: SupabaseClient, id: string) => {
    const { error } = await supabase
      .from('checkin_templates')
      .delete()
      .eq('id', id);
    if (error) throw error;
  },

  listByClient: async (supabase: SupabaseClient, professionalClientId: string) => {
    const { data, error } = await supabase
      .from('client_checkins')
      .select('*')
      .eq('professional_client_id', professionalClientId)
      .order('submitted_at', { ascending: false });
    if (error) throw error;
    return data as ClientCheckin[];
  },

  requestCheckin: async (supabase: SupabaseClient, professionalId: string, clientId: string, professionalClientId: string) => {
    const { error } = await supabase.rpc('request_client_checkin', {
      p_professional_id: professionalId,
      p_client_id: clientId,
      p_professional_client_id: professionalClientId,
    });
    if (error) throw error;
  },
};
