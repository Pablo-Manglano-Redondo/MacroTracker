# MacroTracker — AI Agent Context

## Tech Stack
- **Flutter** 3.x (pinned via `.fvmrc`), **Dart** 3.x+
- **State management:** `flutter_bloc` (17 BLoCs) + `GetIt` DI (94+ registrations)
- **Local DB:** Hive (encrypted, NoSQL, local-first)
- **Cloud:** Supabase (auth, edge functions in Deno, RLS)
- **AI:** Gemini via Supabase Edge Functions
- **Payments:** RevenueCat (B2C) + Stripe (B2B via Supabase)
- **Crash/Error:** Sentry (opt-in, user-consented)
- **Analytics:** Firebase Analytics + Firebase Cloud Messaging
- **CI:** GitHub Actions (Android + iOS, builds + TestFlight)

## Architecture
- **Clean Architecture** enforced per feature: `data/` → `domain/` → `presentation/`
- **Local-first** — all core data stored on-device in Hive; cloud sync optional for professional plan
- **19 features** in `lib/features/`, shared infrastructure in `lib/core/`
- **Dependency injection** via `GetIt` service locator in `lib/core/utils/locator.dart` (487 lines)

## Directory Conventions (MUST FOLLOW)
```
lib/
  core/              # Shared infra: data sources, repos, entities, use cases, services, utils
  features/          # Feature slices
    <feature>/
      data/          # data_source/ (singular), dbo/, repository/
      domain/        # entity/, usecase/
      presentation/  # bloc/, widgets/, <feature>_screen.dart
  generated/         # l10n (EN + ES), code-gen outputs
  l10n/              # ARB source files
```

## Naming Rules
- Directories: `data_source/` (singular), `dbo/` (not dto/), `widgets/` (plural), `bloc/`
- Files: `snake_case.dart`
- Classes: `PascalCase`, suffix `*Entity` / `*DBO` / `*Bloc` / `*Usecase`
- Screen files: `_screen.dart` suffix (not `_page.dart`)

## DI Pattern
- All BLoCs, use cases, repos, data sources, services registered in `locator.dart`
- **6 LazySingleton BLoCs** (app-shell: HomeBloc, DiaryBloc, CalendarDayBloc, ProfileBloc, SettingsBloc, OnboardingBloc)
- **11 Factory BLoCs** (screen-scoped: AddMeal, Scanner, EditMeal, etc.)
- No `BlocProvider` used — BLoCs resolved via `locator<Bloc>()` in `initState`
- `Provider` only for `ThemeModeProvider` (theme + locale)

## BLoC-to-BLoC Communication
- Via global locator: `locator<DiaryBloc>().add(...)` — no event bus
- Covers 12+ widgets/BLoCs. Grep for `locator<.*Bloc>` to find coupling points.

## Testing
- `flutter test` runs all tests
- Unit tests in `test/unit_test/`, widget tests in `test/widget_test/`
- Fixtures in `test/fixture/` (MealEntityFixtures, UserEntityFixtures, PhysicalActivityFixtures)
- **Manual fakes pattern** — no mocking framework. Fakes defined inline in each test file with `_Fake` prefix.
- CI gate: `scripts/check-product-readiness.ps1` — update when adding critical tests
- Coverage target: 40%+ (currently ~12%)

## Build
- `flutter build appbundle` (Android) / `flutter build ios` (iOS)
- `dart run build_runner build --delete-conflicting-outputs` before build
- Flutter version managed via `.fvmrc`

## Known Technical Debt
1. **HomeBloc** has 17 dependencies — do NOT add more. Create new BLoCs instead.
2. **locator.dart** is 487 lines — register new deps with clear section header at bottom of `initLocator()`
3. **workmanager_android** is vendored at `third_party/workmanager_android` — check README before modifying
4. **Google Drive backup** uses direct HTTP (not googleapis) — keep this pattern
5. **Test coverage low** (~12%) — every new business logic MUST include tests
6. **`data_source/` vs `data_sources/`:** use `data_source/` (singular). `add_meal/` and `meal_capture/` need migration.
7. **Entity mutability:** `UserEntity` has public non-final fields. Use `copyWith` or migrate to `freezed`.
