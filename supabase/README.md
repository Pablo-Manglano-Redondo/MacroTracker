# Supabase Functions

This directory contains the backend functions used by the app-side AI capture flows.

## Functions

- `meal-interpretations-text`
- `meal-interpretations-photo`

Both functions return the same structured meal draft contract so the Flutter client does not depend on a specific AI provider.

## Secrets

Use the local working file:

```bash
cp supabase/.env.functions.example supabase/.env.functions
```

Then replace the placeholder values with real secrets:

- `GEMINI_API_KEY`
- optional `GEMINI_MEAL_TEXT_MODEL`
- optional `GEMINI_MEAL_PHOTO_MODEL`

## Deploy

```bash
pwsh ./supabase/deploy.functions.ps1 -ProjectRef your-project-ref
```

The script will:

- push function secrets from `supabase/.env.functions`
- deploy `meal-interpretations-text`
- deploy `meal-interpretations-photo`

If secrets are already configured remotely, you can skip that step:

```bash
pwsh ./supabase/deploy.functions.ps1 -ProjectRef your-project-ref -SkipSecrets
```

## Auth

Before deploying, provide Supabase auth using one of these:

```bash
npx supabase login
```

or

```bash
$env:SUPABASE_ACCESS_TOKEN="your-access-token"
```

## Security Notes

- `verify_jwt = false` is enabled because the mobile app currently calls these endpoints without user auth.
- Images are sent inline for inference only and are not persisted by these functions.
- The functions intentionally avoid logging raw meal text or image payloads.
- Input size is validated before calling Gemini to reduce accidental cost spikes.

## Cost Notes

Defaults are set to `gemini-2.5-flash-lite` to optimize for low cost first.

If photo quality is not good enough, upgrade only the photo model first and keep text on Flash-Lite.
