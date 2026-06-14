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
  const { tr } = usePortalI18n();
  const billingSummary = getBillingSummary(professional);
  const { data: plan, isLoading, error } = usePlan(planId);
  const updatePlan = useUpdatePlan();

  const [planName, setPlanName] = useState('');
  const [hasChanges, setHasChanges] = useState(false);
  const [kcal, setKcal] = useState(0);
  const [protein, setProtein] = useState(0);
  const [carbs, setCarbs] = useState(0);
  const [fat, setFat] = useState(0);
  const [meals, setMeals] = useState<MealInput[]>([
    { slot: 'breakfast', title: 'Breakfast', kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'lunch', title: 'Lunch', kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'dinner', title: 'Dinner', kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'snack', title: 'Snack', kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
  ]);
  const [showMeals, setShowMeals] = useState(false);
  const [recipePickerSlot, setRecipePickerSlot] = useState<string | null>(null);

  const canEditPlan = billingSummary.hasProfessionalAccess && client.status === 'connected';

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

  const mealSlotLabel = (slot: string) =>
    ({
      breakfast: tr('Desayuno', 'Breakfast'),
      lunch: tr('Comida', 'Lunch'),
      dinner: tr('Cena', 'Dinner'),
      snack: tr('Snack', 'Snack'),
    })[slot] ?? slot;

  const handleSave = async () => {
    if (!plan || !canEditPlan) return;

    const result = planSchema.safeParse({ name: planName, kcal, protein, carbs, fat });
    if (!result.success) {
      const firstIssue = result.error.issues[0];
      toast.error(firstIssue?.message || tr('Valores del plan no válidos', 'Invalid plan values'));
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
      toast.success(tr('Plan actualizado', 'Plan updated'));
      setHasChanges(false);
    } catch (err: any) {
      toast.error(tr('No se pudo actualizar el plan', 'Failed to update plan'), {
        description: err?.message || tr('Error desconocido', 'Unknown error'),
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
      toast.success(tr('Plan activado', 'Plan activated'));
    } catch {
      toast.error(tr('No se pudo activar el plan', 'Failed to activate plan'));
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
          {tr('No se pudo cargar el plan. Puede que se haya eliminado.', 'Failed to load plan. It may have been deleted.')}
        </p>
        <button
          onClick={onBack}
          className="mt-4 rounded-xl border border-border px-4 py-2 text-sm font-semibold text-foreground hover:bg-accent"
        >
          {tr('Volver a la lista', 'Back to plan list')}
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
            <p className="portal-kicker">{tr('Plan editor', 'Plan editor')}</p>
            <h3 className="portal-title mt-2 text-2xl text-foreground">{plan.name}</h3>
          </div>
        </div>
        <div className="flex items-center gap-3">
          {plan.status !== 'active' ? (
            <button
              onClick={handleActivate}
              className="rounded-xl border border-primary/20 bg-primary/10 px-3 py-2 text-sm font-semibold text-primary"
            >
              {tr('Marcar activo', 'Mark active')}
            </button>
          ) : null}
          <span className="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
            {plan.status === 'active' ? tr('Activo', 'Active') : plan.status === 'draft' ? tr('Borrador', 'Draft') : plan.status}
          </span>
        </div>
      </div>

      {!canEditPlan ? (
        <Notice>
          <AlertTriangle className="mt-0.5 h-5 w-5 shrink-0 text-amber-500" />
          <div>
            <p className="font-bold">{tr('Edición no disponible', 'Editing unavailable')}</p>
            <p className="mt-1 text-sm leading-relaxed">
              {client.status !== 'connected'
                ? tr(
                    `Esta relación está ${getRelationshipStatusLabel(client.status).toLowerCase()}, así que el plan permanece en modo lectura.`,
                    `This relationship is ${getRelationshipStatusLabel(client.status).toLowerCase()}, so the plan stays read-only.`,
                  )
                : tr(
                    'El acceso profesional debe estar activo o en trial para editar o activar planes.',
                    'Professional access must be active or trialing to edit or activate plans.',
                  )}
            </p>
          </div>
        </Notice>
      ) : null}

      <div className="space-y-6">
        <Field label={tr('Nombre del plan', 'Plan name')}>
          <input
            value={planName}
            onChange={(event) => {
              setPlanName(event.target.value);
              setHasChanges(true);
            }}
            disabled={!canEditPlan}
            placeholder={tr('Ej. Plan nutricional semanal', 'E.g. Weekly nutrition plan')}
            className="portal-input h-11 w-full rounded-xl px-4 text-sm font-medium outline-none focus:border-primary"
          />
        </Field>

        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <MacroStepper label="Protein" unit="g" value={protein} setValue={setProtein} step={5} disabled={!canEditPlan} onChange={() => setHasChanges(true)} />
          <MacroStepper label="Carbs" unit="g" value={carbs} setValue={setCarbs} step={5} disabled={!canEditPlan} onChange={() => setHasChanges(true)} />
          <MacroStepper label="Fat" unit="g" value={fat} setValue={setFat} step={5} disabled={!canEditPlan} onChange={() => setHasChanges(true)} />
          <MacroStepper label="Kcal" value={kcal} setValue={setKcal} step={50} disabled={!canEditPlan} onChange={() => setHasChanges(true)} />
        </div>

        {hasDiscrepancy ? (
          <Notice>
            <AlertTriangle className="mt-0.5 h-5 w-5 shrink-0 text-amber-500" />
            <div className="flex flex-1 flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <p className="font-bold">{tr('Discrepancia de macros', 'Macro discrepancy')}</p>
                <p className="mt-1 text-sm leading-relaxed">
                  {tr(
                    `La suma de macros da ${calculatedKcal} kcal y el objetivo declarado es ${kcal} kcal.`,
                    `The macro sum yields ${calculatedKcal} kcal and the declared target is ${kcal} kcal.`,
                  )}
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
                {tr('Autocorregir kcal', 'Autocorrect kcal')}
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
                  {tr('Configuración de comidas', 'Meal configuration')}
                </p>
                <p className="text-xs text-muted-foreground">
                  {mealTotals.kcal} kcal · {mealTotals.protein}p · {mealTotals.carbs}c · {mealTotals.fat}f
                </p>
              </div>
            </div>
            {showMeals ? <ChevronDown className="h-5 w-5 text-muted-foreground" /> : <ChevronRight className="h-5 w-5 text-muted-foreground" />}
          </button>

          {showMeals ? (
            <div className="space-y-4 border-t border-border px-5 py-4">
              <div className="rounded-xl border border-border bg-background/60 p-4">
                <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                  <span className="text-sm font-bold text-foreground">{tr('Distribución diaria', 'Daily distribution')}</span>
                  <span className="text-sm font-bold text-foreground">{mealTotals.kcal} / {kcal} kcal</span>
                </div>
                <div className="mt-2 flex gap-4 text-xs font-bold text-muted-foreground">
                  <span className="text-primary">P: {mealTotals.protein}/{protein}g</span>
                  <span className="text-sky-500 dark:text-sky-300">C: {mealTotals.carbs}/{carbs}g</span>
                  <span className="text-amber-500 dark:text-amber-300">F: {mealTotals.fat}/{fat}g</span>
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
                        {meal.recipe_id ? tr('Cambiar receta', 'Change recipe') : tr('Asignar receta', 'Assign recipe')}
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
                      placeholder={tr(`${mealSlotLabel(meal.slot)}: nombre`, `${mealSlotLabel(meal.slot)} title`)}
                      className="portal-input mt-3 h-10 w-full rounded-xl px-3 text-sm font-medium outline-none focus:border-primary"
                    />
                    <div className="mt-3 grid grid-cols-4 gap-2">
                      {(['kcal', 'protein', 'carbs', 'fat'] as const).map((field) => (
                        <div key={field} className="space-y-1">
                          <label className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                            {field === 'protein' ? 'P' : field === 'carbs' ? 'C' : field === 'fat' ? 'F' : 'Kcal'}
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
            {tr('Creado el', 'Created on')} {formatDateOnly(plan.created_at.slice(0, 10))}
          </p>
          <button
            onClick={handleSave}
            disabled={!canEditPlan || !hasChanges || updatePlan.isPending}
            className="inline-flex items-center justify-center gap-2 rounded-xl bg-primary px-4 py-2 text-sm font-bold text-primary-foreground disabled:opacity-50"
          >
            {updatePlan.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
            {tr('Guardar cambios', 'Save changes')}
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
}> = ({ label, unit = '', value, setValue, step, disabled, onChange }) => (
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
      {label === 'Kcal' ? '' : `${label === 'Fat' ? value * 9 : value * 4} kcal`}
    </p>
  </div>
);
