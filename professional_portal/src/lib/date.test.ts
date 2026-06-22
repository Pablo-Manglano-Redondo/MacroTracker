import { describe, it, expect } from 'vitest';
import { toDateOnlyString, addDays, parseDateOnly, formatDateOnly } from './date';

describe('date utilities', () => {
  describe('toDateOnlyString', () => {
    it('formats a date as YYYY-MM-DD', () => {
      const date = new Date(2026, 5, 15); // June 15, 2026
      expect(toDateOnlyString(date)).toBe('2026-06-15');
    });

    it('pads single digit months and days with zero', () => {
      const date = new Date(2026, 0, 5); // January 5, 2026
      expect(toDateOnlyString(date)).toBe('2026-01-05');
    });
  });

  describe('addDays', () => {
    it('adds days correctly', () => {
      const date = new Date(2026, 5, 15);
      const result = addDays(date, 5);
      expect(result.getDate()).toBe(20);
    });

    it('subtracts days correctly when negative', () => {
      const date = new Date(2026, 5, 15);
      const result = addDays(date, -5);
      expect(result.getDate()).toBe(10);
    });

    it('rolls over months correctly', () => {
      const date = new Date(2026, 0, 31); // Jan 31
      const result = addDays(date, 1);
      expect(result.getMonth()).toBe(1); // Feb
      expect(result.getDate()).toBe(1);
    });
  });

  describe('parseDateOnly', () => {
    it('parses YYYY-MM-DD string correctly', () => {
      const parsed = parseDateOnly('2026-06-15');
      expect(parsed.getFullYear()).toBe(2026);
      expect(parsed.getMonth()).toBe(5); // June is 5 (0-indexed)
      expect(parsed.getDate()).toBe(15);
    });

    it('falls back to 1970-01-01 on invalid string', () => {
      const parsed = parseDateOnly('invalid-date');
      expect(parsed.getFullYear()).toBe(1970);
      expect(parsed.getMonth()).toBe(0);
      expect(parsed.getDate()).toBe(1);
    });
  });

  describe('formatDateOnly', () => {
    it('formats date according to locale and options', () => {
      const options: Intl.DateTimeFormatOptions = { year: 'numeric', month: 'numeric', day: 'numeric' };
      const formatted = formatDateOnly('2026-06-15', options, 'en-US');
      expect(formatted).toBe('6/15/2026');
    });

    it('falls back through supported portal locales', () => {
      const options: Intl.DateTimeFormatOptions = { year: 'numeric', month: '2-digit', day: '2-digit' };
      const formatted = formatDateOnly('2026-06-15', options, 'es-MX');
      expect(formatted).toBe('15/06/2026');
    });
  });
});
