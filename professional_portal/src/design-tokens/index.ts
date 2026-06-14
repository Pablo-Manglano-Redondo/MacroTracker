export * from './colors';
export * from './spacing';
export * from './typography';
export * from './radii';
export * from './shadows';
export * from './transitions';
export * from './breakpoints';

import { colors } from './colors';
import { spacing } from './spacing';
import { typography } from './typography';
import { radii } from './radii';
import { shadows } from './shadows';
import { transitions } from './transitions';
import { breakpoints } from './breakpoints';

export const designTokens = {
  colors,
  spacing,
  typography,
  radii,
  shadows,
  transitions,
  breakpoints,
} as const;

export type DesignTokens = typeof designTokens;
