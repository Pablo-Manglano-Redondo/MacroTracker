import { type SupabaseClient } from '@supabase/supabase-js';

export interface NutritionPlanDay {
  id: string;
  plan_id: string;
  weekday: number;
  kcal_goal: number;
  protein_goal: number;
  carbs_goal: number;
  fat_goal: number;
}

export interface NutritionPlanMeal {
  id: string;
  plan_id: string;
  slot: string;
  title: string;
  notes: string | null;
  kcal: number | null;
  protein: number | null;
  carbs: number | null;
  fat: number | null;
  recipe_id: string | null;
  created_at: string;
}

export interface NutritionPlan {
  id: string;
  professional_id: string;
  client_id: string;
  name: string;
  objective: string;
  status: 'draft' | 'active' | 'archived';
  starts_on: string | null;
  ends_on: string | null;
  created_at: string;
  updated_at: string;
  days?: NutritionPlanDay[];
  meals?: NutritionPlanMeal[];
}

export const planRepository = {
  create: async (
    supabase: SupabaseClient,
    payload: {
      professional_id: string;
      client_id: string;
      name: string;
      objective?: string;
      status?: string;
    }
  ) => {
    const { data, error } = await supabase
      .from('nutrition_plans')
      .insert({
        professional_id: payload.professional_id,
        client_id: payload.client_id,
        name: payload.name,
        objective: payload.objective ?? 'general_fitness',
        status: payload.status ?? 'active',
      })
      .select('id')
      .single();

    if (error) throw error;
    return data as { id: string };
  },

  createDays: async (
    supabase: SupabaseClient,
    planId: string,
    macros: {
      kcal: number;
      protein: number;
      carbs: number;
      fat: number;
    }
  ) => {
    const dayRows = [1, 2, 3, 4, 5, 6, 7].map((weekday) => ({
      plan_id: planId,
      weekday,
      kcal_goal: macros.kcal,
      protein_goal: macros.protein,
      carbs_goal: macros.carbs,
      fat_goal: macros.fat,
    }));

    const { error } = await supabase
      .from('nutrition_plan_days')
      .insert(dayRows);

    if (error) throw error;
  },

  // List all plans for a client
  listByClient: async (
    supabase: SupabaseClient,
    professionalId: string,
    clientId: string,
  ) => {
    const { data, error } = await supabase
      .from('nutrition_plans')
      .select('*')
      .eq('professional_id', professionalId)
      .eq('client_id', clientId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return (data ?? []) as NutritionPlan[];
  },

  // Get a single plan with its days and meals
  getWithDays: async (supabase: SupabaseClient, planId: string) => {
    const { data: plan, error: planError } = await supabase
      .from('nutrition_plans')
      .select('*')
      .eq('id', planId)
      .single();

    if (planError) throw planError;

    const { data: days, error: daysError } = await supabase
      .from('nutrition_plan_days')
      .select('*')
      .eq('plan_id', planId)
      .order('weekday', { ascending: true });

    if (daysError) throw daysError;

    const { data: meals, error: mealsError } = await supabase
      .from('nutrition_plan_meals')
      .select('*')
      .eq('plan_id', planId)
      .order('slot', { ascending: true });

    if (mealsError) throw mealsError;

    return { ...plan, days: days ?? [], meals: meals ?? [] } as NutritionPlan;
  },

  // Update plan metadata and replace days
  update: async (
    supabase: SupabaseClient,
    planId: string,
    payload: {
      name?: string;
      objective?: string;
      status?: 'draft' | 'active' | 'archived';
      days?: {
        weekday: number;
        kcal_goal: number;
        protein_goal: number;
        carbs_goal: number;
        fat_goal: number;
      }[];
    }
  ) => {
    // Update plan metadata
    const updates: Record<string, unknown> = {};
    if (payload.name !== undefined) updates.name = payload.name;
    if (payload.objective !== undefined) updates.objective = payload.objective;
    if (payload.status !== undefined) updates.status = payload.status;

    if (Object.keys(updates).length > 0) {
      updates.updated_at = new Date().toISOString();
      const { error } = await supabase
        .from('nutrition_plans')
        .update(updates)
        .eq('id', planId);
      if (error) throw error;
    }

    // Replace days if provided
    if (payload.days) {
      // Delete existing days
      const { error: deleteError } = await supabase
        .from('nutrition_plan_days')
        .delete()
        .eq('plan_id', planId);
      if (deleteError) throw deleteError;

      // Insert new days
      const dayRows = payload.days.map((d) => ({
        plan_id: planId,
        weekday: d.weekday,
        kcal_goal: d.kcal_goal,
        protein_goal: d.protein_goal,
        carbs_goal: d.carbs_goal,
        fat_goal: d.fat_goal,
      }));

      const { error: insertError } = await supabase
        .from('nutrition_plan_days')
        .insert(dayRows);
      if (insertError) throw insertError;
    }
  },

  // Archive (soft delete) a plan
  archive: async (supabase: SupabaseClient, planId: string) => {
    const { error } = await supabase
      .from('nutrition_plans')
      .update({ status: 'archived', updated_at: new Date().toISOString() })
      .eq('id', planId);
    if (error) throw error;
  },

  batchArchive: async (supabase: SupabaseClient, planIds: string[]) => {
    if (planIds.length === 0) return;
    const { error } = await supabase
      .from('nutrition_plans')
      .update({ status: 'archived', updated_at: new Date().toISOString() })
      .in('id', planIds);
    if (error) throw error;
  },

  // Hard delete a plan
  delete: async (supabase: SupabaseClient, planId: string) => {
    // Days cascade delete via FK
    const { error } = await supabase
      .from('nutrition_plans')
      .delete()
      .eq('id', planId);
    if (error) throw error;
  },

  // Meals
  createMeals: async (
    supabase: SupabaseClient,
    planId: string,
    meals: { slot: string; title: string; kcal?: number | null; protein?: number | null; carbs?: number | null; fat?: number | null; notes?: string | null; recipe_id?: string | null }[]
  ) => {
    const rows = meals.filter(m => m.title?.trim()).map(m => ({
      plan_id: planId,
      slot: m.slot,
      title: m.title.trim(),
      notes: m.notes || null,
      kcal: m.kcal || null,
      protein: m.protein || null,
      carbs: m.carbs || null,
      fat: m.fat || null,
      recipe_id: m.recipe_id || null,
    }));
    if (rows.length === 0) return;
    const { error } = await supabase.from('nutrition_plan_meals').insert(rows);
    if (error) throw error;
  },

  listMealsByPlan: async (supabase: SupabaseClient, planId: string) => {
    const { data, error } = await supabase
      .from('nutrition_plan_meals')
      .select('*')
      .eq('plan_id', planId)
      .order('slot', { ascending: true });
    if (error) throw error;
    return (data ?? []) as {
      id: string; plan_id: string; slot: string; title: string; notes: string | null;
      kcal: number | null; protein: number | null; carbs: number | null; fat: number | null;
      recipe_id: string | null;
    }[];
  },

  replaceMeals: async (
    supabase: SupabaseClient,
    planId: string,
    meals: { slot: string; title: string; kcal?: number | null; protein?: number | null; carbs?: number | null; fat?: number | null; notes?: string | null; recipe_id?: string | null }[]
  ) => {
    const { error: delError } = await supabase.from('nutrition_plan_meals').delete().eq('plan_id', planId);
    if (delError) throw delError;
    const rows = meals.filter(m => m.title?.trim()).map(m => ({
      plan_id: planId,
      slot: m.slot,
      title: m.title.trim(),
      notes: m.notes || null,
      kcal: m.kcal || null,
      protein: m.protein || null,
      carbs: m.carbs || null,
      fat: m.fat || null,
      recipe_id: m.recipe_id || null,
    }));
    if (rows.length === 0) return;
    const { error } = await supabase.from('nutrition_plan_meals').insert(rows);
    if (error) throw error;
  },

  // Duplicate a plan (create new plan with same days)
  duplicate: async (
    supabase: SupabaseClient,
    professionalId: string,
    clientId: string,
    planId: string,
    newName?: string
  ) => {
    const source = await planRepository.getWithDays(supabase, planId);

    const { data: newPlan, error: planError } = await supabase
      .from('nutrition_plans')
      .insert({
        professional_id: professionalId,
        client_id: clientId,
        name: newName ?? `${source.name} (copy)`,
        objective: source.objective,
        status: 'draft',
      })
      .select('id')
      .single();

    if (planError) throw planError;

    if (source.days && source.days.length > 0) {
      const dayRows = source.days.map((d) => ({
        plan_id: newPlan.id,
        weekday: d.weekday,
        kcal_goal: d.kcal_goal,
        protein_goal: d.protein_goal,
        carbs_goal: d.carbs_goal,
        fat_goal: d.fat_goal,
      }));

      const { error: daysError } = await supabase
        .from('nutrition_plan_days')
        .insert(dayRows);
      if (daysError) throw daysError;
    }

    return newPlan as { id: string };
  },
};
