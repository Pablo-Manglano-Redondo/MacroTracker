import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { professionalRepository } from '../../repositories/professional.repository';

export const useUpdateProfile = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (payload: {
      user_id: string;
      display_name: string;
      business_name?: string;
      avatar_url?: string | null;
    }) => professionalRepository.upsert(supabase, payload),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['professional', variables.user_id] });
    },
  });
};
