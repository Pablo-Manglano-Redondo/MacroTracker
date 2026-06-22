import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';
import {
  defaultPortalLocale,
  portalI18nData,
  portalLocaleMetadata,
  type PortalLocale,
  type PortalTranslationKey,
} from './generated/i18n';

export type { PortalLocale, PortalTranslationKey } from './generated/i18n';

type TranslationParams = Record<string, string | number | boolean | null | undefined>;

type PortalI18nContextValue = {
  locale: PortalLocale;
  setLocale: (locale: PortalLocale) => void;
  t: (key: PortalTranslationKey, params?: TranslationParams) => string;
  has: (key: PortalTranslationKey, locale?: PortalLocale) => boolean;
  locales: typeof portalLocaleMetadata;
};

const PortalI18nContext = createContext<PortalI18nContextValue | undefined>(
  undefined,
);

const supportedLocales = portalLocaleMetadata.map((locale) => locale.code as PortalLocale);

function normalizePortalLocale(value: string | null | undefined): PortalLocale {
  const normalized = `${value ?? ''}`.replace('_', '-').toLowerCase();
  const exact = supportedLocales.find(
    (locale) => locale.toLowerCase() === normalized,
  );
  if (exact) {
    return exact;
  }

  const baseLanguage = normalized.split('-')[0];
  const base = portalLocaleMetadata.find(
    (locale) => locale.languageCode.toLowerCase() === baseLanguage,
  );
  if (base) {
    return base.code as PortalLocale;
  }

  return defaultPortalLocale;
}

function formatTemplate(
  template: string,
  params?: TranslationParams,
): string {
  if (!params) {
    return template;
  }

  return template.replace(/\{(\w+)\}/g, (_, key: string) =>
    Object.prototype.hasOwnProperty.call(params, key)
      ? String(params[key] ?? '')
      : `{${key}}`,
  );
}

function detectInitialLocale(): PortalLocale {
  if (typeof window === 'undefined') {
    return defaultPortalLocale;
  }

  const saved = window.localStorage.getItem('portal-locale');
  if (saved) {
    return normalizePortalLocale(saved);
  }

  return normalizePortalLocale(window.navigator.language);
}

export const PortalI18nProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [locale, setLocale] = useState<PortalLocale>(detectInitialLocale);

  useEffect(() => {
    window.localStorage.setItem('portal-locale', locale);
    document.documentElement.lang = locale;
  }, [locale]);

  const value = useMemo<PortalI18nContextValue>(
    () => ({
      locale,
      setLocale,
      t: (key, params) => {
        const template =
          portalI18nData[locale]?.[key] ??
          portalI18nData[defaultPortalLocale][key];
        return formatTemplate(template, params);
      },
      has: (key, targetLocale = locale) =>
        key in (portalI18nData[targetLocale] ?? portalI18nData[defaultPortalLocale]),
      locales: portalLocaleMetadata,
    }),
    [locale],
  );

  return (
    <PortalI18nContext.Provider value={value}>
      {children}
    </PortalI18nContext.Provider>
  );
};

export function usePortalI18n() {
  const context = useContext(PortalI18nContext);
  if (!context) {
    throw new Error('usePortalI18n must be used within PortalI18nProvider');
  }

  return context;
}
