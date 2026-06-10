import { useMutation } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { planRepository } from '../../repositories/plan.repository';

export interface MealInput {
  slot: string;
  title: string;
  kcal?: number | null;
  protein?: number | null;
  carbs?: number | null;
  fat?: number | null;
  notes?: string | null;
  recipe_id?: string | null;
}

export const usePublishPlan = () => {
  return useMutation({
    mutationFn: async (payload: {
      professional_id: string;
      client_id: string;
      name: string;
      kcal: number;
      protein: number;
      carbs: number;
      fat: number;
      meals?: MealInput[];
    }) => {
      const plan = await planRepository.create(supabase, {
        professional_id: payload.professional_id,
        client_id: payload.client_id,
        name: payload.name,
      });

      await planRepository.createDays(supabase, plan.id, {
        kcal: payload.kcal,
        protein: payload.protein,
        carbs: payload.carbs,
        fat: payload.fat,
      });

      if (payload.meals && payload.meals.length > 0) {
        await planRepository.createMeals(supabase, plan.id, payload.meals);
      }

      return plan;
    },
  });
};
