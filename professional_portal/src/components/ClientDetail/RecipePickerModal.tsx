import React, { useMemo, useState } from 'react';
import { ChefHat, Search, X } from 'lucide-react';
import { useAuth } from '../../lib/auth-context';
import { useRecipes } from '../../hooks/queries/useRecipes';
import type { ProfessionalRecipe } from '../../types/database.types';
import { usePortalI18n } from '../../lib/portal-i18n';

interface RecipePickerModalProps {
  mealType: string;
  onSelect: (recipe: ProfessionalRecipe) => void;
  onClose: () => void;
}

export const RecipePickerModal: React.FC<RecipePickerModalProps> = ({
  mealType,
  onSelect,
  onClose,
}) => {
  const { professional } = useAuth();
  const { t } = usePortalI18n();
  const { data: recipes, isLoading } = useRecipes(professional?.id);
  const [search, setSearch] = useState('');

  const filtered = useMemo(
    () =>
      (recipes || []).filter((recipe) => {
        if (mealType !== 'snack' && recipe.meal_type !== mealType && recipe.meal_type !== null) {
          return false;
        }
        if (search && !recipe.title.toLowerCase().includes(search.toLowerCase())) {
          return false;
        }
        return true;
      }),
    [mealType, recipes, search],
  );

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm" onClick={onClose}>
      <div
        className="glass-card flex max-h-[70vh] w-full max-w-lg flex-col rounded-[1.8rem] p-6"
        onClick={(event) => event.stopPropagation()}
      >
        <div className="mb-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <ChefHat className="h-4.5 w-4.5 text-primary" />
            <h3 className="text-base font-bold text-foreground">{t('components.clientdetail.recipepickermodal.assign_recipe')}</h3>
          </div>
          <button onClick={onClose} className="rounded-xl p-2 text-muted-foreground hover:bg-accent hover:text-foreground">
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="relative mb-3">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
          <input
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            placeholder={t('components.clientdetail.recipepickermodal.search_recipes')}
            className="portal-input h-10 w-full rounded-xl pl-9 pr-3 text-sm font-medium outline-none focus:border-primary"
          />
        </div>

        <div className="min-h-0 flex-1 space-y-2 overflow-y-auto">
          {isLoading ? (
            <div className="space-y-2">
              {[1, 2, 3].map((index) => (
                <div key={index} className="portal-panel h-14 rounded-xl animate-pulse" />
              ))}
            </div>
          ) : filtered.length === 0 ? (
            <p className="py-8 text-center text-sm text-muted-foreground">
              {t('components.clientdetail.recipepickermodal.no_matching_recipes')}
            </p>
          ) : (
            filtered.map((recipe) => (
              <button
                key={recipe.id}
                onClick={() => onSelect(recipe)}
                className="flex w-full items-center justify-between gap-3 rounded-xl border border-border bg-card p-3 text-left transition-colors hover:bg-accent"
              >
                <div className="min-w-0">
                  <p className="truncate text-sm font-semibold text-foreground">{recipe.title}</p>
                  <p className="mt-0.5 text-xs text-muted-foreground">
                    {recipe.kcal != null ? `${recipe.kcal} kcal` : ''}
                    {recipe.protein != null ? ` · P: ${recipe.protein}g` : ''}
                    {recipe.carbs != null ? ` · C: ${recipe.carbs}g` : ''}
                    {recipe.fat != null ? ` · F: ${recipe.fat}g` : ''}
                  </p>
                </div>
                <span className="rounded-full bg-primary/10 px-2 py-0.5 text-[10px] font-bold capitalize text-primary">
                  {recipe.meal_type || mealType}
                </span>
              </button>
            ))
          )}
        </div>
      </div>
    </div>
  );
};
