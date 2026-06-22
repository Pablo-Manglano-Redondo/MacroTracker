import {
  defaultPortalLocale,
  portalLocaleMetadata,
  type PortalLocale,
} from './generated/i18n';

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
  locale?: PortalLocale | string,
): string {
  return parseDateOnly(value).toLocaleDateString(resolvePortalIntlLocale(locale), options);
}

export function resolvePortalIntlLocale(locale?: PortalLocale | string): string {
  const normalized = `${locale ?? defaultPortalLocale}`.replace('_', '-').toLowerCase();
  const exact = portalLocaleMetadata.find(
    (entry) => entry.code.toLowerCase() === normalized,
  );
  if (exact) {
    return exact.code;
  }

  const baseLanguage = normalized.split('-')[0];
  const base = portalLocaleMetadata.find(
    (entry) => entry.languageCode.toLowerCase() === baseLanguage,
  );
  return base?.code ?? defaultPortalLocale;
}

export function formatPortalDate(
  value: string | number | Date,
  locale: PortalLocale | string,
  options?: Intl.DateTimeFormatOptions,
): string {
  return new Date(value).toLocaleDateString(resolvePortalIntlLocale(locale), options);
}

export function formatPortalTime(
  value: string | number | Date,
  locale: PortalLocale | string,
  options?: Intl.DateTimeFormatOptions,
): string {
  return new Date(value).toLocaleTimeString(resolvePortalIntlLocale(locale), options);
}
