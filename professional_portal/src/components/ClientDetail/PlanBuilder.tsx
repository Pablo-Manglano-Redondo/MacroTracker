import React, { useState, useMemo } from 'react';
import { useAuth } from '../../lib/auth-context';
import { usePublishPlan, type MealInput } from '../../hooks/mutations/usePublishPlan';
import type { ProfessionalClient } from '../../types/database.types';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Card } from '../ui/card';
import { toast } from '../../lib/toast';
import { Calculator, CheckCircle2, AlertTriangle, Plus, Minus, ChevronDown, ChevronRight, Utensils, BookOpen } from 'lucide-react';
import { planSchema } from '../../lib/validation/schemas';
import { RecipePickerModal } from './RecipePickerModal';

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
      name: data.name || 'Weekly coaching plan',
      kcal: macros.kcal ?? 2200,
      protein: macros.protein ?? 160,
      carbs: macros.carbs ?? 250,
      fat: macros.fat ?? 70,
    };
  } catch { return null; }
}

export const PlanBuilder: React.FC<PlanBuilderProps> = ({ client }) => {
  const { professional } = useAuth();
  const template = loadTemplateDefaults();
  const [planName, setPlanName] = useState(template?.name || 'Weekly coaching plan');
  const [kcal, setKcal] = useState(template?.kcal || 2200);
  const [protein, setProtein] = useState(template?.protein || 160);
  const [carbs, setCarbs] = useState(template?.carbs || 250);
  const [fat, setFat] = useState(template?.fat || 70);
  const [published, setPublished] = useState(false);
  const [showMeals, setShowMeals] = useState(!!template);
  const [meals, setMeals] = useState<MealInput[]>([
    { slot: 'breakfast', title: 'Breakfast', kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'lunch', title: 'Lunch', kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'dinner', title: 'Dinner', kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
    { slot: 'snack', title: 'Snack', kcal: 0, protein: 0, carbs: 0, fat: 0, recipe_id: null },
  ]);
  const [recipePickerSlot, setRecipePickerSlot] = useState<string | null>(null);

  const mealTotals = useMemo(() => ({
    kcal: meals.reduce((s, m) => s + (m.kcal || 0), 0),
    protein: meals.reduce((s, m) => s + (m.protein || 0), 0),
    carbs: meals.reduce((s, m) => s + (m.carbs || 0), 0),
    fat: meals.reduce((s, m) => s + (m.fat || 0), 0),
  }), [meals]);

  const publishMutation = usePublishPlan();

  const calculatedKcal = protein * 4 + carbs * 4 + fat * 9;
  const hasDiscrepancy = Math.abs(calculatedKcal - kcal) > 5;

  const handleAutocorrectKcal = () => {
    setKcal(calculatedKcal);
  };

  const validate = (): boolean => {
    if (!professional) {
      toast.error('Save your profile first.');
      return false;
    }
    const isProActive = professional.pro_status === 'active' || professional.pro_status === 'trialing';
    if (!isProActive) {
      toast.error('Pro subscription must be trialing or active to publish plans.');
      return false;
    }
    const result = planSchema.safeParse({ name: planName, kcal, protein, carbs, fat });
    if (!result.success) {
      const firstIssue = result.error.issues[0];
      if (firstIssue?.path[0] === 'name') {
        toast.error('Plan name is required.');
      } else {
        toast.error(firstIssue?.message || 'Invalid plan values');
      }
      return false;
    }
    return true;
  };

  const handlePublish = async () => {
    if (!validate()) return;

    const activeMeals = meals.filter(m => m.title?.trim() && ((m.kcal || 0) > 0 || (m.protein || 0) > 0));

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
          if (client.display_name) {
            toast.success(`Plan published for ${client.display_name}`);
          } else {
            toast.success('Plan published');
          }
          setTimeout(() => setPublished(false), 5000);
        },
        onError: (err: any) => {
          toast.error('Failed to publish plan', { description: err?.message || 'Unknown error' });
        },
      }
    );
  };

  const hasActivePro = professional?.pro_status === 'active' || professional?.pro_status === 'trialing';

  return (
    <Card className="p-6 border">
      <div className="flex justify-between items-start gap-4 border-b pb-4 mb-4">
        <div>
          <p className="text-xs font-bold tracking-wider text-primary uppercase mb-1">Plan builder</p>
          <h3 className="text-lg font-bold">Publish a weekly macro target</h3>
        </div>
        <Button
          onClick={handlePublish}
          disabled={publishMutation.isPending || !hasActivePro}
          size="sm"
          className="shrink-0"
        >
          {publishMutation.isPending ? 'Publishing...' : 'Publish plan'}
        </Button>
      </div>

      {!hasActivePro && (
        <div className="flex items-start gap-3 bg-amber-500/10 border border-amber-500/20 text-amber-700 dark:text-amber-300 p-4 rounded-lg text-sm mb-4">
          <AlertTriangle className="w-5 h-5 shrink-0 mt-0.5" />
          <div>
            <p className="font-bold">Subscription required</p>
            <p className="text-xs mt-0.5 leading-relaxed">
              Pro must be trialing or active to publish plans. Please update your subscription.
            </p>
          </div>
        </div>
      )}

      {published && (
        <div className="flex items-center gap-2 bg-accent/30 border border-primary/20 text-primary p-3 rounded-lg text-sm font-semibold mb-4 animate-in fade-in duration-200">
          <CheckCircle2 className="w-4 h-4 shrink-0" />
          <span>Plan published successfully for client {client.client_id}!</span>
        </div>
      )}

      <div className="space-y-4">
        <div className="space-y-1.5">
          <label className="text-xs font-extrabold text-foreground uppercase tracking-wider">Plan name</label>
          <Input
            value={planName}
            onChange={(e) => setPlanName(e.target.value)}
            placeholder="e.g. Weekly coaching plan"
          />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="space-y-1.5 p-3 border rounded-lg bg-card shadow-sm">
            <span className="text-xs font-bold text-primary block">Protein (g)</span>
            <div className="flex items-center gap-1.5 mt-2">
              <Button
                variant="outline"
                size="icon"
                className="w-8 h-8 shrink-0"
                onClick={() => setProtein(prev => Math.max(1, prev - 5))}
              >
                <Minus className="w-3.5 h-3.5" />
              </Button>
              <Input
                type="number"
                value={protein}
                onChange={(e) => setProtein(Math.max(1, Number(e.target.value)))}
                className="text-center h-8 px-1"
              />
              <Button
                variant="outline"
                size="icon"
                className="w-8 h-8 shrink-0"
                onClick={() => setProtein(prev => prev + 5)}
              >
                <Plus className="w-3.5 h-3.5" />
              </Button>
            </div>
            <span className="text-[10px] text-muted-foreground block text-center mt-1">{protein * 4} kcal</span>
          </div>

          <div className="space-y-1.5 p-3 border rounded-lg bg-card shadow-sm">
            <span className="text-xs font-bold text-indigo-500 block">Carbohydrates (g)</span>
            <div className="flex items-center gap-1.5 mt-2">
              <Button
                variant="outline"
                size="icon"
                className="w-8 h-8 shrink-0"
                onClick={() => setCarbs(prev => Math.max(1, prev - 5))}
              >
                <Minus className="w-3.5 h-3.5" />
              </Button>
              <Input
                type="number"
                value={carbs}
                onChange={(e) => setCarbs(Math.max(1, Number(e.target.value)))}
                className="text-center h-8 px-1"
              />
              <Button
                variant="outline"
                size="icon"
                className="w-8 h-8 shrink-0"
                onClick={() => setCarbs(prev => prev + 5)}
              >
                <Plus className="w-3.5 h-3.5" />
              </Button>
            </div>
            <span className="text-[10px] text-muted-foreground block text-center mt-1">{carbs * 4} kcal</span>
          </div>

          <div className="space-y-1.5 p-3 border rounded-lg bg-card shadow-sm">
            <span className="text-xs font-bold text-amber-500 block">Fat (g)</span>
            <div className="flex items-center gap-1.5 mt-2">
              <Button
                variant="outline"
                size="icon"
                className="w-8 h-8 shrink-0"
                onClick={() => setFat(prev => Math.max(1, prev - 5))}
              >
                <Minus className="w-3.5 h-3.5" />
              </Button>
              <Input
                type="number"
                value={fat}
                onChange={(e) => setFat(Math.max(1, Number(e.target.value)))}
                className="text-center h-8 px-1"
              />
              <Button
                variant="outline"
                size="icon"
                className="w-8 h-8 shrink-0"
                onClick={() => setFat(prev => prev + 5)}
              >
                <Plus className="w-3.5 h-3.5" />
              </Button>
            </div>
            <span className="text-[10px] text-muted-foreground block text-center mt-1">{fat * 9} kcal</span>
          </div>

          <div className="space-y-1.5 p-3 border rounded-lg bg-card shadow-sm">
            <span className="text-xs font-bold text-rose-500 block">Declared Kcal</span>
            <div className="flex items-center gap-1.5 mt-2">
              <Button
                variant="outline"
                size="icon"
                className="w-8 h-8 shrink-0"
                onClick={() => setKcal(prev => Math.max(1, prev - 50))}
              >
                <Minus className="w-3.5 h-3.5" />
              </Button>
              <Input
                type="number"
                value={kcal}
                onChange={(e) => setKcal(Math.max(1, Number(e.target.value)))}
                className="text-center h-8 px-1"
              />
              <Button
                variant="outline"
                size="icon"
                className="w-8 h-8 shrink-0"
                onClick={() => setKcal(prev => prev + 50)}
              >
                <Plus className="w-3.5 h-3.5" />
              </Button>
            </div>
            <span className="text-[10px] text-muted-foreground block text-center mt-1">Calculated: {calculatedKcal} kcal</span>
          </div>
        </div>

        <div className={`p-4 rounded-lg flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 border transition-all ${
          hasDiscrepancy
            ? 'bg-amber-500/10 border-amber-500/20 text-amber-800 dark:text-amber-300'
            : 'bg-accent/10 border-primary/20 text-primary'
        }`}>
          <div className="flex gap-2.5 items-start">
            {hasDiscrepancy ? (
              <AlertTriangle className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
            ) : (
              <Calculator className="w-5 h-5 text-primary shrink-0 mt-0.5" />
            )}
            <div>
              <p className="text-sm font-bold">
                {hasDiscrepancy
                  ? 'Macronutrient Calorie Discrepancy'
                  : 'Calorie and macro totals are aligned!'}
              </p>
              <p className="text-xs mt-0.5 leading-relaxed opacity-90">
                Sum of macros yields <strong>{calculatedKcal} kcal</strong>, while your declared calories are <strong>{kcal} kcal</strong>.
              </p>
            </div>
          </div>
          {hasDiscrepancy && (
            <Button
              onClick={handleAutocorrectKcal}
              size="sm"
              variant="outline"
              className="bg-background border-amber-500/30 text-amber-800 hover:bg-amber-500/10 hover:text-amber-900 shrink-0 h-8 font-bold"
            >
              Autocorrect kcal
            </Button>
          )}
        </div>

        {/* Meals Section */}
        <div className="border rounded-xl overflow-hidden">
          <button
            onClick={() => setShowMeals(!showMeals)}
            className="w-full flex items-center justify-between px-4 py-3 text-left hover:bg-secondary/30 transition-colors"
          >
            <div className="flex items-center gap-2">
              <Utensils className="w-4 h-4 text-primary" />
              <span className="text-sm font-bold">Meal slots</span>
              {mealTotals.kcal > 0 && (
                <span className="text-[11px] text-muted-foreground">
                  {mealTotals.kcal} kcal &middot; {mealTotals.protein}p &middot; {mealTotals.carbs}c &middot; {mealTotals.fat}f
                </span>
              )}
            </div>
            {showMeals ? <ChevronDown className="w-4 h-4 text-muted-foreground" /> : <ChevronRight className="w-4 h-4 text-muted-foreground" />}
          </button>

          {showMeals && (
            <div className="px-4 pb-4 space-y-3 border-t pt-3">
              {/* Totals vs daily target bar */}
              <div className={`p-3 rounded-lg text-xs space-y-1 ${
                Math.abs(mealTotals.kcal - kcal) > 50
                  ? 'bg-amber-500/10 border border-amber-500/20'
                  : 'bg-accent/10 border border-primary/10'
              }`}>
                <div className="flex items-center justify-between font-medium">
                  <span>Meal total</span>
                  <span>{mealTotals.kcal} / {kcal} kcal</span>
                </div>
                <div className="flex gap-3 text-muted-foreground">
                  <span>P: {mealTotals.protein}/{protein}g</span>
                  <span>C: {mealTotals.carbs}/{carbs}g</span>
                  <span>F: {mealTotals.fat}/{fat}g</span>
                </div>
                <div className="w-full h-1.5 bg-muted rounded-full mt-1 overflow-hidden">
                  <div className="h-full bg-primary rounded-full transition-all" style={{ width: `${Math.min(100, (mealTotals.kcal / Math.max(1, kcal)) * 100)}%` }} />
                </div>
              </div>

              {/* Meal slots */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                {meals.map((meal, i) => (
                  <div key={meal.slot} className="border rounded-lg p-3 space-y-2">
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">{meal.slot}</span>
                      <button
                        onClick={() => setRecipePickerSlot(meal.slot)}
                        className="flex items-center gap-1 text-[10px] text-primary hover:text-primary/80 transition-colors"
                        title="Assign recipe"
                      >
                        <BookOpen className="w-3 h-3" />
                        {meal.recipe_id ? 'Change' : 'Assign'}
                      </button>
                    </div>
                    <input
                      value={meal.title}
                      onChange={e => {
                        const next = [...meals];
                        next[i] = { ...next[i]!, title: e.target.value };
                        setMeals(next);
                      }}
                      placeholder={`${meal.slot} title`}
                      className="w-full px-2 py-1 text-xs rounded border bg-background focus:outline-none focus:ring-1 focus:ring-primary"
                    />
                    <div className="grid grid-cols-4 gap-1.5">
                      {(['kcal','protein','carbs','fat'] as const).map(f => (
                        <div key={f}>
                          <label className="text-[9px] text-muted-foreground block">{f === 'kcal' ? 'kcal' : f === 'protein' ? 'P' : f === 'carbs' ? 'C' : 'F'}</label>
                          <input
                            type="number" min={0} value={(meal as any)[f] || ''}
                            onChange={e => {
                              const next = [...meals];
                              next[i] = { ...next[i]!, [f]: e.target.value ? +e.target.value : 0 };
                              setMeals(next);
                            }}
                            className="w-full px-1.5 py-1 text-[11px] rounded border bg-background focus:outline-none focus:ring-1 focus:ring-primary"
                          />
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>

      {recipePickerSlot && (
        <RecipePickerModal
          mealType={recipePickerSlot}
          onSelect={(recipe) => {
            setMeals(prev => prev.map(m =>
              m.slot === recipePickerSlot
                ? { ...m, title: recipe.title, kcal: recipe.kcal, protein: recipe.protein, carbs: recipe.carbs, fat: recipe.fat, recipe_id: recipe.id }
                : m
            ));
            setRecipePickerSlot(null);
          }}
          onClose={() => setRecipePickerSlot(null)}
        />
      )}
    </Card>
  );
};
