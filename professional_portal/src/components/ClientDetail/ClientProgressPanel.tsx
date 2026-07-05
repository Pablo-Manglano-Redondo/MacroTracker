import React, { useMemo, useState } from 'react';
import { Plus, Scale, TrendingDown, Weight } from 'lucide-react';
import { toast } from 'sonner';
import type { ProfessionalClient } from '../../types/database.types';
import type { PortalTranslationKey } from '../../lib/generated/i18n';
import { useClientProgress } from '../../hooks/queries/useClientProgress';
import {
  useCreateProgress,
  useDeleteProgress,
} from '../../hooks/mutations/useClientProgress';
import { formatPortalDate, toDateOnlyString } from '../../lib/date';
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
  const w = 300;
  const h = 130;
  const px = 40;
  const pyTop = 15;
  const pyBottom = 25;

  const points = sorted.map((record, index) => {
    const x = px + (index / Math.max(sorted.length - 1, 1)) * (w - px * 2);
    const y = h - pyBottom - ((record.weight_kg - minW) / range) * (h - pyTop - pyBottom);
    return { x, y, ...record };
  });

  const pathD = points
    .map((point, index) => `${index === 0 ? 'M' : 'L'}${point.x.toFixed(1)},${point.y.toFixed(1)}`)
    .join(' ');

  const labelIndices = useMemo(() => {
    if (sorted.length <= 5) {
      return sorted.map((_, i) => i);
    }
    const step = (sorted.length - 1) / 3;
    return [0, Math.round(step), Math.round(step * 2), sorted.length - 1];
  }, [sorted.length]);

  return (
    <div className="rounded-xl border border-border bg-background/60 p-4">
      <p className="portal-label text-primary">{title}</p>
      <svg viewBox={`0 0 ${w} ${h}`} className="mt-3 h-auto w-full" preserveAspectRatio="xMidYMid meet">
        <defs>
          <linearGradient id="weightGrad" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor="#2f7d68" />
            <stop offset="100%" stopColor="#7ec5b4" />
          </linearGradient>
        </defs>

        {/* Grid lines */}
        <line
          x1={px}
          y1={pyTop}
          x2={w - px}
          y2={pyTop}
          stroke="rgba(125,125,125,0.15)"
          strokeWidth="0.8"
          strokeDasharray="3,3"
        />
        <line
          x1={px}
          y1={pyTop + (h - pyTop - pyBottom) / 2}
          x2={w - px}
          y2={pyTop + (h - pyTop - pyBottom) / 2}
          stroke="rgba(125,125,125,0.15)"
          strokeWidth="0.8"
          strokeDasharray="3,3"
        />
        <line
          x1={px}
          y1={h - pyBottom}
          x2={w - px}
          y2={h - pyBottom}
          stroke="rgba(125,125,125,0.25)"
          strokeWidth="1"
        />

        {/* Y Axis Labels */}
        <text x={px - 6} y={pyTop + 2.5} className="fill-[rgb(125,125,125)] font-bold text-[6.5px]" textAnchor="end">
          {maxW.toFixed(1)}
        </text>
        <text
          x={px - 6}
          y={pyTop + (h - pyTop - pyBottom) / 2 + 2.5}
          className="fill-[rgb(125,125,125)] font-bold text-[6.5px]"
          textAnchor="end"
        >
          {((maxW + minW) / 2).toFixed(1)}
        </text>
        <text
          x={px - 6}
          y={h - pyBottom + 2.5}
          className="fill-[rgb(125,125,125)] font-bold text-[6.5px]"
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

        {labelIndices.map((i) => {
          const pt = points[i];
          if (!pt) return null;

          const parts = pt.record_date.split('-');
          const day = parts[2] ? parseInt(parts[2], 10) : '';
          const monthsEs = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
          const monthIndex = parts[1] ? parseInt(parts[1], 10) - 1 : 0;
          const monthStr = monthsEs[monthIndex] || '';
          const label = `${day} ${monthStr}`;

          return (
            <g key={pt.record_date}>
              <line
                x1={pt.x}
                y1={h - pyBottom}
                x2={pt.x}
                y2={h - pyBottom + 3}
                stroke="rgba(125,125,125,0.3)"
                strokeWidth="0.8"
              />
              <text
                x={pt.x}
                y={h - pyBottom + 11}
                className="fill-[rgb(125,125,125)] text-[5.5px]"
                textAnchor="middle"
              >
                {label}
              </text>
            </g>
          );
        })}
      </svg>
    </div>
  );
}

