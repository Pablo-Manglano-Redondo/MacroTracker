import React, { useState } from 'react';
import type { ProfessionalClient } from '../../types/database.types';
import { ChevronDown, ChevronUp, Calendar } from 'lucide-react';
import { usePortalI18n } from '../../lib/portal-i18n';

const INITIAL_SHOWN = 5;

interface SnapshotsPanelProps {
  client: ProfessionalClient;
}

export const SnapshotsPanel: React.FC<SnapshotsPanelProps> = ({ client }) => {
  const { t, locale } = usePortalI18n();
  const [showAll, setShowAll] = useState(false);
  const [expandedSnaps, setExpandedSnaps] = useState<Record<string, boolean>>({});
  const snapshots = client.client_shared_snapshots || [];

  const sortedSnapshots = [...snapshots].sort((a, b) =>
    b.snapshot_date.localeCompare(a.snapshot_date),
  );
  const displayedSnapshots = showAll
    ? sortedSnapshots
    : sortedSnapshots.slice(0, INITIAL_SHOWN);

  const toggleSnap = (snapId: string) => {
    setExpandedSnaps((prev) => ({
      ...prev,
      [snapId]: !prev[snapId],
    }));
  };

  // Get last 7 days for adherence calendar
  const last7Days = React.useMemo(() => {
    const list = [];
    const today = new Date();
    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(today.getDate() - i);
      const yyyy = d.getFullYear();
      const mm = String(d.getMonth() + 1).padStart(2, '0');
      const dd = String(d.getDate()).padStart(2, '0');
      const dateStr = `${yyyy}-${mm}-${dd}`;

      // Find matching snapshot
      const match = snapshots.find((s) => s.snapshot_date === dateStr);

      // Calculate adherence level
      let adherenceColor = 'bg-secondary/40 text-muted-foreground/60 border-border/40';
      let titleTooltip = 'Sin registros';
      if (match) {
        const kcalTarget = match.kcal_target;
        const kcalActual = match.kcal_actual;
        if (kcalTarget > 0) {
          const percent = (kcalActual / kcalTarget) * 100;
          if (percent >= 90 && percent <= 110) {
            adherenceColor = 'bg-emerald-500/10 text-emerald-600 dark:text-[#72de98] border-emerald-500/30';
            titleTooltip = `Óptimo: ${Math.round(percent)}%`;
          } else if (percent >= 75 && percent <= 125) {
            adherenceColor = 'bg-amber-500/10 text-amber-600 dark:text-[#fcd34d] border-amber-500/30';
            titleTooltip = `Desviación leve: ${Math.round(percent)}%`;
          } else {
            adherenceColor = 'bg-rose-500/10 text-rose-600 dark:text-[#fca5a5] border-rose-500/30';
            titleTooltip = `Desviación fuerte: ${Math.round(percent)}%`;
          }
        }
      }

      const dayName = d.toLocaleDateString(locale ?? 'es', { weekday: 'short' });
      const shortDayName = dayName.slice(0, 3).toUpperCase();

      list.push({
        dateStr,
        dayNum: d.getDate(),
        dayName: shortDayName,
        adherenceColor,
        titleTooltip,
      });
    }
    return list;
  }, [snapshots, locale]);

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
      <div className="space-y-1.5">
        <div className="flex items-center justify-between">
          <span className="portal-meta">{label}</span>
          <span
            className={`portal-meta ${getAdherenceText(actual, target)}`}
          >
            {Math.round(actual)}/{Math.round(target)} {unit}
            <span className="ml-1 opacity-70">({rawPercent}%)</span>
          </span>
        </div>
        <div className="h-2 w-full overflow-hidden rounded-full bg-secondary">
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
      <div className="flex items-center gap-3 border-b border-border/50 bg-card/10 px-5 py-4">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/10">
          <Calendar className="h-5 w-5 text-primary" />
        </div>
        <div>
          <p className="portal-card-heading">{t('components.clientdetail.snapshotspanel.snapshots')}</p>
          <p className="portal-meta mt-0.5">
            {t('components.clientdetail.snapshotspanel.recorded', { snapshots_length: snapshots.length })}
          </p>
        </div>
      </div>

      {/* Weekly Adherence Calendar */}
      {snapshots.length > 0 && (
        <div className="border-b border-border/50 bg-secondary/10 px-5 py-3">
          <p className="portal-label text-[10px] text-muted-foreground/80 mb-2">Adherencia última semana</p>
          <div className="grid grid-cols-7 gap-2">
            {last7Days.map((day) => (
              <div
                key={day.dateStr}
                title={`${day.dateStr}: ${day.titleTooltip}`}
                className={`flex flex-col items-center rounded-xl p-1.5 border transition-all duration-200 ${day.adherenceColor}`}
              >
                <span className="text-[9px] font-extrabold opacity-75">{day.dayName}</span>
                <span className="text-xs font-black mt-0.5">{day.dayNum}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="max-h-[450px] flex-1 overflow-y-auto [scrollbar-color:rgba(156,163,175,0.15)_transparent] [scrollbar-width:thin]">
        {snapshots.length === 0 ? (
          <div className="px-5 py-10 text-center">
            <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-xl bg-muted/10">
              <Calendar className="h-5 w-5 text-muted-foreground/60" />
            </div>
            <p className="portal-card-heading">{t('components.clientdetail.snapshotspanel.no_snapshots_yet')}</p>
            <p className="portal-meta mt-1">
              {t('components.clientdetail.snapshotspanel.shared_client_snapshot_data_will_appear_here')}
            </p>
          </div>
        ) : (
          <div className="space-y-2 p-3">
            {displayedSnapshots.map((snap) => {
              const isEmpty =
                snap.kcal_actual === 0 &&
                snap.protein_actual === 0 &&
                snap.carbs_actual === 0 &&
                snap.fat_actual === 0;
              const isExpanded = expandedSnaps[snap.id] ?? !isEmpty;

              if (isEmpty && !isExpanded) {
                return (
                  <div
                    key={snap.id}
                    onClick={() => toggleSnap(snap.id)}
                    className="flex items-center justify-between rounded-xl border border-border/30 bg-secondary/15 px-4 py-2.5 hover:bg-secondary/35 cursor-pointer transition-colors"
                  >
                    <div className="flex items-center gap-2.5">
                      <Calendar className="h-4 w-4 text-muted-foreground/50" />
                      <span className="portal-meta font-extrabold text-muted-foreground/90">{snap.snapshot_date}</span>
                      <span className="text-[10px] bg-secondary text-muted-foreground/60 px-2 py-0.5 rounded-md font-semibold ml-1">
                        Sin registros
                      </span>
                    </div>
                    <span className="text-xs text-primary font-bold flex items-center gap-0.5">
                      Ver <ChevronDown className="h-3.5 w-3.5" />
                    </span>
                  </div>
                );
              }

              return (
                <div
                  key={snap.id}
                  className="rounded-xl border border-transparent p-3.5 transition-all duration-200 hover:border-border/30 hover:bg-secondary/25"
                >
                  <div className="mb-3 flex items-center justify-between">
                    <div className="flex items-center gap-2.5">
                      <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-secondary">
                        <Calendar className="h-4 w-4 text-muted-foreground" />
                      </div>
                      <span className="portal-card-heading">
                        {snap.snapshot_date}
                      </span>
                      {isEmpty && (
                        <span className="text-[10px] bg-secondary text-muted-foreground/60 px-2 py-0.5 rounded-md font-semibold ml-1">
                          Sin registros
                        </span>
                      )}
                    </div>
                    {isEmpty && (
                      <button
                        onClick={() => toggleSnap(snap.id)}
                        className="text-xs text-muted-foreground hover:text-foreground font-semibold flex items-center gap-0.5"
                      >
                        Ocultar <ChevronUp className="h-3.5 w-3.5" />
                      </button>
                    )}
                  </div>

                  <div className="grid grid-cols-1 gap-y-3 pl-10.5">
                    {renderBar(t('common.kcal'), snap.kcal_actual, snap.kcal_target, t('common.kcal_unit'))}
                    {renderBar(
                      t('components.clientdetail.snapshotspanel.protein'),
                      snap.protein_actual,
                      snap.protein_target,
                      'g',
                    )}
                    {renderBar(t('components.clientdetail.snapshotspanel.carbs'), snap.carbs_actual, snap.carbs_target, 'g')}
                    {renderBar(t('components.clientdetail.snapshotspanel.fat'), snap.fat_actual, snap.fat_target, 'g')}
                    {snap.notes && (
                      <div className="mt-3 rounded-lg bg-secondary/35 border-l-2 border-primary/50 px-3 py-2 text-xs text-muted-foreground italic">
                        {snap.notes}
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {sortedSnapshots.length > INITIAL_SHOWN && (
        <div className="border-t border-border/50 bg-card/5 px-5 py-2.5">
          <button
            onClick={() => setShowAll(!showAll)}
            className="portal-action flex items-center gap-1.5 text-muted-foreground transition-colors hover:text-foreground"
          >
            {showAll ? (
              <>
                <ChevronUp className="h-4 w-4" /> {t('components.clientdetail.snapshotspanel.show_less')}
              </>
            ) : (
              <>
                <ChevronDown className="h-4 w-4" />{' '}
                {t('components.clientdetail.snapshotspanel.show_more', { length_initial_shown: sortedSnapshots.length - INITIAL_SHOWN })}
              </>
            )}
          </button>
        </div>
      )}
    </div>
  );
};
