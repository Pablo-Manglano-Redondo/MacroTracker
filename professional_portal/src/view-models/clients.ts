import type {
  ClientSharedSnapshot,
  ProfessionalClient,
} from '../types/database.types';
import type { PortalTranslationKey } from '../lib/generated/i18n';

type TranslateFn = (key: PortalTranslationKey) => string;

export function getClientDisplayName(client: ProfessionalClient) {
  return client.display_name?.trim() || client.client_id.slice(0, 8);
}

export function getClientInitials(client: ProfessionalClient) {
  const name = getClientDisplayName(client);
  return name
    .split(/\s+/)
    .map((part) => part[0])
    .join('')
    .slice(0, 2)
    .toUpperCase();
}

export function getRelationshipStatusLabel(status: string, t: TranslateFn) {
  if (status === 'connected') return t('components.clientspanel.connected');
  if (status === 'revoked') return t('components.clientspanel.revoked');
  if (status === 'archived') return t('components.clientspanel.archived');
  return status;
}

export function getSharingModeLabel(sharingMode: string, t: TranslateFn) {
  if (sharingMode === 'detailed') return t('components.clientspanel.detailed');
  if (sharingMode === 'aggregate') return t('components.clientspanel.aggregate');
  return sharingMode;
}

export function getLatestSnapshot(client: ProfessionalClient) {
  const snapshots = client.client_shared_snapshots ?? [];
  if (snapshots.length === 0) return null;

  return [...snapshots].sort((a, b) =>
    b.snapshot_date.localeCompare(a.snapshot_date),
  )[0] ?? null;
}

export function getSnapshotAdherence(snapshot: ClientSharedSnapshot | null) {
  if (!snapshot || snapshot.kcal_target <= 0) return null;
  const delta = Math.abs(snapshot.kcal_actual - snapshot.kcal_target);
  return Math.max(0, 100 - Math.round((delta / snapshot.kcal_target) * 100));
}
