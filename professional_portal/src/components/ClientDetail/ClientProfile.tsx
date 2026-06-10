import React, { useState } from 'react';
import type { ProfessionalClient } from '../../types/database.types';
import { supabase } from '../../lib/supabase';
import { toast } from 'sonner';
import { useClientProgressSummary } from '../../hooks/queries/useClientProgress';
import { usePlans } from '../../hooks/queries/usePlans';
import { Mail, Pencil, Check, X, Target, Flame, Dumbbell, Wheat, Droplet, TrendingUp, Hash } from 'lucide-react';

interface ClientProfileProps {
  client: ProfessionalClient;
}

export const ClientProfile: React.FC<ClientProfileProps> = ({ client }) => {
  const { data: summary } = useClientProgressSummary(client.client_id);
  const { data: plans } = usePlans(client.client_id);
  const [editing, setEditing] = useState(false);
  const [name, setName] = useState(client.display_name || '');
  const [saving, setSaving] = useState(false);

  const activePlan = (plans || []).find(p => p.status === 'active');
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
    if (error) { toast.error('Failed to update name'); return; }
    toast.success('Display name updated');
    setEditing(false);
  };

  const calcAdherence = (actual: number, target: number) =>
    target > 0 ? Math.round((actual / target) * 100) : null;

  return (
    <div className="space-y-4">
      {/* Identity */}
      <div className="rounded-xl border bg-card p-5 space-y-4 card-elevated">
        <h3 className="text-sm font-bold flex items-center gap-2"><Mail className="w-4 h-4 text-muted-foreground" /> Profile</h3>
        <div className="space-y-3 text-xs">
          <div className="flex items-center justify-between">
            <span className="text-muted-foreground">Display name</span>
            {editing ? (
              <div className="flex items-center gap-1">
                <input value={name} onChange={e => setName(e.target.value)}
                  className="px-2 py-1 text-xs rounded border bg-background focus:outline-none focus:ring-1 focus:ring-primary w-36"
                  autoFocus onKeyDown={e => { if (e.key === 'Enter') handleSave(); if (e.key === 'Escape') setEditing(false); }} />
                <button onClick={handleSave} disabled={saving} className="p-1 text-primary hover:bg-primary/10 rounded">
                  <Check className="w-3 h-3" />
                </button>
                <button onClick={() => { setEditing(false); setName(client.display_name || ''); }} className="p-1 text-muted-foreground hover:bg-secondary rounded">
                  <X className="w-3 h-3" />
                </button>
              </div>
            ) : (
              <div className="flex items-center gap-1">
                <span className="font-medium">{client.display_name || <span className="text-muted-foreground italic">No display name</span>}</span>
                <button onClick={() => setEditing(true)} className="p-1 text-muted-foreground hover:text-primary hover:bg-primary/10 rounded transition-colors">
                  <Pencil className="w-3 h-3" />
                </button>
              </div>
            )}
          </div>
          <div className="flex items-center justify-between">
            <span className="text-muted-foreground">Client ID</span>
            <span className="font-mono text-[10px]">{client.client_id}</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-muted-foreground">Connected</span>
            <span className="font-medium">{new Date(client.connected_at).toLocaleDateString()}</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-muted-foreground">Sharing mode</span>
            <span className="font-medium capitalize">{client.sharing_mode}</span>
          </div>
        </div>
      </div>

      {/* Active plan */}
      <div className="rounded-xl border bg-card p-5 space-y-3 card-elevated">
        <h4 className="text-sm font-bold flex items-center gap-2"><Target className="w-4 h-4 text-primary" /> Active Plan</h4>
        {activePlan ? (
          <div className="space-y-2 text-xs">
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">Plan</span>
              <span className="font-medium">{activePlan.name}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">Status</span>
              <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-medium bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 capitalize">{activePlan.status}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-muted-foreground">Kcal goal</span>
              <span className="font-medium">{activePlan.meals?.reduce((s, m) => s + (m.kcal || 0), 0) || '-'} kcal</span>
            </div>
            {activePlan.objective && (
              <div>
                <span className="text-muted-foreground">Objective</span>
                <p className="font-medium mt-0.5 text-[11px]">{activePlan.objective}</p>
              </div>
            )}
          </div>
        ) : (
          <p className="text-xs text-muted-foreground text-center py-3">No active plan</p>
        )}
      </div>

      {/* Latest adherence */}
      {lastSnapshot && (
        <div className="rounded-xl border bg-card p-5 space-y-3 card-elevated">
          <h4 className="text-sm font-bold flex items-center gap-2"><TrendingUp className="w-4 h-4 text-primary" /> Latest Adherence</h4>
          <div className="grid grid-cols-2 gap-3">
            {[
              { label: 'Kcal', actual: lastSnapshot.kcal_actual, target: lastSnapshot.kcal_target, icon: Flame, color: 'text-orange-500' },
              { label: 'Protein', actual: lastSnapshot.protein_actual, target: lastSnapshot.protein_target, icon: Dumbbell, color: 'text-blue-500' },
              { label: 'Carbs', actual: lastSnapshot.carbs_actual, target: lastSnapshot.carbs_target, icon: Wheat, color: 'text-amber-500' },
              { label: 'Fat', actual: lastSnapshot.fat_actual, target: lastSnapshot.fat_target, icon: Droplet, color: 'text-rose-500' },
            ].map(m => {
              const pct = calcAdherence(m.actual, m.target);
              return (
                <div key={m.label} className="rounded-lg bg-secondary/40 p-3">
                  <div className="flex items-center gap-1.5 text-[11px] text-muted-foreground">
                    <m.icon className={`w-3 h-3 ${m.color}`} />
                    {m.label}
                  </div>
                  <p className="text-lg font-bold mt-1">{pct != null ? `${pct}%` : '-'}</p>
                  <p className="text-[10px] text-muted-foreground">{m.actual}/{m.target} {m.label === 'Kcal' ? 'kcal' : 'g'}</p>
                </div>
              );
            })}
          </div>
          <p className="text-[10px] text-muted-foreground text-right">{new Date(lastSnapshot.snapshot_date).toLocaleDateString()}</p>
        </div>
      )}

      {/* Progress summary */}
      <div className="rounded-xl border bg-card p-5 space-y-3 card-elevated">
        <h4 className="text-sm font-bold flex items-center gap-2"><Hash className="w-4 h-4 text-primary" /> Progress Summary</h4>
        <div className="grid grid-cols-2 gap-3 text-xs">
          <div className="rounded-lg bg-secondary/40 p-3">
            <span className="text-muted-foreground text-[11px]">Weight</span>
            <p className="text-lg font-bold mt-0.5">{summary?.latest_weight != null ? `${summary.latest_weight} kg` : '-'}</p>
            {summary?.weight_change_30d != null && (
              <p className={`text-[10px] mt-0.5 ${summary.weight_change_30d < 0 ? 'text-emerald-500' : 'text-rose-500'}`}>
                {summary.weight_change_30d > 0 ? '+' : ''}{summary.weight_change_30d} kg (30d)
              </p>
            )}
          </div>
          <div className="rounded-lg bg-secondary/40 p-3">
            <span className="text-muted-foreground text-[11px]">Body fat</span>
            <p className="text-lg font-bold mt-0.5">{summary?.latest_body_fat != null ? `${summary.latest_body_fat}%` : '-'}</p>
          </div>
          <div className="rounded-lg bg-secondary/40 p-3">
            <span className="text-muted-foreground text-[11px]">Check-ins</span>
            <p className="text-lg font-bold mt-0.5">{summary?.checkin_count ?? 0}</p>
            <p className="text-[10px] text-muted-foreground mt-0.5">
              {summary?.last_checkin ? `Last: ${new Date(summary.last_checkin).toLocaleDateString()}` : 'No check-ins'}
            </p>
          </div>
          <div className="rounded-lg bg-secondary/40 p-3">
            <span className="text-muted-foreground text-[11px]">Notes / Recipes</span>
            <p className="text-lg font-bold mt-0.5">{summary?.note_count ?? 0} / {summary?.recipe_count ?? 0}</p>
            <p className="text-[10px] text-muted-foreground mt-0.5">Notes · Proposed recipes</p>
          </div>
        </div>
      </div>
    </div>
  );
};
