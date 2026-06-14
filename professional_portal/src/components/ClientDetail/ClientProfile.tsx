import React, { useState } from 'react';
import { Check, Mail, Pencil, Target, TrendingUp, X } from 'lucide-react';
import { toast } from 'sonner';
import type { ProfessionalClient } from '../../types/database.types';
import { supabase } from '../../lib/supabase';
import { useClientProgressSummary } from '../../hooks/queries/useClientProgress';
import { usePlans } from '../../hooks/queries/usePlans';
import { formatDateOnly } from '../../lib/date';
import { getRelationshipStatusLabel, getSharingModeLabel } from '../../view-models/clients';
import { usePortalI18n } from '../../lib/portal-i18n';

interface ClientProfileProps {
  client: ProfessionalClient;
}

export const ClientProfile: React.FC<ClientProfileProps> = ({ client }) => {
  const { tr, locale } = usePortalI18n();
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
      toast.error(tr('No se pudo actualizar el nombre', 'Failed to update name'));
      return;
    }
    toast.success(tr('Nombre visible actualizado', 'Display name updated'));
    setEditing(false);
  };

  const calcAdherence = (actual: number, target: number) =>
    target > 0 ? Math.round((actual / target) * 100) : null;

  return (
    <div className="space-y-4 animate-fade-in-up">
      <section className="portal-panel rounded-[1.6rem] p-5">
        <div className="flex items-center gap-2">
          <Mail className="h-4.5 w-4.5 text-primary" />
          <h3 className="text-base font-bold text-foreground">{tr('Identidad del cliente', 'Client identity')}</h3>
        </div>

        <div className="mt-4 space-y-3 text-sm">
          <Row
            label={tr('Nombre visible', 'Display name')}
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
                    {client.display_name || tr('Sin nombre visible', 'No display name set')}
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
            label="Client ID"
            value={<span className="font-mono text-xs text-foreground">{client.client_id}</span>}
          />
          <Row
            label={tr('Conectado desde', 'Connected since')}
            value={new Date(client.connected_at).toLocaleDateString(locale === 'es' ? 'es-ES' : 'en-US')}
          />
          <Row
            label={tr('Sharing mode', 'Sharing mode')}
            value={
              <span className="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                {getSharingModeLabel(client.sharing_mode)}
              </span>
            }
          />
          <Row
            label={tr('Relación', 'Relationship')}
            value={<span className="font-semibold text-foreground">{getRelationshipStatusLabel(client.status)}</span>}
          />
        </div>
      </section>

      <section className="portal-panel rounded-[1.6rem] p-5">
        <div className="flex items-center gap-2">
          <Target className="h-4.5 w-4.5 text-primary" />
          <h3 className="text-base font-bold text-foreground">{tr('Plan activo', 'Active plan')}</h3>
        </div>
        {activePlan ? (
          <div className="mt-4 space-y-3 text-sm">
            <Row label={tr('Nombre', 'Name')} value={<span className="font-semibold text-foreground">{activePlan.name}</span>} />
            <Row
              label={tr('Estado', 'Status')}
              value={
                <span className="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                  {activePlan.status}
                </span>
              }
            />
            <Row
              label={tr('Objetivo kcal', 'Kcal goal')}
              value={`${activePlan.meals?.reduce((sum: number, meal: any) => sum + (meal.kcal || 0), 0) || '-'} kcal`}
            />
            {activePlan.objective ? (
              <div className="rounded-2xl border border-border bg-background/60 p-4">
                <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                  {tr('Objetivo', 'Objective')}
                </p>
                <p className="mt-1 text-sm font-medium text-foreground">{activePlan.objective}</p>
              </div>
            ) : null}
          </div>
        ) : (
          <div className="mt-4 rounded-xl border border-border bg-background/60 p-4 text-sm text-muted-foreground">
            {tr('No hay ningún plan activo asignado a este cliente.', 'No active plan is assigned to this client.')}
          </div>
        )}
      </section>

      {lastSnapshot ? (
        <section className="portal-panel rounded-[1.6rem] p-5">
          <div className="flex items-center gap-2">
            <TrendingUp className="h-4.5 w-4.5 text-primary" />
            <h3 className="text-base font-bold text-foreground">{tr('Última adherencia', 'Latest adherence')}</h3>
          </div>
          <div className="mt-4 grid gap-3 sm:grid-cols-2">
            {[
              {
                label: 'Kcal',
                actual: lastSnapshot.kcal_actual,
                target: lastSnapshot.kcal_target,
              },
              {
                label: 'Protein',
                actual: lastSnapshot.protein_actual,
                target: lastSnapshot.protein_target,
              },
              {
                label: 'Carbs',
                actual: lastSnapshot.carbs_actual,
                target: lastSnapshot.carbs_target,
              },
              {
                label: 'Fat',
                actual: lastSnapshot.fat_actual,
                target: lastSnapshot.fat_target,
              },
            ].map((metric) => {
              const pct = calcAdherence(metric.actual, metric.target);
              return (
                <div key={metric.label} className="rounded-xl border border-border bg-background/60 p-4">
                  <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                    {metric.label}
                  </p>
                  <p className="mt-1 text-xl font-extrabold text-foreground">
                    {pct != null ? `${pct}%` : '--'}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {metric.actual}/{metric.target} {metric.label === 'Kcal' ? 'kcal' : 'g'}
                  </p>
                </div>
              );
            })}
          </div>
          <p className="mt-3 text-right text-[11px] font-semibold text-muted-foreground">
            {tr('Medido', 'Measured')}: {formatDateOnly(lastSnapshot.snapshot_date, { year: 'numeric', month: 'short', day: 'numeric' })}
          </p>
        </section>
      ) : null}

      <section className="portal-panel rounded-[1.6rem] p-5">
        <div className="flex items-center gap-2">
          <TrendingUp className="h-4.5 w-4.5 text-primary" />
          <h3 className="text-base font-bold text-foreground">{tr('Resumen de seguimiento', 'Follow-up summary')}</h3>
        </div>
        {summaryError ? (
          <div className="mt-4 rounded-xl border border-border bg-background/60 p-4 text-sm text-muted-foreground">
            {tr(
              'Las métricas resumidas aún no están disponibles para este cliente. Aun así, el perfil mantiene la verdad de relación, snapshot y plan.',
              'Summary metrics are not available yet for this client. The profile still keeps relationship, snapshot, and plan truth visible.',
            )}
          </div>
        ) : (
          <div className="mt-4 grid gap-3 sm:grid-cols-2">
            <MetricBox
              label={tr('Último peso', 'Latest weight')}
              value={summary?.latest_weight != null ? `${summary.latest_weight} kg` : '--'}
              note={
                summary?.weight_change_30d != null
                  ? `${summary.weight_change_30d > 0 ? '+' : ''}${summary.weight_change_30d} kg (30d)`
                  : ''
              }
            />
            <MetricBox
              label={tr('Grasa corporal', 'Body fat')}
              value={summary?.latest_body_fat != null ? `${summary.latest_body_fat}%` : '--'}
            />
            <MetricBox
              label={tr('Check-ins', 'Check-ins')}
              value={String(summary?.checkin_count ?? 0)}
              note={
                summary?.last_checkin
                  ? `${tr('Último', 'Last')}: ${new Date(summary.last_checkin).toLocaleDateString(locale === 'es' ? 'es-ES' : 'en-US')}`
                  : tr('Sin check-ins', 'No check-ins')
              }
            />
            <MetricBox
              label={tr('Notas y recetas', 'Notes and recipes')}
              value={`${summary?.note_count ?? 0} / ${summary?.recipe_count ?? 0}`}
              note={tr('Notas · recetas propuestas', 'Notes · proposed recipes')}
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
