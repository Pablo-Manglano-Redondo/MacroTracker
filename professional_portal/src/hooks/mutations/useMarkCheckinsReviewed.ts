import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { checkinRepository } from '../../repositories/checkin.repository';
import { practiceAlertRepository } from '../../repositories/practice-alert.repository';

export const useMarkCheckinsReviewed = (
  professionalClientId?: string,
  professionalId?: string,
) => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async () => {
      await checkinRepository.markPendingReviewed(supabase, professionalClientId!);
      if (professionalId) {
        await practiceAlertRepository.refreshAlerts(supabase, professionalId);
      }
    },
    onSuccess: () => {
      if (professionalClientId) {
        queryClient.invalidateQueries({ queryKey: ['client-checkins', professionalClientId] });
        queryClient.invalidateQueries({ queryKey: ['client-checkin-requests', professionalClientId] });
        queryClient.invalidateQueries({ queryKey: ['practice-alerts', 'client', professionalClientId] });
      }
      if (professionalId) {
        queryClient.invalidateQueries({ queryKey: ['pending-checkin-requests', professionalId] });
        queryClient.invalidateQueries({ queryKey: ['practice-alerts', professionalId, 'open'] });
        queryClient.invalidateQueries({ queryKey: ['practice-alerts', professionalId, 'resolved-today'] });
      }
    },
  });
};

export const useMarkSingleCheckinReviewed = (
  professionalClientId?: string,
  professionalId?: string,
) => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (checkinId: string) => {
      const { error } = await supabase
        .from('client_checkins')
        .update({ reviewed_at: new Date().toISOString() })
        .eq('id', checkinId);
      if (error) throw error;

      if (professionalId) {
        await practiceAlertRepository.refreshAlerts(supabase, professionalId);
      }
    },
    onSuccess: () => {
      if (professionalClientId) {
        queryClient.invalidateQueries({ queryKey: ['client-checkins', professionalClientId] });
        queryClient.invalidateQueries({ queryKey: ['client-checkin-requests', professionalClientId] });
        queryClient.invalidateQueries({ queryKey: ['practice-alerts', 'client', professionalClientId] });
      }
      if (professionalId) {
        queryClient.invalidateQueries({ queryKey: ['pending-checkin-requests', professionalId] });
        queryClient.invalidateQueries({ queryKey: ['practice-alerts', professionalId, 'open'] });
        queryClient.invalidateQueries({ queryKey: ['practice-alerts', professionalId, 'resolved-today'] });
      }
    },
  });
};
