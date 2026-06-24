export interface Professional {
  id: string;
  user_id: string;
  display_name: string | null;
  business_name: string | null;
  pro_status: 'inactive' | 'active' | 'trialing' | 'past_due' | 'canceled' | string;
  commercial_tier: 'starter' | 'growth' | 'studio';
  billing_interval: 'monthly' | 'annual';
  client_limit: number | null;
  avatar_url?: string | null;
  verification_status?: 'basic' | 'verified' | 'rejected';
}

export interface ClientInvite {
  id: string;
  professional_id: string;
  invite_code: string;
  status: 'pending' | 'accepted' | 'expired' | 'revoked' | string;
  expires_at: string;
  created_at: string;
}

export interface ClientSharedSnapshot {
  id: string;
  professional_client_id: string;
  snapshot_date: string;
  kcal_actual: number;
  kcal_target: number;
  protein_actual: number;
  protein_target: number;
  carbs_actual: number;
  carbs_target: number;
  fat_actual: number;
  fat_target: number;
  weight_kg?: number | null;
  waist_cm?: number | null;
  meals_logged?: number;
  created_at: string;
}

export interface ProfessionalClient {
  id: string;
  professional_id: string;
  client_id: string;
  display_name?: string | null;
  status: 'connected' | 'revoked' | 'archived' | string;
  connected_at: string;
  sharing_mode: string;
  messages_enabled: boolean;
  client_shared_snapshots?: ClientSharedSnapshot[];
}

export interface ProfessionalClientMessage {
  id: string;
  professional_client_id: string;
  professional_id: string;
  client_id: string;
  author_role: 'professional' | 'client';
  body: string;
  created_at: string;
  client_read_at: string | null;
  professional_read_at: string | null;
}

export interface NutritionPlan {
  id: string;
  professional_id: string;
  client_id: string;
  name: string;
  objective: string;
  notes?: string | null;
  status: 'draft' | 'active' | 'archived' | string;
  starts_on?: string | null;
  ends_on?: string | null;
  created_at: string;
  updated_at: string;
  days?: NutritionPlanDay[];
  meals?: NutritionPlanMeal[];
}

export interface NutritionPlanDay {
  id: string;
  plan_id: string;
  plan_date?: string | null;
  weekday?: number | null;
  kcal_goal: number;
  carbs_goal: number;
  fat_goal: number;
  protein_goal: number;
}

export interface NutritionPlanMeal {
  id: string;
  plan_id: string;
  slot: 'breakfast' | 'lunch' | 'dinner' | 'snack';
  title: string;
  notes?: string | null;
  kcal?: number | null;
  carbs?: number | null;
  fat?: number | null;
  protein?: number | null;
  recipe_id?: string | null;
  created_at: string;
}

export interface ProfessionalRecipe {
  id: string;
  professional_id: string;
  title: string;
  description?: string | null;
  meal_type?: 'breakfast' | 'lunch' | 'dinner' | 'snack' | null;
  prep_time_min?: number | null;
  cook_time_min?: number | null;
  servings?: number | null;
  kcal?: number | null;
  protein?: number | null;
  carbs?: number | null;
  fat?: number | null;
  ingredients?: any[];
  instructions?: string | null;
  image_url?: string | null;
  source_url?: string | null;
  is_favorite?: boolean;
  created_at: string;
  updated_at: string;
}

export interface ClientProposedRecipe {
  id: string;
  professional_client_id: string;
  recipe_id: string;
  professional_id: string;
  client_id: string;
  note?: string | null;
  status: 'pending' | 'saved' | 'declined';
  created_at: string;
  recipe?: ProfessionalRecipe;
}

export interface ClientNote {
  id: string;
  professional_client_id: string;
  professional_id: string;
  title: string;
  body: string;
  category: 'general' | 'assessment' | 'medical' | 'progress' | 'billing' | 'other';
  pinned: boolean;
  created_at: string;
  updated_at: string;
}

export interface ClientProgress {
  id: string;
  professional_client_id: string;
  professional_id: string;
  client_id: string;
  record_date: string;
  weight_kg?: number | null;
  body_fat_pct?: number | null;
  waist_cm?: number | null;
  hip_cm?: number | null;
  chest_cm?: number | null;
  arm_cm?: number | null;
  thigh_cm?: number | null;
  photo_urls?: string[];
  energy_level?: number | null;
  sleep_hours?: number | null;
  notes?: string | null;
  source: 'professional' | 'client' | 'sync';
  created_at: string;
}

export interface CheckinTemplate {
  id: string;
  professional_id: string;
  title: string;
  questions: any[];
  is_default: boolean;
  created_at: string;
}

export interface ClientCheckin {
  id: string;
  professional_client_id: string;
  template_id?: string | null;
  professional_id: string;
  client_id: string;
  answers: Record<string, any>;
  energy_level?: number | null;
  sleep_avg?: number | null;
  mood?: string | null;
  notes?: string | null;
  submitted_at: string;
}

export interface PlanTemplate {
  id: string;
  professional_id: string;
  name: string;
  description?: string | null;
  duration_days: number;
  objective?: string;
  meals?: any[];
  tags?: string[];
  use_count: number;
  created_at: string;
  updated_at: string;
}

export interface ClientDiaryEntry {
  id: string;
  professional_client_id: string;
  professional_id: string;
  client_id: string;
  entry_date: string;
  meal_type: 'breakfast' | 'lunch' | 'dinner' | 'snack';
  meal_name: string | null;
  meal_brands: string | null;
  amount: number;
  unit: string | null;
  kcal: number | null;
  protein: number | null;
  carbs: number | null;
  fat: number | null;
  sugars: number | null;
  fiber: number | null;
  saturated_fat: number | null;
  source: string | null;
  created_at: string;
}

export interface ClientProgressSummary {
  latest_weight: number | null;
  weight_change_30d: number | null;
  latest_body_fat: number | null;
  checkin_count: number;
  last_checkin: string | null;
  recipe_count: number;
  note_count: number;
}
