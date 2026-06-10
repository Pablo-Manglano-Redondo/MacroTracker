import React, { useState, useEffect, useMemo } from 'react';
import { usePlan } from '../../hooks/queries/usePlans';
import { useUpdatePlan } from '../../hooks/mutations/useUpdatePlan';
import type { MealInput } from '../../hooks/mutations/usePublishPlan';
import { ProfessionalClient } from '../../types/database.types';
import { planRepository } from '../../repositories/plan.repository';
import { supabase } from '../../lib/supabase';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Card } from '../ui/card';
import { Badge } from '../ui/badge';
import { toast } from '../../lib/toast';
import { ArrowLeft, Save, AlertTriangle, Loader2, Utensils, ChevronDown, ChevronRight, BookOpen } from 'lucide-react';
import { planSchema } from '../../lib/validation/schemas';
import { RecipePickerModal } from './RecipePickerModal';

interface PlanEditorProps {
  client: ProfessionalClient;
  planId: string;
  onBack: () => void;
}

export const PlanEditor: React.FC<PlanEditorProps> = ({ client, planId, onBack }) => {
  const { data: plan, isLoading, error } = usePlan(planId);
  const updatePlan = useUpdatePlan(client.client_id);

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

  const mealTotals = useMemo(() => ({
    kcal: meals.reduce((s, m) => s + (m.kcal || 0), 0),
    protein: meals.reduce((s, m) => s + (m.protein || 0), 0),
    carbs: meals.reduce((s, m) => s + (m.carbs || 0), 0),
    fat: meals.reduce((s, m) => s + (m.fat || 0), 0),
  }), [meals]);

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
      planRepository.listMealsByPlan(supabase, plan.id).then(existing => {
        if (existing.length > 0) {
          setMeals(existing.map(m => ({ slot: m.slot as string, title: m.title, kcal: m.kcal || 0, protein: m.protein || 0, carbs: m.carbs || 0, fat: m.fat || 0, recipe_id: (m as any).recipe_id || null })));
          setShowMeals(true);
        }
      }).catch(() => {});
    }
  }, [plan]);

  const calculatedKcal = protein * 4 + carbs * 4 + fat * 9;
  const hasDiscrepancy = Math.abs(calculatedKcal - kcal) > 5;

  const handleSave = async () => {
    if (!plan) return;

    const result = planSchema.safeParse({ name: planName, kcal, protein, carbs, fat });
    if (!result.success) {
      const firstIssue = result.error.issues[0];
      toast.error(firstIssue?.message || 'Invalid plan values');
      return;
    }

    const activeMeals = meals.filter(m => m.title?.trim() && ((m.kcal || 0) > 0 || (m.protein || 0) > 0));

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
      toast.success('Plan updated');
      setHasChanges(false);
    } catch (err: any) {
      toast.error('Failed to update plan', { description: err?.message || 'Unknown error' });
    }
  };

  const handleActivate = async () => {
    if (!plan) return;
    try {
      await updatePlan.mutateAsync({
        planId: plan.id,
        payload: { status: 'active' },
      });
      toast.success('Plan activated');
    } catch {
      toast.error('Failed to activate plan');
    }
  };

  if (isLoading) {
    return (
      <Card className="p-6 border flex items-center justify-center min-h-[300px]">
        <Loader2 className="w-6 h-6 animate-spin text-primary" />
      </Card>
    );
  }

  if (error || !plan) {
    return (
      <Card className="p-6 border text-center text-sm text-destructive">
        Failed to load plan. It may have been deleted.
        <Button onClick={onBack} variant="outline" size="sm" className="mt-4 block mx-auto">
          Back to plans
        </Button>
      </Card>
    );
  }

  return (
    <Card className="p-6 border">
      <div className="flex items-start justify-between border-b pb-4 mb-4">
        <div className="flex items-center gap-3">
          <Button onClick={onBack} variant="ghost" size="icon" className="w-8 h-8 shrink-0">
            <ArrowLeft className="w-4 h-4" />
          </Button>
          <div>
            <p className="text-xs font-bold tracking-wider text-primary uppercase mb-1">Edit Plan</p>
            <h3 className="text-lg font-bold">{plan.name}</h3>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {plan.status !== 'active' && (
            <Button onClick={handleActivate} variant="outline" size="sm" className="h-8">
              Activate
            </Button>
          )}
          <Badge variant={plan.status === 'active' ? 'success' : 'secondary'}>
            {plan.status}
          </Badge>
        </div>
      </div>

      {/* Plan Name */}
      <div className="space-y-1.5 mb-4">
        <label className="text-xs font-extrabold text-foreground uppercase tracking-wider">Plan Name</label>
        <Input
          value={planName}
          onChange={(e) => { setPlanName(e.target.value); setHasChanges(true); }}
          placeholder="e.g. Weekly coaching plan"
        />
      </div>

      {/* Macros and Calories Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-4">
        <div className="space-y-1.5 p-3 border rounded-lg bg-card shadow-sm">
          <span className="text-xs font-bold text-primary block">Protein (g)</span>
          <Input
            type="number"
            value={protein}
            onChange={(e) => { setProtein(Math.max(1, Number(e.target.value))); setHasChanges(true); }}
            className="text-center h-8 px-1"
          />
          <span className="text-[10px] text-muted-foreground block text-center mt-1">{protein * 4} kcal</span>
        </div>
        <div className="space-y-1.5 p-3 border rounded-lg bg-card shadow-sm">
          <span className="text-xs font-bold text-indigo-500 block">Carbs (g)</span>
          <Input
            type="number"
            value={carbs}
            onChange={(e) => { setCarbs(Math.max(1, Number(e.target.value))); setHasChanges(true); }}
            className="text-center h-8 px-1"
          />
          <span className="text-[10px] text-muted-foreground block text-center mt-1">{carbs * 4} kcal</span>
        </div>
        <div className="space-y-1.5 p-3 border rounded-lg bg-card shadow-sm">
          <span className="text-xs font-bold text-amber-500 block">Fat (g)</span>
          <Input
            type="number"
            value={fat}
            onChange={(e) => { setFat(Math.max(1, Number(e.target.value))); setHasChanges(true); }}
            className="text-center h-8 px-1"
          />
          <span className="text-[10px] text-muted-foreground block text-center mt-1">{fat * 9} kcal</span>
        </div>
        <div className="space-y-1.5 p-3 border rounded-lg bg-card shadow-sm">
          <span className="text-xs font-bold text-rose-500 block">Kcal</span>
          <Input
            type="number"
            value={kcal}
            onChange={(e) => { setKcal(Math.max(1, Number(e.target.value))); setHasChanges(true); }}
            className="text-center h-8 px-1"
          />
          <span className="text-[10px] text-muted-foreground block text-center mt-1">
            Calculated: {calculatedKcal} kcal
          </span>
        </div>
      </div>

      {/* Macro discrepancy warning */}
      {hasDiscrepancy && (
        <div className="flex items-start gap-3 p-4 rounded-lg bg-amber-500/10 border border-amber-500/20 text-amber-800 dark:text-amber-300 mb-4">
          <AlertTriangle className="w-5 h-5 shrink-0 mt-0.5 text-amber-600" />
          <div>
            <p className="text-sm font-bold">Macronutrient Calorie Discrepancy</p>
            <p className="text-xs mt-0.5 leading-relaxed opacity-90">
              Sum of macros yields <strong>{calculatedKcal} kcal</strong>, declared: <strong>{kcal} kcal</strong>.
            </p>
          </div>
          <Button
            onClick={() => { setKcal(calculatedKcal); setHasChanges(true); }}
            size="sm"
            variant="outline"
            className="bg-background border-amber-500/30 shrink-0 h-8 font-bold"
          >
            Autocorrect kcal
          </Button>
        </div>
      )}

      {/* Meals Section */}
      <div className="mb-4 border rounded-xl overflow-hidden">
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
                      setMeals(next); setHasChanges(true);
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
                            setMeals(next); setHasChanges(true);
                          }}
                          className="w-full px-1.5 py-1 text-[11px] rounded border bg-background focus:outline-none focus:ring-1 focus:ring-primary"
                        />
                      </div>
                    ))}
                  </div>
                </div>
              ))}
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
                  setHasChanges(true);
                  setRecipePickerSlot(null);
                }}
                onClose={() => setRecipePickerSlot(null)}
              />
            )}
          </div>
        )}
      </div>

      {/* Save */}
      <div className="flex items-center justify-between pt-4 border-t">
        <p className="text-xs text-muted-foreground">
          Created {new Date(plan.created_at).toLocaleDateString()}
        </p>
        <Button onClick={handleSave} disabled={!hasChanges || updatePlan.isPending}>
          {updatePlan.isPending ? (
            <Loader2 className="w-4 h-4 animate-spin mr-2" />
          ) : (
            <Save className="w-4 h-4 mr-2" />
          )}
          Save changes
        </Button>
      </div>
    </Card>
  );
};
