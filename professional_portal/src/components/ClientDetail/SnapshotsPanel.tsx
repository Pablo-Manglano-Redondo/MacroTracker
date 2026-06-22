import React, { useState } from 'react';
import type { ProfessionalClient } from '../../types/database.types';
import { ChevronDown, ChevronUp, Calendar, Info } from 'lucide-react';
import { usePortalI18n } from '../../lib/portal-i18n';

const INITIAL_SHOWN = 5;

interface SnapshotsPanelProps {
  client: ProfessionalClient;
}

export const SnapshotsPanel: React.FC<SnapshotsPanelProps> = ({ client }) => {
  const { t } = usePortalI18n();
  const [showAll, setShowAll] = useState(false);
  const snapshots = client.client_shared_snapshots || [];

  const sortedSnapshots = [...snapshots].sort((a, b) =>
    b.snapshot_date.localeCompare(a.snapshot_date),
  );
  const displayedSnapshots = showAll
    ? sortedSnapshots
    : sortedSnapshots.slice(0, INITIAL_SHOWN);

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
    if (percent >= 90 && percent <= 110) {
      return 'text-emerald-600 dark:text-emerald-400';
    }
    if (percent >= 75 && percent <= 125) {
      return 'text-amber-600 dark:text-amber-400';
    }
    return 'text-rose-600 dark:text-rose-400';
  };

  const renderBar = (
    label: string,
    actual: number,
    target: number,
    unit: string,
  ) => {
    const percent =
      target > 0 ? Math.min(Math.round((actual / target) * 100), 100) : 0;
    const rawPercent = target > 0 ? Math.round((actual / target) * 100) : 0;

    return (
      <div className="space-y-1">
        <div className="flex items-center justify-between">
          <span className="text-[11px] text-muted-foreground">{label}</span>
          <span
            className={`text-[11px] font-medium ${getAdherenceText(actual, target)}`}
          >
            {Math.round(actual)}/{Math.round(target)} {unit}
            <span className="ml-1 opacity-70">({rawPercent}%)</span>
          </span>
        </div>
        <div className="h-1.5 w-full overflow-hidden rounded-full bg-secondary">
          <div
            className={`h-full rounded-full transition-all duration-500 ${getAdherenceColor(actual, target)}`}
            style={{ width: `${percent}%` }}
          />
        </div>
      </div>
    );
  };

  return (
    <div className="glass-card flex flex-col rounded-2xl border border-border/50">
      <div className="flex items-center gap-2.5 border-b border-border/50 bg-card/10 px-5 py-4">
        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10">
          <Calendar className="h-4 w-4 text-primary" />
        </div>
        <div>
          <p className="text-sm font-bold leading-none">{t('components.clientdetail.snapshotspanel.snapshots')}</p>
          <p className="mt-0.5 text-[10px] font-semibold text-muted-foreground">
            {t('components.clientdetail.snapshotspanel.recorded', { snapshots_length: snapshots.length })}
          </p>
        </div>
      </div>

      <div className="m-3.5 flex items-start gap-2.5 rounded-xl border border-emerald-500/20 bg-emerald-500/5 p-3.5 shadow-sm">
        <Info className="mt-0.5 h-4 w-4 shrink-0 text-emerald-500" />
        <div className="space-y-0.5">
          <p className="text-xs font-bold text-emerald-600 dark:text-emerald-400">
            {t('components.clientdetail.snapshotspanel.sync_note')}
          </p>
          <p className="text-[10px] font-medium leading-relaxed text-emerald-800/80 dark:text-emerald-300/80">
            {t('components.clientdetail.snapshotspanel.daily_snapshots_and_weights_are_imported_directly_from_the_client_s_loca')}
          </p>
        </div>
      </div>

      <div className="max-h-[400px] flex-1 overflow-y-auto [scrollbar-color:rgba(156,163,175,0.15)_transparent] [scrollbar-width:thin]">
        {snapshots.length === 0 ? (
          <div className="px-5 py-10 text-center">
            <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-xl bg-muted/10">
              <Calendar className="h-5 w-5 text-muted-foreground/60" />
            </div>
            <p className="text-xs font-bold text-foreground">{t('components.clientdetail.snapshotspanel.no_snapshots_yet')}</p>
            <p className="mt-1 text-[10px] font-semibold text-muted-foreground">
              {t('components.clientdetail.snapshotspanel.shared_client_snapshot_data_will_appear_here')}
            </p>
          </div>
        ) : (
          <div className="space-y-2 p-3">
            {displayedSnapshots.map((snap) => (
              <div
                key={snap.id}
                className="rounded-xl border border-transparent p-3.5 transition-all duration-200 hover:border-border/30 hover:bg-secondary/45"
              >
                <div className="mb-3 flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div className="flex h-6 w-6 items-center justify-center rounded-lg bg-secondary">
                      <Calendar className="h-3 w-3 text-muted-foreground" />
                    </div>
                    <span className="text-xs font-extrabold text-foreground">
                      {snap.snapshot_date}
                    </span>
                  </div>
                </div>

                <div className="grid grid-cols-1 gap-y-2.5 pl-8">
                  {renderBar(t('common.kcal'), snap.kcal_actual, snap.kcal_target, t('common.kcal_unit'))}
                  {renderBar(
                    t('components.clientdetail.snapshotspanel.protein'),
                    snap.protein_actual,
                    snap.protein_target,
                    'g',
                  )}
                  {renderBar(t('components.clientdetail.snapshotspanel.carbs'), snap.carbs_actual, snap.carbs_target, 'g')}
                  {renderBar(t('components.clientdetail.snapshotspanel.fat'), snap.fat_actual, snap.fat_target, 'g')}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {sortedSnapshots.length > INITIAL_SHOWN && (
        <div className="border-t border-border/50 bg-card/5 px-5 py-2.5">
          <button
            onClick={() => setShowAll(!showAll)}
            className="flex items-center gap-1 text-xs font-bold text-muted-foreground transition-colors hover:text-foreground"
          >
            {showAll ? (
              <>
                <ChevronUp className="h-3 w-3" /> {t('components.clientdetail.snapshotspanel.show_less')}
              </>
            ) : (
              <>
                <ChevronDown className="h-3 w-3" />{' '}
                {t('components.clientdetail.snapshotspanel.show_more', { length_initial_shown: sortedSnapshots.length - INITIAL_SHOWN })}
              </>
            )}
          </button>
        </div>
      )}
    </div>
  );
};
