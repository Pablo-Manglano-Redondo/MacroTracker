import React, { useEffect, useMemo, useState } from 'react';
import {
  AlertTriangle,
  ArrowLeft,
  BookOpen,
  ChevronDown,
  ChevronRight,
  Loader2,
  Minus,
  Plus,
  Save,
  Utensils,
} from 'lucide-react';
import { useAuth } from '../../lib/auth-context';
import { usePlan } from '../../hooks/queries/usePlans';
import { useUpdatePlan } from '../../hooks/mutations/useUpdatePlan';
import type { MealInput } from '../../hooks/mutations/usePublishPlan';
import { planRepository } from '../../repositories/plan.repository';
import { supabase } from '../../lib/supabase';
import type { ProfessionalClient } from '../../types/database.types';
import { toast } from '../../lib/toast';
import { planSchema } from '../../lib/validation/schemas';
import { RecipePickerModal } from './RecipePickerModal';
import { getBillingSummary } from '../../view-models/professional';
import { getRelationshipStatusLabel } from '../../view-models/clients';
import { formatDateOnly } from '../../lib/date';
import { usePortalI18n } from '../../lib/portal-i18n';

interface PlanEditorProps {
  client: ProfessionalClient;
  planId: string;
  onBack: () => void;
}

export const PlanEditor: React.FC<PlanEditorProps> = ({ client, planId, onBack }) => {
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();
  const billingSummary = getBillingSummary(professional);
  const { data: plan, isLoading, error } = usePlan(planId);
  const updatePlan = useUpdatePlan();
  const mealSlotLabel = (slot: string) =>
    ({
      breakfast: t('components.clientdetail.planeditor.breakfast'),
      lunch: t('components.clientdetail.planeditor.lunch'),
      dinner: t('components.clientdetail.planeditor.dinner'),
      snack: t('components.clientdetail.planeditor.snack'),
    })[slot] ?? slot;

  const [planName, setPlanName] = useState('');
  const [hasChanges, setHasChanges] = useState(false);
  const [kcal, setKcal] = useState(0);
  const [protein, setProtein] = useState(0);
  const [carbs, setCarbs] = useState(0);
  const [fat, setFat] = useState(0);
  const [meals, setMeals] = useState<MealInput[]>([
    { slot: 'breakfast', title: mealSlotLabel('breakfast'), kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'lunch', title: mealSlotLabel('lunch'), kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'dinner', title: mealSlotLabel('dinner'), kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'snack', title: mealSlotLabel('snack'), kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
  ]);
  const [showMeals, setShowMeals] = useState(false);
  const [recipePickerSlot, setRecipePickerSlot] = useState<string | null>(null);

  const canEditPlan = billingSummary.canPublishPlans && client.status === 'connected';

  const mealTotals = useMemo(
    () => ({
      kcal: meals.reduce((sum, meal) => sum + (meal.kcal || 0), 0),
      protein: meals.reduce((sum, meal) => sum + (meal.protein || 0), 0),
      carbs: meals.reduce((sum, meal) => sum + (meal.carbs || 0), 0),
      fat: meals.reduce((sum, meal) => sum + (meal.fat || 0), 0),
    }),
    [meals],
  );

  useEffect(() => {
    if (plan) {
      setPlanName(plan.name);
      if (plan.days && plan.days.length > 0) {
        const firstDay = plan.days[0]!;
        setKcal(Number(firstDay.kcal_goal));
        setProtein(Number(firstDay.protein_goal));
        setCarbs(Number(firstDay.carbs_goal));
        setFat(Number(firstDay.fat_goal));
      }
      planRepository
        .listMealsByPlan(supabase, plan.id)
        .then((existing) => {
          if (existing.length > 0) {
            setMeals(
              existing.map((meal) => ({
                slot: meal.slot as string,
                title: meal.title,
                kcal: meal.kcal || 0,
                protein: meal.protein || 0,
                carbs: meal.carbs || 0,
                fat: meal.fat || 0,
                recipe_id: (meal as any).recipe_id || null,
              })),
            );
            setShowMeals(true);
          }
        })
        .catch(() => {});
    }
  }, [plan]);

  const calculatedKcal = protein * 4 + carbs * 4 + fat * 9;
  const hasDiscrepancy = Math.abs(calculatedKcal - kcal) > 5;

  const handleSave = async () => {
    if (!plan || !canEditPlan) return;

    const result = planSchema.safeParse({ name: planName, kcal, protein, carbs, fat });
    if (!result.success) {
      const firstIssue = result.error.issues[0];
      toast.error(firstIssue?.message || t('components.clientdetail.planeditor.invalid_plan_values'));
      return;
    }

    const activeMeals = meals.filter(
      (meal) => meal.title?.trim() && ((meal.kcal || 0) > 0 || (meal.protein || 0) > 0),
    );

    try {
      await updatePlan.mutateAsync({
        planId: plan.id,
        payload: {
          name: planName.trim() || plan.name,
          days: [1, 2, 3, 4, 5, 6, 7].map((weekday) => ({
            weekday,
            kcal_goal: kcal,
            protein_goal: protein,
            carbs_goal: carbs,
            fat_goal: fat,
          })),
          meals: activeMeals,
        },
      });
      toast.success(t('components.clientdetail.planeditor.plan_updated'));
      setHasChanges(false);
    } catch (err: any) {
      toast.error(t('components.clientdetail.planeditor.failed_to_update_plan'), {
        description: err?.message || t('components.clientdetail.planeditor.unknown_error'),
      });
    }
  };

  const handleActivate = async () => {
    if (!plan || !canEditPlan) return;
    try {
      await updatePlan.mutateAsync({
        planId: plan.id,
        payload: { status: 'active' },
      });
      toast.success(t('components.clientdetail.planeditor.plan_activated'));
    } catch {
      toast.error(t('components.clientdetail.planeditor.failed_to_activate_plan'));
    }
  };

  if (isLoading) {
    return (
      <div className="portal-panel flex min-h-[320px] items-center justify-center rounded-[1.6rem]">
        <Loader2 className="h-6 w-6 animate-spin text-primary" />
      </div>
    );
  }

  if (error || !plan) {
    return (
      <div className="portal-panel rounded-[1.6rem] p-6 text-center">
        <p className="text-sm text-muted-foreground">
          {t('components.clientdetail.planeditor.failed_to_load_plan_it_may_have_been_deleted')}
        </p>
        <button
          onClick={onBack}
          className="mt-4 rounded-xl border border-border px-4 py-2 text-sm font-semibold text-foreground hover:bg-accent"
        >
          {t('components.clientdetail.planeditor.back_to_plan_list')}
        </button>
      </div>
    );
  }

  return (
    <section className="portal-panel rounded-[1.6rem] p-6">
      <div className="mb-6 flex flex-col gap-4 border-b border-border pb-5 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-3">
          <button
            onClick={onBack}
            className="rounded-xl border border-border bg-card p-2 text-muted-foreground hover:bg-accent hover:text-foreground"
          >
            <ArrowLeft className="h-4 w-4" />
          </button>
          <div>
            <p className="portal-kicker">{t('components.clientdetail.planeditor.plan_editor')}</p>
            <h3 className="portal-title mt-2 text-2xl text-foreground">{plan.name}</h3>
          </div>
        </div>
        <div className="flex items-center gap-3">
          {plan.status !== 'active' ? (
            <button
              onClick={handleActivate}
              className="rounded-xl border border-primary/20 bg-primary/10 px-3 py-2 text-sm font-semibold text-primary"
            >
              {t('components.clientdetail.planeditor.mark_active')}
            </button>
          ) : null}
          <span className="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
            {plan.status === 'active' ? t('components.clientdetail.planeditor.active') : plan.status === 'draft' ? t('components.clientdetail.planeditor.draft') : plan.status}
          </span>
        </div>
      </div>

      {!canEditPlan ? (
        <Notice>
          <AlertTriangle className="mt-0.5 h-5 w-5 shrink-0 text-amber-500" />
          <div>
            <p className="font-bold">{t('components.clientdetail.planeditor.editing_unavailable')}</p>
            <p className="mt-1 text-sm leading-relaxed">
              {client.status !== 'connected'
                ? t('components.clientdetail.planeditor.this_relationship_is_so_the_plan_stays_read_only', { status_tolowercase: getRelationshipStatusLabel(client.status, t).toLowerCase() })
                : t('components.clientdetail.planeditor.professional_access_must_be_active_or_trialing_to_edit_or_activate_plans')}
            </p>
          </div>
        </Notice>
      ) : null}

      <div className="space-y-6">
        <Field label={t('components.clientdetail.planeditor.plan_name')}>
          <input
            value={planName}
            onChange={(event) => {
              setPlanName(event.target.value);
              setHasChanges(true);
            }}
            disabled={!canEditPlan}
            placeholder={t('components.clientdetail.planeditor.e_g_weekly_nutrition_plan')}
            className="portal-input h-11 w-full rounded-xl px-4 text-sm font-medium outline-none focus:border-primary"
          />
        </Field>

        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <MacroStepper label={t('common.protein')} unit={t('common.grams_unit')} value={protein} setValue={setProtein} step={5} disabled={!canEditPlan} onChange={() => setHasChanges(true)} caloriesPerUnit={4} kcalUnitLabel={t('common.kcal_unit')} />
          <MacroStepper label={t('common.carbs')} unit={t('common.grams_unit')} value={carbs} setValue={setCarbs} step={5} disabled={!canEditPlan} onChange={() => setHasChanges(true)} caloriesPerUnit={4} kcalUnitLabel={t('common.kcal_unit')} />
          <MacroStepper label={t('common.fat')} unit={t('common.grams_unit')} value={fat} setValue={setFat} step={5} disabled={!canEditPlan} onChange={() => setHasChanges(true)} caloriesPerUnit={9} kcalUnitLabel={t('common.kcal_unit')} />
          <MacroStepper label={t('common.kcal')} value={kcal} setValue={setKcal} step={50} disabled={!canEditPlan} onChange={() => setHasChanges(true)} kcalUnitLabel={t('common.kcal_unit')} />
        </div>

        {hasDiscrepancy ? (
          <Notice>
            <AlertTriangle className="mt-0.5 h-5 w-5 shrink-0 text-amber-500" />
            <div className="flex flex-1 flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <p className="font-bold">{t('components.clientdetail.planeditor.macro_discrepancy')}</p>
                <p className="mt-1 text-sm leading-relaxed">
                  {t('components.clientdetail.planeditor.the_macro_sum_yields_kcal_and_the_declared_target_is_kcal', { calculatedkcal: calculatedKcal, kcal: kcal })}
                </p>
              </div>
              <button
                onClick={() => {
                  setKcal(calculatedKcal);
                  setHasChanges(true);
                }}
                disabled={!canEditPlan}
                className="rounded-xl border border-amber-500/30 bg-amber-500/10 px-3 py-2 text-sm font-semibold text-amber-800 dark:text-amber-200"
              >
                {t('components.clientdetail.planeditor.autocorrect_kcal')}
              </button>
            </div>
          </Notice>
        ) : null}

        <div className="overflow-hidden rounded-[1.4rem] border border-border">
          <button
            onClick={() => setShowMeals(!showMeals)}
            className="flex w-full items-center justify-between px-5 py-4 text-left hover:bg-accent/50"
          >
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary/12 text-primary">
                <Utensils className="h-4 w-4" />
              </div>
              <div>
                <p className="text-sm font-bold text-foreground">
                  {t('components.clientdetail.planeditor.meal_configuration')}
                </p>
                <p className="text-xs text-muted-foreground">
                  {mealTotals.kcal} {t('common.kcal_unit')} · {mealTotals.protein}{t('common.protein_short')} · {mealTotals.carbs}{t('common.carbs_short')} · {mealTotals.fat}{t('common.fat_short')}
                </p>
              </div>
            </div>
            {showMeals ? <ChevronDown className="h-5 w-5 text-muted-foreground" /> : <ChevronRight className="h-5 w-5 text-muted-foreground" />}
          </button>

          {showMeals ? (
            <div className="space-y-4 border-t border-border px-5 py-4">
              <div className="rounded-xl border border-border bg-background/60 p-4">
                <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                  <span className="text-sm font-bold text-foreground">{t('components.clientdetail.planeditor.daily_distribution')}</span>
                  <span className="text-sm font-bold text-foreground">{mealTotals.kcal} / {kcal} {t('common.kcal_unit')}</span>
                </div>
                <div className="mt-2 flex gap-4 text-xs font-bold text-muted-foreground">
                  <span className="text-primary">{t('common.protein_short')}: {mealTotals.protein}/{protein}{t('common.grams_unit')}</span>
                  <span className="text-sky-500 dark:text-sky-300">{t('common.carbs_short')}: {mealTotals.carbs}/{carbs}{t('common.grams_unit')}</span>
                  <span className="text-amber-500 dark:text-amber-300">{t('common.fat_short')}: {mealTotals.fat}/{fat}{t('common.grams_unit')}</span>
                </div>
                <div className="mt-3 h-2 overflow-hidden rounded-full bg-background">
                  <div className="h-full rounded-full bg-primary transition-all duration-500" style={{ width: `${Math.min(100, (mealTotals.kcal / Math.max(1, kcal)) * 100)}%` }} />
                </div>
              </div>

              <div className="grid gap-4 sm:grid-cols-2">
                {meals.map((meal, index) => (
                  <div key={meal.slot} className="rounded-2xl border border-border bg-background/60 p-4">
                    <div className="flex items-center justify-between gap-2">
                      <span className="text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                        {mealSlotLabel(meal.slot)}
                      </span>
                      <button
                        onClick={() => setRecipePickerSlot(meal.slot)}
                        disabled={!canEditPlan}
                        className="inline-flex items-center gap-1 text-[10px] font-bold text-primary"
                      >
                        <BookOpen className="h-3.5 w-3.5" />
                        {meal.recipe_id ? t('components.clientdetail.planeditor.change_recipe') : t('components.clientdetail.planeditor.assign_recipe')}
                      </button>
                    </div>
                    <input
                      value={meal.title}
                      onChange={(event) => {
                        const next = [...meals];
                        next[index] = { ...next[index]!, title: event.target.value };
                        setMeals(next);
                        setHasChanges(true);
                      }}
                      disabled={!canEditPlan}
                      placeholder={t('components.clientdetail.planeditor.title', { meal_slot: mealSlotLabel(meal.slot) })}
                      className="portal-input mt-3 h-10 w-full rounded-xl px-3 text-sm font-medium outline-none focus:border-primary"
                    />
                    <div className="mt-3 grid grid-cols-4 gap-2">
                      {(['kcal', 'protein', 'carbs', 'fat'] as const).map((field) => (
                        <div key={field} className="space-y-1">
                          <label className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                            {field === 'protein' ? t('common.protein_short') : field === 'carbs' ? t('common.carbs_short') : field === 'fat' ? t('common.fat_short') : t('common.kcal')}
                          </label>
                          <input
                            type="number"
                            min={0}
                            value={(meal as any)[field] || ''}
                            onChange={(event) => {
                              const next = [...meals];
                              next[index] = {
                                ...next[index]!,
                                [field]: event.target.value ? +event.target.value : 0,
                              };
                              setMeals(next);
                              setHasChanges(true);
                            }}
                            disabled={!canEditPlan}
                            className="portal-input h-9 w-full rounded-lg px-2 text-center text-xs font-semibold outline-none focus:border-primary"
                          />
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>

              {recipePickerSlot ? (
                <RecipePickerModal
                  mealType={recipePickerSlot}
                  onSelect={(recipe) => {
                    setMeals((prev) =>
                      prev.map((meal) =>
                        meal.slot === recipePickerSlot
                          ? {
                              ...meal,
                              title: recipe.title,
                              kcal: recipe.kcal,
                              protein: recipe.protein,
                              carbs: recipe.carbs,
                              fat: recipe.fat,
                              recipe_id: recipe.id,
                            }
                          : meal,
                      ),
                    );
                    setHasChanges(true);
                    setRecipePickerSlot(null);
                  }}
                  onClose={() => setRecipePickerSlot(null)}
                />
              ) : null}
            </div>
          ) : null}
        </div>

        <div className="flex flex-col gap-4 border-t border-border pt-5 sm:flex-row sm:items-center sm:justify-between">
          <p className="text-xs text-muted-foreground">
            {t('components.clientdetail.planeditor.created_on')} {formatDateOnly(plan.created_at.slice(0, 10), undefined, locale)}
          </p>
          <button
            onClick={handleSave}
            disabled={!canEditPlan || !hasChanges || updatePlan.isPending}
            className="inline-flex items-center justify-center gap-2 rounded-xl bg-primary px-4 py-2 text-sm font-bold text-primary-foreground disabled:opacity-50"
          >
            {updatePlan.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
            {t('components.clientdetail.planeditor.save_changes')}
          </button>
        </div>
      </div>
    </section>
  );
};

const Field: React.FC<{ label: string; children: React.ReactNode }> = ({ label, children }) => (
  <div className="space-y-2">
    <label className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">{label}</label>
    {children}
  </div>
);

const Notice: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div className="mb-6 flex items-start gap-3 rounded-xl border border-amber-500/25 bg-amber-500/10 p-4 text-sm text-amber-900 dark:text-amber-100">
    {children}
  </div>
);

const MacroStepper: React.FC<{
  label: string;
  unit?: string;
  value: number;
  setValue: React.Dispatch<React.SetStateAction<number>>;
  step: number;
  disabled: boolean;
  onChange: () => void;
  caloriesPerUnit?: number;
  kcalUnitLabel: string;
}> = ({ label, unit = '', value, setValue, step, disabled, onChange, caloriesPerUnit, kcalUnitLabel }) => (
  <div className="rounded-2xl border border-border bg-background/60 p-4">
    <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
      {label}
      {unit ? ` (${unit})` : ''}
    </p>
    <div className="mt-3 flex items-center gap-2">
      <button
        onClick={() => {
          setValue((prev) => Math.max(1, prev - step));
          onChange();
        }}
        disabled={disabled}
        className="rounded-lg border border-border bg-background p-2 text-foreground disabled:opacity-50"
      >
        <Minus className="h-3.5 w-3.5" />
      </button>
      <input
        type="number"
        value={value}
        onChange={(event) => {
          setValue(Math.max(1, Number(event.target.value)));
          onChange();
        }}
        disabled={disabled}
        className="w-full bg-transparent text-center text-lg font-extrabold outline-none disabled:opacity-50"
      />
      <button
        onClick={() => {
          setValue((prev) => prev + step);
          onChange();
        }}
        disabled={disabled}
        className="rounded-lg border border-border bg-background p-2 text-foreground disabled:opacity-50"
      >
        <Plus className="h-3.5 w-3.5" />
      </button>
    </div>
    <p className="mt-2 text-center text-[11px] font-semibold text-muted-foreground">
      {caloriesPerUnit == null ? '' : `${value * caloriesPerUnit} ${kcalUnitLabel}`}
    </p>
  </div>
);
