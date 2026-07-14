import React, { useState } from 'react';
import {
  Archive,
  CheckSquare,
  Copy,
  FileText,
  LayoutList,
  Loader2,
  Plus,
  Square,
  Trash2,
  Coffee,
  Utensils,
  Apple,
  Moon,
} from 'lucide-react';
import { useAuth } from '../../lib/auth-context';
import { usePlans, usePlan } from '../../hooks/queries/usePlans';
import {
  useArchivePlan,
  useBatchArchivePlans,
  useDeletePlan,
  useDuplicatePlan,
} from '../../hooks/mutations/useDeletePlan';
import type { ProfessionalClient } from '../../types/database.types';
import { formatPortalDate } from '../../lib/date';
import { Button } from '../ui/button';
import { toast } from '../../lib/toast';
import { getBillingSummary } from '../../view-models/professional';
import { getRelationshipStatusLabel } from '../../view-models/clients';
import { usePortalI18n } from '../../lib/portal-i18n';

interface PlanListProps {
  client: ProfessionalClient;
  onNewPlan: () => void;
  onEditPlan: (planId: string) => void;
}

export const PlanList: React.FC<PlanListProps> = ({ client, onNewPlan, onEditPlan }) => {
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();
  const billingSummary = getBillingSummary(professional);
  const { data: plans, isLoading, error } = usePlans(client.client_id, client.professional_id);

  const archivePlan = useArchivePlan();
  const deletePlan = useDeletePlan();
  const duplicatePlan = useDuplicatePlan();
  const batchArchivePlans = useBatchArchivePlans();
  const [confirmDelete, setConfirmDelete] = useState<string | null>(null);
  const [selectMode, setSelectMode] = useState(false);
  const [selectedPlans, setSelectedPlans] = useState<Set<string>>(new Set());

  const canManagePlans = billingSummary.canPublishPlans && client.status === 'connected';

  const toggleSelect = (planId: string) => {
    setSelectedPlans((prev) => {
      const next = new Set(prev);
      if (next.has(planId)) next.delete(planId);
      else next.add(planId);
      return next;
    });
  };

  const activePlans = plans?.filter((plan) => plan.status !== 'archived') ?? [];
  const archivedPlans = plans?.filter((plan) => plan.status === 'archived') ?? [];

  const activePlan = plans?.find((plan) => plan.status === 'active') || null;
  const { data: activePlanDetails, isLoading: activePlanDetailsLoading } = usePlan(activePlan?.id);
  const activeDay = activePlanDetails?.days?.[0];

  const mealLabelBySlot = {
    breakfast: t('components.clientdetail.planbuilder.breakfast'),
    lunch: t('components.clientdetail.planbuilder.lunch'),
    dinner: t('components.clientdetail.planbuilder.dinner'),
    snack: t('components.clientdetail.planbuilder.snack'),
  } as const;

  const getMealLabel = (value: string | null | undefined) => {
    const normalized = `${value ?? ''}`.trim().toLowerCase();
    if (normalized in mealLabelBySlot) {
      return mealLabelBySlot[normalized as keyof typeof mealLabelBySlot];
    }
    return value ?? '';
  };

  const otherActivePlans = activePlans.filter((plan) => plan.id !== activePlan?.id);

  const toggleSelectAll = () => {
    setSelectedPlans((prev) =>
      prev.size === otherActivePlans.length ? new Set() : new Set(otherActivePlans.map((plan) => plan.id)),
    );
  };

  const handleBatchArchive = async () => {
    if (selectedPlans.size === 0) return;
    try {
      await batchArchivePlans.mutateAsync(Array.from(selectedPlans));
      toast.success(
        t('components.clientdetail.planlist.archived_plans', { selectedplans_size: selectedPlans.size }),
      );
      setSelectedPlans(new Set());
      setSelectMode(false);
    } catch {
      toast.error(t('components.clientdetail.planlist.failed_to_archive_plans'));
    }
  };

  const handleDuplicate = async (planId: string) => {
    if (!professional || !canManagePlans) return;
    try {
      await duplicatePlan.mutateAsync({
        professionalId: professional.id,
        clientId: client.client_id,
        planId,
      });
      toast.success(t('components.clientdetail.planlist.plan_duplicated'));
    } catch {
      toast.error(t('components.clientdetail.planlist.failed_to_duplicate_plan'));
    }
  };

  const handleArchive = async (planId: string) => {
    if (!canManagePlans) return;
    try {
      await archivePlan.mutateAsync(planId);
      toast.success(t('components.clientdetail.planlist.plan_archived'));
    } catch {
      toast.error(t('components.clientdetail.planlist.failed_to_archive_plan'));
    }
  };

  const handleDelete = async (planId: string) => {
    if (!canManagePlans) return;
    try {
      await deletePlan.mutateAsync(planId);
      toast.success(t('components.clientdetail.planlist.plan_deleted'));
      setConfirmDelete(null);
    } catch {
      toast.error(t('components.clientdetail.planlist.failed_to_delete_plan'));
    }
  };

  const statusLabel = (status: string) =>
    ({
      active: t('components.clientdetail.planlist.active'),
      draft: t('components.clientdetail.planlist.draft'),
      archived: t('components.clientdetail.planlist.archived'),
    })[status] ?? status;

  if (isLoading) {
    return (
      <div className="portal-panel flex min-h-[220px] items-center justify-center rounded-[1.8rem] p-8">
        <Loader2 className="h-6 w-6 animate-spin text-primary" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="portal-panel portal-body rounded-[1.8rem] p-8 text-center text-muted-foreground">
        {t('components.clientdetail.planlist.failed_to_load_plans')}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Prominent Active Plan Section */}
      {activePlan ? (
        <div className="portal-panel rounded-[1.8rem] p-6 bg-primary/[0.01]">
          <div className="flex items-start justify-between gap-4 border-b border-border pb-5">
            <div className="flex items-center gap-3">
              <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary/10 text-primary">
                <LayoutList className="h-6 w-6" />
              </div>
              <div>
                <div className="flex flex-wrap items-center gap-2">
                  <h4 className="portal-section-heading">{activePlan.name.replace(/semanals/gi, 'semanal')}</h4>
                  <span className="portal-pill rounded-full bg-emerald-500/10 px-2.5 py-0.5 text-emerald-600 dark:text-[#72de98]">
                    {t('components.clientdetail.planlist.active')}
                  </span>
                </div>
                <p className="portal-meta mt-1">
                  {activePlan.starts_on ? formatPortalDate(activePlan.starts_on, locale) : ''}
                  {activePlan.ends_on ? ` - ${formatPortalDate(activePlan.ends_on, locale)}` : ''}
                </p>
              </div>
            </div>
            {canManagePlans && (
              <Button
                onClick={() => onEditPlan(activePlan.id)}
                size="sm"
                variant="secondary"
                className="h-10 rounded-xl px-5 portal-meta"
              >
                {t('components.clientdetail.summarypanel.edit_plan')}
              </Button>
            )}
          </div>

          {activePlanDetailsLoading ? (
            <div className="grid gap-4 mt-6 grid-cols-[repeat(auto-fit,minmax(140px,1fr))] w-full">
              {[1, 2, 3, 4].map((i) => (
                <div key={i} className="portal-panel h-24 rounded-2xl animate-pulse bg-black/5 dark:bg-white/5" />
              ))}
            </div>
          ) : activeDay ? (
            (() => {
              const pCal = activeDay.protein_goal * 4;
              const cCal = activeDay.carbs_goal * 4;
              const fCal = activeDay.fat_goal * 9;
              const totalCal = pCal + cCal + fCal;
              const pPct = totalCal > 0 ? Math.round((pCal / totalCal) * 100) : 0;
              const cPct = totalCal > 0 ? Math.round((cCal / totalCal) * 100) : 0;
              const fPct = totalCal > 0 ? Math.round((fCal / totalCal) * 100) : 0;

              return (
                <div className="grid gap-4 mt-6 grid-cols-[repeat(auto-fit,minmax(140px,1fr))] w-full">
                  <div className="portal-panel rounded-2xl p-4 shadow-sm bg-card/40 border-l-4 border-l-primary/70 shadow-[0_0_15px_-3px_rgba(16,185,129,0.05)]">
                    <span className="portal-kpi-label">{t('common.kcal')}</span>
                    <p className="portal-kpi-value mt-1.5">{Math.round(activeDay.kcal_goal)} <span className="portal-meta text-muted-foreground">{t('common.kcal_unit')}</span></p>
                  </div>
                  <div className="portal-panel rounded-2xl p-4 shadow-sm bg-card/40 border-l-4 border-l-emerald-500 dark:border-l-emerald-400 shadow-[0_0_15px_-3px_rgba(16,185,129,0.05)]">
                    <div className="flex flex-wrap items-center justify-between gap-1">
                      <span className="portal-kpi-label text-emerald-600 dark:text-emerald-400">{t('components.clientdetail.snapshotspanel.protein')}</span>
                      <span className="text-[10px] font-bold text-muted-foreground bg-emerald-500/10 px-1.5 py-0.5 rounded-md">({pPct}%)</span>
                    </div>
                    <p className="portal-kpi-value mt-1.5">{Math.round(activeDay.protein_goal)} <span className="portal-meta text-muted-foreground">g</span></p>
                  </div>
                  <div className="portal-panel rounded-2xl p-4 shadow-sm bg-card/40 border-l-4 border-l-sky-500 shadow-[0_0_15px_-3px_rgba(14,165,233,0.05)]">
                    <div className="flex flex-wrap items-center justify-between gap-1">
                      <span className="portal-kpi-label text-sky-500">{t('components.clientdetail.snapshotspanel.carbs')}</span>
                      <span className="text-[10px] font-bold text-muted-foreground bg-sky-500/10 px-1.5 py-0.5 rounded-md">({cPct}%)</span>
                    </div>
                    <p className="portal-kpi-value mt-1.5">{Math.round(activeDay.carbs_goal)} <span className="portal-meta text-muted-foreground">g</span></p>
                  </div>
                  <div className="portal-panel rounded-2xl p-4 shadow-sm bg-card/40 border-l-4 border-l-amber-500 shadow-[0_0_15px_-3px_rgba(245,158,11,0.05)]">
                    <div className="flex flex-wrap items-center justify-between gap-1">
                      <span className="portal-kpi-label text-amber-500">{t('components.clientdetail.snapshotspanel.fat')}</span>
                      <span className="text-[10px] font-bold text-muted-foreground bg-amber-500/10 px-1.5 py-0.5 rounded-md">({fPct}%)</span>
                    </div>
                    <p className="portal-kpi-value mt-1.5">{Math.round(activeDay.fat_goal)} <span className="portal-meta text-muted-foreground">g</span></p>
                  </div>
                </div>
              );
            })()
          ) : null}

          {/* Meals List - Timeline Layout */}
          {activePlanDetails?.meals && activePlanDetails.meals.length > 0 && (
            <div className="mt-6 border-t border-border/80 pt-6">
              <span className="portal-label block mb-4">
                {t('components.clientdetail.planlist.planned_meals')}
              </span>
              <div className="relative pl-6 border-l-2 border-border/60 ml-3.5 space-y-6 my-2">
                {activePlanDetails.meals.map((meal) => {
                  const slotLower = `${meal.slot ?? ''}`.toLowerCase();
                  let MealIcon = FileText;
                  if (slotLower.includes('breakfast') || slotLower.includes('desayuno')) {
                    MealIcon = Coffee;
                  } else if (slotLower.includes('lunch') || slotLower.includes('comida') || slotLower.includes('almuerzo')) {
                    MealIcon = Utensils;
                  } else if (slotLower.includes('snack') || slotLower.includes('merienda')) {
                    MealIcon = Apple;
                  } else if (slotLower.includes('dinner') || slotLower.includes('cena')) {
                    MealIcon = Moon;
                  }

                  return (
                    <div key={meal.id} className="relative group">
                      {/* Timeline Node */}
                      <span className="absolute -left-[35px] top-1.5 flex h-6 w-6 items-center justify-center rounded-full border-2 border-border bg-card text-muted-foreground group-hover:border-primary group-hover:text-primary transition-all duration-200 shadow-sm">
                        <MealIcon className="h-3.5 w-3.5" />
                      </span>

                      <div className="portal-panel rounded-2xl p-4.5 bg-background/25 hover:bg-background/45 flex items-start justify-between gap-4 border border-border/40 transition-all duration-200">
                        <div className="min-w-0">
                          <span className="portal-label text-primary font-bold">
                            {getMealLabel(meal.slot)}
                          </span>
                          <h5 className="portal-card-heading truncate mt-1 text-base font-extrabold text-foreground">
                            {getMealLabel(meal.title)}
                          </h5>
                          {meal.notes && (
                            <p className="portal-meta mt-1.5 text-muted-foreground/80 leading-relaxed max-w-lg">
                              {meal.notes}
                            </p>
                          )}
                        </div>

                        <div className="flex flex-col items-end gap-1.5 shrink-0">
                          {meal.kcal && (
                            <span className="portal-meta bg-primary/10 text-primary px-3 py-1 rounded-xl font-extrabold">
                              {Math.round(meal.kcal)} kcal
                            </span>
                          )}
                          {(meal.protein || meal.carbs || meal.fat) && (
                            <div className="flex items-center gap-2 text-[10px] font-bold text-muted-foreground/70 bg-secondary/50 px-2 py-0.5 rounded-lg border border-border/40">
                              {meal.protein ? <span>{Math.round(meal.protein)}P</span> : null}
                              {meal.carbs ? <span>{Math.round(meal.carbs)}C</span> : null}
                              {meal.fat ? <span>{Math.round(meal.fat)}F</span> : null}
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}
        </div>
      ) : (
        <div className="portal-panel px-6 py-12 text-center rounded-[1.8rem] border border-border bg-card/20">
          <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-primary/10 text-primary">
            <LayoutList className="h-6 w-6" />
          </div>
          <h4 className="portal-card-heading mt-4">
            {t('components.clientdetail.planlist.no_active_plan_heading')}
          </h4>
          <p className="portal-body mt-2 max-w-md mx-auto">
            {t('components.clientdetail.planlist.no_active_plan_body')}
          </p>
          {canManagePlans && (
            <Button
              onClick={onNewPlan}
              className="portal-action mt-5 bg-primary rounded-xl px-5 py-2.5 text-primary-foreground"
            >
              <Plus className="mr-1.5 h-4 w-4" />
              {t('components.clientdetail.summarypanel.create_plan')}
            </Button>
          )}
        </div>
      )}

      {/* History and Other Plans (Drafts & Inactive Plans) */}
      {otherActivePlans.length === 0 ? (
        <div className="border border-border/40 bg-secondary/15 rounded-2xl p-4.5 flex items-center justify-between text-muted-foreground/80">
          <div className="flex items-center gap-2.5">
            <Archive className="h-4 w-4 text-muted-foreground/60" />
            <span className="portal-meta text-xs">
              {t('components.clientdetail.planlist.no_drafts_or_previous_plans')}
            </span>
          </div>
          {canManagePlans && (
            <Button
              onClick={onNewPlan}
              size="sm"
              variant="secondary"
              className="h-8 rounded-xl px-4 text-xs font-semibold"
            >
              <Plus className="mr-1 h-3 w-3" />
              {t('components.clientdetail.planlist.new')}
            </Button>
          )}
        </div>
      ) : (
        <div className="portal-panel rounded-[1.8rem]">
          <div className="flex items-center justify-between border-b border-border px-6 py-4.5">
            <div>
              <h3 className="portal-card-heading uppercase tracking-[0.1em]">
                {t('components.clientdetail.planlist.history_and_drafts')}
              </h3>
              <p className="portal-meta mt-0.5">
                {t('components.clientdetail.planlist.non_archived', { activeplans_length: otherActivePlans.length })}
              </p>
            </div>

            <div className="flex items-center gap-2">
              {selectMode ? (
                <>
                  <Button
                    size="sm"
                    variant="ghost"
                    className="h-9 rounded-xl portal-meta"
                    onClick={() => {
                      setSelectMode(false);
                      setSelectedPlans(new Set());
                    }}
                  >
                    {t('components.clientdetail.planlist.cancel')}
                  </Button>
                  <Button
                    size="sm"
                    variant="secondary"
                    className="h-9 rounded-xl portal-meta"
                    disabled={selectedPlans.size === 0 || batchArchivePlans.isPending}
                    onClick={handleBatchArchive}
                  >
                    {batchArchivePlans.isPending ? (
                      <Loader2 className="mr-1.5 h-3.5 w-3.5 animate-spin" />
                    ) : (
                      <Archive className="mr-1.5 h-3.5 w-3.5" />
                    )}
                    {t('components.clientdetail.planlist.archive')} ({selectedPlans.size})
                  </Button>
                </>
              ) : (
                <>
                  {otherActivePlans.length > 0 && (
                    <button
                      className="rounded-xl p-2.5 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                      onClick={() => setSelectMode(true)}
                      disabled={!canManagePlans}
                      title={t('components.clientdetail.planlist.select_plans')}
                    >
                      <CheckSquare className="h-4 w-4" />
                    </button>
                  )}
                  {(!activePlan || otherActivePlans.length > 0) && (
                    <Button
                      onClick={onNewPlan}
                      size="sm"
                      disabled={!canManagePlans}
                      className="h-9 rounded-xl bg-primary portal-meta text-primary-foreground"
                    >
                      <Plus className="mr-1.5 h-3.5 w-3.5" />
                      {t('components.clientdetail.planlist.new')}
                    </Button>
                  )}
                </>
              )}
            </div>
          </div>

          {!canManagePlans && !activePlan && (
            <div className="portal-body mx-6 mt-4 rounded-xl border border-amber-500/25 bg-amber-500/10 p-4 text-amber-900 dark:text-amber-100">
              {client.status !== 'connected'
                ? t('components.clientdetail.planlist.plan_actions_are_disabled_because_this_relationship_is', { status_tolowercase: getRelationshipStatusLabel(client.status, t).toLowerCase() })
                : t('components.clientdetail.planlist.plan_actions_are_disabled_until_professional_access_returns_to_active_or')}
            </div>
          )}

          <div className="p-3">
            {selectMode && otherActivePlans.length > 0 && (
              <div className="mb-1 flex items-center gap-2 px-3 py-2">
                <button
                  className="rounded-lg p-1 text-muted-foreground transition-colors hover:text-foreground"
                  onClick={toggleSelectAll}
                >
                  {selectedPlans.size === otherActivePlans.length ? (
                    <CheckSquare className="h-4 w-4 text-primary" />
                  ) : (
                    <Square className="h-4 w-4" />
                  )}
                </button>
                <span className="portal-meta">
                  {selectedPlans.size === 0
                    ? t('components.clientdetail.planlist.select_plans_to_batch_archive')
                    : t('components.clientdetail.planlist.of_selected', { selectedplans_size: selectedPlans.size, activeplans_length: otherActivePlans.length })}
                </span>
              </div>
            )}

            <div className="space-y-1">
              {otherActivePlans.map((plan) => (
                <div
                  key={plan.id}
                  className={`group flex items-center gap-3 rounded-2xl px-3 py-3 transition-colors ${
                    selectMode ? '' : 'cursor-pointer hover:bg-accent'
                  }`}
                  onClick={selectMode ? () => toggleSelect(plan.id) : () => onEditPlan(plan.id)}
                >
                  {selectMode ? (
                    <button
                      className="rounded-lg p-1 text-muted-foreground transition-colors hover:text-foreground"
                      onClick={(e) => {
                        e.stopPropagation();
                        toggleSelect(plan.id);
                      }}
                    >
                      {selectedPlans.has(plan.id) ? (
                        <CheckSquare className="h-4 w-4 text-primary" />
                      ) : (
                        <Square className="h-4 w-4" />
                      )}
                    </button>
                  ) : (
                    <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-background text-muted-foreground">
                      <FileText className="h-4 w-4" />
                    </div>
                  )}

                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2">
                      <span className="portal-card-heading truncate">{plan.name.replace(/semanals/gi, 'semanal')}</span>
                      <span className="rounded-full bg-primary/10 px-2.5 py-0.5 portal-pill text-primary">
                        {statusLabel(plan.status)}
                      </span>
                    </div>
                    <p className="portal-meta mt-1">
                      {formatPortalDate(plan.created_at, locale)}
                    </p>
                  </div>

                  {!selectMode ? (
                    <div
                      className="flex items-center gap-1 opacity-0 transition-opacity group-hover:opacity-100"
                      onClick={(e) => e.stopPropagation()}
                    >
                      <IconAction title={t('components.clientdetail.planlist.duplicate')} onClick={() => handleDuplicate(plan.id)}>
                        <Copy className="h-3.5 w-3.5" />
                      </IconAction>
                      <IconAction title={t('components.clientdetail.planlist.archive')} onClick={() => handleArchive(plan.id)}>
                        <Archive className="h-3.5 w-3.5" />
                      </IconAction>
                      {confirmDelete === plan.id ? (
                        <div className="ml-1 flex items-center gap-1">
                          <IconAction title={t('components.clientdetail.planlist.confirm')} onClick={() => handleDelete(plan.id)} danger>
                            <Trash2 className="h-3.5 w-3.5" />
                          </IconAction>
                          <button
                            className="portal-label rounded-lg px-2 py-1 text-muted-foreground hover:bg-accent"
                            onClick={() => setConfirmDelete(null)}
                          >
                            {t('components.clientdetail.planlist.cancel')}
                          </button>
                        </div>
                      ) : (
                        <IconAction title={t('components.clientdetail.planlist.delete')} onClick={() => setConfirmDelete(plan.id)} danger>
                          <Trash2 className="h-3.5 w-3.5" />
                        </IconAction>
                      )}
                    </div>
                  ) : null}
                </div>
              ))}

              {archivedPlans.length > 0 && (
                <details className="group mt-2 border-t border-border/40 pt-2">
                  <summary className="portal-meta cursor-pointer px-3 py-2 transition-colors hover:text-foreground">
                    {t('components.clientdetail.planlist.archived_2', { archivedplans_length: archivedPlans.length })}
                  </summary>
                  <div className="mt-1 space-y-1">
                    {archivedPlans.map((plan) => (
                      <div
                        key={plan.id}
                        className="flex items-center gap-3 rounded-xl bg-background/70 px-3 py-2 opacity-75 transition-opacity hover:opacity-100"
                      >
                        <FileText className="h-4 w-4 shrink-0 text-muted-foreground" />
                        <span className="portal-meta flex-1 truncate">{plan.name.replace(/semanals/gi, 'semanal')}</span>
                        <span className="portal-pill rounded-full bg-background px-2.5 py-0.5 text-muted-foreground">
                          {statusLabel(plan.status)}
                        </span>
                        <IconAction title={t('components.clientdetail.planlist.delete')} onClick={() => handleDelete(plan.id)} danger>
                          <Trash2 className="h-3.5 w-3.5" />
                        </IconAction>
                      </div>
                    ))}
                  </div>
                </details>
              )}
            </div>
          </div>
        </div>
      )}</div>
  );
};

const IconAction: React.FC<{
  title: string;
  onClick: () => void;
  danger?: boolean;
  children: React.ReactNode;
}> = ({ title, onClick, danger = false, children }) => (
  <button
    className={`rounded-lg p-1.5 transition-colors ${
      danger
        ? 'text-muted-foreground hover:bg-rose-500/10 hover:text-rose-500'
        : 'text-muted-foreground hover:bg-accent hover:text-foreground'
    }`}
    onClick={onClick}
    title={title}
  >
    {children}
  </button>
);
