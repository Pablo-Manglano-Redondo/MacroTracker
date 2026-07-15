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
            <h3 className="portal-card-heading">{t('components.clientdetail.diarypanel.client_diary')}</h3>
            <p className="portal-meta">
              {t('components.clientdetail.diarypanel.detailed_reading_gated_by_consent')}
            </p>
          </div>
        </div>

        <div className="py-10 text-center">
          <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-background text-muted-foreground">
            <UtensilsCrossed className="h-6 w-6" />
          </div>
          <p className="portal-card-heading mt-4">
            {t('components.clientdetail.diarypanel.detailed_diary_is_not_shared')}
          </p>
          <p className="portal-body mx-auto mt-2 max-w-md">
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
      <div className="portal-panel portal-body rounded-[1.6rem] p-6 text-center text-muted-foreground">
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
            <h3 className="portal-card-heading">{t('components.clientdetail.diarypanel.client_diary')}</h3>
            <p className="portal-meta">
              {t('components.clientdetail.diarypanel.detailed_rows_shared_from_the_mobile_app')}
            </p>
          </div>
        </div>

        <div className="py-10 text-center">
          <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-background text-muted-foreground">
            <UtensilsCrossed className="h-6 w-6" />
          </div>
          <p className="portal-card-heading mt-4">
            {t('components.clientdetail.diarypanel.no_diary_entries_yet')}
          </p>
          <p className="portal-body mx-auto mt-2 max-w-md">
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
            <h3 className="portal-card-heading">{t('components.clientdetail.diarypanel.client_diary')}</h3>
            <p className="portal-meta">
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
          const dayTotalSodium = dayEntries.reduce((sum, entry) => sum + (entry.sodium ?? 0), 0);
          const dayTotalPotassium = dayEntries.reduce((sum, entry) => sum + (entry.potassium ?? 0), 0);
          const dayTotalCalcium = dayEntries.reduce((sum, entry) => sum + (entry.calcium ?? 0), 0);
          const dayTotalIron = dayEntries.reduce((sum, entry) => sum + (entry.iron ?? 0), 0);
          const dayTotalVitaminC = dayEntries.reduce((sum, entry) => sum + (entry.vitamin_c ?? 0), 0);
          const dayTotalVitaminD = dayEntries.reduce((sum, entry) => sum + (entry.vitamin_d ?? 0), 0);
          const matchSnap = client.client_shared_snapshots?.find((s) => s.snapshot_date === date);
          const dayNote = matchSnap?.notes;

          return (
            <details
              key={date}
              className="overflow-hidden rounded-2xl border border-border bg-background/60"
              open={sortedDates.length <= 3}
            >
              <summary className="flex cursor-pointer list-none items-center justify-between gap-3 bg-background px-4 py-3 text-foreground">
                <div className="flex items-center gap-2">
                  <span className="portal-card-heading">
                    {formatPortalDate(date, locale, {
                      weekday: 'short',
                      month: 'short',
                      day: 'numeric',
                    })}
                  </span>
                  <span className="portal-meta">
                    · {formatKcal(dayTotalKcal)}
                  </span>
                </div>
                <span className="portal-pill rounded-full bg-primary/10 px-3 py-1 text-primary">
                  {dayEntries.length} {t('components.clientdetail.diarypanel.meals')}
                </span>
              </summary>

              <div className="space-y-4 border-t border-border p-4">
                {dayNote && (
                  <div className="rounded-xl border border-primary/20 bg-primary/5 p-3.5 text-xs text-muted-foreground italic flex flex-col gap-1">
                    <span className="font-extrabold text-[9px] uppercase tracking-wider text-primary not-italic">
                      Nota de contexto del cliente
                    </span>
                    "{dayNote}"
                  </div>
                )}
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
                        <span className="portal-label text-foreground">
                          {mealTypeLabel(slot)}
                        </span>
                        <span className="portal-meta ml-auto">
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
                                <p className="portal-card-heading flex items-center gap-2 truncate">
                                  <span>{entry.meal_name || t('components.clientdetail.diarypanel.logged_meal')}</span>
                                  {entry.nova_group != null && (
                                    <span className="portal-pill rounded-full bg-accent/50 px-2 py-0.5 text-[10px] uppercase text-accent-foreground border border-accent">
                                      NOVA {entry.nova_group}
                                    </span>
                                  )}
                                </p>
                                {entry.meal_brands && (
                                  <p className="portal-meta mt-1 truncate">
                                    {entry.meal_brands}
                                  </p>
                                )}
                              </div>
                              <div className="text-right">
                                <p className="portal-card-heading">{formatKcal(entry.kcal)}</p>
                                <p className="portal-label mt-1 flex gap-2 normal-case tracking-normal">
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
                                {(entry.sodium || entry.potassium || entry.calcium || entry.iron || entry.vitamin_c || entry.vitamin_d) ? (
                                  <p className="portal-label mt-1 flex flex-wrap justify-end gap-2 normal-case tracking-normal text-muted-foreground/80">
                                    {entry.sodium != null && entry.sodium > 0 && <span>Na: {Math.round(entry.sodium)}mg</span>}
                                    {entry.potassium != null && entry.potassium > 0 && <span>K: {Math.round(entry.potassium)}mg</span>}
                                    {entry.calcium != null && entry.calcium > 0 && <span>Ca: {Math.round(entry.calcium)}mg</span>}
                                    {entry.iron != null && entry.iron > 0 && <span>Fe: {Math.round(entry.iron)}mg</span>}
                                    {entry.vitamin_c != null && entry.vitamin_c > 0 && <span>Vit C: {Math.round(entry.vitamin_c)}mg</span>}
                                    {entry.vitamin_d != null && entry.vitamin_d > 0 && <span>Vit D: {Math.round(entry.vitamin_d)}µg</span>}
                                  </p>
                                ) : null}
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  );
                })}

                <div className="rounded-xl border border-border bg-card px-4 py-3">
                  <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
                    <span className="portal-label mt-1">
                      {t('components.clientdetail.diarypanel.day_summary')}
                    </span>
                    <div className="flex flex-col items-end gap-1.5">
                      <div className="portal-meta flex flex-wrap items-center justify-end gap-3">
                        <span className="text-foreground font-semibold">{formatKcal(dayTotalKcal)}</span>
                        <span className="text-primary font-medium">P: {Math.round(dayTotalProtein)}g</span>
                        <span className="text-sky-500 dark:text-sky-400 font-medium">C: {Math.round(dayTotalCarbs)}g</span>
                        <span className="text-amber-500 dark:text-amber-300 font-medium">F: {Math.round(dayTotalFat)}g</span>
                      </div>
                      {(dayTotalSodium > 0 || dayTotalPotassium > 0 || dayTotalCalcium > 0 || dayTotalIron > 0 || dayTotalVitaminC > 0 || dayTotalVitaminD > 0) && (
                        <div className="portal-label flex flex-wrap items-center justify-end gap-2 text-muted-foreground/80">
                          {dayTotalSodium > 0 && <span>Na: {Math.round(dayTotalSodium)}mg</span>}
                          {dayTotalPotassium > 0 && <span>K: {Math.round(dayTotalPotassium)}mg</span>}
                          {dayTotalCalcium > 0 && <span>Ca: {Math.round(dayTotalCalcium)}mg</span>}
                          {dayTotalIron > 0 && <span>Fe: {Math.round(dayTotalIron)}mg</span>}
                          {dayTotalVitaminC > 0 && <span>Vit C: {Math.round(dayTotalVitaminC)}mg</span>}
                          {dayTotalVitaminD > 0 && <span>Vit D: {Math.round(dayTotalVitaminD)}µg</span>}
                        </div>
                      )}
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
