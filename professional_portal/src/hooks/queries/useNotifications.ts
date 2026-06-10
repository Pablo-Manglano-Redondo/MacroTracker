import { useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { notificationRepository } from '../../repositories/notification.repository';

export function useNotifications(professionalId: string | undefined) {
  return useQuery({
    queryKey: ['notifications', professionalId],
    queryFn: () => notificationRepository.listByProfessional(supabase, professionalId!),
    enabled: !!professionalId,
    staleTime: 15_000,
    refetchInterval: 30_000,
  });
}

export function useUnreadNotificationCount(professionalId: string | undefined) {
  return useQuery({
    queryKey: ['notifications', 'unread', professionalId],
    queryFn: () => notificationRepository.unreadCount(supabase, professionalId!),
    enabled: !!professionalId,
    staleTime: 10_000,
    refetchInterval: 15_000,
  });
}

export function useMarkNotificationRead(professionalId: string | undefined) {
  const queryClient = useQueryClient();
  return {
    markRead: async (id: string) => {
      await notificationRepository.markRead(supabase, id);
      queryClient.invalidateQueries({ queryKey: ['notifications', professionalId] });
      queryClient.invalidateQueries({ queryKey: ['notifications', 'unread', professionalId] });
    },
    markAllRead: async () => {
      if (!professionalId) return;
      await notificationRepository.markAllRead(supabase, professionalId);
      queryClient.invalidateQueries({ queryKey: ['notifications', professionalId] });
      queryClient.invalidateQueries({ queryKey: ['notifications', 'unread', professionalId] });
    },
  };
}
