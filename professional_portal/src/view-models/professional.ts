import type { Professional } from '../types/database.types';

export type ProfessionalWorkspaceState =
  | 'needs_profile'
  | 'inactive_subscription'
  | 'operational';

const ACTIVE_PRO_STATUSES = new Set(['active', 'trialing']);

const TIER_LABELS: Record<'starter' | 'growth' | 'studio', string> = {
  starter: 'Starter',
  growth: 'Growth',
  studio: 'Studio',
};

const STATUS_LABELS: Record<string, string> = {
  inactive: 'Inactive',
  trialing: 'Trial active',
  active: 'Active',
  past_due: 'Past due',
  canceled: 'Canceled',
};

const INTERVAL_LABELS: Record<'monthly' | 'annual', string> = {
  monthly: 'Monthly',
  annual: 'Annual',
};

export function hasProfessionalAccess(professional: Professional | null | undefined) {
  return ACTIVE_PRO_STATUSES.has(professional?.pro_status ?? '');
}

export function resolveWorkspaceState(
  professional: Professional | null | undefined,
): ProfessionalWorkspaceState {
  if (!professional) return 'needs_profile';
  if (!hasProfessionalAccess(professional)) return 'inactive_subscription';
  return 'operational';
}

export function getBillingSummary(professional: Professional | null | undefined) {
  const tier = professional?.commercial_tier ?? inferTierFromLimit(professional?.client_limit ?? null);
  const billingInterval = professional?.billing_interval ?? 'monthly';
  const proStatus = professional?.pro_status ?? 'inactive';
  const clientLimit = professional?.client_limit ?? limitForTier(tier);

  return {
    tier,
    tierLabel: TIER_LABELS[tier] ?? 'Starter',
    billingInterval,
    billingIntervalLabel: INTERVAL_LABELS[billingInterval] ?? 'Monthly',
    proStatus,
    proStatusLabel: STATUS_LABELS[proStatus] ?? proStatus,
    clientLimit,
    hasProfessionalAccess: ACTIVE_PRO_STATUSES.has(proStatus),
  };
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
