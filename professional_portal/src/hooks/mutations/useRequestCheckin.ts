import { useMutation } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { checkinRepository } from '../../repositories/checkin.repository';
import { toast } from '../../lib/toast';

export function useRequestCheckin() {
  return useMutation({
    mutationFn: (params: { professionalId: string; clientId: string; professionalClientId: string }) =>
      checkinRepository.requestCheckin(supabase, params.professionalId, params.clientId, params.professionalClientId),
    onSuccess: () => {
      toast.success('Check-in requested — push notification sent to client');
    },
    onError: (err: any) => {
      toast.error('Failed to request check-in', { description: err?.message || 'Unknown error' });
    },
  });
}
