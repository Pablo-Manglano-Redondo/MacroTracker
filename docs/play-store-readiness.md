# Google Play Store Readiness

This document captures the release declarations MacroTracker needs before production publication under EPSAIT.

Official references:

- Google Play Data safety: https://support.google.com/googleplay/android-developer/answer/10787469
- Health Connect publication and review: https://developer.android.com/health-and-fitness/health-connect/publish
- Health apps policy requirements: https://support.google.com/googleplay/android-developer/answer/16558241
- Play Store listing asset requirements: https://support.google.com/googleplay/android-developer/answer/9866151

## Package

- Android application ID: `com.epsait.macrotracker`
- Publisher: EPSAIT
- Version source: `pubspec.yaml`
- Release artifact: Android App Bundle (`.aab`)

## Data Safety Draft

Declare data collection/transmission for:

- Health and fitness data: optional Health Connect reads for sleep, workouts, steps, distance, and calories burned.
- Photos: optional meal photo inference when the user chooses AI photo capture.
- App activity / diagnostics: optional anonymous crash diagnostics when the user opts in.
- Files and docs: optional encrypted Google Drive backup controlled by the user.
- App info and performance: crash logs and diagnostics through Sentry when enabled.

Do not declare advertising or sale of user data unless the product behavior changes.

## Health Connect Declaration

Requested Health Connect read types:

- Sleep sessions
- Exercise sessions
- Steps
- Distance
- Total calories burned
- Active calories burned

Use case: show user-authorized activity, sleep, and calorie-burn context inside a calorie and macro tracking app.

## Permissions

Runtime permissions expected in the release manifest:

- Internet access for food search, Supabase AI functions, diagnostics, and Google Drive backup.
- Health Connect read permissions for user-authorized wellness import.
- Activity recognition for Android activity/step permission flows.
- Notifications and boot completed for optional meal reminders.
- Camera for barcode scanning and optional meal photo capture.
- Vibration, wake lock, network state, and foreground-service support contributed by reminder/background-work plugins.
- Biometric and fingerprint support contributed by secure local storage.

`SCHEDULE_EXACT_ALARM` is intentionally not requested. Meal reminders use inexact scheduling to avoid special exact alarm policy requirements.

## Required Manual Console Steps

1. Create or update Google Play app under EPSAIT.
2. Set privacy policy URL to the public EPSAIT-hosted MacroTracker privacy policy: `https://epsait.com/en/privacy/macrotracker`.
3. Complete Data Safety according to this document and the live policy.
4. Complete Health Connect declaration.
5. Upload `featureGraphic.png` at 1024x500 and store icon at 512x512.
6. Upload release `.aab` to internal testing first.
7. Run a closed test on physical Android devices before production rollout.
