import { useMutation } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { usePortalI18n } from '../../lib/portal-i18n';

export const useStripePortal = () => {
  const { t } = usePortalI18n();

  return useMutation({
    mutationFn: async ({ origin }: { origin: string }) => {
      const { data, error } = await supabase.functions.invoke('stripe-pro-portal', {
        body: { origin },
      });

      if (error) {
        throw new Error(error.message || t('hooks.mutations.usestripeportal.failed_to_open_billing_portal'));
      }
      if (data?.error) {
        throw new Error(data.error);
      }
      if (!data?.url) {
        throw new Error(
          t('hooks.mutations.usestripeportal.stripe_portal_did_not_return_a_valid_url')
        );
      }

      return data.url as string;
    },
  });
};
