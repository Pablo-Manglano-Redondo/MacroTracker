import { useMutation } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { inviteRepository } from '../../repositories/invite.repository';

export const useCreateInvite = () => {
  return useMutation({
    mutationFn: (professionalId: string) =>
      inviteRepository.create(supabase, professionalId),
  });
};
