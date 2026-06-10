import { type SupabaseClient } from '@supabase/supabase-js';

export interface Notification {
  id: string;
  professional_id: string;
  type: 'client_connected' | 'snapshot_received' | 'checkin_submitted' | 'message_received' | 'plan_activated' | 'system';
  title: string;
  body: string | null;
  metadata: Record<string, any>;
  read: boolean;
  created_at: string;
}

function notifyTableError(err: unknown): boolean {
  return (err as any)?.code === 'PGRST116' || (err as any)?.message?.includes('relation "notifications" does not exist');
}

export const notificationRepository = {
  listByProfessional: async (supabase: SupabaseClient, professionalId: string) => {
    const { data, error } = await supabase
      .from('notifications')
      .select('*')
      .eq('professional_id', professionalId)
      .order('created_at', { ascending: false })
      .limit(50);
    if (error && !notifyTableError(error)) throw error;
    return (data ?? []) as Notification[];
  },

  unreadCount: async (supabase: SupabaseClient, professionalId: string) => {
    const { count, error } = await supabase
      .from('notifications')
      .select('id', { count: 'exact', head: true })
      .eq('professional_id', professionalId)
      .eq('read', false);
    if (error && !notifyTableError(error)) throw error;
    return count ?? 0;
  },

  markRead: async (supabase: SupabaseClient, id: string) => {
    const { error } = await supabase.rpc('mark_notification_read', { p_id: id });
    if (error) throw error;
  },

  markAllRead: async (supabase: SupabaseClient, professionalId: string) => {
    const { error } = await supabase.rpc('mark_all_notifications_read', { p_professional_id: professionalId });
    if (error) throw error;
  },
};
