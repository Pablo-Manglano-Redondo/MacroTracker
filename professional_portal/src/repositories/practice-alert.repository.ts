import { type SupabaseClient } from '@supabase/supabase-js';
import type { PracticeAlert } from '../types/database.types';

export const practiceAlertRepository = {
  listOpenAlerts: async (supabase: SupabaseClient, professionalId: string) => {
    const { data, error } = await supabase
      .from('practice_alerts')
      .select('*')
      .eq('professional_id', professionalId)
      .eq('status', 'open')
      .order('detected_at', { ascending: false });

    if (error) throw error;
    return (data ?? []) as PracticeAlert[];
  },

  listClientAlerts: async (supabase: SupabaseClient, professionalClientId: string) => {
    const { data, error } = await supabase
      .from('practice_alerts')
      .select('*')
      .eq('professional_client_id', professionalClientId)
      .eq('status', 'open')
      .order('detected_at', { ascending: false });

    if (error) throw error;
    return (data ?? []) as PracticeAlert[];
  },

  dismissAlert: async (supabase: SupabaseClient, alertId: string) => {
    const { error } = await supabase
      .from('practice_alerts')
      .update({ status: 'dismissed', resolved_at: null })
      .eq('id', alertId);

    if (error) throw error;
  },

  resolveAlert: async (supabase: SupabaseClient, alertId: string) => {
    const { error } = await supabase
      .from('practice_alerts')
      .update({ status: 'resolved', resolved_at: new Date().toISOString() })
      .eq('id', alertId);

    if (error) throw error;
  },

  refreshAlerts: async (supabase: SupabaseClient, professionalId: string) => {
    const { data, error } = await supabase.rpc('refresh_practice_alerts', {
      p_professional_id: professionalId,
    });

    if (error) throw error;
    return (data ?? []) as PracticeAlert[];
  },

  countResolvedToday: async (supabase: SupabaseClient, professionalId: string) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const { count, error } = await supabase
      .from('practice_alerts')
      .select('id', { count: 'exact', head: true })
      .eq('professional_id', professionalId)
      .eq('status', 'resolved')
      .gte('resolved_at', today.toISOString());

    if (error) throw error;
    return count ?? 0;
  },
};
