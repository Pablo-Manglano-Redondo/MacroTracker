// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `MacroTracker`
  String get appTitle {
    return Intl.message(
      'MacroTracker',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Version {versionNumber}`
  String appVersionName(Object versionNumber) {
    return Intl.message(
      'Version $versionNumber',
      name: 'appVersionName',
      desc: '',
      args: [versionNumber],
    );
  }

  /// `MacroTracker by EPSAIT is a professional calorie and nutrient tracker with local-first privacy.`
  String get appDescription {
    return Intl.message(
      'MacroTracker by EPSAIT is a professional calorie and nutrient tracker with local-first privacy.',
      name: 'appDescription',
      desc: '',
      args: [],
    );
  }

  /// `[Alpha]`
  String get alphaVersionName {
    return Intl.message(
      '[Alpha]',
      name: 'alphaVersionName',
      desc: '',
      args: [],
    );
  }

  /// `[Beta]`
  String get betaVersionName {
    return Intl.message(
      '[Beta]',
      name: 'betaVersionName',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get addLabel {
    return Intl.message(
      'Add',
      name: 'addLabel',
      desc: '',
      args: [],
    );
  }

  /// `Create custom meal item?`
  String get createCustomDialogTitle {
    return Intl.message(
      'Create custom meal item?',
      name: 'createCustomDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do you want create a custom meal item?`
  String get createCustomDialogContent {
    return Intl.message(
      'Do you want create a custom meal item?',
      name: 'createCustomDialogContent',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsLabel {
    return Intl.message(
      'Settings',
      name: 'settingsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get homeLabel {
    return Intl.message(
      'Home',
      name: 'homeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Diary`
  String get diaryLabel {
    return Intl.message(
      'Diary',
      name: 'diaryLabel',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profileLabel {
    return Intl.message(
      'Profile',
      name: 'profileLabel',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get searchLabel {
    return Intl.message(
      'Search',
      name: 'searchLabel',
      desc: '',
      args: [],
    );
  }

  /// `Quick shortcuts`
  String get addMealQuickActionsTitle {
    return Intl.message(
      'Quick shortcuts',
      name: 'addMealQuickActionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Start with barcode, photo, text, or saved meals. If you search, use Food or Recent history.`
  String get addMealQuickActionsSubtitle {
    return Intl.message(
      'Start with barcode, photo, text, or saved meals. If you search, use Food or Recent history.',
      name: 'addMealQuickActionsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Food`
  String get addMealTabPackaged {
    return Intl.message(
      'Food',
      name: 'addMealTabPackaged',
      desc: '',
      args: [],
    );
  }

  /// `Generic foods`
  String get addMealTabGeneric {
    return Intl.message(
      'Generic foods',
      name: 'addMealTabGeneric',
      desc: '',
      args: [],
    );
  }

  /// `Recent history`
  String get addMealTabRecent {
    return Intl.message(
      'Recent history',
      name: 'addMealTabRecent',
      desc: '',
      args: [],
    );
  }

  /// `Use this for any food search, including branded items.`
  String get addMealTabPackagedHelper {
    return Intl.message(
      'Use this for any food search, including branded items.',
      name: 'addMealTabPackagedHelper',
      desc: '',
      args: [],
    );
  }

  /// `Use this for simple foods like rice, chicken, fruit, or oats.`
  String get addMealTabGenericHelper {
    return Intl.message(
      'Use this for simple foods like rice, chicken, fruit, or oats.',
      name: 'addMealTabGenericHelper',
      desc: '',
      args: [],
    );
  }

  /// `Reuse something you logged recently.`
  String get addMealTabRecentHelper {
    return Intl.message(
      'Reuse something you logged recently.',
      name: 'addMealTabRecentHelper',
      desc: '',
      args: [],
    );
  }

  /// `Food results`
  String get addMealSectionPackagedResults {
    return Intl.message(
      'Food results',
      name: 'addMealSectionPackagedResults',
      desc: '',
      args: [],
    );
  }

  /// `Generic food results`
  String get addMealSectionGenericResults {
    return Intl.message(
      'Generic food results',
      name: 'addMealSectionGenericResults',
      desc: '',
      args: [],
    );
  }

  /// `Recent meals`
  String get addMealSectionRecentResults {
    return Intl.message(
      'Recent meals',
      name: 'addMealSectionRecentResults',
      desc: '',
      args: [],
    );
  }

  /// `No recent meals yet.\nLog a meal once and it will appear here.`
  String get addMealRecentEmpty {
    return Intl.message(
      'No recent meals yet.\nLog a meal once and it will appear here.',
      name: 'addMealRecentEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Offline. Showing cached results.`
  String get addMealOfflineCachedResults {
    return Intl.message(
      'Offline. Showing cached results.',
      name: 'addMealOfflineCachedResults',
      desc: '',
      args: [],
    );
  }

  /// `Offline. No cached results found.`
  String get addMealOfflineNoCachedResults {
    return Intl.message(
      'Offline. No cached results found.',
      name: 'addMealOfflineNoCachedResults',
      desc: '',
      args: [],
    );
  }

  /// `Add meal`
  String get mealEntryTitle {
    return Intl.message(
      'Add meal',
      name: 'mealEntryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose how to log it. The meal will be saved to {mealType}.`
  String mealEntrySubtitle(Object mealType) {
    return Intl.message(
      'Choose how to log it. The meal will be saved to $mealType.',
      name: 'mealEntrySubtitle',
      desc: '',
      args: [mealType],
    );
  }

  /// `Search food`
  String get mealEntrySearchFood {
    return Intl.message(
      'Search food',
      name: 'mealEntrySearchFood',
      desc: '',
      args: [],
    );
  }

  /// `Database and recent meals`
  String get mealEntrySearchFoodSubtitle {
    return Intl.message(
      'Database and recent meals',
      name: 'mealEntrySearchFoodSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Scan barcode`
  String get mealEntryScanBarcode {
    return Intl.message(
      'Scan barcode',
      name: 'mealEntryScanBarcode',
      desc: '',
      args: [],
    );
  }

  /// `Packaged food`
  String get mealEntryScanBarcodeSubtitle {
    return Intl.message(
      'Packaged food',
      name: 'mealEntryScanBarcodeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `AI text`
  String get mealEntryAiText {
    return Intl.message(
      'AI text',
      name: 'mealEntryAiText',
      desc: '',
      args: [],
    );
  }

  /// `AI photo`
  String get mealEntryAiPhoto {
    return Intl.message(
      'AI photo',
      name: 'mealEntryAiPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Review amounts before saving`
  String get mealEntryReviewBeforeSaving {
    return Intl.message(
      'Review amounts before saving',
      name: 'mealEntryReviewBeforeSaving',
      desc: '',
      args: [],
    );
  }

  /// `Recipes and frequent`
  String get mealEntryRecipesAndFrequent {
    return Intl.message(
      'Recipes and frequent',
      name: 'mealEntryRecipesAndFrequent',
      desc: '',
      args: [],
    );
  }

  /// `Saved meals and presets`
  String get mealEntryRecipesAndFrequentSubtitle {
    return Intl.message(
      'Saved meals and presets',
      name: 'mealEntryRecipesAndFrequentSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Workout or extra burn`
  String get mealEntryActivitySubtitle {
    return Intl.message(
      'Workout or extra burn',
      name: 'mealEntryActivitySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Search any food or use barcode.`
  String get addMealSearchPromptPackaged {
    return Intl.message(
      'Search any food or use barcode.',
      name: 'addMealSearchPromptPackaged',
      desc: '',
      args: [],
    );
  }

  /// `Search a generic food like rice, eggs, or yogurt.`
  String get addMealSearchPromptGeneric {
    return Intl.message(
      'Search a generic food like rice, eggs, or yogurt.',
      name: 'addMealSearchPromptGeneric',
      desc: '',
      args: [],
    );
  }

  /// `Search your recent history or open saved meals.`
  String get addMealSearchPromptRecent {
    return Intl.message(
      'Search your recent history or open saved meals.',
      name: 'addMealSearchPromptRecent',
      desc: '',
      args: [],
    );
  }

  /// `Products`
  String get searchProductsPage {
    return Intl.message(
      'Products',
      name: 'searchProductsPage',
      desc: '',
      args: [],
    );
  }

  /// `Food`
  String get searchFoodPage {
    return Intl.message(
      'Food',
      name: 'searchFoodPage',
      desc: '',
      args: [],
    );
  }

  /// `Search results`
  String get searchResultsLabel {
    return Intl.message(
      'Search results',
      name: 'searchResultsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a search word`
  String get searchDefaultLabel {
    return Intl.message(
      'Please enter a search word',
      name: 'searchDefaultLabel',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get allItemsLabel {
    return Intl.message(
      'All',
      name: 'allItemsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Recently`
  String get recentlyAddedLabel {
    return Intl.message(
      'Recently',
      name: 'recentlyAddedLabel',
      desc: '',
      args: [],
    );
  }

  /// `No meals recently added`
  String get noMealsRecentlyAddedLabel {
    return Intl.message(
      'No meals recently added',
      name: 'noMealsRecentlyAddedLabel',
      desc: '',
      args: [],
    );
  }

  /// `No activity recently added`
  String get noActivityRecentlyAddedLabel {
    return Intl.message(
      'No activity recently added',
      name: 'noActivityRecentlyAddedLabel',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get dialogOKLabel {
    return Intl.message(
      'OK',
      name: 'dialogOKLabel',
      desc: '',
      args: [],
    );
  }

  /// `CANCEL`
  String get dialogCancelLabel {
    return Intl.message(
      'CANCEL',
      name: 'dialogCancelLabel',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get dialogYesLabel {
    return Intl.message(
      'Yes',
      name: 'dialogYesLabel',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get dialogNoLabel {
    return Intl.message(
      'No',
      name: 'dialogNoLabel',
      desc: '',
      args: [],
    );
  }

  /// `START`
  String get buttonStartLabel {
    return Intl.message(
      'START',
      name: 'buttonStartLabel',
      desc: '',
      args: [],
    );
  }

  /// `NEXT`
  String get buttonNextLabel {
    return Intl.message(
      'NEXT',
      name: 'buttonNextLabel',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get buttonSaveLabel {
    return Intl.message(
      'Save',
      name: 'buttonSaveLabel',
      desc: '',
      args: [],
    );
  }

  /// `YES`
  String get buttonYesLabel {
    return Intl.message(
      'YES',
      name: 'buttonYesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get buttonResetLabel {
    return Intl.message(
      'Reset',
      name: 'buttonResetLabel',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to`
  String get onboardingWelcomeLabel {
    return Intl.message(
      'Welcome to',
      name: 'onboardingWelcomeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Overview`
  String get onboardingOverviewLabel {
    return Intl.message(
      'Overview',
      name: 'onboardingOverviewLabel',
      desc: '',
      args: [],
    );
  }

  /// `Your calorie goal:`
  String get onboardingYourGoalLabel {
    return Intl.message(
      'Your calorie goal:',
      name: 'onboardingYourGoalLabel',
      desc: '',
      args: [],
    );
  }

  /// `Your macronutrient goals:`
  String get onboardingYourMacrosGoalLabel {
    return Intl.message(
      'Your macronutrient goals:',
      name: 'onboardingYourMacrosGoalLabel',
      desc: '',
      args: [],
    );
  }

  /// `kcal per day`
  String get onboardingKcalPerDayLabel {
    return Intl.message(
      'kcal per day',
      name: 'onboardingKcalPerDayLabel',
      desc: '',
      args: [],
    );
  }

  /// `To start, the app needs some information about you to calculate your daily calorie goal.\nAll information about you is stored securely on your device.`
  String get onboardingIntroDescription {
    return Intl.message(
      'To start, the app needs some information about you to calculate your daily calorie goal.\nAll information about you is stored securely on your device.',
      name: 'onboardingIntroDescription',
      desc: '',
      args: [],
    );
  }

  /// `What's your gender?`
  String get onboardingGenderQuestionSubtitle {
    return Intl.message(
      'What\'s your gender?',
      name: 'onboardingGenderQuestionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Birthday`
  String get onboardingEnterBirthdayLabel {
    return Intl.message(
      'Birthday',
      name: 'onboardingEnterBirthdayLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter Date`
  String get onboardingBirthdayHint {
    return Intl.message(
      'Enter Date',
      name: 'onboardingBirthdayHint',
      desc: '',
      args: [],
    );
  }

  /// `When is your birthday?`
  String get onboardingBirthdayQuestionSubtitle {
    return Intl.message(
      'When is your birthday?',
      name: 'onboardingBirthdayQuestionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Whats your current height?`
  String get onboardingHeightQuestionSubtitle {
    return Intl.message(
      'Whats your current height?',
      name: 'onboardingHeightQuestionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Whats your current weight?`
  String get onboardingWeightQuestionSubtitle {
    return Intl.message(
      'Whats your current weight?',
      name: 'onboardingWeightQuestionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter correct height`
  String get onboardingWrongHeightLabel {
    return Intl.message(
      'Enter correct height',
      name: 'onboardingWrongHeightLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter correct weight`
  String get onboardingWrongWeightLabel {
    return Intl.message(
      'Enter correct weight',
      name: 'onboardingWrongWeightLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 60`
  String get onboardingWeightExampleHintKg {
    return Intl.message(
      'e.g. 60',
      name: 'onboardingWeightExampleHintKg',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 132`
  String get onboardingWeightExampleHintLbs {
    return Intl.message(
      'e.g. 132',
      name: 'onboardingWeightExampleHintLbs',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 170`
  String get onboardingHeightExampleHintCm {
    return Intl.message(
      'e.g. 170',
      name: 'onboardingHeightExampleHintCm',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 5.8`
  String get onboardingHeightExampleHintFt {
    return Intl.message(
      'e.g. 5.8',
      name: 'onboardingHeightExampleHintFt',
      desc: '',
      args: [],
    );
  }

  /// `How active are you? (without workouts)`
  String get onboardingActivityQuestionSubtitle {
    return Intl.message(
      'How active are you? (without workouts)',
      name: 'onboardingActivityQuestionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `What's your current weight goal?`
  String get onboardingGoalQuestionSubtitle {
    return Intl.message(
      'What\'s your current weight goal?',
      name: 'onboardingGoalQuestionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Wrong input, please try again`
  String get onboardingSaveUserError {
    return Intl.message(
      'Wrong input, please try again',
      name: 'onboardingSaveUserError',
      desc: '',
      args: [],
    );
  }

  /// `Protect your cloud account`
  String get onboardingCloudProtectTitle {
    return Intl.message(
      'Protect your cloud account',
      name: 'onboardingCloudProtectTitle',
      desc: '',
      args: [],
    );
  }

  /// `MacroTracker is ready without sign-up. If you protect your account with Google, you can recover it on a new phone and use professional nutritionist connections. This does not enable Google Drive.`
  String get onboardingCloudProtectBody {
    return Intl.message(
      'MacroTracker is ready without sign-up. If you protect your account with Google, you can recover it on a new phone and use professional nutritionist connections. This does not enable Google Drive.',
      name: 'onboardingCloudProtectBody',
      desc: '',
      args: [],
    );
  }

  /// `Not now`
  String get onboardingNotNow {
    return Intl.message(
      'Not now',
      name: 'onboardingNotNow',
      desc: '',
      args: [],
    );
  }

  /// `Use Google`
  String get onboardingUseGoogle {
    return Intl.message(
      'Use Google',
      name: 'onboardingUseGoogle',
      desc: '',
      args: [],
    );
  }

  /// `You can adjust these targets later from Profile. Your data starts on this device; after this you can optionally protect a cloud account for recovery.`
  String get onboardingOverviewDataFootnote {
    return Intl.message(
      'You can adjust these targets later from Profile. Your data starts on this device; after this you can optionally protect a cloud account for recovery.',
      name: 'onboardingOverviewDataFootnote',
      desc: '',
      args: [],
    );
  }

  /// `Units`
  String get settingsUnitsLabel {
    return Intl.message(
      'Units',
      name: 'settingsUnitsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Calculations`
  String get settingsCalculationsLabel {
    return Intl.message(
      'Calculations',
      name: 'settingsCalculationsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get settingsThemeLabel {
    return Intl.message(
      'Theme',
      name: 'settingsThemeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get settingsThemeLightLabel {
    return Intl.message(
      'Light',
      name: 'settingsThemeLightLabel',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get settingsThemeDarkLabel {
    return Intl.message(
      'Dark',
      name: 'settingsThemeDarkLabel',
      desc: '',
      args: [],
    );
  }

  /// `System default`
  String get settingsThemeSystemDefaultLabel {
    return Intl.message(
      'System default',
      name: 'settingsThemeSystemDefaultLabel',
      desc: '',
      args: [],
    );
  }

  /// `Licenses`
  String get settingsLicensesLabel {
    return Intl.message(
      'Licenses',
      name: 'settingsLicensesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Disclaimer`
  String get settingsDisclaimerLabel {
    return Intl.message(
      'Disclaimer',
      name: 'settingsDisclaimerLabel',
      desc: '',
      args: [],
    );
  }

  /// `Report Error`
  String get settingsReportErrorLabel {
    return Intl.message(
      'Report Error',
      name: 'settingsReportErrorLabel',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Settings`
  String get settingsPrivacySettings {
    return Intl.message(
      'Privacy Settings',
      name: 'settingsPrivacySettings',
      desc: '',
      args: [],
    );
  }

  /// `Source Code`
  String get settingsSourceCodeLabel {
    return Intl.message(
      'Source Code',
      name: 'settingsSourceCodeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get settingFeedbackLabel {
    return Intl.message(
      'Feedback',
      name: 'settingFeedbackLabel',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get settingAboutLabel {
    return Intl.message(
      'About',
      name: 'settingAboutLabel',
      desc: '',
      args: [],
    );
  }

  /// `Mass`
  String get settingsMassLabel {
    return Intl.message(
      'Mass',
      name: 'settingsMassLabel',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get settingsSystemLabel {
    return Intl.message(
      'System',
      name: 'settingsSystemLabel',
      desc: '',
      args: [],
    );
  }

  /// `Metric (kg, cm, ml)`
  String get settingsMetricLabel {
    return Intl.message(
      'Metric (kg, cm, ml)',
      name: 'settingsMetricLabel',
      desc: '',
      args: [],
    );
  }

  /// `Imperial (lbs, ft, oz)`
  String get settingsImperialLabel {
    return Intl.message(
      'Imperial (lbs, ft, oz)',
      name: 'settingsImperialLabel',
      desc: '',
      args: [],
    );
  }

  /// `Distance`
  String get settingsDistanceLabel {
    return Intl.message(
      'Distance',
      name: 'settingsDistanceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Volume`
  String get settingsVolumeLabel {
    return Intl.message(
      'Volume',
      name: 'settingsVolumeLabel',
      desc: '',
      args: [],
    );
  }

  /// `MacroTracker is not a medical application. All data provided is not validated and should be used with caution. Please maintain a healthy lifestyle and consult a professional if you have any problems. Use during illness, pregnancy or lactation is not recommended.`
  String get disclaimerText {
    return Intl.message(
      'MacroTracker is not a medical application. All data provided is not validated and should be used with caution. Please maintain a healthy lifestyle and consult a professional if you have any problems. Use during illness, pregnancy or lactation is not recommended.',
      name: 'disclaimerText',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to report an error to the developer?`
  String get reportErrorDialogText {
    return Intl.message(
      'Do you want to report an error to the developer?',
      name: 'reportErrorDialogText',
      desc: '',
      args: [],
    );
  }

  /// `Send anonymous crash and diagnostic reports`
  String get sendAnonymousUserData {
    return Intl.message(
      'Send anonymous crash and diagnostic reports',
      name: 'sendAnonymousUserData',
      desc: '',
      args: [],
    );
  }

  /// `GPL-3.0 license`
  String get appLicenseLabel {
    return Intl.message(
      'GPL-3.0 license',
      name: 'appLicenseLabel',
      desc: '',
      args: [],
    );
  }

  /// `TDEE equation`
  String get calculationsTDEELabel {
    return Intl.message(
      'TDEE equation',
      name: 'calculationsTDEELabel',
      desc: '',
      args: [],
    );
  }

  /// `Institute of Medicine Equation`
  String get calculationsTDEEIOM2006Label {
    return Intl.message(
      'Institute of Medicine Equation',
      name: 'calculationsTDEEIOM2006Label',
      desc: '',
      args: [],
    );
  }

  /// `(recommended)`
  String get calculationsRecommendedLabel {
    return Intl.message(
      '(recommended)',
      name: 'calculationsRecommendedLabel',
      desc: '',
      args: [],
    );
  }

  /// `Macros distribution`
  String get calculationsMacronutrientsDistributionLabel {
    return Intl.message(
      'Macros distribution',
      name: 'calculationsMacronutrientsDistributionLabel',
      desc: '',
      args: [],
    );
  }

  /// `{pctCarbs}% carbs, {pctFats}% fats, {pctProteins}% proteins`
  String calculationsMacrosDistribution(
      Object pctCarbs, Object pctFats, Object pctProteins) {
    return Intl.message(
      '$pctCarbs% carbs, $pctFats% fats, $pctProteins% proteins',
      name: 'calculationsMacrosDistribution',
      desc: '',
      args: [pctCarbs, pctFats, pctProteins],
    );
  }

  /// `Percentage`
  String get calculationsMacroModePercentage {
    return Intl.message(
      'Percentage',
      name: 'calculationsMacroModePercentage',
      desc: '',
      args: [],
    );
  }

  /// `Grams/kg`
  String get calculationsMacroModeGramsPerKg {
    return Intl.message(
      'Grams/kg',
      name: 'calculationsMacroModeGramsPerKg',
      desc: '',
      args: [],
    );
  }

  /// `your current weight`
  String get calculationsCurrentWeightFallback {
    return Intl.message(
      'your current weight',
      name: 'calculationsCurrentWeightFallback',
      desc: '',
      args: [],
    );
  }

  /// `Protein and fat will be calculated by multiplying each value by {weight}. Carbs will fill the remaining kcal from the automatic target.`
  String calculationsGramPerKgHint(Object weight) {
    return Intl.message(
      'Protein and fat will be calculated by multiplying each value by $weight. Carbs will fill the remaining kcal from the automatic target.',
      name: 'calculationsGramPerKgHint',
      desc: '',
      args: [weight],
    );
  }

  /// `Daily Kcal adjustment:`
  String get dailyKcalAdjustmentLabel {
    return Intl.message(
      'Daily Kcal adjustment:',
      name: 'dailyKcalAdjustmentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Macronutrient Distribution:`
  String get macroDistributionLabel {
    return Intl.message(
      'Macronutrient Distribution:',
      name: 'macroDistributionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Export / Import data`
  String get exportImportLabel {
    return Intl.message(
      'Export / Import data',
      name: 'exportImportLabel',
      desc: '',
      args: [],
    );
  }

  /// `Export ZIP creates a local manual copy that you can import later. MacroTracker is local-first; Cuenta cloud, Google Drive backup, AI, and coach connections are optional and separate.`
  String get exportImportDescription {
    return Intl.message(
      'Export ZIP creates a local manual copy that you can import later. MacroTracker is local-first; Cuenta cloud, Google Drive backup, AI, and coach connections are optional and separate.',
      name: 'exportImportDescription',
      desc: '',
      args: [],
    );
  }

  /// `Export / Import successful`
  String get exportImportSuccessLabel {
    return Intl.message(
      'Export / Import successful',
      name: 'exportImportSuccessLabel',
      desc: '',
      args: [],
    );
  }

  /// `Export / Import error`
  String get exportImportErrorLabel {
    return Intl.message(
      'Export / Import error',
      name: 'exportImportErrorLabel',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get exportAction {
    return Intl.message(
      'Export',
      name: 'exportAction',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get importAction {
    return Intl.message(
      'Import',
      name: 'importAction',
      desc: '',
      args: [],
    );
  }

  /// `Google Drive backup`
  String get driveBackupTitle {
    return Intl.message(
      'Google Drive backup',
      name: 'driveBackupTitle',
      desc: '',
      args: [],
    );
  }

  /// `Creates an encrypted ZIP of your data and stores it in your own Drive. This is separate from your MacroTracker cloud account.`
  String get driveBackupSubtitle {
    return Intl.message(
      'Creates an encrypted ZIP of your data and stores it in your own Drive. This is separate from your MacroTracker cloud account.',
      name: 'driveBackupSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Connect Drive`
  String get driveBackupConnect {
    return Intl.message(
      'Connect Drive',
      name: 'driveBackupConnect',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect`
  String get driveBackupDisconnect {
    return Intl.message(
      'Disconnect',
      name: 'driveBackupDisconnect',
      desc: '',
      args: [],
    );
  }

  /// `Back up now`
  String get driveBackupRunNow {
    return Intl.message(
      'Back up now',
      name: 'driveBackupRunNow',
      desc: '',
      args: [],
    );
  }

  /// `Google Drive connected. This does not change your cloud account.`
  String get driveBackupConnectedSnack {
    return Intl.message(
      'Google Drive connected. This does not change your cloud account.',
      name: 'driveBackupConnectedSnack',
      desc: '',
      args: [],
    );
  }

  /// `Google Drive disconnected.`
  String get driveBackupDisconnectedSnack {
    return Intl.message(
      'Google Drive disconnected.',
      name: 'driveBackupDisconnectedSnack',
      desc: '',
      args: [],
    );
  }

  /// `Backup uploaded to Google Drive: {fileName}.`
  String driveBackupUploadedSnack(Object fileName) {
    return Intl.message(
      'Backup uploaded to Google Drive: $fileName.',
      name: 'driveBackupUploadedSnack',
      desc: '',
      args: [fileName],
    );
  }

  /// `file`
  String get driveBackupDefaultFileName {
    return Intl.message(
      'file',
      name: 'driveBackupDefaultFileName',
      desc: '',
      args: [],
    );
  }

  /// `Daily backup enabled on Android.`
  String get driveBackupDailyEnabledSnack {
    return Intl.message(
      'Daily backup enabled on Android.',
      name: 'driveBackupDailyEnabledSnack',
      desc: '',
      args: [],
    );
  }

  /// `Daily backup disabled.`
  String get driveBackupDailyDisabledSnack {
    return Intl.message(
      'Daily backup disabled.',
      name: 'driveBackupDailyDisabledSnack',
      desc: '',
      args: [],
    );
  }

  /// `Drive account connected`
  String get driveBackupAccountConnected {
    return Intl.message(
      'Drive account connected',
      name: 'driveBackupAccountConnected',
      desc: '',
      args: [],
    );
  }

  /// `Not connected`
  String get driveBackupNotConnected {
    return Intl.message(
      'Not connected',
      name: 'driveBackupNotConnected',
      desc: '',
      args: [],
    );
  }

  /// `Ready`
  String get driveBackupReady {
    return Intl.message(
      'Ready',
      name: 'driveBackupReady',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get driveBackupPending {
    return Intl.message(
      'Pending',
      name: 'driveBackupPending',
      desc: '',
      args: [],
    );
  }

  /// `Google Drive OAuth is still missing for this platform. See docs/google-drive-backup-setup.md.`
  String get driveBackupOAuthMissing {
    return Intl.message(
      'Google Drive OAuth is still missing for this platform. See docs/google-drive-backup-setup.md.',
      name: 'driveBackupOAuthMissing',
      desc: '',
      args: [],
    );
  }

  /// `Backup status`
  String get driveBackupStatusTitle {
    return Intl.message(
      'Backup status',
      name: 'driveBackupStatusTitle',
      desc: '',
      args: [],
    );
  }

  /// `Last attempt failed`
  String get driveBackupLastAttemptFailed {
    return Intl.message(
      'Last attempt failed',
      name: 'driveBackupLastAttemptFailed',
      desc: '',
      args: [],
    );
  }

  /// `Last backup completed`
  String get driveBackupLastCompleted {
    return Intl.message(
      'Last backup completed',
      name: 'driveBackupLastCompleted',
      desc: '',
      args: [],
    );
  }

  /// `No backups yet`
  String get driveBackupNoneYet {
    return Intl.message(
      'No backups yet',
      name: 'driveBackupNoneYet',
      desc: '',
      args: [],
    );
  }

  /// `No timestamp`
  String get driveBackupNoTimestamp {
    return Intl.message(
      'No timestamp',
      name: 'driveBackupNoTimestamp',
      desc: '',
      args: [],
    );
  }

  /// `No backup has been uploaded yet.`
  String get driveBackupNoUploadYet {
    return Intl.message(
      'No backup has been uploaded yet.',
      name: 'driveBackupNoUploadYet',
      desc: '',
      args: [],
    );
  }

  /// `Daily automatic backup`
  String get driveBackupDailyTitle {
    return Intl.message(
      'Daily automatic backup',
      name: 'driveBackupDailyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Android will schedule one backup per day when the system allows background work to run.`
  String get driveBackupDailySignedInBody {
    return Intl.message(
      'Android will schedule one backup per day when the system allows background work to run.',
      name: 'driveBackupDailySignedInBody',
      desc: '',
      args: [],
    );
  }

  /// `Connect Google Drive first to enable daily backups.`
  String get driveBackupDailyConnectFirstBody {
    return Intl.message(
      'Connect Google Drive first to enable daily backups.',
      name: 'driveBackupDailyConnectFirstBody',
      desc: '',
      args: [],
    );
  }

  /// `The first run is scheduled for the next overnight window. Android may shift it by minutes or hours depending on battery, network, and power-saving rules.`
  String get driveBackupDailyScheduleNote {
    return Intl.message(
      'The first run is scheduled for the next overnight window. Android may shift it by minutes or hours depending on battery, network, and power-saving rules.',
      name: 'driveBackupDailyScheduleNote',
      desc: '',
      args: [],
    );
  }

  /// `Add new Item:`
  String get addItemLabel {
    return Intl.message(
      'Add new Item:',
      name: 'addItemLabel',
      desc: '',
      args: [],
    );
  }

  /// `Activity`
  String get activityLabel {
    return Intl.message(
      'Activity',
      name: 'activityLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. running, biking, yoga ...`
  String get activityExample {
    return Intl.message(
      'e.g. running, biking, yoga ...',
      name: 'activityExample',
      desc: '',
      args: [],
    );
  }

  /// `Breakfast`
  String get breakfastLabel {
    return Intl.message(
      'Breakfast',
      name: 'breakfastLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. cereal, milk, coffee ...`
  String get breakfastExample {
    return Intl.message(
      'e.g. cereal, milk, coffee ...',
      name: 'breakfastExample',
      desc: '',
      args: [],
    );
  }

  /// `Lunch`
  String get lunchLabel {
    return Intl.message(
      'Lunch',
      name: 'lunchLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. pizza, salad, rice ...`
  String get lunchExample {
    return Intl.message(
      'e.g. pizza, salad, rice ...',
      name: 'lunchExample',
      desc: '',
      args: [],
    );
  }

  /// `Dinner`
  String get dinnerLabel {
    return Intl.message(
      'Dinner',
      name: 'dinnerLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. soup, chicken, wine ...`
  String get dinnerExample {
    return Intl.message(
      'e.g. soup, chicken, wine ...',
      name: 'dinnerExample',
      desc: '',
      args: [],
    );
  }

  /// `Snack`
  String get snackLabel {
    return Intl.message(
      'Snack',
      name: 'snackLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. apple, ice cream, chocolate ...`
  String get snackExample {
    return Intl.message(
      'e.g. apple, ice cream, chocolate ...',
      name: 'snackExample',
      desc: '',
      args: [],
    );
  }

  /// `Edit item`
  String get editItemDialogTitle {
    return Intl.message(
      'Edit item',
      name: 'editItemDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Item updated`
  String get itemUpdatedSnackbar {
    return Intl.message(
      'Item updated',
      name: 'itemUpdatedSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `Delete Item?`
  String get deleteTimeDialogTitle {
    return Intl.message(
      'Delete Item?',
      name: 'deleteTimeDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do want to delete the selected item?`
  String get deleteTimeDialogContent {
    return Intl.message(
      'Do want to delete the selected item?',
      name: 'deleteTimeDialogContent',
      desc: '',
      args: [],
    );
  }

  /// `Delete Items?`
  String get deleteTimeDialogPluralTitle {
    return Intl.message(
      'Delete Items?',
      name: 'deleteTimeDialogPluralTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do want to delete all items of this meal?`
  String get deleteTimeDialogPluralContent {
    return Intl.message(
      'Do want to delete all items of this meal?',
      name: 'deleteTimeDialogPluralContent',
      desc: '',
      args: [],
    );
  }

  /// `Item deleted`
  String get itemDeletedSnackbar {
    return Intl.message(
      'Item deleted',
      name: 'itemDeletedSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `Which meal type do you want to copy to?`
  String get copyDialogTitle {
    return Intl.message(
      'Which meal type do you want to copy to?',
      name: 'copyDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `What do you want to do?`
  String get copyOrDeleteTimeDialogTitle {
    return Intl.message(
      'What do you want to do?',
      name: 'copyOrDeleteTimeDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `With "Copy to today" you can copy the meal to today. With "Delete" you can delete the meal.`
  String get copyOrDeleteTimeDialogContent {
    return Intl.message(
      'With "Copy to today" you can copy the meal to today. With "Delete" you can delete the meal.',
      name: 'copyOrDeleteTimeDialogContent',
      desc: '',
      args: [],
    );
  }

  /// `Copy to today`
  String get dialogCopyLabel {
    return Intl.message(
      'Copy to today',
      name: 'dialogCopyLabel',
      desc: '',
      args: [],
    );
  }

  /// `DELETE`
  String get dialogDeleteLabel {
    return Intl.message(
      'DELETE',
      name: 'dialogDeleteLabel',
      desc: '',
      args: [],
    );
  }

  /// `Delete all`
  String get deleteAllLabel {
    return Intl.message(
      'Delete all',
      name: 'deleteAllLabel',
      desc: '',
      args: [],
    );
  }

  /// `supplied`
  String get suppliedLabel {
    return Intl.message(
      'supplied',
      name: 'suppliedLabel',
      desc: '',
      args: [],
    );
  }

  /// `burned`
  String get burnedLabel {
    return Intl.message(
      'burned',
      name: 'burnedLabel',
      desc: '',
      args: [],
    );
  }

  /// `kcal left`
  String get kcalLeftLabel {
    return Intl.message(
      'kcal left',
      name: 'kcalLeftLabel',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition Information`
  String get nutritionInfoLabel {
    return Intl.message(
      'Nutrition Information',
      name: 'nutritionInfoLabel',
      desc: '',
      args: [],
    );
  }

  /// `kcal`
  String get kcalLabel {
    return Intl.message(
      'kcal',
      name: 'kcalLabel',
      desc: '',
      args: [],
    );
  }

  /// `carbs`
  String get carbsLabel {
    return Intl.message(
      'carbs',
      name: 'carbsLabel',
      desc: '',
      args: [],
    );
  }

  /// `fat`
  String get fatLabel {
    return Intl.message(
      'fat',
      name: 'fatLabel',
      desc: '',
      args: [],
    );
  }

  /// `protein`
  String get proteinLabel {
    return Intl.message(
      'protein',
      name: 'proteinLabel',
      desc: '',
      args: [],
    );
  }

  /// `energy`
  String get energyLabel {
    return Intl.message(
      'energy',
      name: 'energyLabel',
      desc: '',
      args: [],
    );
  }

  /// `saturated fat`
  String get saturatedFatLabel {
    return Intl.message(
      'saturated fat',
      name: 'saturatedFatLabel',
      desc: '',
      args: [],
    );
  }

  /// `carbohydrate`
  String get carbohydrateLabel {
    return Intl.message(
      'carbohydrate',
      name: 'carbohydrateLabel',
      desc: '',
      args: [],
    );
  }

  /// `sugar`
  String get sugarLabel {
    return Intl.message(
      'sugar',
      name: 'sugarLabel',
      desc: '',
      args: [],
    );
  }

  /// `fiber`
  String get fiberLabel {
    return Intl.message(
      'fiber',
      name: 'fiberLabel',
      desc: '',
      args: [],
    );
  }

  /// `Food quality`
  String get foodQualityTitle {
    return Intl.message(
      'Food quality',
      name: 'foodQualityTitle',
      desc: '',
      args: [],
    );
  }

  /// `Estimated nutrition score`
  String get foodQualitySubtitle {
    return Intl.message(
      'Estimated nutrition score',
      name: 'foodQualitySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Estimate based on partial data`
  String get foodQualityPartialSubtitle {
    return Intl.message(
      'Estimate based on partial data',
      name: 'foodQualityPartialSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Excellent`
  String get foodQualityBandExcellent {
    return Intl.message(
      'Excellent',
      name: 'foodQualityBandExcellent',
      desc: '',
      args: [],
    );
  }

  /// `Good`
  String get foodQualityBandGood {
    return Intl.message(
      'Good',
      name: 'foodQualityBandGood',
      desc: '',
      args: [],
    );
  }

  /// `Fair`
  String get foodQualityBandFair {
    return Intl.message(
      'Fair',
      name: 'foodQualityBandFair',
      desc: '',
      args: [],
    );
  }

  /// `Poor`
  String get foodQualityBandPoor {
    return Intl.message(
      'Poor',
      name: 'foodQualityBandPoor',
      desc: '',
      args: [],
    );
  }

  /// `High fiber`
  String get foodQualityReasonHighFiber {
    return Intl.message(
      'High fiber',
      name: 'foodQualityReasonHighFiber',
      desc: '',
      args: [],
    );
  }

  /// `Good protein`
  String get foodQualityReasonGoodProtein {
    return Intl.message(
      'Good protein',
      name: 'foodQualityReasonGoodProtein',
      desc: '',
      args: [],
    );
  }

  /// `Balanced profile`
  String get foodQualityReasonBalancedProfile {
    return Intl.message(
      'Balanced profile',
      name: 'foodQualityReasonBalancedProfile',
      desc: '',
      args: [],
    );
  }

  /// `Moderate sugar`
  String get foodQualityReasonLowSugar {
    return Intl.message(
      'Moderate sugar',
      name: 'foodQualityReasonLowSugar',
      desc: '',
      args: [],
    );
  }

  /// `High sugar`
  String get foodQualityReasonHighSugar {
    return Intl.message(
      'High sugar',
      name: 'foodQualityReasonHighSugar',
      desc: '',
      args: [],
    );
  }

  /// `Calorie dense`
  String get foodQualityReasonHighEnergyDensity {
    return Intl.message(
      'Calorie dense',
      name: 'foodQualityReasonHighEnergyDensity',
      desc: '',
      args: [],
    );
  }

  /// `Reasonable calorie density`
  String get foodQualityReasonLowEnergyDensity {
    return Intl.message(
      'Reasonable calorie density',
      name: 'foodQualityReasonLowEnergyDensity',
      desc: '',
      args: [],
    );
  }

  /// `High saturated fat`
  String get foodQualityReasonHighSaturatedFat {
    return Intl.message(
      'High saturated fat',
      name: 'foodQualityReasonHighSaturatedFat',
      desc: '',
      args: [],
    );
  }

  /// `Partial data`
  String get foodQualityReasonPartialData {
    return Intl.message(
      'Partial data',
      name: 'foodQualityReasonPartialData',
      desc: '',
      args: [],
    );
  }

  /// `Per 100g/ml`
  String get per100gmlLabel {
    return Intl.message(
      'Per 100g/ml',
      name: 'per100gmlLabel',
      desc: '',
      args: [],
    );
  }

  /// `More Information at\nOpenFoodFacts`
  String get additionalInfoLabelOFF {
    return Intl.message(
      'More Information at\nOpenFoodFacts',
      name: 'additionalInfoLabelOFF',
      desc: '',
      args: [],
    );
  }

  /// `The data provided to you by this app are retrieved from the Open Food Facts database. No guarantees can be made for the accuracy, completeness, or reliability of the information provided. The data are provided “as is” and the originating source for the data (Open Food Facts) is not liable for any damages arising out of the use of the data.`
  String get offDisclaimer {
    return Intl.message(
      'The data provided to you by this app are retrieved from the Open Food Facts database. No guarantees can be made for the accuracy, completeness, or reliability of the information provided. The data are provided “as is” and the originating source for the data (Open Food Facts) is not liable for any damages arising out of the use of the data.',
      name: 'offDisclaimer',
      desc: '',
      args: [],
    );
  }

  /// `More Information at\nFoodData Central`
  String get additionalInfoLabelFDC {
    return Intl.message(
      'More Information at\nFoodData Central',
      name: 'additionalInfoLabelFDC',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Meal Item`
  String get additionalInfoLabelUnknown {
    return Intl.message(
      'Unknown Meal Item',
      name: 'additionalInfoLabelUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Custom Meal Item`
  String get additionalInfoLabelCustom {
    return Intl.message(
      'Custom Meal Item',
      name: 'additionalInfoLabelCustom',
      desc: '',
      args: [],
    );
  }

  /// `Information provided\n by the \n'2011 Compendium\n of Physical Activities'`
  String get additionalInfoLabelCompendium2011 {
    return Intl.message(
      'Information provided\n by the \n\'2011 Compendium\n of Physical Activities\'',
      name: 'additionalInfoLabelCompendium2011',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantityLabel {
    return Intl.message(
      'Quantity',
      name: 'quantityLabel',
      desc: '',
      args: [],
    );
  }

  /// `Base quantity (g/ml)`
  String get baseQuantityLabel {
    return Intl.message(
      'Base quantity (g/ml)',
      name: 'baseQuantityLabel',
      desc: '',
      args: [],
    );
  }

  /// `Unit`
  String get unitLabel {
    return Intl.message(
      'Unit',
      name: 'unitLabel',
      desc: '',
      args: [],
    );
  }

  /// `Scan Product`
  String get scanProductLabel {
    return Intl.message(
      'Scan Product',
      name: 'scanProductLabel',
      desc: '',
      args: [],
    );
  }

  /// `Not found`
  String get scannerNotFoundTitle {
    return Intl.message(
      'Not found',
      name: 'scannerNotFoundTitle',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get scannerErrorTitle {
    return Intl.message(
      'Error',
      name: 'scannerErrorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Barcode: {barcode}`
  String scannerBarcodeValue(Object barcode) {
    return Intl.message(
      'Barcode: $barcode',
      name: 'scannerBarcodeValue',
      desc: '',
      args: [barcode],
    );
  }

  /// `Create food manually`
  String get scannerCreateFoodManually {
    return Intl.message(
      'Create food manually',
      name: 'scannerCreateFoodManually',
      desc: '',
      args: [],
    );
  }

  /// `Retry scanning`
  String get scannerRetryScanning {
    return Intl.message(
      'Retry scanning',
      name: 'scannerRetryScanning',
      desc: '',
      args: [],
    );
  }

  /// `Enter code`
  String get scannerEnterCodeTooltip {
    return Intl.message(
      'Enter code',
      name: 'scannerEnterCodeTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Enter barcode`
  String get scannerManualBarcodeTitle {
    return Intl.message(
      'Enter barcode',
      name: 'scannerManualBarcodeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Barcode number`
  String get scannerBarcodeNumberLabel {
    return Intl.message(
      'Barcode number',
      name: 'scannerBarcodeNumberLabel',
      desc: '',
      args: [],
    );
  }

  /// `g`
  String get gramUnit {
    return Intl.message(
      'g',
      name: 'gramUnit',
      desc: '',
      args: [],
    );
  }

  /// `ml`
  String get milliliterUnit {
    return Intl.message(
      'ml',
      name: 'milliliterUnit',
      desc: '',
      args: [],
    );
  }

  /// `g/ml`
  String get gramMilliliterUnit {
    return Intl.message(
      'g/ml',
      name: 'gramMilliliterUnit',
      desc: '',
      args: [],
    );
  }

  /// `oz`
  String get ozUnit {
    return Intl.message(
      'oz',
      name: 'ozUnit',
      desc: '',
      args: [],
    );
  }

  /// `fl.oz`
  String get flOzUnit {
    return Intl.message(
      'fl.oz',
      name: 'flOzUnit',
      desc: '',
      args: [],
    );
  }

  /// `N/A`
  String get notAvailableLabel {
    return Intl.message(
      'N/A',
      name: 'notAvailableLabel',
      desc: '',
      args: [],
    );
  }

  /// `Product missing required kcal or macronutrients information`
  String get missingProductInfo {
    return Intl.message(
      'Product missing required kcal or macronutrients information',
      name: 'missingProductInfo',
      desc: '',
      args: [],
    );
  }

  /// `Added new intake`
  String get infoAddedIntakeLabel {
    return Intl.message(
      'Added new intake',
      name: 'infoAddedIntakeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Added new activity`
  String get infoAddedActivityLabel {
    return Intl.message(
      'Added new activity',
      name: 'infoAddedActivityLabel',
      desc: '',
      args: [],
    );
  }

  /// `Logged entry details`
  String get loggedEntryDetailsLabel {
    return Intl.message(
      'Logged entry details',
      name: 'loggedEntryDetailsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Logged macros`
  String get loggedMacrosLabel {
    return Intl.message(
      'Logged macros',
      name: 'loggedMacrosLabel',
      desc: '',
      args: [],
    );
  }

  /// `Amount: `
  String get amountPrefixLabel {
    return Intl.message(
      'Amount: ',
      name: 'amountPrefixLabel',
      desc: '',
      args: [],
    );
  }

  /// `Activity summary`
  String get activitySummaryLabel {
    return Intl.message(
      'Activity summary',
      name: 'activitySummaryLabel',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get durationLabel {
    return Intl.message(
      'Duration',
      name: 'durationLabel',
      desc: '',
      args: [],
    );
  }

  /// `Edit meal`
  String get editMealLabel {
    return Intl.message(
      'Edit meal',
      name: 'editMealLabel',
      desc: '',
      args: [],
    );
  }

  /// `Meal name`
  String get mealNameLabel {
    return Intl.message(
      'Meal name',
      name: 'mealNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Brands`
  String get mealBrandsLabel {
    return Intl.message(
      'Brands',
      name: 'mealBrandsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Meal size (g/ml)`
  String get mealSizeLabel {
    return Intl.message(
      'Meal size (g/ml)',
      name: 'mealSizeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Meal size (oz/fl oz)`
  String get mealSizeLabelImperial {
    return Intl.message(
      'Meal size (oz/fl oz)',
      name: 'mealSizeLabelImperial',
      desc: '',
      args: [],
    );
  }

  /// `Serving`
  String get servingLabel {
    return Intl.message(
      'Serving',
      name: 'servingLabel',
      desc: '',
      args: [],
    );
  }

  /// `Per Serving`
  String get perServingLabel {
    return Intl.message(
      'Per Serving',
      name: 'perServingLabel',
      desc: '',
      args: [],
    );
  }

  /// `Serving size (g/ml)`
  String get servingSizeLabelMetric {
    return Intl.message(
      'Serving size (g/ml)',
      name: 'servingSizeLabelMetric',
      desc: '',
      args: [],
    );
  }

  /// `Serving size (oz/fl oz)`
  String get servingSizeLabelImperial {
    return Intl.message(
      'Serving size (oz/fl oz)',
      name: 'servingSizeLabelImperial',
      desc: '',
      args: [],
    );
  }

  /// `Meal unit`
  String get mealUnitLabel {
    return Intl.message(
      'Meal unit',
      name: 'mealUnitLabel',
      desc: '',
      args: [],
    );
  }

  /// `kcal per`
  String get mealKcalLabel {
    return Intl.message(
      'kcal per',
      name: 'mealKcalLabel',
      desc: '',
      args: [],
    );
  }

  /// `carbs per`
  String get mealCarbsLabel {
    return Intl.message(
      'carbs per',
      name: 'mealCarbsLabel',
      desc: '',
      args: [],
    );
  }

  /// `fat per`
  String get mealFatLabel {
    return Intl.message(
      'fat per',
      name: 'mealFatLabel',
      desc: '',
      args: [],
    );
  }

  /// `protein per 100 g/ml`
  String get mealProteinLabel {
    return Intl.message(
      'protein per 100 g/ml',
      name: 'mealProteinLabel',
      desc: '',
      args: [],
    );
  }

  /// `Error while saving meal. Did you input the correct meal information?`
  String get errorMealSave {
    return Intl.message(
      'Error while saving meal. Did you input the correct meal information?',
      name: 'errorMealSave',
      desc: '',
      args: [],
    );
  }

  /// `BMI`
  String get bmiLabel {
    return Intl.message(
      'BMI',
      name: 'bmiLabel',
      desc: '',
      args: [],
    );
  }

  /// `Body Mass Index (BMI) is a index to classify overweight and obesity in adults. It is defined as weight in kilograms divided by the square of height in meters (kg/m²).\n\nBMI does not differentiate between fat and muscle mass and can be misleading for some individuals.`
  String get bmiInfo {
    return Intl.message(
      'Body Mass Index (BMI) is a index to classify overweight and obesity in adults. It is defined as weight in kilograms divided by the square of height in meters (kg/m²).\n\nBMI does not differentiate between fat and muscle mass and can be misleading for some individuals.',
      name: 'bmiInfo',
      desc: '',
      args: [],
    );
  }

  /// `I have read and accept the privacy policy.`
  String get readLabel {
    return Intl.message(
      'I have read and accept the privacy policy.',
      name: 'readLabel',
      desc: '',
      args: [],
    );
  }

  /// `Privacy policy`
  String get privacyPolicyLabel {
    return Intl.message(
      'Privacy policy',
      name: 'privacyPolicyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Help improve stability by sending anonymous crash and diagnostic reports`
  String get dataCollectionLabel {
    return Intl.message(
      'Help improve stability by sending anonymous crash and diagnostic reports',
      name: 'dataCollectionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Sedentary`
  String get palSedentaryLabel {
    return Intl.message(
      'Sedentary',
      name: 'palSedentaryLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. office job and mostly sitting free time activities`
  String get palSedentaryDescriptionLabel {
    return Intl.message(
      'e.g. office job and mostly sitting free time activities',
      name: 'palSedentaryDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Low Active`
  String get palLowLActiveLabel {
    return Intl.message(
      'Low Active',
      name: 'palLowLActiveLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. sitting or standing in job and light free time activities`
  String get palLowActiveDescriptionLabel {
    return Intl.message(
      'e.g. sitting or standing in job and light free time activities',
      name: 'palLowActiveDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get palActiveLabel {
    return Intl.message(
      'Active',
      name: 'palActiveLabel',
      desc: '',
      args: [],
    );
  }

  /// `Mostly standing or walking in job and active free time activities`
  String get palActiveDescriptionLabel {
    return Intl.message(
      'Mostly standing or walking in job and active free time activities',
      name: 'palActiveDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Very Active`
  String get palVeryActiveLabel {
    return Intl.message(
      'Very Active',
      name: 'palVeryActiveLabel',
      desc: '',
      args: [],
    );
  }

  /// `Mostly walking, running or carrying weight in job and active free time activities`
  String get palVeryActiveDescriptionLabel {
    return Intl.message(
      'Mostly walking, running or carrying weight in job and active free time activities',
      name: 'palVeryActiveDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Select Activity Level`
  String get selectPalCategoryLabel {
    return Intl.message(
      'Select Activity Level',
      name: 'selectPalCategoryLabel',
      desc: '',
      args: [],
    );
  }

  /// `Choose Weight Goal`
  String get chooseWeightGoalLabel {
    return Intl.message(
      'Choose Weight Goal',
      name: 'chooseWeightGoalLabel',
      desc: '',
      args: [],
    );
  }

  /// `Lose Weight`
  String get goalLoseWeight {
    return Intl.message(
      'Lose Weight',
      name: 'goalLoseWeight',
      desc: '',
      args: [],
    );
  }

  /// `Maintain Weight`
  String get goalMaintainWeight {
    return Intl.message(
      'Maintain Weight',
      name: 'goalMaintainWeight',
      desc: '',
      args: [],
    );
  }

  /// `Gain Weight`
  String get goalGainWeight {
    return Intl.message(
      'Gain Weight',
      name: 'goalGainWeight',
      desc: '',
      args: [],
    );
  }

  /// `Goal`
  String get goalLabel {
    return Intl.message(
      'Goal',
      name: 'goalLabel',
      desc: '',
      args: [],
    );
  }

  /// `Select Height`
  String get selectHeightDialogLabel {
    return Intl.message(
      'Select Height',
      name: 'selectHeightDialogLabel',
      desc: '',
      args: [],
    );
  }

  /// `Height`
  String get heightLabel {
    return Intl.message(
      'Height',
      name: 'heightLabel',
      desc: '',
      args: [],
    );
  }

  /// `cm`
  String get cmLabel {
    return Intl.message(
      'cm',
      name: 'cmLabel',
      desc: '',
      args: [],
    );
  }

  /// `ft`
  String get ftLabel {
    return Intl.message(
      'ft',
      name: 'ftLabel',
      desc: '',
      args: [],
    );
  }

  /// `Select Weight`
  String get selectWeightDialogLabel {
    return Intl.message(
      'Select Weight',
      name: 'selectWeightDialogLabel',
      desc: '',
      args: [],
    );
  }

  /// `Weight`
  String get weightLabel {
    return Intl.message(
      'Weight',
      name: 'weightLabel',
      desc: '',
      args: [],
    );
  }

  /// `kg`
  String get kgLabel {
    return Intl.message(
      'kg',
      name: 'kgLabel',
      desc: '',
      args: [],
    );
  }

  /// `lbs`
  String get lbsLabel {
    return Intl.message(
      'lbs',
      name: 'lbsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Age`
  String get ageLabel {
    return Intl.message(
      'Age',
      name: 'ageLabel',
      desc: '',
      args: [],
    );
  }

  /// `{age} years`
  String yearsLabel(Object age) {
    return Intl.message(
      '$age years',
      name: 'yearsLabel',
      desc: '',
      args: [age],
    );
  }

  /// `Select Gender`
  String get selectGenderDialogLabel {
    return Intl.message(
      'Select Gender',
      name: 'selectGenderDialogLabel',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get genderLabel {
    return Intl.message(
      'Gender',
      name: 'genderLabel',
      desc: '',
      args: [],
    );
  }

  /// `♂ male`
  String get genderMaleLabel {
    return Intl.message(
      '♂ male',
      name: 'genderMaleLabel',
      desc: '',
      args: [],
    );
  }

  /// `♀ female`
  String get genderFemaleLabel {
    return Intl.message(
      '♀ female',
      name: 'genderFemaleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Nothing added`
  String get nothingAddedLabel {
    return Intl.message(
      'Nothing added',
      name: 'nothingAddedLabel',
      desc: '',
      args: [],
    );
  }

  /// `Underweight`
  String get nutritionalStatusUnderweight {
    return Intl.message(
      'Underweight',
      name: 'nutritionalStatusUnderweight',
      desc: '',
      args: [],
    );
  }

  /// `Normal Weight`
  String get nutritionalStatusNormalWeight {
    return Intl.message(
      'Normal Weight',
      name: 'nutritionalStatusNormalWeight',
      desc: '',
      args: [],
    );
  }

  /// `Pre-obesity`
  String get nutritionalStatusPreObesity {
    return Intl.message(
      'Pre-obesity',
      name: 'nutritionalStatusPreObesity',
      desc: '',
      args: [],
    );
  }

  /// `Obesity Class I`
  String get nutritionalStatusObeseClassI {
    return Intl.message(
      'Obesity Class I',
      name: 'nutritionalStatusObeseClassI',
      desc: '',
      args: [],
    );
  }

  /// `Obesity Class II`
  String get nutritionalStatusObeseClassII {
    return Intl.message(
      'Obesity Class II',
      name: 'nutritionalStatusObeseClassII',
      desc: '',
      args: [],
    );
  }

  /// `Obesity Class III`
  String get nutritionalStatusObeseClassIII {
    return Intl.message(
      'Obesity Class III',
      name: 'nutritionalStatusObeseClassIII',
      desc: '',
      args: [],
    );
  }

  /// `Risk of comorbidities: {riskValue}`
  String nutritionalStatusRiskLabel(Object riskValue) {
    return Intl.message(
      'Risk of comorbidities: $riskValue',
      name: 'nutritionalStatusRiskLabel',
      desc: '',
      args: [riskValue],
    );
  }

  /// `Low \n(but risk of other \nclinical problems increased)`
  String get nutritionalStatusRiskLow {
    return Intl.message(
      'Low \n(but risk of other \nclinical problems increased)',
      name: 'nutritionalStatusRiskLow',
      desc: '',
      args: [],
    );
  }

  /// `Average`
  String get nutritionalStatusRiskAverage {
    return Intl.message(
      'Average',
      name: 'nutritionalStatusRiskAverage',
      desc: '',
      args: [],
    );
  }

  /// `Increased`
  String get nutritionalStatusRiskIncreased {
    return Intl.message(
      'Increased',
      name: 'nutritionalStatusRiskIncreased',
      desc: '',
      args: [],
    );
  }

  /// `Moderate`
  String get nutritionalStatusRiskModerate {
    return Intl.message(
      'Moderate',
      name: 'nutritionalStatusRiskModerate',
      desc: '',
      args: [],
    );
  }

  /// `Severe`
  String get nutritionalStatusRiskSevere {
    return Intl.message(
      'Severe',
      name: 'nutritionalStatusRiskSevere',
      desc: '',
      args: [],
    );
  }

  /// `Very severe`
  String get nutritionalStatusRiskVerySevere {
    return Intl.message(
      'Very severe',
      name: 'nutritionalStatusRiskVerySevere',
      desc: '',
      args: [],
    );
  }

  /// `Error while opening email app`
  String get errorOpeningEmail {
    return Intl.message(
      'Error while opening email app',
      name: 'errorOpeningEmail',
      desc: '',
      args: [],
    );
  }

  /// `Error while opening browser app`
  String get errorOpeningBrowser {
    return Intl.message(
      'Error while opening browser app',
      name: 'errorOpeningBrowser',
      desc: '',
      args: [],
    );
  }

  /// `Error while fetching product data`
  String get errorFetchingProductData {
    return Intl.message(
      'Error while fetching product data',
      name: 'errorFetchingProductData',
      desc: '',
      args: [],
    );
  }

  /// `Product not found`
  String get errorProductNotFound {
    return Intl.message(
      'Product not found',
      name: 'errorProductNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Error while loading activities`
  String get errorLoadingActivities {
    return Intl.message(
      'Error while loading activities',
      name: 'errorLoadingActivities',
      desc: '',
      args: [],
    );
  }

  /// `No results found`
  String get noResultsFound {
    return Intl.message(
      'No results found',
      name: 'noResultsFound',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retryLabel {
    return Intl.message(
      'Retry',
      name: 'retryLabel',
      desc: '',
      args: [],
    );
  }

  /// `bicycling`
  String get paHeadingBicycling {
    return Intl.message(
      'bicycling',
      name: 'paHeadingBicycling',
      desc: '',
      args: [],
    );
  }

  /// `conditioning exercise`
  String get paHeadingConditionalExercise {
    return Intl.message(
      'conditioning exercise',
      name: 'paHeadingConditionalExercise',
      desc: '',
      args: [],
    );
  }

  /// `dancing`
  String get paHeadingDancing {
    return Intl.message(
      'dancing',
      name: 'paHeadingDancing',
      desc: '',
      args: [],
    );
  }

  /// `running`
  String get paHeadingRunning {
    return Intl.message(
      'running',
      name: 'paHeadingRunning',
      desc: '',
      args: [],
    );
  }

  /// `sports`
  String get paHeadingSports {
    return Intl.message(
      'sports',
      name: 'paHeadingSports',
      desc: '',
      args: [],
    );
  }

  /// `walking`
  String get paHeadingWalking {
    return Intl.message(
      'walking',
      name: 'paHeadingWalking',
      desc: '',
      args: [],
    );
  }

  /// `water activities`
  String get paHeadingWaterActivities {
    return Intl.message(
      'water activities',
      name: 'paHeadingWaterActivities',
      desc: '',
      args: [],
    );
  }

  /// `winter activities`
  String get paHeadingWinterActivities {
    return Intl.message(
      'winter activities',
      name: 'paHeadingWinterActivities',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paGeneralDesc {
    return Intl.message(
      'general',
      name: 'paGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `bicycling`
  String get paBicyclingGeneral {
    return Intl.message(
      'bicycling',
      name: 'paBicyclingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBicyclingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBicyclingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `bicycling, mountain`
  String get paBicyclingMountainGeneral {
    return Intl.message(
      'bicycling, mountain',
      name: 'paBicyclingMountainGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBicyclingMountainGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBicyclingMountainGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `unicycling`
  String get paUnicyclingGeneral {
    return Intl.message(
      'unicycling',
      name: 'paUnicyclingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paUnicyclingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paUnicyclingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `bicycling, stationary`
  String get paBicyclingStationaryGeneral {
    return Intl.message(
      'bicycling, stationary',
      name: 'paBicyclingStationaryGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBicyclingStationaryGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBicyclingStationaryGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `calisthenics`
  String get paCalisthenicsGeneral {
    return Intl.message(
      'calisthenics',
      name: 'paCalisthenicsGeneral',
      desc: '',
      args: [],
    );
  }

  /// `light or moderate effort, general (e.g., back exercises)`
  String get paCalisthenicsGeneralDesc {
    return Intl.message(
      'light or moderate effort, general (e.g., back exercises)',
      name: 'paCalisthenicsGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `resistance training`
  String get paResistanceTraining {
    return Intl.message(
      'resistance training',
      name: 'paResistanceTraining',
      desc: '',
      args: [],
    );
  }

  /// `weight lifting, free weight, nautilus or universal`
  String get paResistanceTrainingDesc {
    return Intl.message(
      'weight lifting, free weight, nautilus or universal',
      name: 'paResistanceTrainingDesc',
      desc: '',
      args: [],
    );
  }

  /// `rope skipping`
  String get paRopeSkippingGeneral {
    return Intl.message(
      'rope skipping',
      name: 'paRopeSkippingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paRopeSkippingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paRopeSkippingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `water exercise`
  String get paWaterAerobics {
    return Intl.message(
      'water exercise',
      name: 'paWaterAerobics',
      desc: '',
      args: [],
    );
  }

  /// `water aerobics, water calisthenics`
  String get paWaterAerobicsDesc {
    return Intl.message(
      'water aerobics, water calisthenics',
      name: 'paWaterAerobicsDesc',
      desc: '',
      args: [],
    );
  }

  /// `aerobic`
  String get paDancingAerobicGeneral {
    return Intl.message(
      'aerobic',
      name: 'paDancingAerobicGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paDancingAerobicGeneralDesc {
    return Intl.message(
      'general',
      name: 'paDancingAerobicGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `general dancing`
  String get paDancingGeneral {
    return Intl.message(
      'general dancing',
      name: 'paDancingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `e.g. disco, folk, Irish step dancing, line dancing, polka, country`
  String get paDancingGeneralDesc {
    return Intl.message(
      'e.g. disco, folk, Irish step dancing, line dancing, polka, country',
      name: 'paDancingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `jogging`
  String get paJoggingGeneral {
    return Intl.message(
      'jogging',
      name: 'paJoggingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paJoggingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paJoggingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `running`
  String get paRunningGeneral {
    return Intl.message(
      'running',
      name: 'paRunningGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paRunningGeneralDesc {
    return Intl.message(
      'general',
      name: 'paRunningGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `archery`
  String get paArcheryGeneral {
    return Intl.message(
      'archery',
      name: 'paArcheryGeneral',
      desc: '',
      args: [],
    );
  }

  /// `non-hunting`
  String get paArcheryGeneralDesc {
    return Intl.message(
      'non-hunting',
      name: 'paArcheryGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `badminton`
  String get paBadmintonGeneral {
    return Intl.message(
      'badminton',
      name: 'paBadmintonGeneral',
      desc: '',
      args: [],
    );
  }

  /// `social singles and doubles, general`
  String get paBadmintonGeneralDesc {
    return Intl.message(
      'social singles and doubles, general',
      name: 'paBadmintonGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `basketball`
  String get paBasketballGeneral {
    return Intl.message(
      'basketball',
      name: 'paBasketballGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBasketballGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBasketballGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `billiards`
  String get paBilliardsGeneral {
    return Intl.message(
      'billiards',
      name: 'paBilliardsGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBilliardsGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBilliardsGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `bowling`
  String get paBowlingGeneral {
    return Intl.message(
      'bowling',
      name: 'paBowlingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBowlingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBowlingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `boxing`
  String get paBoxingBag {
    return Intl.message(
      'boxing',
      name: 'paBoxingBag',
      desc: '',
      args: [],
    );
  }

  /// `punching bag`
  String get paBoxingBagDesc {
    return Intl.message(
      'punching bag',
      name: 'paBoxingBagDesc',
      desc: '',
      args: [],
    );
  }

  /// `boxing`
  String get paBoxingGeneral {
    return Intl.message(
      'boxing',
      name: 'paBoxingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `in ring, general`
  String get paBoxingGeneralDesc {
    return Intl.message(
      'in ring, general',
      name: 'paBoxingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `broomball`
  String get paBroomball {
    return Intl.message(
      'broomball',
      name: 'paBroomball',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBroomballDesc {
    return Intl.message(
      'general',
      name: 'paBroomballDesc',
      desc: '',
      args: [],
    );
  }

  /// `children’s games`
  String get paChildrenGame {
    return Intl.message(
      'children’s games',
      name: 'paChildrenGame',
      desc: '',
      args: [],
    );
  }

  /// `(e.g., hopscotch, 4-square, dodgeball, playground apparatus, t-ball, tetherball, marbles, arcade games), moderate effort`
  String get paChildrenGameDesc {
    return Intl.message(
      '(e.g., hopscotch, 4-square, dodgeball, playground apparatus, t-ball, tetherball, marbles, arcade games), moderate effort',
      name: 'paChildrenGameDesc',
      desc: '',
      args: [],
    );
  }

  /// `cheerleading`
  String get paCheerleading {
    return Intl.message(
      'cheerleading',
      name: 'paCheerleading',
      desc: '',
      args: [],
    );
  }

  /// `gymnastic moves, competitive`
  String get paCheerleadingDesc {
    return Intl.message(
      'gymnastic moves, competitive',
      name: 'paCheerleadingDesc',
      desc: '',
      args: [],
    );
  }

  /// `cricket`
  String get paCricket {
    return Intl.message(
      'cricket',
      name: 'paCricket',
      desc: '',
      args: [],
    );
  }

  /// `batting, bowling, fielding`
  String get paCricketDesc {
    return Intl.message(
      'batting, bowling, fielding',
      name: 'paCricketDesc',
      desc: '',
      args: [],
    );
  }

  /// `croquet`
  String get paCroquet {
    return Intl.message(
      'croquet',
      name: 'paCroquet',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paCroquetDesc {
    return Intl.message(
      'general',
      name: 'paCroquetDesc',
      desc: '',
      args: [],
    );
  }

  /// `curling`
  String get paCurling {
    return Intl.message(
      'curling',
      name: 'paCurling',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paCurlingDesc {
    return Intl.message(
      'general',
      name: 'paCurlingDesc',
      desc: '',
      args: [],
    );
  }

  /// `darts`
  String get paDartsWall {
    return Intl.message(
      'darts',
      name: 'paDartsWall',
      desc: '',
      args: [],
    );
  }

  /// `wall or lawn`
  String get paDartsWallDesc {
    return Intl.message(
      'wall or lawn',
      name: 'paDartsWallDesc',
      desc: '',
      args: [],
    );
  }

  /// `auto racing`
  String get paAutoRacing {
    return Intl.message(
      'auto racing',
      name: 'paAutoRacing',
      desc: '',
      args: [],
    );
  }

  /// `open wheel`
  String get paAutoRacingDesc {
    return Intl.message(
      'open wheel',
      name: 'paAutoRacingDesc',
      desc: '',
      args: [],
    );
  }

  /// `fencing`
  String get paFencing {
    return Intl.message(
      'fencing',
      name: 'paFencing',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paFencingDesc {
    return Intl.message(
      'general',
      name: 'paFencingDesc',
      desc: '',
      args: [],
    );
  }

  /// `football`
  String get paAmericanFootballGeneral {
    return Intl.message(
      'football',
      name: 'paAmericanFootballGeneral',
      desc: '',
      args: [],
    );
  }

  /// `touch, flag, general`
  String get paAmericanFootballGeneralDesc {
    return Intl.message(
      'touch, flag, general',
      name: 'paAmericanFootballGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `football or baseball`
  String get paCatch {
    return Intl.message(
      'football or baseball',
      name: 'paCatch',
      desc: '',
      args: [],
    );
  }

  /// `playing catch`
  String get paCatchDesc {
    return Intl.message(
      'playing catch',
      name: 'paCatchDesc',
      desc: '',
      args: [],
    );
  }

  /// `frisbee playing`
  String get paFrisbee {
    return Intl.message(
      'frisbee playing',
      name: 'paFrisbee',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paFrisbeeDesc {
    return Intl.message(
      'general',
      name: 'paFrisbeeDesc',
      desc: '',
      args: [],
    );
  }

  /// `golf`
  String get paGolfGeneral {
    return Intl.message(
      'golf',
      name: 'paGolfGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paGolfGeneralDesc {
    return Intl.message(
      'general',
      name: 'paGolfGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `gymnastics`
  String get paGymnasticsGeneral {
    return Intl.message(
      'gymnastics',
      name: 'paGymnasticsGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paGymnasticsGeneralDesc {
    return Intl.message(
      'general',
      name: 'paGymnasticsGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `hacky sack`
  String get paHackySack {
    return Intl.message(
      'hacky sack',
      name: 'paHackySack',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paHackySackDesc {
    return Intl.message(
      'general',
      name: 'paHackySackDesc',
      desc: '',
      args: [],
    );
  }

  /// `handball`
  String get paHandballGeneral {
    return Intl.message(
      'handball',
      name: 'paHandballGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paHandballGeneralDesc {
    return Intl.message(
      'general',
      name: 'paHandballGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `hang gliding`
  String get paHangGliding {
    return Intl.message(
      'hang gliding',
      name: 'paHangGliding',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paHangGlidingDesc {
    return Intl.message(
      'general',
      name: 'paHangGlidingDesc',
      desc: '',
      args: [],
    );
  }

  /// `hockey, field`
  String get paHockeyField {
    return Intl.message(
      'hockey, field',
      name: 'paHockeyField',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paHockeyFieldDesc {
    return Intl.message(
      'general',
      name: 'paHockeyFieldDesc',
      desc: '',
      args: [],
    );
  }

  /// `ice hockey`
  String get paIceHockeyGeneral {
    return Intl.message(
      'ice hockey',
      name: 'paIceHockeyGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paIceHockeyGeneralDesc {
    return Intl.message(
      'general',
      name: 'paIceHockeyGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `horseback riding`
  String get paHorseRidingGeneral {
    return Intl.message(
      'horseback riding',
      name: 'paHorseRidingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paHorseRidingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paHorseRidingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `jai alai`
  String get paJaiAlai {
    return Intl.message(
      'jai alai',
      name: 'paJaiAlai',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paJaiAlaiDesc {
    return Intl.message(
      'general',
      name: 'paJaiAlaiDesc',
      desc: '',
      args: [],
    );
  }

  /// `martial arts`
  String get paMartialArtsSlower {
    return Intl.message(
      'martial arts',
      name: 'paMartialArtsSlower',
      desc: '',
      args: [],
    );
  }

  /// `different types, slower pace, novice performers, practice`
  String get paMartialArtsSlowerDesc {
    return Intl.message(
      'different types, slower pace, novice performers, practice',
      name: 'paMartialArtsSlowerDesc',
      desc: '',
      args: [],
    );
  }

  /// `martial arts`
  String get paMartialArtsModerate {
    return Intl.message(
      'martial arts',
      name: 'paMartialArtsModerate',
      desc: '',
      args: [],
    );
  }

  /// `different types, moderate pace (e.g., judo, jujitsu, karate, kick boxing, tae kwan do, tai-bo, Muay Thai boxing)`
  String get paMartialArtsModerateDesc {
    return Intl.message(
      'different types, moderate pace (e.g., judo, jujitsu, karate, kick boxing, tae kwan do, tai-bo, Muay Thai boxing)',
      name: 'paMartialArtsModerateDesc',
      desc: '',
      args: [],
    );
  }

  /// `juggling`
  String get paJuggling {
    return Intl.message(
      'juggling',
      name: 'paJuggling',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paJugglingDesc {
    return Intl.message(
      'general',
      name: 'paJugglingDesc',
      desc: '',
      args: [],
    );
  }

  /// `kickball`
  String get paKickball {
    return Intl.message(
      'kickball',
      name: 'paKickball',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paKickballDesc {
    return Intl.message(
      'general',
      name: 'paKickballDesc',
      desc: '',
      args: [],
    );
  }

  /// `lacrosse`
  String get paLacrosse {
    return Intl.message(
      'lacrosse',
      name: 'paLacrosse',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paLacrosseDesc {
    return Intl.message(
      'general',
      name: 'paLacrosseDesc',
      desc: '',
      args: [],
    );
  }

  /// `lawn bowling`
  String get paLawnBowling {
    return Intl.message(
      'lawn bowling',
      name: 'paLawnBowling',
      desc: '',
      args: [],
    );
  }

  /// `bocce ball, outdoor`
  String get paLawnBowlingDesc {
    return Intl.message(
      'bocce ball, outdoor',
      name: 'paLawnBowlingDesc',
      desc: '',
      args: [],
    );
  }

  /// `moto-cross`
  String get paMotoCross {
    return Intl.message(
      'moto-cross',
      name: 'paMotoCross',
      desc: '',
      args: [],
    );
  }

  /// `off-road motor sports, all-terrain vehicle, general`
  String get paMotoCrossDesc {
    return Intl.message(
      'off-road motor sports, all-terrain vehicle, general',
      name: 'paMotoCrossDesc',
      desc: '',
      args: [],
    );
  }

  /// `orienteering`
  String get paOrienteering {
    return Intl.message(
      'orienteering',
      name: 'paOrienteering',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paOrienteeringDesc {
    return Intl.message(
      'general',
      name: 'paOrienteeringDesc',
      desc: '',
      args: [],
    );
  }

  /// `paddleball`
  String get paPaddleball {
    return Intl.message(
      'paddleball',
      name: 'paPaddleball',
      desc: '',
      args: [],
    );
  }

  /// `casual, general`
  String get paPaddleballDesc {
    return Intl.message(
      'casual, general',
      name: 'paPaddleballDesc',
      desc: '',
      args: [],
    );
  }

  /// `polo`
  String get paPoloHorse {
    return Intl.message(
      'polo',
      name: 'paPoloHorse',
      desc: '',
      args: [],
    );
  }

  /// `on horseback`
  String get paPoloHorseDesc {
    return Intl.message(
      'on horseback',
      name: 'paPoloHorseDesc',
      desc: '',
      args: [],
    );
  }

  /// `racquetball`
  String get paRacquetball {
    return Intl.message(
      'racquetball',
      name: 'paRacquetball',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paRacquetballDesc {
    return Intl.message(
      'general',
      name: 'paRacquetballDesc',
      desc: '',
      args: [],
    );
  }

  /// `climbing`
  String get paMountainClimbing {
    return Intl.message(
      'climbing',
      name: 'paMountainClimbing',
      desc: '',
      args: [],
    );
  }

  /// `rock or mountain climbing`
  String get paMountainClimbingDesc {
    return Intl.message(
      'rock or mountain climbing',
      name: 'paMountainClimbingDesc',
      desc: '',
      args: [],
    );
  }

  /// `rodeo sports`
  String get paRodeoSportGeneralModerate {
    return Intl.message(
      'rodeo sports',
      name: 'paRodeoSportGeneralModerate',
      desc: '',
      args: [],
    );
  }

  /// `general, moderate effort`
  String get paRodeoSportGeneralModerateDesc {
    return Intl.message(
      'general, moderate effort',
      name: 'paRodeoSportGeneralModerateDesc',
      desc: '',
      args: [],
    );
  }

  /// `rope jumping`
  String get paRopeJumpingGeneral {
    return Intl.message(
      'rope jumping',
      name: 'paRopeJumpingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `moderate pace, 100-120 skips/min, general, 2 foot skip, plain bounce`
  String get paRopeJumpingGeneralDesc {
    return Intl.message(
      'moderate pace, 100-120 skips/min, general, 2 foot skip, plain bounce',
      name: 'paRopeJumpingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `rugby`
  String get paRugbyCompetitive {
    return Intl.message(
      'rugby',
      name: 'paRugbyCompetitive',
      desc: '',
      args: [],
    );
  }

  /// `union, team, competitive`
  String get paRugbyCompetitiveDesc {
    return Intl.message(
      'union, team, competitive',
      name: 'paRugbyCompetitiveDesc',
      desc: '',
      args: [],
    );
  }

  /// `rugby`
  String get paRugbyNonCompetitive {
    return Intl.message(
      'rugby',
      name: 'paRugbyNonCompetitive',
      desc: '',
      args: [],
    );
  }

  /// `touch, non-competitive`
  String get paRugbyNonCompetitiveDesc {
    return Intl.message(
      'touch, non-competitive',
      name: 'paRugbyNonCompetitiveDesc',
      desc: '',
      args: [],
    );
  }

  /// `shuffleboard`
  String get paShuffleboard {
    return Intl.message(
      'shuffleboard',
      name: 'paShuffleboard',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paShuffleboardDesc {
    return Intl.message(
      'general',
      name: 'paShuffleboardDesc',
      desc: '',
      args: [],
    );
  }

  /// `skateboarding`
  String get paSkateboardingGeneral {
    return Intl.message(
      'skateboarding',
      name: 'paSkateboardingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general, moderate effort`
  String get paSkateboardingGeneralDesc {
    return Intl.message(
      'general, moderate effort',
      name: 'paSkateboardingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `roller skating`
  String get paSkatingRoller {
    return Intl.message(
      'roller skating',
      name: 'paSkatingRoller',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paSkatingRollerDesc {
    return Intl.message(
      'general',
      name: 'paSkatingRollerDesc',
      desc: '',
      args: [],
    );
  }

  /// `rollerblading`
  String get paRollerbladingLight {
    return Intl.message(
      'rollerblading',
      name: 'paRollerbladingLight',
      desc: '',
      args: [],
    );
  }

  /// `in-line skating`
  String get paRollerbladingLightDesc {
    return Intl.message(
      'in-line skating',
      name: 'paRollerbladingLightDesc',
      desc: '',
      args: [],
    );
  }

  /// `skydiving`
  String get paSkydiving {
    return Intl.message(
      'skydiving',
      name: 'paSkydiving',
      desc: '',
      args: [],
    );
  }

  /// `skydiving, base jumping, bungee jumping`
  String get paSkydivingDesc {
    return Intl.message(
      'skydiving, base jumping, bungee jumping',
      name: 'paSkydivingDesc',
      desc: '',
      args: [],
    );
  }

  /// `soccer`
  String get paSoccerGeneral {
    return Intl.message(
      'soccer',
      name: 'paSoccerGeneral',
      desc: '',
      args: [],
    );
  }

  /// `casual, general`
  String get paSoccerGeneralDesc {
    return Intl.message(
      'casual, general',
      name: 'paSoccerGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `softball / baseball`
  String get paSoftballBaseballGeneral {
    return Intl.message(
      'softball / baseball',
      name: 'paSoftballBaseballGeneral',
      desc: '',
      args: [],
    );
  }

  /// `fast or slow pitch, general`
  String get paSoftballBaseballGeneralDesc {
    return Intl.message(
      'fast or slow pitch, general',
      name: 'paSoftballBaseballGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `squash`
  String get paSquashGeneral {
    return Intl.message(
      'squash',
      name: 'paSquashGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paSquashGeneralDesc {
    return Intl.message(
      'general',
      name: 'paSquashGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `table tennis`
  String get paTableTennisGeneral {
    return Intl.message(
      'table tennis',
      name: 'paTableTennisGeneral',
      desc: '',
      args: [],
    );
  }

  /// `table tennis, ping pong`
  String get paTableTennisGeneralDesc {
    return Intl.message(
      'table tennis, ping pong',
      name: 'paTableTennisGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `tai chi, qi gong`
  String get paTaiChiQiGongGeneral {
    return Intl.message(
      'tai chi, qi gong',
      name: 'paTaiChiQiGongGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paTaiChiQiGongGeneralDesc {
    return Intl.message(
      'general',
      name: 'paTaiChiQiGongGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `tennis`
  String get paTennisGeneral {
    return Intl.message(
      'tennis',
      name: 'paTennisGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paTennisGeneralDesc {
    return Intl.message(
      'general',
      name: 'paTennisGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `trampoline`
  String get paTrampolineLight {
    return Intl.message(
      'trampoline',
      name: 'paTrampolineLight',
      desc: '',
      args: [],
    );
  }

  /// `recreational`
  String get paTrampolineLightDesc {
    return Intl.message(
      'recreational',
      name: 'paTrampolineLightDesc',
      desc: '',
      args: [],
    );
  }

  /// `volleyball`
  String get paVolleyballGeneral {
    return Intl.message(
      'volleyball',
      name: 'paVolleyballGeneral',
      desc: '',
      args: [],
    );
  }

  /// `non-competitive, 6 - 9 member team, general`
  String get paVolleyballGeneralDesc {
    return Intl.message(
      'non-competitive, 6 - 9 member team, general',
      name: 'paVolleyballGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `wrestling`
  String get paWrestling {
    return Intl.message(
      'wrestling',
      name: 'paWrestling',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paWrestlingDesc {
    return Intl.message(
      'general',
      name: 'paWrestlingDesc',
      desc: '',
      args: [],
    );
  }

  /// `wallyball`
  String get paWallyball {
    return Intl.message(
      'wallyball',
      name: 'paWallyball',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paWallyballDesc {
    return Intl.message(
      'general',
      name: 'paWallyballDesc',
      desc: '',
      args: [],
    );
  }

  /// `track and field`
  String get paTrackField {
    return Intl.message(
      'track and field',
      name: 'paTrackField',
      desc: '',
      args: [],
    );
  }

  /// `(e.g. shot, discus, hammer throw)`
  String get paTrackField1Desc {
    return Intl.message(
      '(e.g. shot, discus, hammer throw)',
      name: 'paTrackField1Desc',
      desc: '',
      args: [],
    );
  }

  /// `(e.g. high jump, long jump, triple jump, javelin, pole vault)`
  String get paTrackField2Desc {
    return Intl.message(
      '(e.g. high jump, long jump, triple jump, javelin, pole vault)',
      name: 'paTrackField2Desc',
      desc: '',
      args: [],
    );
  }

  /// `(e.g. steeplechase, hurdles)`
  String get paTrackField3Desc {
    return Intl.message(
      '(e.g. steeplechase, hurdles)',
      name: 'paTrackField3Desc',
      desc: '',
      args: [],
    );
  }

  /// `backpacking`
  String get paBackpackingGeneral {
    return Intl.message(
      'backpacking',
      name: 'paBackpackingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paBackpackingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paBackpackingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `climbing hills, no load`
  String get paClimbingHillsNoLoadGeneral {
    return Intl.message(
      'climbing hills, no load',
      name: 'paClimbingHillsNoLoadGeneral',
      desc: '',
      args: [],
    );
  }

  /// `no load`
  String get paClimbingHillsNoLoadGeneralDesc {
    return Intl.message(
      'no load',
      name: 'paClimbingHillsNoLoadGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `hiking`
  String get paHikingCrossCountry {
    return Intl.message(
      'hiking',
      name: 'paHikingCrossCountry',
      desc: '',
      args: [],
    );
  }

  /// `cross country`
  String get paHikingCrossCountryDesc {
    return Intl.message(
      'cross country',
      name: 'paHikingCrossCountryDesc',
      desc: '',
      args: [],
    );
  }

  /// `walking`
  String get paWalkingForPleasure {
    return Intl.message(
      'walking',
      name: 'paWalkingForPleasure',
      desc: '',
      args: [],
    );
  }

  /// `for pleasure`
  String get paWalkingForPleasureDesc {
    return Intl.message(
      'for pleasure',
      name: 'paWalkingForPleasureDesc',
      desc: '',
      args: [],
    );
  }

  /// `walking the dog`
  String get paWalkingTheDog {
    return Intl.message(
      'walking the dog',
      name: 'paWalkingTheDog',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paWalkingTheDogDesc {
    return Intl.message(
      'general',
      name: 'paWalkingTheDogDesc',
      desc: '',
      args: [],
    );
  }

  /// `canoeing`
  String get paCanoeingGeneral {
    return Intl.message(
      'canoeing',
      name: 'paCanoeingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `rowing, for pleasure, general`
  String get paCanoeingGeneralDesc {
    return Intl.message(
      'rowing, for pleasure, general',
      name: 'paCanoeingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `diving`
  String get paDivingSpringboardPlatform {
    return Intl.message(
      'diving',
      name: 'paDivingSpringboardPlatform',
      desc: '',
      args: [],
    );
  }

  /// `springboard or platform`
  String get paDivingSpringboardPlatformDesc {
    return Intl.message(
      'springboard or platform',
      name: 'paDivingSpringboardPlatformDesc',
      desc: '',
      args: [],
    );
  }

  /// `kayaking`
  String get paKayakingModerate {
    return Intl.message(
      'kayaking',
      name: 'paKayakingModerate',
      desc: '',
      args: [],
    );
  }

  /// `moderate effort`
  String get paKayakingModerateDesc {
    return Intl.message(
      'moderate effort',
      name: 'paKayakingModerateDesc',
      desc: '',
      args: [],
    );
  }

  /// `paddle boat`
  String get paPaddleBoat {
    return Intl.message(
      'paddle boat',
      name: 'paPaddleBoat',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paPaddleBoatDesc {
    return Intl.message(
      'general',
      name: 'paPaddleBoatDesc',
      desc: '',
      args: [],
    );
  }

  /// `sailing`
  String get paSailingGeneral {
    return Intl.message(
      'sailing',
      name: 'paSailingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `boat and board sailing, windsurfing, ice sailing, general`
  String get paSailingGeneralDesc {
    return Intl.message(
      'boat and board sailing, windsurfing, ice sailing, general',
      name: 'paSailingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `water skiing`
  String get paSkiingWaterWakeboarding {
    return Intl.message(
      'water skiing',
      name: 'paSkiingWaterWakeboarding',
      desc: '',
      args: [],
    );
  }

  /// `water or wakeboarding`
  String get paSkiingWaterWakeboardingDesc {
    return Intl.message(
      'water or wakeboarding',
      name: 'paSkiingWaterWakeboardingDesc',
      desc: '',
      args: [],
    );
  }

  /// `diving`
  String get paDivingGeneral {
    return Intl.message(
      'diving',
      name: 'paDivingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `skindiving, scuba diving, general`
  String get paDivingGeneralDesc {
    return Intl.message(
      'skindiving, scuba diving, general',
      name: 'paDivingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `snorkeling`
  String get paSnorkeling {
    return Intl.message(
      'snorkeling',
      name: 'paSnorkeling',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paSnorkelingDesc {
    return Intl.message(
      'general',
      name: 'paSnorkelingDesc',
      desc: '',
      args: [],
    );
  }

  /// `surfing`
  String get paSurfing {
    return Intl.message(
      'surfing',
      name: 'paSurfing',
      desc: '',
      args: [],
    );
  }

  /// `body or board, general`
  String get paSurfingDesc {
    return Intl.message(
      'body or board, general',
      name: 'paSurfingDesc',
      desc: '',
      args: [],
    );
  }

  /// `paddle boarding`
  String get paPaddleBoarding {
    return Intl.message(
      'paddle boarding',
      name: 'paPaddleBoarding',
      desc: '',
      args: [],
    );
  }

  /// `standing`
  String get paPaddleBoardingDesc {
    return Intl.message(
      'standing',
      name: 'paPaddleBoardingDesc',
      desc: '',
      args: [],
    );
  }

  /// `swimming`
  String get paSwimmingGeneral {
    return Intl.message(
      'swimming',
      name: 'paSwimmingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `treading water, moderate effort, general`
  String get paSwimmingGeneralDesc {
    return Intl.message(
      'treading water, moderate effort, general',
      name: 'paSwimmingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `water aerobics`
  String get paWateraerobicsCalisthenics {
    return Intl.message(
      'water aerobics',
      name: 'paWateraerobicsCalisthenics',
      desc: '',
      args: [],
    );
  }

  /// `water aerobics, water calisthenics`
  String get paWateraerobicsCalisthenicsDesc {
    return Intl.message(
      'water aerobics, water calisthenics',
      name: 'paWateraerobicsCalisthenicsDesc',
      desc: '',
      args: [],
    );
  }

  /// `water polo`
  String get paWaterPolo {
    return Intl.message(
      'water polo',
      name: 'paWaterPolo',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paWaterPoloDesc {
    return Intl.message(
      'general',
      name: 'paWaterPoloDesc',
      desc: '',
      args: [],
    );
  }

  /// `water volleyball`
  String get paWaterVolleyball {
    return Intl.message(
      'water volleyball',
      name: 'paWaterVolleyball',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paWaterVolleyballDesc {
    return Intl.message(
      'general',
      name: 'paWaterVolleyballDesc',
      desc: '',
      args: [],
    );
  }

  /// `ice skating`
  String get paIceSkatingGeneral {
    return Intl.message(
      'ice skating',
      name: 'paIceSkatingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paIceSkatingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paIceSkatingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `skiing`
  String get paSkiingGeneral {
    return Intl.message(
      'skiing',
      name: 'paSkiingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get paSkiingGeneralDesc {
    return Intl.message(
      'general',
      name: 'paSkiingGeneralDesc',
      desc: '',
      args: [],
    );
  }

  /// `snow shoveling`
  String get paSnowShovingModerate {
    return Intl.message(
      'snow shoveling',
      name: 'paSnowShovingModerate',
      desc: '',
      args: [],
    );
  }

  /// `by hand, moderate effort`
  String get paSnowShovingModerateDesc {
    return Intl.message(
      'by hand, moderate effort',
      name: 'paSnowShovingModerateDesc',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get todayLabel {
    return Intl.message(
      'Today',
      name: 'todayLabel',
      desc: '',
      args: [],
    );
  }

  /// `day`
  String get dayLabel {
    return Intl.message(
      'day',
      name: 'dayLabel',
      desc: '',
      args: [],
    );
  }

  /// `AI Meal Photo`
  String get aiMealPhotoTitle {
    return Intl.message(
      'AI Meal Photo',
      name: 'aiMealPhotoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Review AI Draft`
  String get aiReviewDraftTitle {
    return Intl.message(
      'Review AI Draft',
      name: 'aiReviewDraftTitle',
      desc: '',
      args: [],
    );
  }

  /// `Detected ingredients`
  String get aiDetectedIngredients {
    return Intl.message(
      'Detected ingredients',
      name: 'aiDetectedIngredients',
      desc: '',
      args: [],
    );
  }

  /// `{count} active`
  String aiActiveItemsCount(Object count) {
    return Intl.message(
      '$count active',
      name: 'aiActiveItemsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Save as recipe`
  String get aiSaveAsRecipe {
    return Intl.message(
      'Save as recipe',
      name: 'aiSaveAsRecipe',
      desc: '',
      args: [],
    );
  }

  /// `Add ingredient`
  String get aiAddIngredient {
    return Intl.message(
      'Add ingredient',
      name: 'aiAddIngredient',
      desc: '',
      args: [],
    );
  }

  /// `Saving meal...`
  String get aiSavingMeal {
    return Intl.message(
      'Saving meal...',
      name: 'aiSavingMeal',
      desc: '',
      args: [],
    );
  }

  /// `Save meal`
  String get aiSaveMeal {
    return Intl.message(
      'Save meal',
      name: 'aiSaveMeal',
      desc: '',
      args: [],
    );
  }

  /// `Draft not found or expired.`
  String get aiDraftNotFound {
    return Intl.message(
      'Draft not found or expired.',
      name: 'aiDraftNotFound',
      desc: '',
      args: [],
    );
  }

  /// `AI draft ready`
  String get aiDraftReadyTitle {
    return Intl.message(
      'AI draft ready',
      name: 'aiDraftReadyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade`
  String get aiDraftUpgradeAction {
    return Intl.message(
      'Upgrade',
      name: 'aiDraftUpgradeAction',
      desc: '',
      args: [],
    );
  }

  /// `{count} ingredients detected, about {kcal} kcal. You can save without using trials.`
  String aiDraftPremiumMessage(Object count, Object kcal) {
    return Intl.message(
      '$count ingredients detected, about $kcal kcal. You can save without using trials.',
      name: 'aiDraftPremiumMessage',
      desc: '',
      args: [count, kcal],
    );
  }

  /// `{count} ingredients detected, about {kcal} kcal. Reviewing is free; saving uses 1 of your {remaining} trials.`
  String aiDraftTrialMessage(Object count, Object kcal, Object remaining) {
    return Intl.message(
      '$count ingredients detected, about $kcal kcal. Reviewing is free; saving uses 1 of your $remaining trials.',
      name: 'aiDraftTrialMessage',
      desc: '',
      args: [count, kcal, remaining],
    );
  }

  /// `{count} ingredients detected, about {kcal} kcal. Upgrade to save unlimited AI meals.`
  String aiDraftBlockedMessage(Object count, Object kcal) {
    return Intl.message(
      '$count ingredients detected, about $kcal kcal. Upgrade to save unlimited AI meals.',
      name: 'aiDraftBlockedMessage',
      desc: '',
      args: [count, kcal],
    );
  }

  /// `Recipe name`
  String get aiRecipeNameLabel {
    return Intl.message(
      'Recipe name',
      name: 'aiRecipeNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Use names like pre-workout oats, post-workout chicken rice, or shake.`
  String get aiRecipeNameHelper {
    return Intl.message(
      'Use names like pre-workout oats, post-workout chicken rice, or shake.',
      name: 'aiRecipeNameHelper',
      desc: '',
      args: [],
    );
  }

  /// `Saved for quick access`
  String get aiFavoriteQuickAccess {
    return Intl.message(
      'Saved for quick access',
      name: 'aiFavoriteQuickAccess',
      desc: '',
      args: [],
    );
  }

  /// `Capture by photo`
  String get aiCaptureByPhotoTitle {
    return Intl.message(
      'Capture by photo',
      name: 'aiCaptureByPhotoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Import a meal image, review the editable draft, and save it to {mealType}.`
  String aiCaptureByPhotoSubtitle(Object mealType) {
    return Intl.message(
      'Import a meal image, review the editable draft, and save it to $mealType.',
      name: 'aiCaptureByPhotoSubtitle',
      desc: '',
      args: [mealType],
    );
  }

  /// `Pick image`
  String get aiStepPickImage {
    return Intl.message(
      'Pick image',
      name: 'aiStepPickImage',
      desc: '',
      args: [],
    );
  }

  /// `Review items`
  String get aiStepReviewItems {
    return Intl.message(
      'Review items',
      name: 'aiStepReviewItems',
      desc: '',
      args: [],
    );
  }

  /// `Save meal`
  String get aiStepSaveMeal {
    return Intl.message(
      'Save meal',
      name: 'aiStepSaveMeal',
      desc: '',
      args: [],
    );
  }

  /// `Recommendations`
  String get aiHintRecommendations {
    return Intl.message(
      'Recommendations',
      name: 'aiHintRecommendations',
      desc: '',
      args: [],
    );
  }

  /// `Show full plate`
  String get aiHintShowFullPlateTitle {
    return Intl.message(
      'Show full plate',
      name: 'aiHintShowFullPlateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Better framing, better ingredient detection.`
  String get aiHintShowFullPlateSubtitle {
    return Intl.message(
      'Better framing, better ingredient detection.',
      name: 'aiHintShowFullPlateSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Check sauces and oils`
  String get aiHintCheckSaucesTitle {
    return Intl.message(
      'Check sauces and oils',
      name: 'aiHintCheckSaucesTitle',
      desc: '',
      args: [],
    );
  }

  /// `The draft is just the first step. Correct hidden calories.`
  String get aiHintCheckSaucesSubtitle {
    return Intl.message(
      'The draft is just the first step. Correct hidden calories.',
      name: 'aiHintCheckSaucesSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Designed for gym meals`
  String get aiHintGymMealsTitle {
    return Intl.message(
      'Designed for gym meals',
      name: 'aiHintGymMealsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Useful for bowls, shakes, post-workouts, and repeated meals.`
  String get aiHintGymMealsSubtitle {
    return Intl.message(
      'Useful for bowls, shakes, post-workouts, and repeated meals.',
      name: 'aiHintGymMealsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Take photo and review`
  String get aiButtonCapture {
    return Intl.message(
      'Take photo and review',
      name: 'aiButtonCapture',
      desc: '',
      args: [],
    );
  }

  /// `Pick from gallery`
  String get aiButtonPickGallery {
    return Intl.message(
      'Pick from gallery',
      name: 'aiButtonPickGallery',
      desc: '',
      args: [],
    );
  }

  /// `Use text`
  String get aiButtonUseText {
    return Intl.message(
      'Use text',
      name: 'aiButtonUseText',
      desc: '',
      args: [],
    );
  }

  /// `AI suggests ingredients and macros. You review everything before saving.`
  String get aiPhotoReviewNotice {
    return Intl.message(
      'AI suggests ingredients and macros. You review everything before saving.',
      name: 'aiPhotoReviewNotice',
      desc: '',
      args: [],
    );
  }

  /// `Open this if you want better detection.`
  String get aiPhotoHintSubtitle {
    return Intl.message(
      'Open this if you want better detection.',
      name: 'aiPhotoHintSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Take photo`
  String get aiPhotoTakePhoto {
    return Intl.message(
      'Take photo',
      name: 'aiPhotoTakePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Retake photo`
  String get aiPhotoRetakePhoto {
    return Intl.message(
      'Retake photo',
      name: 'aiPhotoRetakePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Choose from gallery`
  String get aiPhotoChooseGallery {
    return Intl.message(
      'Choose from gallery',
      name: 'aiPhotoChooseGallery',
      desc: '',
      args: [],
    );
  }

  /// `You will be able to correct ingredients before saving.`
  String get aiPhotoCorrectionHint {
    return Intl.message(
      'You will be able to correct ingredients before saving.',
      name: 'aiPhotoCorrectionHint',
      desc: '',
      args: [],
    );
  }

  /// `Use this photo`
  String get aiPhotoUseThisPhoto {
    return Intl.message(
      'Use this photo',
      name: 'aiPhotoUseThisPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Remove photo`
  String get aiPhotoRemovePhoto {
    return Intl.message(
      'Remove photo',
      name: 'aiPhotoRemovePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Opening photo analysis...`
  String get aiPhotoOpeningAnalysis {
    return Intl.message(
      'Opening photo analysis...',
      name: 'aiPhotoOpeningAnalysis',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get aiPhotoPreviewTitle {
    return Intl.message(
      'Preview',
      name: 'aiPhotoPreviewTitle',
      desc: '',
      args: [],
    );
  }

  /// `Confirm the photo looks good before sending it to AI.`
  String get aiPhotoPreviewSubtitle {
    return Intl.message(
      'Confirm the photo looks good before sending it to AI.',
      name: 'aiPhotoPreviewSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `This usually takes 5 to 10 seconds.`
  String get aiCaptureProcessingTime {
    return Intl.message(
      'This usually takes 5 to 10 seconds.',
      name: 'aiCaptureProcessingTime',
      desc: '',
      args: [],
    );
  }

  /// `AI is preparing a draft. You will be able to review, edit, or remove ingredients before saving.`
  String get aiCaptureDraftReviewNotice {
    return Intl.message(
      'AI is preparing a draft. You will be able to review, edit, or remove ingredients before saving.',
      name: 'aiCaptureDraftReviewNotice',
      desc: '',
      args: [],
    );
  }

  /// `AI unavailable`
  String get aiUnavailableTitle {
    return Intl.message(
      'AI unavailable',
      name: 'aiUnavailableTitle',
      desc: '',
      args: [],
    );
  }

  /// `Continue manually`
  String get aiContinueManually {
    return Intl.message(
      'Continue manually',
      name: 'aiContinueManually',
      desc: '',
      args: [],
    );
  }

  /// `The AI request timed out. Retry or continue with a manual review.`
  String get aiFailureTimeoutManualReview {
    return Intl.message(
      'The AI request timed out. Retry or continue with a manual review.',
      name: 'aiFailureTimeoutManualReview',
      desc: '',
      args: [],
    );
  }

  /// `No network connection. Retry when you are back online or continue with a manual review.`
  String get aiFailureNoNetworkManualReview {
    return Intl.message(
      'No network connection. Retry when you are back online or continue with a manual review.',
      name: 'aiFailureNoNetworkManualReview',
      desc: '',
      args: [],
    );
  }

  /// `Your cloud session is no longer valid. Reopen or protect your cloud account and retry.`
  String get aiFailureCloudSessionInvalid {
    return Intl.message(
      'Your cloud session is no longer valid. Reopen or protect your cloud account and retry.',
      name: 'aiFailureCloudSessionInvalid',
      desc: '',
      args: [],
    );
  }

  /// `The AI response could not be used. Retry or continue with a manual draft.`
  String get aiFailureInvalidResponseManualDraft {
    return Intl.message(
      'The AI response could not be used. Retry or continue with a manual draft.',
      name: 'aiFailureInvalidResponseManualDraft',
      desc: '',
      args: [],
    );
  }

  /// `AI meal interpretation is temporarily unavailable. Retry or continue manually.`
  String get aiFailureUnavailableManual {
    return Intl.message(
      'AI meal interpretation is temporarily unavailable. Retry or continue manually.',
      name: 'aiFailureUnavailableManual',
      desc: '',
      args: [],
    );
  }

  /// `Describe your meal`
  String get aiTextDescribeMealTitle {
    return Intl.message(
      'Describe your meal',
      name: 'aiTextDescribeMealTitle',
      desc: '',
      args: [],
    );
  }

  /// `Write ingredients, quantities, or a full meal so AI can prepare a draft for you.`
  String get aiTextDescribeMealSubtitle {
    return Intl.message(
      'Write ingredients, quantities, or a full meal so AI can prepare a draft for you.',
      name: 'aiTextDescribeMealSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `AI creates an editable draft. You review ingredients and macros before saving.`
  String get aiTextReviewNotice {
    return Intl.message(
      'AI creates an editable draft. You review ingredients and macros before saving.',
      name: 'aiTextReviewNotice',
      desc: '',
      args: [],
    );
  }

  /// `What did you eat`
  String get aiTextWhatDidYouEat {
    return Intl.message(
      'What did you eat',
      name: 'aiTextWhatDidYouEat',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get aiTextClear {
    return Intl.message(
      'Clear',
      name: 'aiTextClear',
      desc: '',
      args: [],
    );
  }

  /// `Example: 200 g chicken, 150 g rice, salad with olive oil, and a Greek yogurt`
  String get aiTextInputHint {
    return Intl.message(
      'Example: 200 g chicken, 150 g rice, salad with olive oil, and a Greek yogurt',
      name: 'aiTextInputHint',
      desc: '',
      args: [],
    );
  }

  /// `The more specific you are, the better the draft will be.`
  String get aiTextSpecificityHint {
    return Intl.message(
      'The more specific you are, the better the draft will be.',
      name: 'aiTextSpecificityHint',
      desc: '',
      args: [],
    );
  }

  /// `Quick examples`
  String get aiTextQuickExamples {
    return Intl.message(
      'Quick examples',
      name: 'aiTextQuickExamples',
      desc: '',
      args: [],
    );
  }

  /// `Simple breakfast`
  String get aiTextExampleSimpleBreakfastLabel {
    return Intl.message(
      'Simple breakfast',
      name: 'aiTextExampleSimpleBreakfastLabel',
      desc: '',
      args: [],
    );
  }

  /// `Coffee with milk, toast with tomato, and two eggs`
  String get aiTextExampleSimpleBreakfastValue {
    return Intl.message(
      'Coffee with milk, toast with tomato, and two eggs',
      name: 'aiTextExampleSimpleBreakfastValue',
      desc: '',
      args: [],
    );
  }

  /// `Meal with amounts`
  String get aiTextExampleAmountsLabel {
    return Intl.message(
      'Meal with amounts',
      name: 'aiTextExampleAmountsLabel',
      desc: '',
      args: [],
    );
  }

  /// `180 g salmon, 220 g roasted potato, and salad with 10 ml olive oil`
  String get aiTextExampleAmountsValue {
    return Intl.message(
      '180 g salmon, 220 g roasted potato, and salad with 10 ml olive oil',
      name: 'aiTextExampleAmountsValue',
      desc: '',
      args: [],
    );
  }

  /// `Quick dinner`
  String get aiTextExampleQuickDinnerLabel {
    return Intl.message(
      'Quick dinner',
      name: 'aiTextExampleQuickDinnerLabel',
      desc: '',
      args: [],
    );
  }

  /// `Chicken burrito with cheese, guacamole, and a Coke Zero`
  String get aiTextExampleQuickDinnerValue {
    return Intl.message(
      'Chicken burrito with cheese, guacamole, and a Coke Zero',
      name: 'aiTextExampleQuickDinnerValue',
      desc: '',
      args: [],
    );
  }

  /// `Create AI draft`
  String get aiTextCreateDraft {
    return Intl.message(
      'Create AI draft',
      name: 'aiTextCreateDraft',
      desc: '',
      args: [],
    );
  }

  /// `What works best?`
  String get aiTextBestPracticesTitle {
    return Intl.message(
      'What works best?',
      name: 'aiTextBestPracticesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Open this if you want better results.`
  String get aiTextBestPracticesSubtitle {
    return Intl.message(
      'Open this if you want better results.',
      name: 'aiTextBestPracticesSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Include amounts if you know them`
  String get aiTextHintAmountsTitle {
    return Intl.message(
      'Include amounts if you know them',
      name: 'aiTextHintAmountsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Grams, units, or tablespoons help estimate more accurately.`
  String get aiTextHintAmountsSubtitle {
    return Intl.message(
      'Grams, units, or tablespoons help estimate more accurately.',
      name: 'aiTextHintAmountsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Write the dish and the sides`
  String get aiTextHintDishTitle {
    return Intl.message(
      'Write the dish and the sides',
      name: 'aiTextHintDishTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do not write only "pasta"; better "pasta with tuna and tomato".`
  String get aiTextHintDishSubtitle {
    return Intl.message(
      'Do not write only "pasta"; better "pasta with tuna and tomato".',
      name: 'aiTextHintDishSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Do not forget drinks and sauces`
  String get aiTextHintSaucesTitle {
    return Intl.message(
      'Do not forget drinks and sauces',
      name: 'aiTextHintSaucesTitle',
      desc: '',
      args: [],
    );
  }

  /// `They often change the final calories quite a bit.`
  String get aiTextHintSaucesSubtitle {
    return Intl.message(
      'They often change the final calories quite a bit.',
      name: 'aiTextHintSaucesSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Analyzing ingredients and quantities`
  String get aiTextAnalyzingIngredients {
    return Intl.message(
      'Analyzing ingredients and quantities',
      name: 'aiTextAnalyzingIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Preparing image...`
  String get aiStatusPreparing {
    return Intl.message(
      'Preparing image...',
      name: 'aiStatusPreparing',
      desc: '',
      args: [],
    );
  }

  /// `Consulting AI...`
  String get aiStatusConsulting {
    return Intl.message(
      'Consulting AI...',
      name: 'aiStatusConsulting',
      desc: '',
      args: [],
    );
  }

  /// `Personalizing...`
  String get aiStatusPersonalizing {
    return Intl.message(
      'Personalizing...',
      name: 'aiStatusPersonalizing',
      desc: '',
      args: [],
    );
  }

  /// `Image is too large for remote AI. Local draft created.`
  String get aiErrorPayloadTooLarge {
    return Intl.message(
      'Image is too large for remote AI. Local draft created.',
      name: 'aiErrorPayloadTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `Remote AI is not configured in backend. Local draft created.`
  String get aiErrorMissingKey {
    return Intl.message(
      'Remote AI is not configured in backend. Local draft created.',
      name: 'aiErrorMissingKey',
      desc: '',
      args: [],
    );
  }

  /// `Remote AI quota/rate limit reached. Local draft created.`
  String get aiErrorQuotaExceeded {
    return Intl.message(
      'Remote AI quota/rate limit reached. Local draft created.',
      name: 'aiErrorQuotaExceeded',
      desc: '',
      args: [],
    );
  }

  /// `Image format not supported by remote AI. Try JPG/PNG. Local draft created.`
  String get aiErrorUnsupportedFormat {
    return Intl.message(
      'Image format not supported by remote AI. Try JPG/PNG. Local draft created.',
      name: 'aiErrorUnsupportedFormat',
      desc: '',
      args: [],
    );
  }

  /// `Remote image interpretation failed. Local draft created with memory support.`
  String get aiErrorGeneric {
    return Intl.message(
      'Remote image interpretation failed. Local draft created with memory support.',
      name: 'aiErrorGeneric',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get aiRetry {
    return Intl.message(
      'Retry',
      name: 'aiRetry',
      desc: '',
      args: [],
    );
  }

  /// `Edit {item}`
  String aiEditAmountTitle(Object item) {
    return Intl.message(
      'Edit $item',
      name: 'aiEditAmountTitle',
      desc: '',
      args: [item],
    );
  }

  /// `Quantity ({unit})`
  String aiQuantityUnitLabel(Object unit) {
    return Intl.message(
      'Quantity ($unit)',
      name: 'aiQuantityUnitLabel',
      desc: '',
      args: [unit],
    );
  }

  /// `Could not save draft changes`
  String get aiSaveDraftChangesError {
    return Intl.message(
      'Could not save draft changes',
      name: 'aiSaveDraftChangesError',
      desc: '',
      args: [],
    );
  }

  /// `Meal saved`
  String get aiMealSavedSuccess {
    return Intl.message(
      'Meal saved',
      name: 'aiMealSavedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Could not save this meal`
  String get aiMealSaveError {
    return Intl.message(
      'Could not save this meal',
      name: 'aiMealSaveError',
      desc: '',
      args: [],
    );
  }

  /// `Post-workout`
  String get aiGymLabelPostWorkout {
    return Intl.message(
      'Post-workout',
      name: 'aiGymLabelPostWorkout',
      desc: '',
      args: [],
    );
  }

  /// `Pre-workout`
  String get aiGymLabelPreWorkout {
    return Intl.message(
      'Pre-workout',
      name: 'aiGymLabelPreWorkout',
      desc: '',
      args: [],
    );
  }

  /// `High protein`
  String get aiGymLabelHighProtein {
    return Intl.message(
      'High protein',
      name: 'aiGymLabelHighProtein',
      desc: '',
      args: [],
    );
  }

  /// `Lean for definition`
  String get aiGymLabelLeanDefinition {
    return Intl.message(
      'Lean for definition',
      name: 'aiGymLabelLeanDefinition',
      desc: '',
      args: [],
    );
  }

  /// `Balanced`
  String get aiGymLabelBalanced {
    return Intl.message(
      'Balanced',
      name: 'aiGymLabelBalanced',
      desc: '',
      args: [],
    );
  }

  /// `Applied suggestion: {title}`
  String aiSuggestionApplied(Object title) {
    return Intl.message(
      'Applied suggestion: $title',
      name: 'aiSuggestionApplied',
      desc: '',
      args: [title],
    );
  }

  /// `Replaced by {source} to improve accuracy.`
  String aiReplacedBySummary(Object source) {
    return Intl.message(
      'Replaced by $source to improve accuracy.',
      name: 'aiReplacedBySummary',
      desc: '',
      args: [source],
    );
  }

  /// `Recipe saved`
  String get recipeSavedSnackbar {
    return Intl.message(
      'Recipe saved',
      name: 'recipeSavedSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `Captured photo`
  String get aiPhotoCaptured {
    return Intl.message(
      'Captured photo',
      name: 'aiPhotoCaptured',
      desc: '',
      args: [],
    );
  }

  /// `Tap to enlarge. Toggle crop/fit for quick inspection.`
  String get aiPhotoCapturedHint {
    return Intl.message(
      'Tap to enlarge. Toggle crop/fit for quick inspection.',
      name: 'aiPhotoCapturedHint',
      desc: '',
      args: [],
    );
  }

  /// `Could not load preview`
  String get aiPhotoPreviewError {
    return Intl.message(
      'Could not load preview',
      name: 'aiPhotoPreviewError',
      desc: '',
      args: [],
    );
  }

  /// `Crop`
  String get aiCropLabel {
    return Intl.message(
      'Crop',
      name: 'aiCropLabel',
      desc: '',
      args: [],
    );
  }

  /// `Fit`
  String get aiFitLabel {
    return Intl.message(
      'Fit',
      name: 'aiFitLabel',
      desc: '',
      args: [],
    );
  }

  /// `Photo zoom`
  String get aiPhotoZoomTitle {
    return Intl.message(
      'Photo zoom',
      name: 'aiPhotoZoomTitle',
      desc: '',
      args: [],
    );
  }

  /// `AI Photo`
  String get aiSourcePhoto {
    return Intl.message(
      'AI Photo',
      name: 'aiSourcePhoto',
      desc: '',
      args: [],
    );
  }

  /// `AI Text`
  String get aiSourceText {
    return Intl.message(
      'AI Text',
      name: 'aiSourceText',
      desc: '',
      args: [],
    );
  }

  /// `{count} ingredients`
  String aiIngredientsCount(Object count) {
    return Intl.message(
      '$count ingredients',
      name: 'aiIngredientsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Servings to save`
  String get aiServingsToSave {
    return Intl.message(
      'Servings to save',
      name: 'aiServingsToSave',
      desc: '',
      args: [],
    );
  }

  /// `Custom servings`
  String get aiCustomServingsLabel {
    return Intl.message(
      'Custom servings',
      name: 'aiCustomServingsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Adjust the final portion before saving.`
  String get aiCustomServingsHelper {
    return Intl.message(
      'Adjust the final portion before saving.',
      name: 'aiCustomServingsHelper',
      desc: '',
      args: [],
    );
  }

  /// `Your matches`
  String get aiYourMatches {
    return Intl.message(
      'Your matches',
      name: 'aiYourMatches',
      desc: '',
      args: [],
    );
  }

  /// `Use a frequent meal, recipe, or previous correction if it looks more like what you ate.`
  String get aiMatchesHint {
    return Intl.message(
      'Use a frequent meal, recipe, or previous correction if it looks more like what you ate.',
      name: 'aiMatchesHint',
      desc: '',
      args: [],
    );
  }

  /// `This is only a reference. It will never be added to your meal automatically.`
  String get aiMatchesReferenceHint {
    return Intl.message(
      'This is only a reference. It will never be added to your meal automatically.',
      name: 'aiMatchesReferenceHint',
      desc: '',
      args: [],
    );
  }

  /// `Use`
  String get aiButtonUse {
    return Intl.message(
      'Use',
      name: 'aiButtonUse',
      desc: '',
      args: [],
    );
  }

  /// `{count} servings ready to save`
  String aiServingsReady(Object count) {
    return Intl.message(
      '$count servings ready to save',
      name: 'aiServingsReady',
      desc: '',
      args: [count],
    );
  }

  /// `You have used the guest allowance. Protect your account to unlock {count} more free uses.`
  String aiTrialGuestAllowanceUsed(Object count) {
    return Intl.message(
      'You have used the guest allowance. Protect your account to unlock $count more free uses.',
      name: 'aiTrialGuestAllowanceUsed',
      desc: '',
      args: [count],
    );
  }

  /// `You have used your {count} AI trials.`
  String aiTrialLimitUsed(Object count) {
    return Intl.message(
      'You have used your $count AI trials.',
      name: 'aiTrialLimitUsed',
      desc: '',
      args: [count],
    );
  }

  /// `{count} free AI trials remaining.`
  String aiTrialRemaining(Object count) {
    return Intl.message(
      '$count free AI trials remaining.',
      name: 'aiTrialRemaining',
      desc: '',
      args: [count],
    );
  }

  /// `Google`
  String get aiTrialGoogleAction {
    return Intl.message(
      'Google',
      name: 'aiTrialGoogleAction',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade`
  String get aiTrialUpgradeAction {
    return Intl.message(
      'Upgrade',
      name: 'aiTrialUpgradeAction',
      desc: '',
      args: [],
    );
  }

  /// `Editable`
  String get aiEditableLabel {
    return Intl.message(
      'Editable',
      name: 'aiEditableLabel',
      desc: '',
      args: [],
    );
  }

  /// `Use habitual: {label}`
  String aiUseHabitual(Object label) {
    return Intl.message(
      'Use habitual: $label',
      name: 'aiUseHabitual',
      desc: '',
      args: [label],
    );
  }

  /// `Quick adjustment`
  String get aiQuickAdjustment {
    return Intl.message(
      'Quick adjustment',
      name: 'aiQuickAdjustment',
      desc: '',
      args: [],
    );
  }

  /// `Excluded from the final meal.`
  String get aiExcludeFromMeal {
    return Intl.message(
      'Excluded from the final meal.',
      name: 'aiExcludeFromMeal',
      desc: '',
      args: [],
    );
  }

  /// `High confidence`
  String get aiConfidenceHigh {
    return Intl.message(
      'High confidence',
      name: 'aiConfidenceHigh',
      desc: '',
      args: [],
    );
  }

  /// `Medium confidence`
  String get aiConfidenceMedium {
    return Intl.message(
      'Medium confidence',
      name: 'aiConfidenceMedium',
      desc: '',
      args: [],
    );
  }

  /// `Low confidence`
  String get aiConfidenceLow {
    return Intl.message(
      'Low confidence',
      name: 'aiConfidenceLow',
      desc: '',
      args: [],
    );
  }

  /// `This ingredient has low certainty. Your habitual correction is usually the fastest option.`
  String get aiConfidenceLowHint {
    return Intl.message(
      'This ingredient has low certainty. Your habitual correction is usually the fastest option.',
      name: 'aiConfidenceLowHint',
      desc: '',
      args: [],
    );
  }

  /// `This ingredient has low certainty. Check amount or replace it with a more precise food.`
  String get aiConfidenceLowGenericHint {
    return Intl.message(
      'This ingredient has low certainty. Check amount or replace it with a more precise food.',
      name: 'aiConfidenceLowGenericHint',
      desc: '',
      args: [],
    );
  }

  /// `The amount may vary. Check the portion if you see it doesn't fit the photo.`
  String get aiConfidenceMediumHint {
    return Intl.message(
      'The amount may vary. Check the portion if you see it doesn\'t fit the photo.',
      name: 'aiConfidenceMediumHint',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get aiRestoreLabel {
    return Intl.message(
      'Restore',
      name: 'aiRestoreLabel',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get aiRemoveLabel {
    return Intl.message(
      'Remove',
      name: 'aiRemoveLabel',
      desc: '',
      args: [],
    );
  }

  /// `Substitute`
  String get aiSubstituteLabel {
    return Intl.message(
      'Substitute',
      name: 'aiSubstituteLabel',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get aiAmountLabel {
    return Intl.message(
      'Amount',
      name: 'aiAmountLabel',
      desc: '',
      args: [],
    );
  }

  /// `Edit macros`
  String get aiEditMacrosTitle {
    return Intl.message(
      'Edit macros',
      name: 'aiEditMacrosTitle',
      desc: '',
      args: [],
    );
  }

  /// `Macros`
  String get aiEditMacrosLabel {
    return Intl.message(
      'Macros',
      name: 'aiEditMacrosLabel',
      desc: '',
      args: [],
    );
  }

  /// `High match`
  String get aiMatchHigh {
    return Intl.message(
      'High match',
      name: 'aiMatchHigh',
      desc: '',
      args: [],
    );
  }

  /// `Good match`
  String get aiMatchGood {
    return Intl.message(
      'Good match',
      name: 'aiMatchGood',
      desc: '',
      args: [],
    );
  }

  /// `Possible match`
  String get aiMatchPossible {
    return Intl.message(
      'Possible match',
      name: 'aiMatchPossible',
      desc: '',
      args: [],
    );
  }

  /// `Save some recipes and this section will start suggesting based on your training day.`
  String get macroSuggestionsEmpty {
    return Intl.message(
      'Save some recipes and this section will start suggesting based on your training day.',
      name: 'macroSuggestionsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Options for definition`
  String get macroSuggestionsTitleDef {
    return Intl.message(
      'Options for definition',
      name: 'macroSuggestionsTitleDef',
      desc: '',
      args: [],
    );
  }

  /// `Options for legs`
  String get macroSuggestionsTitleLeg {
    return Intl.message(
      'Options for legs',
      name: 'macroSuggestionsTitleLeg',
      desc: '',
      args: [],
    );
  }

  /// `Options for torso`
  String get macroSuggestionsTitleTorso {
    return Intl.message(
      'Options for torso',
      name: 'macroSuggestionsTitleTorso',
      desc: '',
      args: [],
    );
  }

  /// `Options for cardio`
  String get macroSuggestionsTitleCardio {
    return Intl.message(
      'Options for cardio',
      name: 'macroSuggestionsTitleCardio',
      desc: '',
      args: [],
    );
  }

  /// `Options for rest`
  String get macroSuggestionsTitleRest {
    return Intl.message(
      'Options for rest',
      name: 'macroSuggestionsTitleRest',
      desc: '',
      args: [],
    );
  }

  /// `Recommended meals to perform and recover better.`
  String get macroSuggestionsSubtitleGym {
    return Intl.message(
      'Recommended meals to perform and recover better.',
      name: 'macroSuggestionsSubtitleGym',
      desc: '',
      args: [],
    );
  }

  /// `High protein options with controlled calories.`
  String get macroSuggestionsSubtitleLoseWeight {
    return Intl.message(
      'High protein options with controlled calories.',
      name: 'macroSuggestionsSubtitleLoseWeight',
      desc: '',
      args: [],
    );
  }

  /// `Clean closings with high protein and no caloric excess.`
  String get macroSuggestionsSubtitleRest {
    return Intl.message(
      'Clean closings with high protein and no caloric excess.',
      name: 'macroSuggestionsSubtitleRest',
      desc: '',
      args: [],
    );
  }

  /// `Saved meals based on what you are still missing today.`
  String get macroSuggestionsSubtitleDefault {
    return Intl.message(
      'Saved meals based on what you are still missing today.',
      name: 'macroSuggestionsSubtitleDefault',
      desc: '',
      args: [],
    );
  }

  /// `Lean close for cut days: protein-first with calories kept tight.`
  String get macroSuggestionsRationaleCutClose {
    return Intl.message(
      'Lean close for cut days: protein-first with calories kept tight.',
      name: 'macroSuggestionsRationaleCutClose',
      desc: '',
      args: [],
    );
  }

  /// `Post-workout recovery hit with enough carbs and protein to reload.`
  String get macroSuggestionsRationalePostWorkout {
    return Intl.message(
      'Post-workout recovery hit with enough carbs and protein to reload.',
      name: 'macroSuggestionsRationalePostWorkout',
      desc: '',
      args: [],
    );
  }

  /// `Good pre-workout fuel: useful carbs without much digestive drag.`
  String get macroSuggestionsRationalePreWorkout {
    return Intl.message(
      'Good pre-workout fuel: useful carbs without much digestive drag.',
      name: 'macroSuggestionsRationalePreWorkout',
      desc: '',
      args: [],
    );
  }

  /// `Protein-first close to finish the day without guessing.`
  String get macroSuggestionsRationaleProteinClose {
    return Intl.message(
      'Protein-first close to finish the day without guessing.',
      name: 'macroSuggestionsRationaleProteinClose',
      desc: '',
      args: [],
    );
  }

  /// `Fast protein touch when you want something light and easy to log.`
  String get macroSuggestionsRationaleShakeLight {
    return Intl.message(
      'Fast protein touch when you want something light and easy to log.',
      name: 'macroSuggestionsRationaleShakeLight',
      desc: '',
      args: [],
    );
  }

  /// `Clean fit for the calories you still have left.`
  String get macroSuggestionsRationaleCalorieFit {
    return Intl.message(
      'Clean fit for the calories you still have left.',
      name: 'macroSuggestionsRationaleCalorieFit',
      desc: '',
      args: [],
    );
  }

  /// `Solid gym-friendly option that keeps the day moving in the right direction.`
  String get macroSuggestionsRationaleDefault {
    return Intl.message(
      'Solid gym-friendly option that keeps the day moving in the right direction.',
      name: 'macroSuggestionsRationaleDefault',
      desc: '',
      args: [],
    );
  }

  /// `{recipe} added to {slot}`
  String macroSuggestionsAddedTo(Object recipe, Object slot) {
    return Intl.message(
      '$recipe added to $slot',
      name: 'macroSuggestionsAddedTo',
      desc: '',
      args: [recipe, slot],
    );
  }

  /// `{count} portions`
  String macroSuggestionsServingsPortions(Object count) {
    return Intl.message(
      '$count portions',
      name: 'macroSuggestionsServingsPortions',
      desc: '',
      args: [count],
    );
  }

  /// `Cut-focused macro coach`
  String get macroCoachTitleCut {
    return Intl.message(
      'Cut-focused macro coach',
      name: 'macroCoachTitleCut',
      desc: '',
      args: [],
    );
  }

  /// `Leg day macro coach`
  String get macroCoachTitleLeg {
    return Intl.message(
      'Leg day macro coach',
      name: 'macroCoachTitleLeg',
      desc: '',
      args: [],
    );
  }

  /// `Upper body macro coach`
  String get macroCoachTitleUpper {
    return Intl.message(
      'Upper body macro coach',
      name: 'macroCoachTitleUpper',
      desc: '',
      args: [],
    );
  }

  /// `Cardio day macro coach`
  String get macroCoachTitleCardio {
    return Intl.message(
      'Cardio day macro coach',
      name: 'macroCoachTitleCardio',
      desc: '',
      args: [],
    );
  }

  /// `Today's macro coach`
  String get macroCoachTitleToday {
    return Intl.message(
      'Today\'s macro coach',
      name: 'macroCoachTitleToday',
      desc: '',
      args: [],
    );
  }

  /// `Premium adjusts real meals to your workout and remaining macros.`
  String get macroCoachSubtitleTraining {
    return Intl.message(
      'Premium adjusts real meals to your workout and remaining macros.',
      name: 'macroCoachSubtitleTraining',
      desc: '',
      args: [],
    );
  }

  /// `Close the day with high protein and controlled calories.`
  String get macroCoachSubtitleCut {
    return Intl.message(
      'Close the day with high protein and controlled calories.',
      name: 'macroCoachSubtitleCut',
      desc: '',
      args: [],
    );
  }

  /// `Light options to keep adherence without overshooting.`
  String get macroCoachSubtitleRest {
    return Intl.message(
      'Light options to keep adherence without overshooting.',
      name: 'macroCoachSubtitleRest',
      desc: '',
      args: [],
    );
  }

  /// `Choose what to eat now based on what is left today.`
  String get macroCoachSubtitleDefault {
    return Intl.message(
      'Choose what to eat now based on what is left today.',
      name: 'macroCoachSubtitleDefault',
      desc: '',
      args: [],
    );
  }

  /// `Teriyaki chicken with broccoli`
  String get macroCoachPreviewChicken {
    return Intl.message(
      'Teriyaki chicken with broccoli',
      name: 'macroCoachPreviewChicken',
      desc: '',
      args: [],
    );
  }

  /// `Spinach and turkey omelette`
  String get macroCoachPreviewOmelette {
    return Intl.message(
      'Spinach and turkey omelette',
      name: 'macroCoachPreviewOmelette',
      desc: '',
      args: [],
    );
  }

  /// `Premium suggestions`
  String get macroCoachLockedTitle {
    return Intl.message(
      'Premium suggestions',
      name: 'macroCoachLockedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Personalized suggestions tailored to your remaining macros.`
  String get macroCoachLockedSubtitle {
    return Intl.message(
      'Personalized suggestions tailored to your remaining macros.',
      name: 'macroCoachLockedSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Unlock coach`
  String get macroCoachUnlockAction {
    return Intl.message(
      'Unlock coach',
      name: 'macroCoachUnlockAction',
      desc: '',
      args: [],
    );
  }

  /// `Gym nutrition`
  String get homeDashboardTitle {
    return Intl.message(
      'Gym nutrition',
      name: 'homeDashboardTitle',
      desc: '',
      args: [],
    );
  }

  /// `Today at a glance.`
  String get homeDashboardSubtitle {
    return Intl.message(
      'Today at a glance.',
      name: 'homeDashboardSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Log a meal or workout to unlock better guidance.`
  String get homeDashboardEmpty {
    return Intl.message(
      'Log a meal or workout to unlock better guidance.',
      name: 'homeDashboardEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Goal`
  String get homeDashboardGoalLabel {
    return Intl.message(
      'Goal',
      name: 'homeDashboardGoalLabel',
      desc: '',
      args: [],
    );
  }

  /// `Focus`
  String get homeDashboardFocusLabel {
    return Intl.message(
      'Focus',
      name: 'homeDashboardFocusLabel',
      desc: '',
      args: [],
    );
  }

  /// `{count} meals`
  String homeDashboardMealsChip(Object count) {
    return Intl.message(
      '$count meals',
      name: 'homeDashboardMealsChip',
      desc: '',
      args: [count],
    );
  }

  /// `{count} burned`
  String homeDashboardBurnedChip(Object count) {
    return Intl.message(
      '$count burned',
      name: 'homeDashboardBurnedChip',
      desc: '',
      args: [count],
    );
  }

  /// `{count} sessions`
  String homeDashboardSessionsChip(Object count) {
    return Intl.message(
      '$count sessions',
      name: 'homeDashboardSessionsChip',
      desc: '',
      args: [count],
    );
  }

  /// `Protein left`
  String get homeDashboardProteinRemaining {
    return Intl.message(
      'Protein left',
      name: 'homeDashboardProteinRemaining',
      desc: '',
      args: [],
    );
  }

  /// `Kcal left`
  String get homeDashboardKcalRemaining {
    return Intl.message(
      'Kcal left',
      name: 'homeDashboardKcalRemaining',
      desc: '',
      args: [],
    );
  }

  /// `Over goal`
  String get homeDashboardOverGoal {
    return Intl.message(
      'Over goal',
      name: 'homeDashboardOverGoal',
      desc: '',
      args: [],
    );
  }

  /// `No food quality data yet.`
  String get homeDashboardNoFoodQualityData {
    return Intl.message(
      'No food quality data yet.',
      name: 'homeDashboardNoFoodQualityData',
      desc: '',
      args: [],
    );
  }

  /// `Daily average across {count} meals`
  String homeDashboardFoodQualityAverage(Object count) {
    return Intl.message(
      'Daily average across $count meals',
      name: 'homeDashboardFoodQualityAverage',
      desc: '',
      args: [count],
    );
  }

  /// `Today actions`
  String get homeTodayActionsTitle {
    return Intl.message(
      'Today actions',
      name: 'homeTodayActionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Suggestions and ready meals to close macros without friction.`
  String get homeTodayActionsSubtitle {
    return Intl.message(
      'Suggestions and ready meals to close macros without friction.',
      name: 'homeTodayActionsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Tracking`
  String get homeTrackingTitle {
    return Intl.message(
      'Tracking',
      name: 'homeTrackingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Adherence, progress, and trends for better adjustments.`
  String get homeTrackingSubtitle {
    return Intl.message(
      'Adherence, progress, and trends for better adjustments.',
      name: 'homeTrackingSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Daily board`
  String get homeDailyBoardTitle {
    return Intl.message(
      'Daily board',
      name: 'homeDailyBoardTitle',
      desc: '',
      args: [],
    );
  }

  /// `Change focus`
  String get homeChangeFocusTooltip {
    return Intl.message(
      'Change focus',
      name: 'homeChangeFocusTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Change goal`
  String get homeChangeGoalTooltip {
    return Intl.message(
      'Change goal',
      name: 'homeChangeGoalTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Legs`
  String get homeFocusLowerBody {
    return Intl.message(
      'Legs',
      name: 'homeFocusLowerBody',
      desc: '',
      args: [],
    );
  }

  /// `Upper`
  String get homeFocusUpperBody {
    return Intl.message(
      'Upper',
      name: 'homeFocusUpperBody',
      desc: '',
      args: [],
    );
  }

  /// `Cardio`
  String get homeFocusCardio {
    return Intl.message(
      'Cardio',
      name: 'homeFocusCardio',
      desc: '',
      args: [],
    );
  }

  /// `Rest`
  String get homeFocusRest {
    return Intl.message(
      'Rest',
      name: 'homeFocusRest',
      desc: '',
      args: [],
    );
  }

  /// `Working with a nutritionist?`
  String get homeNutritionistPromoTitle {
    return Intl.message(
      'Working with a nutritionist?',
      name: 'homeNutritionistPromoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sync macros, get tailored meal guides, and chat directly with your professional.`
  String get homeNutritionistPromoSubtitle {
    return Intl.message(
      'Sync macros, get tailored meal guides, and chat directly with your professional.',
      name: 'homeNutritionistPromoSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Connect account`
  String get homeNutritionistPromoAction {
    return Intl.message(
      'Connect account',
      name: 'homeNutritionistPromoAction',
      desc: '',
      args: [],
    );
  }

  /// `{amount}g left`
  String homeDashboardMacroRemaining(Object amount) {
    return Intl.message(
      '${amount}g left',
      name: 'homeDashboardMacroRemaining',
      desc: '',
      args: [amount],
    );
  }

  /// `Start logging your day!`
  String get homeDashboardEmptyTitle {
    return Intl.message(
      'Start logging your day!',
      name: 'homeDashboardEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Take a photo of your meal and AI does the rest.`
  String get homeDashboardEmptySubtitle {
    return Intl.message(
      'Take a photo of your meal and AI does the rest.',
      name: 'homeDashboardEmptySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Take AI photo`
  String get homeDashboardEmptyAction {
    return Intl.message(
      'Take AI photo',
      name: 'homeDashboardEmptyAction',
      desc: '',
      args: [],
    );
  }

  /// `{current} of {goal} kcal`
  String homeDashboardKcalProgress(Object current, Object goal) {
    return Intl.message(
      '$current of $goal kcal',
      name: 'homeDashboardKcalProgress',
      desc: '',
      args: [current, goal],
    );
  }

  /// `Goal reached`
  String get homeDashboardMacroDone {
    return Intl.message(
      'Goal reached',
      name: 'homeDashboardMacroDone',
      desc: '',
      args: [],
    );
  }

  /// `Definition on track. Keep the last meal high in protein.`
  String get homeDashboardStatusDefClosing {
    return Intl.message(
      'Definition on track. Keep the last meal high in protein.',
      name: 'homeDashboardStatusDefClosing',
      desc: '',
      args: [],
    );
  }

  /// `You still have room. Add easy carbs and protein.`
  String get homeDashboardStatusBulkOpen {
    return Intl.message(
      'You still have room. Add easy carbs and protein.',
      name: 'homeDashboardStatusBulkOpen',
      desc: '',
      args: [],
    );
  }

  /// `Protein is still the main gap. Prioritize it next meal.`
  String get homeDashboardStatusProteinGap {
    return Intl.message(
      'Protein is still the main gap. Prioritize it next meal.',
      name: 'homeDashboardStatusProteinGap',
      desc: '',
      args: [],
    );
  }

  /// `You still have carb room. Good moment for training fuel.`
  String get homeDashboardStatusCarbWindow {
    return Intl.message(
      'You still have carb room. Good moment for training fuel.',
      name: 'homeDashboardStatusCarbWindow',
      desc: '',
      args: [],
    );
  }

  /// `Rest day almost closed. Finish light and protein-first.`
  String get homeDashboardStatusRestClosing {
    return Intl.message(
      'Rest day almost closed. Finish light and protein-first.',
      name: 'homeDashboardStatusRestClosing',
      desc: '',
      args: [],
    );
  }

  /// `You are above target. Keep the rest of the day tighter.`
  String get homeDashboardStatusOverGoal {
    return Intl.message(
      'You are above target. Keep the rest of the day tighter.',
      name: 'homeDashboardStatusOverGoal',
      desc: '',
      args: [],
    );
  }

  /// `Good pace. Keep it simple and close the day clean.`
  String get homeDashboardStatusDefault {
    return Intl.message(
      'Good pace. Keep it simple and close the day clean.',
      name: 'homeDashboardStatusDefault',
      desc: '',
      args: [],
    );
  }

  /// `Add water`
  String get hydrationAddWater {
    return Intl.message(
      'Add water',
      name: 'hydrationAddWater',
      desc: '',
      args: [],
    );
  }

  /// `Remove water`
  String get hydrationRemoveWater {
    return Intl.message(
      'Remove water',
      name: 'hydrationRemoveWater',
      desc: '',
      args: [],
    );
  }

  /// `Goal reached!`
  String get hydrationGoalReached {
    return Intl.message(
      'Goal reached!',
      name: 'hydrationGoalReached',
      desc: '',
      args: [],
    );
  }

  /// `Hydration`
  String get hydrationTitle {
    return Intl.message(
      'Hydration',
      name: 'hydrationTitle',
      desc: '',
      args: [],
    );
  }

  /// `+250 ml of water registered`
  String get mainWaterAddedSnack {
    return Intl.message(
      '+250 ml of water registered',
      name: 'mainWaterAddedSnack',
      desc: '',
      args: [],
    );
  }

  /// `Meal by text`
  String get aiTextCaptureTitle {
    return Intl.message(
      'Meal by text',
      name: 'aiTextCaptureTitle',
      desc: '',
      args: [],
    );
  }

  /// `Example: 2 eggs, toast with butter and coffee with milk`
  String get aiTextCaptureHint {
    return Intl.message(
      'Example: 2 eggs, toast with butter and coffee with milk',
      name: 'aiTextCaptureHint',
      desc: '',
      args: [],
    );
  }

  /// `Interpret meal`
  String get aiTextCaptureButton {
    return Intl.message(
      'Interpret meal',
      name: 'aiTextCaptureButton',
      desc: '',
      args: [],
    );
  }

  /// `Interpreting...`
  String get aiTextCaptureLoading {
    return Intl.message(
      'Interpreting...',
      name: 'aiTextCaptureLoading',
      desc: '',
      args: [],
    );
  }

  /// `Describe the meal naturally. The text can be processed remotely to estimate ingredients and macros, and you will always review the draft before saving.`
  String get aiTextCaptureDescription {
    return Intl.message(
      'Describe the meal naturally. The text can be processed remotely to estimate ingredients and macros, and you will always review the draft before saving.',
      name: 'aiTextCaptureDescription',
      desc: '',
      args: [],
    );
  }

  /// `Remote interpretation not available. Local draft created with memory support.`
  String get aiTextCaptureError {
    return Intl.message(
      'Remote interpretation not available. Local draft created with memory support.',
      name: 'aiTextCaptureError',
      desc: '',
      args: [],
    );
  }

  /// `Replace ingredient`
  String get aiReplaceTitle {
    return Intl.message(
      'Replace ingredient',
      name: 'aiReplaceTitle',
      desc: '',
      args: [],
    );
  }

  /// `Search for food`
  String get aiReplaceHint {
    return Intl.message(
      'Search for food',
      name: 'aiReplaceHint',
      desc: '',
      args: [],
    );
  }

  /// `Search for a food to replace this ingredient.`
  String get aiReplaceEmpty {
    return Intl.message(
      'Search for a food to replace this ingredient.',
      name: 'aiReplaceEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Enter at least 2 characters.`
  String get aiReplaceMinLength {
    return Intl.message(
      'Enter at least 2 characters.',
      name: 'aiReplaceMinLength',
      desc: '',
      args: [],
    );
  }

  /// `No results found.`
  String get aiReplaceNoResults {
    return Intl.message(
      'No results found.',
      name: 'aiReplaceNoResults',
      desc: '',
      args: [],
    );
  }

  /// `Cannot search for food right now.`
  String get aiReplaceError {
    return Intl.message(
      'Cannot search for food right now.',
      name: 'aiReplaceError',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Insights`
  String get weeklyInsightsTitle {
    return Intl.message(
      'Weekly Insights',
      name: 'weeklyInsightsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Could not load weekly insights.`
  String get weeklyInsightsError {
    return Intl.message(
      'Could not load weekly insights.',
      name: 'weeklyInsightsError',
      desc: '',
      args: [],
    );
  }

  /// `Summary`
  String get weeklyInsightsSummary {
    return Intl.message(
      'Summary',
      name: 'weeklyInsightsSummary',
      desc: '',
      args: [],
    );
  }

  /// `Smart Weekly Checkup`
  String get weeklyInsightsCheckup {
    return Intl.message(
      'Smart Weekly Checkup',
      name: 'weeklyInsightsCheckup',
      desc: '',
      args: [],
    );
  }

  /// `Weight trend: {delta} kg/week`
  String weeklyInsightsTrend(Object delta) {
    return Intl.message(
      'Weight trend: $delta kg/week',
      name: 'weeklyInsightsTrend',
      desc: '',
      args: [delta],
    );
  }

  /// `Apply {delta} kcal/day`
  String weeklyInsightsApplyAdjustment(Object delta) {
    return Intl.message(
      'Apply $delta kcal/day',
      name: 'weeklyInsightsApplyAdjustment',
      desc: '',
      args: [delta],
    );
  }

  /// `Weekly Averages`
  String get weeklyInsightsAverages {
    return Intl.message(
      'Weekly Averages',
      name: 'weeklyInsightsAverages',
      desc: '',
      args: [],
    );
  }

  /// `Adherence`
  String get weeklyInsightsAdherence {
    return Intl.message(
      'Adherence',
      name: 'weeklyInsightsAdherence',
      desc: '',
      args: [],
    );
  }

  /// `Protein Consistency`
  String get weeklyInsightsProteinConsistency {
    return Intl.message(
      'Protein Consistency',
      name: 'weeklyInsightsProteinConsistency',
      desc: '',
      args: [],
    );
  }

  /// `Weekly summary`
  String get weeklyInsightsWeeklySummary {
    return Intl.message(
      'Weekly summary',
      name: 'weeklyInsightsWeeklySummary',
      desc: '',
      args: [],
    );
  }

  /// `Weight trend`
  String get weeklyInsightsWeightTrendLabel {
    return Intl.message(
      'Weight trend',
      name: 'weeklyInsightsWeightTrendLabel',
      desc: '',
      args: [],
    );
  }

  /// `Weekly change`
  String get weeklyInsightsWeeklyChangeLabel {
    return Intl.message(
      'Weekly change',
      name: 'weeklyInsightsWeeklyChangeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Daily averages`
  String get weeklyInsightsDailyAverages {
    return Intl.message(
      'Daily averages',
      name: 'weeklyInsightsDailyAverages',
      desc: '',
      args: [],
    );
  }

  /// `Calorie intake`
  String get weeklyInsightsCalorieIntake {
    return Intl.message(
      'Calorie intake',
      name: 'weeklyInsightsCalorieIntake',
      desc: '',
      args: [],
    );
  }

  /// `day`
  String get weeklyInsightsPerDay {
    return Intl.message(
      'day',
      name: 'weeklyInsightsPerDay',
      desc: '',
      args: [],
    );
  }

  /// `Prot`
  String get weeklyInsightsProteinShort {
    return Intl.message(
      'Prot',
      name: 'weeklyInsightsProteinShort',
      desc: '',
      args: [],
    );
  }

  /// `Carb`
  String get weeklyInsightsCarbShort {
    return Intl.message(
      'Carb',
      name: 'weeklyInsightsCarbShort',
      desc: '',
      args: [],
    );
  }

  /// `Fat`
  String get weeklyInsightsFatShort {
    return Intl.message(
      'Fat',
      name: 'weeklyInsightsFatShort',
      desc: '',
      args: [],
    );
  }

  /// `days`
  String get weeklyInsightsDaysSuffix {
    return Intl.message(
      'days',
      name: 'weeklyInsightsDaysSuffix',
      desc: '',
      args: [],
    );
  }

  /// `Periods of overeating`
  String get weeklyInsightsOvereatingPeriods {
    return Intl.message(
      'Periods of overeating',
      name: 'weeklyInsightsOvereatingPeriods',
      desc: '',
      args: [],
    );
  }

  /// `Days met`
  String get weeklyInsightsDaysMet {
    return Intl.message(
      'Days met',
      name: 'weeklyInsightsDaysMet',
      desc: '',
      args: [],
    );
  }

  /// `Protein cons.`
  String get weeklyInsightsProteinConsistencyShort {
    return Intl.message(
      'Protein cons.',
      name: 'weeklyInsightsProteinConsistencyShort',
      desc: '',
      args: [],
    );
  }

  /// `Consistent days`
  String get weeklyInsightsConsistentDays {
    return Intl.message(
      'Consistent days',
      name: 'weeklyInsightsConsistentDays',
      desc: '',
      args: [],
    );
  }

  /// `{count} times`
  String weeklyInsightsMealCountTimes(Object count) {
    return Intl.message(
      '$count times',
      name: 'weeklyInsightsMealCountTimes',
      desc: '',
      args: [count],
    );
  }

  /// `Smart adjustment recommendation`
  String get weeklyInsightsSmartAdjustmentRecommendation {
    return Intl.message(
      'Smart adjustment recommendation',
      name: 'weeklyInsightsSmartAdjustmentRecommendation',
      desc: '',
      args: [],
    );
  }

  /// `New daily target`
  String get weeklyInsightsNewDailyTarget {
    return Intl.message(
      'New daily target',
      name: 'weeklyInsightsNewDailyTarget',
      desc: '',
      args: [],
    );
  }

  /// `Your weight trends and intake indicate you should adjust your daily calories. Premium calculates the exact change and applies it automatically.`
  String get weeklyInsightsLockedAdjustmentBody {
    return Intl.message(
      'Your weight trends and intake indicate you should adjust your daily calories. Premium calculates the exact change and applies it automatically.',
      name: 'weeklyInsightsLockedAdjustmentBody',
      desc: '',
      args: [],
    );
  }

  /// `Reveal recommended adjustment`
  String get weeklyInsightsRevealAdjustment {
    return Intl.message(
      'Reveal recommended adjustment',
      name: 'weeklyInsightsRevealAdjustment',
      desc: '',
      args: [],
    );
  }

  /// `Summary copied to clipboard successfully.`
  String get weeklyShareCopiedSnackbar {
    return Intl.message(
      'Summary copied to clipboard successfully.',
      name: 'weeklyShareCopiedSnackbar',
      desc: '',
      args: [],
    );
  }

  /// `My weekly progress on MacroTracker`
  String get weeklyShareImageText {
    return Intl.message(
      'My weekly progress on MacroTracker',
      name: 'weeklyShareImageText',
      desc: '',
      args: [],
    );
  }

  /// `Could not generate the progress card image.`
  String get weeklyShareImageError {
    return Intl.message(
      'Could not generate the progress card image.',
      name: 'weeklyShareImageError',
      desc: '',
      args: [],
    );
  }

  /// `Share progress`
  String get weeklyShareTitle {
    return Intl.message(
      'Share progress',
      name: 'weeklyShareTitle',
      desc: '',
      args: [],
    );
  }

  /// `Copy text`
  String get weeklyShareCopyText {
    return Intl.message(
      'Copy text',
      name: 'weeklyShareCopyText',
      desc: '',
      args: [],
    );
  }

  /// `Share card`
  String get weeklyShareShareCard {
    return Intl.message(
      'Share card',
      name: 'weeklyShareShareCard',
      desc: '',
      args: [],
    );
  }

  /// `DAILY AVERAGE`
  String get weeklyShareCardDailyAverageUpper {
    return Intl.message(
      'DAILY AVERAGE',
      name: 'weeklyShareCardDailyAverageUpper',
      desc: '',
      args: [],
    );
  }

  /// `kcal / day`
  String get weeklyShareCardKcalPerDay {
    return Intl.message(
      'kcal / day',
      name: 'weeklyShareCardKcalPerDay',
      desc: '',
      args: [],
    );
  }

  /// `PROTEIN`
  String get weeklyShareCardProteinUpper {
    return Intl.message(
      'PROTEIN',
      name: 'weeklyShareCardProteinUpper',
      desc: '',
      args: [],
    );
  }

  /// `CARBS`
  String get weeklyShareCardCarbsUpper {
    return Intl.message(
      'CARBS',
      name: 'weeklyShareCardCarbsUpper',
      desc: '',
      args: [],
    );
  }

  /// `FAT`
  String get weeklyShareCardFatUpper {
    return Intl.message(
      'FAT',
      name: 'weeklyShareCardFatUpper',
      desc: '',
      args: [],
    );
  }

  /// `GOAL ADHERENCE`
  String get weeklyShareCardGoalAdherenceUpper {
    return Intl.message(
      'GOAL ADHERENCE',
      name: 'weeklyShareCardGoalAdherenceUpper',
      desc: '',
      args: [],
    );
  }

  /// `{count} of 7 days logged`
  String weeklyShareCardDaysLogged(Object count) {
    return Intl.message(
      '$count of 7 days logged',
      name: 'weeklyShareCardDaysLogged',
      desc: '',
      args: [count],
    );
  }

  /// `PROTEIN CONS.`
  String get weeklyShareCardProteinConsistencyUpper {
    return Intl.message(
      'PROTEIN CONS.',
      name: 'weeklyShareCardProteinConsistencyUpper',
      desc: '',
      args: [],
    );
  }

  /// `WEIGHT CHANGE`
  String get weeklyShareCardWeightChangeUpper {
    return Intl.message(
      'WEIGHT CHANGE',
      name: 'weeklyShareCardWeightChangeUpper',
      desc: '',
      args: [],
    );
  }

  /// `MY WEEKLY TRACKING WITH MACROTRACKER`
  String get weeklyShareCardFooter {
    return Intl.message(
      'MY WEEKLY TRACKING WITH MACROTRACKER',
      name: 'weeklyShareCardFooter',
      desc: '',
      args: [],
    );
  }

  /// `My weekly progress (MacroTracker)`
  String get weeklyShareTextReportTitle {
    return Intl.message(
      'My weekly progress (MacroTracker)',
      name: 'weeklyShareTextReportTitle',
      desc: '',
      args: [],
    );
  }

  /// `Range`
  String get weeklyShareTextReportRange {
    return Intl.message(
      'Range',
      name: 'weeklyShareTextReportRange',
      desc: '',
      args: [],
    );
  }

  /// `Average calories`
  String get weeklyShareTextReportAverageCalories {
    return Intl.message(
      'Average calories',
      name: 'weeklyShareTextReportAverageCalories',
      desc: '',
      args: [],
    );
  }

  /// `Average protein`
  String get weeklyShareTextReportAverageProtein {
    return Intl.message(
      'Average protein',
      name: 'weeklyShareTextReportAverageProtein',
      desc: '',
      args: [],
    );
  }

  /// `Average carbs`
  String get weeklyShareTextReportAverageCarbs {
    return Intl.message(
      'Average carbs',
      name: 'weeklyShareTextReportAverageCarbs',
      desc: '',
      args: [],
    );
  }

  /// `Average fat`
  String get weeklyShareTextReportAverageFat {
    return Intl.message(
      'Average fat',
      name: 'weeklyShareTextReportAverageFat',
      desc: '',
      args: [],
    );
  }

  /// `Goal adherence`
  String get weeklyShareTextReportGoalAdherence {
    return Intl.message(
      'Goal adherence',
      name: 'weeklyShareTextReportGoalAdherence',
      desc: '',
      args: [],
    );
  }

  /// `Protein consistency`
  String get weeklyShareTextReportProteinConsistency {
    return Intl.message(
      'Protein consistency',
      name: 'weeklyShareTextReportProteinConsistency',
      desc: '',
      args: [],
    );
  }

  /// `Days tracked`
  String get weeklyShareTextReportDaysTracked {
    return Intl.message(
      'Days tracked',
      name: 'weeklyShareTextReportDaysTracked',
      desc: '',
      args: [],
    );
  }

  /// `Weight change`
  String get weeklyShareTextReportWeightDelta {
    return Intl.message(
      'Weight change',
      name: 'weeklyShareTextReportWeightDelta',
      desc: '',
      args: [],
    );
  }

  /// `day`
  String get weeklyShareTextReportDayUnit {
    return Intl.message(
      'day',
      name: 'weeklyShareTextReportDayUnit',
      desc: '',
      args: [],
    );
  }

  /// `Sent from MacroTracker.`
  String get weeklyShareTextReportFooter {
    return Intl.message(
      'Sent from MacroTracker.',
      name: 'weeklyShareTextReportFooter',
      desc: '',
      args: [],
    );
  }

  /// `{percent}% of registered days`
  String weeklyInsightsRegisteredDays(Object percent) {
    return Intl.message(
      '$percent% of registered days',
      name: 'weeklyInsightsRegisteredDays',
      desc: '',
      args: [percent],
    );
  }

  /// `Most Frequent Meals`
  String get weeklyInsightsTopMeals {
    return Intl.message(
      'Most Frequent Meals',
      name: 'weeklyInsightsTopMeals',
      desc: '',
      args: [],
    );
  }

  /// `No repeated meals detected this week.`
  String get weeklyInsightsNoFrequentMeals {
    return Intl.message(
      'No repeated meals detected this week.',
      name: 'weeklyInsightsNoFrequentMeals',
      desc: '',
      args: [],
    );
  }

  /// `Overeating Pattern`
  String get weeklyInsightsOvereatingPattern {
    return Intl.message(
      'Overeating Pattern',
      name: 'weeklyInsightsOvereatingPattern',
      desc: '',
      args: [],
    );
  }

  /// `Coverage`
  String get weeklyInsightsCoverage {
    return Intl.message(
      'Coverage',
      name: 'weeklyInsightsCoverage',
      desc: '',
      args: [],
    );
  }

  /// `{count} days registered this week`
  String weeklyInsightsTrackedDays(Object count) {
    return Intl.message(
      '$count days registered this week',
      name: 'weeklyInsightsTrackedDays',
      desc: '',
      args: [count],
    );
  }

  /// `Daily adjustment updated to {kcal} kcal.`
  String weeklyInsightsAdjustmentSuccess(Object kcal) {
    return Intl.message(
      'Daily adjustment updated to $kcal kcal.',
      name: 'weeklyInsightsAdjustmentSuccess',
      desc: '',
      args: [kcal],
    );
  }

  /// `Activate this section with an invite and consent. Here you will see plan, follow-up, privacy, and messages.`
  String get professionalSectionConnectSubtitle {
    return Intl.message(
      'Activate this section with an invite and consent. Here you will see plan, follow-up, privacy, and messages.',
      name: 'professionalSectionConnectSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `This is where you control your plan, real follow-up, shared privacy, and professional notes.`
  String get professionalSectionConnectedSubtitle {
    return Intl.message(
      'This is where you control your plan, real follow-up, shared privacy, and professional notes.',
      name: 'professionalSectionConnectedSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Could not load the full section`
  String get professionalSectionLoadErrorTitle {
    return Intl.message(
      'Could not load the full section',
      name: 'professionalSectionLoadErrorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Try refreshing again.`
  String get professionalSectionRetryHint {
    return Intl.message(
      'Try refreshing again.',
      name: 'professionalSectionRetryHint',
      desc: '',
      args: [],
    );
  }

  /// `Current shared data level`
  String get professionalPrivacyCurrentLevel {
    return Intl.message(
      'Current shared data level',
      name: 'professionalPrivacyCurrentLevel',
      desc: '',
      args: [],
    );
  }

  /// `Revoke access now`
  String get professionalRevokeNow {
    return Intl.message(
      'Revoke access now',
      name: 'professionalRevokeNow',
      desc: '',
      args: [],
    );
  }

  /// `Connected, no plan published`
  String get professionalConnectedNoPlan {
    return Intl.message(
      'Connected, no plan published',
      name: 'professionalConnectedNoPlan',
      desc: '',
      args: [],
    );
  }

  /// `Invite only`
  String get professionalStatusInviteOnly {
    return Intl.message(
      'Invite only',
      name: 'professionalStatusInviteOnly',
      desc: '',
      args: [],
    );
  }

  /// `Connected`
  String get professionalStatusConnected {
    return Intl.message(
      'Connected',
      name: 'professionalStatusConnected',
      desc: '',
      args: [],
    );
  }

  /// `Summary`
  String get professionalTabSummary {
    return Intl.message(
      'Summary',
      name: 'professionalTabSummary',
      desc: '',
      args: [],
    );
  }

  /// `Active plan`
  String get professionalSummaryActivePlan {
    return Intl.message(
      'Active plan',
      name: 'professionalSummaryActivePlan',
      desc: '',
      args: [],
    );
  }

  /// `No plan`
  String get professionalSummaryNoPlan {
    return Intl.message(
      'No plan',
      name: 'professionalSummaryNoPlan',
      desc: '',
      args: [],
    );
  }

  /// `Today target`
  String get professionalSummaryTodayTarget {
    return Intl.message(
      'Today target',
      name: 'professionalSummaryTodayTarget',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get professionalSummaryPending {
    return Intl.message(
      'Pending',
      name: 'professionalSummaryPending',
      desc: '',
      args: [],
    );
  }

  /// `Offline queue`
  String get professionalSummaryOfflineQueue {
    return Intl.message(
      'Offline queue',
      name: 'professionalSummaryOfflineQueue',
      desc: '',
      args: [],
    );
  }

  /// `Operations`
  String get professionalSummaryOperationsEyebrow {
    return Intl.message(
      'Operations',
      name: 'professionalSummaryOperationsEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `Active plan, today target, and sync status.`
  String get professionalSummaryOperationsSubtitle {
    return Intl.message(
      'Active plan, today target, and sync status.',
      name: 'professionalSummaryOperationsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Today plan vs reality`
  String get professionalSummaryTodayPlanVsReality {
    return Intl.message(
      'Today plan vs reality',
      name: 'professionalSummaryTodayPlanVsReality',
      desc: '',
      args: [],
    );
  }

  /// `Daily context note`
  String get professionalSummaryDailyContextTitle {
    return Intl.message(
      'Daily context note',
      name: 'professionalSummaryDailyContextTitle',
      desc: '',
      args: [],
    );
  }

  /// `Share details of your day (energy, digestion, events) with your nutritionist.`
  String get professionalSummaryDailyContextSubtitle {
    return Intl.message(
      'Share details of your day (energy, digestion, events) with your nutritionist.',
      name: 'professionalSummaryDailyContextSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Write your note here...`
  String get professionalSummaryDailyContextHint {
    return Intl.message(
      'Write your note here...',
      name: 'professionalSummaryDailyContextHint',
      desc: '',
      args: [],
    );
  }

  /// `Undo`
  String get professionalSummaryUndo {
    return Intl.message(
      'Undo',
      name: 'professionalSummaryUndo',
      desc: '',
      args: [],
    );
  }

  /// `Saving...`
  String get professionalSummarySavingNote {
    return Intl.message(
      'Saving...',
      name: 'professionalSummarySavingNote',
      desc: '',
      args: [],
    );
  }

  /// `Save note`
  String get professionalSummarySaveNote {
    return Intl.message(
      'Save note',
      name: 'professionalSummarySaveNote',
      desc: '',
      args: [],
    );
  }

  /// `Target exceeded`
  String get professionalSummaryTargetExceeded {
    return Intl.message(
      'Target exceeded',
      name: 'professionalSummaryTargetExceeded',
      desc: '',
      args: [],
    );
  }

  /// `Remaining kcal`
  String get professionalSummaryRemainingKcal {
    return Intl.message(
      'Remaining kcal',
      name: 'professionalSummaryRemainingKcal',
      desc: '',
      args: [],
    );
  }

  /// `Daily progress compared to targets assigned by your nutritionist.`
  String get professionalSummaryCalorieProgressBody {
    return Intl.message(
      'Daily progress compared to targets assigned by your nutritionist.',
      name: 'professionalSummaryCalorieProgressBody',
      desc: '',
      args: [],
    );
  }

  /// `No published plan`
  String get professionalSummaryNoPublishedPlan {
    return Intl.message(
      'No published plan',
      name: 'professionalSummaryNoPublishedPlan',
      desc: '',
      args: [],
    );
  }

  /// `Refresh section`
  String get professionalActionRefreshSection {
    return Intl.message(
      'Refresh section',
      name: 'professionalActionRefreshSection',
      desc: '',
      args: [],
    );
  }

  /// `Revoke access`
  String get professionalActionRevokeAccess {
    return Intl.message(
      'Revoke access',
      name: 'professionalActionRevokeAccess',
      desc: '',
      args: [],
    );
  }

  /// `Nutritionist`
  String get professionalScreenTitle {
    return Intl.message(
      'Nutritionist',
      name: 'professionalScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Connect with your nutritionist`
  String get professionalHeroConnectTitle {
    return Intl.message(
      'Connect with your nutritionist',
      name: 'professionalHeroConnectTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your patient-professional section`
  String get professionalHeroConnectedTitle {
    return Intl.message(
      'Your patient-professional section',
      name: 'professionalHeroConnectedTitle',
      desc: '',
      args: [],
    );
  }

  /// `No pending invite was found for that code.`
  String get professionalInviteNotFound {
    return Intl.message(
      'No pending invite was found for that code.',
      name: 'professionalInviteNotFound',
      desc: '',
      args: [],
    );
  }

  /// `This invite has expired.`
  String get professionalInviteExpired {
    return Intl.message(
      'This invite has expired.',
      name: 'professionalInviteExpired',
      desc: '',
      args: [],
    );
  }

  /// `Protect your account`
  String get professionalProtectAccountTitle {
    return Intl.message(
      'Protect your account',
      name: 'professionalProtectAccountTitle',
      desc: '',
      args: [],
    );
  }

  /// `To connect with a nutritionist, protect your cloud account with Google first. This keeps your account recoverable and preserves consent if you change phones. This does not enable Google Drive.`
  String get professionalProtectAccountBody {
    return Intl.message(
      'To connect with a nutritionist, protect your cloud account with Google first. This keeps your account recoverable and preserves consent if you change phones. This does not enable Google Drive.',
      name: 'professionalProtectAccountBody',
      desc: '',
      args: [],
    );
  }

  /// `Link Google`
  String get professionalProtectAccountAction {
    return Intl.message(
      'Link Google',
      name: 'professionalProtectAccountAction',
      desc: '',
      args: [],
    );
  }

  /// `Complete Google and return to accept the invite.`
  String get professionalProtectAccountReturnHint {
    return Intl.message(
      'Complete Google and return to accept the invite.',
      name: 'professionalProtectAccountReturnHint',
      desc: '',
      args: [],
    );
  }

  /// `Could not open Google.`
  String get professionalProtectAccountOpenError {
    return Intl.message(
      'Could not open Google.',
      name: 'professionalProtectAccountOpenError',
      desc: '',
      args: [],
    );
  }

  /// `Revoke professional access`
  String get professionalDisconnectTitle {
    return Intl.message(
      'Revoke professional access',
      name: 'professionalDisconnectTitle',
      desc: '',
      args: [],
    );
  }

  /// `Access will be revoked, this section will disappear, and aggregate sync will stop.`
  String get professionalDisconnectBody {
    return Intl.message(
      'Access will be revoked, this section will disappear, and aggregate sync will stop.',
      name: 'professionalDisconnectBody',
      desc: '',
      args: [],
    );
  }

  /// `Last plan update`
  String get professionalSummaryLastPlanUpdate {
    return Intl.message(
      'Last plan update',
      name: 'professionalSummaryLastPlanUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Last snapshot sent`
  String get professionalSummaryLastSnapshot {
    return Intl.message(
      'Last snapshot sent',
      name: 'professionalSummaryLastSnapshot',
      desc: '',
      args: [],
    );
  }

  /// `Connection status`
  String get professionalSummaryConnectionStatus {
    return Intl.message(
      'Connection status',
      name: 'professionalSummaryConnectionStatus',
      desc: '',
      args: [],
    );
  }

  /// `Protein`
  String get professionalMacroProtein {
    return Intl.message(
      'Protein',
      name: 'professionalMacroProtein',
      desc: '',
      args: [],
    );
  }

  /// `Carbs`
  String get professionalMacroCarbs {
    return Intl.message(
      'Carbs',
      name: 'professionalMacroCarbs',
      desc: '',
      args: [],
    );
  }

  /// `Fat`
  String get professionalMacroFat {
    return Intl.message(
      'Fat',
      name: 'professionalMacroFat',
      desc: '',
      args: [],
    );
  }

  /// `Your coach sees the real active sharing level. If there are {count} pending snapshots, they will sync when connectivity returns.`
  String professionalSharingPendingSnapshots(Object count) {
    return Intl.message(
      'Your coach sees the real active sharing level. If there are $count pending snapshots, they will sync when connectivity returns.',
      name: 'professionalSharingPendingSnapshots',
      desc: '',
      args: [count],
    );
  }

  /// `Detailed diary enabled successfully.`
  String get professionalSharingDetailedEnabled {
    return Intl.message(
      'Detailed diary enabled successfully.',
      name: 'professionalSharingDetailedEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Switched back to aggregate-only sharing.`
  String get professionalSharingAggregateEnabled {
    return Intl.message(
      'Switched back to aggregate-only sharing.',
      name: 'professionalSharingAggregateEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Could not change the privacy level because the device is offline. Try again when the phone has network access.`
  String get professionalSharingModeOfflineError {
    return Intl.message(
      'Could not change the privacy level because the device is offline. Try again when the phone has network access.',
      name: 'professionalSharingModeOfflineError',
      desc: '',
      args: [],
    );
  }

  /// `Could not update the permission with this professional. The relationship may have been revoked or the backend is still blocking this change.`
  String get professionalSharingModePermissionError {
    return Intl.message(
      'Could not update the permission with this professional. The relationship may have been revoked or the backend is still blocking this change.',
      name: 'professionalSharingModePermissionError',
      desc: '',
      args: [],
    );
  }

  /// `The change was not persisted on the server. Close and reopen this section before trying again.`
  String get professionalSharingModeNotPersistedError {
    return Intl.message(
      'The change was not persisted on the server. Close and reopen this section before trying again.',
      name: 'professionalSharingModeNotPersistedError',
      desc: '',
      args: [],
    );
  }

  /// `Your cloud session is no longer valid for changing this permission. Sign in again and try once more.`
  String get professionalSharingModeSessionError {
    return Intl.message(
      'Your cloud session is no longer valid for changing this permission. Sign in again and try once more.',
      name: 'professionalSharingModeSessionError',
      desc: '',
      args: [],
    );
  }

  /// `Could not change the privacy level for this relationship. Try again in a few seconds.`
  String get professionalSharingModeGenericError {
    return Intl.message(
      'Could not change the privacy level for this relationship. Try again in a few seconds.',
      name: 'professionalSharingModeGenericError',
      desc: '',
      args: [],
    );
  }

  /// `Active plan`
  String get professionalPlanActiveEyebrow {
    return Intl.message(
      'Active plan',
      name: 'professionalPlanActiveEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `Your professional prepared this structure to guide your week.`
  String get professionalPlanDefaultObjective {
    return Intl.message(
      'Your professional prepared this structure to guide your week.',
      name: 'professionalPlanDefaultObjective',
      desc: '',
      args: [],
    );
  }

  /// `Template days`
  String get professionalPlanTemplateDays {
    return Intl.message(
      'Template days',
      name: 'professionalPlanTemplateDays',
      desc: '',
      args: [],
    );
  }

  /// `Updated`
  String get professionalPlanUpdated {
    return Intl.message(
      'Updated',
      name: 'professionalPlanUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Weekly view`
  String get professionalPlanWeeklyView {
    return Intl.message(
      'Weekly view',
      name: 'professionalPlanWeeklyView',
      desc: '',
      args: [],
    );
  }

  /// `Tap a day to view its detailed calorie breakdown and log its meals.`
  String get professionalPlanWeeklyViewSubtitle {
    return Intl.message(
      'Tap a day to view its detailed calorie breakdown and log its meals.',
      name: 'professionalPlanWeeklyViewSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Meal guide`
  String get professionalPlanMealGuideEyebrow {
    return Intl.message(
      'Meal guide',
      name: 'professionalPlanMealGuideEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `Tap a meal to view its macronutrient breakdown, or use "+" to add it to today's diary.`
  String get professionalPlanMealGuideSubtitle {
    return Intl.message(
      'Tap a meal to view its macronutrient breakdown, or use "+" to add it to today\'s diary.',
      name: 'professionalPlanMealGuideSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Suggested plan meal`
  String get professionalPlanSuggestedPlanMeal {
    return Intl.message(
      'Suggested plan meal',
      name: 'professionalPlanSuggestedPlanMeal',
      desc: '',
      args: [],
    );
  }

  /// `Macronutrient energy split`
  String get professionalPlanMacroEnergySplit {
    return Intl.message(
      'Macronutrient energy split',
      name: 'professionalPlanMacroEnergySplit',
      desc: '',
      args: [],
    );
  }

  /// `Nutritionist guidelines`
  String get professionalPlanNutritionistGuidelines {
    return Intl.message(
      'Nutritionist guidelines',
      name: 'professionalPlanNutritionistGuidelines',
      desc: '',
      args: [],
    );
  }

  /// `View recipe`
  String get professionalPlanViewRecipe {
    return Intl.message(
      'View recipe',
      name: 'professionalPlanViewRecipe',
      desc: '',
      args: [],
    );
  }

  /// `Log to today's Diary`
  String get professionalPlanLogToTodaysDiary {
    return Intl.message(
      'Log to today\'s Diary',
      name: 'professionalPlanLogToTodaysDiary',
      desc: '',
      args: [],
    );
  }

  /// `Specific target`
  String get professionalPlanSpecificTarget {
    return Intl.message(
      'Specific target',
      name: 'professionalPlanSpecificTarget',
      desc: '',
      args: [],
    );
  }

  /// `No suggested meals`
  String get professionalPlanNoSuggestedMeals {
    return Intl.message(
      'No suggested meals',
      name: 'professionalPlanNoSuggestedMeals',
      desc: '',
      args: [],
    );
  }

  /// `Equivalent substitutes`
  String get professionalPlanEquivalentSubstitutes {
    return Intl.message(
      'Equivalent substitutes',
      name: 'professionalPlanEquivalentSubstitutes',
      desc: '',
      args: [],
    );
  }

  /// `Portions scaled to match the exact target macronutrients of this meal.`
  String get professionalPlanEquivalentSubstitutesSubtitle {
    return Intl.message(
      'Portions scaled to match the exact target macronutrients of this meal.',
      name: 'professionalPlanEquivalentSubstitutesSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Could not load recipe.`
  String get professionalPlanRecipeLoadUnavailable {
    return Intl.message(
      'Could not load recipe.',
      name: 'professionalPlanRecipeLoadUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Error loading recipe: {error}`
  String professionalPlanRecipeLoadError(Object error) {
    return Intl.message(
      'Error loading recipe: $error',
      name: 'professionalPlanRecipeLoadError',
      desc: '',
      args: [error],
    );
  }

  /// `Could not update recipe proposal: {error}`
  String professionalRecipesUpdateError(Object error) {
    return Intl.message(
      'Could not update recipe proposal: $error',
      name: 'professionalRecipesUpdateError',
      desc: '',
      args: [error],
    );
  }

  /// `No recipe proposals yet`
  String get professionalRecipesEmptyTitle {
    return Intl.message(
      'No recipe proposals yet',
      name: 'professionalRecipesEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your nutritionist will send you recipes here.`
  String get professionalRecipesEmptyBody {
    return Intl.message(
      'Your nutritionist will send you recipes here.',
      name: 'professionalRecipesEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `Recipe`
  String get professionalRecipesRecipeFallback {
    return Intl.message(
      'Recipe',
      name: 'professionalRecipesRecipeFallback',
      desc: '',
      args: [],
    );
  }

  /// `Save to my recipes`
  String get professionalRecipesSaveToMine {
    return Intl.message(
      'Save to my recipes',
      name: 'professionalRecipesSaveToMine',
      desc: '',
      args: [],
    );
  }

  /// `Decline`
  String get professionalRecipesDecline {
    return Intl.message(
      'Decline',
      name: 'professionalRecipesDecline',
      desc: '',
      args: [],
    );
  }

  /// `Declined`
  String get professionalRecipesDeclined {
    return Intl.message(
      'Declined',
      name: 'professionalRecipesDeclined',
      desc: '',
      args: [],
    );
  }

  /// `Recipe details`
  String get professionalPlanRecipeDetails {
    return Intl.message(
      'Recipe details',
      name: 'professionalPlanRecipeDetails',
      desc: '',
      args: [],
    );
  }

  /// `Prep`
  String get professionalPlanRecipePrep {
    return Intl.message(
      'Prep',
      name: 'professionalPlanRecipePrep',
      desc: '',
      args: [],
    );
  }

  /// `Cook`
  String get professionalPlanRecipeCook {
    return Intl.message(
      'Cook',
      name: 'professionalPlanRecipeCook',
      desc: '',
      args: [],
    );
  }

  /// `Servings`
  String get professionalPlanRecipeServings {
    return Intl.message(
      'Servings',
      name: 'professionalPlanRecipeServings',
      desc: '',
      args: [],
    );
  }

  /// `Ingredients`
  String get professionalPlanRecipeIngredients {
    return Intl.message(
      'Ingredients',
      name: 'professionalPlanRecipeIngredients',
      desc: '',
      args: [],
    );
  }

  /// `No ingredients specified`
  String get professionalPlanRecipeNoIngredients {
    return Intl.message(
      'No ingredients specified',
      name: 'professionalPlanRecipeNoIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Instructions`
  String get professionalPlanRecipeInstructions {
    return Intl.message(
      'Instructions',
      name: 'professionalPlanRecipeInstructions',
      desc: '',
      args: [],
    );
  }

  /// `No instructions`
  String get professionalPlanRecipeNoInstructions {
    return Intl.message(
      'No instructions',
      name: 'professionalPlanRecipeNoInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Log suggested meal?`
  String get professionalPlanLogSuggestedMealTitle {
    return Intl.message(
      'Log suggested meal?',
      name: 'professionalPlanLogSuggestedMealTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to add "{title}" ({kcal} kcal) to today's diary under "{slotName}"?`
  String professionalPlanLogSuggestedMealBody(
      Object title, Object kcal, Object slotName) {
    return Intl.message(
      'Do you want to add "$title" ($kcal kcal) to today\'s diary under "$slotName"?',
      name: 'professionalPlanLogSuggestedMealBody',
      desc: '',
      args: [title, kcal, slotName],
    );
  }

  /// `"{title}" logged successfully.`
  String professionalPlanLogSuggestedMealSuccess(Object title) {
    return Intl.message(
      '"$title" logged successfully.',
      name: 'professionalPlanLogSuggestedMealSuccess',
      desc: '',
      args: [title],
    );
  }

  /// `Could not log the meal.`
  String get professionalPlanLogSuggestedMealError {
    return Intl.message(
      'Could not log the meal.',
      name: 'professionalPlanLogSuggestedMealError',
      desc: '',
      args: [],
    );
  }

  /// `Log meal`
  String get professionalPlanLogMeal {
    return Intl.message(
      'Log meal',
      name: 'professionalPlanLogMeal',
      desc: '',
      args: [],
    );
  }

  /// `Log to Diary`
  String get professionalPlanLogToDiary {
    return Intl.message(
      'Log to Diary',
      name: 'professionalPlanLogToDiary',
      desc: '',
      args: [],
    );
  }

  /// `Breakfast`
  String get professionalPlanSlotBreakfast {
    return Intl.message(
      'Breakfast',
      name: 'professionalPlanSlotBreakfast',
      desc: '',
      args: [],
    );
  }

  /// `Lunch`
  String get professionalPlanSlotLunch {
    return Intl.message(
      'Lunch',
      name: 'professionalPlanSlotLunch',
      desc: '',
      args: [],
    );
  }

  /// `Dinner`
  String get professionalPlanSlotDinner {
    return Intl.message(
      'Dinner',
      name: 'professionalPlanSlotDinner',
      desc: '',
      args: [],
    );
  }

  /// `Snack`
  String get professionalPlanSlotSnack {
    return Intl.message(
      'Snack',
      name: 'professionalPlanSlotSnack',
      desc: '',
      args: [],
    );
  }

  /// `Suggested meals`
  String get professionalPlanSuggestedMeals {
    return Intl.message(
      'Suggested meals',
      name: 'professionalPlanSuggestedMeals',
      desc: '',
      args: [],
    );
  }

  /// `Today follow-up`
  String get professionalTrackingTodayTitle {
    return Intl.message(
      'Today follow-up',
      name: 'professionalTrackingTodayTitle',
      desc: '',
      args: [],
    );
  }

  /// `Meals logged`
  String get professionalTrackingMealsLogged {
    return Intl.message(
      'Meals logged',
      name: 'professionalTrackingMealsLogged',
      desc: '',
      args: [],
    );
  }

  /// `Tracked days`
  String get professionalTrackingTrackedDays {
    return Intl.message(
      'Tracked days',
      name: 'professionalTrackingTrackedDays',
      desc: '',
      args: [],
    );
  }

  /// `Current week: plan vs reality`
  String get professionalTrackingWeekTitle {
    return Intl.message(
      'Current week: plan vs reality',
      name: 'professionalTrackingWeekTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tracked days`
  String get professionalTrackingFollowUpDays {
    return Intl.message(
      'Tracked days',
      name: 'professionalTrackingFollowUpDays',
      desc: '',
      args: [],
    );
  }

  /// `Daily follow-up`
  String get professionalTrackingDailyEyebrow {
    return Intl.message(
      'Daily follow-up',
      name: 'professionalTrackingDailyEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `Quick adherence read so you know how the day is going against the plan.`
  String get professionalTrackingDailySubtitle {
    return Intl.message(
      'Quick adherence read so you know how the day is going against the plan.',
      name: 'professionalTrackingDailySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `{percent}% of today kcal target`
  String professionalTrackingTodayKcalTarget(Object percent) {
    return Intl.message(
      '$percent% of today kcal target',
      name: 'professionalTrackingTodayKcalTarget',
      desc: '',
      args: [percent],
    );
  }

  /// `{count} meals logged`
  String professionalTrackingMealsLoggedCount(Object count) {
    return Intl.message(
      '$count meals logged',
      name: 'professionalTrackingMealsLoggedCount',
      desc: '',
      args: [count],
    );
  }

  /// `Weekly perspective`
  String get professionalTrackingWeeklyEyebrow {
    return Intl.message(
      'Weekly perspective',
      name: 'professionalTrackingWeeklyEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `This shows whether the week keeps its direction, not only whether a single day was perfect.`
  String get professionalTrackingWeeklySubtitle {
    return Intl.message(
      'This shows whether the week keeps its direction, not only whether a single day was perfect.',
      name: 'professionalTrackingWeeklySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Week kcal`
  String get professionalTrackingWeekKcal {
    return Intl.message(
      'Week kcal',
      name: 'professionalTrackingWeekKcal',
      desc: '',
      args: [],
    );
  }

  /// `On target`
  String get professionalTrackingOnTarget {
    return Intl.message(
      'On target',
      name: 'professionalTrackingOnTarget',
      desc: '',
      args: [],
    );
  }

  /// `{delta}{unit} vs target`
  String professionalTrackingVsTarget(Object delta, Object unit) {
    return Intl.message(
      '$delta$unit vs target',
      name: 'professionalTrackingVsTarget',
      desc: '',
      args: [delta, unit],
    );
  }

  /// `Tap a column to view detail`
  String get professionalTrackingTapBarHint {
    return Intl.message(
      'Tap a column to view detail',
      name: 'professionalTrackingTapBarHint',
      desc: '',
      args: [],
    );
  }

  /// `Adherence history`
  String get professionalTrackingAdherenceHistory {
    return Intl.message(
      'Adherence history',
      name: 'professionalTrackingAdherenceHistory',
      desc: '',
      args: [],
    );
  }

  /// `Weekly calories vs target`
  String get professionalTrackingWeeklyCaloriesVsTarget {
    return Intl.message(
      'Weekly calories vs target',
      name: 'professionalTrackingWeeklyCaloriesVsTarget',
      desc: '',
      args: [],
    );
  }

  /// `Daily visual comparison of calories consumed vs nutritionist targets.`
  String get professionalTrackingWeeklyChartSubtitle {
    return Intl.message(
      'Daily visual comparison of calories consumed vs nutritionist targets.',
      name: 'professionalTrackingWeeklyChartSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Consumed`
  String get professionalTrackingConsumed {
    return Intl.message(
      'Consumed',
      name: 'professionalTrackingConsumed',
      desc: '',
      args: [],
    );
  }

  /// `Plan target`
  String get professionalTrackingPlanTarget {
    return Intl.message(
      'Plan target',
      name: 'professionalTrackingPlanTarget',
      desc: '',
      args: [],
    );
  }

  /// `Monday`
  String get professionalWeekdayMonday {
    return Intl.message(
      'Monday',
      name: 'professionalWeekdayMonday',
      desc: '',
      args: [],
    );
  }

  /// `Tuesday`
  String get professionalWeekdayTuesday {
    return Intl.message(
      'Tuesday',
      name: 'professionalWeekdayTuesday',
      desc: '',
      args: [],
    );
  }

  /// `Wednesday`
  String get professionalWeekdayWednesday {
    return Intl.message(
      'Wednesday',
      name: 'professionalWeekdayWednesday',
      desc: '',
      args: [],
    );
  }

  /// `Thursday`
  String get professionalWeekdayThursday {
    return Intl.message(
      'Thursday',
      name: 'professionalWeekdayThursday',
      desc: '',
      args: [],
    );
  }

  /// `Friday`
  String get professionalWeekdayFriday {
    return Intl.message(
      'Friday',
      name: 'professionalWeekdayFriday',
      desc: '',
      args: [],
    );
  }

  /// `Saturday`
  String get professionalWeekdaySaturday {
    return Intl.message(
      'Saturday',
      name: 'professionalWeekdaySaturday',
      desc: '',
      args: [],
    );
  }

  /// `Sunday`
  String get professionalWeekdaySunday {
    return Intl.message(
      'Sunday',
      name: 'professionalWeekdaySunday',
      desc: '',
      args: [],
    );
  }

  /// `M`
  String get professionalWeekdayInitialMonday {
    return Intl.message(
      'M',
      name: 'professionalWeekdayInitialMonday',
      desc: '',
      args: [],
    );
  }

  /// `T`
  String get professionalWeekdayInitialTuesday {
    return Intl.message(
      'T',
      name: 'professionalWeekdayInitialTuesday',
      desc: '',
      args: [],
    );
  }

  /// `W`
  String get professionalWeekdayInitialWednesday {
    return Intl.message(
      'W',
      name: 'professionalWeekdayInitialWednesday',
      desc: '',
      args: [],
    );
  }

  /// `T`
  String get professionalWeekdayInitialThursday {
    return Intl.message(
      'T',
      name: 'professionalWeekdayInitialThursday',
      desc: '',
      args: [],
    );
  }

  /// `F`
  String get professionalWeekdayInitialFriday {
    return Intl.message(
      'F',
      name: 'professionalWeekdayInitialFriday',
      desc: '',
      args: [],
    );
  }

  /// `S`
  String get professionalWeekdayInitialSaturday {
    return Intl.message(
      'S',
      name: 'professionalWeekdayInitialSaturday',
      desc: '',
      args: [],
    );
  }

  /// `S`
  String get professionalWeekdayInitialSunday {
    return Intl.message(
      'S',
      name: 'professionalWeekdayInitialSunday',
      desc: '',
      args: [],
    );
  }

  /// `Aggregate only`
  String get professionalPrivacyAggregateOnly {
    return Intl.message(
      'Aggregate only',
      name: 'professionalPrivacyAggregateOnly',
      desc: '',
      args: [],
    );
  }

  /// `Consent active since {date}.`
  String professionalPrivacyConsentSince(Object date) {
    return Intl.message(
      'Consent active since $date.',
      name: 'professionalPrivacyConsentSince',
      desc: '',
      args: [date],
    );
  }

  /// `Shared today`
  String get professionalPrivacySharedNow {
    return Intl.message(
      'Shared today',
      name: 'professionalPrivacySharedNow',
      desc: '',
      args: [],
    );
  }

  /// `Not shared today`
  String get professionalPrivacyNotSharedYet {
    return Intl.message(
      'Not shared today',
      name: 'professionalPrivacyNotSharedYet',
      desc: '',
      args: [],
    );
  }

  /// `Next available level`
  String get professionalPrivacyNextAvailable {
    return Intl.message(
      'Next available level',
      name: 'professionalPrivacyNextAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Privacy control`
  String get professionalPrivacyControlEyebrow {
    return Intl.message(
      'Privacy control',
      name: 'professionalPrivacyControlEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `This section describes the real level of data being shared right now, without promising more than what is active.`
  String get professionalPrivacyCurrentLevelSubtitle {
    return Intl.message(
      'This section describes the real level of data being shared right now, without promising more than what is active.',
      name: 'professionalPrivacyCurrentLevelSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Detailed`
  String get professionalPrivacyDetailed {
    return Intl.message(
      'Detailed',
      name: 'professionalPrivacyDetailed',
      desc: '',
      args: [],
    );
  }

  /// `Access level`
  String get professionalPrivacyAccessLevelEyebrow {
    return Intl.message(
      'Access level',
      name: 'professionalPrivacyAccessLevelEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `Choose between aggregate-only or detailed diary sharing`
  String get professionalPrivacySharingModeTitle {
    return Intl.message(
      'Choose between aggregate-only or detailed diary sharing',
      name: 'professionalPrivacySharingModeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Aggregate keeps targets, adherence, snapshots, and messaging. Detailed also unlocks your raw diary for this professional until you change it again.`
  String get professionalPrivacySharingModeSubtitle {
    return Intl.message(
      'Aggregate keeps targets, adherence, snapshots, and messaging. Detailed also unlocks your raw diary for this professional until you change it again.',
      name: 'professionalPrivacySharingModeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Right now the professional cannot read your raw diary or per-meal detail.`
  String get professionalPrivacyAggregateModeBody {
    return Intl.message(
      'Right now the professional cannot read your raw diary or per-meal detail.',
      name: 'professionalPrivacyAggregateModeBody',
      desc: '',
      args: [],
    );
  }

  /// `Right now the professional can read your raw diary and per-meal detail for this relationship.`
  String get professionalPrivacyDetailedModeBody {
    return Intl.message(
      'Right now the professional can read your raw diary and per-meal detail for this relationship.',
      name: 'professionalPrivacyDetailedModeBody',
      desc: '',
      args: [],
    );
  }

  /// `Access`
  String get professionalPrivacyAccessEyebrow {
    return Intl.message(
      'Access',
      name: 'professionalPrivacyAccessEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `Access control`
  String get professionalPrivacyAccessControl {
    return Intl.message(
      'Access control',
      name: 'professionalPrivacyAccessControl',
      desc: '',
      args: [],
    );
  }

  /// `If you revoke access, this section disappears and the professional stops receiving new snapshots.`
  String get professionalPrivacyAccessControlBody {
    return Intl.message(
      'If you revoke access, this section disappears and the professional stops receiving new snapshots.',
      name: 'professionalPrivacyAccessControlBody',
      desc: '',
      args: [],
    );
  }

  /// `The client shell is ready, but async messaging backend support is not available in this version yet.`
  String get professionalMessagesUnavailableBody {
    return Intl.message(
      'The client shell is ready, but async messaging backend support is not available in this version yet.',
      name: 'professionalMessagesUnavailableBody',
      desc: '',
      args: [],
    );
  }

  /// `For now, you will receive plan changes and follow-up from the rest of this section.`
  String get professionalMessagesUnavailableHint {
    return Intl.message(
      'For now, you will receive plan changes and follow-up from the rest of this section.',
      name: 'professionalMessagesUnavailableHint',
      desc: '',
      args: [],
    );
  }

  /// `Mark read`
  String get professionalMessagesMarkRead {
    return Intl.message(
      'Mark read',
      name: 'professionalMessagesMarkRead',
      desc: '',
      args: [],
    );
  }

  /// `Conversation`
  String get professionalMessagesConversationEyebrow {
    return Intl.message(
      'Conversation',
      name: 'professionalMessagesConversationEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `Chat thread`
  String get professionalMessagesChatThreadTitle {
    return Intl.message(
      'Chat thread',
      name: 'professionalMessagesChatThreadTitle',
      desc: '',
      args: [],
    );
  }

  /// `Unread professional messages are marked read when tapped.`
  String get professionalMessagesThreadSubtitle {
    return Intl.message(
      'Unread professional messages are marked read when tapped.',
      name: 'professionalMessagesThreadSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `There are no messages in this conversation yet.`
  String get professionalMessagesEmpty {
    return Intl.message(
      'There are no messages in this conversation yet.',
      name: 'professionalMessagesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Messaging exists, but it is disabled for this connection.`
  String get professionalMessagesDisabled {
    return Intl.message(
      'Messaging exists, but it is disabled for this connection.',
      name: 'professionalMessagesDisabled',
      desc: '',
      args: [],
    );
  }

  /// `New message`
  String get professionalMessagesNewEyebrow {
    return Intl.message(
      'New message',
      name: 'professionalMessagesNewEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `Write to your professional`
  String get professionalMessagesWriteTitle {
    return Intl.message(
      'Write to your professional',
      name: 'professionalMessagesWriteTitle',
      desc: '',
      args: [],
    );
  }

  /// `Keep it brief and actionable.`
  String get professionalMessagesWriteSubtitle {
    return Intl.message(
      'Keep it brief and actionable.',
      name: 'professionalMessagesWriteSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Example: today I fell short on protein and want to adjust dinner`
  String get professionalMessagesInputHint {
    return Intl.message(
      'Example: today I fell short on protein and want to adjust dinner',
      name: 'professionalMessagesInputHint',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get professionalMessagesSend {
    return Intl.message(
      'Send',
      name: 'professionalMessagesSend',
      desc: '',
      args: [],
    );
  }

  /// `You (Client)`
  String get professionalMessagesAuthorClientFull {
    return Intl.message(
      'You (Client)',
      name: 'professionalMessagesAuthorClientFull',
      desc: '',
      args: [],
    );
  }

  /// `Your professional`
  String get professionalMessagesAuthorProfessionalFull {
    return Intl.message(
      'Your professional',
      name: 'professionalMessagesAuthorProfessionalFull',
      desc: '',
      args: [],
    );
  }

  /// `Full message`
  String get professionalMessagesFullMessage {
    return Intl.message(
      'Full message',
      name: 'professionalMessagesFullMessage',
      desc: '',
      args: [],
    );
  }

  /// `Got it`
  String get professionalMessagesGotIt {
    return Intl.message(
      'Got it',
      name: 'professionalMessagesGotIt',
      desc: '',
      args: [],
    );
  }

  /// `You`
  String get professionalMessagesAuthorClientShort {
    return Intl.message(
      'You',
      name: 'professionalMessagesAuthorClientShort',
      desc: '',
      args: [],
    );
  }

  /// `Professional`
  String get professionalMessagesAuthorProfessionalShort {
    return Intl.message(
      'Professional',
      name: 'professionalMessagesAuthorProfessionalShort',
      desc: '',
      args: [],
    );
  }

  /// `Connected with no published plan yet`
  String get professionalHubNoPublishedPlan {
    return Intl.message(
      'Connected with no published plan yet',
      name: 'professionalHubNoPublishedPlan',
      desc: '',
      args: [],
    );
  }

  /// `No target today`
  String get professionalHubNoTodayTarget {
    return Intl.message(
      'No target today',
      name: 'professionalHubNoTodayTarget',
      desc: '',
      args: [],
    );
  }

  /// `Plan daily targets`
  String get professionalHubPlanDailyTargets {
    return Intl.message(
      'Plan daily targets',
      name: 'professionalHubPlanDailyTargets',
      desc: '',
      args: [],
    );
  }

  /// `{kcal} kcal today`
  String professionalHubKcalToday(Object kcal) {
    return Intl.message(
      '$kcal kcal today',
      name: 'professionalHubKcalToday',
      desc: '',
      args: [kcal],
    );
  }

  /// `{count} pending`
  String professionalHubPendingCount(Object count) {
    return Intl.message(
      '$count pending',
      name: 'professionalHubPendingCount',
      desc: '',
      args: [count],
    );
  }

  /// `No offline queue`
  String get professionalHubNoOfflineQueue {
    return Intl.message(
      'No offline queue',
      name: 'professionalHubNoOfflineQueue',
      desc: '',
      args: [],
    );
  }

  /// `Plan`
  String get professionalTabPlan {
    return Intl.message(
      'Plan',
      name: 'professionalTabPlan',
      desc: '',
      args: [],
    );
  }

  /// `Tracking`
  String get professionalTabTracking {
    return Intl.message(
      'Tracking',
      name: 'professionalTabTracking',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get professionalTabPrivacy {
    return Intl.message(
      'Privacy',
      name: 'professionalTabPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get professionalTabMessages {
    return Intl.message(
      'Messages',
      name: 'professionalTabMessages',
      desc: '',
      args: [],
    );
  }

  /// `Messages ({count})`
  String professionalMessagesTabWithCount(Object count) {
    return Intl.message(
      'Messages ($count)',
      name: 'professionalMessagesTabWithCount',
      desc: '',
      args: [count],
    );
  }

  /// `Activate the Nutritionist section`
  String get professionalInviteSectionTitle {
    return Intl.message(
      'Activate the Nutritionist section',
      name: 'professionalInviteSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `You need an invite and consent. You will get professional follow-up, plan, privacy, and access control without mixing it with Google Drive.`
  String get professionalInviteSectionBody {
    return Intl.message(
      'You need an invite and consent. You will get professional follow-up, plan, privacy, and access control without mixing it with Google Drive.',
      name: 'professionalInviteSectionBody',
      desc: '',
      args: [],
    );
  }

  /// `Invite`
  String get professionalInvitePillInvite {
    return Intl.message(
      'Invite',
      name: 'professionalInvitePillInvite',
      desc: '',
      args: [],
    );
  }

  /// `Consent`
  String get professionalInvitePillConsent {
    return Intl.message(
      'Consent',
      name: 'professionalInvitePillConsent',
      desc: '',
      args: [],
    );
  }

  /// `Clear privacy`
  String get professionalInvitePillClearPrivacy {
    return Intl.message(
      'Clear privacy',
      name: 'professionalInvitePillClearPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `Private activation`
  String get professionalInvitePrivateActivation {
    return Intl.message(
      'Private activation',
      name: 'professionalInvitePrivateActivation',
      desc: '',
      args: [],
    );
  }

  /// `Code`
  String get professionalInviteCodeEyebrow {
    return Intl.message(
      'Code',
      name: 'professionalInviteCodeEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `Invite code`
  String get professionalInviteCodeLabel {
    return Intl.message(
      'Invite code',
      name: 'professionalInviteCodeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter the invite to review it before sharing anything.`
  String get professionalInviteReviewBeforeSharing {
    return Intl.message(
      'Enter the invite to review it before sharing anything.',
      name: 'professionalInviteReviewBeforeSharing',
      desc: '',
      args: [],
    );
  }

  /// `Review invite`
  String get professionalInviteReviewAction {
    return Intl.message(
      'Review invite',
      name: 'professionalInviteReviewAction',
      desc: '',
      args: [],
    );
  }

  /// `Consent review`
  String get professionalConsentReviewEyebrow {
    return Intl.message(
      'Consent review',
      name: 'professionalConsentReviewEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `Before connecting, you can review exactly what is shared today and what stays outside.`
  String get professionalConsentReviewSubtitle {
    return Intl.message(
      'Before connecting, you can review exactly what is shared today and what stays outside.',
      name: 'professionalConsentReviewSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `What is shared today`
  String get professionalConsentSharedToday {
    return Intl.message(
      'What is shared today',
      name: 'professionalConsentSharedToday',
      desc: '',
      args: [],
    );
  }

  /// `What is not shared today`
  String get professionalConsentNotSharedToday {
    return Intl.message(
      'What is not shared today',
      name: 'professionalConsentNotSharedToday',
      desc: '',
      args: [],
    );
  }

  /// `kcal, macros, logged meals, aggregate adherence by day, and bidirectional messaging`
  String get professionalConsentSharedTodayBody {
    return Intl.message(
      'kcal, macros, logged meals, aggregate adherence by day, and bidirectional messaging',
      name: 'professionalConsentSharedTodayBody',
      desc: '',
      args: [],
    );
  }

  /// `full raw diary and per-meal detail unless you enable detailed sharing later`
  String get professionalConsentNotSharedTodayBody {
    return Intl.message(
      'full raw diary and per-meal detail unless you enable detailed sharing later',
      name: 'professionalConsentNotSharedTodayBody',
      desc: '',
      args: [],
    );
  }

  /// `You can revoke access at any time from the privacy section.`
  String get professionalConsentRevokeHint {
    return Intl.message(
      'You can revoke access at any time from the privacy section.',
      name: 'professionalConsentRevokeHint',
      desc: '',
      args: [],
    );
  }

  /// `Accept and connect`
  String get professionalAcceptAndConnect {
    return Intl.message(
      'Accept and connect',
      name: 'professionalAcceptAndConnect',
      desc: '',
      args: [],
    );
  }

  /// `Opening Google`
  String get professionalOpeningGoogle {
    return Intl.message(
      'Opening Google',
      name: 'professionalOpeningGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Estimated adherence: {percent}%`
  String professionalTrackingEstimatedAdherence(Object percent) {
    return Intl.message(
      'Estimated adherence: $percent%',
      name: 'professionalTrackingEstimatedAdherence',
      desc: '',
      args: [percent],
    );
  }

  /// `No target`
  String get professionalWeekNoTarget {
    return Intl.message(
      'No target',
      name: 'professionalWeekNoTarget',
      desc: '',
      args: [],
    );
  }

  /// `template`
  String get professionalWeekTemplate {
    return Intl.message(
      'template',
      name: 'professionalWeekTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Your coach is already connected to you, but has not published an active plan yet. When they do, this section will show daily targets, follow-up, and suggested meals.`
  String get professionalEmptyPlanBody {
    return Intl.message(
      'Your coach is already connected to you, but has not published an active plan yet. When they do, this section will show daily targets, follow-up, and suggested meals.',
      name: 'professionalEmptyPlanBody',
      desc: '',
      args: [],
    );
  }

  /// `Last plan sync: {date}`
  String professionalEmptyPlanSync(Object date) {
    return Intl.message(
      'Last plan sync: $date',
      name: 'professionalEmptyPlanSync',
      desc: '',
      args: [date],
    );
  }

  /// `Could not connect. Check your connection and try again.`
  String get professionalErrorOffline {
    return Intl.message(
      'Could not connect. Check your connection and try again.',
      name: 'professionalErrorOffline',
      desc: '',
      args: [],
    );
  }

  /// `Could not create the cloud identity required to connect the plan.`
  String get professionalErrorCloudIdentity {
    return Intl.message(
      'Could not create the cloud identity required to connect the plan.',
      name: 'professionalErrorCloudIdentity',
      desc: '',
      args: [],
    );
  }

  /// `The action could not be completed. Try again.`
  String get professionalErrorAction {
    return Intl.message(
      'The action could not be completed. Try again.',
      name: 'professionalErrorAction',
      desc: '',
      args: [],
    );
  }

  /// `Never`
  String get professionalNever {
    return Intl.message(
      'Never',
      name: 'professionalNever',
      desc: '',
      args: [],
    );
  }

  /// `goal vs actual kcal and macros in aggregate form`
  String get professionalPrivacyAggregateTargets {
    return Intl.message(
      'goal vs actual kcal and macros in aggregate form',
      name: 'professionalPrivacyAggregateTargets',
      desc: '',
      args: [],
    );
  }

  /// `tracked days and number of logged meals`
  String get professionalPrivacyAggregateTrackedDaysMeals {
    return Intl.message(
      'tracked days and number of logged meals',
      name: 'professionalPrivacyAggregateTrackedDaysMeals',
      desc: '',
      args: [],
    );
  }

  /// `aggregate daily adherence`
  String get professionalPrivacyAggregateDailyAdherence {
    return Intl.message(
      'aggregate daily adherence',
      name: 'professionalPrivacyAggregateDailyAdherence',
      desc: '',
      args: [],
    );
  }

  /// `your full raw diary`
  String get professionalPrivacyRawDiary {
    return Intl.message(
      'your full raw diary',
      name: 'professionalPrivacyRawDiary',
      desc: '',
      args: [],
    );
  }

  /// `full per-meal or slot detail`
  String get professionalPrivacyPerMealDetail {
    return Intl.message(
      'full per-meal or slot detail',
      name: 'professionalPrivacyPerMealDetail',
      desc: '',
      args: [],
    );
  }

  /// `real-time bidirectional messaging`
  String get professionalPrivacyRealtimeMessages {
    return Intl.message(
      'real-time bidirectional messaging',
      name: 'professionalPrivacyRealtimeMessages',
      desc: '',
      args: [],
    );
  }

  /// `per-meal detail when backend, legal copy, and consent are ready`
  String get professionalPrivacyPerMealDetailWhenReady {
    return Intl.message(
      'per-meal detail when backend, legal copy, and consent are ready',
      name: 'professionalPrivacyPerMealDetailWhenReady',
      desc: '',
      args: [],
    );
  }

  /// `Saved meals`
  String get recipeLibraryTitle {
    return Intl.message(
      'Saved meals',
      name: 'recipeLibraryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Import from web`
  String get recipeLibraryImportFromWeb {
    return Intl.message(
      'Import from web',
      name: 'recipeLibraryImportFromWeb',
      desc: '',
      args: [],
    );
  }

  /// `Search saved meals`
  String get recipeLibrarySearchHint {
    return Intl.message(
      'Search saved meals',
      name: 'recipeLibrarySearchHint',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get recipeLibraryAllFilter {
    return Intl.message(
      'All',
      name: 'recipeLibraryAllFilter',
      desc: '',
      args: [],
    );
  }

  /// `No saved meals yet.\nSave meals as recipes to reuse them.`
  String get recipeLibraryEmpty {
    return Intl.message(
      'No saved meals yet.\nSave meals as recipes to reuse them.',
      name: 'recipeLibraryEmpty',
      desc: '',
      args: [],
    );
  }

  /// `{count} ingredients`
  String recipeLibraryIngredientsCount(Object count) {
    return Intl.message(
      '$count ingredients',
      name: 'recipeLibraryIngredientsCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} servings`
  String recipeLibraryServingsCount(Object count) {
    return Intl.message(
      '$count servings',
      name: 'recipeLibraryServingsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Saved`
  String get recipeLibraryFavorite {
    return Intl.message(
      'Saved',
      name: 'recipeLibraryFavorite',
      desc: '',
      args: [],
    );
  }

  /// `Pinned`
  String get recipeLibraryPinned {
    return Intl.message(
      'Pinned',
      name: 'recipeLibraryPinned',
      desc: '',
      args: [],
    );
  }

  /// `{count} uses`
  String recipeLibraryUses(Object count) {
    return Intl.message(
      '$count uses',
      name: 'recipeLibraryUses',
      desc: '',
      args: [count],
    );
  }

  /// `Pin`
  String get recipeLibraryPin {
    return Intl.message(
      'Pin',
      name: 'recipeLibraryPin',
      desc: '',
      args: [],
    );
  }

  /// `Unpin`
  String get recipeLibraryUnpin {
    return Intl.message(
      'Unpin',
      name: 'recipeLibraryUnpin',
      desc: '',
      args: [],
    );
  }

  /// `Actions`
  String get recipeLibraryActions {
    return Intl.message(
      'Actions',
      name: 'recipeLibraryActions',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get recipeLibraryEdit {
    return Intl.message(
      'Edit',
      name: 'recipeLibraryEdit',
      desc: '',
      args: [],
    );
  }

  /// `Remove saved`
  String get recipeLibraryRemoveFavorite {
    return Intl.message(
      'Remove saved',
      name: 'recipeLibraryRemoveFavorite',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get recipeLibraryMarkFavorite {
    return Intl.message(
      'Save',
      name: 'recipeLibraryMarkFavorite',
      desc: '',
      args: [],
    );
  }

  /// `{name} added`
  String recipeLibraryAddedSnackbar(Object name) {
    return Intl.message(
      '$name added',
      name: 'recipeLibraryAddedSnackbar',
      desc: '',
      args: [name],
    );
  }

  /// `One library, two sources: meals you save manually and repeated meals detected automatically.`
  String get recipeLibraryIntro {
    return Intl.message(
      'One library, two sources: meals you save manually and repeated meals detected automatically.',
      name: 'recipeLibraryIntro',
      desc: '',
      args: [],
    );
  }

  /// `Filter by real category, pin key recipes, and edit them directly from the library.`
  String get recipeLibraryIntroCard {
    return Intl.message(
      'Filter by real category, pin key recipes, and edit them directly from the library.',
      name: 'recipeLibraryIntroCard',
      desc: '',
      args: [],
    );
  }

  /// `Saved recipes`
  String get recipeLibraryManualSectionTitle {
    return Intl.message(
      'Saved recipes',
      name: 'recipeLibraryManualSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `You save these on purpose to reuse them whenever you want.`
  String get recipeLibraryManualSectionSubtitle {
    return Intl.message(
      'You save these on purpose to reuse them whenever you want.',
      name: 'recipeLibraryManualSectionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Repeated suggestions`
  String get recipeLibraryFrequentSectionTitle {
    return Intl.message(
      'Repeated suggestions',
      name: 'recipeLibraryFrequentSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Detected from your history so you can repeat them faster.`
  String get recipeLibraryFrequentSectionSubtitle {
    return Intl.message(
      'Detected from your history so you can repeat them faster.',
      name: 'recipeLibraryFrequentSectionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `{count} times`
  String recipeLibraryFrequentUses(Object count) {
    return Intl.message(
      '$count times',
      name: 'recipeLibraryFrequentUses',
      desc: '',
      args: [count],
    );
  }

  /// `Suggested intake: {servings} {unit}`
  String recipeDetailSuggestedIntake(Object servings, Object unit) {
    return Intl.message(
      'Suggested intake: $servings $unit',
      name: 'recipeDetailSuggestedIntake',
      desc: '',
      args: [servings, unit],
    );
  }

  /// `Serving: {servings} {unit}`
  String recipeDetailServing(Object servings, Object unit) {
    return Intl.message(
      'Serving: $servings $unit',
      name: 'recipeDetailServing',
      desc: '',
      args: [servings, unit],
    );
  }

  /// `serving`
  String get recipeDetailServingUnitSingular {
    return Intl.message(
      'serving',
      name: 'recipeDetailServingUnitSingular',
      desc: '',
      args: [],
    );
  }

  /// `servings`
  String get recipeDetailServingUnitPlural {
    return Intl.message(
      'servings',
      name: 'recipeDetailServingUnitPlural',
      desc: '',
      args: [],
    );
  }

  /// `Coach recommendation`
  String get recipeDetailCoachRecommendation {
    return Intl.message(
      'Coach recommendation',
      name: 'recipeDetailCoachRecommendation',
      desc: '',
      args: [],
    );
  }

  /// `Recipe notes`
  String get recipeDetailRecipeNotes {
    return Intl.message(
      'Recipe notes',
      name: 'recipeDetailRecipeNotes',
      desc: '',
      args: [],
    );
  }

  /// `No detailed ingredients for this recipe.`
  String get recipeDetailNoDetailedIngredients {
    return Intl.message(
      'No detailed ingredients for this recipe.',
      name: 'recipeDetailNoDetailedIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient`
  String get recipeDetailIngredientFallback {
    return Intl.message(
      'Ingredient',
      name: 'recipeDetailIngredientFallback',
      desc: '',
      args: [],
    );
  }

  /// `Customize recipe`
  String get recipeDetailCustomizeRecipe {
    return Intl.message(
      'Customize recipe',
      name: 'recipeDetailCustomizeRecipe',
      desc: '',
      args: [],
    );
  }

  /// `Edit recipe`
  String get recipeDetailEditRecipe {
    return Intl.message(
      'Edit recipe',
      name: 'recipeDetailEditRecipe',
      desc: '',
      args: [],
    );
  }

  /// `Default serving amount when logging this recipe.`
  String get recipeEditorServingsHelper {
    return Intl.message(
      'Default serving amount when logging this recipe.',
      name: 'recipeEditorServingsHelper',
      desc: '',
      args: [],
    );
  }

  /// `Save recipe`
  String get recipeEditorSaveRecipe {
    return Intl.message(
      'Save recipe',
      name: 'recipeEditorSaveRecipe',
      desc: '',
      args: [],
    );
  }

  /// `Add foods to adjust this recipe.`
  String get recipeEditorIngredientsEmpty {
    return Intl.message(
      'Add foods to adjust this recipe.',
      name: 'recipeEditorIngredientsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition summary`
  String get recipeEditorNutritionSummary {
    return Intl.message(
      'Nutrition summary',
      name: 'recipeEditorNutritionSummary',
      desc: '',
      args: [],
    );
  }

  /// `Per serving. Full recipe: {kcal} kcal.`
  String recipeEditorPerServingSummary(Object kcal) {
    return Intl.message(
      'Per serving. Full recipe: $kcal kcal.',
      name: 'recipeEditorPerServingSummary',
      desc: '',
      args: [kcal],
    );
  }

  /// `Change food`
  String get recipeEditorChangeFood {
    return Intl.message(
      'Change food',
      name: 'recipeEditorChangeFood',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate`
  String get recipeEditorDuplicate {
    return Intl.message(
      'Duplicate',
      name: 'recipeEditorDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Check name, servings, and ingredients.`
  String get recipeEditorInvalidRecipe {
    return Intl.message(
      'Check name, servings, and ingredients.',
      name: 'recipeEditorInvalidRecipe',
      desc: '',
      args: [],
    );
  }

  /// `Search for a food to add it to the recipe.`
  String get recipeEditorSearchPrompt {
    return Intl.message(
      'Search for a food to add it to the recipe.',
      name: 'recipeEditorSearchPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Local cache results`
  String get recipeEditorLocalCacheResults {
    return Intl.message(
      'Local cache results',
      name: 'recipeEditorLocalCacheResults',
      desc: '',
      args: [],
    );
  }

  /// `Search is unavailable right now. Check the connection and try again.`
  String get recipeEditorSearchUnavailable {
    return Intl.message(
      'Search is unavailable right now. Check the connection and try again.',
      name: 'recipeEditorSearchUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Import recipe with AI`
  String get recipeScraperTitle {
    return Intl.message(
      'Import recipe with AI',
      name: 'recipeScraperTitle',
      desc: '',
      args: [],
    );
  }

  /// `Paste a link to a cooking blog or recipe and the AI will extract it automatically.`
  String get recipeScraperSubtitle {
    return Intl.message(
      'Paste a link to a cooking blog or recipe and the AI will extract it automatically.',
      name: 'recipeScraperSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Extracting recipe with AI...`
  String get recipeScraperLoading {
    return Intl.message(
      'Extracting recipe with AI...',
      name: 'recipeScraperLoading',
      desc: '',
      args: [],
    );
  }

  /// `Recipe URL`
  String get recipeScraperUrlLabel {
    return Intl.message(
      'Recipe URL',
      name: 'recipeScraperUrlLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid URL.`
  String get recipeScraperInvalidUrl {
    return Intl.message(
      'Please enter a valid URL.',
      name: 'recipeScraperInvalidUrl',
      desc: '',
      args: [],
    );
  }

  /// `URL must start with http:// or https://`
  String get recipeScraperUrlSchemeError {
    return Intl.message(
      'URL must start with http:// or https://',
      name: 'recipeScraperUrlSchemeError',
      desc: '',
      args: [],
    );
  }

  /// `AI Cost`
  String get settingsAiCostLabel {
    return Intl.message(
      'AI Cost',
      name: 'settingsAiCostLabel',
      desc: '',
      args: [],
    );
  }

  /// `Total estimated: {cost}`
  String settingsAiCostTotal(Object cost) {
    return Intl.message(
      'Total estimated: $cost',
      name: 'settingsAiCostTotal',
      desc: '',
      args: [cost],
    );
  }

  /// `Today: {cost}`
  String settingsAiCostToday(Object cost) {
    return Intl.message(
      'Today: $cost',
      name: 'settingsAiCostToday',
      desc: '',
      args: [cost],
    );
  }

  /// `This month: {cost}`
  String settingsAiCostMonth(Object cost) {
    return Intl.message(
      'This month: $cost',
      name: 'settingsAiCostMonth',
      desc: '',
      args: [cost],
    );
  }

  /// `Total calls: {count}`
  String settingsAiCallsTotal(Object count) {
    return Intl.message(
      'Total calls: $count',
      name: 'settingsAiCallsTotal',
      desc: '',
      args: [count],
    );
  }

  /// `Text calls: {count}`
  String settingsAiCallsText(Object count) {
    return Intl.message(
      'Text calls: $count',
      name: 'settingsAiCallsText',
      desc: '',
      args: [count],
    );
  }

  /// `Photo calls: {count}`
  String settingsAiCallsPhoto(Object count) {
    return Intl.message(
      'Photo calls: $count',
      name: 'settingsAiCallsPhoto',
      desc: '',
      args: [count],
    );
  }

  /// `Based on real token usage per backend request.`
  String get settingsAiCostDescription {
    return Intl.message(
      'Based on real token usage per backend request.',
      name: 'settingsAiCostDescription',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get settingsResetLabel {
    return Intl.message(
      'Reset',
      name: 'settingsResetLabel',
      desc: '',
      args: [],
    );
  }

  /// `Cloud account and device data deleted.`
  String get settingsAccountDeletedMessage {
    return Intl.message(
      'Cloud account and device data deleted.',
      name: 'settingsAccountDeletedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Tracking`
  String get settingsTrackingSection {
    return Intl.message(
      'Tracking',
      name: 'settingsTrackingSection',
      desc: '',
      args: [],
    );
  }

  /// `Percentage distribution (%)`
  String get settingsCalculationPercentageMode {
    return Intl.message(
      'Percentage distribution (%)',
      name: 'settingsCalculationPercentageMode',
      desc: '',
      args: [],
    );
  }

  /// `Grams per kg distribution (g/kg)`
  String get settingsCalculationGramsKgMode {
    return Intl.message(
      'Grams per kg distribution (g/kg)',
      name: 'settingsCalculationGramsKgMode',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get settingsAppearanceSection {
    return Intl.message(
      'Appearance',
      name: 'settingsAppearanceSection',
      desc: '',
      args: [],
    );
  }

  /// `Support and feedback`
  String get settingsSupportSection {
    return Intl.message(
      'Support and feedback',
      name: 'settingsSupportSection',
      desc: '',
      args: [],
    );
  }

  /// `Report a bug`
  String get settingsReportBugTitle {
    return Intl.message(
      'Report a bug',
      name: 'settingsReportBugTitle',
      desc: '',
      args: [],
    );
  }

  /// `Let us know about an issue in the app.`
  String get settingsReportBugSubtitle {
    return Intl.message(
      'Let us know about an issue in the app.',
      name: 'settingsReportBugSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `MacroTracker - Bug report`
  String get settingsReportBugEmailSubject {
    return Intl.message(
      'MacroTracker - Bug report',
      name: 'settingsReportBugEmailSubject',
      desc: '',
      args: [],
    );
  }

  /// `Please describe the bug here:\n\n\n\n---\nSystem info:\nPlatform: {platform}\n`
  String settingsReportBugEmailBody(String platform) {
    return Intl.message(
      'Please describe the bug here:\n\n\n\n---\nSystem info:\nPlatform: $platform\n',
      name: 'settingsReportBugEmailBody',
      desc: '',
      args: [platform],
    );
  }

  /// `Suggest a feature`
  String get settingsSuggestFeatureTitle {
    return Intl.message(
      'Suggest a feature',
      name: 'settingsSuggestFeatureTitle',
      desc: '',
      args: [],
    );
  }

  /// `What would you like to see in MacroTracker?`
  String get settingsSuggestFeatureSubtitle {
    return Intl.message(
      'What would you like to see in MacroTracker?',
      name: 'settingsSuggestFeatureSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `MacroTracker - Feature request`
  String get settingsFeatureRequestEmailSubject {
    return Intl.message(
      'MacroTracker - Feature request',
      name: 'settingsFeatureRequestEmailSubject',
      desc: '',
      args: [],
    );
  }

  /// `Describe the feature you would like to see:\n\n\n`
  String get settingsFeatureRequestEmailBody {
    return Intl.message(
      'Describe the feature you would like to see:\n\n\n',
      name: 'settingsFeatureRequestEmailBody',
      desc: '',
      args: [],
    );
  }

  /// `Daily Drive`
  String get settingsDailyDriveBackup {
    return Intl.message(
      'Daily Drive',
      name: 'settingsDailyDriveBackup',
      desc: '',
      args: [],
    );
  }

  /// `Manual Drive`
  String get settingsManualDriveBackup {
    return Intl.message(
      'Manual Drive',
      name: 'settingsManualDriveBackup',
      desc: '',
      args: [],
    );
  }

  /// `Account and backups`
  String get settingsAccountBackupsSection {
    return Intl.message(
      'Account and backups',
      name: 'settingsAccountBackupsSection',
      desc: '',
      args: [],
    );
  }

  /// `Professional nutritionist`
  String get settingsProfessionalNutritionistSection {
    return Intl.message(
      'Professional nutritionist',
      name: 'settingsProfessionalNutritionistSection',
      desc: '',
      args: [],
    );
  }

  /// `Nutritionist connection`
  String get settingsNutritionistConnectionTitle {
    return Intl.message(
      'Nutritionist connection',
      name: 'settingsNutritionistConnectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Connect your account with a professional by invite and consent.`
  String get settingsNutritionistConnectionBody {
    return Intl.message(
      'Connect your account with a professional by invite and consent.',
      name: 'settingsNutritionistConnectionBody',
      desc: '',
      args: [],
    );
  }

  /// `Professional`
  String get settingsProfessionalStatus {
    return Intl.message(
      'Professional',
      name: 'settingsProfessionalStatus',
      desc: '',
      args: [],
    );
  }

  /// `Privacy and data`
  String get settingsPrivacyDataSection {
    return Intl.message(
      'Privacy and data',
      name: 'settingsPrivacyDataSection',
      desc: '',
      args: [],
    );
  }

  /// `You can turn this on or off at any time.`
  String get settingsAnonymousDataSubtitle {
    return Intl.message(
      'You can turn this on or off at any time.',
      name: 'settingsAnonymousDataSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Delete cloud account and data`
  String get settingsDeleteCloudAccountTitle {
    return Intl.message(
      'Delete cloud account and data',
      name: 'settingsDeleteCloudAccountTitle',
      desc: '',
      args: [],
    );
  }

  /// `Permanently deletes your profile, local logs, and linked cloud data.`
  String get settingsDeleteCloudAccountSubtitle {
    return Intl.message(
      'Permanently deletes your profile, local logs, and linked cloud data.',
      name: 'settingsDeleteCloudAccountSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Project`
  String get settingsAboutProjectLabel {
    return Intl.message(
      'Project',
      name: 'settingsAboutProjectLabel',
      desc: '',
      args: [],
    );
  }

  /// `Calorie, macro, habit, activity, and local/Drive backup tracking.`
  String get settingsAboutProjectValue {
    return Intl.message(
      'Calorie, macro, habit, activity, and local/Drive backup tracking.',
      name: 'settingsAboutProjectValue',
      desc: '',
      args: [],
    );
  }

  /// `Model`
  String get settingsAboutModelLabel {
    return Intl.message(
      'Model',
      name: 'settingsAboutModelLabel',
      desc: '',
      args: [],
    );
  }

  /// `Local-first app with optional sync and AI-assisted meal interpretation.`
  String get settingsAboutModelValue {
    return Intl.message(
      'Local-first app with optional sync and AI-assisted meal interpretation.',
      name: 'settingsAboutModelValue',
      desc: '',
      args: [],
    );
  }

  /// `App`
  String get settingsAppSection {
    return Intl.message(
      'App',
      name: 'settingsAppSection',
      desc: '',
      args: [],
    );
  }

  /// `View Feature Tour`
  String get settingsFeatureTourTitle {
    return Intl.message(
      'View Feature Tour',
      name: 'settingsFeatureTourTitle',
      desc: '',
      args: [],
    );
  }

  /// `My plan`
  String get settingsPlanTitle {
    return Intl.message(
      'My plan',
      name: 'settingsPlanTitle',
      desc: '',
      args: [],
    );
  }

  /// `Free plan`
  String get settingsFreePlan {
    return Intl.message(
      'Free plan',
      name: 'settingsFreePlan',
      desc: '',
      args: [],
    );
  }

  /// `Text and photo AI logging is unlocked.`
  String get settingsPremiumUnlockedMessage {
    return Intl.message(
      'Text and photo AI logging is unlocked.',
      name: 'settingsPremiumUnlockedMessage',
      desc: '',
      args: [],
    );
  }

  /// `You have used the guest allowance. Protect your account to unlock {count} more free uses.`
  String settingsGuestAllowanceUsedBody(int count) {
    return Intl.message(
      'You have used the guest allowance. Protect your account to unlock $count more free uses.',
      name: 'settingsGuestAllowanceUsedBody',
      desc: '',
      args: [count],
    );
  }

  /// `{remaining} of {limit} free uses available now. Protect your account to keep them and unlock {count} more.`
  String settingsTrialProtectBody(int remaining, int limit, int count) {
    return Intl.message(
      '$remaining of $limit free uses available now. Protect your account to keep them and unlock $count more.',
      name: 'settingsTrialProtectBody',
      desc: '',
      args: [remaining, limit, count],
    );
  }

  /// `{remaining} of {limit} free AI uses available.`
  String settingsTrialRemainingBody(int remaining, int limit) {
    return Intl.message(
      '$remaining of $limit free AI uses available.',
      name: 'settingsTrialRemainingBody',
      desc: '',
      args: [remaining, limit],
    );
  }

  /// `{used} used - unlock {count} more with Google`
  String settingsPlanLockedProgress(int used, int count) {
    return Intl.message(
      '$used used - unlock $count more with Google',
      name: 'settingsPlanLockedProgress',
      desc: '',
      args: [used, count],
    );
  }

  /// `{used} used - {remaining} remaining`
  String settingsPlanProgress(int used, int remaining) {
    return Intl.message(
      '$used used - $remaining remaining',
      name: 'settingsPlanProgress',
      desc: '',
      args: [used, remaining],
    );
  }

  /// `{count} AI meals saved - {minutes} min saved`
  String settingsPlanMetricAiMeals(int count, int minutes) {
    return Intl.message(
      '$count AI meals saved - $minutes min saved',
      name: 'settingsPlanMetricAiMeals',
      desc: '',
      args: [count, minutes],
    );
  }

  /// `View Premium`
  String get settingsViewPremium {
    return Intl.message(
      'View Premium',
      name: 'settingsViewPremium',
      desc: '',
      args: [],
    );
  }

  /// `Activate MacroTracker Premium`
  String get settingsActivatePremium {
    return Intl.message(
      'Activate MacroTracker Premium',
      name: 'settingsActivatePremium',
      desc: '',
      args: [],
    );
  }

  /// `Your subscription is active on this device.`
  String get settingsSubscriptionActive {
    return Intl.message(
      'Your subscription is active on this device.',
      name: 'settingsSubscriptionActive',
      desc: '',
      args: [],
    );
  }

  /// `Founding Member`
  String get settingsFoundingMember {
    return Intl.message(
      'Founding Member',
      name: 'settingsFoundingMember',
      desc: '',
      args: [],
    );
  }

  /// `Invite friends`
  String get settingsInviteFriendsTitle {
    return Intl.message(
      'Invite friends',
      name: 'settingsInviteFriendsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Share your invitation code with a friend and you both get extra free AI uses when they redeem it.`
  String get settingsInviteFriendsBody {
    return Intl.message(
      'Share your invitation code with a friend and you both get extra free AI uses when they redeem it.',
      name: 'settingsInviteFriendsBody',
      desc: '',
      args: [],
    );
  }

  /// `YOUR REFERRAL CODE`
  String get settingsReferralCodeLabel {
    return Intl.message(
      'YOUR REFERRAL CODE',
      name: 'settingsReferralCodeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Invitation link and code copied to clipboard.`
  String get settingsReferralCopiedMessage {
    return Intl.message(
      'Invitation link and code copied to clipboard.',
      name: 'settingsReferralCopiedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get settingsCopyReferralTooltip {
    return Intl.message(
      'Copy',
      name: 'settingsCopyReferralTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Try MacroTracker! Log meals with AI in seconds. Use my referral code: {code} and we both get extra free AI uses. {url}`
  String settingsReferralShareMessage(Object code, Object url) {
    return Intl.message(
      'Try MacroTracker! Log meals with AI in seconds. Use my referral code: $code and we both get extra free AI uses. $url',
      name: 'settingsReferralShareMessage',
      desc: '',
      args: [code, url],
    );
  }

  /// `You have already redeemed an invitation code.`
  String get settingsReferralAlreadyRedeemedMessage {
    return Intl.message(
      'You have already redeemed an invitation code.',
      name: 'settingsReferralAlreadyRedeemedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Were you invited by a friend?`
  String get settingsInvitedByFriendQuestion {
    return Intl.message(
      'Were you invited by a friend?',
      name: 'settingsInvitedByFriendQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Enter their code`
  String get settingsEnterReferralCodeHint {
    return Intl.message(
      'Enter their code',
      name: 'settingsEnterReferralCodeHint',
      desc: '',
      args: [],
    );
  }

  /// `Redeem`
  String get settingsRedeemReferralButton {
    return Intl.message(
      'Redeem',
      name: 'settingsRedeemReferralButton',
      desc: '',
      args: [],
    );
  }

  /// `Code redeemed successfully. You earned free AI uses.`
  String get settingsReferralRedeemSuccess {
    return Intl.message(
      'Code redeemed successfully. You earned free AI uses.',
      name: 'settingsReferralRedeemSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Invitation code not found.`
  String get settingsReferralCodeNotFound {
    return Intl.message(
      'Invitation code not found.',
      name: 'settingsReferralCodeNotFound',
      desc: '',
      args: [],
    );
  }

  /// `You cannot redeem your own code.`
  String get settingsReferralSelfReferral {
    return Intl.message(
      'You cannot redeem your own code.',
      name: 'settingsReferralSelfReferral',
      desc: '',
      args: [],
    );
  }

  /// `Log in to redeem codes.`
  String get settingsReferralLoginRequired {
    return Intl.message(
      'Log in to redeem codes.',
      name: 'settingsReferralLoginRequired',
      desc: '',
      args: [],
    );
  }

  /// `Error redeeming code. Please try again.`
  String get settingsReferralRedeemError {
    return Intl.message(
      'Error redeeming code. Please try again.',
      name: 'settingsReferralRedeemError',
      desc: '',
      args: [],
    );
  }

  /// `Purchases restored.`
  String get settingsPurchasesRestored {
    return Intl.message(
      'Purchases restored.',
      name: 'settingsPurchasesRestored',
      desc: '',
      args: [],
    );
  }

  /// `DELETE`
  String get settingsDeleteConfirmationTarget {
    return Intl.message(
      'DELETE',
      name: 'settingsDeleteConfirmationTarget',
      desc: '',
      args: [],
    );
  }

  /// `Delete cloud account and data?`
  String get settingsDeleteConfirmTitle {
    return Intl.message(
      'Delete cloud account and data?',
      name: 'settingsDeleteConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `This action is irreversible. MacroTracker will first delete your current cloud account and its linked remote data. Only after that succeeds will it erase the local data on this device.`
  String get settingsDeleteConfirmBody {
    return Intl.message(
      'This action is irreversible. MacroTracker will first delete your current cloud account and its linked remote data. Only after that succeeds will it erase the local data on this device.',
      name: 'settingsDeleteConfirmBody',
      desc: '',
      args: [],
    );
  }

  /// `If cloud deletion fails, MacroTracker will not show the account as deleted and your local device data will be kept.`
  String get settingsDeleteConfirmFailureGuard {
    return Intl.message(
      'If cloud deletion fails, MacroTracker will not show the account as deleted and your local device data will be kept.',
      name: 'settingsDeleteConfirmFailureGuard',
      desc: '',
      args: [],
    );
  }

  /// `To confirm, type "{target}" in the box below:`
  String settingsDeleteConfirmTypePrompt(String target) {
    return Intl.message(
      'To confirm, type "$target" in the box below:',
      name: 'settingsDeleteConfirmTypePrompt',
      desc: '',
      args: [target],
    );
  }

  /// `Your cloud session is no longer valid. Sign in again and repeat the deletion.`
  String get settingsDeleteErrorSessionInvalid {
    return Intl.message(
      'Your cloud session is no longer valid. Sign in again and repeat the deletion.',
      name: 'settingsDeleteErrorSessionInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Could not reach the cloud service. Check the connection and try again.`
  String get settingsDeleteErrorCloudUnreachable {
    return Intl.message(
      'Could not reach the cloud service. Check the connection and try again.',
      name: 'settingsDeleteErrorCloudUnreachable',
      desc: '',
      args: [],
    );
  }

  /// `Could not delete the cloud account right now. Local data has been kept on this device.`
  String get settingsDeleteErrorLocalKept {
    return Intl.message(
      'Could not delete the cloud account right now. Local data has been kept on this device.',
      name: 'settingsDeleteErrorLocalKept',
      desc: '',
      args: [],
    );
  }

  /// `Could not delete the cloud account right now.`
  String get settingsDeleteErrorGeneric {
    return Intl.message(
      'Could not delete the cloud account right now.',
      name: 'settingsDeleteErrorGeneric',
      desc: '',
      args: [],
    );
  }

  /// `Identity for recovery and nutritionist connections`
  String get settingsCloudIdentityFallback {
    return Intl.message(
      'Identity for recovery and nutritionist connections',
      name: 'settingsCloudIdentityFallback',
      desc: '',
      args: [],
    );
  }

  /// `Protect your account and configure backups.`
  String get settingsProtectAccountBackupsBody {
    return Intl.message(
      'Protect your account and configure backups.',
      name: 'settingsProtectAccountBackupsBody',
      desc: '',
      args: [],
    );
  }

  /// `Protected`
  String get settingsAccountProtectedStatus {
    return Intl.message(
      'Protected',
      name: 'settingsAccountProtectedStatus',
      desc: '',
      args: [],
    );
  }

  /// `No account`
  String get settingsNoAccountStatus {
    return Intl.message(
      'No account',
      name: 'settingsNoAccountStatus',
      desc: '',
      args: [],
    );
  }

  /// `Google account`
  String get settingsGoogleAccountTitle {
    return Intl.message(
      'Google account',
      name: 'settingsGoogleAccountTitle',
      desc: '',
      args: [],
    );
  }

  /// `Link Google to recover your account.`
  String get settingsGoogleAccountBody {
    return Intl.message(
      'Link Google to recover your account.',
      name: 'settingsGoogleAccountBody',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get settingsActiveStatus {
    return Intl.message(
      'Active',
      name: 'settingsActiveStatus',
      desc: '',
      args: [],
    );
  }

  /// `Not linked`
  String get settingsNotLinkedStatus {
    return Intl.message(
      'Not linked',
      name: 'settingsNotLinkedStatus',
      desc: '',
      args: [],
    );
  }

  /// `Store an encrypted copy in your own Drive.`
  String get settingsGoogleDriveBackupBody {
    return Intl.message(
      'Store an encrypted copy in your own Drive.',
      name: 'settingsGoogleDriveBackupBody',
      desc: '',
      args: [],
    );
  }

  /// `Export ZIP`
  String get settingsExportZipTitle {
    return Intl.message(
      'Export ZIP',
      name: 'settingsExportZipTitle',
      desc: '',
      args: [],
    );
  }

  /// `Manual local copy to store or move data.`
  String get settingsExportZipBody {
    return Intl.message(
      'Manual local copy to store or move data.',
      name: 'settingsExportZipBody',
      desc: '',
      args: [],
    );
  }

  /// `Manual`
  String get settingsManualStatus {
    return Intl.message(
      'Manual',
      name: 'settingsManualStatus',
      desc: '',
      args: [],
    );
  }

  /// `Meal reminders`
  String get mealReminderTitle {
    return Intl.message(
      'Meal reminders',
      name: 'mealReminderTitle',
      desc: '',
      args: [],
    );
  }

  /// `Meal reminders`
  String get mealReminderChannelName {
    return Intl.message(
      'Meal reminders',
      name: 'mealReminderChannelName',
      desc: '',
      args: [],
    );
  }

  /// `Daily reminders to log your meals.`
  String get mealReminderChannelDescription {
    return Intl.message(
      'Daily reminders to log your meals.',
      name: 'mealReminderChannelDescription',
      desc: '',
      args: [],
    );
  }

  /// `Breakfast reminder`
  String get mealReminderBreakfastTitle {
    return Intl.message(
      'Breakfast reminder',
      name: 'mealReminderBreakfastTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do not forget to log your breakfast.`
  String get mealReminderBreakfastBody {
    return Intl.message(
      'Do not forget to log your breakfast.',
      name: 'mealReminderBreakfastBody',
      desc: '',
      args: [],
    );
  }

  /// `Lunch reminder`
  String get mealReminderLunchTitle {
    return Intl.message(
      'Lunch reminder',
      name: 'mealReminderLunchTitle',
      desc: '',
      args: [],
    );
  }

  /// `Log your lunch when you are done.`
  String get mealReminderLunchBody {
    return Intl.message(
      'Log your lunch when you are done.',
      name: 'mealReminderLunchBody',
      desc: '',
      args: [],
    );
  }

  /// `Snack reminder`
  String get mealReminderSnackTitle {
    return Intl.message(
      'Snack reminder',
      name: 'mealReminderSnackTitle',
      desc: '',
      args: [],
    );
  }

  /// `You can still log your snack.`
  String get mealReminderSnackBody {
    return Intl.message(
      'You can still log your snack.',
      name: 'mealReminderSnackBody',
      desc: '',
      args: [],
    );
  }

  /// `Dinner reminder`
  String get mealReminderDinnerTitle {
    return Intl.message(
      'Dinner reminder',
      name: 'mealReminderDinnerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Close the day by logging dinner.`
  String get mealReminderDinnerBody {
    return Intl.message(
      'Close the day by logging dinner.',
      name: 'mealReminderDinnerBody',
      desc: '',
      args: [],
    );
  }

  /// `Disabled`
  String get mealReminderDisabledStatus {
    return Intl.message(
      'Disabled',
      name: 'mealReminderDisabledStatus',
      desc: '',
      args: [],
    );
  }

  /// `Enable reminders`
  String get mealReminderEnableLabel {
    return Intl.message(
      'Enable reminders',
      name: 'mealReminderEnableLabel',
      desc: '',
      args: [],
    );
  }

  /// `Android will remind you to log breakfast, lunch, snack, and dinner.`
  String get mealReminderSubtitle {
    return Intl.message(
      'Android will remind you to log breakfast, lunch, snack, and dinner.',
      name: 'mealReminderSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Morning`
  String get mealReminderMorning {
    return Intl.message(
      'Morning',
      name: 'mealReminderMorning',
      desc: '',
      args: [],
    );
  }

  /// `After lunch`
  String get mealReminderAfterLunch {
    return Intl.message(
      'After lunch',
      name: 'mealReminderAfterLunch',
      desc: '',
      args: [],
    );
  }

  /// `Afternoon`
  String get mealReminderAfternoon {
    return Intl.message(
      'Afternoon',
      name: 'mealReminderAfternoon',
      desc: '',
      args: [],
    );
  }

  /// `Dinner`
  String get mealReminderDinner {
    return Intl.message(
      'Dinner',
      name: 'mealReminderDinner',
      desc: '',
      args: [],
    );
  }

  /// `Reminders saved and scheduled.`
  String get mealReminderSavedMessage {
    return Intl.message(
      'Reminders saved and scheduled.',
      name: 'mealReminderSavedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Reminders disabled.`
  String get mealReminderDisabledMessage {
    return Intl.message(
      'Reminders disabled.',
      name: 'mealReminderDisabledMessage',
      desc: '',
      args: [],
    );
  }

  /// `Could not enable reminders because Android permission was denied.`
  String get mealReminderPermissionDeniedMessage {
    return Intl.message(
      'Could not enable reminders because Android permission was denied.',
      name: 'mealReminderPermissionDeniedMessage',
      desc: '',
      args: [],
    );
  }

  /// `{integration} is not available on this device.`
  String healthStatusUnavailableName(Object integration) {
    return Intl.message(
      '$integration is not available on this device.',
      name: 'healthStatusUnavailableName',
      desc: '',
      args: [integration],
    );
  }

  /// `{integration} connected. If sync fails, review permissions.`
  String healthStatusPermissionsReview(Object integration) {
    return Intl.message(
      '$integration connected. If sync fails, review permissions.',
      name: 'healthStatusPermissionsReview',
      desc: '',
      args: [integration],
    );
  }

  /// `Apple Health auto-sync`
  String get appleHealthAutoSyncTitle {
    return Intl.message(
      'Apple Health auto-sync',
      name: 'appleHealthAutoSyncTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sync sleep, steps, and workouts automatically on app open.`
  String get appleHealthAutoSyncSubtitle {
    return Intl.message(
      'Sync sleep, steps, and workouts automatically on app open.',
      name: 'appleHealthAutoSyncSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Sync Apple Health now`
  String get appleHealthSyncNowTitle {
    return Intl.message(
      'Sync Apple Health now',
      name: 'appleHealthSyncNowTitle',
      desc: '',
      args: [],
    );
  }

  /// `Apple Health auto-sync enabled.`
  String get appleHealthAutoSyncEnabledMessage {
    return Intl.message(
      'Apple Health auto-sync enabled.',
      name: 'appleHealthAutoSyncEnabledMessage',
      desc: '',
      args: [],
    );
  }

  /// `Apple Health auto-sync disabled.`
  String get appleHealthAutoSyncDisabledMessage {
    return Intl.message(
      'Apple Health auto-sync disabled.',
      name: 'appleHealthAutoSyncDisabledMessage',
      desc: '',
      args: [],
    );
  }

  /// `{integration} connected. If sync fails, review permissions.`
  String healthStatusReviewPermissions(Object integration) {
    return Intl.message(
      '$integration connected. If sync fails, review permissions.',
      name: 'healthStatusReviewPermissions',
      desc: '',
      args: [integration],
    );
  }

  /// `Steps permission missing. Sync will be partial.`
  String get healthStatusStepsPermissionMissing {
    return Intl.message(
      'Steps permission missing. Sync will be partial.',
      name: 'healthStatusStepsPermissionMissing',
      desc: '',
      args: [],
    );
  }

  /// `Workout detail permissions missing. Some calories may stay at 0.`
  String get healthStatusWorkoutPermissionMissing {
    return Intl.message(
      'Workout detail permissions missing. Some calories may stay at 0.',
      name: 'healthStatusWorkoutPermissionMissing',
      desc: '',
      args: [],
    );
  }

  /// `{integration} connected. Sleep, steps, and workouts can sync automatically.`
  String healthStatusReadyName(Object integration) {
    return Intl.message(
      '$integration connected. Sleep, steps, and workouts can sync automatically.',
      name: 'healthStatusReadyName',
      desc: '',
      args: [integration],
    );
  }

  /// `Your {integration} data is already up to date.`
  String healthSyncAlreadyCurrent(Object integration) {
    return Intl.message(
      'Your $integration data is already up to date.',
      name: 'healthSyncAlreadyCurrent',
      desc: '',
      args: [integration],
    );
  }

  /// `{integration}: {imported} new workouts and {updated} updated.`
  String healthSyncWorkoutSummary(
      Object integration, Object imported, Object updated) {
    return Intl.message(
      '$integration: $imported new workouts and $updated updated.',
      name: 'healthSyncWorkoutSummary',
      desc: '',
      args: [integration, imported, updated],
    );
  }

  /// `{integration} data successfully synced.`
  String healthSyncSuccessName(Object integration) {
    return Intl.message(
      '$integration data successfully synced.',
      name: 'healthSyncSuccessName',
      desc: '',
      args: [integration],
    );
  }

  /// `MacroTracker Premium is active.`
  String get paywallPremiumActive {
    return Intl.message(
      'MacroTracker Premium is active.',
      name: 'paywallPremiumActive',
      desc: '',
      args: [],
    );
  }

  /// `The purchase could not be completed.`
  String get paywallPurchaseFailed {
    return Intl.message(
      'The purchase could not be completed.',
      name: 'paywallPurchaseFailed',
      desc: '',
      args: [],
    );
  }

  /// `No active purchases were found.`
  String get paywallNoActivePurchases {
    return Intl.message(
      'No active purchases were found.',
      name: 'paywallNoActivePurchases',
      desc: '',
      args: [],
    );
  }

  /// `Complete Google and return to MacroTracker.`
  String get paywallGoogleComplete {
    return Intl.message(
      'Complete Google and return to MacroTracker.',
      name: 'paywallGoogleComplete',
      desc: '',
      args: [],
    );
  }

  /// `Could not open Google.`
  String get paywallGoogleOpenFailed {
    return Intl.message(
      'Could not open Google.',
      name: 'paywallGoogleOpenFailed',
      desc: '',
      args: [],
    );
  }

  /// `Could not start Google linking.`
  String get paywallGoogleLinkStartFailed {
    return Intl.message(
      'Could not start Google linking.',
      name: 'paywallGoogleLinkStartFailed',
      desc: '',
      args: [],
    );
  }

  /// `Unlock your remaining free uses with Google`
  String get paywallUnlockFreeUsesTitle {
    return Intl.message(
      'Unlock your remaining free uses with Google',
      name: 'paywallUnlockFreeUsesTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have used the guest allowance. Protect your account and unlock {count} more free uses without losing progress.`
  String paywallUnlockFreeUsesBody(Object count) {
    return Intl.message(
      'You have used the guest allowance. Protect your account and unlock $count more free uses without losing progress.',
      name: 'paywallUnlockFreeUsesBody',
      desc: '',
      args: [count],
    );
  }

  /// `Protect with Google`
  String get paywallProtectWithGoogle {
    return Intl.message(
      'Protect with Google',
      name: 'paywallProtectWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Premium plans are not available right now.`
  String get paywallPremiumUnavailable {
    return Intl.message(
      'Premium plans are not available right now.',
      name: 'paywallPremiumUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Premium is not configured for this build. Please contact support.`
  String get paywallPremiumNotConfigured {
    return Intl.message(
      'Premium is not configured for this build. Please contact support.',
      name: 'paywallPremiumNotConfigured',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Use (EULA)`
  String get paywallTermsOfUseEula {
    return Intl.message(
      'Terms of Use (EULA)',
      name: 'paywallTermsOfUseEula',
      desc: '',
      args: [],
    );
  }

  /// `Best value for AI meal logging all year.`
  String get paywallBestAnnualValue {
    return Intl.message(
      'Best value for AI meal logging all year.',
      name: 'paywallBestAnnualValue',
      desc: '',
      args: [],
    );
  }

  /// `Trial used`
  String get paywallTrialUsedBadge {
    return Intl.message(
      'Trial used',
      name: 'paywallTrialUsedBadge',
      desc: '',
      args: [],
    );
  }

  /// `{count} AI meals saved`
  String paywallAiMealsSavedBadge(Object count) {
    return Intl.message(
      '$count AI meals saved',
      name: 'paywallAiMealsSavedBadge',
      desc: '',
      args: [count],
    );
  }

  /// `{count} AI meals saved. {minutes} min saved.`
  String paywallUsageValueStrip(Object count, Object minutes) {
    return Intl.message(
      '$count AI meals saved. $minutes min saved.',
      name: 'paywallUsageValueStrip',
      desc: '',
      args: [count, minutes],
    );
  }

  /// `{count} AI trials remaining`
  String paywallTrialRemainingBadge(Object count) {
    return Intl.message(
      '$count AI trials remaining',
      name: 'paywallTrialRemainingBadge',
      desc: '',
      args: [count],
    );
  }

  /// `AI meal drafts from text and photos`
  String get paywallBenefitAiDrafts {
    return Intl.message(
      'AI meal drafts from text and photos',
      name: 'paywallBenefitAiDrafts',
      desc: '',
      args: [],
    );
  }

  /// `Editable review before saving`
  String get paywallBenefitEditableReview {
    return Intl.message(
      'Editable review before saving',
      name: 'paywallBenefitEditableReview',
      desc: '',
      args: [],
    );
  }

  /// `Faster macro and progress tracking`
  String get paywallBenefitFasterTracking {
    return Intl.message(
      'Faster macro and progress tracking',
      name: 'paywallBenefitFasterTracking',
      desc: '',
      args: [],
    );
  }

  /// `AI learns from your usual corrections`
  String get paywallBenefitLearnsCorrections {
    return Intl.message(
      'AI learns from your usual corrections',
      name: 'paywallBenefitLearnsCorrections',
      desc: '',
      args: [],
    );
  }

  /// `Concrete options to close today's macros`
  String get paywallBenefitCloseTodayMacros {
    return Intl.message(
      'Concrete options to close today\'s macros',
      name: 'paywallBenefitCloseTodayMacros',
      desc: '',
      args: [],
    );
  }

  /// `Servings adjusted to your remaining calories and protein`
  String get paywallBenefitAdjustedServings {
    return Intl.message(
      'Servings adjusted to your remaining calories and protein',
      name: 'paywallBenefitAdjustedServings',
      desc: '',
      args: [],
    );
  }

  /// `Log the recommendation to the right meal with one tap`
  String get paywallBenefitOneTapLog {
    return Intl.message(
      'Log the recommendation to the right meal with one tap',
      name: 'paywallBenefitOneTapLog',
      desc: '',
      args: [],
    );
  }

  /// `Explanation for why it fits today's goal`
  String get paywallBenefitGoalExplanation {
    return Intl.message(
      'Explanation for why it fits today\'s goal',
      name: 'paywallBenefitGoalExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Start Premium`
  String get paywallStartPremium {
    return Intl.message(
      'Start Premium',
      name: 'paywallStartPremium',
      desc: '',
      args: [],
    );
  }

  /// `Processing...`
  String get paywallProcessing {
    return Intl.message(
      'Processing...',
      name: 'paywallProcessing',
      desc: '',
      args: [],
    );
  }

  /// `Restore purchases`
  String get paywallRestorePurchases {
    return Intl.message(
      'Restore purchases',
      name: 'paywallRestorePurchases',
      desc: '',
      args: [],
    );
  }

  /// `You can keep using manual tracking for free.`
  String get paywallManualTrackingFooter {
    return Intl.message(
      'You can keep using manual tracking for free.',
      name: 'paywallManualTrackingFooter',
      desc: '',
      args: [],
    );
  }

  /// `Speed up your first log`
  String get paywallOnboardingTitle {
    return Intl.message(
      'Speed up your first log',
      name: 'paywallOnboardingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Premium unlocks AI that turns real meals into editable macros in seconds.`
  String get paywallOnboardingSubtitle {
    return Intl.message(
      'Premium unlocks AI that turns real meals into editable macros in seconds.',
      name: 'paywallOnboardingSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Launch offer`
  String get paywallLaunchOfferBadge {
    return Intl.message(
      'Launch offer',
      name: 'paywallLaunchOfferBadge',
      desc: '',
      args: [],
    );
  }

  /// `Turn text into macros`
  String get paywallAiTextTitle {
    return Intl.message(
      'Turn text into macros',
      name: 'paywallAiTextTitle',
      desc: '',
      args: [],
    );
  }

  /// `Describe a meal and review an editable draft before saving it.`
  String get paywallAiTextSubtitle {
    return Intl.message(
      'Describe a meal and review an editable draft before saving it.',
      name: 'paywallAiTextSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Log from a photo`
  String get paywallAiPhotoTitle {
    return Intl.message(
      'Log from a photo',
      name: 'paywallAiPhotoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Use camera or gallery to create an ingredient and macro draft.`
  String get paywallAiPhotoSubtitle {
    return Intl.message(
      'Use camera or gallery to create an ingredient and macro draft.',
      name: 'paywallAiPhotoSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Unlock unlimited AI logging`
  String get paywallAiLimitTitle {
    return Intl.message(
      'Unlock unlimited AI logging',
      name: 'paywallAiLimitTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have tried AI logging. Premium keeps the fast flow available.`
  String get paywallAiLimitSubtitle {
    return Intl.message(
      'You have tried AI logging. Premium keeps the fast flow available.',
      name: 'paywallAiLimitSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Unlock your Macro Coach`
  String get paywallMacroCoachTitle {
    return Intl.message(
      'Unlock your Macro Coach',
      name: 'paywallMacroCoachTitle',
      desc: '',
      args: [],
    );
  }

  /// `Premium turns your remaining macros into concrete meals, adjusted servings, and fast logging.`
  String get paywallMacroCoachSubtitle {
    return Intl.message(
      'Premium turns your remaining macros into concrete meals, adjusted servings, and fast logging.',
      name: 'paywallMacroCoachSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Premium recommendation`
  String get paywallPremiumRecommendationBadge {
    return Intl.message(
      'Premium recommendation',
      name: 'paywallPremiumRecommendationBadge',
      desc: '',
      args: [],
    );
  }

  /// `Turn your data into adjustments`
  String get paywallWeeklyInsightsTitle {
    return Intl.message(
      'Turn your data into adjustments',
      name: 'paywallWeeklyInsightsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Premium combines AI, adherence, and progress to decide what to change this week.`
  String get paywallWeeklyInsightsSubtitle {
    return Intl.message(
      'Premium combines AI, adherence, and progress to decide what to change this week.',
      name: 'paywallWeeklyInsightsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Best with 3+ days`
  String get paywallBestWithThreeDaysBadge {
    return Intl.message(
      'Best with 3+ days',
      name: 'paywallBestWithThreeDaysBadge',
      desc: '',
      args: [],
    );
  }

  /// `Unlock AI meal interpretation from text and photos.`
  String get paywallSettingsSubtitle {
    return Intl.message(
      'Unlock AI meal interpretation from text and photos.',
      name: 'paywallSettingsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Launch annual offer`
  String get paywallLaunchAnnualOfferBadge {
    return Intl.message(
      'Launch annual offer',
      name: 'paywallLaunchAnnualOfferBadge',
      desc: '',
      args: [],
    );
  }

  /// `Health Connect auto-sync`
  String get healthConnectAutoSyncTitle {
    return Intl.message(
      'Health Connect auto-sync',
      name: 'healthConnectAutoSyncTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sync sleep, steps, and workouts automatically on app open.`
  String get healthConnectAutoSyncSubtitle {
    return Intl.message(
      'Sync sleep, steps, and workouts automatically on app open.',
      name: 'healthConnectAutoSyncSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Sync Health Connect now`
  String get healthConnectSyncNowTitle {
    return Intl.message(
      'Sync Health Connect now',
      name: 'healthConnectSyncNowTitle',
      desc: '',
      args: [],
    );
  }

  /// `Grant Health Connect permissions`
  String get healthConnectGrantPermissionsTitle {
    return Intl.message(
      'Grant Health Connect permissions',
      name: 'healthConnectGrantPermissionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Open the permission flow for sleep, steps, and workouts.`
  String get healthConnectGrantPermissionsSubtitle {
    return Intl.message(
      'Open the permission flow for sleep, steps, and workouts.',
      name: 'healthConnectGrantPermissionsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Checking Health Connect status...`
  String get healthConnectStatusChecking {
    return Intl.message(
      'Checking Health Connect status...',
      name: 'healthConnectStatusChecking',
      desc: '',
      args: [],
    );
  }

  /// `Health Connect is not available on this device.`
  String get healthConnectStatusUnavailable {
    return Intl.message(
      'Health Connect is not available on this device.',
      name: 'healthConnectStatusUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Health permissions are required to read sleep, steps, and workouts.`
  String get healthConnectStatusPermissionsRequired {
    return Intl.message(
      'Health permissions are required to read sleep, steps, and workouts.',
      name: 'healthConnectStatusPermissionsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Activity Recognition permission is required for steps.`
  String get healthConnectStatusActivityPermissionRequired {
    return Intl.message(
      'Activity Recognition permission is required for steps.',
      name: 'healthConnectStatusActivityPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Connected. Auto-sync is currently disabled.`
  String get healthConnectStatusAutoSyncDisabled {
    return Intl.message(
      'Connected. Auto-sync is currently disabled.',
      name: 'healthConnectStatusAutoSyncDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Connected. Sleep, steps, and workouts can sync automatically.`
  String get healthConnectStatusReady {
    return Intl.message(
      'Connected. Sleep, steps, and workouts can sync automatically.',
      name: 'healthConnectStatusReady',
      desc: '',
      args: [],
    );
  }

  /// `Health Connect auto-sync enabled.`
  String get healthConnectAutoSyncEnabledMessage {
    return Intl.message(
      'Health Connect auto-sync enabled.',
      name: 'healthConnectAutoSyncEnabledMessage',
      desc: '',
      args: [],
    );
  }

  /// `Health Connect auto-sync disabled.`
  String get healthConnectAutoSyncDisabledMessage {
    return Intl.message(
      'Health Connect auto-sync disabled.',
      name: 'healthConnectAutoSyncDisabledMessage',
      desc: '',
      args: [],
    );
  }

  /// `Health Connect permissions updated.`
  String get healthConnectPermissionsUpdated {
    return Intl.message(
      'Health Connect permissions updated.',
      name: 'healthConnectPermissionsUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Health Connect permissions are still missing.`
  String get healthConnectPermissionsMissing {
    return Intl.message(
      'Health Connect permissions are still missing.',
      name: 'healthConnectPermissionsMissing',
      desc: '',
      args: [],
    );
  }

  /// `Health Connect data synced, including workouts.`
  String get healthConnectSyncSuccess {
    return Intl.message(
      'Health Connect data synced, including workouts.',
      name: 'healthConnectSyncSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No new Health Connect data or workouts were imported.`
  String get healthConnectSyncNoChanges {
    return Intl.message(
      'No new Health Connect data or workouts were imported.',
      name: 'healthConnectSyncNoChanges',
      desc: '',
      args: [],
    );
  }

  /// `Health Connect`
  String get habitSourceHealthConnect {
    return Intl.message(
      'Health Connect',
      name: 'habitSourceHealthConnect',
      desc: '',
      args: [],
    );
  }

  /// `Manual`
  String get habitSourceManual {
    return Intl.message(
      'Manual',
      name: 'habitSourceManual',
      desc: '',
      args: [],
    );
  }

  /// `Synced source`
  String get habitSourceSynced {
    return Intl.message(
      'Synced source',
      name: 'habitSourceSynced',
      desc: '',
      args: [],
    );
  }

  /// `Manual adjustment`
  String get habitSourceManualAdjust {
    return Intl.message(
      'Manual adjustment',
      name: 'habitSourceManualAdjust',
      desc: '',
      args: [],
    );
  }

  /// `Habits and recovery`
  String get gymHabitsTitle {
    return Intl.message(
      'Habits and recovery',
      name: 'gymHabitsTitle',
      desc: '',
      args: [],
    );
  }

  /// `{count}/7 today`
  String gymHabitsCompletedToday(Object count) {
    return Intl.message(
      '$count/7 today',
      name: 'gymHabitsCompletedToday',
      desc: '',
      args: [count],
    );
  }

  /// `Sleep`
  String get gymHabitsSleepTitle {
    return Intl.message(
      'Sleep',
      name: 'gymHabitsSleepTitle',
      desc: '',
      args: [],
    );
  }

  /// `Steps`
  String get gymHabitsStepsTitle {
    return Intl.message(
      'Steps',
      name: 'gymHabitsStepsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Energy`
  String get gymHabitsEnergyTitle {
    return Intl.message(
      'Energy',
      name: 'gymHabitsEnergyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Goal {amount} h`
  String gymHabitsSleepTarget(Object amount) {
    return Intl.message(
      'Goal $amount h',
      name: 'gymHabitsSleepTarget',
      desc: '',
      args: [amount],
    );
  }

  /// `Goal {amount}`
  String gymHabitsStepsTarget(Object amount) {
    return Intl.message(
      'Goal $amount',
      name: 'gymHabitsStepsTarget',
      desc: '',
      args: [amount],
    );
  }

  /// `Main value from Health Connect`
  String get gymHabitsSourceHealthConnectDetail {
    return Intl.message(
      'Main value from Health Connect',
      name: 'gymHabitsSourceHealthConnectDetail',
      desc: '',
      args: [],
    );
  }

  /// `Main value entered manually`
  String get gymHabitsSourceManualDetail {
    return Intl.message(
      'Main value entered manually',
      name: 'gymHabitsSourceManualDetail',
      desc: '',
      args: [],
    );
  }

  /// `Use +/- only if you need to correct the value.`
  String get gymHabitsManualAdjustHint {
    return Intl.message(
      'Use +/- only if you need to correct the value.',
      name: 'gymHabitsManualAdjustHint',
      desc: '',
      args: [],
    );
  }

  /// `Quick category`
  String get recipeQuickCategoryLabel {
    return Intl.message(
      'Quick category',
      name: 'recipeQuickCategoryLabel',
      desc: '',
      args: [],
    );
  }

  /// `Pre-workout`
  String get quickCategoryPreWorkout {
    return Intl.message(
      'Pre-workout',
      name: 'quickCategoryPreWorkout',
      desc: '',
      args: [],
    );
  }

  /// `Post-workout`
  String get quickCategoryPostWorkout {
    return Intl.message(
      'Post-workout',
      name: 'quickCategoryPostWorkout',
      desc: '',
      args: [],
    );
  }

  /// `Shake`
  String get quickCategoryShake {
    return Intl.message(
      'Shake',
      name: 'quickCategoryShake',
      desc: '',
      args: [],
    );
  }

  /// `Light meal`
  String get quickCategoryLeanMeal {
    return Intl.message(
      'Light meal',
      name: 'quickCategoryLeanMeal',
      desc: '',
      args: [],
    );
  }

  /// `Leg day`
  String get gymHabitsFocusLowerBody {
    return Intl.message(
      'Leg day',
      name: 'gymHabitsFocusLowerBody',
      desc: '',
      args: [],
    );
  }

  /// `Upper body day`
  String get gymHabitsFocusUpperBody {
    return Intl.message(
      'Upper body day',
      name: 'gymHabitsFocusUpperBody',
      desc: '',
      args: [],
    );
  }

  /// `Cardio day`
  String get gymHabitsFocusCardio {
    return Intl.message(
      'Cardio day',
      name: 'gymHabitsFocusCardio',
      desc: '',
      args: [],
    );
  }

  /// `Rest day`
  String get gymHabitsFocusRest {
    return Intl.message(
      'Rest day',
      name: 'gymHabitsFocusRest',
      desc: '',
      args: [],
    );
  }

  /// `Higher hydration target for leg day: {goal}.`
  String gymHabitsHydrationHintLowerBody(Object goal) {
    return Intl.message(
      'Higher hydration target for leg day: $goal.',
      name: 'gymHabitsHydrationHintLowerBody',
      desc: '',
      args: [goal],
    );
  }

  /// `Keep hydration high today: {goal}.`
  String gymHabitsHydrationHintUpperBody(Object goal) {
    return Intl.message(
      'Keep hydration high today: $goal.',
      name: 'gymHabitsHydrationHintUpperBody',
      desc: '',
      args: [goal],
    );
  }

  /// `Prioritize fluids today: {goal}.`
  String gymHabitsHydrationHintCardio(Object goal) {
    return Intl.message(
      'Prioritize fluids today: $goal.',
      name: 'gymHabitsHydrationHintCardio',
      desc: '',
      args: [goal],
    );
  }

  /// `Keep hydration steady today: {goal}.`
  String gymHabitsHydrationHintRest(Object goal) {
    return Intl.message(
      'Keep hydration steady today: $goal.',
      name: 'gymHabitsHydrationHintRest',
      desc: '',
      args: [goal],
    );
  }

  /// `Check averages, adherence, protein and top meals`
  String get homeWeeklyInsightsSubtitle {
    return Intl.message(
      'Check averages, adherence, protein and top meals',
      name: 'homeWeeklyInsightsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Barcode`
  String get addMealBarcode {
    return Intl.message(
      'Barcode',
      name: 'addMealBarcode',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get addMealText {
    return Intl.message(
      'Text',
      name: 'addMealText',
      desc: '',
      args: [],
    );
  }

  /// `Photo`
  String get addMealPhoto {
    return Intl.message(
      'Photo',
      name: 'addMealPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Saved`
  String get addMealSaved {
    return Intl.message(
      'Saved',
      name: 'addMealSaved',
      desc: '',
      args: [],
    );
  }

  /// `Quick meals`
  String get quickMealsTitle {
    return Intl.message(
      'Quick meals',
      name: 'quickMealsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Use your saved recipes first. One tap logs a serving fast.`
  String get quickMealsSubtitle {
    return Intl.message(
      'Use your saved recipes first. One tap logs a serving fast.',
      name: 'quickMealsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Open saved meals`
  String get quickMealsSavedTooltip {
    return Intl.message(
      'Open saved meals',
      name: 'quickMealsSavedTooltip',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get quickMealsFilterAll {
    return Intl.message(
      'All',
      name: 'quickMealsFilterAll',
      desc: '',
      args: [],
    );
  }

  /// `Before workout`
  String get quickMealsFilterPreWorkout {
    return Intl.message(
      'Before workout',
      name: 'quickMealsFilterPreWorkout',
      desc: '',
      args: [],
    );
  }

  /// `After workout`
  String get quickMealsFilterPostWorkout {
    return Intl.message(
      'After workout',
      name: 'quickMealsFilterPostWorkout',
      desc: '',
      args: [],
    );
  }

  /// `Shake`
  String get quickMealsFilterShake {
    return Intl.message(
      'Shake',
      name: 'quickMealsFilterShake',
      desc: '',
      args: [],
    );
  }

  /// `Light meal`
  String get quickMealsFilterLight {
    return Intl.message(
      'Light meal',
      name: 'quickMealsFilterLight',
      desc: '',
      args: [],
    );
  }

  /// `Save meals as recipes to keep them one tap away here.`
  String get quickMealsEmptyAll {
    return Intl.message(
      'Save meals as recipes to keep them one tap away here.',
      name: 'quickMealsEmptyAll',
      desc: '',
      args: [],
    );
  }

  /// `No quick meals in this lane yet. Use clear workout-style names so they are easier to recognize later.`
  String get quickMealsEmptyFiltered {
    return Intl.message(
      'No quick meals in this lane yet. Use clear workout-style names so they are easier to recognize later.',
      name: 'quickMealsEmptyFiltered',
      desc: '',
      args: [],
    );
  }

  /// `{recipe} added to {slot}`
  String quickMealsAddedTo(Object recipe, Object slot) {
    return Intl.message(
      '$recipe added to $slot',
      name: 'quickMealsAddedTo',
      desc: '',
      args: [recipe, slot],
    );
  }

  /// `Log one serving`
  String get quickMealsLogServing {
    return Intl.message(
      'Log one serving',
      name: 'quickMealsLogServing',
      desc: '',
      args: [],
    );
  }

  /// `P {amount}`
  String quickMealsProteinShort(Object amount) {
    return Intl.message(
      'P $amount',
      name: 'quickMealsProteinShort',
      desc: '',
      args: [amount],
    );
  }

  /// `C {carbs} | F {fat} | P {protein}`
  String quickMealsMacrosSummary(Object carbs, Object fat, Object protein) {
    return Intl.message(
      'C $carbs | F $fat | P $protein',
      name: 'quickMealsMacrosSummary',
      desc: '',
      args: [carbs, fat, protein],
    );
  }

  /// `Day copied to today`
  String get diaryDayCopied {
    return Intl.message(
      'Day copied to today',
      name: 'diaryDayCopied',
      desc: '',
      args: [],
    );
  }

  /// `Current week`
  String get diaryCurrentWeek {
    return Intl.message(
      'Current week',
      name: 'diaryCurrentWeek',
      desc: '',
      args: [],
    );
  }

  /// `{percent}% adherence`
  String diaryAdherencePill(Object percent) {
    return Intl.message(
      '$percent% adherence',
      name: 'diaryAdherencePill',
      desc: '',
      args: [percent],
    );
  }

  /// `{amount}g avg protein`
  String diaryProteinPill(Object amount) {
    return Intl.message(
      '${amount}g avg protein',
      name: 'diaryProteinPill',
      desc: '',
      args: [amount],
    );
  }

  /// `{count}/7 days`
  String diaryDaysPill(Object count) {
    return Intl.message(
      '$count/7 days',
      name: 'diaryDaysPill',
      desc: '',
      args: [count],
    );
  }

  /// `adherence`
  String get diaryWeeklyAdherenceLabel {
    return Intl.message(
      'adherence',
      name: 'diaryWeeklyAdherenceLabel',
      desc: '',
      args: [],
    );
  }

  /// `protein`
  String get diaryWeeklyProteinLabel {
    return Intl.message(
      'protein',
      name: 'diaryWeeklyProteinLabel',
      desc: '',
      args: [],
    );
  }

  /// `days`
  String get diaryWeeklyDaysLabel {
    return Intl.message(
      'days',
      name: 'diaryWeeklyDaysLabel',
      desc: '',
      args: [],
    );
  }

  /// `Selected day`
  String get diarySelectedDayLabel {
    return Intl.message(
      'Selected day',
      name: 'diarySelectedDayLabel',
      desc: '',
      args: [],
    );
  }

  /// `Previous day`
  String get diaryPreviousDayTooltip {
    return Intl.message(
      'Previous day',
      name: 'diaryPreviousDayTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Next day`
  String get diaryNextDayTooltip {
    return Intl.message(
      'Next day',
      name: 'diaryNextDayTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Day summary`
  String get diarySummaryTitle {
    return Intl.message(
      'Day summary',
      name: 'diarySummaryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Copy day to today`
  String get diaryCopyDayToToday {
    return Intl.message(
      'Copy day to today',
      name: 'diaryCopyDayToToday',
      desc: '',
      args: [],
    );
  }

  /// `No logs for this day`
  String get diaryEmptyDayTitle {
    return Intl.message(
      'No logs for this day',
      name: 'diaryEmptyDayTitle',
      desc: '',
      args: [],
    );
  }

  /// `There are no meals or activities on this day yet.`
  String get diaryEmptyDaySubtitle {
    return Intl.message(
      'There are no meals or activities on this day yet.',
      name: 'diaryEmptyDaySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Add meal`
  String get diaryAddMealAction {
    return Intl.message(
      'Add meal',
      name: 'diaryAddMealAction',
      desc: '',
      args: [],
    );
  }

  /// `In goal`
  String get diaryInGoal {
    return Intl.message(
      'In goal',
      name: 'diaryInGoal',
      desc: '',
      args: [],
    );
  }

  /// `{amount} kcal remaining`
  String diaryKcalRemaining(Object amount) {
    return Intl.message(
      '$amount kcal remaining',
      name: 'diaryKcalRemaining',
      desc: '',
      args: [amount],
    );
  }

  /// `+{amount} kcal`
  String diaryKcalOver(Object amount) {
    return Intl.message(
      '+$amount kcal',
      name: 'diaryKcalOver',
      desc: '',
      args: [amount],
    );
  }

  /// `Goal reached`
  String get diaryGoalReached {
    return Intl.message(
      'Goal reached',
      name: 'diaryGoalReached',
      desc: '',
      args: [],
    );
  }

  /// `{amount} g remaining`
  String diaryGramsRemaining(Object amount) {
    return Intl.message(
      '$amount g remaining',
      name: 'diaryGramsRemaining',
      desc: '',
      args: [amount],
    );
  }

  /// `{count} meals`
  String diaryMealsPill(Object count) {
    return Intl.message(
      '$count meals',
      name: 'diaryMealsPill',
      desc: '',
      args: [count],
    );
  }

  /// `{count} activities`
  String diaryActivitiesPill(Object count) {
    return Intl.message(
      '$count activities',
      name: 'diaryActivitiesPill',
      desc: '',
      args: [count],
    );
  }

  /// `In range`
  String get diaryStatusInRange {
    return Intl.message(
      'In range',
      name: 'diaryStatusInRange',
      desc: '',
      args: [],
    );
  }

  /// `Below`
  String get diaryStatusBelow {
    return Intl.message(
      'Below',
      name: 'diaryStatusBelow',
      desc: '',
      args: [],
    );
  }

  /// `Above`
  String get diaryStatusAbove {
    return Intl.message(
      'Above',
      name: 'diaryStatusAbove',
      desc: '',
      args: [],
    );
  }

  /// `Carbs {carbsTracked}/{carbsGoal} g, fat {fatTracked}/{fatGoal} g, protein {proteinTracked}/{proteinGoal} g`
  String diaryMacrosSummary(
      Object carbsTracked,
      Object carbsGoal,
      Object fatTracked,
      Object fatGoal,
      Object proteinTracked,
      Object proteinGoal) {
    return Intl.message(
      'Carbs $carbsTracked/$carbsGoal g, fat $fatTracked/$fatGoal g, protein $proteinTracked/$proteinGoal g',
      name: 'diaryMacrosSummary',
      desc: '',
      args: [
        carbsTracked,
        carbsGoal,
        fatTracked,
        fatGoal,
        proteinTracked,
        proteinGoal
      ],
    );
  }

  /// `Empty`
  String get diaryEmptySection {
    return Intl.message(
      'Empty',
      name: 'diaryEmptySection',
      desc: '',
      args: [],
    );
  }

  /// `{count} items`
  String diaryElementsSection(Object count) {
    return Intl.message(
      '$count items',
      name: 'diaryElementsSection',
      desc: '',
      args: [count],
    );
  }

  /// `Meal actions`
  String get diaryQuickAmountTitle {
    return Intl.message(
      'Meal actions',
      name: 'diaryQuickAmountTitle',
      desc: '',
      args: [],
    );
  }

  /// `Adjust the logged amount in steps of {step} {unit}.`
  String diaryQuickAmountSubtitle(Object step, Object unit) {
    return Intl.message(
      'Adjust the logged amount in steps of $step $unit.',
      name: 'diaryQuickAmountSubtitle',
      desc: '',
      args: [step, unit],
    );
  }

  /// `Reduce amount`
  String get diaryQuickAmountDecrease {
    return Intl.message(
      'Reduce amount',
      name: 'diaryQuickAmountDecrease',
      desc: '',
      args: [],
    );
  }

  /// `Increase amount`
  String get diaryQuickAmountIncrease {
    return Intl.message(
      'Increase amount',
      name: 'diaryQuickAmountIncrease',
      desc: '',
      args: [],
    );
  }

  /// `Sports profile`
  String get profileSportsProfile {
    return Intl.message(
      'Sports profile',
      name: 'profileSportsProfile',
      desc: '',
      args: [],
    );
  }

  /// `Your profile`
  String get profileYourProfile {
    return Intl.message(
      'Your profile',
      name: 'profileYourProfile',
      desc: '',
      args: [],
    );
  }

  /// `Adjust your base data so that calories, macros and recommendations are consistent.`
  String get profileYourProfileSubtitle {
    return Intl.message(
      'Adjust your base data so that calories, macros and recommendations are consistent.',
      name: 'profileYourProfileSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Calculation base for goals, tracking and suggestions.`
  String get profileCalculationBase {
    return Intl.message(
      'Calculation base for goals, tracking and suggestions.',
      name: 'profileCalculationBase',
      desc: '',
      args: [],
    );
  }

  /// `Current phase: {phase}`
  String profileCurrentPhase(Object phase) {
    return Intl.message(
      'Current phase: $phase',
      name: 'profileCurrentPhase',
      desc: '',
      args: [phase],
    );
  }

  /// `Goal and strategy`
  String get profileGoalAndStrategy {
    return Intl.message(
      'Goal and strategy',
      name: 'profileGoalAndStrategy',
      desc: '',
      args: [],
    );
  }

  /// `What you change here impacts calories, macros and daily adjustments.`
  String get profileGoalAndStrategySubtitle {
    return Intl.message(
      'What you change here impacts calories, macros and daily adjustments.',
      name: 'profileGoalAndStrategySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Body progress`
  String get profileBodyProgress {
    return Intl.message(
      'Body progress',
      name: 'profileBodyProgress',
      desc: '',
      args: [],
    );
  }

  /// `Weight trend, 7d average and waist`
  String get profileBodyProgressSubtitle {
    return Intl.message(
      'Weight trend, 7d average and waist',
      name: 'profileBodyProgressSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Body data`
  String get profileBodyData {
    return Intl.message(
      'Body data',
      name: 'profileBodyData',
      desc: '',
      args: [],
    );
  }

  /// `Weight, height, age and sex so that the base calculation remains accurate.`
  String get profileBodyDataSubtitle {
    return Intl.message(
      'Weight, height, age and sex so that the base calculation remains accurate.',
      name: 'profileBodyDataSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Sex`
  String get profileGenderLabel {
    return Intl.message(
      'Sex',
      name: 'profileGenderLabel',
      desc: '',
      args: [],
    );
  }

  /// `Photo options`
  String get profilePhotoOptions {
    return Intl.message(
      'Photo options',
      name: 'profilePhotoOptions',
      desc: '',
      args: [],
    );
  }

  /// `Change photo`
  String get profileChangePhoto {
    return Intl.message(
      'Change photo',
      name: 'profileChangePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Remove photo`
  String get profileRemovePhoto {
    return Intl.message(
      'Remove photo',
      name: 'profileRemovePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Steps goal`
  String get profileStepsGoal {
    return Intl.message(
      'Steps goal',
      name: 'profileStepsGoal',
      desc: '',
      args: [],
    );
  }

  /// `Sleep hours goal`
  String get profileSleepGoal {
    return Intl.message(
      'Sleep hours goal',
      name: 'profileSleepGoal',
      desc: '',
      args: [],
    );
  }

  /// `Water goal`
  String get profileWaterGoal {
    return Intl.message(
      'Water goal',
      name: 'profileWaterGoal',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get profileDefaultTarget {
    return Intl.message(
      'Default',
      name: 'profileDefaultTarget',
      desc: '',
      args: [],
    );
  }

  /// `Daily steps goal`
  String get profileDailyStepsGoalTitle {
    return Intl.message(
      'Daily steps goal',
      name: 'profileDailyStepsGoalTitle',
      desc: '',
      args: [],
    );
  }

  /// `Set your daily steps goal. If left empty, the default value based on the day will be used.`
  String get profileDailyStepsGoalBody {
    return Intl.message(
      'Set your daily steps goal. If left empty, the default value based on the day will be used.',
      name: 'profileDailyStepsGoalBody',
      desc: '',
      args: [],
    );
  }

  /// `Steps target`
  String get profileStepsTargetLabel {
    return Intl.message(
      'Steps target',
      name: 'profileStepsTargetLabel',
      desc: '',
      args: [],
    );
  }

  /// `Sleep hours goal`
  String get profileSleepHoursGoalTitle {
    return Intl.message(
      'Sleep hours goal',
      name: 'profileSleepHoursGoalTitle',
      desc: '',
      args: [],
    );
  }

  /// `Set your daily sleep hours goal. If left empty, the default value based on the day will be used.`
  String get profileSleepHoursGoalBody {
    return Intl.message(
      'Set your daily sleep hours goal. If left empty, the default value based on the day will be used.',
      name: 'profileSleepHoursGoalBody',
      desc: '',
      args: [],
    );
  }

  /// `Sleep hours target`
  String get profileSleepHoursTargetLabel {
    return Intl.message(
      'Sleep hours target',
      name: 'profileSleepHoursTargetLabel',
      desc: '',
      args: [],
    );
  }

  /// `Daily water goal`
  String get profileDailyWaterGoalTitle {
    return Intl.message(
      'Daily water goal',
      name: 'profileDailyWaterGoalTitle',
      desc: '',
      args: [],
    );
  }

  /// `Set your daily water goal ({unit}). If left empty, the default value based on the day will be used.`
  String profileDailyWaterGoalBody(Object unit) {
    return Intl.message(
      'Set your daily water goal ($unit). If left empty, the default value based on the day will be used.',
      name: 'profileDailyWaterGoalBody',
      desc: '',
      args: [unit],
    );
  }

  /// `Water target ({unit})`
  String profileWaterTargetLabel(Object unit) {
    return Intl.message(
      'Water target ($unit)',
      name: 'profileWaterTargetLabel',
      desc: '',
      args: [unit],
    );
  }

  /// `Targets recalculated. You can review the strategy.`
  String get profileTargetsRecalculatedSnack {
    return Intl.message(
      'Targets recalculated. You can review the strategy.',
      name: 'profileTargetsRecalculatedSnack',
      desc: '',
      args: [],
    );
  }

  /// `Review`
  String get profileReviewAction {
    return Intl.message(
      'Review',
      name: 'profileReviewAction',
      desc: '',
      args: [],
    );
  }

  /// `Definition`
  String get profileGoalLose {
    return Intl.message(
      'Definition',
      name: 'profileGoalLose',
      desc: '',
      args: [],
    );
  }

  /// `Recomp.`
  String get profileGoalMaintain {
    return Intl.message(
      'Recomp.',
      name: 'profileGoalMaintain',
      desc: '',
      args: [],
    );
  }

  /// `Volume`
  String get profileGoalGain {
    return Intl.message(
      'Volume',
      name: 'profileGoalGain',
      desc: '',
      args: [],
    );
  }

  /// `Short and controlled deficit to lose fat without compromising performance or muscle mass.`
  String get profileGoalLoseDesc {
    return Intl.message(
      'Short and controlled deficit to lose fat without compromising performance or muscle mass.',
      name: 'profileGoalLoseDesc',
      desc: '',
      args: [],
    );
  }

  /// `Maintain stable weight while prioritizing strength, performance and adherence.`
  String get profileGoalMaintainDesc {
    return Intl.message(
      'Maintain stable weight while prioritizing strength, performance and adherence.',
      name: 'profileGoalMaintainDesc',
      desc: '',
      args: [],
    );
  }

  /// `Measured surplus to push training, recovery and progression.`
  String get profileGoalGainDesc {
    return Intl.message(
      'Measured surplus to push training, recovery and progression.',
      name: 'profileGoalGainDesc',
      desc: '',
      args: [],
    );
  }

  /// `Today the distribution increases carbs to support a hard leg session.`
  String get profileFocusLowerBody {
    return Intl.message(
      'Today the distribution increases carbs to support a hard leg session.',
      name: 'profileFocusLowerBody',
      desc: '',
      args: [],
    );
  }

  /// `Today the distribution maintains good fuel and clean recovery for torso.`
  String get profileFocusUpperBody {
    return Intl.message(
      'Today the distribution maintains good fuel and clean recovery for torso.',
      name: 'profileFocusUpperBody',
      desc: '',
      args: [],
    );
  }

  /// `Today the distribution seeks enough energy without adding extra carbs.`
  String get profileFocusCardio {
    return Intl.message(
      'Today the distribution seeks enough energy without adding extra carbs.',
      name: 'profileFocusCardio',
      desc: '',
      args: [],
    );
  }

  /// `Today the distribution cuts carbs and maintains high protein to recover.`
  String get profileFocusRest {
    return Intl.message(
      'Today the distribution cuts carbs and maintains high protein to recover.',
      name: 'profileFocusRest',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get settingsLanguageLabel {
    return Intl.message(
      'Language',
      name: 'settingsLanguageLabel',
      desc: '',
      args: [],
    );
  }

  /// `System default`
  String get settingsLanguageSystemDefaultLabel {
    return Intl.message(
      'System default',
      name: 'settingsLanguageSystemDefaultLabel',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get settingsLanguageEnglish {
    return Intl.message(
      'English',
      name: 'settingsLanguageEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Spanish`
  String get settingsLanguageSpanish {
    return Intl.message(
      'Spanish',
      name: 'settingsLanguageSpanish',
      desc: '',
      args: [],
    );
  }

  /// `Select language`
  String get settingsSelectLanguageTitle {
    return Intl.message(
      'Select language',
      name: 'settingsSelectLanguageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Servings`
  String get servingsLabel {
    return Intl.message(
      'Servings',
      name: 'servingsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Performance Summary`
  String get homePerformanceSummary {
    return Intl.message(
      'Performance Summary',
      name: 'homePerformanceSummary',
      desc: '',
      args: [],
    );
  }

  /// `Smart reminders`
  String get nudgeSmartReminders {
    return Intl.message(
      'Smart reminders',
      name: 'nudgeSmartReminders',
      desc: '',
      args: [],
    );
  }

  /// `No pending actions for now.`
  String get nudgeNoPendingActions {
    return Intl.message(
      'No pending actions for now.',
      name: 'nudgeNoPendingActions',
      desc: '',
      args: [],
    );
  }

  /// `Only useful alerts to maintain adherence.`
  String get nudgeKeepAdherence {
    return Intl.message(
      'Only useful alerts to maintain adherence.',
      name: 'nudgeKeepAdherence',
      desc: '',
      args: [],
    );
  }

  /// `You have {amount}g of protein left. Prioritize a high protein meal.`
  String nudgeProteinLeft(Object amount) {
    return Intl.message(
      'You have ${amount}g of protein left. Prioritize a high protein meal.',
      name: 'nudgeProteinLeft',
      desc: '',
      args: [amount],
    );
  }

  /// `Low hydration today. Drink water to close at 100%.`
  String get nudgeLowHydration {
    return Intl.message(
      'Low hydration today. Drink water to close at 100%.',
      name: 'nudgeLowHydration',
      desc: '',
      args: [],
    );
  }

  /// `Closing the day: you lack energy for goal. Add a clean closing meal.`
  String get nudgeDayClosing {
    return Intl.message(
      'Closing the day: you lack energy for goal. Add a clean closing meal.',
      name: 'nudgeDayClosing',
      desc: '',
      args: [],
    );
  }

  /// `No pending reminders. Doing great today.`
  String get nudgeNoReminders {
    return Intl.message(
      'No pending reminders. Doing great today.',
      name: 'nudgeNoReminders',
      desc: '',
      args: [],
    );
  }

  /// `No clear overeating pattern`
  String get weeklyInsightsNoOvereatingPattern {
    return Intl.message(
      'No clear overeating pattern',
      name: 'weeklyInsightsNoOvereatingPattern',
      desc: '',
      args: [],
    );
  }

  /// `Morning`
  String get weeklyInsightsSlotMorning {
    return Intl.message(
      'Morning',
      name: 'weeklyInsightsSlotMorning',
      desc: '',
      args: [],
    );
  }

  /// `Afternoon`
  String get weeklyInsightsSlotAfternoon {
    return Intl.message(
      'Afternoon',
      name: 'weeklyInsightsSlotAfternoon',
      desc: '',
      args: [],
    );
  }

  /// `Evening`
  String get weeklyInsightsSlotEvening {
    return Intl.message(
      'Evening',
      name: 'weeklyInsightsSlotEvening',
      desc: '',
      args: [],
    );
  }

  /// `Late night`
  String get weeklyInsightsSlotLateNight {
    return Intl.message(
      'Late night',
      name: 'weeklyInsightsSlotLateNight',
      desc: '',
      args: [],
    );
  }

  /// `No days registered this week yet.`
  String get weeklyInsightsSummaryNoDays {
    return Intl.message(
      'No days registered this week yet.',
      name: 'weeklyInsightsSummaryNoDays',
      desc: '',
      args: [],
    );
  }

  /// `Solid week: good caloric adherence and protein consistency.`
  String get weeklyInsightsSummarySolid {
    return Intl.message(
      'Solid week: good caloric adherence and protein consistency.',
      name: 'weeklyInsightsSummarySolid',
      desc: '',
      args: [],
    );
  }

  /// `Caloric adherence was irregular this week.`
  String get weeklyInsightsSummaryIrregular {
    return Intl.message(
      'Caloric adherence was irregular this week.',
      name: 'weeklyInsightsSummaryIrregular',
      desc: '',
      args: [],
    );
  }

  /// `The main gap was protein consistency.`
  String get weeklyInsightsSummaryProteinGap {
    return Intl.message(
      'The main gap was protein consistency.',
      name: 'weeklyInsightsSummaryProteinGap',
      desc: '',
      args: [],
    );
  }

  /// `Stable week, with room to improve consistency.`
  String get weeklyInsightsSummaryStable {
    return Intl.message(
      'Stable week, with room to improve consistency.',
      name: 'weeklyInsightsSummaryStable',
      desc: '',
      args: [],
    );
  }

  /// `Adherence too low for automatic adjustment. Improve consistency first.`
  String get weeklyInsightsRecAdherenceLow {
    return Intl.message(
      'Adherence too low for automatic adjustment. Improve consistency first.',
      name: 'weeklyInsightsRecAdherenceLow',
      desc: '',
      args: [],
    );
  }

  /// `Fat loss stalled: suggestion -100 kcal/day.`
  String get weeklyInsightsRecLoseWeightStalled {
    return Intl.message(
      'Fat loss stalled: suggestion -100 kcal/day.',
      name: 'weeklyInsightsRecLoseWeightStalled',
      desc: '',
      args: [],
    );
  }

  /// `Slow fat loss: suggestion -50 kcal/day.`
  String get weeklyInsightsRecLoseWeightSlow {
    return Intl.message(
      'Slow fat loss: suggestion -50 kcal/day.',
      name: 'weeklyInsightsRecLoseWeightSlow',
      desc: '',
      args: [],
    );
  }

  /// `Weight dropping too fast: suggestion +50 kcal/day.`
  String get weeklyInsightsRecLoseWeightFast {
    return Intl.message(
      'Weight dropping too fast: suggestion +50 kcal/day.',
      name: 'weeklyInsightsRecLoseWeightFast',
      desc: '',
      args: [],
    );
  }

  /// `Correct definition pace. No kcal change.`
  String get weeklyInsightsRecLoseWeightCorrect {
    return Intl.message(
      'Correct definition pace. No kcal change.',
      name: 'weeklyInsightsRecLoseWeightCorrect',
      desc: '',
      args: [],
    );
  }

  /// `Weight trending up: suggestion -50 kcal/day.`
  String get weeklyInsightsRecMaintainUp {
    return Intl.message(
      'Weight trending up: suggestion -50 kcal/day.',
      name: 'weeklyInsightsRecMaintainUp',
      desc: '',
      args: [],
    );
  }

  /// `Weight trending down: suggestion +50 kcal/day.`
  String get weeklyInsightsRecMaintainDown {
    return Intl.message(
      'Weight trending down: suggestion +50 kcal/day.',
      name: 'weeklyInsightsRecMaintainDown',
      desc: '',
      args: [],
    );
  }

  /// `Stable maintenance. No kcal change.`
  String get weeklyInsightsRecMaintainStable {
    return Intl.message(
      'Stable maintenance. No kcal change.',
      name: 'weeklyInsightsRecMaintainStable',
      desc: '',
      args: [],
    );
  }

  /// `Bulk too slow: suggestion +100 kcal/day.`
  String get weeklyInsightsRecGainSlow {
    return Intl.message(
      'Bulk too slow: suggestion +100 kcal/day.',
      name: 'weeklyInsightsRecGainSlow',
      desc: '',
      args: [],
    );
  }

  /// `Soft bulk pace: suggestion +50 kcal/day.`
  String get weeklyInsightsRecGainSoft {
    return Intl.message(
      'Soft bulk pace: suggestion +50 kcal/day.',
      name: 'weeklyInsightsRecGainSoft',
      desc: '',
      args: [],
    );
  }

  /// `Weight rising too fast: suggestion -50 kcal/day.`
  String get weeklyInsightsRecGainFast {
    return Intl.message(
      'Weight rising too fast: suggestion -50 kcal/day.',
      name: 'weeklyInsightsRecGainFast',
      desc: '',
      args: [],
    );
  }

  /// `Controlled bulk pace. No kcal change.`
  String get weeklyInsightsRecGainCorrect {
    return Intl.message(
      'Controlled bulk pace. No kcal change.',
      name: 'weeklyInsightsRecGainCorrect',
      desc: '',
      args: [],
    );
  }

  /// `Current adjustment: {kcal} kcal.`
  String weeklyInsightsCurrentAdjustment(Object kcal) {
    return Intl.message(
      'Current adjustment: $kcal kcal.',
      name: 'weeklyInsightsCurrentAdjustment',
      desc: '',
      args: [kcal],
    );
  }

  /// `Body progress`
  String get bodyProgressTitle {
    return Intl.message(
      'Body progress',
      name: 'bodyProgressTitle',
      desc: '',
      args: [],
    );
  }

  /// `Body progress could not be loaded.`
  String get bodyProgressLoadError {
    return Intl.message(
      'Body progress could not be loaded.',
      name: 'bodyProgressLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Log body data`
  String get bodyProgressLogData {
    return Intl.message(
      'Log body data',
      name: 'bodyProgressLogData',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get bodyProgressDay {
    return Intl.message(
      'Day',
      name: 'bodyProgressDay',
      desc: '',
      args: [],
    );
  }

  /// `Weight`
  String get bodyProgressWeight {
    return Intl.message(
      'Weight',
      name: 'bodyProgressWeight',
      desc: '',
      args: [],
    );
  }

  /// `Waist`
  String get bodyProgressWaist {
    return Intl.message(
      'Waist',
      name: 'bodyProgressWaist',
      desc: '',
      args: [],
    );
  }

  /// `Not enough data for this metric yet.`
  String get bodyProgressNotEnoughData {
    return Intl.message(
      'Not enough data for this metric yet.',
      name: 'bodyProgressNotEnoughData',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get historyLabel {
    return Intl.message(
      'History',
      name: 'historyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Log today`
  String get logTodayLabel {
    return Intl.message(
      'Log today',
      name: 'logTodayLabel',
      desc: '',
      args: [],
    );
  }

  /// `min`
  String get minutesLabel {
    return Intl.message(
      'min',
      name: 'minutesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Recent check-ins`
  String get bodyProgressRecentCheckins {
    return Intl.message(
      'Recent check-ins',
      name: 'bodyProgressRecentCheckins',
      desc: '',
      args: [],
    );
  }

  /// `No body check-ins yet. Start logging weight and waist to get a usable trend.`
  String get bodyProgressNoCheckins {
    return Intl.message(
      'No body check-ins yet. Start logging weight and waist to get a usable trend.',
      name: 'bodyProgressNoCheckins',
      desc: '',
      args: [],
    );
  }

  /// `Trend`
  String get bodyProgressTrend {
    return Intl.message(
      'Trend',
      name: 'bodyProgressTrend',
      desc: '',
      args: [],
    );
  }

  /// `Latest weight`
  String get bodyProgressLatestWeight {
    return Intl.message(
      'Latest weight',
      name: 'bodyProgressLatestWeight',
      desc: '',
      args: [],
    );
  }

  /// `7d average`
  String get bodyProgress7dAverage {
    return Intl.message(
      '7d average',
      name: 'bodyProgress7dAverage',
      desc: '',
      args: [],
    );
  }

  /// `Weekly delta`
  String get bodyProgressWeeklyDelta {
    return Intl.message(
      'Weekly delta',
      name: 'bodyProgressWeeklyDelta',
      desc: '',
      args: [],
    );
  }

  /// `Latest waist`
  String get bodyProgressLatestWaist {
    return Intl.message(
      'Latest waist',
      name: 'bodyProgressLatestWaist',
      desc: '',
      args: [],
    );
  }

  /// `Auto read`
  String get bodyProgressAutoRead {
    return Intl.message(
      'Auto read',
      name: 'bodyProgressAutoRead',
      desc: '',
      args: [],
    );
  }

  /// `Weight trend needs another full week of check-ins.`
  String get bodyProgressTrendWeightNeedData {
    return Intl.message(
      'Weight trend needs another full week of check-ins.',
      name: 'bodyProgressTrendWeightNeedData',
      desc: '',
      args: [],
    );
  }

  /// `Weight is holding steady week over week.`
  String get bodyProgressTrendWeightSteady {
    return Intl.message(
      'Weight is holding steady week over week.',
      name: 'bodyProgressTrendWeightSteady',
      desc: '',
      args: [],
    );
  }

  /// `Weight is trending down versus the previous 7-day average.`
  String get bodyProgressTrendWeightDown {
    return Intl.message(
      'Weight is trending down versus the previous 7-day average.',
      name: 'bodyProgressTrendWeightDown',
      desc: '',
      args: [],
    );
  }

  /// `Weight is trending up versus the previous 7-day average.`
  String get bodyProgressTrendWeightUp {
    return Intl.message(
      'Weight is trending up versus the previous 7-day average.',
      name: 'bodyProgressTrendWeightUp',
      desc: '',
      args: [],
    );
  }

  /// `Waist trend needs at least two waist check-ins.`
  String get bodyProgressTrendWaistNeedData {
    return Intl.message(
      'Waist trend needs at least two waist check-ins.',
      name: 'bodyProgressTrendWaistNeedData',
      desc: '',
      args: [],
    );
  }

  /// `Waist is stable across the latest check-ins.`
  String get bodyProgressTrendWaistSteady {
    return Intl.message(
      'Waist is stable across the latest check-ins.',
      name: 'bodyProgressTrendWaistSteady',
      desc: '',
      args: [],
    );
  }

  /// `Waist is tightening versus the previous waist check-in.`
  String get bodyProgressTrendWaistDown {
    return Intl.message(
      'Waist is tightening versus the previous waist check-in.',
      name: 'bodyProgressTrendWaistDown',
      desc: '',
      args: [],
    );
  }

  /// `Waist is up versus the previous waist check-in.`
  String get bodyProgressTrendWaistUp {
    return Intl.message(
      'Waist is up versus the previous waist check-in.',
      name: 'bodyProgressTrendWaistUp',
      desc: '',
      args: [],
    );
  }

  /// `No trend`
  String get bodyProgressTrendNoTrend {
    return Intl.message(
      'No trend',
      name: 'bodyProgressTrendNoTrend',
      desc: '',
      args: [],
    );
  }

  /// `On track`
  String get bodyProgressTrendOnTrack {
    return Intl.message(
      'On track',
      name: 'bodyProgressTrendOnTrack',
      desc: '',
      args: [],
    );
  }

  /// `Off track`
  String get bodyProgressTrendOffTrack {
    return Intl.message(
      'Off track',
      name: 'bodyProgressTrendOffTrack',
      desc: '',
      args: [],
    );
  }

  /// `Mixed`
  String get bodyProgressTrendMixed {
    return Intl.message(
      'Mixed',
      name: 'bodyProgressTrendMixed',
      desc: '',
      args: [],
    );
  }

  /// `Trend chart`
  String get bodyProgressTrendChart {
    return Intl.message(
      'Trend chart',
      name: 'bodyProgressTrendChart',
      desc: '',
      args: [],
    );
  }

  /// `Weight trend with 7d rolling average`
  String get bodyProgressTrendChartWeightSubtitle {
    return Intl.message(
      'Weight trend with 7d rolling average',
      name: 'bodyProgressTrendChartWeightSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Waist trend by check-in`
  String get bodyProgressTrendChartWaistSubtitle {
    return Intl.message(
      'Waist trend by check-in',
      name: 'bodyProgressTrendChartWaistSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Add a few body check-ins to unlock the trend chart.`
  String get bodyProgressAddCheckinsUnlockChart {
    return Intl.message(
      'Add a few body check-ins to unlock the trend chart.',
      name: 'bodyProgressAddCheckinsUnlockChart',
      desc: '',
      args: [],
    );
  }

  /// `No check-ins yet.`
  String get bodyProgressNoCheckinsYet {
    return Intl.message(
      'No check-ins yet.',
      name: 'bodyProgressNoCheckinsYet',
      desc: '',
      args: [],
    );
  }

  /// `Latest check-in {date}`
  String bodyProgressLatestCheckin(Object date) {
    return Intl.message(
      'Latest check-in $date',
      name: 'bodyProgressLatestCheckin',
      desc: '',
      args: [date],
    );
  }

  /// `Open history`
  String get bodyProgressOpenHistoryTooltip {
    return Intl.message(
      'Open history',
      name: 'bodyProgressOpenHistoryTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Delta`
  String get bodyProgressDelta {
    return Intl.message(
      'Delta',
      name: 'bodyProgressDelta',
      desc: '',
      args: [],
    );
  }

  /// `Check-in`
  String get professionalTabCheckin {
    return Intl.message(
      'Check-in',
      name: 'professionalTabCheckin',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get professionalTabNotes {
    return Intl.message(
      'Notes',
      name: 'professionalTabNotes',
      desc: '',
      args: [],
    );
  }

  /// `Recipes`
  String get professionalTabRecipes {
    return Intl.message(
      'Recipes',
      name: 'professionalTabRecipes',
      desc: '',
      args: [],
    );
  }

  /// `Calories`
  String get professionalMacroCalories {
    return Intl.message(
      'Calories',
      name: 'professionalMacroCalories',
      desc: '',
      args: [],
    );
  }

  /// `On target`
  String get professionalPlanOnTarget {
    return Intl.message(
      'On target',
      name: 'professionalPlanOnTarget',
      desc: '',
      args: [],
    );
  }

  /// `Over plan`
  String get professionalPlanOverPlan {
    return Intl.message(
      'Over plan',
      name: 'professionalPlanOverPlan',
      desc: '',
      args: [],
    );
  }

  /// `Left`
  String get professionalPlanRemaining {
    return Intl.message(
      'Left',
      name: 'professionalPlanRemaining',
      desc: '',
      args: [],
    );
  }

  /// `Adherence`
  String get professionalPlanAdherence {
    return Intl.message(
      'Adherence',
      name: 'professionalPlanAdherence',
      desc: '',
      args: [],
    );
  }

  /// `Plan vs actual`
  String get professionalPlanVsActual {
    return Intl.message(
      'Plan vs actual',
      name: 'professionalPlanVsActual',
      desc: '',
      args: [],
    );
  }

  /// `View plan`
  String get professionalPlanViewPlan {
    return Intl.message(
      'View plan',
      name: 'professionalPlanViewPlan',
      desc: '',
      args: [],
    );
  }

  /// `You are exactly on today's target.`
  String get professionalPlanStatusExact {
    return Intl.message(
      'You are exactly on today\'s target.',
      name: 'professionalPlanStatusExact',
      desc: '',
      args: [],
    );
  }

  /// `+{kcal} kcal over today's plan.`
  String professionalPlanStatusOver(Object kcal) {
    return Intl.message(
      '+$kcal kcal over today\'s plan.',
      name: 'professionalPlanStatusOver',
      desc: '',
      args: [kcal],
    );
  }

  /// `{kcal} kcal left on the plan.`
  String professionalPlanStatusLeft(Object kcal) {
    return Intl.message(
      '$kcal kcal left on the plan.',
      name: 'professionalPlanStatusLeft',
      desc: '',
      args: [kcal],
    );
  }

  /// `Check-in submitted!`
  String get checkinTabSubmitted {
    return Intl.message(
      'Check-in submitted!',
      name: 'checkinTabSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Your nutritionist will review it shortly.`
  String get checkinTabReviewShortly {
    return Intl.message(
      'Your nutritionist will review it shortly.',
      name: 'checkinTabReviewShortly',
      desc: '',
      args: [],
    );
  }

  /// `Submit another`
  String get checkinTabSubmitAnother {
    return Intl.message(
      'Submit another',
      name: 'checkinTabSubmitAnother',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Check-in`
  String get checkinTabWeeklyTitle {
    return Intl.message(
      'Weekly Check-in',
      name: 'checkinTabWeeklyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Share how your week went`
  String get checkinTabShareSubtitle {
    return Intl.message(
      'Share how your week went',
      name: 'checkinTabShareSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Energy Level`
  String get checkinTabEnergyLevel {
    return Intl.message(
      'Energy Level',
      name: 'checkinTabEnergyLevel',
      desc: '',
      args: [],
    );
  }

  /// `Low`
  String get checkinTabLow {
    return Intl.message(
      'Low',
      name: 'checkinTabLow',
      desc: '',
      args: [],
    );
  }

  /// `High`
  String get checkinTabHigh {
    return Intl.message(
      'High',
      name: 'checkinTabHigh',
      desc: '',
      args: [],
    );
  }

  /// `Sleep Hours`
  String get checkinTabSleepHours {
    return Intl.message(
      'Sleep Hours',
      name: 'checkinTabSleepHours',
      desc: '',
      args: [],
    );
  }

  /// `How are you feeling?`
  String get checkinTabHowFeeling {
    return Intl.message(
      'How are you feeling?',
      name: 'checkinTabHowFeeling',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Energized, tired, motivated...`
  String get checkinTabMoodHint {
    return Intl.message(
      'e.g. Energized, tired, motivated...',
      name: 'checkinTabMoodHint',
      desc: '',
      args: [],
    );
  }

  /// `Additional notes`
  String get checkinTabAdditionalNotes {
    return Intl.message(
      'Additional notes',
      name: 'checkinTabAdditionalNotes',
      desc: '',
      args: [],
    );
  }

  /// `Any challenges or wins this week?`
  String get checkinTabNotesHint {
    return Intl.message(
      'Any challenges or wins this week?',
      name: 'checkinTabNotesHint',
      desc: '',
      args: [],
    );
  }

  /// `Submitting...`
  String get checkinTabSubmitting {
    return Intl.message(
      'Submitting...',
      name: 'checkinTabSubmitting',
      desc: '',
      args: [],
    );
  }

  /// `Submit Check-in`
  String get checkinTabSubmitButton {
    return Intl.message(
      'Submit Check-in',
      name: 'checkinTabSubmitButton',
      desc: '',
      args: [],
    );
  }

  /// `Nutritionist questions`
  String get checkinTabNutritionistQuestions {
    return Intl.message(
      'Nutritionist questions',
      name: 'checkinTabNutritionistQuestions',
      desc: '',
      args: [],
    );
  }

  /// `Type your answer...`
  String get checkinTabAnswerHint {
    return Intl.message(
      'Type your answer...',
      name: 'checkinTabAnswerHint',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get featureTourStart {
    return Intl.message(
      'Start',
      name: 'featureTourStart',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get featureTourNext {
    return Intl.message(
      'Next',
      name: 'featureTourNext',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get featureTourSkip {
    return Intl.message(
      'Skip',
      name: 'featureTourSkip',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get featureTourBack {
    return Intl.message(
      'Back',
      name: 'featureTourBack',
      desc: '',
      args: [],
    );
  }

  /// `Tap highlighted area`
  String get featureTourTapHighlightedArea {
    return Intl.message(
      'Tap highlighted area',
      name: 'featureTourTapHighlightedArea',
      desc: '',
      args: [],
    );
  }

  /// `Step {current} / {total}`
  String featureTourStepCounter(int current, int total) {
    return Intl.message(
      'Step $current / $total',
      name: 'featureTourStepCounter',
      desc: '',
      args: [current, total],
    );
  }

  /// `Welcome!`
  String get featureTourTitle0 {
    return Intl.message(
      'Welcome!',
      name: 'featureTourTitle0',
      desc: '',
      args: [],
    );
  }

  /// `Log with a Tap`
  String get featureTourTitle1 {
    return Intl.message(
      'Log with a Tap',
      name: 'featureTourTitle1',
      desc: '',
      args: [],
    );
  }

  /// `Daily Calories & Macros`
  String get featureTourTitle2 {
    return Intl.message(
      'Daily Calories & Macros',
      name: 'featureTourTitle2',
      desc: '',
      args: [],
    );
  }

  /// `Habits & Connected Health`
  String get featureTourTitle3 {
    return Intl.message(
      'Habits & Connected Health',
      name: 'featureTourTitle3',
      desc: '',
      args: [],
    );
  }

  /// `Progress & Weight History`
  String get featureTourTitle4 {
    return Intl.message(
      'Progress & Weight History',
      name: 'featureTourTitle4',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Summary & Insights`
  String get featureTourTitle5 {
    return Intl.message(
      'Weekly Summary & Insights',
      name: 'featureTourTitle5',
      desc: '',
      args: [],
    );
  }

  /// `Nutritionist & Invites`
  String get featureTourTitle6 {
    return Intl.message(
      'Nutritionist & Invites',
      name: 'featureTourTitle6',
      desc: '',
      args: [],
    );
  }

  /// `Your Diary History`
  String get featureTourTitle7 {
    return Intl.message(
      'Your Diary History',
      name: 'featureTourTitle7',
      desc: '',
      args: [],
    );
  }

  /// `Diary Management`
  String get featureTourTitle8 {
    return Intl.message(
      'Diary Management',
      name: 'featureTourTitle8',
      desc: '',
      args: [],
    );
  }

  /// `Recipes & AI Web Importer`
  String get featureTourTitle9 {
    return Intl.message(
      'Recipes & AI Web Importer',
      name: 'featureTourTitle9',
      desc: '',
      args: [],
    );
  }

  /// `Profile & Settings`
  String get featureTourTitle10 {
    return Intl.message(
      'Profile & Settings',
      name: 'featureTourTitle10',
      desc: '',
      args: [],
    );
  }

  /// `Cloud Backup & Account`
  String get featureTourTitle11 {
    return Intl.message(
      'Cloud Backup & Account',
      name: 'featureTourTitle11',
      desc: '',
      args: [],
    );
  }

  /// `All Set!`
  String get featureTourTitle12 {
    return Intl.message(
      'All Set!',
      name: 'featureTourTitle12',
      desc: '',
      args: [],
    );
  }

  /// `We will show you how the application works to help you track your nutrition, workouts, and daily habits in just 1 minute.`
  String get featureTourDesc0 {
    return Intl.message(
      'We will show you how the application works to help you track your nutrition, workouts, and daily habits in just 1 minute.',
      name: 'featureTourDesc0',
      desc: '',
      args: [],
    );
  }

  /// `Tap the (+) button to log food quickly:\n• Scan barcodes.\n• Use our private text or photo AI (fully anonymous).\n• Enter calories and macros manually.\n\nTap it right now to see it open!`
  String get featureTourDesc1 {
    return Intl.message(
      'Tap the (+) button to log food quickly:\n• Scan barcodes.\n• Use our private text or photo AI (fully anonymous).\n• Enter calories and macros manually.\n\nTap it right now to see it open!',
      name: 'featureTourDesc1',
      desc: '',
      args: [],
    );
  }

  /// `Your central panel calculates remaining calories in real time:\n• Adds base goals and subtracts food intake.\n• Monitors proteins, carbs, and fats to balance your day.`
  String get featureTourDesc2 {
    return Intl.message(
      'Your central panel calculates remaining calories in real time:\n• Adds base goals and subtracts food intake.\n• Monitors proteins, carbs, and fats to balance your day.',
      name: 'featureTourDesc2',
      desc: '',
      args: [],
    );
  }

  /// `Track your steps, sleep, and water. MacroTracker syncs automatically with Health Connect to import your data effortlessly.`
  String get featureTourDesc3 {
    return Intl.message(
      'Track your steps, sleep, and water. MacroTracker syncs automatically with Health Connect to import your data effortlessly.',
      name: 'featureTourDesc3',
      desc: '',
      args: [],
    );
  }

  /// `Track your evolution by logging body weight and measurements. View interactive trend charts to stay motivated.`
  String get featureTourDesc4 {
    return Intl.message(
      'Track your evolution by logging body weight and measurements. View interactive trend charts to stay motivated.',
      name: 'featureTourDesc4',
      desc: '',
      args: [],
    );
  }

  /// `Receive smart weekly reports generated from your progress. The app will advise you how to adjust your plan to avoid plateaus.`
  String get featureTourDesc5 {
    return Intl.message(
      'Receive smart weekly reports generated from your progress. The app will advise you how to adjust your plan to avoid plateaus.',
      name: 'featureTourDesc5',
      desc: '',
      args: [],
    );
  }

  /// `If your nutritionist uses the platform, you can link your account using their invite code to let them supervise and adapt your plan in real time.`
  String get featureTourDesc6 {
    return Intl.message(
      'If your nutritionist uses the platform, you can link your account using their invite code to let them supervise and adapt your plan in real time.',
      name: 'featureTourDesc6',
      desc: '',
      args: [],
    );
  }

  /// `Organize your intakes by time of day (breakfast, lunch, snack, dinner) and perform continuous tracking of your habits.\n\nTap the 'Diary' tab on the bottom bar to continue.`
  String get featureTourDesc7 {
    return Intl.message(
      'Organize your intakes by time of day (breakfast, lunch, snack, dinner) and perform continuous tracking of your habits.\n\nTap the \'Diary\' tab on the bottom bar to continue.',
      name: 'featureTourDesc7',
      desc: '',
      args: [],
    );
  }

  /// `Review your daily intake. Tap any food to edit its grams or swipe to delete it if you made a mistake.`
  String get featureTourDesc8 {
    return Intl.message(
      'Review your daily intake. Tap any food to edit its grams or swipe to delete it if you made a mistake.',
      name: 'featureTourDesc8',
      desc: '',
      args: [],
    );
  }

  /// `Save your frequent meals in your library. Also, copy the link of any web recipe and our AI will import its ingredients automatically.`
  String get featureTourDesc9 {
    return Intl.message(
      'Save your frequent meals in your library. Also, copy the link of any web recipe and our AI will import its ingredients automatically.',
      name: 'featureTourDesc9',
      desc: '',
      args: [],
    );
  }

  /// `Access here to adjust your caloric requirements, change the language, metric/imperial units, or the application theme.\n\nTap the 'Profile' tab to continue.`
  String get featureTourDesc10 {
    return Intl.message(
      'Access here to adjust your caloric requirements, change the language, metric/imperial units, or the application theme.\n\nTap the \'Profile\' tab to continue.',
      name: 'featureTourDesc10',
      desc: '',
      args: [],
    );
  }

  /// `Link your account to sync your data in the cloud and schedule automatic encrypted backups to your Google Drive account.`
  String get featureTourDesc11 {
    return Intl.message(
      'Link your account to sync your data in the cloud and schedule automatic encrypted backups to your Google Drive account.',
      name: 'featureTourDesc11',
      desc: '',
      args: [],
    );
  }

  /// `You have completed the interactive tour. Start logging your meals and habits today to reach your physical goal. Good luck!`
  String get featureTourDesc12 {
    return Intl.message(
      'You have completed the interactive tour. Start logging your meals and habits today to reach your physical goal. Good luck!',
      name: 'featureTourDesc12',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
