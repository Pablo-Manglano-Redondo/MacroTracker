import { useQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { checkinRepository } from '../../repositories/checkin.repository';

export function useCheckinTemplates(professionalId: string | undefined) {
  return useQuery({
    queryKey: ['checkin-templates', professionalId],
    queryFn: () => checkinRepository.listTemplates(supabase, professionalId!),
    enabled: !!professionalId,
    staleTime: 60_000,
  });
}

export function useClientCheckins(professionalClientId: string | undefined) {
  return useQuery({
    queryKey: ['client-checkins', professionalClientId],
    queryFn: () => checkinRepository.listByClient(supabase, professionalClientId!),
    enabled: !!professionalClientId,
    staleTime: 15_000,
  });
}
