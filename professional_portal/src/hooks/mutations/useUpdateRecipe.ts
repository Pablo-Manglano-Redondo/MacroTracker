import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { recipeRepository } from '../../repositories/recipe.repository';

export function useUpdateRecipe(professionalId: string | undefined) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, updates }: { id: string; updates: Parameters<typeof recipeRepository.update>[2] }) =>
      recipeRepository.update(supabase, id, updates),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['recipes', professionalId] });
    },
  });
}
