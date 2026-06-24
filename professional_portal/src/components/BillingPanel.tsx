import React, { useEffect, useMemo, useState } from 'react';
import { BadgeCheck, Loader2, ShieldAlert, Users } from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import type { PortalTranslationKey } from '../lib/generated/i18n';
import { usePortalI18n } from '../lib/portal-i18n';
import { toast } from '../lib/toast';
import { useStripeCheckout } from '../hooks/mutations/useStripeCheckout';
import { useClients } from '../hooks/queries/useClients';
import { getBillingSummary } from '../view-models/professional';

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
  { id: 'starter', name: 'Starter', monthlyPrice: '$29', annualPrice: '$276', clientLimit: 10 },
  { id: 'growth', name: 'Growth', monthlyPrice: '$79', annualPrice: '$756', clientLimit: 50 },
  { id: 'studio', name: 'Studio', monthlyPrice: '$199', annualPrice: '$1908', clientLimit: 500 },
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

const billingStatusKeyByStatus = {
  inactive: 'components.billingpanel.inactive',
  trialing: 'components.billingpanel.trial_active',
  active: 'components.billingpanel.active',
  past_due: 'components.billingpanel.past_due',
  canceled: 'components.billingpanel.canceled',
} as const satisfies Record<
  ReturnType<typeof getBillingSummary>['proStatus'],
  PortalTranslationKey
>;

