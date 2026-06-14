import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { planRepository } from '../../repositories/plan.repository';

export const useArchivePlan = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (planId: string) => planRepository.archive(supabase, planId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['plans'] });
    },
  });
};

export const useDeletePlan = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (planId: string) => planRepository.delete(supabase, planId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['plans'] });
    },
  });
};

export const useDuplicatePlan = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      professionalId,
      clientId,
      planId,
      newName,
    }: {
      professionalId: string;
      clientId: string;
      planId: string;
      newName?: string;
    }) => planRepository.duplicate(supabase, professionalId, clientId, planId, newName),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['plans'] });
    },
  });
};

export const useBatchArchivePlans = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (planIds: string[]) => planRepository.batchArchive(supabase, planIds),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['plans'] });
    },
  });
};
