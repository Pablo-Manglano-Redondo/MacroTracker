import React, { useMemo, useState } from 'react';
import {
  ArrowRight,
  ChevronDown,
  MessageSquare,
  RefreshCw,
  Search,
  ShieldAlert,
  SlidersHorizontal,
  UserPlus,
  Users,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { usePortalI18n } from '../lib/portal-i18n';
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

interface ClientsPanelProps {
  onSelectClient: (client: ProfessionalClient | null) => void;
  selectedClient: ProfessionalClient | null;
  onAddClient?: () => void;
}

type StatusFilter = 'all' | 'connected' | 'revoked' | 'archived' | 'attention' | 'no_plan';
type SharingFilter = 'all' | 'aggregate' | 'detailed' | 'stale_sync' | 'unread';

type RankedClient = {
  client: ProfessionalClient;
  unreadCount: number;
  latestSnapshotDate: string | null;
  adherence: number | null;
  actionScore: number;
  actionLabel: string;
};

export const ClientsPanel: React.FC<ClientsPanelProps> = ({
  onSelectClient,
  selectedClient,
  onAddClient,
}) => {
  const { professional } = useAuth();
  const { t } = usePortalI18n();
  const { data: clients = [], isLoading, refetch, isRefetching } = useClients(professional?.id);
  const { data: unreadCounts = {} } = useUnreadCounts(professional?.id);

  const connectedClients = useMemo(
    () => clients.filter((client) => client.status === 'connected').length,
    [clients],
  );
  const billingSummary = useMemo(
    () => getBillingSummary(professional, connectedClients),
    [connectedClients, professional],
  );

  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('all');
  const [sharingFilter, setSharingFilter] = useState<SharingFilter>('all');

  const getDaysSince = (dateStr: string) => {
    const date = new Date(dateStr);
    const diff = Date.now() - date.getTime();
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    return Math.max(1, days);
  };

  const getClientActiveLabel = (client: ProfessionalClient) => {
    if (client.status !== 'connected') {
      return t('components.clientspanel.days_ago', {
        count: getDaysSince(client.connected_at),
      });
    }

    const latest = getLatestSnapshot(client);
    if (!latest) return t('components.clientspanel.no_sync_short');

    const diffDays = getDaysSince(latest.snapshot_date);
    if (diffDays <= 3) return t('components.clientspanel.plan_active_short');

    return t('components.clientspanel.days_ago', { count: diffDays });
  };

  const rankedClients = useMemo<RankedClient[]>(() => {
    return clients
      .map((client) => {
        const unreadCount = unreadCounts[client.id] ?? 0;
        const latestSnapshot = getLatestSnapshot(client);
        const adherence = getSnapshotAdherence(latestSnapshot);
        let actionScore = 0;
        let actionLabel = t('components.clientspanel.stable');

        if (unreadCount > 0) {
          actionScore += 1000 + unreadCount;
          actionLabel = t('components.clientspanel.unread_messages');
        } else if (!latestSnapshot && client.status === 'connected') {
          actionScore += 800;
          actionLabel = t('components.clientspanel.no_sync_recent');
        } else if (adherence !== null && adherence < 75) {
          actionScore += 600 + (75 - adherence);
          actionLabel = t('components.clientspanel.need_attention');
        } else if (client.sharing_mode === 'detailed') {
          actionScore += 150;
          actionLabel = t('components.clientspanel.detailed_sharing');
        }

        actionScore += Date.parse(client.connected_at) / 1000000000000;

        return {
          client,
          unreadCount,
          latestSnapshotDate: latestSnapshot?.snapshot_date ?? null,
          adherence,
          actionScore,
          actionLabel,
        };
      })
      .sort((left, right) => right.actionScore - left.actionScore);
  }, [clients, t, unreadCounts]);

  const filteredClients = useMemo(() => {
    const query = search.trim().toLowerCase();

    return rankedClients.filter((entry) => {
      const { client, unreadCount, latestSnapshotDate } = entry;

      if (statusFilter === 'connected' && client.status !== 'connected') return false;
      if (statusFilter === 'revoked' && client.status !== 'revoked') return false;
      if (statusFilter === 'archived' && client.status !== 'archived') return false;
      if (
        statusFilter === 'attention' &&
        !(unreadCount > 0 || (!latestSnapshotDate && client.status === 'connected'))
      ) {
        return false;
      }
      if (statusFilter === 'no_plan' && client.status !== 'connected') return false;

      if (sharingFilter === 'aggregate' && client.sharing_mode !== 'aggregate') return false;
      if (sharingFilter === 'detailed' && client.sharing_mode !== 'detailed') return false;
      if (sharingFilter === 'stale_sync' && !!latestSnapshotDate) return false;
      if (sharingFilter === 'unread' && unreadCount === 0) return false;

      if (!query) return true;

      return (
        getClientDisplayName(client).toLowerCase().includes(query) ||
        client.client_id.toLowerCase().includes(query)
      );
    });
  }, [rankedClients, search, sharingFilter, statusFilter]);

  if (!professional) {
    return (
      <div className="portal-panel rounded-[1.6rem] p-6 text-sm leading-relaxed text-muted-foreground">
        {t('components.clientspanel.create_the_professional_profile_first_client_relationships_attach_to_the')}
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in-up">
      {!billingSummary.canOperatePractice && (
        <section className="rounded-2xl border border-amber-500/25 bg-amber-500/10 p-4">
          <div className="flex items-start gap-3">
            <ShieldAlert className="mt-0.5 h-5 w-5 text-amber-500 dark:text-amber-300" />
            <p className="text-sm leading-relaxed text-amber-900 dark:text-amber-100">
              {t('components.clientspanel.billing_not_active_roster_read_only')}
            </p>
          </div>
        </section>
      )}

      <section className="grid gap-6 lg:grid-cols-4 xl:grid-cols-5">
        <div className="portal-panel rounded-[1.6rem] p-5 lg:col-span-1 lg:self-start xl:col-span-1">
          <div className="flex flex-col gap-3 border-b border-border pb-4">
            <div className="flex gap-2">
              <div className="relative flex-1">
                <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <input
                  value={search}
                  onChange={(event) => setSearch(event.target.value)}
                  placeholder={t('components.clientspanel.search_clients')}
                  className="portal-input w-full rounded-xl py-2.5 pl-10 pr-3 text-sm font-semibold outline-none transition-colors focus:border-primary"
                />
              </div>
              <button
                onClick={() => refetch()}
                disabled={isRefetching}
                className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl border border-border bg-card text-foreground transition-colors hover:bg-accent disabled:opacity-50"
                title={t('components.clientspanel.refresh')}
              >
                <RefreshCw className={`h-4.5 w-4.5 text-muted-foreground ${isRefetching ? 'animate-spin' : ''}`} />
              </button>
              <button
                className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl border border-border bg-card text-foreground transition-colors hover:bg-accent"
                title={t('components.clientspanel.filter_settings')}
              >
                <SlidersHorizontal className="h-4.5 w-4.5 text-muted-foreground hover:text-foreground" />
              </button>
            </div>

            <div className="grid grid-cols-1 gap-2">
              <div className="relative">
                <select
                  value={statusFilter}
                  onChange={(event) => setStatusFilter(event.target.value as StatusFilter)}
                  className="portal-input w-full appearance-none rounded-xl px-3 py-2.5 pr-8 text-xs font-extrabold uppercase tracking-[0.14em] outline-none"
                >
                  <option value="all">{t('components.clientspanel.all_statuses')}</option>
                  <option value="attention">{t('components.clientspanel.require_attention')}</option>
                  <option value="connected">{t('components.clientspanel.connected')}</option>
                  <option value="revoked">{t('components.clientspanel.revoked')}</option>
                  <option value="archived">{t('components.clientspanel.archived')}</option>
                </select>
                <ChevronDown className="pointer-events-none absolute right-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
              </div>

              <div className="relative">
                <select
                  value={sharingFilter}
                  onChange={(event) => setSharingFilter(event.target.value as SharingFilter)}
                  className="portal-input w-full appearance-none rounded-xl px-3 py-2.5 pr-8 text-xs font-extrabold uppercase tracking-[0.14em] outline-none"
                >
                  <option value="all">{t('components.clientspanel.all_modes')}</option>
                  <option value="stale_sync">{t('components.clientspanel.no_sync_recent')}</option>
                  <option value="unread">{t('components.clientspanel.unread_messages')}</option>
                  <option value="aggregate">{t('components.clientspanel.aggregate')}</option>
                  <option value="detailed">{t('components.clientspanel.detailed')}</option>
                </select>
                <ChevronDown className="pointer-events-none absolute right-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
              </div>
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
                canInvite={billingSummary.canInviteClients}
                blockedByBilling={!billingSummary.canOperatePractice}
                onAddClient={onAddClient}
              />
            ) : (
              filteredClients.map((entry) => {
                const { client, adherence, unreadCount } = entry;
                const isSelected = selectedClient?.id === client.id;

                const dotColorClass =
                  client.status !== 'connected'
                    ? 'bg-muted/80'
                    : (adherence !== null && adherence < 75) || unreadCount > 0
                      ? 'bg-amber-500'
                      : 'bg-emerald-500';

                const activeLabel = getClientActiveLabel(client);
                const isActiveLabelGreen =
                  activeLabel === t('components.clientspanel.plan_active_short');

                return (
                  <button
                    key={client.id}
                    onClick={() => onSelectClient(isSelected ? null : client)}
                    className={`w-full rounded-2xl border p-5 text-left transition-all ${
                      isSelected
                        ? 'border-primary bg-primary/8 shadow-sm shadow-primary/5'
                        : 'border-border bg-card hover:bg-accent/40'
                    }`}
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div className="flex min-w-0 gap-3">
                        <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-sm font-extrabold text-primary">
                          {getClientInitials(client)}
                        </div>
                        <div className="min-w-0">
                          <p className="truncate text-base font-extrabold text-foreground">
                            {getClientDisplayName(client)}
                          </p>
                          <p className="mt-1 truncate text-xs font-medium text-muted-foreground">
                            {getRelationshipStatusLabel(client.status, t)} ·{' '}
                            {getSharingModeLabel(client.sharing_mode, t)}
                          </p>
                          <p
                            className={`mt-1.5 text-xs font-semibold leading-none ${
                              isActiveLabelGreen ? 'text-primary' : 'text-muted-foreground'
                            }`}
                          >
                            {activeLabel}
                          </p>
                          {client.status === 'connected' &&
                            adherence !== null &&
                            adherence < 75 && (
                              <div className="mt-2 flex flex-wrap">
                                <span className="inline-flex items-center rounded-lg border border-[#f59e0b]/20 bg-[#f59e0b]/10 px-2 py-0.5 text-[10px] font-bold text-[#f59e0b]">
                                  {t('components.clientspanel.low_adherence_badge')}
                                </span>
                              </div>
                            )}
                        </div>
                      </div>

                      <div className="flex shrink-0 flex-col items-end justify-between gap-2.5">
                        <span className={`h-2.5 w-2.5 rounded-full ${dotColorClass}`} />

                        {unreadCount > 0 && (
                          <span className="inline-flex items-center gap-1 rounded-full bg-rose-500 px-2 py-0.5 text-[9px] font-bold text-white">
                            <MessageSquare className="h-2.5 w-2.5" />
                            {unreadCount}
                          </span>
                        )}
                      </div>
                    </div>
                  </button>
                );
              })
            )}
          </div>

          {!isLoading && (
            <div className="mt-4 border-t border-border/60 pt-3 text-xs font-semibold text-muted-foreground">
              {t('components.clientspanel.showing_clients_count', {
                visible: filteredClients.length,
                total: clients.length,
              })}
            </div>
          )}
        </div>

        <div className="lg:col-span-3 xl:col-span-4" id="client-detail-section">
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
                {t('components.clientspanel.open_real_client_workspace')}
              </p>
            </section>
          )}
        </div>
      </section>
    </div>
  );
};

const EmptyRosterState: React.FC<{
  hasClients: boolean;
  canInvite: boolean;
  blockedByBilling: boolean;
  onAddClient?: () => void;
}> = ({ hasClients, canInvite, blockedByBilling, onAddClient }) => {
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
          : blockedByBilling
            ? t('components.clientspanel.roster_empty_billing_blocked')
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
