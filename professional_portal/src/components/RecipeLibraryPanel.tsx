import React, { useMemo, useState } from 'react';
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
  const { tr } = usePortalI18n();
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
      toast.error(tr('El título es obligatorio', 'Recipe title required'));
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
        toast.success(tr('Receta actualizada', 'Recipe updated'));
      } else {
        await createRecipe.mutateAsync(payload as any);
        toast.success(tr('Receta creada', 'Recipe created'));
      }
      setShowForm(false);
    } catch {
      toast.error(
        editingId
          ? tr('No se pudo actualizar la receta', 'Failed to update recipe')
          : tr('No se pudo crear la receta', 'Failed to create recipe'),
      );
    }
  };

  const handlePropose = async (clientId: string, note: string) => {
    if (!proposeTarget || !professional) {
      return;
    }
    const client = clients?.find((c) => c.client_id === clientId);
    if (!client) {
      toast.error(tr('Selecciona un cliente', 'Select a client'));
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
      toast.success(tr('Receta propuesta al cliente', 'Recipe proposed to client'));
      setProposeTarget(null);
    } catch {
      toast.error(tr('No se pudo proponer la receta', 'Failed to propose recipe'));
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
      breakfast: tr('Desayuno', 'Breakfast'),
      lunch: tr('Comida', 'Lunch'),
      dinner: tr('Cena', 'Dinner'),
      snack: tr('Snack', 'Snack'),
      all: tr('Todas', 'All'),
    })[meal] ?? meal;

  return (
    <div className="space-y-6 animate-fade-in-up">
      <section className="portal-hero rounded-[1.8rem] p-6">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
          <div className="space-y-2">
            <p className="portal-kicker">{tr('Biblioteca de recetas', 'Recipe library')}</p>
            <h2 className="portal-title text-3xl text-foreground">
              {tr(
                'Recetas operativas para recomendar o reutilizar.',
                'Operational recipes to recommend or reuse.',
              )}
            </h2>
            <p className="max-w-3xl text-sm leading-relaxed text-muted-foreground">
              {tr(
                'Mantén una biblioteca profesional con macros, ingredientes e instrucciones claras. Desde aquí puedes proponer recetas a clientes conectados.',
                'Maintain a professional library with macros, ingredients, and clear instructions. From here you can propose recipes to connected clients.',
              )}
            </p>
          </div>
          <button
            onClick={openCreate}
            className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-xs font-bold uppercase tracking-[0.16em] text-primary-foreground"
          >
            <Plus className="h-4 w-4" />
            {tr('Nueva receta', 'New recipe')}
          </button>
        </div>
      </section>

      <section className="grid gap-4 md:grid-cols-3">
        <StatCard
          label={tr('Recetas visibles', 'Visible recipes')}
          value={filtered.length}
          note={tr('Resultado según búsqueda y filtro', 'Result after search and filter')}
        />
        <StatCard
          label={tr('Biblioteca total', 'Library total')}
          value={recipes?.length ?? 0}
          note={tr('Recursos almacenados', 'Stored resources')}
        />
        <StatCard
          label={tr('Clientes conectados', 'Connected clients')}
          value={(clients || []).filter((client) => client.status === 'connected').length}
          note={tr('Posibles destinatarios de una propuesta', 'Possible recipients for a proposal')}
        />
      </section>

      <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
        <div className="relative w-full max-w-sm">
          <Search className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={tr('Buscar recetas', 'Search recipes')}
            className="portal-input h-11 w-full rounded-xl pl-10 pr-4 text-sm font-medium outline-none focus:border-primary"
          />
        </div>

        <div className="flex flex-wrap gap-2">
          {MEAL_TYPES.map((meal) => (
            <button
              key={meal}
              onClick={() => setMealFilter(meal)}
              className={`rounded-full px-3 py-1.5 text-xs font-bold transition-colors ${
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
          <h3 className="portal-title mt-5 text-2xl text-foreground">
            {tr('No hay recetas para mostrar', 'No recipes to show')}
          </h3>
          <p className="mt-2 max-w-sm text-sm leading-relaxed text-muted-foreground">
            {tr(
              'Crea una nueva receta o ajusta la búsqueda y el filtro para ver resultados.',
              'Create a new recipe or adjust the search and filter to see results.',
            )}
          </p>
        </div>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {filtered.map((recipe) => (
            <article key={recipe.id} className="portal-panel rounded-[1.6rem] p-5">
              <div className="flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <div className="flex items-center gap-2">
                    <ChefHat className="h-4 w-4 text-primary" />
                    <h3 className="truncate text-base font-bold text-foreground">{recipe.title}</h3>
                  </div>
                  {recipe.description && (
                    <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
                      {recipe.description}
                    </p>
                  )}
                </div>
                <div className="flex gap-1">
                  <IconAction
                    title={tr('Editar receta', 'Edit recipe')}
                    onClick={() => openEdit(recipe)}
                    icon={<Pencil className="h-4 w-4" />}
                  />
                  <IconAction
                    title={tr('Proponer a cliente', 'Propose to client')}
                    onClick={() => setProposeTarget({ recipeId: recipe.id })}
                    icon={<Send className="h-4 w-4" />}
                  />
                  <IconAction
                    title={tr('Eliminar receta', 'Delete recipe')}
                    onClick={() => setDeleteConfirm(recipe.id)}
                    icon={<Trash2 className="h-4 w-4" />}
                    danger
                  />
                </div>
              </div>

              <div className="mt-4 flex flex-wrap items-center gap-3 text-sm text-muted-foreground">
                {recipe.meal_type && (
                  <span className="rounded-full bg-primary/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-primary">
                    {mealLabel(recipe.meal_type)}
                  </span>
                )}
                {recipe.prep_time_min ? (
                  <span className="inline-flex items-center gap-1">
                    <Clock className="h-4 w-4 text-primary" />
                    {tr(`Prep ${recipe.prep_time_min} min`, `Prep ${recipe.prep_time_min} min`)}
                  </span>
                ) : null}
                {recipe.servings ? (
                  <span className="inline-flex items-center gap-1">
                    <Users className="h-4 w-4 text-primary" />
                    {tr(`${recipe.servings} raciones`, `Serves ${recipe.servings}`)}
                  </span>
                ) : null}
              </div>

              <div className="mt-4 grid grid-cols-4 gap-2">
                <MacroMini label="Kcal" value={recipe.kcal} tone="rose" />
                <MacroMini label="P" value={recipe.protein} tone="emerald" suffix="g" />
                <MacroMini label="C" value={recipe.carbs} tone="blue" suffix="g" />
                <MacroMini label="F" value={recipe.fat} tone="amber" suffix="g" />
              </div>
            </article>
          ))}
        </div>
      )}

      {showForm && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm"
          onClick={() => setShowForm(false)}
        >
          <div
            className="glass-card max-h-[88vh] w-full max-w-3xl overflow-y-auto rounded-[1.8rem] p-6"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="mb-5 flex items-center justify-between border-b border-border pb-4">
              <div>
                <h3 className="text-lg font-bold text-foreground">
                  {editingId
                    ? tr('Editar receta', 'Edit recipe')
                    : tr('Crear receta', 'Create recipe')}
                </h3>
                <p className="text-sm text-muted-foreground">
                  {tr(
                    'Macros, ingredientes e instrucciones para la biblioteca profesional.',
                    'Macros, ingredients, and instructions for the professional library.',
                  )}
                </p>
              </div>
              <button
                onClick={() => setShowForm(false)}
                className="rounded-xl p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="grid gap-4 md:grid-cols-2">
              <Field label={tr('Título', 'Title')} required className="md:col-span-2">
                <input
                  value={form.title}
                  onChange={(e) => setForm((prev) => ({ ...prev, title: e.target.value }))}
                  className="portal-input h-11 w-full rounded-xl px-4 text-sm font-medium outline-none focus:border-primary"
                />
              </Field>
              <Field label={tr('Descripción', 'Description')} className="md:col-span-2">
                <textarea
                  value={form.description}
                  onChange={(e) =>
                    setForm((prev) => ({ ...prev, description: e.target.value }))
                  }
                  rows={2}
                  className="portal-input w-full rounded-xl px-4 py-3 text-sm font-medium outline-none focus:border-primary"
                />
              </Field>
              <Field label={tr('Tipo de comida', 'Meal type')}>
                <select
                  value={form.meal_type}
                  onChange={(e) => setForm((prev) => ({ ...prev, meal_type: e.target.value }))}
                  className="portal-input h-11 w-full rounded-xl px-4 text-sm font-semibold outline-none"
                >
                  {MEAL_TYPES.filter((meal) => meal !== 'all').map((meal) => (
                    <option key={meal} value={meal}>
                      {mealLabel(meal)}
                    </option>
                  ))}
                </select>
              </Field>
              <Field label={tr('Raciones', 'Servings')}>
                <input
                  type="number"
                  min={1}
                  value={form.servings}
                  onChange={(e) => setForm((prev) => ({ ...prev, servings: +e.target.value }))}
                  className="portal-input h-11 w-full rounded-xl px-4 text-sm font-semibold outline-none focus:border-primary"
                />
              </Field>
              <Field label={tr('Prep (min)', 'Prep (min)')}>
                <input
                  type="number"
                  value={form.prep_time_min}
                  onChange={(e) =>
                    setForm((prev) => ({ ...prev, prep_time_min: +e.target.value }))
                  }
                  className="portal-input h-11 w-full rounded-xl px-4 text-sm font-semibold outline-none focus:border-primary"
                />
              </Field>
              <Field label={tr('Cocción (min)', 'Cook (min)')}>
                <input
                  type="number"
                  value={form.cook_time_min}
                  onChange={(e) =>
                    setForm((prev) => ({ ...prev, cook_time_min: +e.target.value }))
                  }
                  className="portal-input h-11 w-full rounded-xl px-4 text-sm font-semibold outline-none focus:border-primary"
                />
              </Field>

              <div className="md:col-span-2 rounded-2xl border border-border bg-background/60 p-4">
                <p className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
                  {tr('Macros', 'Macros')}
                </p>
                <div className="mt-3 grid grid-cols-2 gap-3 md:grid-cols-4">
                  {[
                    { label: 'Kcal', value: form.kcal, key: 'kcal' as const },
                    { label: 'Protein', value: form.protein, key: 'protein' as const },
                    { label: 'Carbs', value: form.carbs, key: 'carbs' as const },
                    { label: 'Fat', value: form.fat, key: 'fat' as const },
                  ].map((macro) => (
                    <Field key={macro.key} label={macro.label}>
                      <input
                        type="number"
                        value={macro.value}
                        onChange={(e) =>
                          setForm((prev) => ({ ...prev, [macro.key]: +e.target.value }))
                        }
                        className="portal-input h-10 w-full rounded-xl px-3 text-sm font-semibold outline-none focus:border-primary"
                      />
                    </Field>
                  ))}
                </div>
              </div>

              <div className="md:col-span-2 rounded-2xl border border-border bg-background/60 p-4">
                <div className="mb-3 flex items-center justify-between">
                  <p className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
                    {tr('Ingredientes', 'Ingredients')}
                  </p>
                  <button
                    onClick={addIngredient}
                    className="inline-flex items-center gap-1 text-xs font-bold text-primary"
                  >
                    <PlusCircle className="h-4 w-4" />
                    {tr('Añadir ingrediente', 'Add ingredient')}
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
                        placeholder={tr('Ingrediente', 'Ingredient')}
                        className="portal-input h-10 rounded-xl px-3 text-sm font-medium outline-none focus:border-primary"
                      />
                      <input
                        type="number"
                        value={ingredient.amount || ''}
                        onChange={(e) => updateIngredient(index, 'amount', +e.target.value)}
                        className="portal-input h-10 rounded-xl px-3 text-sm font-semibold outline-none focus:border-primary"
                      />
                      <select
                        value={ingredient.unit}
                        onChange={(e) => updateIngredient(index, 'unit', e.target.value)}
                        className="portal-input h-10 rounded-xl px-3 text-sm font-semibold outline-none"
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
                    <p className="text-sm text-muted-foreground">
                      {tr('Todavía no hay ingredientes.', 'No ingredients yet.')}
                    </p>
                  )}
                </div>
              </div>

              <Field label={tr('Instrucciones', 'Instructions')} className="md:col-span-2">
                <textarea
                  value={form.instructions}
                  onChange={(e) =>
                    setForm((prev) => ({ ...prev, instructions: e.target.value }))
                  }
                  rows={4}
                  placeholder={tr('Describe la preparación paso a paso...', 'Describe the preparation step by step...')}
                  className="portal-input w-full rounded-xl px-4 py-3 text-sm font-medium outline-none focus:border-primary"
                />
              </Field>
            </div>

            <div className="mt-5 flex justify-end gap-3 border-t border-border pt-4">
              <button
                onClick={() => setShowForm(false)}
                className="rounded-xl border border-border px-4 py-2 text-sm font-semibold text-foreground transition-colors hover:bg-accent"
              >
                {tr('Cancelar', 'Cancel')}
              </button>
              <button
                onClick={handleSave}
                disabled={createRecipe.isPending || updateRecipe.isPending}
                className="rounded-xl bg-primary px-4 py-2 text-sm font-bold text-primary-foreground disabled:opacity-50"
              >
                {createRecipe.isPending || updateRecipe.isPending
                  ? tr('Guardando...', 'Saving...')
                  : editingId
                    ? tr('Actualizar receta', 'Update recipe')
                    : tr('Crear receta', 'Create recipe')}
              </button>
            </div>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={deleteConfirm !== null}
        title={tr('Eliminar receta', 'Delete recipe')}
        message={tr(
          'Esta acción no se puede deshacer. La receta se eliminará definitivamente de la biblioteca profesional.',
          'This action cannot be undone. The recipe will be permanently removed from the professional library.',
        )}
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
  const { tr } = usePortalI18n();
  const [clientId, setClientId] = useState('');
  const [note, setNote] = useState('');

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm" onClick={onClose}>
      <div className="glass-card w-full max-w-sm rounded-[1.8rem] p-6" onClick={(e) => e.stopPropagation()}>
        <div className="mb-4 flex items-center justify-between border-b border-border pb-3">
          <div>
            <h3 className="text-lg font-bold text-foreground">{tr('Proponer receta', 'Propose recipe')}</h3>
            <p className="text-sm text-muted-foreground">
              {tr('Enviar a un cliente conectado', 'Send to a connected client')}
            </p>
          </div>
          <button onClick={onClose} className="rounded-xl p-2 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground">
            <X className="h-4 w-4" />
          </button>
        </div>
        <div className="space-y-4">
          <Field label={tr('Cliente conectado', 'Connected client')}>
            <select
              value={clientId}
              onChange={(e) => setClientId(e.target.value)}
              className="portal-input h-11 w-full rounded-xl px-4 text-sm font-semibold outline-none"
            >
              <option value="">{tr('Selecciona un cliente...', 'Select a client...')}</option>
              {clients.map((client) => (
                <option key={client.id} value={client.client_id}>
                  {client.display_name || client.client_id.slice(0, 8)}
                </option>
              ))}
            </select>
          </Field>
          <Field label={tr('Nota opcional', 'Optional note')}>
            <textarea
              value={note}
              onChange={(e) => setNote(e.target.value)}
              rows={2}
              placeholder={tr('Ej. Prueba esta opción para la cena.', 'E.g. Try this option for dinner.')}
              className="portal-input w-full rounded-xl px-4 py-3 text-sm font-medium outline-none focus:border-primary"
            />
          </Field>
          <div className="flex justify-end gap-3 border-t border-border pt-4">
            <button
              onClick={onClose}
              className="rounded-xl border border-border px-4 py-2 text-sm font-semibold text-foreground transition-colors hover:bg-accent"
            >
              {tr('Cancelar', 'Cancel')}
            </button>
            <button
              onClick={() => onSubmit(clientId, note)}
              disabled={!clientId}
              className="rounded-xl bg-primary px-4 py-2 text-sm font-bold text-primary-foreground disabled:opacity-50"
            >
              {tr('Enviar propuesta', 'Send proposal')}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

const StatCard: React.FC<{ label: string; value: number; note: string }> = ({
  label,
  value,
  note,
}) => (
  <div className="portal-panel rounded-[1.4rem] p-4">
    <p className="text-[10px] font-bold uppercase tracking-[0.16em] text-muted-foreground">{label}</p>
    <p className="portal-metric mt-2 text-3xl font-extrabold text-foreground">{value}</p>
    <p className="mt-1 text-xs leading-relaxed text-muted-foreground">{note}</p>
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

const MacroMini: React.FC<{
  label: string;
  value: number | null | undefined;
  tone: 'rose' | 'emerald' | 'blue' | 'amber';
  suffix?: string;
}> = ({ label, value, tone, suffix = '' }) => {
  const toneClass = {
    rose: 'text-rose-500 bg-rose-500/8',
    emerald: 'text-emerald-600 dark:text-emerald-400 bg-emerald-500/8',
    blue: 'text-sky-600 dark:text-sky-400 bg-sky-500/8',
    amber: 'text-amber-600 dark:text-amber-400 bg-amber-500/8',
  }[tone];

  return (
    <div className={`rounded-xl px-3 py-3 text-center ${toneClass}`}>
      <p className="text-[10px] font-bold uppercase tracking-[0.16em]">{label}</p>
      <p className="mt-1 text-sm font-extrabold">
        {value ?? '--'}
        {suffix}
      </p>
    </div>
  );
};

const Field: React.FC<{
  label: string;
  required?: boolean;
  className?: string;
  children: React.ReactNode;
}> = ({ label, required = false, className = '', children }) => (
  <div className={`space-y-2 ${className}`}>
    <label className="text-xs font-bold uppercase tracking-[0.18em] text-muted-foreground">
      {label}
      {required ? ' *' : ''}
    </label>
    {children}
  </div>
);
