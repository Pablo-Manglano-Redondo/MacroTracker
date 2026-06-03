# Professional Platform Release Runbook

This runbook is the operational path from the current repo state to a controlled
invite-only release.

## 1. Supabase Database

Apply the migration:

```powershell
npx supabase link --project-ref vjbhtlautynotigaicjt --workdir .
npx supabase db push --linked --workdir .
```

Then verify in Supabase:

- Anonymous sign-ins are enabled.
- Email magic-link auth is enabled for the professional portal.
- Site URL and redirect URLs include the professional portal origin.
- Run or adapt `supabase/rls.professional_smoke_test.sql` in staging to verify
  professional/client isolation with real JWTs.

## 2. Stripe

Use Stripe test mode first and create three recurring prices:

- Starter: metadata `tier=starter`
- Growth: metadata `tier=growth`
- Studio: metadata `tier=studio`

Set these Supabase function secrets:

```powershell
STRIPE_SECRET_KEY="sk_live_..."
STRIPE_PRO_WEBHOOK_SECRET="whsec_..."
STRIPE_PRO_STARTER_PRICE_ID="price_..."
STRIPE_PRO_GROWTH_PRICE_ID="price_..."
STRIPE_PRO_STUDIO_PRICE_ID="price_..."
```

Configure Stripe webhook endpoint:

```text
https://vjbhtlautynotigaicjt.functions.supabase.co/stripe-pro-webhook
```

Events:

- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`

For each tier, complete a test checkout from the portal and confirm the
`professionals` row receives:

- `pro_status = active` or `trialing`
- `stripe_customer_id`
- `stripe_subscription_id`
- `client_limit = 10` for Starter, `50` for Growth, `500` for Studio

Then cancel a test subscription and confirm new invites and new plans are
blocked while existing active client plans remain readable.

## 3. Edge Functions

Deploy:

```powershell
pwsh ./supabase/deploy.functions.ps1 -ProjectRef vjbhtlautynotigaicjt
```

Verify:

```powershell
deno test supabase/functions/_shared
deno check supabase/functions/stripe-pro-checkout/index.ts supabase/functions/stripe-pro-webhook/index.ts
```

## 4. Firebase Analytics

Add the private Firebase config files before mobile QA:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`, included in the Runner target

Verify analytics collection follows the existing anonymous-data consent:

- off by default before onboarding consent
- enabled after consent is accepted
- disabled again from Settings when the toggle is turned off

## 5. Professional Portal

Generate `professional_portal/config.js` during deployment:

```js
window.MT_SUPABASE_CONFIG = {
  url: "https://vjbhtlautynotigaicjt.supabase.co",
  anonKey: "<anon-key from .env>"
};
```

Host `professional_portal` as a static site over HTTPS.

## 6. Mobile Verification

Install an internal Android/iOS build and verify:

- Onboarding paywall appears and purchase/restore events are tracked only with
  anonymous-data opt-in enabled.
- AI meal trial counts 1/2/3, then blocks and opens the AI-limit paywall.
- Macro Coach shows locked free state and Premium unlocked suggestions.
- Weekly Insights free users see the weekly summary but cannot view or apply
  the kcal adjustment. Premium users can view and apply it.
- `macrotracker://invite/<CODE>` opens the professional plan screen.
- Manual code entry previews the invite.
- Accepting an invite creates a connected relationship.
- Revoking access sets `professional_clients.status = revoked`.
- Home targets use the active professional plan.
- Diary shows day-level plan comparison.
- Snapshots include aggregate totals only.
- Offline startup still shows the cached active plan.

## 7. Release Decision

Release only after:

- RLS isolation is verified with at least two professionals and two clients.
- Stripe checkout and webhook state changes have been tested in test mode.
- Legal text is reviewed for every launch market.
- App Store/Play Store privacy answers are updated for optional professional
  sharing and Stripe professional billing.
