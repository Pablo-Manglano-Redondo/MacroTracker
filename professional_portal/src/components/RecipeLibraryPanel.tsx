import React, { useMemo, useState } from 'react';
import { createPortal } from 'react-dom';
import {
  ChefHat,
  Clock,
  GripVertical,
  Pencil,
  Plus,
  PlusCircle,
  Search,
  Send,
  Trash2,
  Users,
  Utensils,
  X,
} from 'lucide-react';
import { toast } from 'sonner';
import { useAuth } from '../lib/auth-context';
import { useRecipes } from '../hooks/queries/useRecipes';
import {
  useCreateRecipe,
  useDeleteRecipe,
  useProposeRecipe,
} from '../hooks/mutations/useCreateRecipe';
import { useUpdateRecipe } from '../hooks/mutations/useUpdateRecipe';
import { useClients } from '../hooks/queries/useClients';
import { ConfirmDialog } from './ui/confirm-dialog';
import type { ProfessionalRecipe } from '../types/database.types';
import { usePortalI18n } from '../lib/portal-i18n';

const MEAL_TYPES = ['all', 'breakfast', 'lunch', 'dinner', 'snack'] as const;

interface Ingredient {
  name: string;
  amount: number;
  unit: string;
}

function emptyForm() {
  return {
    title: '',
    description: '',
    meal_type: 'breakfast' as string,
    prep_time_min: 0,
    cook_time_min: 0,
    servings: 1,
    kcal: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    ingredients: [] as Ingredient[],
    instructions: '',
  };
}

function recipeToForm(r: ProfessionalRecipe) {
  const raw = Array.isArray(r.ingredients) ? r.ingredients : [];
  return {
    title: r.title,
    description: r.description || '',
    meal_type: r.meal_type || 'breakfast',
    prep_time_min: r.prep_time_min || 0,
    cook_time_min: r.cook_time_min || 0,
    servings: r.servings || 1,
    kcal: r.kcal || 0,
    protein: r.protein || 0,
    carbs: r.carbs || 0,
    fat: r.fat || 0,
    ingredients: raw.map((i: any) => ({
      name: String(i.name ?? ''),
      amount: Number(i.amount ?? 0),
      unit: String(i.unit ?? 'g'),
    })),
    instructions: r.instructions || '',
  };
}

