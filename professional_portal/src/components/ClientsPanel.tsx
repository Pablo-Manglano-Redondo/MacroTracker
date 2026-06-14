import React, { useMemo, useState } from 'react';
import {
  ArrowRight,
  MessageSquare,
  Search,
  ShieldAlert,
  UserPlus,
  Users,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { useClients, useUnreadCounts } from '../hooks/queries/useClients';
import type { ProfessionalClient } from '../types/database.types';
import { ClientDetail } from './ClientDetail';
import { Skeleton } from './ui/skeleton';
import {
  getClientDisplayName,
  getClientInitials,
  getLatestSnapshot,
  getRelationshipStatusLabel,
  getSharingModeLabel,
  getSnapshotAdherence,
} from '../view-models/clients';
import { getBillingSummary } from '../view-models/professional';
import { usePortalI18n } from '../lib/portal-i18n';

interface ClientsPanelProps {
  onSelectClient: (client: ProfessionalClient | null) => void;
  selectedClient: ProfessionalClient | null;
  onAddClient?: () => void;
}

type StatusFilter = 'all' | 'connected' | 'revoked' | 'archived';
type SharingFilter = 'all' | 'aggregate' | 'detailed';

export const ClientsPanel: React.FC<ClientsPanelProps> = ({
  onSelectClient,
  selectedClient,
  onAddClient,
}) => {
  const { professional } = useAuth();
  const { tr } = usePortalI18n();
  const billingSummary = useMemo(() => getBillingSummary(professional), [professional]);
  const { data: clients = [], isLoading, refetch, isRefetching } = useClients(professional?.id);
  const { data: unreadCounts = {} } = useUnreadCounts(professional?.id);

  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('all');
  const [sharingFilter, setSharingFilter] = useState<SharingFilter>('all');

  const filteredClients = useMemo(() => {
    const query = search.trim().toLowerCase();

    return clients
      .filter((client) => {
        if (statusFilter !== 'all' && client.status !== statusFilter) return false;
        if (sharingFilter !== 'all' && client.sharing_mode !== sharingFilter) return false;
        if (!query) return true;

        return (
          getClientDisplayName(client).toLowerCase().includes(query) ||
          client.client_id.toLowerCase().includes(query)
        );
      })
      .sort((left, right) => right.connected_at.localeCompare(left.connected_at));
  }, [clients, search, sharingFilter, statusFilter]);

  const stats = useMemo(() => {
    const connected = clients.filter((client) => client.status === 'connected').length;
    const detailed = clients.filter((client) => client.sharing_mode === 'detailed').length;
    const withRecentSnapshots = clients.filter((client) => getLatestSnapshot(client)).length;
    const unreadThreads = Object.values(unreadCounts).filter((count) => count > 0).length;

    return {
      connected,
      detailed,
      withRecentSnapshots,
      unreadThreads,
    };
  }, [clients, unreadCounts]);

  if (!professional) {
    return (
      <div className="portal-panel rounded-[1.6rem] p-6 text-sm leading-relaxed text-muted-foreground">
        {tr(
          'Primero crea el perfil profesional. Las relaciones cliente-profesional cuelgan del registro profesional, no del usuario auth en bruto.',
          'Create the professional profile first. Client relationships attach to the professional record, not to the raw auth user.',
        )}
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in-up">
      <section className="portal-hero rounded-[1.8rem] p-6">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
          <div className="space-y-2">
            <p className="portal-kicker">{tr('Roster clínico', 'Clinical roster')}</p>
            <h2 className="portal-title text-3xl text-foreground">
              {tr('Clientes y estado real de la relación.', 'Clients and real relationship state.')}
            </h2>
            <p className="max-w-3xl text-sm leading-relaxed text-muted-foreground">
              {tr(
                'Este roster solo refleja relaciones `professional_clients`, su modo de sharing y el último snapshot sincronizado.',
                'This roster only reflects `professional_clients` relationships, their sharing mode, and the latest synced snapshot.',
              )}
            </p>
          </div>

          <div className="flex flex-wrap gap-3">
            <button
              onClick={() => refetch()}
              className="rounded-xl border border-border bg-card px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-foreground transition-colors hover:bg-accent"
            >
              {isRefetching ? tr('Actualizando...', 'Refreshing...') : tr('Actualizar', 'Refresh')}
            </button>
            {onAddClient && (
              <button
                onClick={onAddClient}
                disabled={!billingSummary.hasProfessionalAccess}
                className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground transition-colors hover:opacity-95 disabled:cursor-not-allowed disabled:opacity-50"
              >
                <UserPlus className="h-4 w-4" />
                {tr('Invitar cliente', 'Invite client')}
              </button>
            )}
          </div>
        </div>
      </section>

      {!billingSummary.hasProfessionalAccess && (
        <section className="rounded-2xl border border-amber-500/25 bg-amber-500/10 p-4">
          <div className="flex items-start gap-3">
            <ShieldAlert className="mt-0.5 h-5 w-5 text-amber-500 dark:text-amber-300" />
            <p className="text-sm leading-relaxed text-amber-900 dark:text-amber-100">
              {tr(
                'La facturación no está activa, así que las nuevas invitaciones deben seguir bloqueadas. Las relaciones ya conectadas aún pueden aparecer aquí en modo lectura.',
                'Billing is not active, so new invites should remain blocked. Existing connected relationships may still appear here in read-only mode.',
              )}
            </p>
          </div>
        </section>
      )}

      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label={tr('Conectados', 'Connected')}
          value={stats.connected}
          note={tr('Relaciones activas', 'Active relationships')}
        />
        <StatCard
          label={tr('Sharing detailed', 'Detailed sharing')}
          value={stats.detailed}
          note={tr('Diario detallado habilitado', 'Detailed diary enabled')}
        />
        <StatCard
          label={tr('Con snapshots', 'With snapshots')}
          value={stats.withRecentSnapshots}
          note={tr('Al menos un sync recibido', 'At least one sync received')}
        />
        <StatCard
          label={tr('Hilos sin leer', 'Unread threads')}
          value={stats.unreadThreads}
          note={tr('Mensajes pendientes de revisar', 'Client messages awaiting review')}
        />
      </section>

      <section className="grid gap-6 xl:grid-cols-12">
        <div className="portal-panel rounded-[1.6rem] p-5 xl:col-span-4 xl:self-start">
          <div className="flex flex-col gap-3 border-b border-border pb-4">
            <div className="relative">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <input
                value={search}
                onChange={(event) => setSearch(event.target.value)}
                placeholder={tr('Buscar clientes', 'Search clients')}
                className="portal-input w-full rounded-xl py-2 pl-10 pr-3 text-sm font-medium outline-none transition-colors focus:border-primary"
              />
            </div>

            <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
              <select
                value={statusFilter}
                onChange={(event) => setStatusFilter(event.target.value as StatusFilter)}
                className="portal-input rounded-xl px-3 py-2 text-xs font-bold uppercase tracking-[0.14em] outline-none"
              >
                <option value="all">{tr('Todos los estados', 'All statuses')}</option>
                <option value="connected">{tr('Conectado', 'Connected')}</option>
                <option value="revoked">{tr('Revocado', 'Revoked')}</option>
                <option value="archived">{tr('Archivado', 'Archived')}</option>
              </select>
              <select
                value={sharingFilter}
                onChange={(event) => setSharingFilter(event.target.value as SharingFilter)}
                className="portal-input rounded-xl px-3 py-2 text-xs font-bold uppercase tracking-[0.14em] outline-none"
              >
                <option value="all">{tr('Todo el sharing', 'All sharing')}</option>
                <option value="aggregate">{tr('Agregado', 'Aggregate')}</option>
                <option value="detailed">{tr('Detallado', 'Detailed')}</option>
              </select>
            </div>
          </div>

          <div className="mt-4 space-y-2 xl:max-h-[calc(100vh-22rem)] xl:overflow-y-auto xl:pr-1">
            {isLoading ? (
              <div className="space-y-2">
                {[1, 2, 3].map((index) => (
                  <div key={index} className="portal-soft-panel rounded-2xl p-4">
                    <Skeleton className="h-4 w-32 bg-black/5 dark:bg-white/5" />
                    <Skeleton className="mt-2 h-3 w-48 bg-black/5 dark:bg-white/5" />
                  </div>
                ))}
              </div>
            ) : filteredClients.length === 0 ? (
              <EmptyRosterState
                hasClients={clients.length > 0}
                canInvite={billingSummary.hasProfessionalAccess}
                onAddClient={onAddClient}
              />
            ) : (
              filteredClients.map((client) => {
                const latestSnapshot = getLatestSnapshot(client);
                const adherence = getSnapshotAdherence(latestSnapshot);
                const isSelected = selectedClient?.id === client.id;
                const unreadCount = unreadCounts[client.id] ?? 0;

                return (
                  <button
                    key={client.id}
                    onClick={() => onSelectClient(isSelected ? null : client)}
                    className={`w-full rounded-2xl border p-4 text-left transition-colors ${
                      isSelected
                        ? 'border-primary bg-primary/8'
                        : 'border-border bg-card hover:bg-accent'
                    }`}
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div className="flex min-w-0 gap-3">
                        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/12 font-bold text-primary">
                          {getClientInitials(client)}
                        </div>
                        <div className="min-w-0">
                          <p className="truncate text-sm font-bold text-foreground">
                            {getClientDisplayName(client)}
                          </p>
                          <p className="mt-1 text-xs text-muted-foreground">
                            {getRelationshipStatusLabel(client.status)} · {getSharingModeLabel(client.sharing_mode)}
                          </p>
                        </div>
                      </div>

                      {unreadCount > 0 && (
                        <span className="inline-flex items-center gap-1 rounded-full bg-rose-500 px-2 py-1 text-[10px] font-bold text-white">
                          <MessageSquare className="h-3 w-3" />
                          {unreadCount}
                        </span>
                      )}
                    </div>

                    <div className="mt-3 flex items-center justify-between gap-3 text-xs text-muted-foreground">
                      <span>
                        {latestSnapshot
                          ? tr(
                              `Snapshot ${latestSnapshot.snapshot_date}`,
                              `Snapshot ${latestSnapshot.snapshot_date}`,
                            )
                          : tr('Todavía no hay snapshots', 'No snapshots synced yet')}
                      </span>
                      <span className="font-semibold text-foreground">
                        {adherence === null ? tr('Sin adherencia', 'No adherence') : `${adherence}% kcal`}
                      </span>
                    </div>
                  </button>
                );
              })
            )}
          </div>
        </div>

        <div className="xl:col-span-8" id="client-detail-section">
          {selectedClient ? (
            <ClientDetail
              client={selectedClient}
              onClose={() => onSelectClient(null)}
              onMessagesRead={() => {}}
              unreadCount={unreadCounts[selectedClient.id] ?? 0}
            />
          ) : (
            <section className="portal-panel flex min-h-[420px] flex-col items-center justify-center rounded-[1.6rem] p-8 text-center">
              <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-primary/12 text-primary">
                <Users className="h-6 w-6" />
              </div>
              <h3 className="portal-title mt-4 text-2xl text-foreground">
                {tr('Selecciona un cliente', 'Select a client')}
              </h3>
              <p className="mt-2 max-w-md text-sm leading-relaxed text-muted-foreground">
                {tr(
                  'Usa el roster para abrir el workflow real de planes, notas, snapshots, check-ins, diario detallado y chat. Si una superficie aún no tiene backend suficiente, debe decirlo.',
                  'Use the roster to open the real workflow for plans, notes, snapshots, check-ins, detailed diary, and chat. If a surface does not yet have enough backend support, it should say so explicitly.',
                )}
              </p>
            </section>
          )}
        </div>
      </section>
    </div>
  );
};

const StatCard: React.FC<{ label: string; value: number; note: string }> = ({
  label,
  value,
  note,
}) => (
  <div className="portal-panel rounded-[1.4rem] p-4">
    <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
      {label}
    </p>
    <p className="portal-metric mt-2 text-3xl font-extrabold text-foreground">{value}</p>
    <p className="mt-1 text-xs leading-relaxed text-muted-foreground">{note}</p>
  </div>
);

const EmptyRosterState: React.FC<{
  hasClients: boolean;
  canInvite: boolean;
  onAddClient?: () => void;
}> = ({ hasClients, canInvite, onAddClient }) => {
  const { tr } = usePortalI18n();

  return (
    <div className="portal-soft-panel rounded-2xl p-6 text-center">
      <p className="text-sm font-bold text-foreground">
        {hasClients
          ? tr('Ningún cliente coincide con los filtros', 'No clients match the current filters')
          : tr('Todavía no hay relaciones cliente-profesional', 'No client relationships yet')}
      </p>
      <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
        {hasClients
          ? tr(
              'Limpia los filtros o la búsqueda para volver a ver el roster completo.',
              'Clear the filters or search query to see the full roster again.',
            )
          : tr(
              'Las relaciones conectadas aparecerán aquí después de que el cliente acepte la invitación desde la app móvil.',
              'Connected relationships will appear here after the client accepts an invite from the mobile app.',
            )}
      </p>
      {onAddClient && !hasClients && (
        <button
          onClick={onAddClient}
          disabled={!canInvite}
          className="mt-4 inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground disabled:cursor-not-allowed disabled:opacity-50"
        >
          <UserPlus className="h-4 w-4" />
          {tr('Invitar primer cliente', 'Invite first client')}
        </button>
      )}
      {hasClients && (
        <div className="mt-4 inline-flex items-center gap-2 text-xs font-bold uppercase tracking-[0.16em] text-primary">
          {tr('Revisar filtros', 'Review filters')}
          <ArrowRight className="h-4 w-4" />
        </div>
      )}
    </div>
  );
};
