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

  /// `MacroTracker is a free and open-source calorie and nutrient tracker that respects your privacy.`
  String get appDescription {
    return Intl.message(
      'MacroTracker is a free and open-source calorie and nutrient tracker that respects your privacy.',
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

  /// `Send anonymous usage data`
  String get sendAnonymousUserData {
    return Intl.message(
      'Send anonymous usage data',
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

  /// `You can export the app data to a zip file and import it later. This is useful if you want to backup your data or transfer it to another device.\n\nThe app does not use any cloud service to store your data.`
  String get exportImportDescription {
    return Intl.message(
      'You can export the app data to a zip file and import it later. This is useful if you want to backup your data or transfer it to another device.\n\nThe app does not use any cloud service to store your data.',
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

  /// `Support development by providing anonymous usage data`
  String get dataCollectionLabel {
    return Intl.message(
      'Support development by providing anonymous usage data',
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

  /// `Favorite for quick access`
  String get aiFavoriteQuickAccess {
    return Intl.message(
      'Favorite for quick access',
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

  /// `Saved meals`
  String get recipeLibraryTitle {
    return Intl.message(
      'Saved meals',
      name: 'recipeLibraryTitle',
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

  /// `Favorite`
  String get recipeLibraryFavorite {
    return Intl.message(
      'Favorite',
      name: 'recipeLibraryFavorite',
      desc: '',
      args: [],
    );
  }

  /// `Remove favorite`
  String get recipeLibraryRemoveFavorite {
    return Intl.message(
      'Remove favorite',
      name: 'recipeLibraryRemoveFavorite',
      desc: '',
      args: [],
    );
  }

  /// `Mark favorite`
  String get recipeLibraryMarkFavorite {
    return Intl.message(
      'Mark favorite',
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
