import { useQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { analyticsRepository } from '../../repositories/analytics.repository';

export const useRosterStats = (professionalId?: string) => {
  return useQuery({
    queryKey: ['analytics', 'roster', professionalId],
    queryFn: () => analyticsRepository.getRosterStats(supabase, professionalId!),
    enabled: !!professionalId,
    staleTime: 60_000,
  });
};

export const useAdherenceTrends = (professionalId?: string) => {
  return useQuery({
    queryKey: ['analytics', 'adherence', professionalId],
    queryFn: () => analyticsRepository.getAdherenceTrends(supabase, professionalId!),
    enabled: !!professionalId,
    staleTime: 60_000,
  });
};

export const usePerClientAdherence = (professionalId?: string) => {
  return useQuery({
    queryKey: ['analytics', 'per-client', professionalId],
    queryFn: () => analyticsRepository.getPerClientAdherence(supabase, professionalId!),
    enabled: !!professionalId,
    staleTime: 60_000,
  });
};
