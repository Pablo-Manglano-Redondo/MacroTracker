import type { ProfessionalClient } from '../types/database.types';

/**
 * A synthetic demo client injected into the UI during the onboarding tour
 * when the professional has no real connected clients yet.
 * It is clearly marked as a demo and never persisted.
 */
export const DEMO_CLIENT_ID = '__tour_demo_client__';

export function buildDemoClient(professionalId: string, clientName: string): ProfessionalClient {
  return {
    id: DEMO_CLIENT_ID,
    professional_id: professionalId,
    client_id: DEMO_CLIENT_ID,
    status: 'connected',
    sharing_mode: 'aggregate',
    display_name: clientName,
    avatar_url: null,
    notes: null,
    connected_at: new Date().toISOString(),
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    client_shared_snapshots: [],
    is_demo: true,
  } as unknown as ProfessionalClient;
}

export function isDemoClient(client: ProfessionalClient | null | undefined): boolean {
  return client?.client_id === DEMO_CLIENT_ID || (client as any)?.is_demo === true;
}
