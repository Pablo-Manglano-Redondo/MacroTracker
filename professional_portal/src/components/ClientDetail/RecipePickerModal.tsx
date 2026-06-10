import React, { useState } from 'react';
import { useAuth } from '../../lib/auth-context';
import { useRecipes } from '../../hooks/queries/useRecipes';
import { X, Search, ChefHat } from 'lucide-react';
import type { ProfessionalRecipe } from '../../types/database.types';

interface RecipePickerModalProps {
  mealType: string;
  onSelect: (recipe: ProfessionalRecipe) => void;
  onClose: () => void;
}

export const RecipePickerModal: React.FC<RecipePickerModalProps> = ({ mealType, onSelect, onClose }) => {
  const { professional } = useAuth();
  const { data: recipes, isLoading } = useRecipes(professional?.id);
  const [search, setSearch] = useState('');

  const filtered = (recipes || []).filter(r => {
    if (mealType !== 'snack' && r.meal_type !== mealType && r.meal_type !== null) return false;
    if (search && !r.title.toLowerCase().includes(search.toLowerCase())) return false;
    return true;
  });

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onClick={onClose}>
      <div className="bg-card rounded-2xl p-6 w-full max-w-lg max-h-[70vh] flex flex-col m-4 shadow-2xl" onClick={e => e.stopPropagation()}>
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-sm font-bold flex items-center gap-2">
            <ChefHat className="w-4 h-4 text-primary" />
            Assign Recipe
          </h3>
          <button onClick={onClose} className="p-1 rounded-md hover:bg-secondary"><X className="w-4 h-4" /></button>
        </div>

        <div className="relative mb-3">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-muted-foreground" />
          <input value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search recipes..."
            className="w-full pl-9 pr-3 py-1.5 text-xs rounded-lg border bg-background focus:outline-none focus:ring-1 focus:ring-primary"
          />
        </div>

        <div className="flex-1 overflow-y-auto space-y-2 min-h-0">
          {isLoading ? (
            <div className="space-y-2">{[1,2,3].map(i => <div key={i} className="h-14 rounded-lg bg-muted/30 animate-pulse" />)}</div>
          ) : filtered.length === 0 ? (
            <p className="text-xs text-muted-foreground text-center py-8">No matching recipes</p>
          ) : (
            filtered.map(r => (
              <button key={r.id} onClick={() => onSelect(r)}
                className="w-full text-left p-3 rounded-lg border bg-card hover:bg-secondary/40 transition-colors flex items-center justify-between gap-3">
                <div className="min-w-0">
                  <p className="text-xs font-medium truncate">{r.title}</p>
                  <p className="text-[10px] text-muted-foreground mt-0.5">
                    {r.kcal != null && `${r.kcal} kcal`}
                    {r.protein != null && ` · P: ${r.protein}g`}
                    {r.carbs != null && ` · C: ${r.carbs}g`}
                    {r.fat != null && ` · F: ${r.fat}g`}
                  </p>
                </div>
                <span className="text-[10px] px-1.5 py-0.5 rounded-full bg-primary/10 text-primary shrink-0 capitalize">{r.meal_type}</span>
              </button>
            ))
          )}
        </div>
      </div>
    </div>
  );
};
