import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { practiceAlertRepository } from '../../repositories/practice-alert.repository';
import { practiceAlertsEnabled } from '../../config';

const queryKeys = {
  open: (professionalId: string) => ['practice-alerts', professionalId, 'open'] as const,
  client: (professionalClientId: string) => ['practice-alerts', 'client', professionalClientId] as const,
  resolvedToday: (professionalId: string) => ['practice-alerts', professionalId, 'resolved-today'] as const,
};

export const useOpenPracticeAlerts = (professionalId?: string) => {
  return useQuery({
    queryKey: queryKeys.open(professionalId ?? ''),
    queryFn: () => practiceAlertRepository.listOpenAlerts(supabase, professionalId!),
    enabled: !!professionalId && practiceAlertsEnabled,
    staleTime: 15_000,
  });
};

export const useClientPracticeAlerts = (professionalClientId?: string) => {
  return useQuery({
    queryKey: queryKeys.client(professionalClientId ?? ''),
    queryFn: () => practiceAlertRepository.listClientAlerts(supabase, professionalClientId!),
    enabled: !!professionalClientId && practiceAlertsEnabled,
    staleTime: 15_000,
  });
};

export const useResolvedPracticeAlertsToday = (professionalId?: string) => {
  return useQuery({
    queryKey: queryKeys.resolvedToday(professionalId ?? ''),
    queryFn: () => practiceAlertRepository.countResolvedToday(supabase, professionalId!),
    enabled: !!professionalId && practiceAlertsEnabled,
    staleTime: 30_000,
  });
};

export const useDismissPracticeAlert = (professionalId?: string) => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (alertId: string) => practiceAlertRepository.dismissAlert(supabase, alertId),
    onSuccess: () => {
      if (!professionalId) return;
      queryClient.invalidateQueries({ queryKey: queryKeys.open(professionalId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.resolvedToday(professionalId) });
    },
  });
};

export const useResolvePracticeAlert = (professionalId?: string) => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (alertId: string) => practiceAlertRepository.resolveAlert(supabase, alertId),
    onSuccess: () => {
      if (!professionalId) return;
      queryClient.invalidateQueries({ queryKey: queryKeys.open(professionalId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.resolvedToday(professionalId) });
    },
  });
};

export const useRefreshPracticeAlerts = (professionalId?: string) => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: () => practiceAlertRepository.refreshAlerts(supabase, professionalId!),
    onSuccess: () => {
      if (!professionalId) return;
      queryClient.invalidateQueries({ queryKey: queryKeys.open(professionalId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.resolvedToday(professionalId) });
      queryClient.invalidateQueries({ queryKey: ['clients', professionalId] });
    },
  });
};

export { queryKeys as practiceAlertQueryKeys };
