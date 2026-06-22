import {
  defaultRequestLocale,
  requestI18nData,
  requestLocaleMetadata,
  type RequestLocale,
  type RequestTranslationKey,
} from "./generated_i18n.ts";

type TranslationParams = Record<string, string | number | boolean | null | undefined>;

const supportedRequestLocales = requestLocaleMetadata.map(
  (locale) => locale.code as RequestLocale,
);

function formatTemplate(
  template: string,
  params?: TranslationParams,
): string {
  if (!params) {
    return template;
  }

  return template.replace(/\{(\w+)\}/g, (_, key: string) =>
    Object.prototype.hasOwnProperty.call(params, key)
      ? String(params[key] ?? "")
      : `{${key}}`
  );
}

function localeFromBody(body?: unknown): string {
  return typeof body === "object" &&
      body !== null &&
      "locale" in body &&
      typeof (body as { locale?: unknown }).locale === "string"
    ? (body as { locale: string }).locale
    : "";
}

function localeFromHeader(request: Request): string {
  return request.headers.get("accept-language") ?? "";
}

function normalizeRequestLocale(input?: string): RequestLocale {
  const normalized = `${input ?? ""}`.replace(/_/g, "-").trim().toLowerCase();
  const exact = supportedRequestLocales.find(
    (locale) => locale.toLowerCase() === normalized,
  );
  if (exact) {
    return exact;
  }

  const baseLanguage = normalized.split("-")[0];
  const base = requestLocaleMetadata.find(
    (locale) => locale.languageCode.toLowerCase() === baseLanguage,
  );
  if (base) {
    return base.code as RequestLocale;
  }

  return defaultRequestLocale;
}

function resolveRequestLocale(
  request: Request,
  body?: unknown,
): RequestLocale {
  return normalizeRequestLocale(localeFromBody(body) || localeFromHeader(request));
}

function t(
  locale: RequestLocale,
  key: RequestTranslationKey,
  params?: TranslationParams,
): string {
  const template =
    requestI18nData[locale]?.[key] ??
    requestI18nData[defaultRequestLocale][key];
  return formatTemplate(template, params);
}

export {
  defaultRequestLocale,
  normalizeRequestLocale,
  requestLocaleMetadata,
  resolveRequestLocale,
  supportedRequestLocales,
  t,
  type RequestLocale,
  type RequestTranslationKey,
};