export const RecipeLibraryPanel: React.FC = () => {
  const { professional } = useAuth();
  const { t } = usePortalI18n();
  const { data: recipes, isLoading } = useRecipes(professional?.id);
  const { data: clients } = useClients(professional?.id);
  const createRecipe = useCreateRecipe(professional?.id);
  const deleteRecipe = useDeleteRecipe(professional?.id);
  const proposeRecipe = useProposeRecipe();
  const updateRecipe = useUpdateRecipe(professional?.id);

  const [search, setSearch] = useState('');
  const [mealFilter, setMealFilter] = useState<string>('all');
  const [showForm, setShowForm] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [proposeTarget, setProposeTarget] = useState<{ recipeId: string } | null>(null);
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);
  const [form, setForm] = useState(emptyForm());

  const filtered = useMemo(
    () =>
      (recipes || []).filter((recipe) => {
        if (mealFilter !== 'all' && recipe.meal_type !== mealFilter) {
          return false;
        }
        if (search && !recipe.title.toLowerCase().includes(search.toLowerCase())) {
          return false;
        }
        return true;
      }),
    [mealFilter, recipes, search],
  );

  const openCreate = () => {
    setEditingId(null);
    setForm(emptyForm());
    setShowForm(true);
  };

  const openEdit = (recipe: ProfessionalRecipe) => {
    setEditingId(recipe.id);
    setForm(recipeToForm(recipe));
    setShowForm(true);
  };

  const handleSave = async () => {
    if (!form.title.trim()) {
      toast.error(t('components.recipelibrarypanel.recipe_title_required'));
      return;
    }
    try {
      const payload = {
        professional_id: professional!.id,
        title: form.title,
        description: form.description || null,
        meal_type: form.meal_type as any,
        prep_time_min: form.prep_time_min || null,
        cook_time_min: form.cook_time_min || null,
        servings: form.servings || null,
        kcal: form.kcal || null,
        protein: form.protein || null,
        carbs: form.carbs || null,
        fat: form.fat || null,
        ingredients: form.ingredients,
        instructions: form.instructions || null,
      };

      if (editingId) {
        await updateRecipe.mutateAsync({ id: editingId, updates: payload });
        toast.success(t('components.recipelibrarypanel.recipe_updated'));
      } else {
        await createRecipe.mutateAsync(payload as any);
        toast.success(t('components.recipelibrarypanel.recipe_created'));
      }
      setShowForm(false);
    } catch {
      toast.error(
        editingId
          ? t('components.recipelibrarypanel.failed_to_update_recipe')
          : t('components.recipelibrarypanel.failed_to_create_recipe'),
      );
    }
  };

  const handlePropose = async (clientId: string, note: string) => {
    if (!proposeTarget || !professional) {
      return;
    }
    const client = clients?.find((c) => c.client_id === clientId);
    if (!client) {
      toast.error(t('components.recipelibrarypanel.select_a_client'));
      return;
    }
    try {
      await proposeRecipe.mutateAsync({
        professional_client_id: client.id,
        recipe_id: proposeTarget.recipeId,
        professional_id: professional.id,
        client_id: clientId,
        note: note || undefined,
      });
      toast.success(t('components.recipelibrarypanel.recipe_proposed_to_client'));
      setProposeTarget(null);
    } catch {
      toast.error(t('components.recipelibrarypanel.failed_to_propose_recipe'));
    }
  };

  const addIngredient = () => {
    setForm((previous) => ({
      ...previous,
      ingredients: [...previous.ingredients, { name: '', amount: 0, unit: 'g' }],
    }));
  };

  const removeIngredient = (index: number) => {
    setForm((previous) => ({
      ...previous,
      ingredients: previous.ingredients.filter((_, idx) => idx !== index),
    }));
  };

  const updateIngredient = (
    index: number,
    field: 'name' | 'amount' | 'unit',
    value: string | number,
  ) => {
    setForm((previous) => {
      const ingredients = previous.ingredients.map((ingredient, idx) => {
        if (idx !== index) {
          return ingredient;
        }
        if (field === 'name') {
          return { ...ingredient, name: value as string };
        }
        if (field === 'amount') {
          return { ...ingredient, amount: value as number };
        }
        return { ...ingredient, unit: value as string };
      });
      return { ...previous, ingredients };
    });
  };

  const mealLabel = (meal: string) =>
    ({
      breakfast: t('components.recipelibrarypanel.breakfast'),
      lunch: t('components.recipelibrarypanel.lunch'),
      dinner: t('components.recipelibrarypanel.dinner'),
      snack: t('components.recipelibrarypanel.snack'),
      all: t('components.recipelibrarypanel.all'),
    })[meal] ?? meal;

  return (
    <div id="tour-recipes-panel" className="space-y-6 animate-fade-in-up">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <h2 className="portal-section-heading uppercase tracking-[0.12em] text-foreground">
          {t('components.recipelibrarypanel.recipe_library')}
        </h2>
        <button
          onClick={openCreate}
          className="inline-flex h-12 items-center gap-2 rounded-xl bg-primary px-5 portal-action text-primary-foreground shadow-sm hover:opacity-95 transition-opacity shrink-0"
        >
          <Plus className="h-4.5 w-4.5" />
          <span>{t('components.recipelibrarypanel.new_recipe')}</span>
        </button>
      </div>

      <section className="grid gap-4 md:grid-cols-3">
        <StatCard
          label={t('components.recipelibrarypanel.visible_recipes')}
          value={filtered.length}
          note={t('components.recipelibrarypanel.result_after_search_and_filter')}
        />
        <StatCard
          label={t('components.recipelibrarypanel.library_total')}
          value={recipes?.length ?? 0}
          note={t('components.recipelibrarypanel.stored_resources')}
        />
        <StatCard
          label={t('components.recipelibrarypanel.connected_clients')}
          value={(clients || []).filter((client) => client.status === 'connected').length}
          note={t('components.recipelibrarypanel.possible_recipients_for_a_proposal')}
        />
      </section>

      <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
        <div className="flex flex-1 flex-col gap-4 sm:flex-row sm:items-center">
          <div className="relative w-full max-w-sm">
            <Search className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder={t('components.recipelibrarypanel.search_recipes')}
              className="portal-input h-12 w-full rounded-xl pl-10 pr-4 outline-none focus:border-primary"
            />
          </div>

          <div className="flex flex-wrap gap-2">
            {MEAL_TYPES.map((meal) => (
              <button
                key={meal}
                onClick={() => setMealFilter(meal)}
                className={`rounded-full px-5 py-2.5 portal-action transition-colors ${
                  mealFilter === meal
                    ? 'bg-primary text-primary-foreground'
                    : 'portal-chip hover:bg-accent'
                }`}
              >
                {mealLabel(meal)}
              </button>
            ))}
          </div>
        </div>
      </div>

      {isLoading ? (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {[1, 2, 3].map((index) => (
            <div key={index} className="portal-panel h-56 rounded-[1.6rem] animate-pulse" />
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <div className="portal-panel flex min-h-[320px] flex-col items-center justify-center rounded-[1.6rem] p-10 text-center">
          <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10 text-primary">
            <Utensils className="h-8 w-8" />
          </div>
          <h3 className="portal-title mt-5 text-foreground">
            {t('components.recipelibrarypanel.no_recipes_to_show')}
          </h3>
          <p className="portal-body mt-2 max-w-sm text-muted-foreground">
            {t('components.recipelibrarypanel.create_a_new_recipe_or_adjust_the_search_and_filter_to_see_results')}
          </p>
        </div>
      ) : (
        <div className="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
          {filtered.map((recipe) => (
            <article key={recipe.id} className="portal-panel flex flex-col rounded-2xl p-6 shadow-sm">
              {/* Header */}
              <div className="flex items-start justify-between gap-3">
                <div className="flex min-w-0 items-center gap-2.5">
                  <ChefHat className="h-5 w-5 shrink-0 text-primary" />
                  <h3 className="portal-card-heading truncate text-foreground">{recipe.title}</h3>
                </div>
                <div className="flex shrink-0 gap-0.5">
                  <IconAction
                    title={t('components.recipelibrarypanel.edit_recipe')}
                    onClick={() => openEdit(recipe)}
                    icon={<Pencil className="h-4 w-4" />}
                  />
                  <IconAction
                    title={t('components.recipelibrarypanel.propose_to_client')}
                    onClick={() => setProposeTarget({ recipeId: recipe.id })}
                    icon={<Send className="h-4 w-4" />}
                  />
                  <IconAction
                    title={t('components.recipelibrarypanel.delete_recipe')}
                    onClick={() => setDeleteConfirm(recipe.id)}
                    icon={<Trash2 className="h-4 w-4" />}
                    danger
                  />
                </div>
              </div>

              {/* Description */}
              {recipe.description && (
                <p className="portal-body mt-2 line-clamp-2 text-muted-foreground">
                  {recipe.description}
                </p>
              )}

              {/* Chips */}
              <div className="mt-3 flex flex-wrap items-center gap-2">
                {recipe.meal_type && (
                  <span className="portal-pill inline-flex items-center rounded-md border border-border/70 bg-card px-2.5 py-1 text-foreground">
                    {mealLabel(recipe.meal_type)}
                  </span>
                )}
                {recipe.prep_time_min ? (
                  <span className="portal-pill inline-flex items-center gap-1.5 rounded-md border border-border/70 bg-card px-2.5 py-1 text-muted-foreground">
                    <Clock className="h-3.5 w-3.5" />
                    {t('components.recipelibrarypanel.prep_min', { recipe_prep_time_min: recipe.prep_time_min })}
                  </span>
                ) : null}
                {recipe.servings ? (
                  <span className="portal-pill inline-flex items-center gap-1.5 rounded-md border border-border/70 bg-card px-2.5 py-1 text-muted-foreground">
                    <Users className="h-3.5 w-3.5" />
                    {t('components.recipelibrarypanel.serves', { recipe_servings: recipe.servings })}
                  </span>
                ) : null}
              </div>

              {/* Macros */}
              <div className="mt-4 grid grid-cols-4 gap-px rounded-xl border border-border/60 bg-border/40 overflow-hidden">
                <MacroCell label={t('common.kcal')} value={recipe.kcal} accent="text-rose-500" />
                <MacroCell label={t('common.protein_short')} value={recipe.protein} suffix={t('common.grams_unit')} accent="text-emerald-500" />
                <MacroCell label={t('common.carbs_short')} value={recipe.carbs} suffix={t('common.grams_unit')} accent="text-sky-500" />
                <MacroCell label={t('common.fat_short')} value={recipe.fat} suffix={t('common.grams_unit')} accent="text-amber-500" />
              </div>
            </article>
          ))}
        </div>
      )}

      {showForm &&
        createPortal(
          <div
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm"
            onClick={() => setShowForm(false)}
          >
            <div
              className="glass-card flex max-h-[85vh] w-full max-w-3xl flex-col rounded-[1.8rem] overflow-hidden"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between border-b border-border p-6 pb-4 shrink-0">
                <div>
                  <h3 className="portal-card-heading text-foreground">
                    {editingId
                      ? t('components.recipelibrarypanel.edit_recipe')
                      : t('components.recipelibrarypanel.create_recipe')}
                  </h3>
                  <p className="portal-meta text-muted-foreground">
                    {t('components.recipelibrarypanel.macros_ingredients_and_instructions_for_the_professional_library')}
                  </p>
                </div>
                <button
                  onClick={() => setShowForm(false)}
                  className="rounded-xl p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto p-6 space-y-6 custom-scrollbar">
                <div className="grid gap-4 md:grid-cols-2">
                <Field label={t('components.recipelibrarypanel.title')} required className="md:col-span-2">
                  <input
                    value={form.title}
                    onChange={(e) => setForm((prev) => ({ ...prev, title: e.target.value }))}
                    className="portal-input h-12 w-full rounded-xl px-4 outline-none focus:border-primary"
                  />
                </Field>
                <Field label={t('components.recipelibrarypanel.description')} className="md:col-span-2">
                  <textarea
                    value={form.description}
                    onChange={(e) =>
                      setForm((prev) => ({ ...prev, description: e.target.value }))
                    }
                    rows={2}
                    className="portal-input w-full rounded-xl px-5 py-4 outline-none focus:border-primary"
                  />
                </Field>
                <Field label={t('components.recipelibrarypanel.meal_type')}>
                  <select
                    value={form.meal_type}
                    onChange={(e) => setForm((prev) => ({ ...prev, meal_type: e.target.value }))}
                    className="portal-input h-12 w-full rounded-xl px-4 outline-none"
                  >
                    {MEAL_TYPES.filter((meal) => meal !== 'all').map((meal) => (
                      <option key={meal} value={meal}>
                        {mealLabel(meal)}
                      </option>
                    ))}
                  </select>
                </Field>
                <Field label={t('components.recipelibrarypanel.servings')}>
                  <input
                    type="number"
                    min={1}
                    value={form.servings}
                    onChange={(e) => setForm((prev) => ({ ...prev, servings: +e.target.value }))}
                    className="portal-input h-12 w-full rounded-xl px-4 outline-none focus:border-primary"
                  />
                </Field>
                <Field label={t('components.recipelibrarypanel.prep_min_2')}>
                  <input
                    type="number"
                    value={form.prep_time_min}
                    onChange={(e) =>
                      setForm((prev) => ({ ...prev, prep_time_min: +e.target.value }))
                    }
                    className="portal-input h-12 w-full rounded-xl px-4 outline-none focus:border-primary"
                  />
                </Field>
                <Field label={t('components.recipelibrarypanel.cook_min')}>
                  <input
                    type="number"
                    value={form.cook_time_min}
                    onChange={(e) =>
                      setForm((prev) => ({ ...prev, cook_time_min: +e.target.value }))
                    }
                    className="portal-input h-12 w-full rounded-xl px-4 outline-none focus:border-primary"
                  />
                </Field>

                <div className="md:col-span-2 rounded-2xl border border-border bg-background/60 p-4">
                  <p className="portal-label text-muted-foreground">
                    {t('components.recipelibrarypanel.macros')}
                  </p>
                  <div className="mt-3 grid grid-cols-2 gap-3 md:grid-cols-4">
                    {[
                      { label: t('common.kcal'), value: form.kcal, key: 'kcal' as const },
                      { label: t('common.protein'), value: form.protein, key: 'protein' as const },
                      { label: t('common.carbs'), value: form.carbs, key: 'carbs' as const },
                      { label: t('common.fat'), value: form.fat, key: 'fat' as const },
                    ].map((macro) => (
                      <Field key={macro.key} label={macro.label}>
                        <input
                          type="number"
                          value={macro.value}
                          onChange={(e) =>
                            setForm((prev) => ({ ...prev, [macro.key]: +e.target.value }))
                          }
                          className="portal-input h-10 w-full rounded-xl px-3 outline-none focus:border-primary"
                        />
                      </Field>
                    ))}
                  </div>
                </div>

                <div className="md:col-span-2 rounded-2xl border border-border bg-background/60 p-4">
                  <div className="mb-3 flex items-center justify-between">
                    <p className="portal-label text-muted-foreground">
                      {t('components.recipelibrarypanel.ingredients')}
                    </p>
                    <button
                      onClick={addIngredient}
                      className="inline-flex items-center gap-1 portal-action text-primary"
                    >
                      <PlusCircle className="h-4 w-4" />
                      {t('components.recipelibrarypanel.add_ingredient')}
                    </button>
                  </div>

                  <div className="space-y-2">
                    {form.ingredients.map((ingredient, index) => (
                      <div key={index} className="grid grid-cols-[18px_minmax(0,1fr)_88px_92px_36px] gap-2">
                        <div className="flex items-center justify-center text-muted-foreground">
                          <GripVertical className="h-4 w-4" />
                        </div>
                        <input
                          value={ingredient.name}
                          onChange={(e) => updateIngredient(index, 'name', e.target.value)}
                          placeholder={t('components.recipelibrarypanel.ingredient')}
                          className="portal-input h-10 rounded-xl px-3 outline-none focus:border-primary"
                        />
                        <input
                          type="number"
                          value={ingredient.amount || ''}
                          onChange={(e) => updateIngredient(index, 'amount', +e.target.value)}
                          className="portal-input h-10 rounded-xl px-3 outline-none focus:border-primary"
                        />
                        <select
                          value={ingredient.unit}
                          onChange={(e) => updateIngredient(index, 'unit', e.target.value)}
                          className="portal-input h-10 rounded-xl px-3 outline-none"
                        >
                          {['g', 'ml', 'tsp', 'tbsp', 'cup', 'oz', 'lb', 'unit', 'slice', 'piece'].map(
                            (unit) => (
                              <option key={unit} value={unit}>
                                {unit}
                              </option>
                            ),
                          )}
                        </select>
                        <button
                          onClick={() => removeIngredient(index)}
                          className="rounded-xl text-muted-foreground transition-colors hover:bg-rose-500/10 hover:text-rose-500"
                        >
                          <X className="mx-auto h-4 w-4" />
                        </button>
                      </div>
                    ))}
                    {form.ingredients.length === 0 && (
                      <p className="portal-meta text-muted-foreground">
                        {t('components.recipelibrarypanel.no_ingredients_yet')}
                      </p>
                    )}
                  </div>
                </div>

                <Field label={t('components.recipelibrarypanel.instructions')} className="md:col-span-2">
                  <textarea
                    value={form.instructions}
                    onChange={(e) =>
                      setForm((prev) => ({ ...prev, instructions: e.target.value }))
                    }
                    rows={4}
                    placeholder={t('components.recipelibrarypanel.describe_the_preparation_step_by_step')}
                    className="portal-input w-full rounded-xl px-4 py-3 outline-none focus:border-primary"
                  />
                </Field>
              </div>
              </div>

              <div className="flex justify-end gap-3 border-t border-border p-6 pt-4 shrink-0">
                <button
                  onClick={() => setShowForm(false)}
                  className="rounded-xl border border-border px-4 py-2 portal-action text-foreground transition-colors hover:bg-accent"
                >
                  {t('components.recipelibrarypanel.cancel')}
                </button>
                <button
                  onClick={handleSave}
                  disabled={createRecipe.isPending || updateRecipe.isPending}
                  className="rounded-xl bg-primary px-4 py-2 portal-action text-primary-foreground disabled:opacity-50"
                >
                  {createRecipe.isPending || updateRecipe.isPending
                    ? t('components.recipelibrarypanel.saving')
                    : editingId
                      ? t('components.recipelibrarypanel.update_recipe')
                      : t('components.recipelibrarypanel.create_recipe')}
                </button>
              </div>
            </div>
          </div>,
          document.body,
        )}

      <ConfirmDialog
        open={deleteConfirm !== null}
        title={t('components.recipelibrarypanel.delete_recipe')}
        message={t('components.recipelibrarypanel.this_action_cannot_be_undone_the_recipe_will_be_permanently_removed_from')}
        onConfirm={() => {
          if (deleteConfirm) {
            deleteRecipe.mutate(deleteConfirm);
          }
          setDeleteConfirm(null);
        }}
        onCancel={() => setDeleteConfirm(null)}
        loading={deleteRecipe.isPending}
      />

      {proposeTarget && (
        <ProposeModal clients={clients || []} onSubmit={handlePropose} onClose={() => setProposeTarget(null)} />
      )}
    </div>
  );
};

function ProposeModal({
  clients,
  onSubmit,
  onClose,
}: {
  clients: { client_id: string; id: string; display_name?: string | null }[];
  onSubmit: (clientId: string, note: string) => void;
  onClose: () => void;
}) {
  const { t } = usePortalI18n();
  const [clientId, setClientId] = useState('');
  const [note, setNote] = useState('');

  return createPortal(
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm" onClick={onClose}>
      <div className="glass-card w-full max-w-sm rounded-[1.8rem] p-6" onClick={(e) => e.stopPropagation()}>
        <div className="mb-4 flex items-center justify-between border-b border-border pb-3">
          <div>
            <h3 className="portal-card-heading text-foreground">{t('components.recipelibrarypanel.propose_recipe')}</h3>
            <p className="portal-meta text-muted-foreground">
              {t('components.recipelibrarypanel.send_to_a_connected_client')}
            </p>
          </div>
          <button onClick={onClose} className="rounded-xl p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground">
            <X className="h-4 w-4" />
          </button>
        </div>
        <div className="space-y-4">
          <Field label={t('components.recipelibrarypanel.connected_client')}>
            <select
              value={clientId}
              onChange={(e) => setClientId(e.target.value)}
              className="portal-input h-11 w-full rounded-xl px-4 outline-none"
            >
              <option value="">{t('components.recipelibrarypanel.select_a_client_2')}</option>
              {clients.map((client) => (
                <option key={client.id} value={client.client_id}>
                  {client.display_name || client.client_id.slice(0, 8)}
                </option>
              ))}
            </select>
          </Field>
          <Field label={t('components.recipelibrarypanel.optional_note')}>
            <textarea
              value={note}
              onChange={(e) => setNote(e.target.value)}
              rows={2}
              placeholder={t('components.recipelibrarypanel.e_g_try_this_option_for_dinner')}
              className="portal-input w-full rounded-xl px-4 py-3 outline-none focus:border-primary"
            />
          </Field>
          <div className="flex justify-end gap-3 border-t border-border pt-4">
            <button
              onClick={onClose}
              className="rounded-xl border border-border px-4 py-2 portal-action text-foreground transition-colors hover:bg-accent"
            >
              {t('components.recipelibrarypanel.cancel')}
            </button>
            <button
              onClick={() => onSubmit(clientId, note)}
              disabled={!clientId}
              className="rounded-xl bg-primary px-4 py-2 portal-action text-primary-foreground disabled:opacity-50"
            >
              {t('components.recipelibrarypanel.send_proposal')}
            </button>
          </div>
        </div>
      </div>
    </div>,
    document.body,
  );
}

const StatCard: React.FC<{ label: string; value: number; note: string }> = ({
  label,
  value,
  note,
}) => (
  <div className="portal-panel rounded-[1.4rem] p-6">
    <p className="portal-label text-muted-foreground">{label}</p>
    <p className="portal-metric mt-2 text-foreground">{value}</p>
    <p className="portal-meta mt-1 text-muted-foreground">{note}</p>
  </div>
);

const IconAction: React.FC<{
  title: string;
  onClick: () => void;
  icon: React.ReactNode;
  danger?: boolean;
}> = ({ title, onClick, icon, danger = false }) => (
  <button
    onClick={onClick}
    title={title}
    className={`rounded-xl p-2 transition-colors ${
      danger
        ? 'text-muted-foreground hover:bg-rose-500/10 hover:text-rose-500'
        : 'text-muted-foreground hover:bg-primary/10 hover:text-primary'
    }`}
  >
    {icon}
  </button>
);

const MacroCell: React.FC<{
  label: string;
  value: number | null | undefined;
  suffix?: string;
  accent?: string;
}> = ({ label, value, suffix = '', accent = 'text-muted-foreground' }) => (
  <div className="flex flex-col items-center gap-1 bg-card px-3 py-4 text-center">
    <p className={`portal-label ${accent}`}>{label}</p>
    <p className="portal-metric text-foreground leading-none">
      {value ?? '--'}<span className="portal-meta text-muted-foreground">{suffix}</span>
    </p>
  </div>
);

const Field: React.FC<{
  label: string;
  required?: boolean;
  className?: string;
  children: React.ReactNode;
}> = ({ label, required = false, className = '', children }) => (
  <div className={`space-y-2.5 ${className}`}>
    <label className="portal-label text-muted-foreground">
      {label}
      {required ? ' *' : ''}
    </label>
    {children}
  </div>
);
