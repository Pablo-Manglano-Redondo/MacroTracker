# Google Drive Backup Setup

This project uses `google_sign_in` and the Google Drive API for manual backups.
This is intentionally separate from Supabase Auth account linking. Supabase
Google login protects the MacroTracker cloud account; Drive backup asks for the
`drive.file` scope and stores encrypted ZIP files in the user's own Drive.

## Android

1. In Google Cloud, create OAuth credentials for:
   - Android app: package `com.epsait.macrotracker`
   - Web application
2. Add the SHA-1 and SHA-256 of every Android signing configuration you use.
3. Enable the Google Drive API.
4. Set the web client ID in your shell before building:

```powershell
$env:GOOGLE_DRIVE_SERVER_CLIENT_ID="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com"
```

5. Build with:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build-apk.ps1 -Mode debug -SkipPubGet
```

The build script forwards `GOOGLE_DRIVE_SERVER_CLIENT_ID` as a Flutter `--dart-define`.

## iOS

1. In Google Cloud or Firebase, create the iOS OAuth client for bundle ID `com.epsait.macrotracker`.
2. Copy `ios/Flutter/GoogleDrive.xcconfig.template` to `ios/Flutter/GoogleDrive.xcconfig`.
3. Fill:
   - `GOOGLE_DRIVE_IOS_CLIENT_ID`
   - `GOOGLE_DRIVE_IOS_REVERSED_CLIENT_ID`
   - `GOOGLE_DRIVE_SERVER_CLIENT_ID`
4. Keep `ios/Flutter/GoogleDrive.xcconfig` out of git.

`Info.plist` already reads those values through build settings.

## Common failure modes

- `clientConfigurationError`:
  wrong package name, wrong bundle ID, missing SHA, or missing server client ID.
- Android account picker closes as canceled:
  often still a configuration error, usually SHA or OAuth mismatch.
- Google Drive backup dialog says configuration is missing:
  the app was built without `GOOGLE_DRIVE_SERVER_CLIENT_ID` on Android.

## Relationship with Supabase Auth

For production, keep these two Google OAuth flows configured in the same Google
Cloud project but treat them as different permissions:

- Supabase Auth Google provider:
  - needs a Web OAuth client ID and secret in Supabase.
  - Google Cloud authorized redirect URI:
    `https://vjbhtlautynotigaicjt.supabase.co/auth/v1/callback`
  - Supabase allowed mobile redirect URL:
    `macrotracker://login-callback`
  - should request only identity scopes such as email/profile.
- Google Drive backup:
  - needs Android/iOS OAuth clients for the app package or bundle ID.
  - needs the Web client ID exposed as `GOOGLE_DRIVE_SERVER_CLIENT_ID`.
  - requests `drive.file` only when the user connects Drive from backup
    settings.

Linking Google in Supabase does not grant Drive backup permission. Connecting
Drive does not protect or recover the Supabase cloud account.
