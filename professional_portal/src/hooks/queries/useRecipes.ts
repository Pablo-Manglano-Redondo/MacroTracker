import { useQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { recipeRepository } from '../../repositories/recipe.repository';

export function useRecipes(professionalId: string | undefined) {
  return useQuery({
    queryKey: ['recipes', professionalId],
    queryFn: () => recipeRepository.list(supabase, professionalId!),
    enabled: !!professionalId,
    staleTime: 30_000,
  });
}

export function useProposedRecipes(professionalClientId: string | undefined) {
  return useQuery({
    queryKey: ['proposed-recipes', professionalClientId],
    queryFn: () => recipeRepository.getProposed(supabase, professionalClientId!),
    enabled: !!professionalClientId,
    staleTime: 10_000,
  });
}
