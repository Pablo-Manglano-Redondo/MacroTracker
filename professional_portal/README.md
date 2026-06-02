# MacroTracker Professional Portal MVP

Static invite-only portal for the B2B professional flow. It uses Supabase Auth
and the tables in `supabase/migrations/20260601_b2b_professional_plans.sql`.

Open `index.html` locally or host the folder as a static site. Copy
`config.example.js` to `config.js` and set the Supabase URL and anon key from
the deployment environment, then sign in with magic link.

V1 scope:

- Professional profile and Pro status visibility.
- Stripe Checkout for Pro plans through the `stripe-pro-checkout` function.
- Create invite codes for clients.
- List connected clients.
- Create an active weekly macro plan.
- View aggregate snapshots shared by connected clients.

The portal reads `professionals.pro_status`; Stripe webhooks update that field.