export const BillingPanel: React.FC = () => {
  const { professional } = useAuth();
  const { t } = usePortalI18n();
  const checkoutMutation = useStripeCheckout();
  const { data: clients = [] } = useClients(professional?.id);
  const connectedClients = useMemo(
    () => clients.filter((client) => client.status === 'connected').length,
    [clients],
  );
  const [selectedInterval, setSelectedInterval] = useState<BillingInterval>('monthly');
  const [loadingTier, setLoadingTier] = useState<string | null>(null);
  const [checkoutStatus, setCheckoutStatus] = useState<'success' | 'canceled' | null>(null);

  const billingSummary = useMemo(
    () => getBillingSummary(professional, connectedClients),
    [connectedClients, professional],
  );
  const billingIntervalLabel =
    billingSummary.billingInterval === 'annual'
      ? t('components.billingpanel.annual')
      : t('components.billingpanel.monthly');
  const billingStatusLabel = t(billingStatusKeyByStatus[billingSummary.proStatus]);

  const statusTitle =
    billingSummary.primaryAction === 'resolve_payment'
      ? t('components.billingpanel.practice_blocked_by_payment')
      : billingSummary.primaryAction === 'reactivate_plan'
        ? t('components.billingpanel.practice_canceled')
        : billingSummary.primaryAction === 'manage_plan'
          ? t('components.billingpanel.practice_operational')
          : billingSummary.primaryAction === 'use_trial'
            ? t('components.billingpanel.trial_active')
            : t('components.billingpanel.activate_billing');

  const statusBody =
    billingSummary.primaryAction === 'resolve_payment'
      ? t('components.billingpanel.historical_relationships_readable_until_payment_resolved')
      : billingSummary.primaryAction === 'reactivate_plan'
        ? t('components.billingpanel.historical_records_read_only_until_reactivated')
        : billingSummary.primaryAction === 'manage_plan'
          ? t('components.billingpanel.billing_state_and_capacity_healthy')
          : billingSummary.primaryAction === 'use_trial'
            ? t('components.billingpanel.use_trial_carefully_until_upgrade')
            : t('components.billingpanel.complete_billing_activation_before_new_operations');

  const primaryCtaLabel =
    billingSummary.primaryAction === 'resolve_payment'
      ? t('components.billingpanel.resolve_payment')
      : billingSummary.primaryAction === 'reactivate_plan'
        ? t('components.billingpanel.reactivate_plan')
        : billingSummary.primaryAction === 'manage_plan'
          ? t('components.billingpanel.manage_current_plan')
          : billingSummary.primaryAction === 'use_trial'
            ? t('components.billingpanel.use_trial_capacity')
            : t('components.billingpanel.activate_plan');

  useEffect(() => {
    if (professional?.billing_interval) setSelectedInterval(professional.billing_interval);
  }, [professional?.billing_interval]);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const checkout = params.get('checkout');
    if (checkout === 'success') setCheckoutStatus('success');
    else if (checkout === 'canceled' || checkout === 'cancelled') setCheckoutStatus('canceled');
    else return;

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
      <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
        <h2 className="text-2xl font-black text-foreground uppercase tracking-[0.12em]">
          {t('components.billingpanel.billing')}
        </h2>

        <div className="flex flex-wrap items-center gap-4">
          <div className="inline-flex rounded-xl border border-border bg-card p-1">
            {(['monthly', 'annual'] as BillingInterval[]).map((interval) => (
              <button
                key={interval}
                onClick={() => setSelectedInterval(interval)}
                className={`rounded-lg px-4 py-2 text-xs font-extrabold uppercase tracking-[0.16em] transition-colors ${
                  selectedInterval === interval
                    ? 'bg-primary text-primary-foreground'
                    : 'text-muted-foreground hover:text-foreground'
                }`}
              >
                {interval === 'monthly'
                  ? t('components.billingpanel.monthly')
                  : t('components.billingpanel.annual')}
              </button>
            ))}
          </div>
          <button
            onClick={() => handleCheckout(billingSummary.tier)}
            disabled={!professional || checkoutMutation.isPending}
            className="inline-flex h-11 items-center justify-center gap-2 rounded-xl bg-primary px-5 text-xs font-extrabold uppercase tracking-[0.16em] text-primary-foreground disabled:cursor-not-allowed disabled:opacity-50 shadow-sm"
          >
            {checkoutMutation.isPending ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                {t('components.billingpanel.redirecting')}
              </>
            ) : (
              primaryCtaLabel
            )}
          </button>
        </div>
      </div>

      {checkoutStatus === 'success' && (
        <div className="rounded-xl border border-primary/25 bg-primary/10 p-4 text-base font-semibold text-primary">
          {t('components.billingpanel.checkout_completed_if_the_stripe_webhook_has_not_landed_yet_refresh_the_')}
        </div>
      )}
      {checkoutStatus === 'canceled' && (
        <div className="rounded-xl border border-amber-500/25 bg-amber-500/10 p-4 text-base font-semibold text-amber-700 dark:text-amber-300">
          {t('components.billingpanel.checkout_canceled_no_billing_change_was_applied')}
        </div>
      )}

      <div className="portal-panel rounded-[1.6rem] p-8">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
          <div className="space-y-2">
            <p className="text-xs font-black uppercase tracking-[0.2em] text-primary">
              {t('components.billingpanel.current_state')}
            </p>
            <h3 className="text-2xl font-black text-foreground">{statusTitle}</h3>
            <p className="max-w-2xl text-base leading-relaxed text-muted-foreground">{statusBody}</p>
          </div>
          <div className="rounded-2xl border border-border bg-background px-5 py-4 text-base font-semibold">
            <p className="font-bold text-foreground">{billingStatusLabel}</p>
            <p className="mt-1 text-muted-foreground font-medium">
              {billingSummary.tierLabel} / {billingIntervalLabel}
            </p>
          </div>
        </div>
      </div>

      {billingSummary.proStatus === 'trialing' && billingSummary.clientLimit === 1 && (
        <div className="rounded-[1.6rem] border border-primary/20 bg-primary/5 p-6 text-base text-foreground">
          <div className="flex items-start gap-3">
            <BadgeCheck className="h-5 w-5 shrink-0 text-primary mt-0.5" />
            <div className="space-y-1">
              <p className="font-extrabold text-foreground">
                {t('components.billingpanel.you_are_on_the_free_trial_plan')}
              </p>
              <p className="text-sm font-semibold leading-relaxed text-muted-foreground">
                {t('components.billingpanel.your_trial_account_allows_you_to_connect_with_exactly_1_client_for_free_')}
              </p>
            </div>
          </div>
        </div>
      )}

      <section className="grid gap-6 md:grid-cols-2 xl:grid-cols-5">
        <SummaryCard
          label={t('components.billingpanel.access_status')}
          value={billingStatusLabel}
          tone={billingSummary.canOperatePractice ? 'good' : 'warn'}
          note={
            billingSummary.canOperatePractice
              ? t('components.billingpanel.invites_and_plan_publishing_are_enabled')
              : t('components.billingpanel.invites_and_new_plans_stay_blocked_until_billing_is_active')
          }
        />
        <SummaryCard
          label={t('components.billingpanel.commercial_tier')}
          value={billingSummary.tierLabel}
          note={t('components.billingpanel.access_and_capacity_tracked_separately')}
        />
        <SummaryCard
          label={t('components.billingpanel.billing_interval')}
          value={billingIntervalLabel}
          note={t('components.billingpanel.stored_separately_from_subscription_status')}
        />
        <SummaryCard
          label={t('components.billingpanel.connected_clients_summary')}
          value={String(connectedClients)}
          note={t('components.billingpanel.allowed_in_current_plan', {
            client_limit: billingSummary.clientLimit,
          })}
        />
        <SummaryCard
          label={t('components.billingpanel.remaining_slots')}
          value={String(billingSummary.remainingClientSlots)}
          note={
            billingSummary.atCapacity
              ? t('components.billingpanel.capacity_is_full_right_now')
              : t('components.billingpanel.room_to_invite_more_clients')
          }
        />
      </section>

      {!billingSummary.canOperatePractice && (
        <section className="rounded-2xl border border-amber-500/25 bg-amber-500/10 p-6">
          <div className="flex items-start gap-3">
            <ShieldAlert className="mt-0.5 h-5 w-5 text-amber-500 dark:text-amber-300" />
            <div className="space-y-1">
              <p className="text-base font-black text-foreground dark:text-white">
                {t('components.billingpanel.practice_not_operational_yet')}
              </p>
              <p className="text-base leading-relaxed text-amber-900 dark:text-amber-100 font-semibold">
                {t('components.billingpanel.practice_not_operational_status_body', {
                  status: billingSummary.proStatus,
                })}
              </p>
            </div>
          </div>
        </section>
      )}

      <section className="grid gap-6 xl:grid-cols-3">
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
              className={`rounded-[1.6rem] border p-8 flex flex-col justify-between ${
                isCurrentPlan ? 'border-primary bg-primary/10' : 'portal-panel'
              }`}
            >
              <div>
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <p className="text-base font-black uppercase tracking-[0.2em] text-primary">
                      {tier.name}
                    </p>
                    <h3 className="portal-metric mt-3 text-4xl font-black text-foreground">
                      {price}
                    </h3>
                  </div>
                  <div className="portal-soft-panel rounded-xl px-4 py-3 text-right">
                    <p className="text-[11px] font-black uppercase tracking-[0.16em] text-muted-foreground">
                      {t('components.billingpanel.capacity')}
                    </p>
                    <p className="mt-1 flex items-center gap-1.5 text-base font-black text-foreground">
                      <Users className="h-4.5 w-4.5 text-primary" />
                      {tier.clientLimit}
                    </p>
                  </div>
                </div>

                <p className="mt-4 text-base leading-relaxed text-muted-foreground font-semibold">
                  {t(tierSummaryKey[tier.id])}
                </p>

                <ul className="mt-5 space-y-3.5">
                  {tierFeatureKeys[tier.id].map((featureKey) => (
                    <li key={featureKey} className="flex items-start gap-2.5 text-base font-semibold text-muted-foreground">
                      <BadgeCheck className="mt-0.5 h-5 w-5 shrink-0 text-primary" />
                      <span>{t(featureKey)}</span>
                    </li>
                  ))}
                </ul>
              </div>

              <button
                onClick={() => handleCheckout(tier.id)}
                disabled={!professional || isCurrentPlan || checkoutMutation.isPending}
                className={`mt-8 flex w-full items-center justify-center gap-2.5 rounded-xl px-5 py-3.5 text-xs font-extrabold uppercase tracking-[0.16em] transition-colors ${
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

      <section className="portal-panel rounded-[1.6rem] p-8">
        <h3 className="text-xl font-black uppercase tracking-[0.16em] text-foreground">
          {t('components.billingpanel.operating_faq')}
        </h3>
        <div className="mt-5 grid gap-4 md:grid-cols-2">
          <InfoCard
            title={t('components.billingpanel.what_unlocks_after_payment')}
            body={t('components.billingpanel.what_unlocks_after_payment_body')}
          />
          <InfoCard
            title={t('components.billingpanel.what_happens_if_i_cancel')}
            body={t('components.billingpanel.what_happens_if_i_cancel_body')}
          />
          <InfoCard
            title={t('components.billingpanel.how_does_the_1_client_trial_work')}
            body={t('components.billingpanel.how_does_the_1_client_trial_work_body')}
          />
          <InfoCard
            title={t('components.billingpanel.what_if_checkout_succeeds_but_portal_looks_stale')}
            body={t('components.billingpanel.what_if_checkout_succeeds_but_portal_looks_stale_body')}
          />
        </div>
      </section>

      <section className="portal-panel rounded-[1.6rem] p-8">
        <h3 className="text-xl font-black uppercase tracking-[0.16em] text-foreground">
          {t('components.billingpanel.data_contract_reminders')}
        </h3>
        <div className="mt-5 grid gap-4 md:grid-cols-2">
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
  <div className="portal-soft-panel rounded-xl p-6">
    <p className="text-xs font-black uppercase tracking-[0.2em] text-muted-foreground">
      {label}
    </p>
    <p
      className={`mt-2.5 text-2xl font-black ${
        tone === 'good'
          ? 'text-primary'
          : tone === 'warn'
            ? 'text-amber-500 dark:text-amber-300'
            : 'text-foreground'
      }`}
    >
      {value}
    </p>
    <p className="mt-1.5 text-sm font-semibold leading-relaxed text-muted-foreground">{note}</p>
  </div>
);

const InfoCard: React.FC<{ title: string; body: string }> = ({ title, body }) => (
  <div className="portal-soft-panel rounded-xl p-6">
    <p className="text-base font-black text-foreground">{title}</p>
    <p className="mt-2.5 text-base font-semibold leading-relaxed text-muted-foreground">{body}</p>
  </div>
);
