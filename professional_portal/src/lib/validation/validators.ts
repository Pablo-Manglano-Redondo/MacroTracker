import { z } from 'zod';

export const emailSchema = z.string().email('Invalid email address');

export const uuidSchema = z.string().uuid('Invalid UUID');

export const positiveNumber = z.number().positive('Must be greater than zero').int('Must be a whole number');

export const displayNameSchema = z.string().min(1, 'Display name is required').max(100, 'Display name too long');
