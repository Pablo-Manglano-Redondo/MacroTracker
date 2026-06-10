import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { progressRepository } from '../../repositories/progress.repository';

export function useCreateProgress(professionalClientId: string | undefined) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (record: Parameters<typeof progressRepository.create>[1]) =>
      progressRepository.create(supabase, record),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['client-progress', professionalClientId] });
      queryClient.invalidateQueries({ queryKey: ['client-progress-summary'] });
    },
  });
}

export function useDeleteProgress(professionalClientId: string | undefined) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => progressRepository.remove(supabase, id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['client-progress', professionalClientId] });
      queryClient.invalidateQueries({ queryKey: ['client-progress-summary'] });
    },
  });
}
