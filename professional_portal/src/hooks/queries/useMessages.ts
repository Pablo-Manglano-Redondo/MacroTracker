import { useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect } from 'react';
import { supabase } from '../../lib/supabase';
import { messageRepository } from '../../repositories/message.repository';
import type { ProfessionalClientMessage } from '../../types/database.types';

export const useMessages = (professionalClientId?: string) => {
  const queryClient = useQueryClient();
  const queryKey = ['messages', professionalClientId];

  const query = useQuery({
    queryKey,
    queryFn: () => messageRepository.listByRelationship(supabase, professionalClientId!),
    enabled: !!professionalClientId,
    staleTime: 10_000,
  });

  // Realtime subscription sync
  useEffect(() => {
    if (!professionalClientId) return;

    const channel = messageRepository.subscribeToNewMessages(
      supabase,
      professionalClientId,
      (newMessage: ProfessionalClientMessage) => {
        queryClient.setQueryData<ProfessionalClientMessage[]>(queryKey, (prev) => {
          if (!prev) return [newMessage];
          if (prev.some((m) => m.id === newMessage.id)) return prev;
          return [...prev, newMessage];
        });
      }
    );

    return () => {
      supabase.removeChannel(channel);
    };
  }, [professionalClientId, queryClient, queryKey]);

  return query;
};

export const useMessagesQueryKey = (professionalClientId?: string) =>
  ['messages', professionalClientId] as const;
