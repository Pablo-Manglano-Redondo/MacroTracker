import React, { useState } from 'react';
import { Check, Mail, Pencil, Target, TrendingUp, X } from 'lucide-react';
import { toast } from 'sonner';
import type { ProfessionalClient } from '../../types/database.types';
import { supabase } from '../../lib/supabase';
import { useClientProgressSummary } from '../../hooks/queries/useClientProgress';
import { usePlans } from '../../hooks/queries/usePlans';
import { formatDateOnly, formatPortalDate } from '../../lib/date';
import { getRelationshipStatusLabel, getSharingModeLabel } from '../../view-models/clients';
import { usePortalI18n } from '../../lib/portal-i18n';

interface ClientProfileProps {
  client: ProfessionalClient;
}

export const ClientProfile: React.FC<ClientProfileProps> = ({ client }) => {
  const { t, locale } = usePortalI18n();
  const { data: summary, error: summaryError } = useClientProgressSummary(client.client_id);
  const { data: plans } = usePlans(client.client_id, client.professional_id);
  const [editing, setEditing] = useState(false);
  const [name, setName] = useState(client.display_name || '');
  const [saving, setSaving] = useState(false);

  const activePlan = (plans || []).find((plan) => plan.status === 'active');
  const lastSnapshot = client.client_shared_snapshots?.length
    ? [...client.client_shared_snapshots].sort((a, b) => b.snapshot_date.localeCompare(a.snapshot_date))[0]
    : null;

  const handleSave = async () => {
    setSaving(true);
    const { error } = await supabase
      .from('professional_clients')
      .update({ display_name: name || null })
      .eq('id', client.id);
    setSaving(false);
    if (error) {
      toast.error(t('components.clientdetail.clientprofile.failed_to_update_name'));
      return;
    }
    toast.success(t('components.clientdetail.clientprofile.display_name_updated'));
    setEditing(false);
  };

  const calcAdherence = (actual: number, target: number) =>
    target > 0 ? Math.round((actual / target) * 100) : null;

  return (
    <div className="space-y-4 animate-fade-in-up">
      <section className="portal-panel rounded-[1.6rem] p-5">
        <div className="flex items-center gap-2">
          <Mail className="h-4.5 w-4.5 text-primary" />
          <h3 className="text-base font-bold text-foreground">{t('components.clientdetail.clientprofile.client_identity')}</h3>
        </div>

        <div className="mt-4 space-y-3 text-sm">
          <Row
            label={t('components.clientdetail.clientprofile.display_name')}
            value={
              editing ? (
                <div className="flex items-center gap-2">
                  <input
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="portal-input h-9 w-44 rounded-xl px-3 text-sm font-medium outline-none focus:border-primary"
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
                  <span className="font-semibold text-foreground">
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
            value={<span className="font-mono text-xs text-foreground">{client.client_id}</span>}
          />
          <Row
            label={t('components.clientdetail.clientprofile.connected_since')}
            value={formatPortalDate(client.connected_at, locale)}
          />
          <Row
            label={t('components.clientdetail.clientprofile.sharing_mode')}
            value={
              <span className="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                {getSharingModeLabel(client.sharing_mode, t)}
              </span>
            }
          />
          <Row
            label={t('components.clientdetail.clientprofile.relationship')}
            value={<span className="font-semibold text-foreground">{getRelationshipStatusLabel(client.status, t)}</span>}
          />
        </div>
      </section>

      <section className="portal-panel rounded-[1.6rem] p-5">
        <div className="flex items-center gap-2">
          <Target className="h-4.5 w-4.5 text-primary" />
          <h3 className="text-base font-bold text-foreground">{t('components.clientdetail.clientprofile.active_plan')}</h3>
        </div>
        {activePlan ? (
          <div className="mt-4 space-y-3 text-sm">
            <Row label={t('components.clientdetail.clientprofile.name')} value={<span className="font-semibold text-foreground">{activePlan.name}</span>} />
            <Row
              label={t('components.clientdetail.clientprofile.status')}
              value={
                <span className="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                  {activePlan.status}
                </span>
              }
            />
            <Row
              label={t('components.clientdetail.clientprofile.kcal_goal')}
              value={`${activePlan.meals?.reduce((sum: number, meal: any) => sum + (meal.kcal || 0), 0) || '-'} kcal`}
            />
            {activePlan.objective ? (
              <div className="rounded-2xl border border-border bg-background/60 p-4">
                <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                  {t('components.clientdetail.clientprofile.objective')}
                </p>
                <p className="mt-1 text-sm font-medium text-foreground">{activePlan.objective}</p>
              </div>
            ) : null}
          </div>
        ) : (
          <div className="mt-4 rounded-xl border border-border bg-background/60 p-4 text-sm text-muted-foreground">
            {t('components.clientdetail.clientprofile.no_active_plan_is_assigned_to_this_client')}
          </div>
        )}
      </section>

      {lastSnapshot ? (
        <section className="portal-panel rounded-[1.6rem] p-5">
          <div className="flex items-center gap-2">
            <TrendingUp className="h-4.5 w-4.5 text-primary" />
            <h3 className="text-base font-bold text-foreground">{t('components.clientdetail.clientprofile.latest_adherence')}</h3>
          </div>
          <div className="mt-4 grid gap-3 sm:grid-cols-2">
            {[
              {
                key: 'kcal',
                label: t('common.kcal'),
                unit: t('common.kcal_unit'),
                actual: lastSnapshot.kcal_actual,
                target: lastSnapshot.kcal_target,
              },
              {
                key: 'protein',
                label: t('common.protein'),
                unit: t('common.grams_unit'),
                actual: lastSnapshot.protein_actual,
                target: lastSnapshot.protein_target,
              },
              {
                key: 'carbs',
                label: t('common.carbs'),
                unit: t('common.grams_unit'),
                actual: lastSnapshot.carbs_actual,
                target: lastSnapshot.carbs_target,
              },
              {
                key: 'fat',
                label: t('common.fat'),
                unit: t('common.grams_unit'),
                actual: lastSnapshot.fat_actual,
                target: lastSnapshot.fat_target,
              },
            ].map((metric) => {
              const pct = calcAdherence(metric.actual, metric.target);
              return (
                <div key={metric.key} className="rounded-xl border border-border bg-background/60 p-4">
                  <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                    {metric.label}
                  </p>
                  <p className="mt-1 text-xl font-extrabold text-foreground">
                    {pct != null ? `${pct}%` : '--'}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {metric.actual}/{metric.target} {metric.unit}
                  </p>
                </div>
              );
            })}
          </div>
          <p className="mt-3 text-right text-[11px] font-semibold text-muted-foreground">
            {t('components.clientdetail.clientprofile.measured')}: {formatDateOnly(lastSnapshot.snapshot_date, { year: 'numeric', month: 'short', day: 'numeric' })}
          </p>
        </section>
      ) : null}

      <section className="portal-panel rounded-[1.6rem] p-5">
        <div className="flex items-center gap-2">
          <TrendingUp className="h-4.5 w-4.5 text-primary" />
          <h3 className="text-base font-bold text-foreground">{t('components.clientdetail.clientprofile.follow_up_summary')}</h3>
        </div>
        {summaryError ? (
          <div className="mt-4 rounded-xl border border-border bg-background/60 p-4 text-sm text-muted-foreground">
            {t('components.clientdetail.clientprofile.summary_metrics_are_not_available_yet_for_this_client_the_profile_still_')}
          </div>
        ) : (
          <div className="mt-4 grid gap-3 sm:grid-cols-2">
            <MetricBox
              label={t('components.clientdetail.clientprofile.latest_weight')}
              value={summary?.latest_weight != null ? `${summary.latest_weight} kg` : '--'}
              note={
                summary?.weight_change_30d != null
                  ? `${summary.weight_change_30d > 0 ? '+' : ''}${summary.weight_change_30d} kg (30d)`
                  : ''
              }
            />
            <MetricBox
              label={t('components.clientdetail.clientprofile.body_fat')}
              value={summary?.latest_body_fat != null ? `${summary.latest_body_fat}%` : '--'}
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
      </section>
    </div>
  );
};

const Row: React.FC<{ label: string; value: React.ReactNode }> = ({ label, value }) => (
  <div className="flex items-center justify-between gap-3 border-b border-border/50 pb-2 text-sm last:border-b-0 last:pb-0">
    <span className="text-muted-foreground">{label}</span>
    <div className="text-right">{value}</div>
  </div>
);

const MetricBox: React.FC<{ label: string; value: string; note?: string }> = ({ label, value, note }) => (
  <div className="rounded-xl border border-border bg-background/60 p-4">
    <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">{label}</p>
    <p className="mt-1 text-xl font-extrabold text-foreground">{value}</p>
    {note ? <p className="mt-1 text-xs text-muted-foreground">{note}</p> : null}
  </div>
);
