import React, { useEffect, useState } from 'react';
import { useAuth } from '../lib/auth-context';
import { useStripeCheckout } from '../hooks/mutations/useStripeCheckout';
import { toast } from '../lib/toast';
import { CreditCard, Loader2, Check, Zap } from 'lucide-react';

export const BillingPanel: React.FC = () => {
  const { professional } = useAuth();
  const [loadingTier, setLoadingTier] = useState<string | null>(null);
  const [checkoutStatus, setCheckoutStatus] = useState<'success' | 'canceled' | null>(null);
  const checkoutMutation = useStripeCheckout();

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    if (params.get('checkout') === 'success') {
      setCheckoutStatus('success');
      window.history.replaceState({}, document.title, window.location.pathname + window.location.hash);
    } else if (params.get('checkout') === 'canceled') {
      setCheckoutStatus('canceled');
      window.history.replaceState({}, document.title, window.location.pathname + window.location.hash);
    }
  }, []);

  const handleCheckout = (tier: string) => {
    if (!professional) {
      toast.error('Save your profile first to unlock billing.');
      return;
    }

    setLoadingTier(tier);
    checkoutMutation.mutate(
      { tier, origin: window.location.origin + window.location.pathname },
      {
        onSuccess: (url) => {
          window.location.href = url;
        },
        onError: (err: any) => {
          toast.error('Checkout failed', { description: err?.message || 'Unknown error' });
          setLoadingTier(null);
        },
      }
    );
  };

  const tiers = [
    {
      id: 'starter',
      name: 'Starter',
      price: '$29',
      period: '/mo',
      capacity: '10 clients',
      features: ['Client management', 'Plan builder', 'Direct messaging'],
    },
    {
      id: 'growth',
      name: 'Growth',
      price: '$79',
      period: '/mo',
      capacity: '50 clients',
      features: ['Everything in Starter', 'Analytics dashboard', 'Priority support'],
      popular: true,
    },
    {
      id: 'studio',
      name: 'Studio',
      price: '$199',
      period: '/mo',
      capacity: '500 clients',
      features: ['Everything in Growth', 'Team management', 'Custom branding'],
    },
  ];

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center gap-3">
        <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
          <CreditCard className="w-4 h-4 text-primary" />
        </div>
        <div>
          <h2 className="text-lg font-bold">Billing</h2>
          <p className="text-xs text-muted-foreground">Choose the plan for your practice</p>
        </div>
      </div>

      {/* Status messages */}
      {checkoutStatus === 'success' && (
        <div className="rounded-lg bg-emerald-50 dark:bg-emerald-900/20 border border-emerald-200 dark:border-emerald-800 p-4 text-sm text-emerald-700 dark:text-emerald-300">
          Subscription updated successfully!
        </div>
      )}
      {checkoutStatus === 'canceled' && (
        <div className="rounded-lg bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 p-4 text-sm text-amber-700 dark:text-amber-300">
          Checkout was canceled. You can try again anytime.
        </div>
      )}

      {/* Current plan */}
      {professional && (
        <div className="rounded-xl border bg-card p-4 flex items-center justify-between card-elevated">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
              <Zap className="w-5 h-5 text-primary" />
            </div>
            <div>
              <p className="text-sm font-semibold">Current Plan</p>
              <p className="text-xs text-muted-foreground capitalize">
                {professional.pro_status === 'active' ? 'Pro Active' : professional.pro_status || 'Free'}
              </p>
            </div>
          </div>
          <span className="text-xs text-muted-foreground">
            {professional.client_limit || 0} client limit
          </span>
        </div>
      )}

      {/* Tier cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {tiers.map((tier) => {
          const isLoading = loadingTier === tier.id;
          const isCurrentPlan = professional?.pro_status === tier.id;

          return (
            <button
              key={tier.id}
              onClick={() => handleCheckout(tier.id)}
              disabled={loadingTier !== null || !professional || isCurrentPlan}
              className={`relative flex flex-col text-left p-5 rounded-xl border transition-all ${
                tier.popular
                  ? 'border-primary bg-primary/5'
                  : 'bg-card hover:border-primary/50'
              } ${isCurrentPlan ? 'opacity-60' : ''} card-elevated`}
            >
              {tier.popular && (
                <span className="absolute -top-2.5 left-4 px-2 py-0.5 bg-primary text-primary-foreground text-[10px] font-bold rounded-full">
                  Popular
                </span>
              )}

              <div className="flex items-baseline gap-0.5 mb-3">
                <span className="text-2xl font-bold">{tier.price}</span>
                <span className="text-xs text-muted-foreground">{tier.period}</span>
              </div>

              <p className="text-sm font-semibold mb-1">{tier.name}</p>
              <p className="text-xs text-muted-foreground mb-4">{tier.capacity}</p>

              <ul className="space-y-1.5 mt-auto">
                {tier.features.map((f, i) => (
                  <li key={i} className="flex items-center gap-1.5 text-xs text-muted-foreground">
                    <Check className="w-3 h-3 text-primary shrink-0" />
                    {f}
                  </li>
                ))}
              </ul>

              {isLoading && (
                <div className="mt-4 flex items-center gap-2 text-xs text-primary font-medium">
                  <Loader2 className="w-3.5 h-3.5 animate-spin" />
                  Redirecting...
                </div>
              )}

              {isCurrentPlan && (
                <div className="mt-4 text-xs text-muted-foreground font-medium">Current plan</div>
              )}
            </button>
          );
        })}
      </div>

      <p className="text-xs text-muted-foreground/70 text-center">
        Stripe checkout. Cancel anytime. Existing plans stay accessible if billing lapses.
      </p>
    </div>
  );
};
