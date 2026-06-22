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
  const { t } = usePortalI18n();
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
        {t('components.clientspanel.create_the_professional_profile_first_client_relationships_attach_to_the')}
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in-up">
      <section className="portal-hero rounded-[1.8rem] p-6">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
          <div className="space-y-2">
            <p className="portal-kicker">{t('components.clientspanel.clinical_roster')}</p>
            <h2 className="portal-title text-3xl text-foreground">
              {t('components.clientspanel.clients_and_real_relationship_state')}
            </h2>
            <p className="max-w-3xl text-sm leading-relaxed text-muted-foreground">
              {t('components.clientspanel.this_roster_only_reflects_professional_clients_relationships_their_shari')}
            </p>
          </div>

          <div className="flex flex-wrap gap-3">
            <button
              onClick={() => refetch()}
              className="rounded-xl border border-border bg-card px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-foreground transition-colors hover:bg-accent"
            >
              {isRefetching ? t('components.clientspanel.refreshing') : t('components.clientspanel.refresh')}
            </button>
            {onAddClient && (
              <button
                onClick={onAddClient}
                disabled={!billingSummary.hasProfessionalAccess}
                className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground transition-colors hover:opacity-95 disabled:cursor-not-allowed disabled:opacity-50"
              >
                <UserPlus className="h-4 w-4" />
                {t('components.clientspanel.invite_client')}
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
              {t('components.clientspanel.billing_is_not_active_so_new_invites_should_remain_blocked_existing_conn')}
            </p>
          </div>
        </section>
      )}

      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <StatCard
          label={t('components.clientspanel.connected')}
          value={stats.connected}
          note={t('components.clientspanel.active_relationships')}
        />
        <StatCard
          label={t('components.clientspanel.detailed_sharing')}
          value={stats.detailed}
          note={t('components.clientspanel.detailed_diary_enabled')}
        />
        <StatCard
          label={t('components.clientspanel.with_snapshots')}
          value={stats.withRecentSnapshots}
          note={t('components.clientspanel.at_least_one_sync_received')}
        />
        <StatCard
          label={t('components.clientspanel.unread_threads')}
          value={stats.unreadThreads}
          note={t('components.clientspanel.client_messages_awaiting_review')}
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
                placeholder={t('components.clientspanel.search_clients')}
                className="portal-input w-full rounded-xl py-2 pl-10 pr-3 text-sm font-medium outline-none transition-colors focus:border-primary"
              />
            </div>

            <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
              <select
                value={statusFilter}
                onChange={(event) => setStatusFilter(event.target.value as StatusFilter)}
                className="portal-input rounded-xl px-3 py-2 text-xs font-bold uppercase tracking-[0.14em] outline-none"
              >
                <option value="all">{t('components.clientspanel.all_statuses')}</option>
                <option value="connected">{t('components.clientspanel.connected')}</option>
                <option value="revoked">{t('components.clientspanel.revoked')}</option>
                <option value="archived">{t('components.clientspanel.archived')}</option>
              </select>
              <select
                value={sharingFilter}
                onChange={(event) => setSharingFilter(event.target.value as SharingFilter)}
                className="portal-input rounded-xl px-3 py-2 text-xs font-bold uppercase tracking-[0.14em] outline-none"
              >
                <option value="all">{t('components.clientspanel.all_sharing')}</option>
                <option value="aggregate">{t('components.clientspanel.aggregate')}</option>
                <option value="detailed">{t('components.clientspanel.detailed')}</option>
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
                            {getRelationshipStatusLabel(client.status, t)} · {getSharingModeLabel(client.sharing_mode, t)}
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
                          ? t('components.clientspanel.snapshot', { latestsnapshot_snapshot_date: latestSnapshot.snapshot_date })
                          : t('components.clientspanel.no_snapshots_synced_yet')}
                      </span>
                      <span className="font-semibold text-foreground">
                        {adherence === null ? t('components.clientspanel.no_adherence') : `${adherence}% kcal`}
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
                {t('components.clientspanel.select_a_client')}
              </h3>
              <p className="mt-2 max-w-md text-sm leading-relaxed text-muted-foreground">
                {t('components.clientspanel.use_the_roster_to_open_the_real_workflow_for_plans_notes_snapshots_check')}
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
  const { t } = usePortalI18n();

  return (
    <div className="portal-soft-panel rounded-2xl p-6 text-center">
      <p className="text-sm font-bold text-foreground">
        {hasClients
          ? t('components.clientspanel.no_clients_match_the_current_filters')
          : t('components.clientspanel.no_client_relationships_yet')}
      </p>
      <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
        {hasClients
          ? t('components.clientspanel.clear_the_filters_or_search_query_to_see_the_full_roster_again')
          : t('components.clientspanel.connected_relationships_will_appear_here_after_the_client_accepts_an_inv')}
      </p>
      {onAddClient && !hasClients && (
        <button
          onClick={onAddClient}
          disabled={!canInvite}
          className="mt-4 inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground disabled:cursor-not-allowed disabled:opacity-50"
        >
          <UserPlus className="h-4 w-4" />
          {t('components.clientspanel.invite_first_client')}
        </button>
      )}
      {hasClients && (
        <div className="mt-4 inline-flex items-center gap-2 text-xs font-bold uppercase tracking-[0.16em] text-primary">
          {t('components.clientspanel.review_filters')}
          <ArrowRight className="h-4 w-4" />
        </div>
      )}
    </div>
  );
};
