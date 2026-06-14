import React, { useMemo, useState } from 'react';
import { Plus, Scale, TrendingDown, Weight } from 'lucide-react';
import { toast } from 'sonner';
import type { ProfessionalClient } from '../../types/database.types';
import { useClientProgress } from '../../hooks/queries/useClientProgress';
import {
  useCreateProgress,
  useDeleteProgress,
} from '../../hooks/mutations/useClientProgress';
import { toDateOnlyString } from '../../lib/date';
import { usePortalI18n } from '../../lib/portal-i18n';

function WeightChart({
  records,
  title,
}: {
  records: { record_date: string; weight_kg: number }[];
  title: string;
}) {
  const sorted = [...records].sort((a, b) => a.record_date.localeCompare(b.record_date));
  const minW = Math.min(...sorted.map((r) => r.weight_kg));
  const maxW = Math.max(...sorted.map((r) => r.weight_kg));
  const range = Math.max(maxW - minW, 1);
  const w = 280;
  const h = 100;
  const px = 35;
  const py = 10;

  const points = sorted.map((record, index) => {
    const x = px + (index / Math.max(sorted.length - 1, 1)) * (w - px * 2);
    const y = h - py - ((record.weight_kg - minW) / range) * (h - py * 2);
    return { x, y, ...record };
  });

  const pathD = points
    .map((point, index) => `${index === 0 ? 'M' : 'L'}${point.x.toFixed(1)},${point.y.toFixed(1)}`)
    .join(' ');

  return (
    <div className="rounded-xl border border-border bg-background/60 p-4">
      <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-primary">{title}</p>
      <svg viewBox={`0 0 ${w} ${h}`} className="mt-3 h-auto w-full" preserveAspectRatio="xMidYMid meet">
        <defs>
          <linearGradient id="weightGrad" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor="#2f7d68" />
            <stop offset="100%" stopColor="#7ec5b4" />
          </linearGradient>
        </defs>

        <text x={px - 6} y={py + 3} className="fill-[rgb(125,125,125)] font-bold" fontSize="6.5" textAnchor="end">
          {maxW.toFixed(1)}
        </text>
        <text
          x={px - 6}
          y={h - py + 3}
          className="fill-[rgb(125,125,125)] font-bold"
          fontSize="6.5"
          textAnchor="end"
        >
          {minW.toFixed(1)}
        </text>

        {sorted.length > 1 ? (
          <path d={pathD} fill="none" stroke="url(#weightGrad)" strokeWidth="2.2" strokeLinecap="round" />
        ) : null}

        {points.map((point) => (
          <circle key={point.record_date} cx={point.x} cy={point.y} r="2.5" fill="#2f7d68" />
        ))}
      </svg>
    </div>
  );
}

