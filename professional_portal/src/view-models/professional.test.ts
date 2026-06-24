import { describe, expect, it } from 'vitest';
import {
  getBillingSummary,
  hasProfessionalAccess,
  resolveWorkspaceState,
} from './professional';
import type { Professional } from '../types/database.types';

function makeProfessional(overrides: Partial<Professional> = {}): Professional {
  return {
    id: 'pro-1',
    user_id: 'user-1',
    display_name: 'Ana Pro',
    business_name: 'Ana Nutrition',
    pro_status: 'inactive',
    commercial_tier: 'starter',
    billing_interval: 'monthly',
    client_limit: 10,
    ...overrides,
  };
}

describe('professional view models', () => {
  it('resolves workspace states explicitly by pro status', () => {
    expect(resolveWorkspaceState(null)).toBe('needs_profile');
    expect(resolveWorkspaceState(makeProfessional({ pro_status: 'inactive' }))).toBe(
      'inactive_subscription',
    );
    expect(resolveWorkspaceState(makeProfessional({ pro_status: 'trialing' }))).toBe('trialing');
    expect(resolveWorkspaceState(makeProfessional({ pro_status: 'active' }))).toBe('active');
    expect(resolveWorkspaceState(makeProfessional({ pro_status: 'past_due' }))).toBe('past_due');
    expect(resolveWorkspaceState(makeProfessional({ pro_status: 'canceled' }))).toBe('canceled');
  });

  it('keeps active access limited to trialing and active', () => {
    expect(hasProfessionalAccess(makeProfessional({ pro_status: 'trialing' }))).toBe(true);
    expect(hasProfessionalAccess(makeProfessional({ pro_status: 'active' }))).toBe(true);
    expect(hasProfessionalAccess(makeProfessional({ pro_status: 'inactive' }))).toBe(false);
    expect(hasProfessionalAccess(makeProfessional({ pro_status: 'past_due' }))).toBe(false);
  });

  it('derives operational capabilities and capacity from connected clients', () => {
    const active = getBillingSummary(
      makeProfessional({ pro_status: 'active', client_limit: 3, commercial_tier: 'starter' }),
      2,
    );

    expect(active.canOperatePractice).toBe(true);
    expect(active.canInviteClients).toBe(true);
    expect(active.canPublishPlans).toBe(true);
    expect(active.remainingClientSlots).toBe(1);
    expect(active.primaryAction).toBe('manage_plan');

    const fullTrial = getBillingSummary(
      makeProfessional({ pro_status: 'trialing', client_limit: 1 }),
      1,
    );

    expect(fullTrial.canOperatePractice).toBe(true);
    expect(fullTrial.canInviteClients).toBe(false);
    expect(fullTrial.atCapacity).toBe(true);
    expect(fullTrial.primaryAction).toBe('use_trial');
  });

  it('keeps historical read-only mode for non-operational billing states', () => {
    const pastDue = getBillingSummary(makeProfessional({ pro_status: 'past_due' }), 4);
    const canceled = getBillingSummary(makeProfessional({ pro_status: 'canceled' }), 4);

    expect(pastDue.canOperatePractice).toBe(false);
    expect(pastDue.isReadOnlyHistoricalMode).toBe(true);
    expect(pastDue.primaryAction).toBe('resolve_payment');

    expect(canceled.canOperatePractice).toBe(false);
    expect(canceled.isReadOnlyHistoricalMode).toBe(true);
    expect(canceled.primaryAction).toBe('reactivate_plan');
  });
});
