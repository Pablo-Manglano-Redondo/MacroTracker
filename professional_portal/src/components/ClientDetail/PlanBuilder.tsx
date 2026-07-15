import React, { useMemo, useState } from 'react';
import {
  AlertTriangle,
  BookOpen,
  Calculator,
  CheckCircle2,
  ChevronDown,
  ChevronRight,
  ChefHat,
  GripVertical,
  Minus,
  Plus,
  Search,
  Trash2,
  Utensils,
  X,
} from 'lucide-react';
import { useAuth } from '../../lib/auth-context';
import { usePublishPlan, type MealInput } from '../../hooks/mutations/usePublishPlan';
import { useRecipes } from '../../hooks/queries/useRecipes';
import type { ProfessionalClient, ProfessionalRecipe } from '../../types/database.types';
import { toast } from '../../lib/toast';
import { planSchema } from '../../lib/validation/schemas';
import { RecipePickerModal } from './RecipePickerModal';
import { getBillingSummary } from '../../view-models/professional';
import { getRelationshipStatusLabel } from '../../view-models/clients';
import { usePortalI18n } from '../../lib/portal-i18n';

interface PlanBuilderProps {
  client: ProfessionalClient;
}

function loadTemplateDefaults(): { name: string; kcal: number; protein: number; carbs: number; fat: number } | null {
  try {
    const raw = sessionStorage.getItem('apply-template');
    if (!raw) return null;
    sessionStorage.removeItem('apply-template');
    const data = JSON.parse(raw);
    const macros = Array.isArray(data.meals) && data.meals.length > 0 ? data.meals[0] : {};
    return {
      name: data.name || 'Weekly nutrition plan',
      kcal: macros.kcal ?? 2200,
      protein: macros.protein ?? 160,
      carbs: macros.carbs ?? 250,
      fat: macros.fat ?? 70,
    };
  } catch {
    return null;
  }
}

