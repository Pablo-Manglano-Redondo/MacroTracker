export function toDateOnlyString(date: Date = new Date()): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

export function addDays(date: Date, days: number): Date {
  const next = new Date(date);
  next.setDate(next.getDate() + days);
  return next;
}

export function parseDateOnly(value: string): Date {
  const [rawYear = 1970, rawMonth = 1, rawDay = 1] = value
    .split('-')
    .map(Number);
  const safeYear: number = Number.isFinite(rawYear) ? rawYear : 1970;
  const safeMonth: number = Number.isFinite(rawMonth) ? rawMonth : 1;
  const safeDay: number = Number.isFinite(rawDay) ? rawDay : 1;
  return new Date(safeYear, safeMonth - 1, safeDay);
}

export function formatDateOnly(
  value: string,
  options?: Intl.DateTimeFormatOptions,
  locale?: string,
): string {
  return parseDateOnly(value).toLocaleDateString(locale, options);
}
