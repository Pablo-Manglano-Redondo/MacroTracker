import React, { useEffect, useMemo, useState } from 'react';
import {
  BadgeCheck,
  CreditCard,
  Loader2,
  ShieldAlert,
  Users,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import type { PortalTranslationKey } from '../lib/generated/i18n';
import { toast } from '../lib/toast';
import { useStripeCheckout } from '../hooks/mutations/useStripeCheckout';
import { getBillingSummary } from '../view-models/professional';
import { usePortalI18n } from '../lib/portal-i18n';

type BillingInterval = 'monthly' | 'annual';
type BillingTierId = 'starter' | 'growth' | 'studio';

type TierCard = {
  id: BillingTierId;
  name: string;
  monthlyPrice: string;
  annualPrice: string;
  clientLimit: number;
};

const TIERS: TierCard[] = [
  {
    id: 'starter',
    name: 'Starter',
    monthlyPrice: '$29',
    annualPrice: '$276',
    clientLimit: 10,
  },
  {
    id: 'growth',
    name: 'Growth',
    monthlyPrice: '$79',
    annualPrice: '$756',
    clientLimit: 50,
  },
  {
    id: 'studio',
    name: 'Studio',
    monthlyPrice: '$199',
    annualPrice: '$1908',
    clientLimit: 500,
  },
];

const tierSummaryKey: Record<BillingTierId, PortalTranslationKey> = {
  starter:
    'components.billingpanel.for_solo_nutritionists_validating_the_workflow_with_a_small_roster',
  growth:
    'components.billingpanel.for_practices_already_managing_a_stable_book_of_recurring_clients',
  studio:
    'components.billingpanel.for_larger_teams_using_the_portal_as_a_controlled_internal_operation',
};

const tierFeatureKeys: Record<BillingTierId, PortalTranslationKey[]> = {
  starter: [
    'components.billingpanel.up_to_10_active_client_relationships',
    'components.billingpanel.plans_notes_check_ins_and_aggregate_snapshots',
    'components.billingpanel.detailed_diary_only_when_the_client_grants_explicit_consent',
  ],
  growth: [
    'components.billingpanel.up_to_50_active_client_relationships',
    'components.billingpanel.the_same_operational_surfaces_as_starter',
    'components.billingpanel.more_capacity_for_plan_publishing_and_invite_operations',
  ],
  studio: [
    'components.billingpanel.up_to_500_active_client_relationships',
    'components.billingpanel.the_same_data_contract_and_privacy_model',
    'components.billingpanel.built_for_higher_volume_invite_only_operations',
  ],
};

export const BillingPanel: React.FC = () => {
  const { professional } = useAuth();
  const { t } = usePortalI18n();
  const checkoutMutation = useStripeCheckout();
  const [selectedInterval, setSelectedInterval] = useState<BillingInterval>('monthly');
  const [loadingTier, setLoadingTier] = useState<string | null>(null);
  const [checkoutStatus, setCheckoutStatus] = useState<'success' | 'canceled' | null>(null);

  const billingSummary = useMemo(() => getBillingSummary(professional), [professional]);
  const billingIntervalLabel =
    billingSummary.billingInterval === 'annual'
      ? t('components.billingpanel.annual')
      : t('components.billingpanel.monthly');
  const proStatusLabelMap: Record<string, string> = {
    inactive: t('components.billingpanel.inactive'),
    trialing: t('components.billingpanel.trial_active'),
    active: t('components.billingpanel.active'),
    past_due: t('components.billingpanel.past_due'),
    canceled: t('components.billingpanel.canceled'),
  };
  const proStatusLabel = proStatusLabelMap[billingSummary.proStatus] ?? billingSummary.proStatus;

  useEffect(() => {
    if (professional?.billing_interval) {
      setSelectedInterval(professional.billing_interval);
    }
  }, [professional?.billing_interval]);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const checkout = params.get('checkout');
    if (checkout === 'success') {
      setCheckoutStatus('success');
    } else if (checkout === 'canceled' || checkout === 'cancelled') {
      setCheckoutStatus('canceled');
    } else {
      return;
    }

    window.history.replaceState({}, document.title, window.location.pathname + window.location.hash);
  }, []);

  const handleCheckout = (tierId: TierCard['id']) => {
    if (!professional) {
      toast.error(
        t('components.billingpanel.create_the_professional_profile_before_opening_stripe_checkout'),
      );
      return;
    }

    setLoadingTier(tierId);
    checkoutMutation.mutate(
      {
        tier: tierId,
        billingInterval: selectedInterval,
        origin: window.location.origin + window.location.pathname,
      },
      {
        onSuccess: (url) => {
          window.location.href = url;
        },
        onError: (error: unknown) => {
          const message =
            error instanceof Error
              ? error.message
              : t('components.billingpanel.stripe_checkout_failed');
          toast.error(t('components.billingpanel.checkout_unavailable'), { description: message });
          setLoadingTier(null);
        },
      },
    );
  };

  return (
    <div className="space-y-6 animate-fade-in-up">
      <section className="portal-hero rounded-[1.8rem] p-6">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
          <div className="space-y-2">
            <div className="flex items-center gap-2 text-primary">
              <CreditCard className="h-5 w-5" />
              <p className="portal-kicker">{t('components.billingpanel.billing')}</p>
            </div>
            <h2 className="portal-title text-3xl text-foreground">
              {t('components.billingpanel.access_tier_and_capacity')}
            </h2>
            <p className="max-w-2xl text-sm leading-relaxed text-muted-foreground">
              {t('components.billingpanel.the_portal_separates_access_status_commercial_tier_and_billing_interval_')}
            </p>
          </div>

          <div className="inline-flex rounded-xl border border-border bg-card p-1">
            {(['monthly', 'annual'] as BillingInterval[]).map((interval) => (
              <button
                key={interval}
                onClick={() => setSelectedInterval(interval)}
                className={`rounded-lg px-3 py-1.5 text-xs font-bold uppercase tracking-[0.16em] transition-colors ${
                  selectedInterval === interval
                    ? 'bg-primary text-primary-foreground'
                    : 'text-muted-foreground hover:text-foreground'
                }`}
              >
                {interval === 'monthly' ? t('components.billingpanel.monthly') : t('components.billingpanel.annual')}
              </button>
            ))}
          </div>
        </div>

        {checkoutStatus === 'success' && (
          <div className="mt-4 rounded-xl border border-primary/25 bg-primary/10 p-3 text-sm font-semibold text-primary">
            {t('components.billingpanel.checkout_completed_if_the_stripe_webhook_has_not_landed_yet_refresh_the_')}
          </div>
        )}
        {checkoutStatus === 'canceled' && (
          <div className="mt-4 rounded-xl border border-amber-500/25 bg-amber-500/10 p-3 text-sm font-semibold text-amber-700 dark:text-amber-300">
            {t('components.billingpanel.checkout_canceled_no_billing_change_was_applied')}
          </div>
        )}

        {billingSummary.proStatus === 'trialing' && billingSummary.clientLimit === 1 && (
          <div className="mt-4 rounded-xl border border-primary/20 bg-primary/5 p-4 text-sm text-foreground">
            <div className="flex items-start gap-2.5">
              <BadgeCheck className="h-5 w-5 shrink-0 text-primary" />
              <div className="space-y-1">
                <p className="font-bold text-foreground">
                  {t('components.billingpanel.you_are_on_the_free_trial_plan')}
                </p>
                <p className="text-xs text-muted-foreground leading-relaxed">
                  {t('components.billingpanel.your_trial_account_allows_you_to_connect_with_exactly_1_client_for_free_')}
                </p>
              </div>
            </div>
          </div>
        )}

        <div className="mt-5 grid gap-4 md:grid-cols-3">
          <SummaryCard
            label={t('components.billingpanel.access_status')}
            value={proStatusLabel}
            tone={billingSummary.hasProfessionalAccess ? 'good' : 'warn'}
            note={
              billingSummary.hasProfessionalAccess
                ? t('components.billingpanel.invites_and_plan_publishing_are_enabled')
                : t('components.billingpanel.invites_and_new_plans_stay_blocked_until_billing_is_active')
            }
          />
          <SummaryCard
            label={t('components.billingpanel.commercial_tier')}
            value={billingSummary.tierLabel}
            note={t('components.billingpanel.active_clients_included', {
              billingsummary_clientlimit: billingSummary.clientLimit,
            })}
          />
          <SummaryCard
            label={t('components.billingpanel.billing_interval')}
            value={billingIntervalLabel}
            note={t('components.billingpanel.stored_separately_from_subscription_status')}
          />
        </div>

        {selectedInterval === 'annual' && (
          <div className="portal-soft-panel mt-4 rounded-xl p-3 text-xs leading-relaxed text-muted-foreground">
            {t('components.billingpanel.annual_checkout_depends_on_the_matching_annual_price_id_secrets_being_co')}
          </div>
        )}
      </section>

      {!billingSummary.hasProfessionalAccess && (
        <section className="rounded-2xl border border-amber-500/25 bg-amber-500/10 p-5">
          <div className="flex items-start gap-3">
            <ShieldAlert className="mt-0.5 h-5 w-5 text-amber-500 dark:text-amber-300" />
            <div className="space-y-1">
              <p className="text-sm font-bold text-foreground dark:text-white">
                {t('components.billingpanel.practice_not_operational_yet')}
              </p>
              <p className="text-sm leading-relaxed text-amber-900 dark:text-amber-100">
                {t('components.billingpanel.existing_records_may_remain_readable_but_new_invites_and_new_plans_shoul', {
                  billingsummary_prostatus: billingSummary.proStatus,
                })}
              </p>
            </div>
          </div>
        </section>
      )}

      <section className="grid gap-4 xl:grid-cols-3">
        {TIERS.map((tier) => {
          const isCurrentPlan =
            billingSummary.tier === tier.id &&
            billingSummary.billingInterval === selectedInterval &&
            billingSummary.hasProfessionalAccess;
          const isLoading = loadingTier === tier.id;
          const price =
            selectedInterval === 'monthly'
              ? `${tier.monthlyPrice}/mo`
              : `${tier.annualPrice}/yr`;

          return (
            <article
              key={tier.id}
              className={`rounded-[1.6rem] border p-6 ${
                isCurrentPlan ? 'border-primary bg-primary/10' : 'portal-panel'
              }`}
            >
              <div className="flex items-start justify-between gap-4">
                <div>
                  <p className="text-sm font-bold uppercase tracking-[0.16em] text-primary">
                    {tier.name}
                  </p>
                  <h3 className="portal-metric mt-2 text-3xl font-extrabold text-foreground">
                    {price}
                  </h3>
                </div>
                <div className="portal-soft-panel rounded-xl px-3 py-2 text-right">
                  <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                    {t('components.billingpanel.capacity')}
                  </p>
                  <p className="mt-1 flex items-center gap-1 text-sm font-bold text-foreground">
                    <Users className="h-4 w-4 text-primary" />
                    {tier.clientLimit}
                  </p>
                </div>
              </div>

              <p className="mt-4 text-sm leading-relaxed text-muted-foreground">
                {t(tierSummaryKey[tier.id])}
              </p>

              <ul className="mt-5 space-y-3">
                {tierFeatureKeys[tier.id].map((featureKey) => (
                  <li key={featureKey} className="flex items-start gap-2 text-sm text-muted-foreground">
                    <BadgeCheck className="mt-0.5 h-4 w-4 shrink-0 text-primary" />
                    <span>{t(featureKey)}</span>
                  </li>
                ))}
              </ul>

              <button
                onClick={() => handleCheckout(tier.id)}
                disabled={!professional || isCurrentPlan || checkoutMutation.isPending}
                className={`mt-6 flex w-full items-center justify-center gap-2 rounded-xl px-4 py-3 text-xs font-bold uppercase tracking-[0.16em] transition-colors ${
                  isCurrentPlan
                    ? 'cursor-default border border-primary/30 bg-primary/15 text-primary'
                    : 'bg-primary text-primary-foreground hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50'
                }`}
              >
                {isLoading ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    {t('components.billingpanel.redirecting')}
                  </>
                ) : isCurrentPlan ? (
                  t('components.billingpanel.current_plan')
                ) : (
                  t('components.billingpanel.open_checkout')
                )}
              </button>
            </article>
          );
        })}
      </section>

      <section className="portal-panel rounded-[1.6rem] p-6">
        <h3 className="text-sm font-bold uppercase tracking-[0.16em] text-foreground">
          {t('components.billingpanel.data_contract_reminders')}
        </h3>
        <div className="mt-4 grid gap-3 md:grid-cols-2">
          <InfoCard
            title={t('components.billingpanel.aggregate_sharing_is_the_baseline')}
            body={t('components.billingpanel.snapshots_macro_adherence_and_summary_progress_can_be_visible_with_an_ac')}
          />
          <InfoCard
            title={t('components.billingpanel.detailed_requires_consent')}
            body={t('components.billingpanel.raw_diary_rows_only_appear_when_the_client_keeps_the_relationship_active')}
          />
          <InfoCard
            title={t('components.billingpanel.billing_does_not_override_privacy')}
            body={t('components.billingpanel.a_higher_tier_increases_capacity_not_the_amount_of_private_data_the_prof')}
          />
          <InfoCard
            title={t('components.billingpanel.read_only_fallback_stays_honest')}
            body={t('components.billingpanel.when_billing_lapses_historical_records_can_remain_readable_while_new_inv')}
          />
        </div>
      </section>
    </div>
  );
};

const SummaryCard: React.FC<{
  label: string;
  value: string;
  note: string;
  tone?: 'good' | 'warn' | 'neutral';
}> = ({ label, value, note, tone = 'neutral' }) => (
  <div className="portal-soft-panel rounded-xl p-4">
    <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
      {label}
    </p>
    <p
      className={`mt-2 text-lg font-extrabold ${
        tone === 'good'
          ? 'text-primary'
          : tone === 'warn'
            ? 'text-amber-500 dark:text-amber-300'
            : 'text-foreground'
      }`}
    >
      {value}
    </p>
    <p className="mt-1 text-xs leading-relaxed text-muted-foreground">{note}</p>
  </div>
);

const InfoCard: React.FC<{ title: string; body: string }> = ({ title, body }) => (
  <div className="portal-soft-panel rounded-xl p-4">
    <p className="text-sm font-bold text-foreground">{title}</p>
    <p className="mt-2 text-sm leading-relaxed text-muted-foreground">{body}</p>
  </div>
);
