import React, { useState } from 'react';
import type { ProfessionalClient } from '../../types/database.types';
import { ChevronDown, ChevronUp, Calendar, Info } from 'lucide-react';

const INITIAL_SHOWN = 5;

interface SnapshotsPanelProps {
  client: ProfessionalClient;
}

export const SnapshotsPanel: React.FC<SnapshotsPanelProps> = ({ client }) => {
  const [showAll, setShowAll] = useState(false);
  const snapshots = client.client_shared_snapshots || [];

  const sortedSnapshots = [...snapshots].sort((a, b) => b.snapshot_date.localeCompare(a.snapshot_date));
  const displayedSnapshots = showAll ? sortedSnapshots : sortedSnapshots.slice(0, INITIAL_SHOWN);

  const getAdherenceColor = (actual: number, target: number) => {
    if (!target || target === 0) return 'bg-zinc-200 dark:bg-zinc-700';
    const percent = (actual / target) * 100;
    if (percent >= 90 && percent <= 110) return 'bg-emerald-500';
    if (percent >= 75 && percent <= 125) return 'bg-amber-500';
    return 'bg-rose-500';
  };

  const getAdherenceText = (actual: number, target: number) => {
    if (!target || target === 0) return 'text-muted-foreground';
    const percent = (actual / target) * 100;
    if (percent >= 90 && percent <= 110) return 'text-emerald-600 dark:text-emerald-400';
    if (percent >= 75 && percent <= 125) return 'text-amber-600 dark:text-amber-400';
    return 'text-rose-600 dark:text-rose-400';
  };

  const renderBar = (label: string, actual: number, target: number, unit: string) => {
    const percent = target > 0 ? Math.min(Math.round((actual / target) * 100), 100) : 0;
    const rawPercent = target > 0 ? Math.round((actual / target) * 100) : 0;

    return (
      <div className="space-y-1">
        <div className="flex justify-between items-center">
          <span className="text-[11px] text-muted-foreground">{label}</span>
          <span className={`text-[11px] font-medium ${getAdherenceText(actual, target)}`}>
            {Math.round(actual)}/{Math.round(target)} {unit}
            <span className="ml-1 opacity-70">({rawPercent}%)</span>
          </span>
        </div>
        <div className="h-1.5 w-full bg-secondary rounded-full overflow-hidden">
          <div
            className={`h-full rounded-full transition-all duration-500 ${getAdherenceColor(actual, target)}`}
            style={{ width: `${percent}%` }}
          />
        </div>
      </div>
    );
  };

  return (
    <div className="rounded-xl border bg-card card-elevated flex flex-col">
      {/* Header */}
      <div className="px-5 py-4 border-b flex items-center gap-2.5">
        <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
          <Calendar className="w-4 h-4 text-primary" />
        </div>
        <div>
          <p className="text-sm font-semibold leading-none">Snapshots</p>
          <p className="text-[11px] text-muted-foreground mt-0.5">
            {snapshots.length} recorded
          </p>
        </div>
      </div>

      {/* Sync Warning Card */}
      <div className="m-3 p-3 bg-blue-50/50 dark:bg-blue-950/20 border border-blue-100 dark:border-blue-900/30 rounded-lg flex items-start gap-2.5">
        <Info className="w-4 h-4 text-blue-500 shrink-0 mt-0.5" />
        <div className="space-y-0.5">
          <p className="text-xs font-semibold text-blue-800 dark:text-blue-300">Nota de Sincronización</p>
          <p className="text-[11px] text-blue-700/80 dark:text-blue-400/80 leading-relaxed">
            Los snapshots diarios y pesos se importan directamente desde la app local-first del paciente. Para garantizar la integridad del diario del cliente, la edición de snapshots está deshabilitada en la web.
          </p>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto max-h-[400px] [scrollbar-width:thin] [scrollbar-color:rgb(200_200_200/0.3)_transparent] dark:[scrollbar-color:rgb(60_60_60/0.3)_transparent]">
        {snapshots.length === 0 ? (
          <div className="px-5 py-10 text-center">
            <div className="w-12 h-12 rounded-full bg-muted/50 flex items-center justify-center mx-auto mb-3">
              <Calendar className="w-5 h-5 text-muted-foreground/60" />
            </div>
            <p className="text-sm text-muted-foreground">No snapshots yet</p>
            <p className="text-xs text-muted-foreground/70 mt-1">
              Client shared data will appear here
            </p>
          </div>
        ) : (
          <div className="p-3 space-y-2">
            {displayedSnapshots.map((snap) => (
              <div
                key={snap.id}
                className="p-3 rounded-lg hover:bg-secondary/50 transition-colors"
              >
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <div className="w-6 h-6 rounded-full bg-secondary flex items-center justify-center">
                      <Calendar className="w-3 h-3 text-muted-foreground" />
                    </div>
                    <span className="text-xs font-medium">{snap.snapshot_date}</span>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-x-4 gap-y-2.5 pl-8">
                  {renderBar('Kcal', snap.kcal_actual, snap.kcal_target, 'kcal')}
                  {renderBar('Protein', snap.protein_actual, snap.protein_target, 'g')}
                  {renderBar('Carbs', snap.carbs_actual, snap.carbs_target, 'g')}
                  {renderBar('Fat', snap.fat_actual, snap.fat_target, 'g')}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Show more/less */}
      {sortedSnapshots.length > INITIAL_SHOWN && (
        <div className="px-5 py-2.5 border-t">
          <button
            onClick={() => setShowAll(!showAll)}
            className="text-xs text-muted-foreground hover:text-foreground transition-colors flex items-center gap-1"
          >
            {showAll ? (
              <><ChevronUp className="w-3 h-3" /> Show less</>
            ) : (
              <><ChevronDown className="w-3 h-3" /> Show {sortedSnapshots.length - INITIAL_SHOWN} more</>
            )}
          </button>
        </div>
      )}
    </div>
  );
};
