import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';

export type PortalLocale = 'es' | 'en';

type PortalI18nContextValue = {
  locale: PortalLocale;
  setLocale: (locale: PortalLocale) => void;
  tr: (es: string, en: string) => string;
};

const PortalI18nContext = createContext<PortalI18nContextValue | undefined>(
  undefined,
);

function detectInitialLocale(): PortalLocale {
  if (typeof window === 'undefined') {
    return 'en';
  }

  const saved = window.localStorage.getItem('portal-locale');
  if (saved === 'es' || saved === 'en') {
    return saved;
  }

  return window.navigator.language.toLowerCase().startsWith('es') ? 'es' : 'en';
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
      tr: (es, en) => (locale === 'es' ? es : en),
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
