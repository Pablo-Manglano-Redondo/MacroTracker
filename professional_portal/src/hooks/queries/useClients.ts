import { useQuery, useInfiniteQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { clientRepository } from '../../repositories/client.repository';

const queryKeys = {
  clients: (professionalId: string) => ['clients', professionalId] as const,
  unreadCounts: (professionalId: string) => ['clients', professionalId, 'unread'] as const,
};

export const useClients = (professionalId?: string) => {
  return useQuery({
    queryKey: queryKeys.clients(professionalId ?? ''),
    queryFn: () => clientRepository.listByProfessional(supabase, professionalId!),
    enabled: !!professionalId,
    staleTime: 30_000,
  });
};

export const useInfiniteClients = (professionalId?: string) => {
  return useInfiniteQuery({
    queryKey: [...queryKeys.clients(professionalId ?? ''), 'infinite'],
    queryFn: async ({ pageParam = 0 }: { pageParam: number }) => {
      return clientRepository.listByProfessionalPage(supabase, professionalId!, pageParam);
    },
    initialPageParam: 0,
    enabled: !!professionalId,
    staleTime: 30_000,
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.length === 10 ? allPages.length : undefined;
    },
  });
};

export const useUnreadCounts = (professionalId?: string) => {
  return useQuery({
    queryKey: queryKeys.unreadCounts(professionalId ?? ''),
    queryFn: () => clientRepository.getUnreadCounts(supabase, professionalId!),
    enabled: !!professionalId,
    staleTime: 15_000,
  });
};

export { queryKeys as clientQueryKeys };
