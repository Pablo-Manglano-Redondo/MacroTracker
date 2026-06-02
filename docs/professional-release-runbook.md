# Professional Platform Release Runbook

This runbook is the operational path from the current repo state to a controlled
invite-only release.

## 1. Supabase Database

Apply the migration:

```powershell
npx supabase db push --project-ref <project-ref> --workdir .
```

Then verify in Supabase:

- Anonymous sign-ins are enabled.
- Email magic-link auth is enabled for the professional portal.
- Site URL and redirect URLs include the professional portal origin.
- Run or adapt `supabase/rls.professional_smoke_test.sql` in staging to verify
  professional/client isolation with real JWTs.

## 2. Stripe

Create three recurring prices:

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
https://<project-ref>.functions.supabase.co/stripe-pro-webhook
```

Events:

- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`

## 3. Edge Functions

Deploy:

```powershell
pwsh ./supabase/deploy.functions.ps1 -ProjectRef <project-ref>
```

Verify:

```powershell
deno test supabase/functions/_shared
deno check supabase/functions/stripe-pro-checkout/index.ts supabase/functions/stripe-pro-webhook/index.ts
```

## 4. Professional Portal

Generate `professional_portal/config.js` during deployment:

```js
window.MT_SUPABASE_CONFIG = {
  url: "https://<project-ref>.supabase.co",
  anonKey: "<anon-key>"
};
```

Host `professional_portal` as a static site over HTTPS.

## 5. Mobile Verification

Install an internal Android/iOS build and verify:

- `macrotracker://invite/<CODE>` opens the professional plan screen.
- Manual code entry previews the invite.
- Accepting an invite creates a connected relationship.
- Revoking access sets `professional_clients.status = revoked`.
- Home targets use the active professional plan.
- Diary shows day-level plan comparison.
- Snapshots include aggregate totals only.
- Offline startup still shows the cached active plan.

## 6. Release Decision

Release only after:

- RLS isolation is verified with at least two professionals and two clients.
- Stripe checkout and webhook state changes have been tested in test mode.
- Legal text is reviewed for every launch market.
- App Store/Play Store privacy answers are updated for optional professional
  sharing and Stripe professional billing.
