import type {
  ClientSharedSnapshot,
  ProfessionalClient,
} from '../types/database.types';

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

export function getRelationshipStatusLabel(status: string) {
  if (status === 'connected') return 'Activo';
  if (status === 'revoked') return 'Revocado';
  if (status === 'archived') return 'Archivado';
  return status;
}

export function getSharingModeLabel(sharingMode: string) {
  if (sharingMode === 'detailed') return 'Detallado';
  if (sharingMode === 'aggregate') return 'Agregado';
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
