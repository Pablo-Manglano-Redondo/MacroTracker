export const colors = {
  primary: {
    DEFAULT: 'hsl(var(--primary))',
    foreground: 'hsl(var(--primary-foreground))',
    50: 'hsl(var(--primary) / 0.05)',
    100: 'hsl(var(--primary) / 0.1)',
    200: 'hsl(var(--primary) / 0.2)',
    300: 'hsl(var(--primary) / 0.3)',
    400: 'hsl(var(--primary) / 0.4)',
    500: 'hsl(var(--primary) / 0.5)',
    600: 'hsl(var(--primary) / 0.6)',
    700: 'hsl(var(--primary) / 0.7)',
    800: 'hsl(var(--primary) / 0.8)',
    900: 'hsl(var(--primary) / 0.9)',
  },
  secondary: {
    DEFAULT: 'hsl(var(--secondary))',
    foreground: 'hsl(var(--secondary-foreground))',
  },
  destructive: {
    DEFAULT: 'hsl(var(--destructive))',
    foreground: 'hsl(var(--destructive-foreground))',
  },
  muted: {
    DEFAULT: 'hsl(var(--muted))',
    foreground: 'hsl(var(--muted-foreground))',
  },
  accent: {
    DEFAULT: 'hsl(var(--accent))',
    foreground: 'hsl(var(--accent-foreground))',
  },
  background: 'hsl(var(--background))',
  foreground: 'hsl(var(--foreground))',
  card: {
    DEFAULT: 'hsl(var(--card))',
    foreground: 'hsl(var(--card-foreground))',
  },
  popover: {
    DEFAULT: 'hsl(var(--popover))',
    foreground: 'hsl(var(--popover-foreground))',
  },
  border: 'hsl(var(--border))',
  input: 'hsl(var(--input))',
  ring: 'hsl(var(--ring))',

  // Semantic aliases for common use cases
  success: {
    DEFAULT: 'hsl(153 51% 28%)',
    foreground: 'hsl(0 0% 100%)',
    light: 'hsl(153 38% 93%)',
    dark: 'hsl(153 44% 16%)',
  },
  warning: {
    DEFAULT: 'hsl(38 92% 50%)',
    foreground: 'hsl(0 0% 100%)',
    light: 'hsl(48 96% 89%)',
    dark: 'hsl(38 92% 40%)',
  },
  info: {
    DEFAULT: 'hsl(221 83% 53%)',
    foreground: 'hsl(0 0% 100%)',
    light: 'hsl(219 100% 97%)',
    dark: 'hsl(221 83% 43%)',
  },

  // Chart/visualization colors
  chart: {
    1: 'hsl(var(--primary))',
    2: 'hsl(38 92% 50%)',
    3: 'hsl(221 83% 53%)',
    4: 'hsl(340 82% 52%)',
    5: 'hsl(142 71% 45%)',
  },

  // Adherence colors (for snapshots)
  adherence: {
    excellent: 'hsl(153 51% 28%)',
    good: 'hsl(38 92% 50%)',
    poor: 'hsl(340 82% 52%)',
    neutral: 'hsl(150 6% 43%)',
  },
} as const;

export type Colors = typeof colors;