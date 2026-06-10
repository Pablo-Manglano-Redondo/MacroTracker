import React, { useState } from 'react';
import { useAuth } from '../lib/auth-context';
import { useRecipes } from '../hooks/queries/useRecipes';
import { useCreateRecipe, useDeleteRecipe, useProposeRecipe } from '../hooks/mutations/useCreateRecipe';
import { useUpdateRecipe } from '../hooks/mutations/useUpdateRecipe';
import { useClients } from '../hooks/queries/useClients';
import { Plus, Search, Trash2, Send, ChefHat, Clock, Users, X, Utensils, Pencil, PlusCircle, GripVertical } from 'lucide-react';
import { toast } from 'sonner';
import { ConfirmDialog } from './ui/confirm-dialog';
import type { ProfessionalRecipe } from '../types/database.types';

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
    ingredients: raw.map((i: any) => ({ name: String(i.name ?? ''), amount: Number(i.amount ?? 0), unit: String(i.unit ?? 'g') })),
    instructions: r.instructions || '',
  };
}

export const RecipeLibraryPanel: React.FC = () => {
  const { professional } = useAuth();
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

  const filtered = (recipes || []).filter(r => {
    if (mealFilter !== 'all' && r.meal_type !== mealFilter) return false;
    if (search && !r.title.toLowerCase().includes(search.toLowerCase())) return false;
    return true;
  });

  const openCreate = () => {
    setEditingId(null);
    setForm(emptyForm());
    setShowForm(true);
  };

  const openEdit = (r: ProfessionalRecipe) => {
    setEditingId(r.id);
    setForm(recipeToForm(r));
    setShowForm(true);
  };

  const handleSave = async () => {
    if (!form.title.trim()) { toast.error('Recipe title required'); return; }
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
        toast.success('Recipe updated');
      } else {
        await createRecipe.mutateAsync(payload as any);
        toast.success('Recipe created');
      }
      setShowForm(false);
    } catch { toast.error(editingId ? 'Failed to update recipe' : 'Failed to create recipe'); }
  };

  const handlePropose = async (clientId: string, note: string) => {
    if (!proposeTarget || !professional) { return; }
    const client = clients?.find(c => c.client_id === clientId);
    if (!client) { toast.error('Select a client'); return; }
    try {
      await proposeRecipe.mutateAsync({
        professional_client_id: client.id,
        recipe_id: proposeTarget.recipeId,
        professional_id: professional.id,
        client_id: clientId,
        note: note || undefined,
      });
      toast.success('Recipe proposed to client');
      setProposeTarget(null);
    } catch { toast.error('Failed to propose recipe'); }
  };

  const addIngredient = () => {
    setForm(p => ({ ...p, ingredients: [...p.ingredients, { name: '', amount: 0, unit: 'g' }] }));
  };

  const removeIngredient = (i: number) => {
    setForm(p => ({ ...p, ingredients: p.ingredients.filter((_, idx) => idx !== i) }));
  };

  const updateIngredient = (i: number, field: 'name' | 'amount' | 'unit', value: string | number) => {
    setForm(p => {
      const ings = p.ingredients.map((ing, idx) => {
        if (idx !== i) return ing;
        if (field === 'name') return { ...ing, name: value as string };
        if (field === 'amount') return { ...ing, amount: value as number };
        return { ...ing, unit: value as string };
      });
      return { ...p, ingredients: ings };
    });
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h2 className="text-lg font-bold text-foreground flex items-center gap-2">
            <ChefHat className="w-5 h-5 text-primary" />
            Recipe Library
          </h2>
          <p className="text-xs text-muted-foreground mt-0.5">{filtered.length} recipes</p>
        </div>
        <button onClick={openCreate} className="btn-primary text-xs px-3 py-1.5 rounded-lg gap-1.5 flex items-center">
          <Plus className="w-3.5 h-3.5" /> New Recipe
        </button>
      </div>

      {/* Filters */}
      <div className="flex items-center gap-3 flex-wrap">
        <div className="relative flex-1 min-w-[200px] max-w-xs">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-muted-foreground" />
          <input
            value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search recipes..."
            className="w-full pl-9 pr-3 py-1.5 text-xs rounded-lg border bg-card focus:outline-none focus:ring-1 focus:ring-primary"
          />
        </div>
        <div className="flex gap-1">
          {MEAL_TYPES.map(m => (
            <button key={m} onClick={() => setMealFilter(m)}
              className={`px-2.5 py-1.5 rounded-md text-[11px] font-medium transition-colors ${
                mealFilter === m ? 'bg-primary text-primary-foreground' : 'bg-secondary text-muted-foreground hover:text-foreground'
              }`}>
              {m === 'all' ? 'All' : m.charAt(0).toUpperCase() + m.slice(1)}
            </button>
          ))}
        </div>
      </div>

      {/* Recipe Grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1,2,3].map(i => (
            <div key={i} className="h-40 rounded-xl bg-muted/30 animate-pulse" />
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <div className="text-center py-12 text-muted-foreground">
          <Utensils className="w-10 h-10 mx-auto mb-3 text-primary/30" />
          <p className="text-sm font-medium">No recipes yet</p>
          <p className="text-xs mt-1">Create your first recipe to get started.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {filtered.map(recipe => (
            <div key={recipe.id} className="rounded-xl bg-card border card-elevated p-4 space-y-3 hover:shadow-md transition-shadow">
              <div className="flex items-start justify-between gap-2">
                <div className="min-w-0">
                  <h4 className="text-sm font-bold text-foreground truncate">{recipe.title}</h4>
                  {recipe.description && (
                    <p className="text-[11px] text-muted-foreground truncate mt-0.5">{recipe.description}</p>
                  )}
                </div>
                <div className="flex gap-1 shrink-0">
                  <button onClick={() => openEdit(recipe)}
                    className="p-1.5 rounded-md text-muted-foreground hover:text-primary hover:bg-primary/10 transition-colors"
                    title="Edit">
                    <Pencil className="w-3.5 h-3.5" />
                  </button>
                  <button onClick={() => setProposeTarget({ recipeId: recipe.id })}
                    className="p-1.5 rounded-md text-muted-foreground hover:text-primary hover:bg-primary/10 transition-colors"
                    title="Propose to client">
                    <Send className="w-3.5 h-3.5" />
                  </button>
                  <button onClick={() => setDeleteConfirm(recipe.id)}
                    className="p-1.5 rounded-md text-muted-foreground hover:text-red-500 hover:bg-red-500/10 transition-colors"
                    title="Delete">
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>

              <div className="flex flex-wrap gap-1.5">
                {recipe.meal_type && (
                  <span className="text-[10px] font-medium px-2 py-0.5 rounded-full bg-primary/10 text-primary">
                    {recipe.meal_type}
                  </span>
                )}
                {recipe.prep_time_min && (
                  <span className="text-[10px] text-muted-foreground flex items-center gap-1">
                    <Clock className="w-3 h-3" /> {recipe.prep_time_min}m
                  </span>
                )}
                {recipe.servings && (
                  <span className="text-[10px] text-muted-foreground flex items-center gap-1">
                    <Users className="w-3 h-3" /> {recipe.servings}
                  </span>
                )}
              </div>

              <div className="flex gap-3 text-[11px] font-medium text-muted-foreground">
                {recipe.kcal != null && <span>{recipe.kcal} kcal</span>}
                {recipe.protein != null && <span>P: {recipe.protein}g</span>}
                {recipe.carbs != null && <span>C: {recipe.carbs}g</span>}
                {recipe.fat != null && <span>F: {recipe.fat}g</span>}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Create/Edit Form Modal */}
      {showForm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onClick={() => setShowForm(false)}>
          <div className="bg-card rounded-2xl p-6 w-full max-w-lg max-h-[80vh] overflow-y-auto m-4 shadow-2xl" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-bold">{editingId ? 'Edit Recipe' : 'New Recipe'}</h3>
              <button onClick={() => setShowForm(false)} className="p-1 rounded-md hover:bg-secondary"><X className="w-4 h-4" /></button>
            </div>
            <div className="space-y-3">
              <div className="grid grid-cols-2 gap-3">
                <div className="col-span-2">
                  <label className="text-[11px] font-medium text-muted-foreground">Title *</label>
                  <input value={form.title} onChange={e => setForm(p => ({...p, title: e.target.value}))}
                    className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                </div>
                <div className="col-span-2">
                  <label className="text-[11px] font-medium text-muted-foreground">Description</label>
                  <textarea value={form.description} onChange={e => setForm(p => ({...p, description: e.target.value}))} rows={2}
                    className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                </div>
                <div>
                  <label className="text-[11px] font-medium text-muted-foreground">Meal Type</label>
                  <select value={form.meal_type} onChange={e => setForm(p => ({...p, meal_type: e.target.value}))}
                    className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary">
                    {MEAL_TYPES.filter(m => m !== 'all').map(m => (
                      <option key={m} value={m}>{m.charAt(0).toUpperCase() + m.slice(1)}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="text-[11px] font-medium text-muted-foreground">Servings</label>
                  <input type="number" min={1} value={form.servings} onChange={e => setForm(p => ({...p, servings: +e.target.value}))}
                    className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                </div>
                <div>
                  <label className="text-[11px] font-medium text-muted-foreground">Prep (min)</label>
                  <input type="number" value={form.prep_time_min} onChange={e => setForm(p => ({...p, prep_time_min: +e.target.value}))}
                    className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                </div>
                <div>
                  <label className="text-[11px] font-medium text-muted-foreground">Cook (min)</label>
                  <input type="number" value={form.cook_time_min} onChange={e => setForm(p => ({...p, cook_time_min: +e.target.value}))}
                    className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                </div>
                <div>
                  <label className="text-[11px] font-medium text-muted-foreground">Kcal</label>
                  <input type="number" value={form.kcal} onChange={e => setForm(p => ({...p, kcal: +e.target.value}))}
                    className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                </div>
                <div className="grid grid-cols-3 gap-2">
                  <div>
                    <label className="text-[11px] font-medium text-muted-foreground">Protein</label>
                    <input type="number" value={form.protein} onChange={e => setForm(p => ({...p, protein: +e.target.value}))}
                      className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                  </div>
                  <div>
                    <label className="text-[11px] font-medium text-muted-foreground">Carbs</label>
                    <input type="number" value={form.carbs} onChange={e => setForm(p => ({...p, carbs: +e.target.value}))}
                      className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                  </div>
                  <div>
                    <label className="text-[11px] font-medium text-muted-foreground">Fat</label>
                    <input type="number" value={form.fat} onChange={e => setForm(p => ({...p, fat: +e.target.value}))}
                      className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                  </div>
                </div>

                {/* Ingredients Builder */}
                <div className="col-span-2">
                  <div className="flex items-center justify-between mb-1">
                    <label className="text-[11px] font-medium text-muted-foreground">Ingredients</label>
                    <button onClick={addIngredient} className="flex items-center gap-1 text-[11px] text-primary hover:text-primary/80 transition-colors">
                      <PlusCircle className="w-3 h-3" /> Add
                    </button>
                  </div>
                  <div className="space-y-2">
                    {form.ingredients.map((ing, i) => (
                      <div key={i} className="flex items-center gap-2">
                        <GripVertical className="w-3 h-3 text-muted-foreground/40 shrink-0" />
                        <input value={ing.name} onChange={e => updateIngredient(i, 'name', e.target.value)}
                          placeholder="Name" className="flex-1 min-w-0 px-2 py-1 text-xs rounded border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                        <input type="number" value={ing.amount || ''} onChange={e => updateIngredient(i, 'amount', +e.target.value)}
                          placeholder="0" className="w-16 px-2 py-1 text-xs rounded border bg-background focus:outline-none focus:ring-1 focus:ring-primary text-right" />
                        <select value={ing.unit} onChange={e => updateIngredient(i, 'unit', e.target.value)}
                          className="w-14 px-1 py-1 text-[10px] rounded border bg-background focus:outline-none focus:ring-1 focus:ring-primary">
                          {['g','ml','tsp','tbsp','cup','oz','lb','unit','slice','piece'].map(u => (
                            <option key={u} value={u}>{u}</option>
                          ))}
                        </select>
                        <button onClick={() => removeIngredient(i)} className="p-1 text-muted-foreground hover:text-red-500 transition-colors">
                          <X className="w-3 h-3" />
                        </button>
                      </div>
                    ))}
                    {form.ingredients.length === 0 && (
                      <p className="text-[10px] text-muted-foreground italic">No ingredients added yet</p>
                    )}
                  </div>
                </div>

                <div className="col-span-2">
                  <label className="text-[11px] font-medium text-muted-foreground">Instructions</label>
                  <textarea value={form.instructions} onChange={e => setForm(p => ({...p, instructions: e.target.value}))} rows={4}
                    className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
                </div>
              </div>
              <div className="flex justify-end gap-2 pt-2">
                <button onClick={() => setShowForm(false)} className="px-4 py-1.5 text-xs rounded-lg border hover:bg-secondary transition-colors">Cancel</button>
                <button onClick={handleSave} disabled={createRecipe.isPending || updateRecipe.isPending}
                  className="px-4 py-1.5 text-xs rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-50">
                  {(createRecipe.isPending || updateRecipe.isPending) ? 'Saving...' : editingId ? 'Update' : 'Create'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      <ConfirmDialog
        open={deleteConfirm !== null}
        title="Delete recipe"
        message="This action cannot be undone. The recipe will be removed from your library."
        onConfirm={() => { if (deleteConfirm) deleteRecipe.mutate(deleteConfirm); setDeleteConfirm(null); }}
        onCancel={() => setDeleteConfirm(null)}
        loading={deleteRecipe.isPending}
      />

      {/* Propose to Client Modal */}
      {proposeTarget && (
        <ProposeModal
          clients={clients || []}
          onSubmit={handlePropose}
          onClose={() => setProposeTarget(null)}
        />
      )}
    </div>
  );
};

function ProposeModal({ clients, onSubmit, onClose }: {
  clients: { client_id: string; id: string }[];
  onSubmit: (clientId: string, note: string) => void;
  onClose: () => void;
}) {
  const [clientId, setClientId] = useState('');
  const [note, setNote] = useState('');

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onClick={onClose}>
      <div className="bg-card rounded-2xl p-6 w-full max-w-sm m-4 shadow-2xl" onClick={e => e.stopPropagation()}>
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-sm font-bold">Propose Recipe</h3>
          <button onClick={onClose} className="p-1 rounded-md hover:bg-secondary"><X className="w-4 h-4" /></button>
        </div>
        <div className="space-y-3">
          <div>
            <label className="text-[11px] font-medium text-muted-foreground">Client</label>
            <select value={clientId} onChange={e => setClientId(e.target.value)}
              className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary">
              <option value="">Select a client...</option>
              {clients.map(c => (
                <option key={c.id} value={c.client_id}>{c.client_id.slice(0, 8)}...</option>
              ))}
            </select>
          </div>
          <div>
            <label className="text-[11px] font-medium text-muted-foreground">Note (optional)</label>
            <textarea value={note} onChange={e => setNote(e.target.value)} rows={2}
              className="w-full mt-1 px-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary" />
          </div>
          <div className="flex justify-end gap-2 pt-2">
            <button onClick={onClose} className="px-4 py-1.5 text-xs rounded-lg border hover:bg-secondary transition-colors">Cancel</button>
            <button onClick={() => onSubmit(clientId, note)} disabled={!clientId}
              className="px-4 py-1.5 text-xs rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors disabled:opacity-50">
              Send
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
