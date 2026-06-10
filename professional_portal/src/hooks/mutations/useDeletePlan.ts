import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { planRepository } from '../../repositories/plan.repository';
import { planQueryKeys } from '../queries/usePlans';

export const useArchivePlan = (clientId?: string) => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (planId: string) => planRepository.archive(supabase, planId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: planQueryKeys.plans(clientId ?? '') });
    },
  });
};

export const useDeletePlan = (clientId?: string) => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (planId: string) => planRepository.delete(supabase, planId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: planQueryKeys.plans(clientId ?? '') });
    },
  });
};

export const useDuplicatePlan = (clientId?: string) => {
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
      queryClient.invalidateQueries({ queryKey: planQueryKeys.plans(clientId ?? '') });
    },
  });
};

export const useBatchArchivePlans = (clientId?: string) => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (planIds: string[]) => planRepository.batchArchive(supabase, planIds),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: planQueryKeys.plans(clientId ?? '') });
    },
  });
};
