import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { messageRepository } from '../../repositories/message.repository';
import type { ProfessionalClientMessage } from '../../types/database.types';

export const useSendMessage = (professionalClientId?: string) => {
  const queryClient = useQueryClient();
  const queryKey = ['messages', professionalClientId];

  return useMutation({
    mutationFn: (payload: {
      professional_client_id: string;
      professional_id: string;
      client_id: string;
      body: string;
    }) => messageRepository.send(supabase, payload),

    // Optimistic update
    onMutate: async (payload) => {
      await queryClient.cancelQueries({ queryKey });

      const previous = queryClient.getQueryData<ProfessionalClientMessage[]>(queryKey);

      const optimistic: ProfessionalClientMessage = {
        id: `optimistic-${Date.now()}`,
        professional_client_id: payload.professional_client_id,
        professional_id: payload.professional_id,
        client_id: payload.client_id,
        body: payload.body,
        author_role: 'professional',
        created_at: new Date().toISOString(),
        client_read_at: null,
        professional_read_at: new Date().toISOString(),
      };

      queryClient.setQueryData<ProfessionalClientMessage[]>(queryKey, (prev) => {
        if (!prev) return [optimistic];
        return [...prev, optimistic];
      });

      return { previous, optimistic };
    },

    onError: (_err, _payload, context) => {
      if (context?.previous) {
        queryClient.setQueryData(queryKey, context.previous);
      }
    },

    onSettled: () => {
      queryClient.invalidateQueries({ queryKey });
    },
  });
};
