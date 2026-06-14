import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { planRepository } from '../../repositories/plan.repository';
import { planQueryKeys } from '../queries/usePlans';
import type { MealInput } from './usePublishPlan';

export const useUpdatePlan = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({
      planId,
      payload,
    }: {
      planId: string;
      payload: {
        name?: string;
        objective?: string;
        status?: 'draft' | 'active' | 'archived';
        days?: {
          weekday: number;
          kcal_goal: number;
          protein_goal: number;
          carbs_goal: number;
          fat_goal: number;
        }[];
        meals?: MealInput[];
      };
    }) => {
      await planRepository.update(supabase, planId, payload);
      if (payload.meals) {
        await planRepository.replaceMeals(supabase, planId, payload.meals);
      }
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['plans'] });
      queryClient.invalidateQueries({ queryKey: planQueryKeys.plan(variables.planId) });
    },
  });
};