export const ClientProgressPanel: React.FC<{ client: ProfessionalClient }> = ({ client }) => {
  const { t, locale } = usePortalI18n();
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

  const snapshots = client.client_shared_snapshots || [];
  const weightFromProgress = (records || []).filter(
    (record): record is typeof record & { weight_kg: number } => record.weight_kg != null && record.weight_kg > 0,
  );
  const weightFromSnapshots = snapshots
    .filter((snapshot): snapshot is typeof snapshot & { weight_kg: number } => snapshot.weight_kg != null && snapshot.weight_kg > 0)
    .map((snapshot) => ({ record_date: snapshot.snapshot_date, weight_kg: snapshot.weight_kg! }));

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

  // Combine records and snapshots for unified history
  const combinedHistory = useMemo(() => {
    const proRecords = (records || []).map((r) => ({
      ...r,
      source: 'professional' as const,
      date: r.record_date,
    }));

    const snapRecords = snapshots
      .filter((s) => (s.weight_kg != null && s.weight_kg > 0) || (s.waist_cm != null && s.waist_cm > 0))
      .map((s) => ({
        id: s.id,
        professional_client_id: s.professional_client_id,
        professional_id: client.professional_id,
        client_id: client.client_id,
        record_date: s.snapshot_date,
        weight_kg: s.weight_kg ?? null,
        body_fat_pct: null,
        waist_cm: s.waist_cm ?? null,
        hip_cm: null,
        chest_cm: null,
        arm_cm: null,
        thigh_cm: null,
        notes: null,
        source: 'client' as const,
        date: s.snapshot_date,
      }));

    const merged = [...proRecords, ...snapRecords];

    // Deduplicate by date (prefer proRecords if dates match)
    const map = new Map<string, typeof merged[number]>();
    merged.sort((a, b) => {
      if (a.record_date !== b.record_date) {
        return a.record_date.localeCompare(b.record_date);
      }
      return a.source === 'client' ? -1 : 1;
    });
    merged.forEach((item) => {
      map.set(item.record_date, item);
    });

    return Array.from(map.values()).sort((a, b) => b.record_date.localeCompare(a.record_date));
  }, [records, snapshots, client]);

  const latestWeight = useMemo(() => combinedHistory.find((r) => r.weight_kg != null)?.weight_kg ?? null, [combinedHistory]);
  const latestBodyFat = useMemo(() => combinedHistory.find((r) => r.body_fat_pct != null)?.body_fat_pct ?? null, [combinedHistory]);
  const latestWaist = useMemo(() => combinedHistory.find((r) => r.waist_cm != null)?.waist_cm ?? null, [combinedHistory]);
  const latestHip = useMemo(() => combinedHistory.find((r) => r.hip_cm != null)?.hip_cm ?? null, [combinedHistory]);

  const handleCreate = async () => {
    if (!form.weight_kg && !form.body_fat_pct && !form.waist_cm) {
      toast.error(t('components.clientdetail.clientprogresspanel.at_least_one_measurement_is_required'));
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
      toast.success(t('components.clientdetail.clientprogresspanel.progress_saved'));
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
      toast.error(t('components.clientdetail.clientprogresspanel.failed_to_save'));
    }
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between border-b border-border pb-3">
        <div className="flex items-center gap-2">
          <Scale className="h-4.5 w-4.5 text-primary" />
          <h3 className="portal-card-heading">
            {t('components.clientdetail.clientprogresspanel.progress_and_measurements')}
          </h3>
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="portal-action inline-flex items-center gap-1 rounded-xl bg-primary px-3 py-1.5 text-primary-foreground"
        >
          <Plus className="h-3.5 w-3.5" />
          {t('components.clientdetail.clientprogresspanel.record_entry')}
        </button>
      </div>

      {(latestWeight != null || latestBodyFat != null || latestWaist != null || latestHip != null) ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {latestWeight != null ? (
            <MetricCard
              label={t('components.clientdetail.clientprogresspanel.weight')}
              value={`${latestWeight} kg`}
              icon={<Weight className="h-3.5 w-3.5 text-primary" />}
            />
          ) : null}
          {latestBodyFat != null ? (
            <MetricCard
              label={t('components.clientdetail.clientprogresspanel.body_fat')}
              value={`${latestBodyFat}%`}
              icon={<TrendingDown className="h-3.5 w-3.5 text-sky-500 dark:text-sky-300" />}
            />
          ) : null}
          {latestWaist != null ? (
            <MetricCard
              label={t('components.clientdetail.clientprogresspanel.waist')}
              value={`${latestWaist} cm`}
            />
          ) : null}
          {latestHip != null ? (
            <MetricCard label={t('components.clientdetail.clientprogresspanel.hip')} value={`${latestHip} cm`} />
          ) : null}
        </div>
      ) : null}

      {weightRecords.length >= 2 ? (
        <WeightChart records={weightRecords} title={t('components.clientdetail.clientprogresspanel.weight_trend_kg')} />
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
                <label className="portal-label capitalize">
                  {progressFieldLabel(field, t)}
                </label>
                <input
                  type="number"
                  step="0.1"
                  value={form[field]}
                  onChange={(e) => setForm((prev) => ({ ...prev, [field]: e.target.value }))}
                  className="portal-input h-10 w-full rounded-xl px-3 outline-none focus:border-primary"
                />
              </div>
            ))}
          </div>
          <textarea
            value={form.notes}
            onChange={(e) => setForm((prev) => ({ ...prev, notes: e.target.value }))}
            placeholder={t('components.clientdetail.clientprogresspanel.measurement_notes_optional')}
            rows={2}
            className="portal-input mt-4 w-full rounded-xl px-3 py-3 outline-none focus:border-primary"
          />
          <div className="mt-4 flex justify-end gap-2">
            <button
              onClick={() => setShowForm(false)}
              className="portal-meta rounded-xl border border-border px-3 py-2 text-foreground hover:bg-accent"
            >
              {t('components.clientdetail.clientprogresspanel.cancel')}
            </button>
            <button
              onClick={handleCreate}
              disabled={createRecord.isPending}
              className="portal-action rounded-xl bg-primary px-3 py-2 text-primary-foreground disabled:opacity-50"
            >
              {t('components.clientdetail.clientprogresspanel.save_record')}
            </button>
          </div>
        </div>
      ) : null}

      {error ? (
        <div className="portal-panel portal-body rounded-[1.4rem] p-8 text-center text-muted-foreground">
          {t('components.clientdetail.clientprogresspanel.progress_records_are_not_available_right_now_snapshot_based_metrics_may_')}
        </div>
      ) : isLoading ? (
        <div className="space-y-3">
          {[1, 2].map((index) => (
            <div key={index} className="portal-panel h-14 rounded-[1.4rem] animate-pulse" />
          ))}
        </div>
      ) : combinedHistory.length === 0 ? (
        <div className="portal-panel portal-body rounded-[1.4rem] p-8 text-center text-muted-foreground">
          {t('components.clientdetail.clientprogresspanel.no_progress_records_have_been_saved_yet')}
        </div>
      ) : (
        <div className="portal-panel overflow-hidden rounded-[1.4rem]">
          <div className="overflow-x-auto">
            <table className="w-full border-collapse">
              <thead>
                <tr className="portal-label border-b border-border bg-background text-muted-foreground">
                  <th className="px-4 py-3 text-left">{t('components.clientdetail.clientprogresspanel.date')}</th>
                  <th className="px-3 py-3 text-right">{t('components.clientdetail.clientprogresspanel.weight')}</th>
                  <th className="px-3 py-3 text-right">{t('common.body_fat_short')}</th>
                  <th className="px-3 py-3 text-right">{t('components.clientdetail.clientprogresspanel.waist')}</th>
                  <th className="px-3 py-3 text-right">{t('components.clientdetail.clientprogresspanel.hip')}</th>
                  <th className="px-3 py-3 text-right">{t('components.clientdetail.clientprogresspanel.chest')}</th>
                  <th className="px-3 py-3 text-right">{t('components.clientdetail.clientprogresspanel.arm')}</th>
                  <th className="px-3 py-3 text-right">{t('components.clientdetail.clientprogresspanel.thigh')}</th>
                  <th className="w-12 px-4 py-3" />
                </tr>
              </thead>
              <tbody className="divide-y divide-border/40">
                {combinedHistory.map((record) => (
                  <tr key={record.id} className="hover:bg-accent/50">
                    <td className="px-4 py-3 portal-meta text-foreground col-span-1">
                      <div className="flex items-center gap-1.5">
                        <span>{formatPortalDate(record.record_date, locale)}</span>
                        {record.source === 'client' && (
                          <span className="text-[9px] bg-secondary/80 text-muted-foreground px-1.5 py-0.5 rounded font-extrabold uppercase tracking-wider">
                            App
                          </span>
                        )}
                        {record.source === 'professional' && (
                          <span className="text-[9px] bg-primary/10 text-primary px-1.5 py-0.5 rounded font-extrabold uppercase tracking-wider">
                            Pro
                          </span>
                        )}
                      </div>
                    </td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.weight_kg ?? '--'}</td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.body_fat_pct ?? '--'}</td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.waist_cm ?? '--'}</td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.hip_cm ?? '--'}</td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.chest_cm ?? '--'}</td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.arm_cm ?? '--'}</td>
                    <td className="px-3 py-3 text-right text-muted-foreground">{record.thigh_cm ?? '--'}</td>
                    <td className="px-4 py-3 text-right">
                      {record.source === 'professional' ? (
                        <button
                          onClick={async () => {
                            try {
                              await deleteRecord.mutateAsync(record.id);
                              toast.success(t('components.clientdetail.clientprogresspanel.record_deleted'));
                            } catch {
                              toast.error(t('components.clientdetail.clientprogresspanel.failed_to_delete'));
                            }
                          }}
                          className="portal-meta rounded-xl px-2 py-1 text-muted-foreground hover:bg-rose-500/10 hover:text-rose-500"
                        >
                          {t('components.clientdetail.clientprogresspanel.delete')}
                        </button>
                      ) : (
                        <span className="text-[10px] text-muted-foreground/60 italic pr-2">
                          {locale?.toLowerCase().startsWith('es') ? 'Sólo lectura' : 'Read-only'}
                        </span>
                      )}
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
      <p className="portal-kpi-label">{label}</p>
    </div>
    <p className="portal-metric mt-2 text-foreground">{value}</p>
    {note ? <p className="portal-meta mt-1">{note}</p> : null}
  </div>
);

function progressFieldLabel(
  field: 'weight_kg' | 'body_fat_pct' | 'waist_cm' | 'hip_cm' | 'chest_cm' | 'arm_cm' | 'thigh_cm',
  t: (key: PortalTranslationKey) => string,
) {
  switch (field) {
    case 'weight_kg':
      return t('components.clientdetail.clientprogresspanel.weight');
    case 'body_fat_pct':
      return t('components.clientdetail.clientprogresspanel.body_fat');
    case 'waist_cm':
      return t('components.clientdetail.clientprogresspanel.waist');
    case 'hip_cm':
      return t('components.clientdetail.clientprogresspanel.hip');
    case 'chest_cm':
      return t('components.clientdetail.clientprogresspanel.chest');
    case 'arm_cm':
      return t('components.clientdetail.clientprogresspanel.arm');
    case 'thigh_cm':
      return t('components.clientdetail.clientprogresspanel.thigh');
  }
}
