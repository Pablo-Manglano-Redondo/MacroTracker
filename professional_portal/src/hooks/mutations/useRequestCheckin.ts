import { useMutation } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { checkinRepository } from '../../repositories/checkin.repository';
import { toast } from '../../lib/toast';
import { usePortalI18n } from '../../lib/portal-i18n';

export function useRequestCheckin() {
  const { tr } = usePortalI18n();

  return useMutation({
    mutationFn: (params: { professionalId: string; clientId: string; professionalClientId: string }) =>
      checkinRepository.requestCheckin(supabase, params.professionalId, params.clientId, params.professionalClientId),
    onSuccess: () => {
      toast.success(tr('Check-in solicitado. Se ha enviado una notificación al cliente.', 'Check-in requested. Push notification sent to client.'));
    },
    onError: (err: any) => {
      toast.error(tr('No se pudo solicitar el check-in', 'Failed to request check-in'), {
        description: err?.message || tr('Error desconocido', 'Unknown error'),
      });
    },
  });
}
