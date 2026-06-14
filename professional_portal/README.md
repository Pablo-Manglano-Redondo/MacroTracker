# MacroTracker Professional Portal

Invite-only React/Vite portal for the B2B professional flow. It uses Supabase
Auth plus the professional tables and functions under `supabase/`.

For local development, install dependencies and run the Vite app:

```bash
npm ci
npm run dev
```

Before shipping portal changes, run:

```bash
npm run verify
```

`npm run verify` checks source files for trailing whitespace, runs
TypeScript typechecking, and produces a production build.

The deployed static site still needs `config.js` generated from environment
values. Copy `config.example.js` to `config.js` for local static hosting or
generate it during deployment. `config.js` remains deploy-time config and
should not be committed.

Supported runtime:

- React + Vite only
- `professional_portal/app.js` legacy runtime removed
- Static hosting over HTTPS

Current scope:

- Professional profile plus explicit access status, commercial tier and billing interval
- Stripe Checkout for Pro plans through `stripe-pro-checkout`
- Invite generation and invite history for connected mobile flows
- Real connected-client roster from `professional_clients`
- Plans, notes, progress, check-ins and snapshots using live Supabase data
- Detailed diary only when the relationship is active and `sharing_mode = detailed`

Billing truth source:

- `professionals.pro_status` = access state
- `professionals.commercial_tier` = starter/growth/studio
- `professionals.billing_interval` = monthly/annual

Stripe webhooks update those fields together with `client_limit`.
