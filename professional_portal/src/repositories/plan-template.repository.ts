import { type SupabaseClient } from '@supabase/supabase-js';
import type { PlanTemplate } from '../types/database.types';

export const planTemplateRepository = {
  list: async (supabase: SupabaseClient, professionalId: string) => {
    const { data, error } = await supabase
      .from('plan_templates')
      .select('*')
      .eq('professional_id', professionalId)
      .order('use_count', { ascending: false });
    if (error) throw error;
    return data as PlanTemplate[];
  },

  create: async (supabase: SupabaseClient, template: Partial<PlanTemplate>) => {
    const { data, error } = await supabase
      .from('plan_templates')
      .insert(template)
      .select()
      .single();
    if (error) throw error;
    return data as PlanTemplate;
  },

  remove: async (supabase: SupabaseClient, id: string) => {
    const { error } = await supabase
      .from('plan_templates')
      .delete()
      .eq('id', id);
    if (error) throw error;
  },

  incrementUse: async (supabase: SupabaseClient, id: string) => {
    const { data, error } = await supabase
      .from('plan_templates')
      .update({ use_count: supabase.rpc('increment') as any })
      .eq('id', id)
      .select()
      .single();
    if (error) throw error;
    return data as PlanTemplate;
  },
};
