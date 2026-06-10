import { z } from 'zod';
import { displayNameSchema, positiveNumber } from './validators';

export const profileSchema = z.object({
  displayName: displayNameSchema,
  businessName: z.string().max(100, 'Business name too long').optional().or(z.literal('')),
});

export const planSchema = z.object({
  name: z.string().min(1, 'Plan name is required').max(100, 'Plan name too long'),
  kcal: positiveNumber.max(10000, 'Calories seem too high'),
  protein: positiveNumber.max(1000, 'Protein seems too high'),
  carbs: positiveNumber.max(1000, 'Carbs seem too high'),
  fat: positiveNumber.max(500, 'Fat seems too high'),
}).refine(
  (data) => {
    const calculated = data.protein * 4 + data.carbs * 4 + data.fat * 9;
    return Math.abs(calculated - data.kcal) <= 5;
  },
  {
    message: "Macros don't match declared calories (use autocorrect)",
    path: ['kcal'],
  }
);

export const messageSchema = z.object({
  body: z.string().min(1, 'Message cannot be empty').max(5000, 'Message too long'),
});

export const checkoutSchema = z.object({
  tier: z.enum(['starter', 'growth', 'studio']),
});

export type ProfileFormData = z.infer<typeof profileSchema>;
export type PlanFormData = z.infer<typeof planSchema>;
export type MessageFormData = z.infer<typeof messageSchema>;
export type CheckoutFormData = z.infer<typeof checkoutSchema>;
