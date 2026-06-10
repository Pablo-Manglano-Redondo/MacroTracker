import React, { useState, useMemo } from 'react';
import type { ProfessionalClient } from '../../types/database.types';
import { useClientProgress } from '../../hooks/queries/useClientProgress';
import { useCreateProgress, useDeleteProgress } from '../../hooks/mutations/useClientProgress';
import { Scale, Plus, Trash2, TrendingDown, Weight } from 'lucide-react';
import { toast } from 'sonner';

function WeightChart({ records }: { records: { record_date: string; weight_kg: number }[] }) {
  const sorted = [...records].sort((a, b) => a.record_date.localeCompare(b.record_date));
  const minW = Math.min(...sorted.map(r => r.weight_kg));
  const maxW = Math.max(...sorted.map(r => r.weight_kg));
  const range = Math.max(maxW - minW, 1);
  const w = 280, h = 100, px = 35, py = 5;

  const points = sorted.map((r, i) => {
    const x = px + (i / Math.max(sorted.length - 1, 1)) * (w - px * 2);
    const y = h - py - ((r.weight_kg - minW) / range) * (h - py * 2);
    return { x, y, ...r };
  });

  const pathD = points.map((p, i) => `${i === 0 ? 'M' : 'L'}${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(' ');
  const midY = h / 2;

  return (
    <div className="rounded-xl border bg-card p-4 card-elevated">
      <p className="text-[10px] font-medium text-muted-foreground mb-2">Weight trend</p>
      <svg viewBox={`0 0 ${w} ${h}`} className="w-full h-auto" preserveAspectRatio="xMidYMid meet">
        <line x1={px} y1={midY} x2={w - px} y2={midY} stroke="currentColor" className="text-border" strokeWidth="0.5" />
        <text x={px - 4} y={py + 8} className="fill-muted-foreground" fontSize="8" textAnchor="end">{maxW.toFixed(1)}</text>
        <text x={px - 4} y={h - py} className="fill-muted-foreground" fontSize="8" textAnchor="end">{minW.toFixed(1)}</text>
        <path d={pathD} fill="none" stroke="hsl(var(--primary))" strokeWidth="1.5" strokeLinejoin="round" strokeLinecap="round" />
        {points.filter((_, i) => i === 0 || i === points.length - 1).map(p => (
          <circle key={p.record_date} cx={p.x} cy={p.y} r="2.5" fill="hsl(var(--primary))" />
        ))}
        {(() => {
          const first = points[0];
          if (!first) return null;
          return <text x={first.x} y={h - 2} className="fill-muted-foreground" fontSize="7" textAnchor="middle">
            {new Date(first.record_date).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}
          </text>;
        })()}
        {(() => {
          const last = points.length > 1 ? points[points.length - 1] : null;
          if (!last) return null;
          return <text x={last.x} y={h - 2} className="fill-muted-foreground" fontSize="7" textAnchor="middle">
            {new Date(last.record_date).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}
          </text>;
        })()}
      </svg>
    </div>
  );
}

export const ClientProgressPanel: React.FC<{ client: ProfessionalClient }> = ({ client }) => {
  const { data: records, isLoading } = useClientProgress(client.id);
  const createRecord = useCreateProgress(client.id);
  const deleteRecord = useDeleteProgress(client.id);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ weight_kg: '', body_fat_pct: '', waist_cm: '', hip_cm: '', chest_cm: '', arm_cm: '', thigh_cm: '', notes: '' });

  const latest = records?.[0];
  const sorted = [...(records || [])].sort((a, b) => new Date(b.record_date).getTime() - new Date(a.record_date).getTime());
  const snapshots = client.client_shared_snapshots || [];
  const weightFromProgress = (records || []).filter((r): r is typeof r & { weight_kg: number } => r.weight_kg != null && r.weight_kg > 0);
  const weightFromSnapshots = snapshots
    .filter((s): s is typeof s & { weight_kg: number } => s.weight_kg != null && s.weight_kg > 0)
    .map(s => ({ record_date: s.snapshot_date, weight_kg: s.weight_kg! }));
  const latestWaistFromSnapshot = snapshots
    .filter((s): s is typeof s & { waist_cm: number } => s.waist_cm != null && s.waist_cm > 0)
    .sort((a, b) => b.snapshot_date.localeCompare(a.snapshot_date))[0]?.waist_cm;
  const weightRecords = useMemo(() => {
    const merged = [...weightFromProgress, ...weightFromSnapshots];
    merged.sort((a, b) => a.record_date.localeCompare(b.record_date));
    const deduped: typeof merged = [];
    for (const r of merged) {
      const last = deduped.length > 0 ? deduped[deduped.length - 1] : null;
      if (!last || last.record_date !== r.record_date) deduped.push(r);
    }
    return deduped;
  }, [weightFromProgress.length, weightFromSnapshots.length, client.client_shared_snapshots?.length]);

  const handleCreate = async () => {
    if (!form.weight_kg && !form.body_fat_pct && !form.waist_cm) { toast.error('At least one measurement required'); return; }
    try {
      await createRecord.mutateAsync({
        professional_client_id: client.id,
        professional_id: client.professional_id,
        client_id: client.client_id,
        record_date: new Date().toISOString().split('T')[0],
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
      toast.success('Progress saved');
      setShowForm(false);
      setForm({ weight_kg: '', body_fat_pct: '', waist_cm: '', hip_cm: '', chest_cm: '', arm_cm: '', thigh_cm: '', notes: '' });
    } catch { toast.error('Failed to save'); }
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h4 className="text-sm font-bold flex items-center gap-1.5">
          <Scale className="w-4 h-4 text-primary" />
          Progress
        </h4>
        <button onClick={() => setShowForm(true)}
          className="flex items-center gap-1 px-2.5 py-1 text-[11px] rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors">
          <Plus className="w-3 h-3" /> Record
        </button>
      </div>

      {latest && (
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          {latest.weight_kg != null && (
            <div className="rounded-xl bg-card border p-3 card-elevated">
              <p className="text-[10px] text-muted-foreground flex items-center gap-1"><Weight className="w-3 h-3" /> Weight</p>
              <p className="text-lg font-bold">{latest.weight_kg} <span className="text-xs font-normal text-muted-foreground">kg</span></p>
            </div>
          )}
          {latest.body_fat_pct != null && (
            <div className="rounded-xl bg-card border p-3 card-elevated">
              <p className="text-[10px] text-muted-foreground flex items-center gap-1"><TrendingDown className="w-3 h-3" /> Body Fat</p>
              <p className="text-lg font-bold">{latest.body_fat_pct}<span className="text-xs font-normal text-muted-foreground">%</span></p>
            </div>
          )}
          {(latest?.waist_cm ?? latestWaistFromSnapshot) != null && (
            <div className="rounded-xl bg-card border p-3 card-elevated">
              <p className="text-[10px] text-muted-foreground">Waist</p>
              <p className="text-lg font-bold">{latest?.waist_cm ?? latestWaistFromSnapshot} <span className="text-xs font-normal text-muted-foreground">cm</span></p>
              {latest?.waist_cm == null && <p className="text-[9px] text-muted-foreground/60 mt-0.5">from client</p>}
            </div>
          )}
          {latest.hip_cm != null && (
            <div className="rounded-xl bg-card border p-3 card-elevated">
              <p className="text-[10px] text-muted-foreground">Hip</p>
              <p className="text-lg font-bold">{latest.hip_cm} <span className="text-xs font-normal text-muted-foreground">cm</span></p>
            </div>
          )}
        </div>
      )}

      {weightRecords.length >= 2 && <WeightChart records={weightRecords} />}

      {showForm && (
        <div className="rounded-xl border bg-card p-4 space-y-3 card-elevated">
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
            {(['weight_kg', 'body_fat_pct', 'waist_cm', 'hip_cm', 'chest_cm', 'arm_cm', 'thigh_cm'] as const).map(f => (
              <div key={f}>
                <label className="text-[10px] font-medium text-muted-foreground capitalize">{f.replace('_', ' ')}</label>
                <input type="number" step="0.1" value={form[f]} onChange={e => setForm(p => ({...p, [f]: e.target.value}))}
                  className="w-full mt-0.5 px-2.5 py-1 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
              </div>
            ))}
          </div>
          <textarea value={form.notes} onChange={e => setForm(p => ({...p, notes: e.target.value}))} placeholder="Notes..." rows={2}
            className="w-full px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
          <div className="flex justify-end gap-2">
            <button onClick={() => setShowForm(false)}
              className="px-3 py-1 text-[11px] rounded-lg border hover:bg-secondary transition-colors">Cancel</button>
            <button onClick={handleCreate} disabled={createRecord.isPending}
              className="px-3 py-1 text-[11px] rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-50">
              Save Record
            </button>
          </div>
        </div>
      )}

      {isLoading ? (
        <div className="space-y-2">{[1,2].map(i => <div key={i} className="h-12 rounded-xl bg-muted/30 animate-pulse" />)}</div>
      ) : sorted.length === 0 ? (
        <p className="text-xs text-muted-foreground text-center py-6">No progress records yet</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-xs">
            <thead>
              <tr className="text-muted-foreground border-b">
                <th className="text-left py-2 px-2 font-medium">Date</th>
                <th className="text-right py-2 px-2 font-medium">Weight</th>
                <th className="text-right py-2 px-2 font-medium">BF%</th>
                <th className="text-right py-2 px-2 font-medium">Waist</th>
                <th className="text-right py-2 px-2 font-medium">Hip</th>
                <th className="text-right py-2 px-2 font-medium">Chest</th>
                <th className="text-right py-2 px-2 font-medium">Arm</th>
                <th className="text-right py-2 px-2 font-medium">Thigh</th>
                <th className="w-8" />
              </tr>
            </thead>
            <tbody>
              {sorted.map(r => (
                <tr key={r.id} className="border-b last:border-0 hover:bg-muted/20 transition-colors">
                  <td className="py-2 px-2 text-muted-foreground">{new Date(r.record_date).toLocaleDateString()}</td>
                  <td className="text-right py-2 px-2 font-medium">{r.weight_kg ?? '—'}</td>
                  <td className="text-right py-2 px-2">{r.body_fat_pct ?? '—'}</td>
                  <td className="text-right py-2 px-2">{r.waist_cm ?? '—'}</td>
                  <td className="text-right py-2 px-2">{r.hip_cm ?? '—'}</td>
                  <td className="text-right py-2 px-2">{r.chest_cm ?? '—'}</td>
                  <td className="text-right py-2 px-2">{r.arm_cm ?? '—'}</td>
                  <td className="text-right py-2 px-2">{r.thigh_cm ?? '—'}</td>
                  <td className="py-2">
                    <button onClick={() => deleteRecord.mutate(r.id)}
                      className="p-1 rounded-md text-muted-foreground hover:text-red-500 transition-colors">
                      <Trash2 className="w-3 h-3" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};
