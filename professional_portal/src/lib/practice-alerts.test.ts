import { describe, expect, it } from 'vitest';
import {
  getPracticeAlertBody,
  getPracticeAlertSeverityLabel,
  getPracticeAlertTitle,
  sortPracticeAlerts,
} from './practice-alerts';
import type { PracticeAlert } from '../types/database.types';

const baseAlert: PracticeAlert = {
  id: 'alert-1',
  professional_id: 'pro-1',
  professional_client_id: 'pc-1',
  alert_type: 'client_without_plan',
  severity: 'high',
  status: 'open',
  title_key: 'practice_alert.client_without_plan.title',
  title: 'Client without active plan',
  body_key: 'practice_alert.client_without_plan.body',
  body: 'Open the plan workspace and publish a plan for this client.',
  action_kind: 'open_client_tab',
  action_target_tab: 'plans',
  action_payload: { professional_client_id: 'pc-1', client_id: 'client-1', tab: 'plans' },
  evidence: {},
  dedupe_key: 'client_without_plan:pc-1',
  detected_at: '2026-06-26T08:00:00.000Z',
  updated_at: '2026-06-26T08:00:00.000Z',
  resolved_at: null,
  created_at: '2026-06-26T08:00:00.000Z',
};

describe('practice alert helpers', () => {
  it('sorts alerts by severity and recency', () => {
    const alerts: PracticeAlert[] = [
      { ...baseAlert, id: 'low', severity: 'low', detected_at: '2026-06-26T10:00:00.000Z' },
      { ...baseAlert, id: 'critical', severity: 'critical', detected_at: '2026-06-26T09:00:00.000Z' },
      { ...baseAlert, id: 'high-new', severity: 'high', detected_at: '2026-06-26T11:00:00.000Z' },
    ];

    expect(sortPracticeAlerts(alerts).map((alert) => alert.id)).toEqual([
      'critical',
      'high-new',
      'low',
    ]);
  });

  it('returns localized labels and copy', () => {
    expect(getPracticeAlertSeverityLabel('critical', 'es')).toBe('Crítica');
    expect(getPracticeAlertTitle(baseAlert, 'es')).toBe('Cliente sin plan activo');
    expect(getPracticeAlertBody(baseAlert, 'en')).toContain('publish a plan');
  });
});
