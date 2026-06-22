import React from 'react';
import {
  Coffee,
  Loader2,
  Moon,
  Pizza,
  Sandwich,
  UtensilsCrossed,
} from 'lucide-react';
import { useDiaryEntries } from '../../hooks/queries/useDiaryEntries';
import type { ProfessionalClient } from '../../types/database.types';
import { formatPortalDate } from '../../lib/date';
import { usePortalI18n } from '../../lib/portal-i18n';

interface DiaryPanelProps {
  client: ProfessionalClient;
}

function mealTypeIcon(type: string) {
  switch (type) {
    case 'breakfast':
      return <Coffee className="h-3.5 w-3.5" />;
    case 'lunch':
      return <Sandwich className="h-3.5 w-3.5" />;
    case 'dinner':
      return <Moon className="h-3.5 w-3.5" />;
    case 'snack':
      return <Pizza className="h-3.5 w-3.5" />;
    default:
      return <UtensilsCrossed className="h-3.5 w-3.5" />;
  }
}

export const DiaryPanel: React.FC<DiaryPanelProps> = ({ client }) => {
  const { t, locale } = usePortalI18n();
  const { data: entries, isLoading, error } = useDiaryEntries(client.id);

  const mealTypeLabel = (type: string) =>
    ({
      breakfast: t('components.clientdetail.diarypanel.breakfast'),
      lunch: t('components.clientdetail.diarypanel.lunch'),
      dinner: t('components.clientdetail.diarypanel.dinner'),
      snack: t('components.clientdetail.diarypanel.snack'),
    })[type] ?? type;

  const formatKcal = (value: number | null) =>
    value != null ? `${Math.round(value)} kcal` : '--';

  if (client.sharing_mode !== 'detailed') {
    return (
      <section className="portal-panel rounded-[1.6rem] p-6">
        <div className="flex items-center gap-3 border-b border-border pb-4">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/12 text-primary">
            <UtensilsCrossed className="h-5 w-5" />
          </div>
          <div>
            <h3 className="text-base font-bold text-foreground">{t('components.clientdetail.diarypanel.client_diary')}</h3>
            <p className="text-sm text-muted-foreground">
              {t('components.clientdetail.diarypanel.detailed_reading_gated_by_consent')}
            </p>
          </div>
        </div>

        <div className="py-10 text-center">
          <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-background text-muted-foreground">
            <UtensilsCrossed className="h-6 w-6" />
          </div>
          <p className="mt-4 text-base font-bold text-foreground">
            {t('components.clientdetail.diarypanel.detailed_diary_is_not_shared')}
          </p>
          <p className="mx-auto mt-2 max-w-md text-sm leading-relaxed text-muted-foreground">
            {t('components.clientdetail.diarypanel.this_relationship_is_in_aggregate_mode_so_the_portal_can_read_snapshots_')}
          </p>
        </div>
      </section>
    );
  }

  if (isLoading) {
    return (
      <div className="portal-panel flex min-h-[220px] items-center justify-center rounded-[1.6rem]">
        <Loader2 className="h-6 w-6 animate-spin text-primary" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="portal-panel rounded-[1.6rem] p-6 text-center text-sm text-muted-foreground">
        {t('components.clientdetail.diarypanel.the_diary_entries_could_not_be_loaded')}
      </div>
    );
  }

  if (!entries || entries.length === 0) {
    return (
      <section className="portal-panel rounded-[1.6rem] p-6">
        <div className="flex items-center gap-3 border-b border-border pb-4">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/12 text-primary">
            <UtensilsCrossed className="h-5 w-5" />
          </div>
          <div>
            <h3 className="text-base font-bold text-foreground">{t('components.clientdetail.diarypanel.client_diary')}</h3>
            <p className="text-sm text-muted-foreground">
              {t('components.clientdetail.diarypanel.detailed_rows_shared_from_the_mobile_app')}
            </p>
          </div>
        </div>

        <div className="py-10 text-center">
          <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-background text-muted-foreground">
            <UtensilsCrossed className="h-6 w-6" />
          </div>
          <p className="mt-4 text-base font-bold text-foreground">
            {t('components.clientdetail.diarypanel.no_diary_entries_yet')}
          </p>
          <p className="mx-auto mt-2 max-w-md text-sm leading-relaxed text-muted-foreground">
            {t('components.clientdetail.diarypanel.when_the_client_shares_the_diary_in_detailed_mode_meals_will_appear_here')}
          </p>
        </div>
      </section>
    );
  }

  const grouped: Record<string, typeof entries> = {};
  for (const entry of entries) {
    (grouped[entry.entry_date] ??= []).push(entry);
  }

  const sortedDates = Object.keys(grouped).sort((a, b) => b.localeCompare(a));

  return (
    <section className="portal-panel overflow-hidden rounded-[1.6rem]">
      <div className="border-b border-border px-5 py-4">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary/12 text-primary">
            <UtensilsCrossed className="h-5 w-5" />
          </div>
          <div>
            <h3 className="text-base font-bold text-foreground">{t('components.clientdetail.diarypanel.client_diary')}</h3>
            <p className="text-sm text-muted-foreground">
              {t('components.clientdetail.diarypanel.shared_entries', { entries_length: entries.length })}
            </p>
          </div>
        </div>
      </div>

      <div className="space-y-4 p-4">
        {sortedDates.map((date) => {
          const dayEntries = grouped[date]!;
          const dayTotalKcal = dayEntries.reduce((sum, entry) => sum + (entry.kcal ?? 0), 0);
          const dayTotalProtein = dayEntries.reduce((sum, entry) => sum + (entry.protein ?? 0), 0);
          const dayTotalCarbs = dayEntries.reduce((sum, entry) => sum + (entry.carbs ?? 0), 0);
          const dayTotalFat = dayEntries.reduce((sum, entry) => sum + (entry.fat ?? 0), 0);

          return (
            <details
              key={date}
              className="overflow-hidden rounded-2xl border border-border bg-background/60"
              open={sortedDates.length <= 3}
            >
              <summary className="flex cursor-pointer list-none items-center justify-between gap-3 bg-background px-4 py-3 text-sm font-bold text-foreground">
                <div className="flex items-center gap-2">
                  <span>
                    {formatPortalDate(date, locale, {
                      weekday: 'short',
                      month: 'short',
                      day: 'numeric',
                    })}
                  </span>
                  <span className="text-sm font-medium text-muted-foreground">
                    · {formatKcal(dayTotalKcal)}
                  </span>
                </div>
                <span className="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                  {dayEntries.length} {t('components.clientdetail.diarypanel.meals')}
                </span>
              </summary>

              <div className="space-y-4 border-t border-border p-4">
                {(['breakfast', 'lunch', 'dinner', 'snack'] as const).map((slot) => {
                  const slotEntries = dayEntries.filter((entry) => entry.meal_type === slot);
                  if (slotEntries.length === 0) {
                    return null;
                  }

                  return (
                    <div key={slot} className="space-y-2">
                      <div className="flex items-center gap-2">
                        <span className="rounded-lg bg-primary/10 p-1.5 text-primary">
                          {mealTypeIcon(slot)}
                        </span>
                        <span className="text-xs font-bold uppercase tracking-[0.16em] text-foreground">
                          {mealTypeLabel(slot)}
                        </span>
                        <span className="ml-auto text-xs font-semibold text-muted-foreground">
                          {formatKcal(slotEntries.reduce((sum, entry) => sum + (entry.kcal ?? 0), 0))}
                        </span>
                      </div>

                      <div className="space-y-2">
                        {slotEntries.map((entry) => (
                          <div
                            key={entry.id}
                            className="rounded-xl border border-border bg-card px-3 py-3"
                          >
                            <div className="flex items-start justify-between gap-3">
                              <div className="min-w-0">
                                <p className="truncate text-sm font-bold text-foreground">
                                  {entry.meal_name || t('components.clientdetail.diarypanel.logged_meal')}
                                </p>
                                {entry.meal_brands && (
                                  <p className="mt-1 truncate text-xs text-muted-foreground">
                                    {entry.meal_brands}
                                  </p>
                                )}
                              </div>
                              <div className="text-right">
                                <p className="text-sm font-bold text-foreground">{formatKcal(entry.kcal)}</p>
                                <p className="mt-1 flex gap-2 text-[10px] font-bold">
                                  {entry.protein != null ? (
                                    <span className="text-primary">P: {Math.round(entry.protein)}g</span>
                                  ) : null}
                                  {entry.carbs != null ? (
                                    <span className="text-sky-500 dark:text-sky-400">
                                      C: {Math.round(entry.carbs)}g
                                    </span>
                                  ) : null}
                                  {entry.fat != null ? (
                                    <span className="text-amber-500 dark:text-amber-300">
                                      F: {Math.round(entry.fat)}g
                                    </span>
                                  ) : null}
                                </p>
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  );
                })}

                <div className="rounded-xl border border-border bg-card px-4 py-3">
                  <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                    <span className="text-xs font-bold uppercase tracking-[0.16em] text-muted-foreground">
                      {t('components.clientdetail.diarypanel.day_summary')}
                    </span>
                    <div className="flex flex-wrap items-center gap-3 text-xs font-bold">
                      <span className="text-foreground">{formatKcal(dayTotalKcal)}</span>
                      <span className="text-primary">P: {Math.round(dayTotalProtein)}g</span>
                      <span className="text-sky-500 dark:text-sky-400">C: {Math.round(dayTotalCarbs)}g</span>
                      <span className="text-amber-500 dark:text-amber-300">F: {Math.round(dayTotalFat)}g</span>
                    </div>
                  </div>
                </div>
              </div>
            </details>
          );
        })}
      </div>
    </section>
  );
};
