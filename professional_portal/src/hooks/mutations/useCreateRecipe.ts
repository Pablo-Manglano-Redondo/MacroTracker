import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { recipeRepository } from '../../repositories/recipe.repository';

export function useCreateRecipe(professionalId: string | undefined) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (recipe: Parameters<typeof recipeRepository.create>[1]) =>
      recipeRepository.create(supabase, recipe),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['recipes', professionalId] });
    },
  });
}

export function useDeleteRecipe(professionalId: string | undefined) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => recipeRepository.remove(supabase, id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['recipes', professionalId] });
    },
  });
}

export function useProposeRecipe() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: Parameters<typeof recipeRepository.proposeToClient>[1]) =>
      recipeRepository.proposeToClient(supabase, payload),
    onSuccess: (_data, vars) => {
      queryClient.invalidateQueries({ queryKey: ['proposed-recipes', vars.professional_client_id] });
      queryClient.invalidateQueries({ queryKey: ['client-progress-summary'] });
    },
  });
}
