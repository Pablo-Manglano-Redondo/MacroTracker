# Product Validation Checklist

This is the minimum validation ladder for changes that touch monetization, AI request handling, Supabase account flows, or other release-critical product logic.

## Automated checks

Run these from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-product-readiness.ps1
```

That script currently runs:

1. `git diff --check`
2. Focused Flutter tests:
   - `test/unit_test/cloud_account_deletion_service_test.dart`
   - `test/unit_test/conversion_analytics_service_test.dart`
   - `test/unit_test/monetization_service_test.dart`
   - `test/unit_test/meal_interpretation_remote_data_source_test.dart`
3. Android debug build:
   - `powershell -ExecutionPolicy Bypass -File .\scripts\check-android-debug.ps1 -SkipPubGet`

Use the flags only when narrowing a failure:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-product-readiness.ps1 -SkipAndroidBuild
powershell -ExecutionPolicy Bypass -File .\scripts\check-product-readiness.ps1 -SkipFocusedTests
```

## Manual funnel checks

Run this short manual pass before calling monetization, AI, or cloud-account work done:

1. Guest user:
   exhaust the small guest AI allowance and confirm the gate blocks further use.
2. Protect with Google:
   link the account and confirm the AI state refreshes and reopens the remaining free allowance.
3. Premium purchase or restore:
   confirm premium bypasses trial consumption and removes the gate.
4. Cloud account deletion:
   confirm remote deletion succeeds before local cleanup and that a failed cloud call does not wipe local data.
5. AI remote failure:
   trigger a timeout or network failure, verify retry is available, and verify manual fallback does not lose the typed text or selected image.

## Notes

- The Android build may still emit non-blocking warnings from third-party plugins that have not yet migrated to built-in Kotlin.
- `flutter analyze` is not the primary gate in this checkout until the local tooling path is made consistently reliable again.
