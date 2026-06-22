import { useMutation } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { toast } from '../../lib/toast';
import { usePortalI18n } from '../../lib/portal-i18n';
import { checkinRepository } from '../../repositories/checkin.repository';

export function useRequestCheckin() {
  const { t } = usePortalI18n();

  return useMutation({
    mutationFn: (params: {
      professionalId: string;
      clientId: string;
      professionalClientId: string;
    }) =>
      checkinRepository.requestCheckin(
        supabase,
        params.professionalId,
        params.clientId,
        params.professionalClientId,
      ),
    onSuccess: () => {
      toast.success(
        t('hooks.mutations.userequestcheckin.check_in_requested_push_notification_sent_to_client'),
      );
    },
    onError: (err: any) => {
      toast.error(t('hooks.mutations.userequestcheckin.failed_to_request_check_in'), {
        description: err?.message || t('hooks.mutations.userequestcheckin.unknown_error'),
      });
    },
  });
}
