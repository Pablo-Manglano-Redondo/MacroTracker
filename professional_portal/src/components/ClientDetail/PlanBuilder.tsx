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
  const { tr } = usePortalI18n();
  const billingSummary = getBillingSummary(professional);
  const template = loadTemplateDefaults();
  const [planName, setPlanName] = useState(template?.name || tr('Plan nutricional semanal', 'Weekly nutrition plan'));
  const [kcal, setKcal] = useState(template?.kcal || 2200);
  const [protein, setProtein] = useState(template?.protein || 160);
  const [carbs, setCarbs] = useState(template?.carbs || 250);
  const [fat, setFat] = useState(template?.fat || 70);
  const [published, setPublished] = useState(false);
  const [showMeals, setShowMeals] = useState(true);
  const [meals, setMeals] = useState<MealInput[]>([
    { slot: 'breakfast', title: 'Breakfast', kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'lunch', title: 'Lunch', kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'dinner', title: 'Dinner', kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'snack', title: 'Snack', kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
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
  const hasActivePro = billingSummary.hasProfessionalAccess;
  const canPublishPlan = hasActivePro && client.status === 'connected';

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

  const mealSlotLabel = (slot: string) =>
    ({
      breakfast: tr('Desayuno', 'Breakfast'),
      lunch: tr('Comida', 'Lunch'),
      dinner: tr('Cena', 'Dinner'),
      snack: tr('Snack', 'Snack'),
    })[slot] ?? slot;

  const validate = (): boolean => {
    if (!professional) {
      toast.error(tr('Guarda primero tu perfil.', 'Save your profile first.'));
      return false;
    }
    if (!billingSummary.hasProfessionalAccess) {
      toast.error(
        tr(
          'El acceso profesional debe estar activo o en trial para publicar planes.',
          'Professional access must be active or trialing to publish plans.',
        ),
      );
      return false;
    }
    if (client.status !== 'connected') {
      toast.error(
        tr(
          `Esta relación está ${getRelationshipStatusLabel(client.status).toLowerCase()}, así que nuevos planes deben seguir bloqueados.`,
          `This relationship is ${getRelationshipStatusLabel(client.status).toLowerCase()}, so new plans should stay blocked.`,
        ),
      );
      return false;
    }
    const result = planSchema.safeParse({ name: planName, kcal, protein, carbs, fat });
    if (!result.success) {
      const firstIssue = result.error.issues[0];
      if (firstIssue?.path[0] === 'name') {
        toast.error(tr('El nombre del plan es obligatorio.', 'Plan name is required.'));
      } else {
        toast.error(firstIssue?.message || tr('Valores del plan no válidos', 'Invalid plan values'));
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
              ? tr(`Plan publicado para ${client.display_name}`, `Plan published for ${client.display_name}`)
              : tr('Plan publicado', 'Plan published'),
          );
          setTimeout(() => setPublished(false), 5000);
        },
        onError: (err: any) => {
          toast.error(tr('No se pudo publicar el plan', 'Failed to publish plan'), {
            description: err?.message || tr('Error desconocido', 'Unknown error'),
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
          tr(`Comida movida de ${data.fromSlot} a ${targetSlot}`, `Moved meal from ${data.fromSlot} to ${targetSlot}`),
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
        toast.success(tr(`Receta asignada a ${targetSlot}`, `Assigned recipe to ${targetSlot}`));
      }
    } catch {
      toast.error(tr('No se pudo soltar la receta', 'Failed to drop recipe'));
    }
  };

  return (
    <div className="grid grid-cols-1 gap-6 lg:grid-cols-12">
      <div className="space-y-6 lg:col-span-8">
        <section className="portal-panel rounded-[1.6rem] p-6">
          <div className="mb-6 flex flex-col gap-4 border-b border-border pb-5 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p className="portal-kicker">{tr('Plan builder', 'Plan builder')}</p>
              <h3 className="portal-title mt-2 text-2xl text-foreground">
                {tr('Publicar un plan semanal', 'Publish a weekly plan')}
              </h3>
            </div>
            <button
              onClick={handlePublish}
              disabled={publishMutation.isPending || !canPublishPlan}
              className="rounded-xl bg-primary px-4 py-2 text-sm font-bold text-primary-foreground disabled:opacity-50"
            >
              {publishMutation.isPending
                ? tr('Publicando...', 'Publishing...')
                : tr('Publicar plan', 'Publish plan')}
            </button>
          </div>

          {!canPublishPlan ? (
            <Notice tone="warn">
              <AlertTriangle className="mt-0.5 h-5 w-5 shrink-0 text-amber-500" />
              <div>
                <p className="font-bold">{tr('Publicación no disponible', 'Publishing unavailable')}</p>
                <p className="mt-1 text-sm leading-relaxed">
                  {client.status !== 'connected'
                    ? tr(
                        `Esta relación está ${getRelationshipStatusLabel(client.status).toLowerCase()}, así que el portal no debe publicar nuevos planes.`,
                        `This relationship is ${getRelationshipStatusLabel(client.status).toLowerCase()}, so the portal should not publish new plans.`,
                      )
                    : tr(
                        'El acceso profesional debe estar activo o en trial para publicar planes.',
                        'Professional access must be active or trialing to publish plans.',
                      )}
                </p>
              </div>
            </Notice>
          ) : null}

          {published ? (
            <Notice tone="good">
              <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-primary" />
              <div>
                <p className="font-bold">{tr('Plan publicado correctamente', 'Plan published successfully')}</p>
              </div>
            </Notice>
          ) : null}

          <div className="space-y-6">
            <Field label={tr('Nombre del plan', 'Plan name')}>
              <input
                value={planName}
                onChange={(event) => setPlanName(event.target.value)}
                placeholder={tr('Ej. Plan nutricional semanal', 'E.g. Weekly nutrition plan')}
                className="portal-input h-11 w-full rounded-xl px-4 text-sm font-medium outline-none focus:border-primary"
              />
            </Field>

            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
              <MacroStepper label="Protein" unit="g" value={protein} setValue={setProtein} step={5} tone="emerald" />
              <MacroStepper label="Carbs" unit="g" value={carbs} setValue={setCarbs} step={5} tone="blue" />
              <MacroStepper label="Fat" unit="g" value={fat} setValue={setFat} step={5} tone="amber" />
              <MacroStepper label="Kcal" value={kcal} setValue={setKcal} step={50} tone="rose" />
            </div>

            <Notice tone={hasDiscrepancy ? 'warn' : 'good'}>
              {hasDiscrepancy ? (
                <AlertTriangle className="mt-0.5 h-5 w-5 shrink-0 text-amber-500" />
              ) : (
                <Calculator className="mt-0.5 h-5 w-5 shrink-0 text-primary" />
              )}
              <div className="flex flex-1 flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <p className="font-bold">
                    {hasDiscrepancy
                      ? tr('Hay discrepancia entre macros y kcal', 'There is a macro/kcal discrepancy')
                      : tr('Macros y kcal alineados', 'Calories and macros are aligned')}
                  </p>
                  <p className="mt-1 text-sm leading-relaxed">
                    {tr(
                      `La suma de macros da ${calculatedKcal} kcal y el objetivo declarado es ${kcal} kcal.`,
                      `The macro sum yields ${calculatedKcal} kcal and the declared target is ${kcal} kcal.`,
                    )}
                  </p>
                </div>
                {hasDiscrepancy ? (
                  <button
                    onClick={() => setKcal(calculatedKcal)}
                    className="rounded-xl border border-amber-500/30 bg-amber-500/10 px-3 py-2 text-sm font-semibold text-amber-800 dark:text-amber-200"
                  >
                    {tr('Autocorregir kcal', 'Autocorrect kcal')}
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
                    <p className="text-sm font-bold text-foreground">
                      {tr('Configuración de comidas', 'Meal configuration')}
                    </p>
                    <p className="text-xs text-muted-foreground">
                      {mealTotals.kcal} kcal · {mealTotals.protein}p · {mealTotals.carbs}c · {mealTotals.fat}f
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
                      <span className="text-sm font-bold text-foreground">
                        {tr('Distribución diaria', 'Daily distribution')}
                      </span>
                      <span className="text-sm font-bold text-foreground">
                        {mealTotals.kcal} / {kcal} kcal
                      </span>
                    </div>
                    <div className="mt-2 flex gap-4 text-xs font-bold text-muted-foreground">
                      <span className="text-primary">P: {mealTotals.protein}/{protein}g</span>
                      <span className="text-sky-500 dark:text-sky-300">C: {mealTotals.carbs}/{carbs}g</span>
                      <span className="text-amber-500 dark:text-amber-300">F: {mealTotals.fat}/{fat}g</span>
                    </div>
                    <div className="mt-3 h-2 overflow-hidden rounded-full bg-background">
                      <div
                        className="h-full rounded-full bg-primary transition-all duration-500"
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
                              <span className="text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
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
                                      tr(`Bloque ${mealSlotLabel(meal.slot)} limpiado`, `${mealSlotLabel(meal.slot)} cleared`),
                                    );
                                  }}
                                  className="inline-flex items-center gap-1 text-[10px] font-bold text-rose-500"
                                >
                                  <Trash2 className="h-3 w-3" />
                                  {tr('Limpiar', 'Clear')}
                                </button>
                              ) : null}
                              <button
                                type="button"
                                onClick={() => setRecipePickerSlot(meal.slot)}
                                className="inline-flex items-center gap-1 text-[10px] font-bold text-primary"
                              >
                                <BookOpen className="h-3 w-3" />
                                {meal.recipe_id ? tr('Cambiar', 'Change') : tr('Asignar', 'Assign')}
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
                                    const targetIndex = next.findIndex((item) => item.slot === meal.slot);
                                    if (targetIndex !== -1) {
                                      next[targetIndex] = {
                                        ...next[targetIndex]!,
                                        [field]: event.target.value ? +event.target.value : 0,
                                      };
                                    }
                                    setMeals(next);
                                  }}
                                  className="portal-input h-9 w-full rounded-lg px-2 text-center text-xs font-semibold outline-none focus:border-primary"
                                />
                              </div>
                            ))}
                          </div>

                          {!hasContent ? (
                            <div className="mt-3 rounded-xl border border-dashed border-border bg-background px-3 py-4 text-center">
                              <ChefHat className="mx-auto h-5 w-5 text-muted-foreground" />
                              <p className="mt-1 text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">
                                {tr('Slot vacío', 'Empty slot')}
                              </p>
                              <p className="mt-1 text-[11px] text-muted-foreground">
                                {tr('Arrastra una receta o usa Asignar.', 'Drag a recipe or use Assign.')}
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
              <h4 className="text-base font-bold text-foreground">{tr('Biblioteca de recetas', 'Recipe library')}</h4>
            </div>
            <p className="mt-1 text-sm text-muted-foreground">
              {tr('Arrastra recetas al timeline o asígnalas por slot.', 'Drag recipes into the timeline or assign them by slot.')}
            </p>
          </div>

          <div className="relative mb-3">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
            <input
              value={searchQuery}
              onChange={(event) => setSearchQuery(event.target.value)}
              placeholder={tr('Buscar recetas', 'Search recipes')}
              className="portal-input h-10 w-full rounded-xl pl-9 pr-8 text-sm font-medium outline-none focus:border-primary"
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

          <div className="mb-4 grid grid-cols-5 gap-1 rounded-xl border border-border bg-background p-1">
            {(['all', 'breakfast', 'lunch', 'dinner', 'snack'] as const).map((category) => (
              <button
                key={category}
                type="button"
                onClick={() => setActiveCategory(category)}
                className={`rounded-lg px-1 py-1.5 text-[10px] font-bold uppercase tracking-[0.14em] transition-colors ${
                  activeCategory === category
                    ? 'bg-primary text-primary-foreground'
                    : 'text-muted-foreground hover:text-foreground'
                }`}
              >
                {category === 'all' ? tr('Todo', 'All') : mealSlotLabel(category)}
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
              <div className="py-8 text-center text-sm text-muted-foreground">
                {tr('No hay recetas para este filtro.', 'No matching recipes for this filter.')}
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
                      <p className="truncate text-sm font-semibold text-foreground">{recipe.title}</p>
                      <span className="rounded-full bg-primary/10 px-2 py-0.5 text-[10px] font-bold text-primary">
                        {recipe.meal_type ? mealSlotLabel(recipe.meal_type) : tr('Snack', 'Snack')}
                      </span>
                    </div>
                    <div className="mt-1 flex flex-wrap items-center gap-x-2 gap-y-0.5 text-[10px] font-bold text-muted-foreground">
                      <span>{recipe.kcal || 0} kcal</span>
                      <span className="text-primary">P: {recipe.protein || 0}g</span>
                      <span className="text-sky-500 dark:text-sky-300">C: {recipe.carbs || 0}g</span>
                      <span className="text-amber-500 dark:text-amber-300">F: {recipe.fat || 0}g</span>
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
    <label className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">{label}</label>
    {children}
  </div>
);

const Notice: React.FC<{ tone: 'warn' | 'good'; children: React.ReactNode }> = ({ tone, children }) => (
  <div
    className={`mb-6 flex items-start gap-3 rounded-xl border p-4 text-sm ${
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
}> = ({ label, unit = '', value, setValue, step, tone }) => {
  const toneClass = {
    emerald: 'text-primary bg-primary/6',
    blue: 'text-sky-600 dark:text-sky-300 bg-sky-500/6',
    amber: 'text-amber-600 dark:text-amber-300 bg-amber-500/6',
    rose: 'text-rose-600 dark:text-rose-300 bg-rose-500/6',
  }[tone];

  return (
    <div className={`rounded-2xl border border-border p-4 ${toneClass}`}>
      <p className="text-[10px] font-bold uppercase tracking-[0.16em]">{label}{unit ? ` (${unit})` : ''}</p>
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
          className="w-full bg-transparent text-center text-lg font-extrabold outline-none"
        />
        <button
          onClick={() => setValue((prev) => prev + step)}
          className="rounded-lg border border-border bg-background p-2 text-foreground"
        >
          <Plus className="h-3.5 w-3.5" />
        </button>
      </div>
      <p className="mt-2 text-center text-[11px] font-semibold text-muted-foreground">
        {label === 'Kcal' ? '' : `${label === 'Fat' ? value * 9 : value * 4} kcal`}
      </p>
    </div>
  );
};
