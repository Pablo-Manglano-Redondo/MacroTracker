import React, { useMemo, useState } from 'react';
import {
  Activity,
  AlertCircle,
  ChefHat,
  ChevronRight,
  ClipboardCheck,
  CreditCard,
  Download,
  FileText,
  MessageSquare,
  PlusCircle,
  RefreshCw,
  TrendingUp,
  UserPlus,
  Users,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { usePortalI18n } from '../lib/portal-i18n';
import {
  useAdherenceTrends,
  usePerClientAdherence,
  useRosterStats,
} from '../hooks/queries/useAnalytics';
import { useClients } from '../hooks/queries/useClients';
import { useInvites } from '../hooks/queries/useInvites';
import { useNotifications, useMarkNotificationRead } from '../hooks/queries/useNotifications';
import {
  useDismissPracticeAlert,
  useOpenPracticeAlerts,
  useRefreshPracticeAlerts,
  useResolvedPracticeAlertsToday,
} from '../hooks/queries/usePracticeAlerts';
import { openInviteModal } from '../lib/portal-events';
import { downloadCsv } from '../lib/csv';
import { formatPortalDate } from '../lib/date';
import { Skeleton } from './ui/skeleton';
import { getBillingSummary } from '../view-models/professional';
import { getClientDisplayName } from '../view-models/clients';
import {
  executePracticeAlertAction,
  getPracticeAlertBody,
  getPracticeAlertCtaLabel,
  getPracticeAlertReason,
  getPracticeAlertSeverityLabel,
  getPracticeAlertStrings,
  getPracticeAlertTitle,
  sortPracticeAlerts,
} from '../lib/practice-alerts';
import { trackPortalEvent } from '../lib/portal-analytics';
import type { PracticeAlert } from '../types/database.types';

const getTypeStyles = (type: string) => {
  switch (type) {
    case 'client_connected':
      return {
        bg: 'bg-emerald-500/10 border-emerald-500/20 text-emerald-600 dark:text-emerald-400',
        icon: UserPlus,
      };
    case 'snapshot_received':
      return {
        bg: 'bg-primary/10 border-primary/20 text-primary',
        icon: Activity,
      };
    case 'checkin_submitted':
      return {
        bg: 'bg-amber-500/10 border-amber-500/20 text-amber-600 dark:text-amber-400',
        icon: ClipboardCheck,
      };
    case 'message_received':
      return {
        bg: 'bg-indigo-500/10 border-indigo-500/20 text-indigo-600 dark:text-indigo-400',
        icon: MessageSquare,
      };
    default:
      return {
        bg: 'bg-white/5 border-white/10 text-muted-foreground',
        icon: Activity,
      };
  }
};

const severityTone: Record<string, string> = {
  critical: 'border-rose-500/30 bg-rose-500/10 text-rose-700 dark:text-rose-300',
  high: 'border-amber-500/30 bg-amber-500/10 text-amber-700 dark:text-amber-300',
  medium: 'border-sky-500/30 bg-sky-500/10 text-sky-700 dark:text-sky-300',
  low: 'border-emerald-500/30 bg-emerald-500/10 text-emerald-700 dark:text-emerald-300',
};

export const DashboardPanel: React.FC = () => {
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();
  const strings = getPracticeAlertStrings(locale);
  const { data: clients = [] } = useClients(professional?.id);
  const { data: openAlerts = [], isLoading: alertsLoading } = useOpenPracticeAlerts(professional?.id);
  const { data: resolvedToday = 0 } = useResolvedPracticeAlertsToday(professional?.id);
  const refreshAlerts = useRefreshPracticeAlerts(professional?.id);
  const dismissAlert = useDismissPracticeAlert(professional?.id);

  const connectedClients = useMemo(
    () => clients.filter((client) => client.status === 'connected'),
    [clients],
  );
  const clientsByRelationshipId = useMemo(
    () => new Map(clients.map((client) => [client.id, client])),
    [clients],
  );

  const billingSummary = useMemo(
    () => getBillingSummary(professional, connectedClients.length),
    [connectedClients.length, professional],
  );

  const { data: roster, isLoading: rosterLoading } = useRosterStats(professional?.id);
  const { data: trends = [], isLoading: trendsLoading } = useAdherenceTrends(professional?.id);
  const { data: clientAdherence = [], isLoading: clientsLoading } = usePerClientAdherence(
    professional?.id,
  );
  const { data: invites = [] } = useInvites(professional?.id);
  const { data: notifications = [], isLoading: notificationsLoading } = useNotifications(professional?.id);
  const { markRead } = useMarkNotificationRead(professional?.id);

  const [selectedMacro, setSelectedMacro] = useState<'kcal' | 'protein' | 'carbs' | 'fat'>('kcal');

  const sortedAlerts = useMemo(() => sortPracticeAlerts(openAlerts), [openAlerts]);
  const pendingCheckinsCount = useMemo(
    () =>
      openAlerts
        .filter((alert) => alert.alert_type === 'pending_checkin_review')
        .reduce((sum, alert) => sum + Number(alert.evidence?.pending_checkin_count ?? 1), 0),
    [openAlerts],
  );
  const validPendingInvites = invites.filter(
    (invite) => invite.status === 'pending' && new Date(invite.expires_at) >= new Date(),
  );
  const latestInvite = invites[0]?.created_at ?? null;
  const clientsNeedingPlan = useMemo(
    () => openAlerts.filter((alert) => alert.alert_type === 'client_without_plan').length,
    [openAlerts],
  );
  const summaryCounts = useMemo(
    () => ({
      critical: openAlerts.filter((alert) => alert.severity === 'critical').length,
      high: openAlerts.filter((alert) => alert.severity === 'high').length,
    }),
    [openAlerts],
  );

  if (!professional) {
    return (
      <section className="portal-panel rounded-[1.6rem] p-6">
        <h2 className="portal-section-heading">
          {t('components.dashboardpanel.operational_overview')}
        </h2>
        <p className="portal-body mt-2 max-w-2xl text-muted-foreground">
          {t('components.dashboardpanel.create_the_professional_profile_first_this_panel_depends_on_the_professi')}
        </p>
      </section>
    );
  }

  const avgAdherence =
    trends.length > 0
      ? Math.round(trends.reduce((sum, day) => sum + day.kcalAdherence, 0) / trends.length)
      : null;

  const translateNotification = (title: string, body?: string | null) => {
    let translatedTitle = title;
    let translatedBody = body || undefined;

    if (title === 'New client connected') {
      translatedTitle = t('components.notificationbell.type_client_connected_title');
    } else if (title === 'Daily snapshot received') {
      translatedTitle = t('components.notificationbell.type_snapshot_received_title');
    } else if (title === 'Check-in requested') {
      translatedTitle = t('components.notificationbell.type_checkin_requested_title');
    } else if (title === 'Check-in submitted') {
      translatedTitle = t('components.notificationbell.type_checkin_submitted_title');
    } else if (title === 'New message received') {
      translatedTitle = t('components.notificationbell.type_message_received_title');
    } else if (title === 'Plan activated') {
      translatedTitle = t('components.notificationbell.type_plan_activated_title');
    }

    if (body === 'A client has accepted your invitation and connected to your practice.') {
      translatedBody = t('components.notificationbell.type_client_connected_body');
    } else if (body === 'A client has shared their daily nutrition snapshot.') {
      translatedBody = t('components.notificationbell.type_snapshot_received_body');
    } else if (body === 'A check-in request was sent to the client.') {
      translatedBody = t('components.notificationbell.type_checkin_requested_body');
    } else if (body === 'A client has submitted their weekly check-in.') {
      translatedBody = t('components.notificationbell.type_checkin_submitted_body');
    } else if (body === 'A client has sent you a message.') {
      translatedBody = t('components.notificationbell.type_message_received_body');
    } else if (body === 'The nutrition plan has been activated.') {
      translatedBody = t('components.notificationbell.type_plan_activated_body');
    }

    return { title: translatedTitle, body: translatedBody };
  };

  const handleNotificationClick = async (n: any) => {
    if (!n.read) {
      await markRead(n.id);
    }

    const clientId = n.metadata?.client_id || n.metadata?.professional_client_id;
    if (clientId) {
      let tab = 'summary';
      if (n.type === 'snapshot_received' || n.title === 'Daily snapshot received') {
        tab = 'diary';
      } else if (n.type === 'checkin_submitted' || n.title === 'Check-in submitted' || n.title === 'Check-in requested') {
        tab = 'checkins';
      } else if (n.type === 'message_received' || n.title === 'New message received') {
        tab = 'chat';
      } else if (n.type === 'plan_activated' || n.title === 'Plan activated') {
        tab = 'plans';
      }

      (window as any).__pendingClientTab = { clientId, tab };
      window.location.hash = 'clients-panel';
      window.dispatchEvent(new CustomEvent('select-client', { detail: clientId }));
      window.dispatchEvent(new CustomEvent('select-client-tab', { detail: { clientId, tab } }));
    }
  };

  const exportAdherenceCsv = () => {
    const rows = trends.map((day) => [
      day.date,
      day.kcalAdherence,
      day.proteinAdherence,
      day.carbsAdherence,
      day.fatAdherence,
    ]);

    downloadCsv(
      'professional-dashboard-adherence.csv',
      ['date', 'kcal_adherence', 'protein_adherence', 'carbs_adherence', 'fat_adherence'],
      rows,
    );
  };

  const handleRefreshAlerts = async () => {
    trackPortalEvent('alerts_refresh_requested', { professionalId: professional.id });
    const nextAlerts = await refreshAlerts.mutateAsync();
    trackPortalEvent('alerts_generated', {
      professionalId: professional.id,
      openCount: nextAlerts.length,
    });
  };

  const handleAlertCta = (alert: PracticeAlert) => {
    trackPortalEvent('alert_opened', {
      alertType: alert.alert_type,
      severity: alert.severity,
      professionalClientId: alert.professional_client_id,
    });
    trackPortalEvent('alert_cta_clicked', {
      alertType: alert.alert_type,
      severity: alert.severity,
      professionalClientId: alert.professional_client_id,
    });
    executePracticeAlertAction(alert);
  };

  const handleDismissAlert = async (alert: PracticeAlert) => {
    await dismissAlert.mutateAsync(alert.id);
    trackPortalEvent('alert_dismissed', {
      alertType: alert.alert_type,
      severity: alert.severity,
      professionalClientId: alert.professional_client_id,
    });
  };

  return (
    <div className="space-y-5 animate-fade-in-up">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <h2 className="portal-card-heading uppercase tracking-[0.14em]">
          {t('components.dashboardpanel.daily_practice_triage')}
        </h2>
        <div className="flex items-center gap-2">
          <button
            onClick={handleRefreshAlerts}
            disabled={refreshAlerts.isPending}
            className="inline-flex h-9 items-center gap-2 rounded-xl border border-border bg-card px-3.5 portal-action text-muted-foreground transition-colors hover:bg-accent hover:text-foreground disabled:cursor-not-allowed disabled:opacity-40 shadow-sm"
          >
            <RefreshCw className={`h-3.5 w-3.5 ${refreshAlerts.isPending ? 'animate-spin' : ''}`} />
            <span>{strings.refresh}</span>
          </button>
          <button
            onClick={exportAdherenceCsv}
            disabled={trends.length === 0}
            className="inline-flex h-9 items-center gap-2 rounded-xl border border-border bg-card px-3.5 portal-action text-muted-foreground transition-colors hover:bg-accent hover:text-foreground disabled:cursor-not-allowed disabled:opacity-40 shadow-sm"
          >
            <Download className="h-3.5 w-3.5" />
            <span className="hidden sm:inline">{t('components.dashboardpanel.export_adherence')}</span>
          </button>
        </div>
      </div>

      {!billingSummary.canOperatePractice && (
        <section className="flex items-center gap-3 rounded-2xl border border-amber-500/25 bg-amber-500/8 px-5 py-3.5">
          <CreditCard className="h-4 w-4 shrink-0 text-amber-500 dark:text-amber-300" />
          <p className="portal-body text-amber-900 dark:text-amber-100">
            {t('components.dashboardpanel.billing_status_read_only_body', {
              status: billingSummary.proStatus,
            })}
          </p>
        </section>
      )}

      <section
        id="tour-dashboard-metrics"
        className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5 animate-scale-in"
      >
        <MetricCard
          label={t('components.dashboardpanel.connected_clients')}
          icon={<Users className="h-4 w-4 text-primary" />}
          value={rosterLoading ? null : roster?.activeClients ?? 0}
          note={t('components.dashboardpanel.slots_still_available', {
            count: billingSummary.remainingClientSlots,
          })}
        />
        <MetricCard
          label={t('components.dashboardpanel.active_plans')}
          icon={<FileText className="h-4 w-4 text-primary" />}
          value={rosterLoading ? null : roster?.activePlans ?? 0}
          note={t('components.dashboardpanel.connected_clients_need_plan', {
            count: Math.max(0, clientsNeedingPlan),
          })}
        />
        <MetricCard
          label={t('components.dashboardpanel.pending_checkins')}
          icon={<ClipboardCheck className="h-4 w-4 text-primary" />}
          value={alertsLoading ? null : pendingCheckinsCount}
          note={
            pendingCheckinsCount > 0
              ? t('components.dashboardpanel.checkins_need_review', { count: pendingCheckinsCount })
              : t('components.dashboardpanel.no_pending_checkins')
          }
        />
        <MetricCard
          label={t('components.dashboardpanel.average_adherence')}
          icon={<TrendingUp className="h-4 w-4 text-primary" />}
          value={trendsLoading ? null : avgAdherence !== null ? `${avgAdherence}%` : '--'}
          note={
            avgAdherence === null
              ? t('components.dashboardpanel.no_shared_snapshots_received_yet')
              : t('components.dashboardpanel.based_on_shared_daily_snapshots')
          }
        />
        <MetricCard
          label={t('components.dashboardpanel.pending_invites')}
          icon={<MessageSquare className="h-4 w-4 text-primary" />}
          value={validPendingInvites.length}
          note={
            latestInvite
              ? t('components.dashboardpanel.latest_invite_short', {
                  date: formatPortalDate(latestInvite, locale),
                })
              : t('components.dashboardpanel.no_invite_history_yet')
          }
        />
      </section>

      <section id="tour-dashboard-feed" className="grid gap-4 xl:grid-cols-2">
        <div className="flex flex-col gap-4">
          <div className="portal-panel flex-1 rounded-2xl p-6 shadow-sm">
            <SectionHeader
              title={strings.title}
              subtitle={t('components.dashboardpanel.prioritized_from_real_signals')}
              icon={<AlertCircle className="h-4 w-4 text-primary" />}
            />

            <div className="mt-4 grid gap-3 sm:grid-cols-3">
              <SummaryCard
                label={strings.summaryCritical}
                value={summaryCounts.critical}
                tone="critical"
              />
              <SummaryCard
                label={strings.summaryHigh}
                value={summaryCounts.high}
                tone="high"
              />
              <SummaryCard
                label={strings.summaryResolvedToday}
                value={resolvedToday}
                tone="low"
              />
            </div>

            <div className="mt-4 space-y-3">
              {alertsLoading ? (
                <div className="space-y-2">
                  {[1, 2, 3].map((index) => (
                    <Skeleton key={index} className="h-24 w-full bg-black/5 dark:bg-white/5" />
                  ))}
                </div>
              ) : sortedAlerts.length === 0 ? (
                <EmptyPanel
                  title={strings.clear}
                  body={strings.clearBody}
                />
              ) : (
                sortedAlerts.map((alert) => {
                  const client = alert.professional_client_id
                    ? clientsByRelationshipId.get(alert.professional_client_id)
                    : null;
                  const clientName = client ? getClientDisplayName(client) : null;

                  return (
                    <AlertCard
                      key={alert.id}
                      alert={alert}
                      locale={locale}
                      clientName={clientName}
                      onOpen={() => handleAlertCta(alert)}
                      onDismiss={() => handleDismissAlert(alert)}
                    />
                  );
                })
              )}
            </div>
          </div>

          <div className="portal-panel rounded-2xl p-6 shadow-sm">
            <SectionHeader
              title={t('components.dashboardpanel.quick_actions')}
            />
            <div className="mt-4 grid grid-cols-3 gap-2.5">
              {[
                {
                  icon: <UserPlus className="h-4 w-4" />,
                  label: t('components.dashboardpanel.invite_client'),
                  onClick: openInviteModal,
                  disabled: !billingSummary.canOperatePractice,
                },
                {
                  icon: <PlusCircle className="h-4 w-4" />,
                  label: t('components.dashboardpanel.create_template_desc'),
                  onClick: () => { window.location.hash = 'templates-panel'; },
                  disabled: !billingSummary.canOperatePractice,
                },
                {
                  icon: <ChefHat className="h-4 w-4" />,
                  label: t('components.dashboardpanel.create_recipe_desc'),
                  onClick: () => { window.location.hash = 'recipes-panel'; },
                  disabled: !billingSummary.canOperatePractice,
                },
              ].map(({ icon, label, onClick, disabled }) => (
                <button
                  key={label}
                  onClick={onClick}
                  disabled={disabled}
                  className="flex flex-col items-center gap-2.5 rounded-xl border border-border bg-background/50 p-3.5 text-center transition-all hover:bg-accent hover:border-border/80 group disabled:cursor-not-allowed disabled:opacity-50"
                >
                  <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary/10 text-primary transition-transform group-hover:scale-105">
                    {icon}
                  </div>
                  <span className="portal-action text-foreground leading-tight">
                    {label}
                  </span>
                </button>
              ))}
            </div>
          </div>

          <div className="portal-panel rounded-2xl p-6 shadow-sm">
            <SectionHeader
              title={t('components.dashboardpanel.client_adherence')}
              subtitle={t('components.dashboardpanel.client_adherence_quick_prioritization')}
              icon={<Users className="h-4 w-4 text-primary" />}
            />
            {clientsLoading ? (
              <div className="mt-4 space-y-2">
                {[1, 2, 3].map((i) => (
                  <Skeleton key={i} className="h-11 w-full bg-black/5 dark:bg-white/5" />
                ))}
              </div>
            ) : clientAdherence.length === 0 ? (
              <EmptyPanel
                title={t('components.dashboardpanel.no_rows_yet')}
                body={t('components.dashboardpanel.once_snapshots_arrive_this_panel_will_rank_connected_clients_by_average_')}
              />
            ) : (
              <div className="mt-4 space-y-1.5">
                {clientAdherence.slice(0, 6).map((client) => (
                  <button
                    key={client.clientId}
                    onClick={() => {
                      (window as any).__pendingClientTab = { clientId: client.clientId, tab: 'summary' };
                      window.location.hash = 'clients-panel';
                      window.dispatchEvent(new CustomEvent('select-client', { detail: client.clientId }));
                    }}
                    className="w-full flex items-center justify-between rounded-xl px-4 py-3 border border-transparent bg-accent/20 hover:bg-accent/40 hover:border-border transition-all active:scale-[0.99] cursor-pointer"
                  >
                    <div className="min-w-0">
                      <p className="portal-card-heading truncate text-foreground">{client.name}</p>
                      <p className="portal-meta text-muted-foreground">
                        {t('components.dashboardpanel.snapshots', {
                          client_snapshotcount: client.snapshotCount,
                        })}
                      </p>
                    </div>
                    <span className="portal-metric ml-3 shrink-0 text-primary">
                      {client.avgKcalAdherence}%
                    </span>
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>

        <div className="flex flex-col gap-4">
          <div className="portal-panel rounded-2xl p-6 shadow-sm">
            <div className="flex items-start justify-between">
              <SectionHeader
                title={t('components.dashboardpanel.adherence_trend')}
                subtitle={t('components.dashboardpanel.shared_snapshot_trend_for_latest_roster')}
              />
              <Activity className="h-4 w-4 shrink-0 text-primary mt-0.5" />
            </div>

            <div className="mt-4 flex gap-1.5 flex-wrap">
              {(
                [
                  { id: 'kcal', label: t('common.kcal') },
                  { id: 'protein', label: t('common.protein') },
                  { id: 'carbs', label: t('common.carbs') },
                  { id: 'fat', label: t('common.fat') },
                ] as const
              ).map((macro) => (
                <button
                  key={macro.id}
                  onClick={() => setSelectedMacro(macro.id)}
                  className={`rounded-lg px-3.5 py-1.5 portal-action transition-all border cursor-pointer ${
                    selectedMacro === macro.id
                      ? 'bg-primary text-primary-foreground border-transparent shadow-sm'
                      : 'border-border bg-card text-muted-foreground hover:text-foreground hover:bg-accent'
                  }`}
                >
                  {macro.label}
                </button>
              ))}
            </div>

            {trendsLoading ? (
              <div className="mt-5 space-y-2">
                <Skeleton className="h-3 w-32 bg-black/5 dark:bg-white/5" />
                <Skeleton className="h-44 w-full bg-black/5 dark:bg-white/5" />
              </div>
            ) : trends.length === 0 ? (
              <EmptyPanel
                title={t('components.dashboardpanel.no_trend_yet')}
                body={t('components.dashboardpanel.the_chart_will_populate_after_connected_clients_sync_aggregate_snapshots')}
              />
            ) : (
              <div className="mt-5 portal-soft-panel flex h-52 items-end gap-1.5 rounded-xl p-3">
                {trends.slice(-14).map((day) => {
                  const adherenceValue = {
                    kcal: day.kcalAdherence,
                    protein: day.proteinAdherence,
                    carbs: day.carbsAdherence,
                    fat: day.fatAdherence,
                  }[selectedMacro];

                  return (
                    <div key={day.date} className="flex flex-1 flex-col items-center gap-1.5">
                      <div className="flex h-36 w-full items-end">
                        <div
                          className={`w-full rounded-t-md transition-all duration-300 ${
                            adherenceValue >= 85
                              ? 'bg-emerald-500'
                              : adherenceValue >= 70
                                ? 'bg-amber-500'
                                : 'bg-rose-500'
                          }`}
                          style={{ height: `${Math.max(adherenceValue, 6)}%` }}
                          title={`${day.date}: ${adherenceValue}%`}
                        />
                      </div>
                      <span className="portal-label text-muted-foreground">
                        {day.date.slice(5)}
                      </span>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

          <div className="portal-panel flex-1 rounded-2xl p-6 shadow-sm">
            <div className="flex items-start justify-between border-b border-border/60 pb-4 mb-4">
              <SectionHeader
                title={t('components.dashboardpanel.recent_activity')}
                subtitle={t('components.dashboardpanel.latest_events_roster')}
              />
              <ClipboardCheck className="h-4 w-4 shrink-0 text-primary mt-0.5" />
            </div>

            {notificationsLoading ? (
              <div className="space-y-2.5">
                {[1, 2, 3].map((idx) => (
                  <Skeleton key={idx} className="h-14 w-full bg-black/5 dark:bg-white/5" />
                ))}
              </div>
            ) : notifications.length === 0 ? (
              <EmptyPanel
                title={t('components.dashboardpanel.no_rows_yet')}
                body={t('components.dashboardpanel.no_connected_clients_yet_body')}
              />
            ) : (
              <div className="space-y-2 max-h-[320px] overflow-y-auto pr-1 custom-scrollbar">
                {notifications.slice(0, 8).map((n) => {
                  const styles = getTypeStyles(n.type);
                  const Icon = styles.icon;
                  const { title: displayTitle, body: displayBody } = translateNotification(n.title, n.body);

                  return (
                    <button
                      key={n.id}
                      onClick={() => handleNotificationClick(n)}
                      className={`w-full flex items-center gap-3 p-3.5 text-left transition-all border rounded-xl cursor-pointer ${
                        !n.read
                          ? 'bg-primary/[0.03] border-primary/30 hover:bg-primary/[0.06] active:scale-[0.99]'
                          : 'border-border/50 bg-accent/10 hover:bg-accent/20 active:scale-[0.99]'
                      }`}
                    >
                      <div className={`shrink-0 w-8 h-8 rounded-lg flex items-center justify-center border ${styles.bg}`}>
                        <Icon className="w-3.5 h-3.5" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between gap-2">
                          <p className={`portal-card-heading truncate ${!n.read ? 'text-foreground' : 'text-muted-foreground'}`}>
                            {displayTitle}
                          </p>
                          {!n.read && (
                            <span className="shrink-0 w-2 h-2 rounded-full bg-primary shadow-[0_0_6px_rgba(16,185,129,0.5)]" />
                          )}
                        </div>
                        {displayBody && (
                          <p className="portal-meta mt-0.5 line-clamp-1 text-muted-foreground/80">
                            {displayBody}
                          </p>
                        )}
                        <p className="portal-label mt-1 text-muted-foreground/50">
                          {formatPortalDate(n.created_at, locale, {
                            month: 'short',
                            day: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit',
                          })}
                        </p>
                      </div>
                      <ChevronRight className="w-4 h-4 text-muted-foreground/50 shrink-0" />
                    </button>
                  );
                })}
              </div>
            )}
          </div>
        </div>
      </section>
    </div>
  );
};

const SectionHeader: React.FC<{
  title: string;
  subtitle?: string;
  icon?: React.ReactNode;
}> = ({ title, subtitle, icon }) => (
  <div className="flex items-start justify-between gap-3">
    <div className="min-w-0">
      <h3 className="portal-card-heading uppercase tracking-[0.16em]">{title}</h3>
      {subtitle && (
        <p className="portal-meta mt-0.5 text-muted-foreground">{subtitle}</p>
      )}
    </div>
    {icon && <div className="shrink-0 mt-0.5">{icon}</div>}
  </div>
);

const MetricCard: React.FC<{
  label: string;
  icon: React.ReactNode;
  value: number | string | null;
  note: string;
}> = ({ label, icon, value, note }) => (
  <div className="portal-panel rounded-2xl p-4 shadow-sm flex flex-col justify-between min-h-[108px]">
    <div className="flex items-center justify-between">
      <p className="portal-label leading-tight">
        {label}
      </p>
      {icon}
    </div>
    {value === null ? (
      <div className="mt-2 space-y-1.5">
        <Skeleton className="h-7 w-14 bg-black/5 dark:bg-white/5" />
        <Skeleton className="h-3 w-24 bg-black/5 dark:bg-white/5" />
      </div>
    ) : (
      <div className="mt-2">
        <p className="portal-metric text-foreground leading-none">{value}</p>
        <p className="portal-meta mt-1.5 leading-tight">{note}</p>
      </div>
    )}
  </div>
);

const SummaryCard: React.FC<{
  label: string;
  value: number;
  tone: 'critical' | 'high' | 'low';
}> = ({ label, value, tone }) => (
  <div className={`rounded-2xl border p-4 ${severityTone[tone]}`}>
    <p className="portal-label">{label}</p>
    <p className="portal-metric mt-2 text-current">{value}</p>
  </div>
);

const EmptyPanel: React.FC<{ title: string; body: string }> = ({ title, body }) => (
  <div className="portal-soft-panel mt-4 rounded-xl p-4 border border-border/50">
    <p className="portal-card-heading">{title}</p>
    <p className="portal-meta mt-1 text-muted-foreground leading-relaxed">{body}</p>
  </div>
);

const AlertCard: React.FC<{
  alert: PracticeAlert;
  locale?: string;
  clientName: string | null;
  onOpen: () => void;
  onDismiss: () => void;
}> = ({ alert, locale, clientName, onOpen, onDismiss }) => {
  const title = getPracticeAlertTitle(alert, locale);
  const body = getPracticeAlertBody(alert, locale);
  const ctaLabel = getPracticeAlertCtaLabel(alert, locale);
  const severityLabel = getPracticeAlertSeverityLabel(alert.severity, locale);
  const reason = getPracticeAlertReason(alert, locale);

  return (
    <div className="rounded-2xl border border-border bg-card/70 p-4 shadow-sm">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <div className="flex flex-wrap items-center gap-2">
            <span className={`inline-flex items-center rounded-full border px-2.5 py-1 portal-pill ${severityTone[alert.severity]}`}>
              {severityLabel}
            </span>
            {clientName && (
              <span className="portal-pill rounded-full border border-border bg-background px-2.5 py-1 text-muted-foreground">
                {clientName}
              </span>
            )}
            <span className="portal-pill rounded-full border border-border bg-background px-2.5 py-1 text-muted-foreground">
              {reason}
            </span>
          </div>
          <p className="portal-card-heading mt-3 text-foreground">{title}</p>
          <p className="portal-meta mt-1 leading-relaxed text-muted-foreground">{body}</p>
        </div>
        <button
          onClick={onDismiss}
          className="rounded-lg border border-border bg-background px-2.5 py-1.5 portal-action text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
        >
          {getPracticeAlertStrings(locale).dismiss}
        </button>
      </div>

      <div className="mt-4 flex items-center justify-between gap-3">
          <p className="portal-label text-muted-foreground">
          {formatPortalDate(alert.detected_at, locale ?? 'en', {
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
          })}
        </p>
        <button
          onClick={onOpen}
          className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 portal-action text-primary-foreground transition-opacity hover:opacity-95"
        >
          <span>{ctaLabel}</span>
          <ChevronRight className="h-4 w-4" />
        </button>
      </div>
    </div>
  );
};
