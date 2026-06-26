import { openInviteModal } from './portal-events';
import type {
  PracticeAlert,
  PracticeAlertAction,
  PracticeAlertSeverity,
  ProfessionalClient,
} from '../types/database.types';
import { getClientDisplayName } from '../view-models/clients';

type PortalLocale = 'en' | 'es';

const severityRank: Record<PracticeAlertSeverity, number> = {
  critical: 4,
  high: 3,
  medium: 2,
  low: 1,
};

const text = {
  en: {
    title: 'Action queue',
    hasAlerts: 'Has alerts',
    clear: 'No active alerts',
    clearBody: 'The roster is clear right now. KPIs stay visible, but there is nothing blocked in triage.',
    refresh: 'Refresh alerts',
    dismiss: 'Dismiss',
    resolve: 'Mark resolved',
    critical: 'Critical',
    high: 'High',
    medium: 'Medium',
    low: 'Low',
    openClient: 'Open client',
    openBilling: 'Review billing',
    openInvite: 'Open invite flow',
    openRoster: 'Open roster',
    summaryCritical: 'Critical',
    summaryHigh: 'High',
    summaryResolvedToday: 'Resolved today',
    practiceBlockedTitle: 'Practice requires billing attention',
    practiceBlockedBody: 'Billing is not active, so new invites and plan operations are blocked.',
    noConnectedClientsTitle: 'No connected clients yet',
    noConnectedClientsBody: 'Invite the first client to start using the roster and follow-up workspace.',
    clientWithoutPlanTitle: 'Client without active plan',
    clientWithoutPlanBody: 'Open the plan workspace and publish a plan for this client.',
    staleSnapshotTitle: 'Snapshot follow-up needed',
    staleSnapshotBody: 'This client has no recent shared snapshot to review.',
    lowAdherenceTitle: 'Low adherence detected',
    lowAdherenceBody: 'Review the client summary to understand what is blocking adherence.',
    unreadMessagesTitle: 'Unread client messages',
    unreadMessagesBody: 'Open the conversation and reply to clear the backlog.',
    pendingCheckinTitle: 'Pending check-in review',
    pendingCheckinBody: 'Open recent check-ins and mark them as reviewed after triage.',
    inviteExpiringTitle: 'Pending invite expires soon',
    inviteExpiringBody: 'Review the invite before it expires and send a new one if needed.',
    clientWithoutPlanReason: 'No active plan',
    staleSnapshotReason: 'Snapshot stale',
    lowAdherenceReason: 'Low adherence',
    unreadReason: 'Unread messages',
    pendingCheckinReason: 'Pending check-in',
    inviteReason: 'Invite expiring',
    practiceReason: 'Billing blocked',
    noClientsReason: 'No connected clients',
  },
  es: {
    title: 'Cola de acción',
    hasAlerts: 'Con alertas',
    clear: 'No hay alertas activas',
    clearBody: 'La cartera está limpia ahora mismo. Los KPIs siguen visibles, pero no hay nada bloqueado en el triage.',
    refresh: 'Actualizar alertas',
    dismiss: 'Descartar',
    resolve: 'Marcar resuelta',
    critical: 'Crítica',
    high: 'Alta',
    medium: 'Media',
    low: 'Baja',
    openClient: 'Abrir cliente',
    openBilling: 'Revisar facturación',
    openInvite: 'Abrir invitación',
    openRoster: 'Abrir cartera',
    summaryCritical: 'Críticas',
    summaryHigh: 'Altas',
    summaryResolvedToday: 'Resueltas hoy',
    practiceBlockedTitle: 'La práctica necesita atención de facturación',
    practiceBlockedBody: 'La facturación no está activa, así que las invitaciones nuevas y la operativa de planes están bloqueadas.',
    noConnectedClientsTitle: 'Todavía no hay clientes conectados',
    noConnectedClientsBody: 'Invita al primer cliente para empezar a usar la cartera y el seguimiento.',
    clientWithoutPlanTitle: 'Cliente sin plan activo',
    clientWithoutPlanBody: 'Abre el espacio de planes y publica un plan para este cliente.',
    staleSnapshotTitle: 'Hace falta revisar snapshots',
    staleSnapshotBody: 'Este cliente no tiene un snapshot reciente para revisar.',
    lowAdherenceTitle: 'Se detectó baja adherencia',
    lowAdherenceBody: 'Revisa el resumen del cliente para entender qué está bloqueando la adherencia.',
    unreadMessagesTitle: 'Mensajes del cliente sin leer',
    unreadMessagesBody: 'Abre la conversación y responde para vaciar la cola.',
    pendingCheckinTitle: 'Seguimiento pendiente de revisar',
    pendingCheckinBody: 'Abre los seguimientos recientes y márcalos como revisados tras el triage.',
    inviteExpiringTitle: 'Una invitación pendiente caduca pronto',
    inviteExpiringBody: 'Revisa la invitación antes de que caduque y reenvía una nueva si hace falta.',
    clientWithoutPlanReason: 'Sin plan activo',
    staleSnapshotReason: 'Snapshot desactualizado',
    lowAdherenceReason: 'Baja adherencia',
    unreadReason: 'Mensajes sin leer',
    pendingCheckinReason: 'Seguimiento pendiente',
    inviteReason: 'Invitación caduca',
    practiceReason: 'Facturación bloqueada',
    noClientsReason: 'Sin clientes conectados',
  },
} as const;

function normalizeLocale(locale?: string): PortalLocale {
  return locale?.toLowerCase().startsWith('es') ? 'es' : 'en';
}

export function getPracticeAlertSeverityRank(severity: PracticeAlertSeverity) {
  return severityRank[severity] ?? 0;
}

