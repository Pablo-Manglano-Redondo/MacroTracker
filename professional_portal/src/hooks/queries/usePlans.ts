import { useQuery, useInfiniteQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { planRepository, type NutritionPlan } from '../../repositories/plan.repository';

const queryKeys = {
  plans: (professionalId: string, clientId: string) => ['plans', professionalId, clientId] as const,
  plan: (planId: string) => ['plan', planId] as const,
};

export const usePlans = (clientId?: string, professionalId?: string) => {
  return useQuery({
    queryKey: queryKeys.plans(professionalId ?? '', clientId ?? ''),
    queryFn: () => planRepository.listByClient(supabase, professionalId!, clientId!),
    enabled: !!clientId && !!professionalId,
    staleTime: 30_000,
  });
};

export const useInfinitePlans = (clientId?: string, professionalId?: string) => {
  return useInfiniteQuery({
    queryKey: [...queryKeys.plans(professionalId ?? '', clientId ?? ''), 'infinite'],
    queryFn: async ({ pageParam = 0 }: { pageParam: number }) => {
      const { data, error } = await supabase
        .from('nutrition_plans')
        .select('*')
        .eq('professional_id', professionalId!)
        .eq('client_id', clientId!)
        .order('created_at', { ascending: false })
        .range(pageParam * 10, pageParam * 10 + 9);

      if (error) throw error;
      return (data ?? []) as NutritionPlan[];
    },
    initialPageParam: 0,
    enabled: !!clientId && !!professionalId,
    staleTime: 30_000,
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.length === 10 ? allPages.length : undefined;
    },
  });
};

export const usePlan = (planId?: string) => {
  return useQuery({
    queryKey: queryKeys.plan(planId ?? ''),
    queryFn: () => planRepository.getWithDays(supabase, planId!),
    enabled: !!planId,
    staleTime: 30_000,
  });
};

export { queryKeys as planQueryKeys };
