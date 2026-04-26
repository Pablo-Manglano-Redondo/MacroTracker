<p align="center">
  <img alt="MacroTracker logo" src="assets/icon/ont_logo_square.png" width="128" />
  <h1 align="center">MacroTracker</h1>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-GPLv3-blue" alt="GPLv3 license" />
</p>

## Description

MacroTracker is an open-source mobile application for tracking calories, macros, meals, recipes, activity, and weekly nutrition trends. It is built with Flutter and stores user data locally, with optional Supabase Edge Functions for AI-assisted meal interpretation.

## Screenshots

<p align="center">
  <img alt="MacroTracker screenshot 1" src="fastlane/metadata/android/en-US/images/phoneScreenshots/1_en-US.png" width="20%" />
  &nbsp;&nbsp;
  <img alt="MacroTracker screenshot 2" src="fastlane/metadata/android/en-US/images/phoneScreenshots/2_en-US.png" width="20%" />
  &nbsp;&nbsp;
  <img alt="MacroTracker screenshot 3" src="fastlane/metadata/android/en-US/images/phoneScreenshots/3_en-US.png" width="20%" />
  &nbsp;&nbsp;
  <img alt="MacroTracker screenshot 4" src="fastlane/metadata/android/en-US/images/phoneScreenshots/4_en-US.png" width="20%" />
</p>

## Key Features

- Nutritional tracking for meals, snacks, calories, and macros
- Food diary with daily intake history
- Custom meals and recipe library
- Barcode scanner backed by food product data sources
- Activity tracking and calorie burn estimates
- Weekly insights and macro suggestions
- AI meal interpretation from text or photos through Supabase Edge Functions
- Local-first storage with optional anonymous crash reporting

## Privacy

MacroTracker stores app data locally on the device. AI meal interpretation sends text or image input to Supabase Edge Functions only for inference, and the current function contract is designed for non-persistent processing.

See [Data Protection](https://www.iubenda.com/privacy-policy/53501884).

## Getting Started

See [GettingStarted.md](GettingStarted.md).

## AI Meal Interpretation

MacroTracker includes app-side integration for two Supabase Edge Functions:

- `meal-interpretations-text`
- `meal-interpretations-photo`

These functions live under `supabase/functions` and call the Gemini Developer API to return a structured meal draft that remains editable in the app before saving.

Required function secrets:

- `GEMINI_API_KEY`

Optional function secrets:

- `GEMINI_MEAL_TEXT_MODEL`
- `GEMINI_MEAL_PHOTO_MODEL`

Typical deploy flow:

```bash
supabase functions deploy meal-interpretations-text
supabase functions deploy meal-interpretations-photo
supabase secrets set GEMINI_API_KEY=...
```

Privacy notes:

- images are sent to the edge function only for inference
- the function contract is designed for `stored: false`
- the app never auto-saves inferred meals; every result goes through review/edit first

## Disclaimer

MacroTracker is not a medical application. All data provided is not validated and should be used with caution. Please maintain a healthy lifestyle and consult a professional if you have any problems. Use during illness, pregnancy, or lactation is not recommended.

The application is still under construction. Errors, bugs, and crashes might occur.

## License

This project is licensed under the GNU General Public License v3.0 License. See [LICENSE](LICENSE).
