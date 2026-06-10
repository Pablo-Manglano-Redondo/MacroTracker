-- Add recipe_id to nutrition_plan_meals
alter table public.nutrition_plan_meals
  add column recipe_id uuid references public.professional_recipes on delete set null;

-- Index for faster lookups
create index idx_nutrition_plan_meals_recipe_id on public.nutrition_plan_meals(recipe_id);
