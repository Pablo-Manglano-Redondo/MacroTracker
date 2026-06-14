# Supabase Functions

This directory contains the backend functions used by the app-side AI capture flows.

## Functions

- `meal-interpretations-text`
- `meal-interpretations-photo`
- `delete-current-account`
- `stripe-pro-checkout`
- `stripe-pro-webhook`

Both functions return the same structured meal draft contract so the Flutter client does not depend on a specific AI provider.
The Stripe webhook updates professional Pro subscription state in Supabase.
`delete-current-account` requires a valid user JWT and a configured
`SUPABASE_SERVICE_ROLE_KEY`.

## Tooling

This project can use the Supabase CLI directly through `npx`, so a global install is not required.

Quick checks:

```bash
npx --yes supabase --version
deno test supabase/functions/_shared
```

## Local Test

Run the shared function contract tests with Deno:

```bash
pwsh ./supabase/test.functions.ps1
```

or directly:

```bash
deno test supabase/functions/_shared
```

## Local Serve

Serve all Edge Functions locally:

```bash
pwsh ./supabase/serve.functions.ps1
```

This uses:

```bash
npx --yes supabase functions serve --env-file supabase/.env.functions --workdir .
```

Notes:

- local serving usually requires Docker
- use `--NoVerifyJwt` in the helper script if you want to mirror the current unauthenticated mobile flow more closely

## Secrets

Use the local working file:

```bash
cp supabase/.env.functions.example supabase/.env.functions
```

Then replace the placeholder values with real secrets:

- `GEMINI_API_KEY`
- optional `GEMINI_MEAL_TEXT_MODEL`
- optional `GEMINI_MEAL_PHOTO_MODEL`
- optional `GEMINI_25_FLASH_LITE_INPUT_TOKEN_USD_PER_1M`
- optional `GEMINI_25_FLASH_LITE_OUTPUT_TOKEN_USD_PER_1M`
- optional `GEMINI_25_FLASH_INPUT_TOKEN_USD_PER_1M`
- optional `GEMINI_25_FLASH_OUTPUT_TOKEN_USD_PER_1M`
- `STRIPE_SECRET_KEY`
- `STRIPE_PRO_WEBHOOK_SECRET`
- `STRIPE_PRO_STARTER_MONTHLY_PRICE_ID`
- `STRIPE_PRO_STARTER_ANNUAL_PRICE_ID`
- `STRIPE_PRO_GROWTH_MONTHLY_PRICE_ID`
- `STRIPE_PRO_GROWTH_ANNUAL_PRICE_ID`
- `STRIPE_PRO_STUDIO_MONTHLY_PRICE_ID`
- `STRIPE_PRO_STUDIO_ANNUAL_PRICE_ID`

## Deploy

```bash
pwsh ./supabase/deploy.functions.ps1 -ProjectRef your-project-ref
```

The script will:

- push function secrets from `supabase/.env.functions`
- deploy `meal-interpretations-text`
- deploy `meal-interpretations-photo`
- deploy `delete-current-account`
- deploy `stripe-pro-checkout`
- deploy `stripe-pro-webhook`

## Professional Pro Billing

Use Stripe for the professional portal subscription because the existing
RevenueCat integration is app-store-oriented and currently exposes only the
mobile `premium` entitlement. The B2B Pro product is paid by the professional
in a web portal and must update Supabase server-side RLS fields such as
`professionals.pro_status` and `professionals.client_limit`.

Stripe checkout sessions should set either:

- `client_reference_id=<professionals.id>`
- or `metadata.professional_id=<professionals.id>`

Subscriptions should include:

- `metadata.professional_id`
- `metadata.tier` with `starter`, `growth`, or `studio`
- `metadata.billing_interval` with `monthly` or `annual`

Configure the Stripe endpoint to:

```text
https://<project-ref>.functions.supabase.co/stripe-pro-webhook
```

Listen for:

- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`

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

## Mobile Account Linking

The app starts with anonymous Supabase auth and lets users protect that same
account with Google when they need recovery or a professional connection.

Production setup:

1. Enable anonymous sign-ins in Supabase Auth.
2. Enable Google as a Supabase Auth provider.
3. In Google Cloud, use a Web OAuth client for Supabase Auth and add this
   authorized redirect URI:

```text
https://<project-ref>.supabase.co/auth/v1/callback
```

4. In Supabase Auth URL configuration, allow this mobile redirect URL:

```text
macrotracker://login-callback
```

For the current production project this means:

```text
https://vjbhtlautynotigaicjt.supabase.co/auth/v1/callback
macrotracker://login-callback
```

This Google identity is only for the MacroTracker cloud account. Google Drive
backup uses `google_sign_in` with the Drive API and remains a separate consent
flow because it needs the `drive.file` scope.

## Security Notes

- `verify_jwt = false` is enabled only for `meal-interpretations-text`,
  `meal-interpretations-photo`, and `stripe-pro-webhook`.
- `verify_jwt = true` is required for `stripe-pro-checkout` and
  `delete-current-account`.
- Images are sent inline for inference only and are not persisted by these functions.
- The functions intentionally avoid logging raw meal text or image payloads.
- Input size is validated before calling Gemini to reduce accidental cost spikes.

## Delete Account Rollout

Before deploying `delete-current-account`:

1. Apply the latest SQL migrations, including
   `20260606200100_delete_account_hardening.sql`.
2. Confirm the project has `SUPABASE_SERVICE_ROLE_KEY` available to functions.
3. Deploy functions with `pwsh ./supabase/deploy.functions.ps1 -ProjectRef your-project-ref`.

Expected behavior:

- authenticated guest and Google-linked users can delete their current cloud account
- remote rows with `on delete cascade` are removed automatically
- `client_invites.accepted_by` is preserved as historical metadata via
  `on delete set null`

## Cost Notes

The backend estimates cost using the actual model returned in each request.

Current default model split in code:

- text: `gemini-2.5-flash-lite`
- photo: `gemini-2.5-flash`

If you want lower cost, explicitly set `GEMINI_MEAL_PHOTO_MODEL=gemini-2.5-flash-lite`.
