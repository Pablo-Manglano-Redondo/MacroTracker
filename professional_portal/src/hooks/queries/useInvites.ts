import { useQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { inviteRepository } from '../../repositories/invite.repository';

export function useInvites(professionalId: string | undefined) {
  return useQuery({
    queryKey: ['invites', professionalId],
    queryFn: () => inviteRepository.list(supabase, professionalId!),
    enabled: !!professionalId,
    staleTime: 30_000,
  });
}
