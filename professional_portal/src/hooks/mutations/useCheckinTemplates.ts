import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { checkinRepository } from '../../repositories/checkin.repository';

export function useCreateCheckinTemplate(professionalId: string | undefined) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (template: Parameters<typeof checkinRepository.createTemplate>[1]) =>
      checkinRepository.createTemplate(supabase, template),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['checkin-templates', professionalId] });
    },
  });
}

export function useDeleteCheckinTemplate(professionalId: string | undefined) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => checkinRepository.removeTemplate(supabase, id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['checkin-templates', professionalId] });
    },
  });
}
