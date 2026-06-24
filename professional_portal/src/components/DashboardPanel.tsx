import React, { useMemo } from 'react';
import {
  Activity,
  AlertCircle,
  CreditCard,
  Download,
  FileText,
  MessageSquare,
  TrendingUp,
  Users,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import { usePortalI18n } from '../lib/portal-i18n';
import {
  useAdherenceTrends,
  usePerClientAdherence,
  useRosterStats,
} from '../hooks/queries/useAnalytics';
import { useClients, useUnreadCounts } from '../hooks/queries/useClients';
import { useInvites } from '../hooks/queries/useInvites';
import { downloadCsv } from '../lib/csv';
import { formatPortalDate } from '../lib/date';
import { Skeleton } from './ui/skeleton';
import { getLatestSnapshot } from '../view-models/clients';
import { getBillingSummary } from '../view-models/professional';

export const DashboardPanel: React.FC = () => {
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();
  const { data: clients = [] } = useClients(professional?.id);
  const { data: unreadCounts = {} } = useUnreadCounts(professional?.id);
  const connectedClients = useMemo(
    () => clients.filter((client) => client.status === 'connected'),
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

  if (!professional) {
    return (
      <section className="portal-panel rounded-[1.6rem] p-6">
        <h2 className="portal-title text-2xl text-foreground">
          {t('components.dashboardpanel.operational_overview')}
        </h2>
        <p className="mt-2 max-w-2xl text-sm leading-relaxed text-muted-foreground">
          {t('components.dashboardpanel.create_the_professional_profile_first_this_panel_depends_on_the_professi')}
        </p>
      </section>
    );
  }

  const avgAdherence =
    trends.length > 0
      ? Math.round(trends.reduce((sum, day) => sum + day.kcalAdherence, 0) / trends.length)
      : null;

  const validPendingInvites = invites.filter(
    (invite) => invite.status === 'pending' && new Date(invite.expires_at) >= new Date(),
  );
  const latestInvite = invites[0]?.created_at ?? null;
  const clientsWithoutSnapshots = connectedClients.filter((client) => !getLatestSnapshot(client));
  const clientsNeedingPlan = connectedClients.length - (roster?.activePlans ?? 0);
  const lowAdherenceClients = clientAdherence.filter((client) => client.avgKcalAdherence < 75);
  const unreadThreads = Object.values(unreadCounts).filter((count) => count > 0).length;

  const actionFeed = [
    !billingSummary.canOperatePractice
      ? {
          title: t('components.dashboardpanel.practice_not_operational_title'),
          body: t('components.dashboardpanel.practice_not_operational_body'),
        }
      : null,
    connectedClients.length === 0
      ? {
          title: t('components.dashboardpanel.no_connected_clients_yet_title'),
          body: t('components.dashboardpanel.no_connected_clients_yet_body'),
        }
      : null,
    clientsNeedingPlan > 0
      ? {
          title:
            clientsNeedingPlan === 1
              ? t('components.dashboardpanel.clients_without_active_plan_title_one', {
                  count: clientsNeedingPlan,
                })
              : t('components.dashboardpanel.clients_without_active_plan_title', {
                  count: clientsNeedingPlan,
                }),
          body: t('components.dashboardpanel.clients_without_active_plan_body'),
        }
      : null,
    clientsWithoutSnapshots.length > 0
      ? {
          title:
            clientsWithoutSnapshots.length === 1
              ? t('components.dashboardpanel.clients_without_snapshots_title_one', {
                  count: clientsWithoutSnapshots.length,
                })
              : t('components.dashboardpanel.clients_without_snapshots_title', {
                  count: clientsWithoutSnapshots.length,
                }),
          body: t('components.dashboardpanel.clients_without_snapshots_body'),
        }
      : null,
    lowAdherenceClients.length > 0
      ? {
          title:
            lowAdherenceClients.length === 1
              ? t('components.dashboardpanel.clients_with_low_adherence_title_one', {
                  count: lowAdherenceClients.length,
                })
              : t('components.dashboardpanel.clients_with_low_adherence_title', {
                  count: lowAdherenceClients.length,
                }),
          body: t('components.dashboardpanel.clients_with_low_adherence_body'),
        }
      : null,
    unreadThreads > 0
      ? {
          title:
            unreadThreads === 1
              ? t('components.dashboardpanel.conversations_waiting_title_one', {
                  count: unreadThreads,
                })
              : t('components.dashboardpanel.conversations_waiting_title', {
                  count: unreadThreads,
                }),
          body: t('components.dashboardpanel.conversations_waiting_body'),
        }
      : null,
  ].filter(Boolean) as Array<{ title: string; body: string }>;

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

  return (
    <div className="space-y-6 animate-fade-in-up">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <h2 className="text-2xl font-black text-foreground uppercase tracking-[0.12em]">
          {t('components.dashboardpanel.daily_practice_triage')}
        </h2>
        <div className="flex items-center gap-3">
          <button
            onClick={exportAdherenceCsv}
            disabled={trends.length === 0}
            className="inline-flex h-11 items-center gap-2 rounded-xl border border-border bg-card px-4 text-xs font-extrabold uppercase tracking-[0.16em] text-foreground transition-colors hover:bg-accent disabled:cursor-not-allowed disabled:opacity-50 shadow-sm"
          >
            <Download className="h-4 w-4" />
            <span>{t('components.dashboardpanel.export_adherence')}</span>
          </button>
        </div>
      </div>

      {!billingSummary.canOperatePractice && (
        <section className="rounded-2xl border border-amber-500/25 bg-amber-500/10 p-4">
          <div className="flex items-start gap-3">
            <CreditCard className="mt-0.5 h-5 w-5 text-amber-500 dark:text-amber-300" />
            <p className="text-sm leading-relaxed text-amber-900 dark:text-amber-100">
              {t('components.dashboardpanel.billing_status_read_only_body', {
                status: billingSummary.proStatus,
              })}
            </p>
          </div>
        </section>
      )}

      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
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
          label={t('components.dashboardpanel.average_adherence')}
          icon={<TrendingUp className="h-4 w-4 text-primary" />}
          value={trendsLoading ? null : avgAdherence ?? '--'}
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

      <section className="grid gap-6 xl:grid-cols-12">
        <div className="space-y-6 xl:col-span-5">
          <div className="portal-panel rounded-[1.6rem] p-8">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-xl font-black uppercase tracking-[0.2em] text-foreground">
                  {t('components.dashboardpanel.requires_action_today')}
                </h3>
                <p className="mt-1.5 text-base font-semibold text-muted-foreground">
                  {t('components.dashboardpanel.prioritized_from_real_signals')}
                </p>
              </div>
              <AlertCircle className="h-5 w-5 text-primary" />
            </div>

            <div className="mt-5 space-y-3.5">
              {actionFeed.length === 0 ? (
                <ActionHint
                  title={t('components.dashboardpanel.practice_looks_clear')}
                  body={t('components.dashboardpanel.practice_looks_clear_body')}
                />
              ) : (
                actionFeed.map((item) => (
                  <ActionHint key={item.title} title={item.title} body={item.body} />
                ))
              )}
            </div>
          </div>

          <div className="portal-panel rounded-[1.6rem] p-8">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-xl font-black uppercase tracking-[0.2em] text-foreground">
                  {t('components.dashboardpanel.client_adherence')}
                </h3>
                <p className="mt-1.5 text-base font-semibold text-muted-foreground">
                  {t('components.dashboardpanel.client_adherence_quick_prioritization')}
                </p>
              </div>
              <Users className="h-5 w-5 text-primary" />
            </div>

            {clientsLoading ? (
              <div className="mt-4 space-y-2">
                {[1, 2, 3].map((index) => (
                  <Skeleton key={index} className="h-12 w-full bg-black/5 dark:bg-white/5" />
                ))}
              </div>
            ) : clientAdherence.length === 0 ? (
              <EmptyPanel
                title={t('components.dashboardpanel.no_rows_yet')}
                body={t('components.dashboardpanel.once_snapshots_arrive_this_panel_will_rank_connected_clients_by_average_')}
              />
            ) : (
              <div className="mt-4 space-y-2">
                {clientAdherence.slice(0, 6).map((client) => (
                  <div
                    key={client.clientId}
                    className="portal-soft-panel flex items-center justify-between rounded-2xl px-5 py-4"
                  >
                    <div className="min-w-0">
                      <p className="truncate text-base font-extrabold text-foreground">{client.name}</p>
                      <p className="text-sm font-semibold text-muted-foreground">
                        {t('components.dashboardpanel.snapshots', {
                          client_snapshotcount: client.snapshotCount,
                        })}
                      </p>
                    </div>
                    <span className="portal-metric text-xl font-black text-primary">
                      {client.avgKcalAdherence}%
                    </span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        <div className="portal-panel rounded-[1.6rem] p-8 xl:col-span-7">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-xl font-black uppercase tracking-[0.2em] text-foreground">
                {t('components.dashboardpanel.adherence_trend')}
              </h3>
              <p className="mt-1.5 text-base font-semibold text-muted-foreground">
                {t('components.dashboardpanel.shared_snapshot_trend_for_latest_roster')}
              </p>
            </div>
            <Activity className="h-5 w-5 text-primary" />
          </div>

          {trendsLoading ? (
            <div className="mt-6 space-y-2">
              <Skeleton className="h-4 w-40 bg-black/5 dark:bg-white/5" />
              <Skeleton className="h-48 w-full bg-black/5 dark:bg-white/5" />
            </div>
          ) : trends.length === 0 ? (
            <EmptyPanel
              title={t('components.dashboardpanel.no_trend_yet')}
              body={t('components.dashboardpanel.the_chart_will_populate_after_connected_clients_sync_aggregate_snapshots')}
            />
          ) : (
            <div className="mt-6">
              <div className="portal-soft-panel flex h-56 items-end gap-2 rounded-2xl p-4">
                {trends.slice(-14).map((day) => (
                  <div key={day.date} className="flex flex-1 flex-col items-center gap-2">
                    <div className="flex h-40 w-full items-end">
                      <div
                        className={`w-full rounded-t ${
                          day.kcalAdherence >= 85
                            ? 'bg-emerald-500'
                            : day.kcalAdherence >= 70
                              ? 'bg-amber-500'
                              : 'bg-rose-500'
                        }`}
                        style={{ height: `${Math.max(day.kcalAdherence, 8)}%` }}
                        title={`${day.date}: ${day.kcalAdherence}%`}
                      />
                    </div>
                    <span className="text-[10px] font-bold text-muted-foreground">
                      {day.date.slice(5)}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </section>
    </div>
  );
};

const MetricCard: React.FC<{
  label: string;
  icon: React.ReactNode;
  value: number | string | null;
  note: string;
}> = ({ label, icon, value, note }) => (
  <div className="portal-panel rounded-[1.4rem] p-6">
    <div className="flex items-center justify-between">
      <p className="text-xs font-black uppercase tracking-[0.2em] text-muted-foreground">
        {label}
      </p>
      {icon}
    </div>
    {value === null ? (
      <div className="mt-3 space-y-2">
        <Skeleton className="h-8 w-16 bg-black/5 dark:bg-white/5" />
        <Skeleton className="h-3 w-28 bg-black/5 dark:bg-white/5" />
      </div>
    ) : (
      <>
        <p className="portal-metric mt-3 text-3xl font-black text-foreground">{value}</p>
        <p className="mt-1 text-sm font-semibold text-muted-foreground">{note}</p>
      </>
    )}
  </div>
);

const EmptyPanel: React.FC<{ title: string; body: string }> = ({ title, body }) => (
  <div className="portal-soft-panel mt-4 rounded-2xl p-6">
    <p className="text-base font-extrabold text-foreground">{title}</p>
    <p className="mt-2 text-base font-semibold text-muted-foreground">{body}</p>
  </div>
);

const ActionHint: React.FC<{ title: string; body: string }> = ({ title, body }) => (
  <div className="portal-soft-panel rounded-2xl p-5">
    <p className="text-lg font-extrabold text-foreground">{title}</p>
    <p className="mt-1 text-base font-semibold text-muted-foreground">{body}</p>
  </div>
);