export const ClientProgressPanel: React.FC<{ client: ProfessionalClient }> = ({ client }) => {
  const { tr, locale } = usePortalI18n();
  const { data: records, isLoading, error } = useClientProgress(client.id);
  const createRecord = useCreateProgress(client.id);
  const deleteRecord = useDeleteProgress(client.id);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({
    weight_kg: '',
    body_fat_pct: '',
    waist_cm: '',
    hip_cm: '',
    chest_cm: '',
    arm_cm: '',
    thigh_cm: '',
    notes: '',
  });

  const latest = records?.[0];
  const sorted = [...(records || [])].sort((a, b) => b.record_date.localeCompare(a.record_date));
  const snapshots = client.client_shared_snapshots || [];
  const weightFromProgress = (records || []).filter(
    (record): record is typeof record & { weight_kg: number } => record.weight_kg != null && record.weight_kg > 0,
  );
  const weightFromSnapshots = snapshots
    .filter((snapshot): snapshot is typeof snapshot & { weight_kg: number } => snapshot.weight_kg != null && snapshot.weight_kg > 0)
    .map((snapshot) => ({ record_date: snapshot.snapshot_date, weight_kg: snapshot.weight_kg! }));
  const latestWaistFromSnapshot = snapshots
    .filter((snapshot): snapshot is typeof snapshot & { waist_cm: number } => snapshot.waist_cm != null && snapshot.waist_cm > 0)
    .sort((a, b) => b.snapshot_date.localeCompare(a.snapshot_date))[0]?.waist_cm;

  const weightRecords = useMemo(() => {
    const merged = [...weightFromProgress, ...weightFromSnapshots];
    merged.sort((a, b) => a.record_date.localeCompare(b.record_date));
    const deduped: typeof merged = [];
    for (const record of merged) {
      const last = deduped.length > 0 ? deduped[deduped.length - 1] : null;
      if (!last || last.record_date !== record.record_date) deduped.push(record);
    }
    return deduped;
  }, [weightFromProgress.length, weightFromSnapshots.length, client.client_shared_snapshots?.length]);

  const handleCreate = async () => {
    if (!form.weight_kg && !form.body_fat_pct && !form.waist_cm) {
      toast.error(tr('Introduce al menos una medición', 'At least one measurement is required'));
      return;
    }
    try {
      await createRecord.mutateAsync({
        professional_client_id: client.id,
        professional_id: client.professional_id,
        client_id: client.client_id,
        record_date: toDateOnlyString(),
        weight_kg: form.weight_kg ? +form.weight_kg : null,
        body_fat_pct: form.body_fat_pct ? +form.body_fat_pct : null,
        waist_cm: form.waist_cm ? +form.waist_cm : null,
        hip_cm: form.hip_cm ? +form.hip_cm : null,
        chest_cm: form.chest_cm ? +form.chest_cm : null,
        arm_cm: form.arm_cm ? +form.arm_cm : null,
        thigh_cm: form.thigh_cm ? +form.thigh_cm : null,
        notes: form.notes || null,
        source: 'professional',
      });
      toast.success(tr('Progreso guardado', 'Progress saved'));
      setShowForm(false);
      setForm({
        weight_kg: '',
        body_fat_pct: '',
        waist_cm: '',
        hip_cm: '',
        chest_cm: '',
        arm_cm: '',
        thigh_cm: '',
        notes: '',
      });
    } catch {
      toast.error(tr('No se pudo guardar', 'Failed to save'));
    }
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between border-b border-border pb-3">
        <div className="flex items-center gap-2">
          <Scale className="h-4.5 w-4.5 text-primary" />
          <h3 className="text-base font-bold text-foreground">
            {tr('Progreso y mediciones', 'Progress and measurements')}
          </h3>
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="inline-flex items-center gap-1 rounded-xl bg-primary px-3 py-1.5 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground"
        >
          <Plus className="h-3.5 w-3.5" />
          {tr('Registrar', 'Record entry')}
        </button>
      </div>

      {latest ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {latest.weight_kg != null ? (
            <MetricCard
              label={tr('Peso', 'Weight')}
              value={`${latest.weight_kg} kg`}
              icon={<Weight className="h-3.5 w-3.5 text-primary" />}
            />
          ) : null}
          {latest.body_fat_pct != null ? (
            <MetricCard
              label={tr('Grasa corporal', 'Body fat')}
              value={`${latest.body_fat_pct}%`}
              icon={<TrendingDown className="h-3.5 w-3.5 text-sky-500 dark:text-sky-300" />}
            />
          ) : null}
          {(latest?.waist_cm ?? latestWaistFromSnapshot) != null ? (
            <MetricCard
              label={tr('Cintura', 'Waist')}
              value={`${latest?.waist_cm ?? latestWaistFromSnapshot} cm`}
              note={latest?.waist_cm == null ? tr('Dato del cliente', 'Client-shared') : undefined}
            />
          ) : null}
          {latest.hip_cm != null ? (
            <MetricCard label={tr('Cadera', 'Hip')} value={`${latest.hip_cm} cm`} />
          ) : null}
        </div>
      ) : null}

      {weightRecords.length >= 2 ? (
        <WeightChart records={weightRecords} title={tr('Tendencia de peso (kg)', 'Weight trend (kg)')} />
      ) : null}

      {showForm ? (
        <div className="portal-panel rounded-[1.4rem] p-4">
          <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
            {(
              [
                'weight_kg',
                'body_fat_pct',
                'waist_cm',
                'hip_cm',
                'chest_cm',
                'arm_cm',
                'thigh_cm',
              ] as const
            ).map((field) => (
              <div key={field} className="space-y-1">
                <label className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground capitalize">
                  {field.replace('_', ' ')}
                </label>
                <input
                  type="number"
                  step="0.1"
                  value={form[field]}
                  onChange={(e) => setForm((prev) => ({ ...prev, [field]: e.target.value }))}
                  className="portal-input h-10 w-full rounded-xl px-3 text-sm font-medium outline-none focus:border-primary"
                />
              </div>
            ))}
          </div>
          <textarea
            value={form.notes}
            onChange={(e) => setForm((prev) => ({ ...prev, notes: e.target.value }))}
            placeholder={tr('Notas sobre la medición (opcional)...', 'Measurement notes (optional)...')}
            rows={2}
            className="portal-input mt-4 w-full rounded-xl px-3 py-3 text-sm font-medium outline-none focus:border-primary"
          />
          <div className="mt-4 flex justify-end gap-2">
            <button
              onClick={() => setShowForm(false)}
              className="rounded-xl border border-border px-3 py-2 text-sm font-semibold text-foreground hover:bg-accent"
            >
              {tr('Cancelar', 'Cancel')}
            </button>
            <button
              onClick={handleCreate}
              disabled={createRecord.isPending}
              className="rounded-xl bg-primary px-3 py-2 text-sm font-bold text-primary-foreground disabled:opacity-50"
            >
              {tr('Guardar registro', 'Save record')}
            </button>
          </div>
        </div>
      ) : null}

      {error ? (
        <div className="portal-panel rounded-[1.4rem] p-8 text-center text-sm text-muted-foreground">
          {tr(
            'Los registros de progreso no están disponibles ahora mismo. Las métricas derivadas de snapshots pueden seguir apareciendo.',
            'Progress records are not available right now. Snapshot-based metrics may still appear.',
          )}
        </div>
      ) : isLoading ? (
        <div className="space-y-3">
          {[1, 2].map((index) => (
            <div key={index} className="portal-panel h-14 rounded-[1.4rem] animate-pulse" />
          ))}
        </div>
      ) : sorted.length === 0 ? (
        <div className="portal-panel rounded-[1.4rem] p-8 text-center text-sm text-muted-foreground">
          {tr('Todavía no hay registros de progreso.', 'No progress records have been saved yet.')}
        </div>
      ) : (
        <div className="portal-panel overflow-hidden rounded-[1.4rem]">
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-sm">
              <thead>
                <tr className="border-b border-border bg-background text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                  <th className="px-4 py-3 text-left">{tr('Fecha', 'Date')}</th>
                  <th className="px-3 py-3 text-right">{tr('Peso', 'Weight')}</th>
                  <th className="px-3 py-3 text-right">BF%</th>
                  <th className="px-3 py-3 text-right">{tr('Cintura', 'Waist')}</th>
                  <th className="px-3 py-3 text-right">{tr('Cadera', 'Hip')}</th>
                  <th className="px-3 py-3 text-right">{tr('Pecho', 'Chest')}</th>
                  <th className="px-3 py-3 text-right">{tr('Brazo', 'Arm')}</th>
                  <th className="px-3 py-3 text-right">{tr('Muslo', 'Thigh')}</th>
                  <th className="w-12 px-4 py-3" />
                </tr>
              </thead>
              <tbody className="divide-y divide-border/40">
                {sorted.map((record) => (
                  <tr key={record.id} className="hover:bg-accent/50">
                    <td className="px-4 py-3 font-semibold text-foreground">
                      {new Date(record.record_date).toLocaleDateString(locale === 'es' ? 'es-ES' : 'en-US')}
                    </td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.weight_kg ?? '--'}</td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.body_fat_pct ?? '--'}</td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.waist_cm ?? '--'}</td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.hip_cm ?? '--'}</td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.chest_cm ?? '--'}</td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.arm_cm ?? '--'}</td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.thigh_cm ?? '--'}</td>
                    <td className="px-4 py-3 text-right">
                      <button
                        onClick={async () => {
                          try {
                            await deleteRecord.mutateAsync(record.id);
                            toast.success(tr('Registro eliminado', 'Record deleted'));
                          } catch {
                            toast.error(tr('No se pudo eliminar', 'Failed to delete'));
                          }
                        }}
                        className="rounded-xl px-2 py-1 text-[11px] font-semibold text-muted-foreground hover:bg-rose-500/10 hover:text-rose-500"
                      >
                        {tr('Borrar', 'Delete')}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
};

const MetricCard: React.FC<{
  label: string;
  value: string;
  icon?: React.ReactNode;
  note?: string;
}> = ({ label, value, icon, note }) => (
  <div className="portal-panel rounded-[1.4rem] p-4">
    <div className="flex items-center gap-2">
      {icon}
      <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">{label}</p>
    </div>
    <p className="mt-2 text-xl font-extrabold text-foreground">{value}</p>
    {note ? <p className="mt-1 text-xs text-muted-foreground">{note}</p> : null}
  </div>
);