export function sortPracticeAlerts(alerts: PracticeAlert[]) {
  return [...alerts].sort((left, right) => {
    const severityDiff =
      getPracticeAlertSeverityRank(right.severity) - getPracticeAlertSeverityRank(left.severity);
    if (severityDiff !== 0) return severityDiff;
    return Date.parse(right.detected_at) - Date.parse(left.detected_at);
  });
}

export function getPracticeAlertStrings(locale?: string) {
  return text[normalizeLocale(locale)];
}

export function getPracticeAlertTitle(alert: PracticeAlert, locale?: string) {
  const strings = getPracticeAlertStrings(locale);

  switch (alert.alert_type) {
    case 'practice_blocked':
      return strings.practiceBlockedTitle;
    case 'no_connected_clients':
      return strings.noConnectedClientsTitle;
    case 'client_without_plan':
      return strings.clientWithoutPlanTitle;
    case 'stale_snapshot':
      return strings.staleSnapshotTitle;
    case 'low_adherence':
      return strings.lowAdherenceTitle;
    case 'unread_messages':
      return strings.unreadMessagesTitle;
    case 'pending_checkin_review':
      return strings.pendingCheckinTitle;
    case 'pending_invite_expiring':
      return strings.inviteExpiringTitle;
    default:
      return alert.title;
  }
}

export function getPracticeAlertBody(alert: PracticeAlert, locale?: string) {
  const strings = getPracticeAlertStrings(locale);

  switch (alert.alert_type) {
    case 'practice_blocked':
      return strings.practiceBlockedBody;
    case 'no_connected_clients':
      return strings.noConnectedClientsBody;
    case 'client_without_plan':
      return strings.clientWithoutPlanBody;
    case 'stale_snapshot':
      return strings.staleSnapshotBody;
    case 'low_adherence':
      return strings.lowAdherenceBody;
    case 'unread_messages':
      return strings.unreadMessagesBody;
    case 'pending_checkin_review':
      return strings.pendingCheckinBody;
    case 'pending_invite_expiring':
      return strings.inviteExpiringBody;
    default:
      return alert.body ?? '';
  }
}

export function getPracticeAlertReason(alert: PracticeAlert, locale?: string) {
  const strings = getPracticeAlertStrings(locale);

  switch (alert.alert_type) {
    case 'practice_blocked':
      return strings.practiceReason;
    case 'no_connected_clients':
      return strings.noClientsReason;
    case 'client_without_plan':
      return strings.clientWithoutPlanReason;
    case 'stale_snapshot':
      return strings.staleSnapshotReason;
    case 'low_adherence':
      return strings.lowAdherenceReason;
    case 'unread_messages':
      return strings.unreadReason;
    case 'pending_checkin_review':
      return strings.pendingCheckinReason;
    case 'pending_invite_expiring':
      return strings.inviteReason;
    default:
      return alert.title;
  }
}

export function getPracticeAlertSeverityLabel(severity: PracticeAlertSeverity, locale?: string) {
  const strings = getPracticeAlertStrings(locale);
  return strings[severity];
}

export function getPracticeAlertAction(alert: PracticeAlert): PracticeAlertAction {
  return {
    kind: alert.action_kind,
    target_tab: alert.action_target_tab ?? null,
    payload: alert.action_payload ?? {},
  };
}

export function getPracticeAlertCtaLabel(alert: PracticeAlert, locale?: string) {
  const strings = getPracticeAlertStrings(locale);

  switch (alert.action_kind) {
    case 'open_billing_panel':
      return strings.openBilling;
    case 'open_invite_modal':
      return strings.openInvite;
    case 'open_clients_panel':
      return strings.openRoster;
    case 'open_client_tab':
      return strings.openClient;
    default:
      return strings.openRoster;
  }
}

export function executePracticeAlertAction(alert: PracticeAlert) {
  const action = getPracticeAlertAction(alert);

  if (action.kind === 'open_billing_panel') {
    window.location.hash = 'billing-panel';
    return;
  }

  if (action.kind === 'open_invite_modal') {
    openInviteModal();
    return;
  }

  if (action.kind === 'open_clients_panel') {
    window.location.hash = 'clients-panel';
    return;
  }

  const relationshipId = action.payload.professional_client_id;
  const clientId = action.payload.client_id;
  const tab = action.payload.tab ?? action.target_tab ?? 'summary';

  (window as any).__pendingClientTab = {
    clientId: relationshipId ?? clientId,
    tab,
  };

  window.location.hash = 'clients-panel';
  window.dispatchEvent(
    new CustomEvent('select-client', {
      detail: {
        relationshipId,
        clientId,
      },
    }),
  );
  window.dispatchEvent(
    new CustomEvent('select-client-tab', {
      detail: {
        clientId: relationshipId ?? clientId,
        tab,
      },
    }),
  );
}

export function groupAlertsByClient(alerts: PracticeAlert[]) {
  const map = new Map<string, PracticeAlert[]>();

  for (const alert of alerts) {
    if (!alert.professional_client_id) continue;
    const existing = map.get(alert.professional_client_id) ?? [];
    existing.push(alert);
    map.set(alert.professional_client_id, existing);
  }

  return map;
}

export function getTopClientAlert(alerts: PracticeAlert[]) {
  return sortPracticeAlerts(alerts)[0] ?? null;
}

export function resolveAlertClientName(
  alert: PracticeAlert,
  clientsById: Map<string, ProfessionalClient>,
) {
  if (!alert.professional_client_id) return null;
  const client = clientsById.get(alert.professional_client_id);
  if (!client) return null;
  return getClientDisplayName(client);
}
