# Shared I18n

`shared/i18n/locales/*.json` are the canonical source of truth for user-visible copy across Flutter, `professional_portal`, and Supabase edge functions.

Rules:
- Add or edit copy in locale JSON, not in generated ARB or generated TS/Dart files.
- Keep key parity and placeholder parity across locales.
- Use stable domain prefixes such as `flutter.*`, `portal.*`, and `functions.*`.
- Run `node scripts/i18n/sync-i18n.mjs build` after changing locale files.

Bootstrap and migration:
- `node scripts/i18n/sync-i18n.mjs bootstrap`

Validation and generation:
- `node scripts/i18n/sync-i18n.mjs validate`
- `node scripts/i18n/sync-i18n.mjs build`
- `pwsh ./scripts/check-i18n-readiness.ps1`
