import React, { useEffect, useMemo, useState } from 'react';
import {
  ArrowRight,
  ChevronDown,
  MessageSquare,
  RefreshCw,
  Search,
  ShieldAlert,
  UserPlus,
  Users,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { usePortalI18n } from '../lib/portal-i18n';
import { useClients, useUnreadCounts } from '../hooks/queries/useClients';
import { useOpenPracticeAlerts } from '../hooks/queries/usePracticeAlerts';
import type { PracticeAlert, ProfessionalClient } from '../types/database.types';
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
import {
  getPracticeAlertReason,
  getPracticeAlertSeverityLabel,
  getPracticeAlertSeverityRank,
  getPracticeAlertStrings,
  getTopClientAlert,
  groupAlertsByClient,
  sortPracticeAlerts,
} from '../lib/practice-alerts';
import { trackPortalEvent } from '../lib/portal-analytics';

interface ClientsPanelProps {
  onSelectClient: (client: ProfessionalClient | null) => void;
  selectedClient: ProfessionalClient | null;
  onAddClient?: () => void;
  onClientUpdated?: (client: ProfessionalClient) => void;
}

type StatusFilter =
  | 'all'
  | 'connected'
  | 'revoked'
  | 'archived'
  | 'has_alerts'
  | 'critical'
  | 'needs_plan'
  | 'stale_snapshot'
  | 'low_adherence'
  | 'unread';
type SharingFilter = 'all' | 'aggregate' | 'detailed';

type RankedClient = {
  client: ProfessionalClient;
  unreadCount: number;
  latestSnapshotDate: string | null;
  adherence: number | null;
  maxAlertSeverity: number;
  openAlertCount: number;
  topAlert: PracticeAlert | null;
  actionScore: number;
  actionLabel: string;
};

const severityBadgeTone: Record<string, string> = {
  critical: 'bg-rose-500/10 text-rose-600 dark:text-rose-400 border border-rose-500/20',
  high: 'bg-amber-500/10 text-amber-700 dark:text-amber-400 border border-amber-500/20',
  medium: 'bg-sky-500/10 text-sky-700 dark:text-sky-400 border border-sky-500/20',
  low: 'bg-emerald-500/10 text-emerald-700 dark:text-emerald-400 border border-emerald-500/20',
};

export const ClientsPanel: React.FC<ClientsPanelProps> = ({
  onSelectClient,
  selectedClient,
  onAddClient,
  onClientUpdated,
}) => {
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();
  const alertStrings = getPracticeAlertStrings(locale);
  const { data: clients = [], isLoading, refetch, isRefetching } = useClients(professional?.id);
  const { data: unreadCounts = {} } = useUnreadCounts(professional?.id);
  const { data: openAlerts = [] } = useOpenPracticeAlerts(professional?.id);

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

  const alertsByClient = useMemo(() => groupAlertsByClient(openAlerts), [openAlerts]);

  useEffect(() => {
    if (!professional || openAlerts.length === 0) return;
    trackPortalEvent('roster_sorted_by_alerts', {
      professionalId: professional.id,
      openAlerts: openAlerts.length,
    });
  }, [openAlerts.length, professional]);

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
        const clientAlerts = sortPracticeAlerts(alertsByClient.get(client.id) ?? []);
        const topAlert = getTopClientAlert(clientAlerts);
        const maxAlertSeverity = topAlert ? getPracticeAlertSeverityRank(topAlert.severity) : 0;

        let actionScore = maxAlertSeverity * 10_000;
        let actionLabel = topAlert
          ? getPracticeAlertReason(topAlert, locale)
          : t('components.clientspanel.stable');

        if (topAlert?.alert_type === 'unread_messages') {
          actionScore += 5_000;
        } else if (topAlert?.alert_type === 'low_adherence') {
          actionScore += 4_000;
        } else if (topAlert?.alert_type === 'stale_snapshot') {
          actionScore += 3_000;
        }

        actionScore += unreadCount * 100;

        if (adherence !== null && adherence < 75) {
          actionScore += 75 - adherence;
        }

        actionScore += Date.parse(client.connected_at) / 1000000000000;

        return {
          client,
          unreadCount,
          latestSnapshotDate: latestSnapshot?.snapshot_date ?? null,
          adherence,
          maxAlertSeverity,
          openAlertCount: clientAlerts.length,
          topAlert,
          actionScore,
          actionLabel,
        };
      })
      .sort((left, right) => right.actionScore - left.actionScore);
  }, [alertsByClient, clients, locale, t, unreadCounts]);

  const filteredClients = useMemo(() => {
    const query = search.trim().toLowerCase();

    return rankedClients.filter((entry) => {
      const { client, unreadCount, topAlert, openAlertCount } = entry;

      if (statusFilter === 'connected' && client.status !== 'connected') return false;
      if (statusFilter === 'revoked' && client.status !== 'revoked') return false;
      if (statusFilter === 'archived' && client.status !== 'archived') return false;
      const clientAlerts = alertsByClient.get(client.id) ?? [];

      if (statusFilter === 'has_alerts' && openAlertCount === 0) return false;
      if (statusFilter === 'critical' && topAlert?.severity !== 'critical') return false;
      if (statusFilter === 'needs_plan' && !clientAlerts.some((alert) => alert.alert_type === 'client_without_plan')) return false;
      if (statusFilter === 'stale_snapshot' && !clientAlerts.some((alert) => alert.alert_type === 'stale_snapshot')) return false;
      if (statusFilter === 'low_adherence' && !clientAlerts.some((alert) => alert.alert_type === 'low_adherence')) return false;
      if (statusFilter === 'unread' && unreadCount === 0 && !clientAlerts.some((alert) => alert.alert_type === 'unread_messages')) return false;

      if (sharingFilter === 'aggregate' && client.sharing_mode !== 'aggregate') return false;
      if (sharingFilter === 'detailed' && client.sharing_mode !== 'detailed') return false;

      if (!query) return true;

      return (
        getClientDisplayName(client).toLowerCase().includes(query) ||
        client.client_id.toLowerCase().includes(query)
      );
    });
  }, [alertsByClient, rankedClients, search, sharingFilter, statusFilter]);

  if (!professional) {
    return (
      <div className="portal-panel rounded-[1.6rem] p-6 portal-body text-muted-foreground">
        {t('components.clientspanel.create_the_professional_profile_first_client_relationships_attach_to_the')}
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in-up">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <h2 className="portal-section-heading uppercase tracking-[0.12em]">
          {t('components.appshell.clients')}
        </h2>
        {onAddClient && (
          <button
            onClick={onAddClient}
            className="inline-flex h-12 items-center gap-2 rounded-xl bg-primary px-5 portal-action text-primary-foreground shadow-sm hover:opacity-95 transition-opacity"
          >
            <UserPlus className="h-4.5 w-4.5" />
            <span>{t('components.clientspanel.invite_client')}</span>
          </button>
        )}
      </div>

      {!billingSummary.canOperatePractice && (
        <section className="rounded-2xl border border-amber-500/25 bg-amber-500/10 p-4">
          <div className="flex items-start gap-3">
            <ShieldAlert className="mt-0.5 h-5 w-5 text-amber-500 dark:text-amber-300" />
            <p className="portal-body text-amber-900 dark:text-amber-100">
              {t('components.clientspanel.billing_not_active_roster_read_only')}
            </p>
          </div>
        </section>
      )}

      <section className="grid gap-6 grid-cols-1 lg:grid-cols-[280px_1fr] w-full">
        <div className="portal-panel rounded-[1.6rem] p-5 lg:self-start">
          <div className="flex flex-col gap-3 border-b border-border pb-4">
            <div className="flex gap-2">
              <div className="relative flex-1">
                <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <input
                  value={search}
                  onChange={(event) => setSearch(event.target.value)}
                  placeholder={t('components.clientspanel.search_clients')}
                  className="portal-input w-full rounded-xl py-2.5 pl-10 pr-3 outline-none transition-colors focus:border-primary"
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
            </div>

            <div className="space-y-3">
              <div className="space-y-1">
                <label className="portal-label pl-1 text-muted-foreground/80">
                  {t('components.clientspanel.status_filter_label')}
                </label>
                <div className="relative">
                  <select
                    value={statusFilter}
                    onChange={(event) => setStatusFilter(event.target.value as StatusFilter)}
                    className="portal-input w-full appearance-none rounded-xl px-3.5 py-2.5 pr-8 outline-none focus:border-primary transition-colors cursor-pointer"
                  >
                    <option value="all">{t('components.clientspanel.all_statuses')}</option>
                    <option value="has_alerts">{alertStrings.hasAlerts}</option>
                    <option value="critical">{alertStrings.critical}</option>
                    <option value="needs_plan">{alertStrings.clientWithoutPlanReason}</option>
                    <option value="stale_snapshot">{alertStrings.staleSnapshotReason}</option>
                    <option value="low_adherence">{alertStrings.lowAdherenceReason}</option>
                    <option value="unread">{alertStrings.unreadReason}</option>
                    <option value="connected">{t('components.clientspanel.connected')}</option>
                    <option value="revoked">{t('components.clientspanel.revoked')}</option>
                    <option value="archived">{t('components.clientspanel.archived')}</option>
                  </select>
                  <ChevronDown className="pointer-events-none absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground/60" />
                </div>
              </div>

              <div className="space-y-1">
                <label className="portal-label pl-1 text-muted-foreground/80">
                  {t('components.clientspanel.sharing_filter_label')}
                </label>
                <div className="relative">
                  <select
                    value={sharingFilter}
                    onChange={(event) => setSharingFilter(event.target.value as SharingFilter)}
                    className="portal-input w-full appearance-none rounded-xl px-3.5 py-2.5 pr-8 outline-none focus:border-primary transition-colors cursor-pointer"
                  >
                    <option value="all">{t('components.clientspanel.all_modes')}</option>
                    <option value="aggregate">{t('components.clientspanel.aggregate')}</option>
                    <option value="detailed">{t('components.clientspanel.detailed')}</option>
                  </select>
                  <ChevronDown className="pointer-events-none absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground/60" />
                </div>
              </div>
            </div>
          </div>

          <div id="tour-clients-list" className="mt-4 space-y-2 xl:max-h-[calc(100vh-22rem)] xl:overflow-y-auto px-1.5 py-1 xl:pr-1">
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
                const { client, adherence, unreadCount, openAlertCount, topAlert } = entry;
                const isSelected = selectedClient?.id === client.id;
                const activeLabel = getClientActiveLabel(client);
                const isActiveLabelGreen =
                  activeLabel === t('components.clientspanel.plan_active_short');
                const isLowAdherence = client.status === 'connected' && adherence !== null && adherence < 75;

                return (
                  <button
                    key={client.id}
                    onClick={() => onSelectClient(isSelected ? null : client)}
                    className={`group relative w-full rounded-2xl border p-4.5 text-left transition-all duration-300 hover:scale-[1.01] active:scale-[0.99] cursor-pointer ${
                      entry.maxAlertSeverity >= 4
                        ? isSelected
                          ? 'border-rose-500 bg-rose-500/8 dark:bg-rose-500/12 shadow-[0_4px_20px_-4px_rgba(244,63,94,0.15)]'
                          : 'border-rose-500/25 bg-rose-500/[0.02] dark:bg-rose-500/[0.03] hover:bg-rose-500/[0.05] hover:border-rose-500/40 hover:shadow-[0_4px_16px_rgba(244,63,94,0.04)]'
                        : isLowAdherence
                          ? isSelected
                            ? 'border-amber-500 bg-amber-500/8 dark:bg-amber-500/12 shadow-[0_4px_20px_-4px_rgba(245,158,11,0.12)]'
                            : 'border-amber-500/25 bg-amber-500/[0.02] dark:bg-amber-500/[0.03] hover:bg-amber-500/[0.05] hover:border-amber-500/40 hover:shadow-[0_4px_16px_rgba(245,158,11,0.03)]'
                          : isSelected
                            ? 'border-primary bg-primary/[0.04] dark:bg-primary/[0.06] shadow-[0_4px_20px_-4px_rgba(114,222,152,0.12)]'
                            : 'border-border/60 bg-card hover:bg-accent/40 hover:border-border hover:shadow-sm'
                    }`}
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div className="flex min-w-0 gap-3.5">
                        <div className="relative shrink-0">
                          <div className={`portal-card-heading flex h-11 w-11 shrink-0 items-center justify-center rounded-xl border text-sm font-bold tracking-normal group-hover:scale-105 transition-transform duration-300 ${
                            entry.maxAlertSeverity >= 4
                              ? 'bg-rose-500/10 text-rose-600 dark:text-rose-400 border-rose-500/20'
                              : isLowAdherence
                                ? 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/20'
                                : 'bg-primary/10 text-primary border-primary/20'
                          }`}>
                            {getClientInitials(client)}
                          </div>
                        </div>
                        <div className="min-w-0">
                          <p className="portal-card-heading truncate text-[15px] font-bold text-foreground tracking-tight group-hover:text-primary transition-colors duration-200">
                            {getClientDisplayName(client)}
                          </p>
                          <p className="text-xs mt-0.5 truncate text-muted-foreground/75 font-medium tracking-wide">
                            {client.status !== 'connected' && (
                              <>{getRelationshipStatusLabel(client.status, t)} · </>
                            )}
                            {getSharingModeLabel(client.sharing_mode, t)}
                          </p>
                          {(!isActiveLabelGreen || topAlert) && (
                            <div className="mt-2.5 flex flex-wrap items-center gap-1.5">
                              {!isActiveLabelGreen && (
                                <span className="portal-pill text-[10px] font-bold text-muted-foreground/70 bg-muted/10 px-2 py-0.5 rounded-full whitespace-nowrap">
                                  {activeLabel}
                                </span>
                              )}
                              {topAlert && (
                                <span className="portal-pill text-[10px] font-bold tracking-wider uppercase rounded-full border border-border/80 bg-background/50 px-2 py-0.5 text-muted-foreground whitespace-nowrap">
                                  {entry.actionLabel}
                                </span>
                              )}
                            </div>
                          )}
                        </div>
                      </div>

                      <div className="flex shrink-0 flex-col items-end justify-start gap-1.5 mt-0.5">
                        {topAlert && (
                          <span className={`portal-pill inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-extrabold whitespace-nowrap ${severityBadgeTone[topAlert.severity]}`}>
                            {getPracticeAlertSeverityLabel(topAlert.severity, locale)}
                          </span>
                        )}
                        {unreadCount > 0 && (
                          <span className="portal-pill inline-flex items-center gap-1 rounded-full bg-rose-500 px-2 py-0.5 text-[10px] font-extrabold text-white shadow-[0_2px_8px_rgba(244,63,94,0.4)] whitespace-nowrap">
                            <MessageSquare className="h-2.5 w-2.5" />
                            {unreadCount}
                          </span>
                        )}
                        {openAlertCount > 1 && (
                          <span className="portal-pill inline-flex items-center gap-1 rounded-full border border-border/80 bg-background/50 px-2 py-0.5 text-[10px] font-semibold text-muted-foreground whitespace-nowrap">
                            +{openAlertCount - 1}
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
            <div className="portal-meta mt-4 border-t border-border/60 pt-3 text-muted-foreground">
              {t('components.clientspanel.showing_clients_count', {
                visible: filteredClients.length,
                total: clients.length,
              })}
            </div>
          )}
        </div>

        <div id="client-detail-section" className="min-w-0 w-full">
          {selectedClient ? (
            <ClientDetail
              client={selectedClient}
              onClose={() => onSelectClient(null)}
              onMessagesRead={() => {}}
              unreadCount={unreadCounts[selectedClient.id] ?? 0}
              onClientUpdated={onClientUpdated}
            />
          ) : (
            <section className="portal-panel flex min-h-[420px] flex-col items-center justify-center rounded-[1.6rem] p-8 text-center">
              <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-primary/12 text-primary">
                <Users className="h-6 w-6" />
              </div>
              <h3 className="portal-section-heading mt-4">
                {t('components.clientspanel.select_a_client')}
              </h3>
              <p className="portal-body mt-2 max-w-md text-muted-foreground">
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
      <p className="portal-card-heading">
        {hasClients
          ? t('components.clientspanel.no_clients_match_the_current_filters')
          : t('components.clientspanel.no_client_relationships_yet')}
      </p>
      <p className="portal-body mt-2 text-muted-foreground">
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
          className="mt-4 inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 portal-action text-primary-foreground disabled:cursor-not-allowed disabled:opacity-50"
        >
          <UserPlus className="h-4 w-4" />
          {t('components.clientspanel.invite_first_client')}
        </button>
      )}
      {hasClients && (
        <div className="mt-4 inline-flex items-center gap-2 portal-action text-primary">
          {t('components.clientspanel.review_filters')}
          <ArrowRight className="h-4 w-4" />
        </div>
      )}
    </div>
  );
};
