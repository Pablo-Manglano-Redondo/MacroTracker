import React, { useMemo } from 'react';
import {
  Activity,
  AlertCircle,
  CreditCard,
  Download,
  FileText,
  LayoutDashboard,
  MessageSquare,
  TrendingUp,
  UserPlus,
  Users,
} from 'lucide-react';
import { useAuth } from '../lib/auth-context';
import {
  useAdherenceTrends,
  usePerClientAdherence,
  useRosterStats,
} from '../hooks/queries/useAnalytics';
import { useInvites } from '../hooks/queries/useInvites';
import { downloadCsv } from '../lib/csv';
import { formatPortalDate } from '../lib/date';
import { openInviteModal } from '../lib/portal-events';
import { Skeleton } from './ui/skeleton';
import { getBillingSummary } from '../view-models/professional';
import { usePortalI18n } from '../lib/portal-i18n';

export const DashboardPanel: React.FC = () => {
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();
  const billingSummary = useMemo(() => getBillingSummary(professional), [professional]);
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

  const pendingInvites = invites.filter((invite) => invite.status === 'pending').length;
  const latestInvite = invites[0]?.created_at ?? null;
  const hasRosterData = (roster?.totalClients ?? 0) > 0;

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
      <section className="portal-hero rounded-[1.8rem] p-6">
        <div className="flex flex-col gap-5 lg:flex-row lg:items-start lg:justify-between">
          <div className="space-y-3">
            <div className="flex items-center gap-2 text-primary">
              <LayoutDashboard className="h-5 w-5" />
              <p className="portal-kicker">{t('components.dashboardpanel.practice_overview')}</p>
            </div>
            <h2 className="portal-title text-3xl text-foreground">
              {t('components.dashboardpanel.what_is_actually_happening_in_your_practice_today')}
            </h2>
            <p className="max-w-3xl text-sm leading-relaxed text-muted-foreground">
              {t('components.dashboardpanel.this_panel_only_uses_real_relationships_invite_history_plans_and_synced_')}
            </p>
          </div>

          <div className="flex flex-wrap gap-3">
            <button
              onClick={() => openInviteModal()}
              disabled={!billingSummary.hasProfessionalAccess}
              className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground disabled:cursor-not-allowed disabled:opacity-50"
            >
              <UserPlus className="h-4 w-4" />
              {t('components.dashboardpanel.invite_client')}
            </button>
            <button
              onClick={exportAdherenceCsv}
              disabled={trends.length === 0}
              className="inline-flex items-center gap-2 rounded-xl border border-border bg-card px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-foreground disabled:cursor-not-allowed disabled:opacity-50"
            >
              <Download className="h-4 w-4" />
              {t('components.dashboardpanel.export_adherence')}
            </button>
          </div>
        </div>

        {!billingSummary.hasProfessionalAccess && (
          <div className="mt-5 rounded-2xl border border-amber-500/25 bg-amber-500/10 p-4">
            <div className="flex items-start gap-3">
              <CreditCard className="mt-0.5 h-5 w-5 text-amber-500 dark:text-amber-300" />
              <p className="text-sm leading-relaxed text-amber-900 dark:text-amber-100">
                {t('components.dashboardpanel.billing_is_currently_historical_records_may_remain_visible_but_new_invit', { billingsummary_prostatus: billingSummary.proStatus })}
              </p>
            </div>
          </div>
        )}
      </section>

      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          label={t('components.dashboardpanel.connected_clients')}
          icon={<Users className="h-4 w-4 text-primary" />}
          value={rosterLoading ? null : roster?.activeClients ?? 0}
          note={t('components.dashboardpanel.slots_in_the_current_plan', { roster: roster?.clientLimit ?? billingSummary.clientLimit })}
        />
        <MetricCard
          label={t('components.dashboardpanel.active_plans')}
          icon={<FileText className="h-4 w-4 text-primary" />}
          value={rosterLoading ? null : roster?.activePlans ?? 0}
          note={t('components.dashboardpanel.plans_created_in_total', { roster: roster?.totalPlans ?? 0 })}
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
          value={pendingInvites}
          note={
            latestInvite
              ? t('components.dashboardpanel.latest_invite', { locale_es: formatPortalDate(latestInvite, locale) })
              : t('components.dashboardpanel.no_invite_history_yet')
          }
        />
      </section>

      <section className="grid gap-6 xl:grid-cols-12">
        <div className="portal-panel rounded-[1.6rem] p-5 xl:col-span-7">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-bold uppercase tracking-[0.16em] text-foreground">
                {t('components.dashboardpanel.adherence_trend')}
              </h3>
              <p className="mt-1 text-sm text-muted-foreground">
                {t('components.dashboardpanel.daily_averages_calculated_from_client_shared_snapshots')}
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

        <div className="space-y-6 xl:col-span-5">
          <div className="portal-panel rounded-[1.6rem] p-5">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-sm font-bold uppercase tracking-[0.16em] text-foreground">
                  {t('components.dashboardpanel.next_actions')}
                </h3>
                <p className="mt-1 text-sm text-muted-foreground">
                  {t('components.dashboardpanel.based_on_the_real_workspace_state')}
                </p>
              </div>
              <AlertCircle className="h-5 w-5 text-primary" />
            </div>

            <div className="mt-4 space-y-3">
              {!billingSummary.hasProfessionalAccess && (
                <ActionHint
                  title={t('components.dashboardpanel.reactivate_billing')}
                  body={t('components.dashboardpanel.restore_an_active_or_trialing_status_before_sending_more_invites')}
                />
              )}
              {!hasRosterData && (
                <ActionHint
                  title={t('components.dashboardpanel.connect_the_first_client')}
                  body={t('components.dashboardpanel.the_mobile_app_remains_the_source_of_truth_for_accepting_invite_codes_an')}
                />
              )}
              {(roster?.totalPlans ?? 0) === 0 && (
                <ActionHint
                  title={t('components.dashboardpanel.publish_the_first_plan')}
                  body={t('components.dashboardpanel.the_client_workflow_supports_plans_but_none_has_been_created_yet_for_thi')}
                />
              )}
              {trends.length === 0 && (
                <ActionHint
                  title={t('components.dashboardpanel.wait_for_the_first_sync')}
                  body={t('components.dashboardpanel.adherence_and_progress_cards_will_remain_empty_until_shared_data_arrives')}
                />
              )}
              {billingSummary.hasProfessionalAccess &&
                hasRosterData &&
                (roster?.totalPlans ?? 0) > 0 &&
                trends.length > 0 && (
                  <ActionHint
                    title={t('components.dashboardpanel.review_detailed_diary_cases')}
                    body={t('components.dashboardpanel.use_the_roster_to_see_which_clients_granted_detailed_access_versus_aggre')}
                  />
                )}
            </div>
          </div>

          <div className="portal-panel rounded-[1.6rem] p-5">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-sm font-bold uppercase tracking-[0.16em] text-foreground">
                  {t('components.dashboardpanel.client_adherence')}
                </h3>
                <p className="mt-1 text-sm text-muted-foreground">
                  {t('components.dashboardpanel.latest_averages_for_connected_clients')}
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
                    className="portal-soft-panel flex items-center justify-between rounded-2xl px-4 py-3"
                  >
                    <div className="min-w-0">
                      <p className="truncate text-sm font-bold text-foreground">{client.name}</p>
                      <p className="text-xs text-muted-foreground">
                        {t('components.dashboardpanel.snapshots', { client_snapshotcount: client.snapshotCount })}
                      </p>
                    </div>
                    <span className="portal-metric text-lg font-bold text-primary">
                      {client.avgKcalAdherence}%
                    </span>
                  </div>
                ))}
              </div>
            )}
          </div>
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
  <div className="portal-panel rounded-[1.4rem] p-4">
    <div className="flex items-center justify-between">
      <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
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
        <p className="portal-metric mt-3 text-3xl font-extrabold text-foreground">{value}</p>
        <p className="mt-1 text-xs leading-relaxed text-muted-foreground">{note}</p>
      </>
    )}
  </div>
);

const EmptyPanel: React.FC<{ title: string; body: string }> = ({ title, body }) => (
  <div className="portal-soft-panel mt-4 rounded-2xl p-5">
    <p className="text-sm font-bold text-foreground">{title}</p>
    <p className="mt-2 text-sm leading-relaxed text-muted-foreground">{body}</p>
  </div>
);

const ActionHint: React.FC<{ title: string; body: string }> = ({ title, body }) => (
  <div className="portal-soft-panel rounded-2xl p-4">
    <p className="text-sm font-bold text-foreground">{title}</p>
    <p className="mt-1 text-sm leading-relaxed text-muted-foreground">{body}</p>
  </div>
);