export const PlanBuilder: React.FC<PlanBuilderProps> = ({ client }) => {
  const { professional } = useAuth();
  const { t, locale } = usePortalI18n();
  const isEs = locale?.toLowerCase().startsWith('es');
  const billingSummary = getBillingSummary(professional);
  const template = loadTemplateDefaults();
  const mealSlotLabel = (slot: string) =>
    ({
      breakfast: t('components.clientdetail.planbuilder.breakfast'),
      lunch: t('components.clientdetail.planbuilder.lunch'),
      dinner: t('components.clientdetail.planbuilder.dinner'),
      snack: t('components.clientdetail.planbuilder.snack'),
    })[slot] ?? slot;
  const [planName, setPlanName] = useState(template?.name || t('components.clientdetail.planbuilder.weekly_nutrition_plan'));
  const [kcal, setKcal] = useState(template?.kcal || 2200);
  const [protein, setProtein] = useState(template?.protein || 160);
  const [carbs, setCarbs] = useState(template?.carbs || 250);
  const [fat, setFat] = useState(template?.fat || 70);
  const [published, setPublished] = useState(false);
  const [showMeals, setShowMeals] = useState(true);
  const [meals, setMeals] = useState<MealInput[]>([
    { slot: 'breakfast', title: mealSlotLabel('breakfast'), kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'lunch', title: mealSlotLabel('lunch'), kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'dinner', title: mealSlotLabel('dinner'), kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'snack', title: mealSlotLabel('snack'), kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
  ]);
  const [recipePickerSlot, setRecipePickerSlot] = useState<string | null>(null);
  const [dragOverSlot, setDragOverSlot] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState<'all' | 'breakfast' | 'lunch' | 'dinner' | 'snack'>('all');

  const { data: recipes, isLoading: recipesLoading } = useRecipes(professional?.id);
  const publishMutation = usePublishPlan();

  const mealTotals = useMemo(
    () => ({
      kcal: meals.reduce((sum, meal) => sum + (meal.kcal || 0), 0),
      protein: meals.reduce((sum, meal) => sum + (meal.protein || 0), 0),
      carbs: meals.reduce((sum, meal) => sum + (meal.carbs || 0), 0),
      fat: meals.reduce((sum, meal) => sum + (meal.fat || 0), 0),
    }),
    [meals],
  );

  const calculatedKcal = protein * 4 + carbs * 4 + fat * 9;
  const hasDiscrepancy = Math.abs(calculatedKcal - kcal) > 5;
  const canPublishPlan = billingSummary.canPublishPlans && client.status === 'connected';

  const filteredRecipes = useMemo(
    () =>
      (recipes || []).filter((recipe) => {
        const matchesSearch = recipe.title.toLowerCase().includes(searchQuery.toLowerCase());
        if (activeCategory === 'all') return matchesSearch;
        if (activeCategory === 'snack') {
          return matchesSearch && (recipe.meal_type === 'snack' || recipe.meal_type === null);
        }
        return matchesSearch && recipe.meal_type === activeCategory;
      }),
    [recipes, searchQuery, activeCategory],
  );

  const validate = (): boolean => {
    if (!professional) {
      toast.error(t('components.clientdetail.planbuilder.save_your_profile_first'));
      return false;
    }
    if (!billingSummary.canPublishPlans) {
      toast.error(
        t('components.clientdetail.planbuilder.professional_access_must_be_active_or_trialing_to_publish_plans'),
      );
      return false;
    }
    if (client.status !== 'connected') {
      toast.error(
        t('components.clientdetail.planbuilder.this_relationship_is_so_new_plans_should_stay_blocked', { status_tolowercase: getRelationshipStatusLabel(client.status, t).toLowerCase() }),
      );
      return false;
    }
    const result = planSchema.safeParse({ name: planName, kcal, protein, carbs, fat });
    if (!result.success) {
      const firstIssue = result.error.issues[0];
      if (firstIssue?.path[0] === 'name') {
        toast.error(t('components.clientdetail.planbuilder.plan_name_is_required'));
      } else {
        toast.error(firstIssue?.message || t('components.clientdetail.planbuilder.invalid_plan_values'));
      }
      return false;
    }
    return true;
  };

  const handlePublish = () => {
    if (!validate()) return;
    const activeMeals = meals.filter(
      (meal) => meal.title?.trim() && ((meal.kcal || 0) > 0 || (meal.protein || 0) > 0),
    );

    publishMutation.mutate(
      {
        professional_id: professional!.id,
        client_id: client.client_id,
        name: planName.trim(),
        kcal,
        protein,
        carbs,
        fat,
        meals: activeMeals,
      },
      {
        onSuccess: () => {
          setPublished(true);
          toast.success(
            client.display_name
              ? t('components.clientdetail.planbuilder.plan_published_for', { client_display_name: client.display_name })
              : t('components.clientdetail.planbuilder.plan_published'),
          );
          setTimeout(() => setPublished(false), 5000);
        },
        onError: (err: any) => {
          toast.error(t('components.clientdetail.planbuilder.failed_to_publish_plan'), {
            description: err?.message || t('components.clientdetail.planbuilder.unknown_error'),
          });
        },
      },
    );
  };

  const handleRecipeDragStart = (event: React.DragEvent, recipe: ProfessionalRecipe) => {
    event.dataTransfer.setData(
      'application/json',
      JSON.stringify({
        id: recipe.id,
        title: recipe.title,
        kcal: recipe.kcal || 0,
        protein: recipe.protein || 0,
        carbs: recipe.carbs || 0,
        fat: recipe.fat || 0,
        source: 'library',
      }),
    );
    event.dataTransfer.effectAllowed = 'copy';
  };

  const handleMealDragStart = (event: React.DragEvent, sourceSlot: string, meal: MealInput) => {
    if (!meal.recipe_id && !meal.title) return;
    event.dataTransfer.setData(
      'application/json',
      JSON.stringify({
        id: meal.recipe_id,
        title: meal.title,
        kcal: meal.kcal || 0,
        protein: meal.protein || 0,
        carbs: meal.carbs || 0,
        fat: meal.fat || 0,
        source: 'meal',
        fromSlot: sourceSlot,
      }),
    );
    event.dataTransfer.effectAllowed = 'move';
  };

  const handleDrop = (event: React.DragEvent, targetSlot: string) => {
    event.preventDefault();
    setDragOverSlot(null);
    try {
      const rawData = event.dataTransfer.getData('application/json');
      if (!rawData) return;
      const data = JSON.parse(rawData);

      if (data.source === 'meal' && data.fromSlot) {
        if (data.fromSlot === targetSlot) return;
        setMeals((prev) =>
          prev.map((meal) => {
            if (meal.slot === targetSlot) {
              return {
                ...meal,
                title: data.title,
                kcal: data.kcal,
                protein: data.protein,
                carbs: data.carbs,
                fat: data.fat,
                recipe_id: data.id,
              };
            }
            if (meal.slot === data.fromSlot) {
              return {
                ...meal,
                title: '',
                kcal: 0,
                protein: 0,
                carbs: 0,
                fat: 0,
                recipe_id: null,
              };
            }
            return meal;
          }),
        );
        toast.success(
          t('components.clientdetail.planbuilder.moved_meal_from_to', { data_fromslot: data.fromSlot, targetslot: targetSlot }),
        );
      } else {
        setMeals((prev) =>
          prev.map((meal) =>
            meal.slot === targetSlot
              ? {
                  ...meal,
                  title: data.title,
                  kcal: data.kcal,
                  protein: data.protein,
                  carbs: data.carbs,
                  fat: data.fat,
                  recipe_id: data.id,
                }
              : meal,
          ),
        );
        toast.success(t('components.clientdetail.planbuilder.assigned_recipe_to', { targetslot: targetSlot }));
      }
    } catch {
      toast.error(t('components.clientdetail.planbuilder.failed_to_drop_recipe'));
    }
  };

  return (
    <div className="grid grid-cols-1 gap-6 lg:grid-cols-12">
      <div className="space-y-6 lg:col-span-8">
        <section className="portal-panel rounded-[1.6rem] p-6">
          <div className="mb-6 flex flex-col gap-4 border-b border-border pb-5 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p className="portal-kicker">{t('components.clientdetail.planbuilder.plan_builder')}</p>
              <h3 className="portal-section-heading mt-2">
                {t('components.clientdetail.planbuilder.publish_a_weekly_plan')}
              </h3>
            </div>
            <button
              onClick={handlePublish}
              disabled={publishMutation.isPending || !canPublishPlan}
              className="rounded-xl bg-primary px-4 py-2 portal-action text-primary-foreground disabled:opacity-50"
            >
              {publishMutation.isPending
                ? t('components.clientdetail.planbuilder.publishing')
                : t('components.clientdetail.planbuilder.publish_plan')}
            </button>
          </div>

          {!canPublishPlan ? (
            <Notice tone="warn">
              <AlertTriangle className="mt-0.5 h-5 w-5 shrink-0 text-amber-500" />
              <div>
                <p className="portal-card-heading">{t('components.clientdetail.planbuilder.publishing_unavailable')}</p>
                <p className="portal-body mt-1">
                  {client.status !== 'connected'
                    ? t('components.clientdetail.planbuilder.this_relationship_is_so_the_portal_should_not_publish_new_plans', { status_tolowercase: getRelationshipStatusLabel(client.status, t).toLowerCase() })
                    : t('components.clientdetail.planbuilder.professional_access_must_be_active_or_trialing_to_publish_plans')}
                </p>
              </div>
            </Notice>
          ) : null}

          {published ? (
            <Notice tone="good">
              <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-primary" />
              <div>
                <p className="portal-card-heading">{t('components.clientdetail.planbuilder.plan_published_successfully')}</p>
              </div>
            </Notice>
          ) : null}

          <div className="space-y-6">
            <Field label={t('components.clientdetail.planbuilder.plan_name')}>
              <input
                value={planName}
                onChange={(event) => setPlanName(event.target.value)}
                placeholder={t('components.clientdetail.planbuilder.e_g_weekly_nutrition_plan')}
                className="portal-input h-11 w-full rounded-xl px-4 outline-none focus:border-primary"
              />
            </Field>

            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
              <MacroStepper label={t('common.protein')} unit={t('common.grams_unit')} value={protein} setValue={setProtein} step={5} tone="emerald" caloriesPerUnit={4} kcalUnitLabel={t('common.kcal_unit')} />
              <MacroStepper label={t('common.carbs')} unit={t('common.grams_unit')} value={carbs} setValue={setCarbs} step={5} tone="blue" caloriesPerUnit={4} kcalUnitLabel={t('common.kcal_unit')} />
              <MacroStepper label={t('common.fat')} unit={t('common.grams_unit')} value={fat} setValue={setFat} step={5} tone="amber" caloriesPerUnit={9} kcalUnitLabel={t('common.kcal_unit')} />
              <MacroStepper label={t('common.kcal')} value={kcal} setValue={setKcal} step={50} tone="rose" kcalUnitLabel={t('common.kcal_unit')} />
            </div>

            <Notice tone={hasDiscrepancy ? 'warn' : 'good'}>
              {hasDiscrepancy ? (
                <AlertTriangle className="mt-0.5 h-5 w-5 shrink-0 text-amber-500" />
              ) : (
                <Calculator className="mt-0.5 h-5 w-5 shrink-0 text-primary" />
              )}
              <div className="flex flex-1 flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <p className="portal-card-heading">
                    {hasDiscrepancy
                      ? t('components.clientdetail.planbuilder.there_is_a_macro_kcal_discrepancy')
                      : t('components.clientdetail.planbuilder.calories_and_macros_are_aligned')}
                  </p>
                  <p className="portal-body mt-1">
                    {t('components.clientdetail.planbuilder.the_macro_sum_yields_kcal_and_the_declared_target_is_kcal', { calculatedkcal: calculatedKcal, kcal: kcal })}
                  </p>
                </div>
                {hasDiscrepancy ? (
                  <button
                    onClick={() => setKcal(calculatedKcal)}
                    className="portal-meta rounded-xl border border-amber-500/30 bg-amber-500/10 px-3 py-2 text-amber-800 dark:text-amber-200"
                  >
                    {t('components.clientdetail.planbuilder.autocorrect_kcal')}
                  </button>
                ) : null}
              </div>
            </Notice>

            <div className="overflow-hidden rounded-[1.4rem] border border-border">
              <button
                type="button"
                onClick={() => setShowMeals(!showMeals)}
                className="flex w-full items-center justify-between px-5 py-4 text-left hover:bg-accent/50"
              >
                <div className="flex items-center gap-3">
                  <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary/12 text-primary">
                    <Utensils className="h-4 w-4" />
                  </div>
                  <div>
                    <p className="portal-card-heading">
                      {t('components.clientdetail.planbuilder.meal_configuration')}
                    </p>
                    <p className="portal-meta">
                      {mealTotals.kcal} {t('common.kcal_unit')} · {mealTotals.protein}{t('common.protein_short')} · {mealTotals.carbs}{t('common.carbs_short')} · {mealTotals.fat}{t('common.fat_short')}
                    </p>
                  </div>
                </div>
                {showMeals ? (
                  <ChevronDown className="h-5 w-5 text-muted-foreground" />
                ) : (
                  <ChevronRight className="h-5 w-5 text-muted-foreground" />
                )}
              </button>

              {showMeals ? (
                <div className="space-y-4 border-t border-border px-5 py-4">
                  <div className="rounded-xl border border-border bg-background/60 p-4">
                    <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                      <span className="portal-card-heading">
                        {t('components.clientdetail.planbuilder.daily_distribution')}
                      </span>
                      <span className={`portal-card-heading ${mealTotals.kcal > kcal ? 'text-rose-500 font-bold' : ''}`}>
                        {mealTotals.kcal} / {kcal} {t('common.kcal_unit')}
                      </span>
                    </div>
                    <div className="portal-meta mt-2 flex gap-4">
                      <span className={mealTotals.protein > protein ? 'text-rose-500 font-bold' : 'text-primary'}>
                        {t('common.protein_short')}: {mealTotals.protein}/{protein}{t('common.grams_unit')}
                      </span>
                      <span className={mealTotals.carbs > carbs ? 'text-rose-500 font-bold' : 'text-sky-500 dark:text-sky-300'}>
                        {t('common.carbs_short')}: {mealTotals.carbs}/{carbs}{t('common.grams_unit')}
                      </span>
                      <span className={mealTotals.fat > fat ? 'text-rose-500 font-bold' : 'text-amber-500 dark:text-amber-300'}>
                        {t('common.fat_short')}: {mealTotals.fat}/{fat}{t('common.grams_unit')}
                      </span>
                    </div>
                    <div className="mt-3 h-2 overflow-hidden rounded-full bg-background">
                      <div
                        className={`h-full rounded-full transition-all duration-500 ${
                          mealTotals.kcal > kcal
                            ? 'bg-rose-500'
                            : Math.abs(mealTotals.kcal - kcal) <= 5
                              ? 'bg-emerald-500 dark:bg-emerald-400'
                              : 'bg-primary'
                        }`}
                        style={{ width: `${Math.min(100, (mealTotals.kcal / Math.max(1, kcal)) * 100)}%` }}
                      />
                    </div>
                  </div>

                  <div className="grid gap-4 sm:grid-cols-2">
                    {meals.map((meal) => {
                      const isHovered = dragOverSlot === meal.slot;
                      const hasContent = !!meal.title || (meal.kcal || 0) > 0;
                      return (
                        <div
                          key={meal.slot}
                          draggable={hasContent}
                          onDragStart={(event) => handleMealDragStart(event, meal.slot, meal)}
                          onDragOver={(event) => {
                            event.preventDefault();
                            setDragOverSlot(meal.slot);
                          }}
                          onDragLeave={() => setDragOverSlot(null)}
                          onDrop={(event) => handleDrop(event, meal.slot)}
                          className={`rounded-2xl border p-4 transition-all ${
                            isHovered ? 'border-primary bg-primary/8' : 'border-border bg-background/60'
                          } ${hasContent ? 'cursor-grab active:cursor-grabbing' : ''}`}
                        >
                          <div className="flex items-center justify-between gap-2">
                            <div className="flex items-center gap-2">
                              {hasContent ? <GripVertical className="h-3.5 w-3.5 text-muted-foreground" /> : null}
                              <span className="portal-label text-primary">
                                {mealSlotLabel(meal.slot)}
                              </span>
                            </div>
                            <div className="flex items-center gap-2">
                              {hasContent ? (
                                <button
                                  type="button"
                                  onClick={() => {
                                    setMeals((prev) =>
                                      prev.map((item) =>
                                        item.slot === meal.slot
                                          ? {
                                              ...item,
                                              title: '',
                                              kcal: 0,
                                              protein: 0,
                                              carbs: 0,
                                              fat: 0,
                                              recipe_id: null,
                                            }
                                          : item,
                                      ),
                                    );
                                    toast.success(
                                      t('components.clientdetail.planbuilder.cleared', { meal_slot: mealSlotLabel(meal.slot) }),
                                    );
                                  }}
                                  className="inline-flex items-center gap-1 portal-label text-rose-500"
                                >
                                  <Trash2 className="h-3 w-3" />
                                  {t('components.clientdetail.planbuilder.clear')}
                                </button>
                              ) : null}
                              <button
                                type="button"
                                onClick={() => setRecipePickerSlot(meal.slot)}
                                className="inline-flex items-center gap-1 portal-label text-primary"
                              >
                                <BookOpen className="h-3 w-3" />
                                {meal.recipe_id ? t('components.clientdetail.planbuilder.change') : t('components.clientdetail.planbuilder.assign')}
                              </button>
                            </div>
                          </div>

                          <input
                            value={meal.title}
                            onChange={(event) => {
                              const next = [...meals];
                              const targetIndex = next.findIndex((item) => item.slot === meal.slot);
                              if (targetIndex !== -1) {
                                next[targetIndex] = { ...next[targetIndex]!, title: event.target.value };
                              }
                              setMeals(next);
                            }}
                            placeholder={t('components.clientdetail.planbuilder.title', { meal_slot: mealSlotLabel(meal.slot) })}
                            className="portal-input mt-3 h-10 w-full rounded-xl px-3 outline-none focus:border-primary"
                          />

                          <div className="mt-3 grid grid-cols-4 gap-2">
                            {(['kcal', 'protein', 'carbs', 'fat'] as const).map((field) => (
                              <div key={field} className="space-y-1">
                                <label className="portal-label">
                                  {field === 'protein' ? t('common.protein_short') : field === 'carbs' ? t('common.carbs_short') : field === 'fat' ? t('common.fat_short') : t('common.kcal')}
                                </label>
                                <input
                                  type="number"
                                  min={0}
                                  value={(meal as any)[field] || ''}
                                  onChange={(event) => {
                                    const next = [...meals];
                                    const targetIndex = next.findIndex((item) => item.slot === meal.slot);
                                    if (targetIndex !== -1) {
                                      next[targetIndex] = {
                                        ...next[targetIndex]!,
                                        [field]: event.target.value ? +event.target.value : 0,
                                      };
                                    }
                                    setMeals(next);
                                  }}
                                  className="portal-input h-9 w-full rounded-lg px-2 text-center outline-none focus:border-primary"
                                />
                              </div>
                            ))}
                          </div>

                          {!hasContent ? (
                            <div className="mt-3 rounded-xl border border-dashed border-border bg-background px-3 py-4 text-center">
                              <ChefHat className="mx-auto h-5 w-5 text-muted-foreground" />
                              <p className="portal-label mt-1">
                                {t('components.clientdetail.planbuilder.empty_slot')}
                              </p>
                              <p className="portal-meta mt-1">
                                {t('components.clientdetail.planbuilder.drag_a_recipe_or_use_assign')}
                              </p>
                            </div>
                          ) : null}
                        </div>
                      );
                    })}
                  </div>
                </div>
              ) : null}
            </div>
          </div>
        </section>

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
              setRecipePickerSlot(null);
            }}
            onClose={() => setRecipePickerSlot(null)}
          />
        ) : null}
      </div>

      <aside className="space-y-4 self-start lg:sticky lg:top-6 lg:col-span-4">
        <section className="portal-panel flex max-h-[85vh] flex-col rounded-[1.6rem] p-5">
          <div className="mb-3 border-b border-border pb-4">
            <div className="flex items-center gap-2">
              <ChefHat className="h-4.5 w-4.5 text-primary" />
              <h4 className="portal-card-heading">{t('components.clientdetail.planbuilder.recipe_library')}</h4>
            </div>
            <p className="portal-meta mt-1">
              {t('components.clientdetail.planbuilder.drag_recipes_into_the_timeline_or_assign_them_by_slot')}
            </p>
          </div>

          <div className="relative mb-3">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
            <input
              value={searchQuery}
              onChange={(event) => setSearchQuery(event.target.value)}
              placeholder={t('components.clientdetail.planbuilder.search_recipes')}
              className="portal-input h-10 w-full rounded-xl pl-9 pr-8 outline-none focus:border-primary"
            />
            {searchQuery ? (
              <button
                onClick={() => setSearchQuery('')}
                className="absolute right-2.5 top-1/2 -translate-y-1/2 rounded-md p-0.5 hover:bg-accent"
              >
                <X className="h-3 w-3 text-muted-foreground" />
              </button>
            ) : null}
          </div>

          <div className="mb-4 flex flex-wrap gap-1.5">
            {(['all', 'breakfast', 'lunch', 'dinner', 'snack'] as const).map((category) => (
              <button
                key={category}
                type="button"
                onClick={() => setActiveCategory(category)}
                className={`rounded-lg px-2.5 py-1.5 portal-action transition-colors border text-[10px] ${
                  activeCategory === category
                    ? 'bg-primary text-primary-foreground border-primary'
                    : 'bg-background text-muted-foreground border-border/80 hover:text-foreground hover:bg-accent'
                }`}
              >
                {category === 'all' ? t('components.clientdetail.planbuilder.all') : mealSlotLabel(category)}
              </button>
            ))}
          </div>

          <div className="min-h-0 flex-1 space-y-2 overflow-y-auto pr-1">
            {recipesLoading ? (
              <div className="space-y-2">
                {[1, 2, 3, 4].map((index) => (
                  <div key={index} className="portal-panel h-16 rounded-xl animate-pulse" />
                ))}
              </div>
            ) : filteredRecipes.length === 0 ? (
              <div className="portal-body py-8 text-center text-muted-foreground">
                {t('components.clientdetail.planbuilder.no_matching_recipes_for_this_filter')}
              </div>
            ) : (
              filteredRecipes.map((recipe) => (
                <div
                  key={recipe.id}
                  draggable
                  onDragStart={(event) => handleRecipeDragStart(event, recipe)}
                  className="flex cursor-grab items-start gap-2.5 rounded-xl border border-border bg-card p-3 transition-colors hover:bg-accent"
                >
                  <div className="flex shrink-0 items-center self-center text-muted-foreground">
                    <GripVertical className="h-3.5 w-3.5" />
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-start justify-between gap-2">
                      <p className="portal-meta truncate text-foreground">{recipe.title}</p>
                      <span className="rounded-full bg-primary/10 px-2 py-0.5 portal-pill text-primary">
                        {recipe.meal_type ? mealSlotLabel(recipe.meal_type) : t('components.clientdetail.planbuilder.snack')}
                      </span>
                    </div>
                    <div className="mt-1 flex flex-wrap items-center gap-x-2 gap-y-0.5 portal-label">
                      <span>{recipe.kcal || 0} {t('common.kcal_unit')}</span>
                      <span className="text-primary">{t('common.protein_short')}: {recipe.protein || 0}{t('common.grams_unit')}</span>
                      <span className="text-sky-500 dark:text-sky-300">{t('common.carbs_short')}: {recipe.carbs || 0}{t('common.grams_unit')}</span>
                      <span className="text-amber-500 dark:text-amber-300">{t('common.fat_short')}: {recipe.fat || 0}{t('common.grams_unit')}</span>
                    </div>
                    <div className="mt-2.5 flex items-center justify-between border-t border-border/40 pt-2">
                      <span className="text-[9px] font-medium text-muted-foreground">
                        {isEs ? 'Asignar:' : 'Assign:'}
                      </span>
                      <div className="flex gap-1">
                        {(['breakfast', 'lunch', 'dinner', 'snack'] as const).map((slot) => (
                          <button
                            key={slot}
                            type="button"
                            onClick={() => {
                              setMeals((prev) =>
                                prev.map((meal) =>
                                  meal.slot === slot
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
                              toast.success(
                                isEs
                                  ? `Receta asignada a ${mealSlotLabel(slot)}`
                                  : `Recipe assigned to ${mealSlotLabel(slot)}`
                              );
                            }}
                            className="rounded bg-primary/10 px-1.5 py-0.5 text-[9px] font-bold text-primary transition-colors hover:bg-primary hover:text-primary-foreground"
                          >
                            {mealSlotLabel(slot).slice(0, 3)}
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </section>
      </aside>
    </div>
  );
};

const Field: React.FC<{ label: string; children: React.ReactNode }> = ({ label, children }) => (
  <div className="space-y-2">
    <label className="portal-label">{label}</label>
    {children}
  </div>
);

const Notice: React.FC<{ tone: 'warn' | 'good'; children: React.ReactNode }> = ({ tone, children }) => (
  <div
    className={`portal-body mb-6 flex items-start gap-3 rounded-xl border p-4 ${
      tone === 'warn'
        ? 'border-amber-500/25 bg-amber-500/10 text-amber-900 dark:text-amber-100'
        : 'border-primary/25 bg-primary/10 text-foreground'
    }`}
  >
    {children}
  </div>
);

const MacroStepper: React.FC<{
  label: string;
  unit?: string;
  value: number;
  setValue: React.Dispatch<React.SetStateAction<number>>;
  step: number;
  tone: 'emerald' | 'blue' | 'amber' | 'rose';
  caloriesPerUnit?: number;
  kcalUnitLabel: string;
}> = ({ label, unit = '', value, setValue, step, tone, caloriesPerUnit, kcalUnitLabel }) => {
  const toneClass = {
    emerald: 'text-primary bg-primary/6',
    blue: 'text-sky-600 dark:text-sky-300 bg-sky-500/6',
    amber: 'text-amber-600 dark:text-amber-300 bg-amber-500/6',
    rose: 'text-rose-600 dark:text-rose-300 bg-rose-500/6',
  }[tone];

  return (
    <div className={`rounded-2xl border border-border p-4 ${toneClass}`}>
      <p className="portal-label text-current">{label}{unit ? ` (${unit})` : ''}</p>
      <div className="mt-3 flex items-center gap-2">
        <button
          onClick={() => setValue((prev) => Math.max(1, prev - step))}
          className="rounded-lg border border-border bg-background p-2 text-foreground"
        >
          <Minus className="h-3.5 w-3.5" />
        </button>
        <input
          type="number"
          value={value}
          onChange={(event) => setValue(Math.max(1, Number(event.target.value)))}
          className="flex-1 min-w-0 bg-transparent text-center text-xl font-extrabold outline-none focus:ring-0 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
        />
        <button
          onClick={() => setValue((prev) => prev + step)}
          className="rounded-lg border border-border bg-background p-2 text-foreground"
        >
          <Plus className="h-3.5 w-3.5" />
        </button>
      </div>
      <p className="portal-meta mt-2 text-center">
        {caloriesPerUnit == null ? '' : `${value * caloriesPerUnit} ${kcalUnitLabel}`}
      </p>
    </div>
  );
};
