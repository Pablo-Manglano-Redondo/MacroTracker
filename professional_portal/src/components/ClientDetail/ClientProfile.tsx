import React, { useState, useMemo } from 'react';
import { Check, Mail, Pencil, Target, TrendingUp, X } from 'lucide-react';
import { useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import type { ProfessionalClient } from '../../types/database.types';
import { useClientProgressSummary } from '../../hooks/queries/useClientProgress';
import { usePlans, usePlan } from '../../hooks/queries/usePlans';
import { clientQueryKeys } from '../../hooks/queries/useClients';
import { clientRepository } from '../../repositories/client.repository';
import { formatDateOnly, formatPortalDate } from '../../lib/date';
import { getRelationshipStatusLabel, getSharingModeLabel } from '../../view-models/clients';
import { usePortalI18n } from '../../lib/portal-i18n';
import { useAuth } from '../../lib/auth-context';
import { supabase } from '../../lib/supabase';

interface ClientProfileProps {
  client: ProfessionalClient;
  onClientUpdated?: (client: ProfessionalClient) => void;
}

export const ClientProfile: React.FC<ClientProfileProps> = ({
  client,
  onClientUpdated,
}) => {
  const queryClient = useQueryClient();
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();
  const { data: summary, error: summaryError } = useClientProgressSummary(client.client_id);
  const { data: plans } = usePlans(client.client_id, client.professional_id);
  const [editing, setEditing] = useState(false);
  const [name, setName] = useState(client.display_name || '');
  const [saving, setSaving] = useState(false);

  const activePlanBasic = (plans || []).find((plan) => plan.status === 'active');
  const { data: activePlan } = usePlan(activePlanBasic?.id);

  const lastSnapshot = client.client_shared_snapshots?.length
    ? [...client.client_shared_snapshots].sort((a, b) => b.snapshot_date.localeCompare(a.snapshot_date))[0]
    : null;

  const latestWeight = useMemo(() => {
    if (summary?.latest_weight != null) return `${summary.latest_weight} kg`;
    const sortedSnaps = [...(client.client_shared_snapshots || [])].sort((a, b) => b.snapshot_date.localeCompare(a.snapshot_date));
    const snapWeight = sortedSnaps.find((s) => s.weight_kg != null && s.weight_kg > 0)?.weight_kg;
    return snapWeight != null ? `${snapWeight} kg` : '--';
  }, [summary?.latest_weight, client.client_shared_snapshots]);

  const latestBodyFat = useMemo(() => {
    if (summary?.latest_body_fat != null) return `${summary.latest_body_fat}%`;
    return '--';
  }, [summary?.latest_body_fat]);

  const objectiveLabel = (value: string) =>
    ({
      general_fitness: t('components.plantemplatespanel.general_fitness' as any) || 'Estado físico general',
      weight_loss: t('components.plantemplatespanel.weight_loss' as any) || 'Pérdida de peso',
      muscle_gain: t('components.plantemplatespanel.muscle_gain' as any) || 'Ganancia muscular',
      maintenance: t('components.plantemplatespanel.maintenance' as any) || 'Mantenimiento',
      performance: t('components.plantemplatespanel.performance' as any) || 'Rendimiento',
    })[value] ?? value;

  const handleSave = async () => {
    setSaving(true);
    const normalizedName = name.trim() || null;
    let error: Error | null = null;
    try {
      await clientRepository.updateDisplayName(supabase, client.id, normalizedName ?? '');
    } catch (err) {
      error = err as Error;
    }
    setSaving(false);
    if (error) {
      toast.error(t('components.clientdetail.clientprofile.failed_to_update_name'));
      return;
    }
    const updatedClient: ProfessionalClient = {
      ...client,
      display_name: normalizedName,
    };
    if (professional?.id) {
      queryClient.setQueryData<ProfessionalClient[]>(
        clientQueryKeys.clients(professional.id),
        (current) =>
          current?.map((item) => (item.id === client.id ? updatedClient : item)) ?? current,
      );
      void queryClient.invalidateQueries({
        queryKey: clientQueryKeys.clients(professional.id),
      });
    }
    onClientUpdated?.(updatedClient);
    toast.success(t('components.clientdetail.clientprofile.display_name_updated'));
    setEditing(false);
  };

  const calcAdherence = (actual: number, target: number) =>
    target > 0 ? Math.round((actual / target) * 100) : null;

  return (
    <div className="grid grid-cols-1 gap-5 lg:grid-cols-2 items-stretch animate-fade-in-up">
      {/* Card 1: Client Identity */}
      <section className="portal-panel rounded-[1.6rem] p-5 flex flex-col justify-between h-full">
        <div>
          <div className="flex items-center gap-2">
            <Mail className="h-4.5 w-4.5 text-primary" />
            <h3 className="portal-card-heading">{t('components.clientdetail.clientprofile.client_identity')}</h3>
          </div>

          <div className="mt-4 space-y-3">
            <Row
              label={t('components.clientdetail.clientprofile.display_name')}
              value={
                editing ? (
                  <div className="flex items-center gap-2">
                    <input
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      className="portal-input h-9 w-44 rounded-xl px-3 outline-none focus:border-primary"
                      autoFocus
                      onKeyDown={(e) => {
                        if (e.key === 'Enter') handleSave();
                        if (e.key === 'Escape') setEditing(false);
                      }}
                    />
                    <button onClick={handleSave} disabled={saving} className="rounded-xl p-2 text-primary hover:bg-primary/10">
                      <Check className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => {
                        setEditing(false);
                        setName(client.display_name || '');
                      }}
                      className="rounded-xl p-2 text-muted-foreground hover:bg-accent"
                    >
                      <X className="h-4 w-4" />
                    </button>
                  </div>
                ) : (
                  <div className="flex items-center gap-2">
                    <span className="portal-meta text-foreground">
                      {client.display_name || t('components.clientdetail.clientprofile.no_display_name_set')}
                    </span>
                    <button
                      onClick={() => setEditing(true)}
                      className="rounded-xl p-1.5 text-muted-foreground hover:bg-primary/10 hover:text-primary"
                    >
                      <Pencil className="h-3.5 w-3.5" />
                    </button>
                  </div>
                )
              }
            />
            <Row
              label={t('common.client_id')}
              value={<span className="portal-meta font-mono text-foreground text-[11px] truncate max-w-[150px] inline-block">{client.client_id}</span>}
            />
            <Row
              label={t('components.clientdetail.clientprofile.connected_since')}
              value={formatPortalDate(client.connected_at, locale)}
            />
            <Row
              label={t('components.clientdetail.clientprofile.sharing_mode')}
              value={
                <span className="portal-pill rounded-full bg-primary/10 px-3 py-1 text-primary">
                  {getSharingModeLabel(client.sharing_mode, t)}
                </span>
              }
            />
            <Row
              label={t('components.clientdetail.clientprofile.relationship')}
              value={<span className="portal-meta text-foreground">{getRelationshipStatusLabel(client.status, t)}</span>}
            />
          </div>
        </div>
      </section>

      {/* Card 2: Active Plan */}
      <section className="portal-panel rounded-[1.6rem] p-5 flex flex-col justify-between h-full">
        <div>
          <div className="flex items-center gap-2">
            <Target className="h-4.5 w-4.5 text-primary" />
            <h3 className="portal-card-heading">{t('components.clientdetail.clientprofile.active_plan')}</h3>
          </div>
          {activePlan ? (
            <div className="mt-4 space-y-3">
              <Row label={t('components.clientdetail.clientprofile.name')} value={<span className="portal-meta text-foreground font-extrabold">{activePlan.name}</span>} />
              <Row
                label={t('components.clientdetail.clientprofile.status')}
                value={
                  <span className="portal-pill rounded-full bg-primary/10 px-3 py-1 text-primary capitalize font-extrabold">
                    {activePlan.status}
                  </span>
                }
              />
              <Row
                label={t('components.clientdetail.clientprofile.kcal_goal')}
                value={`${activePlan.days?.[0]?.kcal_goal || activePlan.meals?.reduce((sum: number, meal: any) => sum + (meal.kcal || 0), 0) || '-'} kcal`}
              />
              {activePlan.objective ? (
                <div className="rounded-2xl border border-border bg-background/60 p-4 mt-2">
                  <p className="portal-label">
                    {t('components.clientdetail.clientprofile.objective')}
                  </p>
                  <p className="portal-body mt-1 text-foreground font-extrabold">{objectiveLabel(activePlan.objective)}</p>
                </div>
              ) : null}
            </div>
          ) : (
            <div className="portal-body mt-4 rounded-xl border border-border bg-background/60 p-4 text-muted-foreground animate-pulse">
              {t('components.clientdetail.clientprofile.no_active_plan_is_assigned_to_this_client')}
            </div>
          )}
        </div>
      </section>

      {/* Card 3: Follow-up Summary */}
      <section className="portal-panel rounded-[1.6rem] p-5 flex flex-col justify-between h-full">
        <div>
          <div className="flex items-center gap-2">
            <TrendingUp className="h-4.5 w-4.5 text-primary" />
            <h3 className="portal-card-heading">{t('components.clientdetail.clientprofile.follow_up_summary')}</h3>
          </div>
          {summaryError ? (
            <div className="portal-body mt-4 rounded-xl border border-border bg-background/60 p-4 text-muted-foreground">
              {t('components.clientdetail.clientprofile.summary_metrics_are_not_available_yet_for_this_client_the_profile_still_')}
            </div>
          ) : (
            <div className="mt-4 grid gap-3 sm:grid-cols-2">
              <MetricBox
                label={t('components.clientdetail.clientprofile.latest_weight')}
                value={latestWeight}
                note={
                  summary?.weight_change_30d != null
                    ? `${summary.weight_change_30d > 0 ? '+' : ''}${summary.weight_change_30d} kg (30d)`
                    : '\u00A0'
                }
              />
              <MetricBox
                label={t('components.clientdetail.clientprofile.body_fat')}
                value={latestBodyFat}
                note="\u00A0"
              />
              <MetricBox
                label={t('components.clientdetail.clientprofile.check_ins')}
                value={String(summary?.checkin_count ?? 0)}
                note={
                  summary?.last_checkin
                    ? `${t('components.clientdetail.clientprofile.last')}: ${formatPortalDate(summary.last_checkin, locale)}`
                    : t('components.clientdetail.clientprofile.no_check_ins')
                }
              />
              <MetricBox
                label={t('components.clientdetail.clientprofile.notes_and_recipes')}
                value={`${summary?.note_count ?? 0} / ${summary?.recipe_count ?? 0}`}
                note={t('components.clientdetail.clientprofile.notes_proposed_recipes')}
              />
            </div>
          )}
        </div>
        <p className="portal-meta mt-4 text-right text-muted-foreground/80">
          {summary?.last_checkin
            ? `${t('components.clientdetail.clientprofile.last')}: ${formatPortalDate(summary.last_checkin, locale)}`
            : '\u00A0'}
        </p>
      </section>

      {/* Card 4: Latest Adherence */}
      {lastSnapshot ? (
        <section className="portal-panel rounded-[1.6rem] p-5 flex flex-col justify-between h-full">
          <div>
            <div className="flex items-center gap-2">
              <TrendingUp className="h-4.5 w-4.5 text-primary" />
              <h3 className="portal-card-heading">{t('components.clientdetail.clientprofile.latest_adherence')}</h3>
            </div>
            <div className="mt-4 grid gap-3 sm:grid-cols-2">
              {[
                {
                  key: 'kcal',
                  label: t('common.kcal'),
                  unit: t('common.kcal_unit'),
                  actual: lastSnapshot.kcal_actual,
                  target: lastSnapshot.kcal_target,
                  colorClass: 'bg-primary',
                },
                {
                  key: 'protein',
                  label: t('common.protein'),
                  unit: t('common.grams_unit'),
                  actual: lastSnapshot.protein_actual,
                  target: lastSnapshot.protein_target,
                  colorClass: 'bg-emerald-500',
                },
                {
                  key: 'carbs',
                  label: t('common.carbs'),
                  unit: t('common.grams_unit'),
                  actual: lastSnapshot.carbs_actual,
                  target: lastSnapshot.carbs_target,
                  colorClass: 'bg-sky-500',
                },
                {
                  key: 'fat',
                  label: t('common.fat'),
                  unit: t('common.grams_unit'),
                  actual: lastSnapshot.fat_actual,
                  target: lastSnapshot.fat_target,
                  colorClass: 'bg-amber-500',
                },
              ].map((metric) => {
                const pct = calcAdherence(metric.actual, metric.target);
                return (
                  <MetricBox
                    key={metric.key}
                    label={metric.label}
                    value={pct != null ? `${pct}%` : '--'}
                    note={`${metric.actual}/${metric.target} ${metric.unit}`}
                    progress={
                      pct != null
                        ? {
                            pct,
                            colorClass: metric.colorClass,
                          }
                        : undefined
                    }
                  />
                );
              })}
            </div>
          </div>
          <p className="portal-meta mt-4 text-right">
            {t('components.clientdetail.clientprofile.measured')}: {formatDateOnly(lastSnapshot.snapshot_date, { year: 'numeric', month: 'short', day: 'numeric' }, locale)}
          </p>
        </section>
      ) : (
        <section className="portal-panel rounded-[1.6rem] p-5 flex flex-col justify-center items-center text-muted-foreground text-center h-full">
          <TrendingUp className="h-8 w-8 text-muted-foreground/40 mb-2" />
          <p className="portal-body">
            {locale?.toLowerCase().startsWith('es') ? 'No hay registros de adherencia recientes.' : 'No recent adherence records.'}
          </p>
        </section>
      )}
    </div>
  );
};

const Row: React.FC<{ label: string; value: React.ReactNode }> = ({ label, value }) => (
  <div className="portal-meta flex items-center justify-between gap-3 border-b border-border/50 pb-2 last:border-b-0 last:pb-0">
    <span className="portal-meta">{label}</span>
    <div className="text-right">{value}</div>
  </div>
);

const MetricBox: React.FC<{
  label: string;
  value: string;
  note?: string;
  progress?: {
    pct: number;
    colorClass: string;
  };
}> = ({ label, value, note, progress }) => (
  <div className="rounded-xl border border-border bg-background/60 p-4 h-[115px] flex flex-col justify-between">
    <div>
      <p className="portal-kpi-label truncate">{label}</p>
      <p className="portal-metric mt-0.5 text-foreground font-extrabold truncate">{value}</p>
    </div>
    <div>
      {note ? <p className="portal-meta truncate">{note}</p> : null}
      {progress && (
        <div className="mt-2.5 h-1.5 w-full rounded-full bg-secondary/30 overflow-hidden">
          <div
            className={`h-full rounded-full transition-all duration-500 ${progress.colorClass}`}
            style={{ width: `${Math.min(100, progress.pct)}%` }}
          />
        </div>
      )}
    </div>
  </div>
);
