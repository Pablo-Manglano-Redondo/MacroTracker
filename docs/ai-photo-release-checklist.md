# AI Photo Meal Release Checklist

Use this checklist before promoting the photo AI flow from internal beta to production.

## Test Matrix

Run at least 30 real photos across these groups:

- Simple plate: 1-3 clear foods, good lighting.
- Complex plate: mixed dish, sauce, toppings, multiple macro components.
- Restaurant plate: larger portions, hidden oil/sauce likely.
- Packaged or branded food: visible packaging or label.
- Low-quality photo: dim, angled, partially occluded, noisy.
- Non-meal or invalid photo: should fail gracefully or produce a manual fallback path.

Record for each photo:

- Result usable: yes/no.
- Total latency.
- Remote latency.
- Edge/Gemini latency.
- Model attempts.
- Fallback used.
- User correction needed: none/minor/major.

## Go/No-Go Criteria

- Normal photos: at least 95% produce a usable editable draft.
- Complex photos: at least 85% produce a usable editable draft.
- Accepted zero-kcal placeholder output: 0 cases.
- Timeout on normal network: below 5%.
- Normal photo latency: ideally under 12 seconds.
- Complex photo latency: acceptable under 35 seconds when the result is useful.
- No visible debug diagnostics in release builds.
- Sentry does not receive expected timeout/unusable-response cases as production errors.

## Release Notes

- The photo flow is an editable estimate, not an authoritative nutrition label.
- Complex dishes should be grouped into macro-relevant components when exact ingredients are uncertain.
- Manual review remains mandatory before saving.
