import { useMutation } from '@tanstack/react-query';
import { supabase } from '../../lib/supabase';

export const useStripeCheckout = () => {
  return useMutation({
    mutationFn: async ({ tier, origin }: { tier: string; origin: string }) => {
      const { data, error } = await supabase.functions.invoke('stripe-pro-checkout', {
        body: { tier, origin },
      });

      if (error) throw error;
      if (!data?.url) throw new Error('Stripe checkout did not return a valid URL.');

      return data.url as string;
    },
  });
};
