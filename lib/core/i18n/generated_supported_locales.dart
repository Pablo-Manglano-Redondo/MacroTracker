import 'package:flutter/material.dart';

class AppSupportedLocale {
  final String code;
  final String nativeName;
  final String languageCode;
  final String? countryCode;

  const AppSupportedLocale({
    required this.code,
    required this.nativeName,
    required this.languageCode,
    required this.countryCode,
  });

  Locale get locale => Locale.fromSubtags(
        languageCode: languageCode,
        countryCode: countryCode,
      );
}

const appDefaultLocaleCode = 'en';

const appSupportedLocales = <AppSupportedLocale>[
  AppSupportedLocale(
    code: 'en',
    nativeName: 'English',
    languageCode: 'en',
    countryCode: null,
  ),
  AppSupportedLocale(
    code: 'en-GB',
    nativeName: 'English (United Kingdom)',
    languageCode: 'en',
    countryCode: 'GB',
  ),
  AppSupportedLocale(
    code: 'es',
    nativeName: 'Español',
    languageCode: 'es',
    countryCode: null,
  ),
];

AppSupportedLocale? findSupportedLocaleByCode(String code) {
  final normalized = code.replaceAll('_', '-').toLowerCase();
  for (final locale in appSupportedLocales) {
    if (locale.code.toLowerCase() == normalized) {
      return locale;
    }
  }

  final baseLanguage = normalized.split('-').first;
  for (final locale in appSupportedLocales) {
    if (locale.languageCode.toLowerCase() == baseLanguage) {
      return locale;
    }
  }

  for (final locale in appSupportedLocales) {
    if (locale.code == appDefaultLocaleCode) {
      return locale;
    }
  }
  return null;
}

Locale? buildSupportedLocale(String? code) {
  if (code == null || code.isEmpty) {
    return null;
  }
  return findSupportedLocaleByCode(code)?.locale;
}

List<AppSupportedLocale> getSupportedLocalesMetadata() => List.unmodifiable(appSupportedLocales);
