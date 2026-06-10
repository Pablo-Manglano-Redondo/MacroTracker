import React from 'react';
import { useDiaryEntries } from '../../hooks/queries/useDiaryEntries';
import type { ProfessionalClient } from '../../types/database.types';
import { Loader2, UtensilsCrossed, Coffee, Sandwich, Pizza, Moon } from 'lucide-react';

interface DiaryPanelProps {
  client: ProfessionalClient;
}

function mealTypeIcon(type: string) {
  switch (type) {
    case 'breakfast': return <Coffee className="w-3.5 h-3.5" />;
    case 'lunch': return <Sandwich className="w-3.5 h-3.5" />;
    case 'dinner': return <Moon className="w-3.5 h-3.5" />;
    case 'snack': return <Pizza className="w-3.5 h-3.5" />;
    default: return <UtensilsCrossed className="w-3.5 h-3.5" />;
  }
}

function mealTypeLabel(type: string) {
  return type.charAt(0).toUpperCase() + type.slice(1);
}

function formatKcal(v: number | null) {
  return v != null ? `${Math.round(v)} kcal` : '—';
}

function formatMacro(v: number | null, label: string) {
  if (v == null) return null;
  return `${Math.round(v)}g ${label}`;
}

export const DiaryPanel: React.FC<DiaryPanelProps> = ({ client }) => {
  const { data: entries, isLoading, error } = useDiaryEntries(client.id);

  if (isLoading) {
    return (
      <div className="rounded-xl border bg-card card-elevated p-6 flex items-center justify-center min-h-[200px]">
        <Loader2 className="w-5 h-5 animate-spin text-muted-foreground" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="rounded-xl border bg-card p-5 text-center text-sm text-destructive">
        Failed to load diary entries.
      </div>
    );
  }

  if (!entries || entries.length === 0) {
    return (
      <div className="rounded-xl border bg-card card-elevated p-6">
        <div className="flex items-center gap-2.5 mb-4">
          <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
            <UtensilsCrossed className="w-4 h-4 text-primary" />
          </div>
          <p className="text-sm font-semibold">Diary</p>
        </div>
        <div className="text-center py-10">
          <div className="w-12 h-12 rounded-full bg-muted/50 flex items-center justify-center mx-auto mb-3">
            <UtensilsCrossed className="w-5 h-5 text-muted-foreground/60" />
          </div>
          <p className="text-sm text-muted-foreground">No diary entries yet</p>
          <p className="text-xs text-muted-foreground/70 mt-1">
            Client diary entries will appear here when sharing is set to "detailed".
          </p>
        </div>
      </div>
    );
  }

  // Group entries by date
  const grouped: Record<string, typeof entries> = {};
  for (const e of entries) {
    (grouped[e.entry_date] ??= []).push(e);
  }

  const sortedDates = Object.keys(grouped).sort((a, b) => b.localeCompare(a));

  return (
    <div className="rounded-xl border bg-card card-elevated">
      <div className="px-5 py-4 border-b flex items-center gap-2.5">
        <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
          <UtensilsCrossed className="w-4 h-4 text-primary" />
        </div>
        <div>
          <p className="text-sm font-semibold leading-none">Diary</p>
          <p className="text-[11px] text-muted-foreground mt-0.5">{entries.length} entries</p>
        </div>
      </div>

      <div className="p-3 space-y-4">
        {sortedDates.map((date) => {
          const dayEntries = grouped[date]!;
          const dayTotalKcal = dayEntries.reduce((s, e) => s + (e.kcal ?? 0), 0);
          const dayTotalProtein = dayEntries.reduce((s, e) => s + (e.protein ?? 0), 0);
          const dayTotalCarbs = dayEntries.reduce((s, e) => s + (e.carbs ?? 0), 0);
          const dayTotalFat = dayEntries.reduce((s, e) => s + (e.fat ?? 0), 0);

          return (
            <details key={date} className="group" defaultChecked={sortedDates.length <= 3}>
              <summary className="flex items-center gap-2 px-3 py-2 rounded-lg hover:bg-secondary/60 transition-colors cursor-pointer text-xs font-medium text-muted-foreground select-none">
                <span>{new Date(date).toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' })}</span>
                <span className="text-[11px] text-muted-foreground/60">— {formatKcal(dayTotalKcal)}</span>
                <span className="ml-auto text-[11px] text-muted-foreground/60">{dayEntries.length} meal{dayEntries.length !== 1 ? 's' : ''}</span>
              </summary>
              <div className="mt-2 space-y-1.5 pl-2">
                {(['breakfast', 'lunch', 'dinner', 'snack'] as const).map((slot) => {
                  const slotEntries = dayEntries.filter(e => e.meal_type === slot);
                  if (slotEntries.length === 0) return null;

                  return (
                    <div key={slot}>
                      <div className="flex items-center gap-1.5 px-3 py-1">
                        <span className="text-muted-foreground">{mealTypeIcon(slot)}</span>
                        <span className="text-[11px] font-medium text-muted-foreground">{mealTypeLabel(slot)}</span>
                        <span className="text-[11px] text-muted-foreground/60 ml-auto">
                          {formatKcal(slotEntries.reduce((s, e) => s + (e.kcal ?? 0), 0))}
                        </span>
                      </div>
                      <div className="space-y-1">
                        {slotEntries.map((entry) => (
                          <div key={entry.id} className="flex items-start gap-2 px-4 py-1.5 rounded-lg hover:bg-secondary/30 transition-colors">
                            <div className="w-1.5 h-1.5 rounded-full bg-primary/40 mt-1.5 shrink-0" />
                            <div className="flex-1 min-w-0">
                              <p className="text-xs font-medium truncate">
                                {entry.meal_name || 'Unknown meal'}
                              </p>
                              {entry.meal_brands && (
                                <p className="text-[10px] text-muted-foreground/60 truncate">{entry.meal_brands}</p>
                              )}
                            </div>
                            <div className="text-right shrink-0">
                              <p className="text-xs tabular-nums">{formatKcal(entry.kcal)}</p>
                              <p className="text-[10px] text-muted-foreground/60 tabular-nums">
                                {[formatMacro(entry.protein, 'P'), formatMacro(entry.carbs, 'C'), formatMacro(entry.fat, 'F')]
                                  .filter(Boolean)
                                  .join(' · ')}
                              </p>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  );
                })}

                {dayTotalKcal > 0 && (
                  <div className="flex items-center gap-2 px-4 py-2 mt-1 border-t border-border/40">
                    <span className="text-[11px] font-medium text-muted-foreground">Total</span>
                    <span className="text-[11px] tabular-nums text-muted-foreground/80 ml-auto">
                      {formatKcal(dayTotalKcal)}
                    </span>
                    <span className="text-[10px] tabular-nums text-muted-foreground/60">
                      P{Math.round(dayTotalProtein)}g · C{Math.round(dayTotalCarbs)}g · F{Math.round(dayTotalFat)}g
                    </span>
                  </div>
                )}
              </div>
            </details>
          );
        })}
      </div>
    </div>
  );
};
