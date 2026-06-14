# MacroTracker Privacy Policy

Last updated: 2026-06-01

MacroTracker is provided by EPSAIT. This policy describes how MacroTracker handles data when installed from Google Play or built from source.

## Contact

Privacy and support contact: support@epsait.com

## Data Stored On Device

MacroTracker stores nutrition, meal diary, recipe, settings, body progress, reminder, and activity information locally on the user's device by default.

## Optional Data Sent Outside The Device

MacroTracker can send limited data outside the device only when the user enables or uses the related feature:

- Food search and barcode lookup: search terms or barcodes may be sent to food data providers configured by the app.
- AI meal interpretation: meal text or selected meal photos may be sent to EPSAIT's Supabase Edge Functions for inference. The app requires user review before saving any AI result.
- Anonymous diagnostics: if the user opts in, crash and diagnostic data may be sent to Sentry to improve stability.
- Google Drive backup: if the user connects Google Drive, encrypted backup files are uploaded to the user's own Google Drive account.
- Professional plan sharing: if the user accepts an invite from a professional, MacroTracker creates a Supabase cloud identity and starts with aggregate-only sharing for that relationship. Shared snapshots include daily calories, macronutrient totals and targets, meal count, optional body weight if enabled in a future version, and sync timestamps. The raw meal diary, food names, photos, recipes, and full activity records are not shared by default. If the user later enables detailed sharing explicitly inside the app, the professional may also read raw diary entries and per-meal detail for that relationship until the user changes the sharing level again or revokes access.

## Health Connect

MacroTracker can read Health Connect data only after the user grants Android permissions. The app requests read access for sleep sessions, exercise sessions, steps, distance, total calories burned, and active calories burned. These records are used to show activity and wellness context inside MacroTracker and to help estimate nutrition progress. MacroTracker does not sell Health Connect data and does not use it for advertising.

## Retention And Deletion

Local app data remains on the device until the user deletes it, clears app storage, uninstalls the app, or imports/replaces data through app tools. Google Drive backups are controlled by the user's Google Drive account and can be deleted there. Health Connect access can be revoked from Android Health Connect settings. Professional sharing can be revoked inside MacroTracker; revocation stops future snapshot sync and marks the professional-client connection as revoked.

## Third-Party Processors

Optional integrations may involve Google Drive, Google Health Connect, Supabase, Sentry, Stripe for professional portal billing, food data providers, and AI model providers used behind EPSAIT's Supabase Edge Functions.

## Medical Disclaimer

MacroTracker is not a medical device. Nutrition, activity, and AI-generated information may be incomplete or inaccurate and should not replace professional medical advice.
