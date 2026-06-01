# iOS production readiness

This checklist covers the iOS items that cannot be fully verified from a
Windows development machine.

## Implemented in repo

- Apple Health is exposed as Apple Health on iOS and Health Connect on Android.
- iOS HealthKit read permission copy is present in `ios/Runner/Info.plist`.
- `ios/Runner/Runner.entitlements` enables the HealthKit entitlement for the
  Runner target.
- Camera permission copy covers barcode scanning and AI meal photos.
- Photo library permission copy covers AI meal photo import and data export.
- Daily Google Drive background backup is no longer promised on iOS; iOS keeps
  manual Drive backup only.
- Home widget refresh is Android-only until the iOS Widget Extension is wired
  into the Xcode project.

## Required on Mac before App Store submission

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Confirm the Runner target has the HealthKit capability enabled.
3. Confirm signing uses the correct Apple Developer team and bundle id
   `com.epsait.macrotracker`.
4. Build an archive with the production defines:

   ```sh
   flutter build ipa --release \
     --dart-define=REVENUECAT_IOS_API_KEY=... \
     --dart-define=GOOGLE_DRIVE_IOS_CLIENT_ID=... \
     --dart-define=GOOGLE_DRIVE_IOS_REVERSED_CLIENT_ID=... \
     --dart-define=GOOGLE_DRIVE_SERVER_CLIENT_ID=...
   ```

5. Upload to TestFlight and test on a real iPhone:
   - onboarding
   - Premium paywall
   - purchase and restore purchases
   - AI text and photo logging
   - camera barcode scanning
   - Apple Health permission request and sync
   - local notifications
   - manual Google Drive backup
6. Review the Xcode privacy report and App Store Connect privacy answers.

## Optional for parity

The Swift widget source exists at `ios/Widget/MacroTrackerWidget.swift`, but it
still needs a real Widget Extension target, App Group entitlements, and Xcode
project wiring before enabling iOS widget refresh in Flutter.
