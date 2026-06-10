import { useQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { progressRepository } from '../../repositories/progress.repository';

export function useClientProgress(professionalClientId: string | undefined) {
  return useQuery({
    queryKey: ['client-progress', professionalClientId],
    queryFn: () => progressRepository.listByClient(supabase, professionalClientId!),
    enabled: !!professionalClientId,
    staleTime: 15_000,
  });
}

export function useClientProgressSummary(clientId: string | undefined) {
  return useQuery({
    queryKey: ['client-progress-summary', clientId],
    queryFn: () => progressRepository.getSummary(supabase, clientId!),
    enabled: !!clientId,
    staleTime: 30_000,
  });
}
