import { type SupabaseClient } from '@supabase/supabase-js';
import type { ProfessionalRecipe, ClientProposedRecipe } from '../types/database.types';

export const recipeRepository = {
  list: async (supabase: SupabaseClient, professionalId: string) => {
    const { data, error } = await supabase
      .from('professional_recipes')
      .select('*')
      .eq('professional_id', professionalId)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data as ProfessionalRecipe[];
  },

  get: async (supabase: SupabaseClient, id: string) => {
    const { data, error } = await supabase
      .from('professional_recipes')
      .select('*')
      .eq('id', id)
      .single();
    if (error) throw error;
    return data as ProfessionalRecipe;
  },

  create: async (supabase: SupabaseClient, recipe: Partial<ProfessionalRecipe>) => {
    const { data, error } = await supabase
      .from('professional_recipes')
      .insert(recipe)
      .select()
      .single();
    if (error) throw error;
    return data as ProfessionalRecipe;
  },

  update: async (supabase: SupabaseClient, id: string, updates: Partial<ProfessionalRecipe>) => {
    const { data, error } = await supabase
      .from('professional_recipes')
      .update(updates)
      .eq('id', id)
      .select()
      .single();
    if (error) throw error;
    return data as ProfessionalRecipe;
  },

  remove: async (supabase: SupabaseClient, id: string) => {
    const { error } = await supabase
      .from('professional_recipes')
      .delete()
      .eq('id', id);
    if (error) throw error;
  },

  proposeToClient: async (
    supabase: SupabaseClient,
    payload: {
      professional_client_id: string;
      recipe_id: string;
      professional_id: string;
      client_id: string;
      note?: string;
    }
  ) => {
    const { data, error } = await supabase
      .from('client_proposed_recipes')
      .insert(payload)
      .select('*, recipe:recipe_id(*)')
      .single();
    if (error) throw error;
    return data as ClientProposedRecipe;
  },

  getProposed: async (supabase: SupabaseClient, professionalClientId: string) => {
    const { data, error } = await supabase
      .from('client_proposed_recipes')
      .select('*, recipe:recipe_id(*)')
      .eq('professional_client_id', professionalClientId)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data as ClientProposedRecipe[];
  },
};
