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
import { openInviteModal } from '../lib/portal-events';
import { Skeleton } from './ui/skeleton';
import { getBillingSummary } from '../view-models/professional';
import { usePortalI18n } from '../lib/portal-i18n';

export const DashboardPanel: React.FC = () => {
  const { professional } = useAuth();
  const { tr, locale } = usePortalI18n();
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
          {tr('Resumen operativo', 'Operational overview')}
        </h2>
        <p className="mt-2 max-w-2xl text-sm leading-relaxed text-muted-foreground">
          {tr(
            'Primero crea el perfil profesional. Este panel depende del registro profesional y de las relaciones conectadas.',
            'Create the professional profile first. This panel depends on the professional record and connected relationships.',
          )}
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
              <p className="portal-kicker">{tr('Resumen de práctica', 'Practice overview')}</p>
            </div>
            <h2 className="portal-title text-3xl text-foreground">
              {tr(
                'Lo que sí está pasando hoy en tu consulta.',
                'What is actually happening in your practice today.',
              )}
            </h2>
            <p className="max-w-3xl text-sm leading-relaxed text-muted-foreground">
              {tr(
                'Este panel solo usa relaciones reales, historial de invitaciones, planes y snapshots sincronizados. Si aún no existe dato, el portal lo dice de forma explícita.',
                'This panel only uses real relationships, invite history, plans, and synced snapshots. If data does not exist yet, the portal says so explicitly.',
              )}
            </p>
          </div>

          <div className="flex flex-wrap gap-3">
            <button
              onClick={() => openInviteModal()}
              disabled={!billingSummary.hasProfessionalAccess}
              className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground disabled:cursor-not-allowed disabled:opacity-50"
            >
              <UserPlus className="h-4 w-4" />
              {tr('Invitar cliente', 'Invite client')}
            </button>
            <button
              onClick={exportAdherenceCsv}
              disabled={trends.length === 0}
              className="inline-flex items-center gap-2 rounded-xl border border-border bg-card px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-foreground disabled:cursor-not-allowed disabled:opacity-50"
            >
              <Download className="h-4 w-4" />
              {tr('Exportar adherencia', 'Export adherence')}
            </button>
          </div>
        </div>

        {!billingSummary.hasProfessionalAccess && (
          <div className="mt-5 rounded-2xl border border-amber-500/25 bg-amber-500/10 p-4">
            <div className="flex items-start gap-3">
              <CreditCard className="mt-0.5 h-5 w-5 text-amber-500 dark:text-amber-300" />
              <p className="text-sm leading-relaxed text-amber-900 dark:text-amber-100">
                {tr(
                  `La facturación está en estado "${billingSummary.proStatus}". Los registros históricos pueden seguir visibles, pero nuevas invitaciones y nuevos planes deben permanecer bloqueados hasta volver a estado activo o trialing.`,
                  `Billing is currently "${billingSummary.proStatus}". Historical records may remain visible, but new invites and new plans should stay blocked until access returns to active or trialing.`,
                )}
              </p>
            </div>
          </div>
        )}
      </section>

      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          label={tr('Clientes conectados', 'Connected clients')}
          icon={<Users className="h-4 w-4 text-primary" />}
          value={rosterLoading ? null : roster?.activeClients ?? 0}
          note={tr(
            `${roster?.clientLimit ?? billingSummary.clientLimit} plazas en el plan actual`,
            `${roster?.clientLimit ?? billingSummary.clientLimit} slots in the current plan`,
          )}
        />
        <MetricCard
          label={tr('Planes activos', 'Active plans')}
          icon={<FileText className="h-4 w-4 text-primary" />}
          value={rosterLoading ? null : roster?.activePlans ?? 0}
          note={tr(
            `${roster?.totalPlans ?? 0} planes creados en total`,
            `${roster?.totalPlans ?? 0} plans created in total`,
          )}
        />
        <MetricCard
          label={tr('Adherencia media', 'Average adherence')}
          icon={<TrendingUp className="h-4 w-4 text-primary" />}
          value={trendsLoading ? null : avgAdherence ?? '--'}
          note={
            avgAdherence === null
              ? tr('Todavía no hay snapshots compartidos', 'No shared snapshots received yet')
              : tr('Calculado desde snapshots diarios compartidos', 'Based on shared daily snapshots')
          }
        />
        <MetricCard
          label={tr('Invitaciones pendientes', 'Pending invites')}
          icon={<MessageSquare className="h-4 w-4 text-primary" />}
          value={pendingInvites}
          note={
            latestInvite
              ? tr(
                  `Última invitación ${new Date(latestInvite).toLocaleDateString(locale === 'es' ? 'es-ES' : 'en-US')}`,
                  `Latest invite ${new Date(latestInvite).toLocaleDateString(locale === 'es' ? 'es-ES' : 'en-US')}`,
                )
              : tr('Todavía no hay historial de invitaciones', 'No invite history yet')
          }
        />
      </section>

      <section className="grid gap-6 xl:grid-cols-12">
        <div className="portal-panel rounded-[1.6rem] p-5 xl:col-span-7">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-sm font-bold uppercase tracking-[0.16em] text-foreground">
                {tr('Tendencia de adherencia', 'Adherence trend')}
              </h3>
              <p className="mt-1 text-sm text-muted-foreground">
                {tr(
                  'Promedios diarios calculados desde `client_shared_snapshots`',
                  'Daily averages calculated from `client_shared_snapshots`',
                )}
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
              title={tr('Todavía no hay tendencia', 'No trend yet')}
              body={tr(
                'El gráfico se llenará cuando clientes conectados sincronicen snapshots agregados desde la app móvil.',
                'The chart will populate after connected clients sync aggregate snapshots from the mobile app.',
              )}
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
                  {tr('Siguientes acciones', 'Next actions')}
                </h3>
                <p className="mt-1 text-sm text-muted-foreground">
                  {tr('Según el estado real del workspace', 'Based on the real workspace state')}
                </p>
              </div>
              <AlertCircle className="h-5 w-5 text-primary" />
            </div>

            <div className="mt-4 space-y-3">
              {!billingSummary.hasProfessionalAccess && (
                <ActionHint
                  title={tr('Reactivar facturación', 'Reactivate billing')}
                  body={tr(
                    'Recupera estado activo o trialing antes de enviar más invitaciones.',
                    'Restore an active or trialing status before sending more invites.',
                  )}
                />
              )}
              {!hasRosterData && (
                <ActionHint
                  title={tr('Conectar el primer cliente', 'Connect the first client')}
                  body={tr(
                    'La app móvil sigue siendo el origen de verdad para aceptar códigos de invitación y establecer la relación.',
                    'The mobile app remains the source of truth for accepting invite codes and establishing the relationship.',
                  )}
                />
              )}
              {(roster?.totalPlans ?? 0) === 0 && (
                <ActionHint
                  title={tr('Publicar el primer plan', 'Publish the first plan')}
                  body={tr(
                    'El workflow de cliente soporta planes, pero todavía no existe ninguno para este profesional.',
                    'The client workflow supports plans, but none has been created yet for this professional.',
                  )}
                />
              )}
              {trends.length === 0 && (
                <ActionHint
                  title={tr('Esperar el primer sync', 'Wait for the first sync')}
                  body={tr(
                    'Las tarjetas de adherencia y progreso seguirán vacías hasta recibir datos compartidos.',
                    'Adherence and progress cards will remain empty until shared data arrives.',
                  )}
                />
              )}
              {billingSummary.hasProfessionalAccess &&
                hasRosterData &&
                (roster?.totalPlans ?? 0) > 0 &&
                trends.length > 0 && (
                  <ActionHint
                    title={tr('Revisar casos con diario detallado', 'Review detailed diary cases')}
                    body={tr(
                      'Usa el roster para ver qué clientes otorgaron acceso detailed frente a aggregate.',
                      'Use the roster to see which clients granted detailed access versus aggregate-only sharing.',
                    )}
                  />
                )}
            </div>
          </div>

          <div className="portal-panel rounded-[1.6rem] p-5">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-sm font-bold uppercase tracking-[0.16em] text-foreground">
                  {tr('Adherencia por cliente', 'Client adherence')}
                </h3>
                <p className="mt-1 text-sm text-muted-foreground">
                  {tr(
                    'Últimos promedios de clientes conectados',
                    'Latest averages for connected clients',
                  )}
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
                title={tr('Sin filas todavía', 'No rows yet')}
                body={tr(
                  'Cuando lleguen snapshots, esta tabla ordenará a los clientes conectados por adherencia media de kcal.',
                  'Once snapshots arrive, this panel will rank connected clients by average kcal adherence.',
                )}
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
                        {tr(
                          `${client.snapshotCount} snapshots`,
                          `${client.snapshotCount} snapshots`,
                        )}
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
