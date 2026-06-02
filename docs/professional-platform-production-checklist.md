# Professional Platform Production Checklist

This checklist covers the B2B invite-only professional platform before release.

## Supabase

- Apply `supabase/migrations/20260601_b2b_professional_plans.sql`.
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

## Stripe Pro

- Create Stripe products and prices for Starter, Growth, and Studio.
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

## Mobile QA

- Verify `macrotracker://invite/CODE` on Android and iOS.
- Verify manual invite code entry.
- Accept valid invite, reject expired invite, reject revoked invite.
- Confirm the consent screen states that only aggregate snapshots are shared.
- Confirm Home targets switch to the professional plan when active.
- Confirm Diary shows plan vs actual for days covered by the plan.
- Confirm revoking access updates `professional_clients.status = revoked` and
  stops snapshot upload.
- Test offline startup with a cached plan.

## Portal

- Deploy `professional_portal` as a static internal site.
- Generate `professional_portal/config.js` during deployment from environment
  variables. Do not commit `config.js`.
- Configure Supabase Auth redirect URLs for the portal origin.
- Replace manual Pro status management with Stripe checkout and webhook flow
  before selling to real professionals.

## Legal

- Update privacy policy for professional-client sharing.
- Add explicit terms that v1 is general fitness and wellness coaching, not
  clinical nutrition.
- Add professional terms covering client consent, data handling, and acceptable
  use.
