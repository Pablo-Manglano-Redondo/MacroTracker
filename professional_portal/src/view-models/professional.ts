import type { PortalTranslationKey } from '../lib/generated/i18n';
import type { Professional } from '../types/database.types';

export type ProfessionalWorkspaceState =
  | 'trialing'
  | 'active'
  | 'past_due'
  | 'canceled'
  | 'needs_profile'
  | 'inactive_subscription'
  | 'operational';

export type BillingPrimaryAction =
  | 'activate_plan'
  | 'use_trial'
  | 'manage_plan'
  | 'resolve_payment'
  | 'reactivate_plan';

type ProfessionalStatus = 'inactive' | 'active' | 'trialing' | 'past_due' | 'canceled';

const ACTIVE_PRO_STATUSES = new Set(['active', 'trialing']);
const READ_ONLY_HISTORICAL_STATUSES = new Set(['inactive', 'past_due', 'canceled']);

const TIER_LABEL_KEYS: Record<'starter' | 'growth' | 'studio', PortalTranslationKey> = {
  starter: 'components.billingpanel.tier_starter',
  growth: 'components.billingpanel.tier_growth',
  studio: 'components.billingpanel.tier_studio',
};

const STATUS_LABEL_KEYS: Record<ProfessionalStatus, PortalTranslationKey> = {
  inactive: 'components.billingpanel.inactive',
  trialing: 'components.billingpanel.trial_active',
  active: 'components.billingpanel.active',
  past_due: 'components.billingpanel.past_due',
  canceled: 'components.billingpanel.canceled',
};

const INTERVAL_LABEL_KEYS: Record<'monthly' | 'annual', PortalTranslationKey> = {
  monthly: 'components.billingpanel.monthly',
  annual: 'components.billingpanel.annual',
};

export function getBillingTierLabelKey(
  tier: 'starter' | 'growth' | 'studio',
): PortalTranslationKey {
  return TIER_LABEL_KEYS[tier];
}

export function getBillingStatusLabelKey(
  proStatus: ProfessionalStatus,
): PortalTranslationKey {
  return STATUS_LABEL_KEYS[proStatus];
}

export function getBillingIntervalLabelKey(
  billingInterval: 'monthly' | 'annual',
): PortalTranslationKey {
  return INTERVAL_LABEL_KEYS[billingInterval];
}

export function hasProfessionalAccess(professional: Professional | null | undefined) {
  return ACTIVE_PRO_STATUSES.has(professional?.pro_status ?? '');
}

export function resolveWorkspaceState(
  professional: Professional | null | undefined,
): ProfessionalWorkspaceState {
  if (!professional) return 'needs_profile';
  if (professional.pro_status === 'trialing') return 'trialing';
  if (professional.pro_status === 'active') return 'active';
  if (professional.pro_status === 'past_due') return 'past_due';
  if (professional.pro_status === 'canceled') return 'canceled';
  if (!hasProfessionalAccess(professional)) return 'inactive_subscription';
  return 'operational';
}

export function getBillingSummary(
  professional: Professional | null | undefined,
  connectedClients = 0,
) {
  const tier = professional?.commercial_tier ?? inferTierFromLimit(professional?.client_limit ?? null);
  const billingInterval = professional?.billing_interval ?? 'monthly';
  const proStatus = normalizeProStatus(professional?.pro_status);
  const clientLimit = professional?.client_limit ?? limitForTier(tier);
  const hasAccess = ACTIVE_PRO_STATUSES.has(proStatus);
  const remainingClientSlots = Math.max(0, clientLimit - connectedClients);
  const atCapacity = remainingClientSlots <= 0;
  const isReadOnlyHistoricalMode = READ_ONLY_HISTORICAL_STATUSES.has(proStatus);
  const canOperatePractice = hasAccess;
  const canInviteClients = canOperatePractice && !atCapacity;
  const canPublishPlans = canOperatePractice;
  const requiresBillingAction = !hasAccess || proStatus === 'past_due';
  const primaryAction = resolvePrimaryBillingAction(proStatus);

  return {
    tier,
    tierLabelKey: getBillingTierLabelKey(tier),
    billingInterval,
    billingIntervalLabelKey: getBillingIntervalLabelKey(billingInterval),
    proStatus,
    proStatusLabelKey: getBillingStatusLabelKey(proStatus),
    clientLimit,
    connectedClients,
    remainingClientSlots,
    atCapacity,
    hasProfessionalAccess: hasAccess,
    canOperatePractice,
    canInviteClients,
    canPublishPlans,
    isReadOnlyHistoricalMode,
    requiresBillingAction,
    primaryAction,
  };
}

function normalizeProStatus(value: string | null | undefined): ProfessionalStatus {
  if (
    value === 'active' ||
    value === 'trialing' ||
    value === 'past_due' ||
    value === 'canceled'
  ) {
    return value;
  }
  return 'inactive';
}

function resolvePrimaryBillingAction(proStatus: ProfessionalStatus): BillingPrimaryAction {
  if (proStatus === 'trialing') return 'use_trial';
  if (proStatus === 'active') return 'manage_plan';
  if (proStatus === 'past_due') return 'resolve_payment';
  if (proStatus === 'canceled') return 'reactivate_plan';
  return 'activate_plan';
}

function inferTierFromLimit(clientLimit: number | null) {
  if ((clientLimit ?? 0) >= 500) return 'studio' as const;
  if ((clientLimit ?? 0) >= 50) return 'growth' as const;
  return 'starter' as const;
}

function limitForTier(tier: 'starter' | 'growth' | 'studio') {
  if (tier === 'studio') return 500;
  if (tier === 'growth') return 50;
  return 10;
}
