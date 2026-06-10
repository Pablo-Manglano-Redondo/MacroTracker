import { useMutation } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { messageRepository } from '../../repositories/message.repository';

export const useMarkMessagesRead = () => {
  return useMutation({
    mutationFn: async ({
      messageIds,
      onSuccess,
    }: {
      messageIds: string[];
      onSuccess?: () => void;
    }) => {
      await messageRepository.markAsRead(supabase, messageIds, 'professional');
      onSuccess?.();
    },
  });
};
