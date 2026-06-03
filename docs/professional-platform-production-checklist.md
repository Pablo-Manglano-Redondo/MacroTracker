# Professional Platform Production Checklist

This checklist covers the B2B invite-only professional platform before release.

## Supabase

- Apply `supabase/migrations/20260601_b2b_professional_plans.sql`.
- Run `deno test supabase/functions/_shared`.
- Run `deno check supabase/functions/stripe-pro-checkout/index.ts supabase/functions/stripe-pro-webhook/index.ts`.
- Enable anonymous sign-ins in Supabase Auth. MacroTracker uses a persistent
  anonymous Supabase user as the cloud identity for invite acceptance and RLS.
- Verify RPC grants:
  - `preview_client_invite(text)` callable by `anon` and `authenticated`.
  - `accept_client_invite(text)` callable by `authenticated`.
- Test RLS with four accounts:
  - professional A with Pro active
  - professional B with Pro active
  - connected client
  - unrelated authenticated client
- Confirm professional A cannot read professional B clients, plans, invites, or
  snapshots.
- Confirm connected clients can read only their own active plan and write only
  aggregate snapshots for their own relationship.
- Confirm snapshots contain aggregate calories, macros, targets, meal count and
  sync timestamps only. Raw diary entries, meal names, photos, recipes and full
  activity records must not appear in professional portal responses.

## Firebase Analytics

- Add the real Firebase Android config at `android/app/google-services.json`.
  The Google Services Gradle plugin is applied only when this file exists.
- Add the real Firebase iOS config at `ios/Runner/GoogleService-Info.plist`
  and include it in the Runner target in Xcode.
- Verify analytics collection is disabled until the user opts in to anonymous
  data collection during onboarding or Settings.
- Verify disabling the anonymous-data toggle calls Firebase collection disable
  and stops product conversion events.

## Stripe Pro

- Create Stripe products and prices for Starter, Growth, and Studio.
- Use Stripe test mode for the private-release rehearsal before live mode.
- Implement webhook handling with the Supabase service role key only on the
  server side. The repo includes `supabase/functions/stripe-pro-webhook`.
- Use `supabase/functions/stripe-pro-checkout` to create professional checkout
  sessions from the authenticated portal.
- On subscription updates, write:
  - `professionals.pro_status`
  - `professionals.stripe_customer_id`
  - `professionals.stripe_subscription_id`
  - `professionals.client_limit`
- Keep existing active client plans readable if Pro becomes inactive.
- Block new invites and new plans when `pro_status` is not `trialing` or
  `active`.
- Test checkout for Starter, Growth, and Studio and confirm webhook updates
  `pro_status`, `stripe_customer_id`, `stripe_subscription_id`, and
  `client_limit` to 10, 50, and 500 clients respectively.

## Mobile QA

- Verify onboarding paywall, AI trial uses 1/2/3, AI limit blocking, Macro
  Coach locked/unlocked, and Weekly Insights free/Premium states.
- Verify `macrotracker://invite/CODE` on Android and iOS.
- Verify manual invite code entry.
- Accept valid invite, reject expired invite, reject revoked invite.
- Confirm the consent screen states that only aggregate snapshots are shared.
- Confirm Home targets switch to the professional plan when active.
- Confirm Diary shows plan vs actual for days covered by the plan.
- Confirm revoking access updates `professional_clients.status = revoked` and
  stops snapshot upload.
- Test offline startup with a cached plan.
- Confirm `professional_invite_previewed`, `professional_invite_accepted`, and
  `professional_connection_revoked` analytics events emit only with anonymous
  data opt-in enabled.

## Portal

- Deploy `professional_portal` as a static internal site.
- Serve the portal over HTTPS before Stripe checkout testing.
- Generate `professional_portal/config.js` during deployment from environment
  variables. Do not commit `config.js`.
- Configure Supabase Auth redirect URLs for the portal origin.
- Confirm inactive professionals see the Stripe CTA and cannot create invites or
  publish plans until `pro_status` is `trialing` or `active`.

## Legal

- Update privacy policy for professional-client sharing.
- Add explicit terms that v1 is general fitness and wellness coaching, not
  clinical nutrition.
- Add professional terms covering client consent, data handling, and acceptable
  use.
- Confirm App Store and Play Store privacy answers mention optional analytics,
  optional professional sharing, and professional Stripe billing separately from
  mobile RevenueCat billing.
