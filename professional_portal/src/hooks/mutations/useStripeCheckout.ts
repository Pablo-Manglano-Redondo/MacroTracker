import { useMutation } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';
import { usePortalI18n } from '../../lib/portal-i18n';
import type { PortalTranslationKey } from '../../lib/generated/i18n';
import { getBillingTierLabelKey } from '../../view-models/professional';

type CheckoutErrorPayload = {
  code?: string;
  error?: string;
  billingInterval?: 'monthly' | 'annual';
  tier?: string;
};

function mapCheckoutError(
  payload: CheckoutErrorPayload,
  t: (key: PortalTranslationKey, params?: Record<string, string>) => string,
): string {
  if (payload.code === 'missing_price_configuration') {
    const intervalLabel = payload.billingInterval === 'annual'
      ? t('hooks.mutations.usestripecheckout.annual')
      : t('hooks.mutations.usestripecheckout.monthly');
    const tierLabel =
      payload.tier === 'starter' || payload.tier === 'growth' || payload.tier === 'studio'
        ? t(getBillingTierLabelKey(payload.tier))
        : payload.tier ?? t('hooks.mutations.usestripecheckout.selected');
    return t('hooks.mutations.usestripecheckout.the_checkout_is_not_configured_yet_update_the_stripe_price_ids_in_supaba', { intervallabel: intervalLabel, tierlabel: tierLabel });
  }

  if (payload.code === 'missing_professional_profile') {
    return t('hooks.mutations.usestripecheckout.create_your_professional_profile_before_opening_stripe_checkout');
  }

  return payload.error ?? t('hooks.mutations.usestripecheckout.stripe_checkout_failed');
}

export const useStripeCheckout = () => {
  const { t } = usePortalI18n();

  return useMutation({
    mutationFn: async ({
      tier,
      billingInterval,
      origin,
    }: {
      tier: string;
      billingInterval: 'monthly' | 'annual';
      origin: string;
    }) => {
      const { data, error } = await supabase.functions.invoke('stripe-pro-checkout', {
        body: { tier, billingInterval, origin },
      });

      const payload = (data ?? {}) as CheckoutErrorPayload & { url?: string };
      if (error) {
        throw new Error(mapCheckoutError(payload, t));
      }
      if (payload.error) {
        throw new Error(mapCheckoutError(payload, t));
      }
      if (!data?.url) {
        throw new Error(
          t('hooks.mutations.usestripecheckout.stripe_checkout_did_not_return_a_valid_url'),
        );
      }

      return data.url as string;
    },
  });
};
