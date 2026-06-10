import { useQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { professionalRepository } from '../../repositories/professional.repository';

export const useProfessional = (userId?: string) => {
  return useQuery({
    queryKey: ['professional', userId],
    queryFn: () => professionalRepository.getByUserId(supabase, userId!),
    enabled: !!userId,
    staleTime: 5 * 60_000,
  });
};
