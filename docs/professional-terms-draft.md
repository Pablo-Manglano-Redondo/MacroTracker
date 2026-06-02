# MacroTracker Professional Terms Draft

Last updated: 2026-06-01

This draft is implementation guidance and must be reviewed before public
release.

## Scope

MacroTracker Pro is an invite-only professional portal for general fitness,
wellness, and habit-coaching workflows. It is not designed for diagnosis,
treatment, clinical nutrition, or medical decision-making.

## Professional Responsibilities

Professionals are responsible for:

- Inviting only clients who have agreed to use MacroTracker with them.
- Staying within their legal scope of practice and local professional rules.
- Using plans as coaching guidance rather than medical prescriptions.
- Explaining any plan changes to their clients outside the app when needed.
- Keeping their portal account, email, and billing access secure.

## Client Consent

Clients must explicitly accept an invite in the mobile app before any data is
shared. The consent screen states that v1 shares aggregate snapshots only:

- calories consumed and target
- macro totals and targets
- meals logged count
- adherence summary
- sync timestamp

MacroTracker v1 does not share full diary entries, food names, recipes, photos,
or raw activity details with professionals.

## Billing

Professional subscriptions are billed outside the mobile app through Stripe in
the professional portal. Client-facing Premium features in the mobile app remain
separate and continue to use the existing mobile subscription integration.

If a professional subscription becomes inactive, new invites and new plan writes
are blocked. Existing connected clients may continue to view plans already
received in the app to avoid abrupt disruption.

## Data Access

Professionals can access only clients connected to their own professional
profile. Row-level security in Supabase is the enforcement boundary for
professional-client data access.

Clients can revoke access in the mobile app. Revocation stops future aggregate
snapshot sync and marks the relationship as revoked.

## Required Review Before Release

- Privacy policy review.
- App Store and Play Store policy review.
- Local legal review for the words "nutritionist", "dietitian", "coach", or
  equivalent regulated terms in each target market.
- Data processing agreement and support process for deletion/export requests.
