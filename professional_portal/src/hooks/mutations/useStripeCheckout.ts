import { useMutation } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';

type CheckoutErrorPayload = {
  code?: string;
  error?: string;
  billingInterval?: 'monthly' | 'annual';
  tier?: string;
};

function mapCheckoutError(payload: CheckoutErrorPayload): string {
  if (payload.code === 'missing_price_configuration') {
    const intervalLabel = payload.billingInterval === 'annual' ? 'annual' : 'monthly';
    const tierLabel = payload.tier ?? 'selected';
    return `The ${intervalLabel} ${tierLabel} checkout is not configured yet. Update the Stripe price IDs in Supabase secrets before retrying.`;
  }

  if (payload.code === 'missing_professional_profile') {
    return 'Create your professional profile before opening Stripe checkout.';
  }

  return payload.error ?? 'Stripe checkout failed.';
}

export const useStripeCheckout = () => {
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
        throw new Error(mapCheckoutError(payload));
      }
      if (payload.error) {
        throw new Error(mapCheckoutError(payload));
      }
      if (!data?.url) throw new Error('Stripe checkout did not return a valid URL.');

      return data.url as string;
    },
  });
};
