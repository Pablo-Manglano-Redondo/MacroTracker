// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MacroTracker';

  @override
  String appVersionName(Object versionNumber) {
    return 'Version $versionNumber';
  }

  @override
  String get appDescription =>
      'MacroTracker is a free and open-source calorie and nutrient tracker that respects your privacy.';

  @override
  String get alphaVersionName => '[Alpha]';

  @override
  String get betaVersionName => '[Beta]';

  @override
  String get addLabel => 'Add';

  @override
  String get createCustomDialogTitle => 'Create custom meal item?';

  @override
  String get createCustomDialogContent =>
      'Do you want create a custom meal item?';

  @override
  String get settingsLabel => 'Settings';

  @override
  String get homeLabel => 'Home';

  @override
  String get diaryLabel => 'Diary';

  @override
  String get profileLabel => 'Profile';

  @override
  String get searchLabel => 'Search';

  @override
  String get addMealQuickActionsTitle => 'Quick shortcuts';

  @override
  String get addMealQuickActionsSubtitle =>
      'Start with barcode, photo, text, or saved meals. If you search, choose the source below.';

  @override
  String get addMealTabPackaged => 'Packaged';

  @override
  String get addMealTabGeneric => 'Generic foods';

  @override
  String get addMealTabRecent => 'Recent history';

  @override
  String get addMealTabPackagedHelper =>
      'Use this for supermarket products and branded items.';

  @override
  String get addMealTabGenericHelper =>
      'Use this for simple foods like rice, chicken, fruit, or oats.';

  @override
  String get addMealTabRecentHelper => 'Reuse something you logged recently.';

  @override
  String get addMealSectionPackagedResults => 'Packaged results';

  @override
  String get addMealSectionGenericResults => 'Generic food results';

  @override
  String get addMealSectionRecentResults => 'Recent meals';

  @override
  String get addMealRecentEmpty =>
      'No recent meals yet.\nLog a meal once and it will appear here.';

  @override
  String get addMealSearchPromptPackaged =>
      'Search a packaged product or use barcode.';

  @override
  String get addMealSearchPromptGeneric =>
      'Search a generic food like rice, eggs, or yogurt.';

  @override
  String get addMealSearchPromptRecent =>
      'Search your recent history or open saved meals.';

  @override
  String get searchProductsPage => 'Products';

  @override
  String get searchFoodPage => 'Food';

  @override
  String get searchResultsLabel => 'Search results';

  @override
  String get searchDefaultLabel => 'Please enter a search word';

  @override
  String get allItemsLabel => 'All';

  @override
  String get recentlyAddedLabel => 'Recently';

  @override
  String get noMealsRecentlyAddedLabel => 'No meals recently added';

  @override
  String get noActivityRecentlyAddedLabel => 'No activity recently added';

  @override
  String get dialogOKLabel => 'OK';

  @override
  String get dialogCancelLabel => 'CANCEL';

  @override
  String get buttonStartLabel => 'START';

  @override
  String get buttonNextLabel => 'NEXT';

  @override
  String get buttonSaveLabel => 'Save';

  @override
  String get buttonYesLabel => 'YES';

  @override
  String get buttonResetLabel => 'Reset';

  @override
  String get onboardingWelcomeLabel => 'Welcome to';

  @override
  String get onboardingOverviewLabel => 'Overview';

  @override
  String get onboardingYourGoalLabel => 'Your calorie goal:';

  @override
  String get onboardingYourMacrosGoalLabel => 'Your macronutrient goals:';

  @override
  String get onboardingKcalPerDayLabel => 'kcal per day';

  @override
  String get onboardingIntroDescription =>
      'To start, the app needs some information about you to calculate your daily calorie goal.\nAll information about you is stored securely on your device.';

  @override
  String get onboardingGenderQuestionSubtitle => 'What\'s your gender?';

  @override
  String get onboardingEnterBirthdayLabel => 'Birthday';

  @override
  String get onboardingBirthdayHint => 'Enter Date';

  @override
  String get onboardingBirthdayQuestionSubtitle => 'When is your birthday?';

  @override
  String get onboardingHeightQuestionSubtitle => 'Whats your current height?';

  @override
  String get onboardingWeightQuestionSubtitle => 'Whats your current weight?';

  @override
  String get onboardingWrongHeightLabel => 'Enter correct height';

  @override
  String get onboardingWrongWeightLabel => 'Enter correct weight';

  @override
  String get onboardingWeightExampleHintKg => 'e.g. 60';

  @override
  String get onboardingWeightExampleHintLbs => 'e.g. 132';

  @override
  String get onboardingHeightExampleHintCm => 'e.g. 170';

  @override
  String get onboardingHeightExampleHintFt => 'e.g. 5.8';

  @override
  String get onboardingActivityQuestionSubtitle =>
      'How active are you? (without workouts)';

  @override
  String get onboardingGoalQuestionSubtitle =>
      'What\'s your current weight goal?';

  @override
  String get onboardingSaveUserError => 'Wrong input, please try again';

  @override
  String get settingsUnitsLabel => 'Units';

  @override
  String get settingsCalculationsLabel => 'Calculations';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeLightLabel => 'Light';

  @override
  String get settingsThemeDarkLabel => 'Dark';

  @override
  String get settingsThemeSystemDefaultLabel => 'System default';

  @override
  String get settingsLicensesLabel => 'Licenses';

  @override
  String get settingsDisclaimerLabel => 'Disclaimer';

  @override
  String get settingsReportErrorLabel => 'Report Error';

  @override
  String get settingsPrivacySettings => 'Privacy Settings';

  @override
  String get settingsSourceCodeLabel => 'Source Code';

  @override
  String get settingFeedbackLabel => 'Feedback';

  @override
  String get settingAboutLabel => 'About';

  @override
  String get settingsMassLabel => 'Mass';

  @override
  String get settingsSystemLabel => 'System';

  @override
  String get settingsMetricLabel => 'Metric (kg, cm, ml)';

  @override
  String get settingsImperialLabel => 'Imperial (lbs, ft, oz)';

  @override
  String get settingsDistanceLabel => 'Distance';

  @override
  String get settingsVolumeLabel => 'Volume';

  @override
  String get disclaimerText =>
      'MacroTracker is not a medical application. All data provided is not validated and should be used with caution. Please maintain a healthy lifestyle and consult a professional if you have any problems. Use during illness, pregnancy or lactation is not recommended.';

  @override
  String get reportErrorDialogText =>
      'Do you want to report an error to the developer?';

  @override
  String get sendAnonymousUserData => 'Send anonymous usage data';

  @override
  String get appLicenseLabel => 'GPL-3.0 license';

  @override
  String get calculationsTDEELabel => 'TDEE equation';

  @override
  String get calculationsTDEEIOM2006Label => 'Institute of Medicine Equation';

  @override
  String get calculationsRecommendedLabel => '(recommended)';

  @override
  String get calculationsMacronutrientsDistributionLabel =>
      'Macros distribution';

  @override
  String calculationsMacrosDistribution(
      Object pctCarbs, Object pctFats, Object pctProteins) {
    return '$pctCarbs% carbs, $pctFats% fats, $pctProteins% proteins';
  }

  @override
  String get dailyKcalAdjustmentLabel => 'Daily Kcal adjustment:';

  @override
  String get macroDistributionLabel => 'Macronutrient Distribution:';

  @override
  String get exportImportLabel => 'Export / Import data';

  @override
  String get exportImportDescription =>
      'You can export the app data to a zip file and import it later. This is useful if you want to backup your data or transfer it to another device.\n\nThe app does not use any cloud service to store your data.';

  @override
  String get exportImportSuccessLabel => 'Export / Import successful';

  @override
  String get exportImportErrorLabel => 'Export / Import error';

  @override
  String get exportAction => 'Export';

  @override
  String get importAction => 'Import';

  @override
  String get addItemLabel => 'Add new Item:';

  @override
  String get activityLabel => 'Activity';

  @override
  String get activityExample => 'e.g. running, biking, yoga ...';

  @override
  String get breakfastLabel => 'Breakfast';

  @override
  String get breakfastExample => 'e.g. cereal, milk, coffee ...';

  @override
  String get lunchLabel => 'Lunch';

  @override
  String get lunchExample => 'e.g. pizza, salad, rice ...';

  @override
  String get dinnerLabel => 'Dinner';

  @override
  String get dinnerExample => 'e.g. soup, chicken, wine ...';

  @override
  String get snackLabel => 'Snack';

  @override
  String get snackExample => 'e.g. apple, ice cream, chocolate ...';

  @override
  String get editItemDialogTitle => 'Edit item';

  @override
  String get itemUpdatedSnackbar => 'Item updated';

  @override
  String get deleteTimeDialogTitle => 'Delete Item?';

  @override
  String get deleteTimeDialogContent => 'Do want to delete the selected item?';

  @override
  String get deleteTimeDialogPluralTitle => 'Delete Items?';

  @override
  String get deleteTimeDialogPluralContent =>
      'Do want to delete all items of this meal?';

  @override
  String get itemDeletedSnackbar => 'Item deleted';

  @override
  String get copyDialogTitle => 'Which meal type do you want to copy to?';

  @override
  String get copyOrDeleteTimeDialogTitle => 'What do you want to do?';

  @override
  String get copyOrDeleteTimeDialogContent =>
      'With \"Copy to today\" you can copy the meal to today. With \"Delete\" you can delete the meal.';

  @override
  String get dialogCopyLabel => 'Copy to today';

  @override
  String get dialogDeleteLabel => 'DELETE';

  @override
  String get deleteAllLabel => 'Delete all';

  @override
  String get suppliedLabel => 'supplied';

  @override
  String get burnedLabel => 'burned';

  @override
  String get kcalLeftLabel => 'kcal left';

  @override
  String get nutritionInfoLabel => 'Nutrition Information';

  @override
  String get kcalLabel => 'kcal';

  @override
  String get carbsLabel => 'carbs';

  @override
  String get fatLabel => 'fat';

  @override
  String get proteinLabel => 'protein';

  @override
  String get energyLabel => 'energy';

  @override
  String get saturatedFatLabel => 'saturated fat';

  @override
  String get carbohydrateLabel => 'carbohydrate';

  @override
  String get sugarLabel => 'sugar';

  @override
  String get fiberLabel => 'fiber';

  @override
  String get per100gmlLabel => 'Per 100g/ml';

  @override
  String get additionalInfoLabelOFF => 'More Information at\nOpenFoodFacts';

  @override
  String get offDisclaimer =>
      'The data provided to you by this app are retrieved from the Open Food Facts database. No guarantees can be made for the accuracy, completeness, or reliability of the information provided. The data are provided “as is” and the originating source for the data (Open Food Facts) is not liable for any damages arising out of the use of the data.';

  @override
  String get additionalInfoLabelFDC => 'More Information at\nFoodData Central';

  @override
  String get additionalInfoLabelUnknown => 'Unknown Meal Item';

  @override
  String get additionalInfoLabelCustom => 'Custom Meal Item';

  @override
  String get additionalInfoLabelCompendium2011 =>
      'Information provided\n by the \n\'2011 Compendium\n of Physical Activities\'';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get baseQuantityLabel => 'Base quantity (g/ml)';

  @override
  String get unitLabel => 'Unit';

  @override
  String get scanProductLabel => 'Scan Product';

  @override
  String get gramUnit => 'g';

  @override
  String get milliliterUnit => 'ml';

  @override
  String get gramMilliliterUnit => 'g/ml';

  @override
  String get ozUnit => 'oz';

  @override
  String get flOzUnit => 'fl.oz';

  @override
  String get notAvailableLabel => 'N/A';

  @override
  String get missingProductInfo =>
      'Product missing required kcal or macronutrients information';

  @override
  String get infoAddedIntakeLabel => 'Added new intake';

  @override
  String get infoAddedActivityLabel => 'Added new activity';

  @override
  String get editMealLabel => 'Edit meal';

  @override
  String get mealNameLabel => 'Meal name';

  @override
  String get mealBrandsLabel => 'Brands';

  @override
  String get mealSizeLabel => 'Meal size (g/ml)';

  @override
  String get mealSizeLabelImperial => 'Meal size (oz/fl oz)';

  @override
  String get servingLabel => 'Serving';

  @override
  String get perServingLabel => 'Per Serving';

  @override
  String get servingSizeLabelMetric => 'Serving size (g/ml)';

  @override
  String get servingSizeLabelImperial => 'Serving size (oz/fl oz)';

  @override
  String get mealUnitLabel => 'Meal unit';

  @override
  String get mealKcalLabel => 'kcal per';

  @override
  String get mealCarbsLabel => 'carbs per';

  @override
  String get mealFatLabel => 'fat per';

  @override
  String get mealProteinLabel => 'protein per 100 g/ml';

  @override
  String get errorMealSave =>
      'Error while saving meal. Did you input the correct meal information?';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get bmiInfo =>
      'Body Mass Index (BMI) is a index to classify overweight and obesity in adults. It is defined as weight in kilograms divided by the square of height in meters (kg/m²).\n\nBMI does not differentiate between fat and muscle mass and can be misleading for some individuals.';

  @override
  String get readLabel => 'I have read and accept the privacy policy.';

  @override
  String get privacyPolicyLabel => 'Privacy policy';

  @override
  String get dataCollectionLabel =>
      'Support development by providing anonymous usage data';

  @override
  String get palSedentaryLabel => 'Sedentary';

  @override
  String get palSedentaryDescriptionLabel =>
      'e.g. office job and mostly sitting free time activities';

  @override
  String get palLowLActiveLabel => 'Low Active';

  @override
  String get palLowActiveDescriptionLabel =>
      'e.g. sitting or standing in job and light free time activities';

  @override
  String get palActiveLabel => 'Active';

  @override
  String get palActiveDescriptionLabel =>
      'Mostly standing or walking in job and active free time activities';

  @override
  String get palVeryActiveLabel => 'Very Active';

  @override
  String get palVeryActiveDescriptionLabel =>
      'Mostly walking, running or carrying weight in job and active free time activities';

  @override
  String get selectPalCategoryLabel => 'Select Activity Level';

  @override
  String get chooseWeightGoalLabel => 'Choose Weight Goal';

  @override
  String get goalLoseWeight => 'Lose Weight';

  @override
  String get goalMaintainWeight => 'Maintain Weight';

  @override
  String get goalGainWeight => 'Gain Weight';

  @override
  String get goalLabel => 'Goal';

  @override
  String get selectHeightDialogLabel => 'Select Height';

  @override
  String get heightLabel => 'Height';

  @override
  String get cmLabel => 'cm';

  @override
  String get ftLabel => 'ft';

  @override
  String get selectWeightDialogLabel => 'Select Weight';

  @override
  String get weightLabel => 'Weight';

  @override
  String get kgLabel => 'kg';

  @override
  String get lbsLabel => 'lbs';

  @override
  String get ageLabel => 'Age';

  @override
  String yearsLabel(Object age) {
    return '$age years';
  }

  @override
  String get selectGenderDialogLabel => 'Select Gender';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderMaleLabel => '♂ male';

  @override
  String get genderFemaleLabel => '♀ female';

  @override
  String get nothingAddedLabel => 'Nothing added';

  @override
  String get nutritionalStatusUnderweight => 'Underweight';

  @override
  String get nutritionalStatusNormalWeight => 'Normal Weight';

  @override
  String get nutritionalStatusPreObesity => 'Pre-obesity';

  @override
  String get nutritionalStatusObeseClassI => 'Obesity Class I';

  @override
  String get nutritionalStatusObeseClassII => 'Obesity Class II';

  @override
  String get nutritionalStatusObeseClassIII => 'Obesity Class III';

  @override
  String nutritionalStatusRiskLabel(Object riskValue) {
    return 'Risk of comorbidities: $riskValue';
  }

  @override
  String get nutritionalStatusRiskLow =>
      'Low \n(but risk of other \nclinical problems increased)';

  @override
  String get nutritionalStatusRiskAverage => 'Average';

  @override
  String get nutritionalStatusRiskIncreased => 'Increased';

  @override
  String get nutritionalStatusRiskModerate => 'Moderate';

  @override
  String get nutritionalStatusRiskSevere => 'Severe';

  @override
  String get nutritionalStatusRiskVerySevere => 'Very severe';

  @override
  String get errorOpeningEmail => 'Error while opening email app';

  @override
  String get errorOpeningBrowser => 'Error while opening browser app';

  @override
  String get errorFetchingProductData => 'Error while fetching product data';

  @override
  String get errorProductNotFound => 'Product not found';

  @override
  String get errorLoadingActivities => 'Error while loading activities';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get retryLabel => 'Retry';

  @override
  String get paHeadingBicycling => 'bicycling';

  @override
  String get paHeadingConditionalExercise => 'conditioning exercise';

  @override
  String get paHeadingDancing => 'dancing';

  @override
  String get paHeadingRunning => 'running';

  @override
  String get paHeadingSports => 'sports';

  @override
  String get paHeadingWalking => 'walking';

  @override
  String get paHeadingWaterActivities => 'water activities';

  @override
  String get paHeadingWinterActivities => 'winter activities';

  @override
  String get paGeneralDesc => 'general';

  @override
  String get paBicyclingGeneral => 'bicycling';

  @override
  String get paBicyclingGeneralDesc => 'general';

  @override
  String get paBicyclingMountainGeneral => 'bicycling, mountain';

  @override
  String get paBicyclingMountainGeneralDesc => 'general';

  @override
  String get paUnicyclingGeneral => 'unicycling';

  @override
  String get paUnicyclingGeneralDesc => 'general';

  @override
  String get paBicyclingStationaryGeneral => 'bicycling, stationary';

  @override
  String get paBicyclingStationaryGeneralDesc => 'general';

  @override
  String get paCalisthenicsGeneral => 'calisthenics';

  @override
  String get paCalisthenicsGeneralDesc =>
      'light or moderate effort, general (e.g., back exercises)';

  @override
  String get paResistanceTraining => 'resistance training';

  @override
  String get paResistanceTrainingDesc =>
      'weight lifting, free weight, nautilus or universal';

  @override
  String get paRopeSkippingGeneral => 'rope skipping';

  @override
  String get paRopeSkippingGeneralDesc => 'general';

  @override
  String get paWaterAerobics => 'water exercise';

  @override
  String get paWaterAerobicsDesc => 'water aerobics, water calisthenics';

  @override
  String get paDancingAerobicGeneral => 'aerobic';

  @override
  String get paDancingAerobicGeneralDesc => 'general';

  @override
  String get paDancingGeneral => 'general dancing';

  @override
  String get paDancingGeneralDesc =>
      'e.g. disco, folk, Irish step dancing, line dancing, polka, country';

  @override
  String get paJoggingGeneral => 'jogging';

  @override
  String get paJoggingGeneralDesc => 'general';

  @override
  String get paRunningGeneral => 'running';

  @override
  String get paRunningGeneralDesc => 'general';

  @override
  String get paArcheryGeneral => 'archery';

  @override
  String get paArcheryGeneralDesc => 'non-hunting';

  @override
  String get paBadmintonGeneral => 'badminton';

  @override
  String get paBadmintonGeneralDesc => 'social singles and doubles, general';

  @override
  String get paBasketballGeneral => 'basketball';

  @override
  String get paBasketballGeneralDesc => 'general';

  @override
  String get paBilliardsGeneral => 'billiards';

  @override
  String get paBilliardsGeneralDesc => 'general';

  @override
  String get paBowlingGeneral => 'bowling';

  @override
  String get paBowlingGeneralDesc => 'general';

  @override
  String get paBoxingBag => 'boxing';

  @override
  String get paBoxingBagDesc => 'punching bag';

  @override
  String get paBoxingGeneral => 'boxing';

  @override
  String get paBoxingGeneralDesc => 'in ring, general';

  @override
  String get paBroomball => 'broomball';

  @override
  String get paBroomballDesc => 'general';

  @override
  String get paChildrenGame => 'children’s games';

  @override
  String get paChildrenGameDesc =>
      '(e.g., hopscotch, 4-square, dodgeball, playground apparatus, t-ball, tetherball, marbles, arcade games), moderate effort';

  @override
  String get paCheerleading => 'cheerleading';

  @override
  String get paCheerleadingDesc => 'gymnastic moves, competitive';

  @override
  String get paCricket => 'cricket';

  @override
  String get paCricketDesc => 'batting, bowling, fielding';

  @override
  String get paCroquet => 'croquet';

  @override
  String get paCroquetDesc => 'general';

  @override
  String get paCurling => 'curling';

  @override
  String get paCurlingDesc => 'general';

  @override
  String get paDartsWall => 'darts';

  @override
  String get paDartsWallDesc => 'wall or lawn';

  @override
  String get paAutoRacing => 'auto racing';

  @override
  String get paAutoRacingDesc => 'open wheel';

  @override
  String get paFencing => 'fencing';

  @override
  String get paFencingDesc => 'general';

  @override
  String get paAmericanFootballGeneral => 'football';

  @override
  String get paAmericanFootballGeneralDesc => 'touch, flag, general';

  @override
  String get paCatch => 'football or baseball';

  @override
  String get paCatchDesc => 'playing catch';

  @override
  String get paFrisbee => 'frisbee playing';

  @override
  String get paFrisbeeDesc => 'general';

  @override
  String get paGolfGeneral => 'golf';

  @override
  String get paGolfGeneralDesc => 'general';

  @override
  String get paGymnasticsGeneral => 'gymnastics';

  @override
  String get paGymnasticsGeneralDesc => 'general';

  @override
  String get paHackySack => 'hacky sack';

  @override
  String get paHackySackDesc => 'general';

  @override
  String get paHandballGeneral => 'handball';

  @override
  String get paHandballGeneralDesc => 'general';

  @override
  String get paHangGliding => 'hang gliding';

  @override
  String get paHangGlidingDesc => 'general';

  @override
  String get paHockeyField => 'hockey, field';

  @override
  String get paHockeyFieldDesc => 'general';

  @override
  String get paIceHockeyGeneral => 'ice hockey';

  @override
  String get paIceHockeyGeneralDesc => 'general';

  @override
  String get paHorseRidingGeneral => 'horseback riding';

  @override
  String get paHorseRidingGeneralDesc => 'general';

  @override
  String get paJaiAlai => 'jai alai';

  @override
  String get paJaiAlaiDesc => 'general';

  @override
  String get paMartialArtsSlower => 'martial arts';

  @override
  String get paMartialArtsSlowerDesc =>
      'different types, slower pace, novice performers, practice';

  @override
  String get paMartialArtsModerate => 'martial arts';

  @override
  String get paMartialArtsModerateDesc =>
      'different types, moderate pace (e.g., judo, jujitsu, karate, kick boxing, tae kwan do, tai-bo, Muay Thai boxing)';

  @override
  String get paJuggling => 'juggling';

  @override
  String get paJugglingDesc => 'general';

  @override
  String get paKickball => 'kickball';

  @override
  String get paKickballDesc => 'general';

  @override
  String get paLacrosse => 'lacrosse';

  @override
  String get paLacrosseDesc => 'general';

  @override
  String get paLawnBowling => 'lawn bowling';

  @override
  String get paLawnBowlingDesc => 'bocce ball, outdoor';

  @override
  String get paMotoCross => 'moto-cross';

  @override
  String get paMotoCrossDesc =>
      'off-road motor sports, all-terrain vehicle, general';

  @override
  String get paOrienteering => 'orienteering';

  @override
  String get paOrienteeringDesc => 'general';

  @override
  String get paPaddleball => 'paddleball';

  @override
  String get paPaddleballDesc => 'casual, general';

  @override
  String get paPoloHorse => 'polo';

  @override
  String get paPoloHorseDesc => 'on horseback';

  @override
  String get paRacquetball => 'racquetball';

  @override
  String get paRacquetballDesc => 'general';

  @override
  String get paMountainClimbing => 'climbing';

  @override
  String get paMountainClimbingDesc => 'rock or mountain climbing';

  @override
  String get paRodeoSportGeneralModerate => 'rodeo sports';

  @override
  String get paRodeoSportGeneralModerateDesc => 'general, moderate effort';

  @override
  String get paRopeJumpingGeneral => 'rope jumping';

  @override
  String get paRopeJumpingGeneralDesc =>
      'moderate pace, 100-120 skips/min, general, 2 foot skip, plain bounce';

  @override
  String get paRugbyCompetitive => 'rugby';

  @override
  String get paRugbyCompetitiveDesc => 'union, team, competitive';

  @override
  String get paRugbyNonCompetitive => 'rugby';

  @override
  String get paRugbyNonCompetitiveDesc => 'touch, non-competitive';

  @override
  String get paShuffleboard => 'shuffleboard';

  @override
  String get paShuffleboardDesc => 'general';

  @override
  String get paSkateboardingGeneral => 'skateboarding';

  @override
  String get paSkateboardingGeneralDesc => 'general, moderate effort';

  @override
  String get paSkatingRoller => 'roller skating';

  @override
  String get paSkatingRollerDesc => 'general';

  @override
  String get paRollerbladingLight => 'rollerblading';

  @override
  String get paRollerbladingLightDesc => 'in-line skating';

  @override
  String get paSkydiving => 'skydiving';

  @override
  String get paSkydivingDesc => 'skydiving, base jumping, bungee jumping';

  @override
  String get paSoccerGeneral => 'soccer';

  @override
  String get paSoccerGeneralDesc => 'casual, general';

  @override
  String get paSoftballBaseballGeneral => 'softball / baseball';

  @override
  String get paSoftballBaseballGeneralDesc => 'fast or slow pitch, general';

  @override
  String get paSquashGeneral => 'squash';

  @override
  String get paSquashGeneralDesc => 'general';

  @override
  String get paTableTennisGeneral => 'table tennis';

  @override
  String get paTableTennisGeneralDesc => 'table tennis, ping pong';

  @override
  String get paTaiChiQiGongGeneral => 'tai chi, qi gong';

  @override
  String get paTaiChiQiGongGeneralDesc => 'general';

  @override
  String get paTennisGeneral => 'tennis';

  @override
  String get paTennisGeneralDesc => 'general';

  @override
  String get paTrampolineLight => 'trampoline';

  @override
  String get paTrampolineLightDesc => 'recreational';

  @override
  String get paVolleyballGeneral => 'volleyball';

  @override
  String get paVolleyballGeneralDesc =>
      'non-competitive, 6 - 9 member team, general';

  @override
  String get paWrestling => 'wrestling';

  @override
  String get paWrestlingDesc => 'general';

  @override
  String get paWallyball => 'wallyball';

  @override
  String get paWallyballDesc => 'general';

  @override
  String get paTrackField => 'track and field';

  @override
  String get paTrackField1Desc => '(e.g. shot, discus, hammer throw)';

  @override
  String get paTrackField2Desc =>
      '(e.g. high jump, long jump, triple jump, javelin, pole vault)';

  @override
  String get paTrackField3Desc => '(e.g. steeplechase, hurdles)';

  @override
  String get paBackpackingGeneral => 'backpacking';

  @override
  String get paBackpackingGeneralDesc => 'general';

  @override
  String get paClimbingHillsNoLoadGeneral => 'climbing hills, no load';

  @override
  String get paClimbingHillsNoLoadGeneralDesc => 'no load';

  @override
  String get paHikingCrossCountry => 'hiking';

  @override
  String get paHikingCrossCountryDesc => 'cross country';

  @override
  String get paWalkingForPleasure => 'walking';

  @override
  String get paWalkingForPleasureDesc => 'for pleasure';

  @override
  String get paWalkingTheDog => 'walking the dog';

  @override
  String get paWalkingTheDogDesc => 'general';

  @override
  String get paCanoeingGeneral => 'canoeing';

  @override
  String get paCanoeingGeneralDesc => 'rowing, for pleasure, general';

  @override
  String get paDivingSpringboardPlatform => 'diving';

  @override
  String get paDivingSpringboardPlatformDesc => 'springboard or platform';

  @override
  String get paKayakingModerate => 'kayaking';

  @override
  String get paKayakingModerateDesc => 'moderate effort';

  @override
  String get paPaddleBoat => 'paddle boat';

  @override
  String get paPaddleBoatDesc => 'general';

  @override
  String get paSailingGeneral => 'sailing';

  @override
  String get paSailingGeneralDesc =>
      'boat and board sailing, windsurfing, ice sailing, general';

  @override
  String get paSkiingWaterWakeboarding => 'water skiing';

  @override
  String get paSkiingWaterWakeboardingDesc => 'water or wakeboarding';

  @override
  String get paDivingGeneral => 'diving';

  @override
  String get paDivingGeneralDesc => 'skindiving, scuba diving, general';

  @override
  String get paSnorkeling => 'snorkeling';

  @override
  String get paSnorkelingDesc => 'general';

  @override
  String get paSurfing => 'surfing';

  @override
  String get paSurfingDesc => 'body or board, general';

  @override
  String get paPaddleBoarding => 'paddle boarding';

  @override
  String get paPaddleBoardingDesc => 'standing';

  @override
  String get paSwimmingGeneral => 'swimming';

  @override
  String get paSwimmingGeneralDesc =>
      'treading water, moderate effort, general';

  @override
  String get paWateraerobicsCalisthenics => 'water aerobics';

  @override
  String get paWateraerobicsCalisthenicsDesc =>
      'water aerobics, water calisthenics';

  @override
  String get paWaterPolo => 'water polo';

  @override
  String get paWaterPoloDesc => 'general';

  @override
  String get paWaterVolleyball => 'water volleyball';

  @override
  String get paWaterVolleyballDesc => 'general';

  @override
  String get paIceSkatingGeneral => 'ice skating';

  @override
  String get paIceSkatingGeneralDesc => 'general';

  @override
  String get paSkiingGeneral => 'skiing';

  @override
  String get paSkiingGeneralDesc => 'general';

  @override
  String get paSnowShovingModerate => 'snow shoveling';

  @override
  String get paSnowShovingModerateDesc => 'by hand, moderate effort';

  @override
  String get todayLabel => 'Today';

  @override
  String get dayLabel => 'day';

  @override
  String get aiMealPhotoTitle => 'AI Meal Photo';

  @override
  String get aiReviewDraftTitle => 'Review AI Draft';

  @override
  String get aiDetectedIngredients => 'Detected ingredients';

  @override
  String aiActiveItemsCount(Object count) {
    return '$count active';
  }

  @override
  String get aiSaveAsRecipe => 'Save as recipe';

  @override
  String get aiAddIngredient => 'Add ingredient';

  @override
  String get aiSavingMeal => 'Saving meal...';

  @override
  String get aiSaveMeal => 'Save meal';

  @override
  String get aiDraftNotFound => 'Draft not found or expired.';

  @override
  String get aiRecipeNameLabel => 'Recipe name';

  @override
  String get aiRecipeNameHelper =>
      'Use names like pre-workout oats, post-workout chicken rice, or shake.';

  @override
  String get aiFavoriteQuickAccess => 'Favorite for quick access';

  @override
  String get aiCaptureByPhotoTitle => 'Capture by photo';

  @override
  String aiCaptureByPhotoSubtitle(Object mealType) {
    return 'Import a meal image, review the editable draft, and save it to $mealType.';
  }

  @override
  String get aiStepPickImage => 'Pick image';

  @override
  String get aiStepReviewItems => 'Review items';

  @override
  String get aiStepSaveMeal => 'Save meal';

  @override
  String get aiHintRecommendations => 'Recommendations';

  @override
  String get aiHintShowFullPlateTitle => 'Show full plate';

  @override
  String get aiHintShowFullPlateSubtitle =>
      'Better framing, better ingredient detection.';

  @override
  String get aiHintCheckSaucesTitle => 'Check sauces and oils';

  @override
  String get aiHintCheckSaucesSubtitle =>
      'The draft is just the first step. Correct hidden calories.';

  @override
  String get aiHintGymMealsTitle => 'Designed for gym meals';

  @override
  String get aiHintGymMealsSubtitle =>
      'Useful for bowls, shakes, post-workouts, and repeated meals.';

  @override
  String get aiButtonCapture => 'Take photo and review';

  @override
  String get aiButtonPickGallery => 'Pick from gallery';

  @override
  String get aiButtonUseText => 'Use text';

  @override
  String get aiStatusPreparing => 'Preparing image...';

  @override
  String get aiStatusConsulting => 'Consulting AI...';

  @override
  String get aiStatusPersonalizing => 'Personalizing...';

  @override
  String get aiErrorPayloadTooLarge =>
      'Image is too large for remote AI. Local draft created.';

  @override
  String get aiErrorMissingKey =>
      'Remote AI is not configured in backend. Local draft created.';

  @override
  String get aiErrorQuotaExceeded =>
      'Remote AI quota/rate limit reached. Local draft created.';

  @override
  String get aiErrorUnsupportedFormat =>
      'Image format not supported by remote AI. Try JPG/PNG. Local draft created.';

  @override
  String get aiErrorGeneric =>
      'Remote image interpretation failed. Local draft created with memory support.';

  @override
  String get aiRetry => 'Retry';

  @override
  String aiEditAmountTitle(Object item) {
    return 'Edit $item';
  }

  @override
  String aiQuantityUnitLabel(Object unit) {
    return 'Quantity ($unit)';
  }

  @override
  String get aiSaveDraftChangesError => 'Could not save draft changes';

  @override
  String get aiMealSavedSuccess => 'Meal saved';

  @override
  String get aiMealSaveError => 'Could not save this meal';

  @override
  String get aiGymLabelPostWorkout => 'Post-workout';

  @override
  String get aiGymLabelPreWorkout => 'Pre-workout';

  @override
  String get aiGymLabelHighProtein => 'High protein';

  @override
  String get aiGymLabelLeanDefinition => 'Lean for definition';

  @override
  String get aiGymLabelBalanced => 'Balanced';

  @override
  String aiSuggestionApplied(Object title) {
    return 'Applied suggestion: $title';
  }

  @override
  String aiReplacedBySummary(Object source) {
    return 'Replaced by $source to improve accuracy.';
  }

  @override
  String get recipeSavedSnackbar => 'Recipe saved';

  @override
  String get aiPhotoCaptured => 'Captured photo';

  @override
  String get aiPhotoCapturedHint =>
      'Tap to enlarge. Toggle crop/fit for quick inspection.';

  @override
  String get aiPhotoPreviewError => 'Could not load preview';

  @override
  String get aiCropLabel => 'Crop';

  @override
  String get aiFitLabel => 'Fit';

  @override
  String get aiPhotoZoomTitle => 'Photo zoom';

  @override
  String get aiSourcePhoto => 'AI Photo';

  @override
  String get aiSourceText => 'AI Text';

  @override
  String aiIngredientsCount(Object count) {
    return '$count ingredients';
  }

  @override
  String get aiServingsToSave => 'Servings to save';

  @override
  String get aiCustomServingsLabel => 'Custom servings';

  @override
  String get aiCustomServingsHelper =>
      'Adjust the final portion before saving.';

  @override
  String get aiYourMatches => 'Your matches';

  @override
  String get aiMatchesHint =>
      'Use a frequent meal, recipe, or previous correction if it looks more like what you ate.';

  @override
  String get aiMatchesReferenceHint =>
      'This is only a reference. It will never be added to your meal automatically.';

  @override
  String get aiButtonUse => 'Use';

  @override
  String aiServingsReady(Object count) {
    return '$count servings ready to save';
  }

  @override
  String get aiEditableLabel => 'Editable';

  @override
  String aiUseHabitual(Object label) {
    return 'Use habitual: $label';
  }

  @override
  String get aiQuickAdjustment => 'Quick adjustment';

  @override
  String get aiExcludeFromMeal => 'Excluded from the final meal.';

  @override
  String get aiConfidenceHigh => 'High confidence';

  @override
  String get aiConfidenceMedium => 'Medium confidence';

  @override
  String get aiConfidenceLow => 'Low confidence';

  @override
  String get aiConfidenceLowHint =>
      'This ingredient has low certainty. Your habitual correction is usually the fastest option.';

  @override
  String get aiConfidenceLowGenericHint =>
      'This ingredient has low certainty. Check amount or replace it with a more precise food.';

  @override
  String get aiConfidenceMediumHint =>
      'The amount may vary. Check the portion if you see it doesn\'t fit the photo.';

  @override
  String get aiRestoreLabel => 'Restore';

  @override
  String get aiRemoveLabel => 'Remove';

  @override
  String get aiSubstituteLabel => 'Substitute';

  @override
  String get aiAmountLabel => 'Amount';

  @override
  String get aiEditMacrosTitle => 'Edit macros';

  @override
  String get aiEditMacrosLabel => 'Macros';

  @override
  String get aiMatchHigh => 'High match';

  @override
  String get aiMatchGood => 'Good match';

  @override
  String get aiMatchPossible => 'Possible match';

  @override
  String get macroSuggestionsEmpty =>
      'Save some recipes and this section will start suggesting based on your training day.';

  @override
  String get macroSuggestionsTitleDef => 'Options for definition';

  @override
  String get macroSuggestionsTitleLeg => 'Options for legs';

  @override
  String get macroSuggestionsTitleTorso => 'Options for torso';

  @override
  String get macroSuggestionsTitleCardio => 'Options for cardio';

  @override
  String get macroSuggestionsTitleRest => 'Options for rest';

  @override
  String get macroSuggestionsSubtitleGym =>
      'Recommended meals to perform and recover better.';

  @override
  String get macroSuggestionsSubtitleLoseWeight =>
      'High protein options with controlled calories.';

  @override
  String get macroSuggestionsSubtitleRest =>
      'Clean closings with high protein and no caloric excess.';

  @override
  String get macroSuggestionsSubtitleDefault =>
      'Saved meals based on what you are still missing today.';

  @override
  String macroSuggestionsAddedTo(Object recipe, Object slot) {
    return '$recipe added to $slot';
  }

  @override
  String macroSuggestionsServingsPortions(Object count) {
    return '$count portions';
  }

  @override
  String get homeDashboardTitle => 'Gym nutrition';

  @override
  String get homeDashboardSubtitle => 'Today at a glance.';

  @override
  String get homeDashboardEmpty =>
      'Log a meal or workout to unlock better guidance.';

  @override
  String get homeDashboardGoalLabel => 'Goal';

  @override
  String get homeDashboardFocusLabel => 'Focus';

  @override
  String homeDashboardMealsChip(Object count) {
    return '$count meals';
  }

  @override
  String homeDashboardBurnedChip(Object count) {
    return '$count burned';
  }

  @override
  String homeDashboardSessionsChip(Object count) {
    return '$count sessions';
  }

  @override
  String get homeDashboardProteinRemaining => 'Protein left';

  @override
  String get homeDashboardKcalRemaining => 'Kcal left';

  @override
  String get homeDashboardOverGoal => 'Over goal';

  @override
  String homeDashboardKcalProgress(Object current, Object goal) {
    return '$current of $goal kcal';
  }

  @override
  String get homeDashboardMacroDone => 'Goal reached';

  @override
  String get homeDashboardStatusDefClosing =>
      'Definition on track. Keep the last meal high in protein.';

  @override
  String get homeDashboardStatusBulkOpen =>
      'You still have room. Add easy carbs and protein.';

  @override
  String get homeDashboardStatusProteinGap =>
      'Protein is still the main gap. Prioritize it next meal.';

  @override
  String get homeDashboardStatusCarbWindow =>
      'You still have carb room. Good moment for training fuel.';

  @override
  String get homeDashboardStatusRestClosing =>
      'Rest day almost closed. Finish light and protein-first.';

  @override
  String get homeDashboardStatusOverGoal =>
      'You are above target. Keep the rest of the day tighter.';

  @override
  String get homeDashboardStatusDefault =>
      'Good pace. Keep it simple and close the day clean.';

  @override
  String get hydrationAddWater => 'Add water';

  @override
  String get hydrationRemoveWater => 'Remove water';

  @override
  String get hydrationGoalReached => 'Goal reached!';

  @override
  String get hydrationTitle => 'Hydration';

  @override
  String get aiTextCaptureTitle => 'Meal by text';

  @override
  String get aiTextCaptureHint =>
      'Example: 2 eggs, toast with butter and coffee with milk';

  @override
  String get aiTextCaptureButton => 'Interpret meal';

  @override
  String get aiTextCaptureLoading => 'Interpreting...';

  @override
  String get aiTextCaptureDescription =>
      'Describe the meal naturally. The text can be processed remotely to estimate ingredients and macros, and you will always review the draft before saving.';

  @override
  String get aiTextCaptureError =>
      'Remote interpretation not available. Local draft created with memory support.';

  @override
  String get aiReplaceTitle => 'Replace ingredient';

  @override
  String get aiReplaceHint => 'Search for food';

  @override
  String get aiReplaceEmpty => 'Search for a food to replace this ingredient.';

  @override
  String get aiReplaceMinLength => 'Enter at least 2 characters.';

  @override
  String get aiReplaceNoResults => 'No results found.';

  @override
  String get aiReplaceError => 'Cannot search for food right now.';

  @override
  String get weeklyInsightsTitle => 'Weekly Insights';

  @override
  String get weeklyInsightsError => 'Could not load weekly insights.';

  @override
  String get weeklyInsightsSummary => 'Summary';

  @override
  String get weeklyInsightsCheckup => 'Smart Weekly Checkup';

  @override
  String weeklyInsightsTrend(Object delta) {
    return 'Weight trend: $delta kg/week';
  }

  @override
  String weeklyInsightsApplyAdjustment(Object delta) {
    return 'Apply $delta kcal/day';
  }

  @override
  String get weeklyInsightsAverages => 'Weekly Averages';

  @override
  String get weeklyInsightsAdherence => 'Adherence';

  @override
  String get weeklyInsightsProteinConsistency => 'Protein Consistency';

  @override
  String weeklyInsightsRegisteredDays(Object percent) {
    return '$percent% of registered days';
  }

  @override
  String get weeklyInsightsTopMeals => 'Most Frequent Meals';

  @override
  String get weeklyInsightsNoFrequentMeals =>
      'No repeated meals detected this week.';

  @override
  String get weeklyInsightsOvereatingPattern => 'Overeating Pattern';

  @override
  String get weeklyInsightsCoverage => 'Coverage';

  @override
  String weeklyInsightsTrackedDays(Object count) {
    return '$count days registered this week';
  }

  @override
  String weeklyInsightsAdjustmentSuccess(Object kcal) {
    return 'Daily adjustment updated to $kcal kcal.';
  }

  @override
  String get recipeLibraryTitle => 'Saved meals';

  @override
  String get recipeLibrarySearchHint => 'Search saved meals';

  @override
  String get recipeLibraryEmpty =>
      'No saved meals yet.\nSave meals as recipes to reuse them.';

  @override
  String recipeLibraryIngredientsCount(Object count) {
    return '$count ingredients';
  }

  @override
  String recipeLibraryServingsCount(Object count) {
    return '$count servings';
  }

  @override
  String get recipeLibraryFavorite => 'Favorite';

  @override
  String get recipeLibraryRemoveFavorite => 'Remove favorite';

  @override
  String get recipeLibraryMarkFavorite => 'Mark favorite';

  @override
  String recipeLibraryAddedSnackbar(Object name) {
    return '$name added';
  }

  @override
  String get recipeLibraryIntro =>
      'One library, two sources: meals you save manually and repeated meals detected automatically.';

  @override
  String get recipeLibraryManualSectionTitle => 'Saved recipes';

  @override
  String get recipeLibraryManualSectionSubtitle =>
      'You save these on purpose to reuse them whenever you want.';

  @override
  String get recipeLibraryFrequentSectionTitle => 'Repeated suggestions';

  @override
  String get recipeLibraryFrequentSectionSubtitle =>
      'Detected from your history so you can repeat them faster.';

  @override
  String recipeLibraryFrequentUses(Object count) {
    return '$count times';
  }

  @override
  String get settingsAiCostLabel => 'AI Cost';

  @override
  String settingsAiCostTotal(Object cost) {
    return 'Total estimated: $cost';
  }

  @override
  String settingsAiCostToday(Object cost) {
    return 'Today: $cost';
  }

  @override
  String settingsAiCostMonth(Object cost) {
    return 'This month: $cost';
  }

  @override
  String settingsAiCallsTotal(Object count) {
    return 'Total calls: $count';
  }

  @override
  String settingsAiCallsText(Object count) {
    return 'Text calls: $count';
  }

  @override
  String settingsAiCallsPhoto(Object count) {
    return 'Photo calls: $count';
  }

  @override
  String get settingsAiCostDescription =>
      'Based on real token usage per backend request.';

  @override
  String get settingsResetLabel => 'Reset';

  @override
  String get healthConnectAutoSyncTitle => 'Health Connect auto-sync';

  @override
  String get healthConnectAutoSyncSubtitle =>
      'Sync sleep and steps automatically on app open.';

  @override
  String get healthConnectSyncNowTitle => 'Sync Health Connect now';

  @override
  String get healthConnectGrantPermissionsTitle =>
      'Grant Health Connect permissions';

  @override
  String get healthConnectGrantPermissionsSubtitle =>
      'Open the permission flow for sleep and steps.';

  @override
  String get healthConnectStatusChecking => 'Checking Health Connect status...';

  @override
  String get healthConnectStatusUnavailable =>
      'Health Connect is not available on this device.';

  @override
  String get healthConnectStatusPermissionsRequired =>
      'Health permissions are required to read sleep and steps.';

  @override
  String get healthConnectStatusActivityPermissionRequired =>
      'Activity Recognition permission is required for steps.';

  @override
  String get healthConnectStatusAutoSyncDisabled =>
      'Connected. Auto-sync is currently disabled.';

  @override
  String get healthConnectStatusReady =>
      'Connected. Sleep and steps can sync automatically.';

  @override
  String get healthConnectAutoSyncEnabledMessage =>
      'Health Connect auto-sync enabled.';

  @override
  String get healthConnectAutoSyncDisabledMessage =>
      'Health Connect auto-sync disabled.';

  @override
  String get healthConnectPermissionsUpdated =>
      'Health Connect permissions updated.';

  @override
  String get healthConnectPermissionsMissing =>
      'Health Connect permissions are still missing.';

  @override
  String get healthConnectSyncSuccess => 'Health Connect data synced.';

  @override
  String get healthConnectSyncNoChanges =>
      'No new Health Connect data was imported.';

  @override
  String get habitSourceHealthConnect => 'Health Connect';

  @override
  String get habitSourceManual => 'Manual';

  @override
  String get habitSourceSynced => 'Synced source';

  @override
  String get habitSourceManualAdjust => 'Manual adjustment';

  @override
  String get gymHabitsTitle => 'Habits and recovery';

  @override
  String gymHabitsCompletedToday(Object count) {
    return '$count/7 today';
  }

  @override
  String get gymHabitsSleepTitle => 'Sleep';

  @override
  String get gymHabitsStepsTitle => 'Steps';

  @override
  String get gymHabitsEnergyTitle => 'Energy';

  @override
  String gymHabitsSleepTarget(Object amount) {
    return 'Goal $amount h';
  }

  @override
  String gymHabitsStepsTarget(Object amount) {
    return 'Goal $amount';
  }

  @override
  String get gymHabitsSourceHealthConnectDetail =>
      'Main value from Health Connect';

  @override
  String get gymHabitsSourceManualDetail => 'Main value entered manually';

  @override
  String get gymHabitsManualAdjustHint =>
      'Use +/- only if you need to correct the value.';

  @override
  String get gymHabitsFocusLowerBody => 'Leg day';

  @override
  String get gymHabitsFocusUpperBody => 'Upper body day';

  @override
  String get gymHabitsFocusCardio => 'Cardio day';

  @override
  String get gymHabitsFocusRest => 'Rest day';

  @override
  String gymHabitsHydrationHintLowerBody(Object goal) {
    return 'Higher hydration target for leg day: $goal.';
  }

  @override
  String gymHabitsHydrationHintUpperBody(Object goal) {
    return 'Keep hydration high today: $goal.';
  }

  @override
  String gymHabitsHydrationHintCardio(Object goal) {
    return 'Prioritize fluids today: $goal.';
  }

  @override
  String gymHabitsHydrationHintRest(Object goal) {
    return 'Keep hydration steady today: $goal.';
  }

  @override
  String get homeWeeklyInsightsSubtitle =>
      'Check averages, adherence, protein and top meals';

  @override
  String get addMealBarcode => 'Barcode';

  @override
  String get addMealText => 'Text';

  @override
  String get addMealPhoto => 'Photo';

  @override
  String get addMealSaved => 'Saved';

  @override
  String get quickMealsTitle => 'Quick meals';

  @override
  String get quickMealsSubtitle =>
      'Use your saved recipes first. One tap logs a serving fast.';

  @override
  String get quickMealsSavedTooltip => 'Open saved meals';

  @override
  String get quickMealsFilterAll => 'All';

  @override
  String get quickMealsFilterPreWorkout => 'Before workout';

  @override
  String get quickMealsFilterPostWorkout => 'After workout';

  @override
  String get quickMealsFilterShake => 'Shake';

  @override
  String get quickMealsFilterLight => 'Light meal';

  @override
  String get quickMealsEmptyAll =>
      'Save meals as recipes to keep them one tap away here.';

  @override
  String get quickMealsEmptyFiltered =>
      'No quick meals in this lane yet. Use clear workout-style names so they are easier to recognize later.';

  @override
  String quickMealsAddedTo(Object recipe, Object slot) {
    return '$recipe added to $slot';
  }

  @override
  String get quickMealsLogServing => 'Log one serving';

  @override
  String quickMealsProteinShort(Object amount) {
    return 'P $amount';
  }

  @override
  String quickMealsMacrosSummary(Object carbs, Object fat, Object protein) {
    return 'C $carbs | F $fat | P $protein';
  }

  @override
  String get diaryDayCopied => 'Day copied to today';

  @override
  String get diaryCurrentWeek => 'Current week';

  @override
  String diaryAdherencePill(Object percent) {
    return '$percent% adherence';
  }

  @override
  String diaryProteinPill(Object amount) {
    return '${amount}g avg protein';
  }

  @override
  String diaryDaysPill(Object count) {
    return '$count/7 days';
  }

  @override
  String get diarySelectedDayLabel => 'Selected day';

  @override
  String get diaryPreviousDayTooltip => 'Previous day';

  @override
  String get diaryNextDayTooltip => 'Next day';

  @override
  String get diarySummaryTitle => 'Day summary';

  @override
  String get diaryCopyDayToToday => 'Copy day to today';

  @override
  String get diaryInGoal => 'In goal';

  @override
  String diaryKcalRemaining(Object amount) {
    return '$amount kcal remaining';
  }

  @override
  String diaryKcalOver(Object amount) {
    return '+$amount kcal';
  }

  @override
  String get diaryGoalReached => 'Goal reached';

  @override
  String diaryGramsRemaining(Object amount) {
    return '$amount g remaining';
  }

  @override
  String diaryMealsPill(Object count) {
    return '$count meals';
  }

  @override
  String diaryActivitiesPill(Object count) {
    return '$count activities';
  }

  @override
  String get diaryStatusInRange => 'In range';

  @override
  String get diaryStatusBelow => 'Below';

  @override
  String get diaryStatusAbove => 'Above';

  @override
  String diaryMacrosSummary(
      Object carbsGoal,
      Object carbsTracked,
      Object fatGoal,
      Object fatTracked,
      Object proteinGoal,
      Object proteinTracked) {
    return 'Carbs $carbsTracked/$carbsGoal g, fat $fatTracked/$fatGoal g, protein $proteinTracked/$proteinGoal g';
  }

  @override
  String get diaryEmptySection => 'Empty';

  @override
  String diaryElementsSection(Object count) {
    return '$count items';
  }

  @override
  String get profileSportsProfile => 'Sports profile';

  @override
  String get profileYourProfile => 'Your profile';

  @override
  String get profileYourProfileSubtitle =>
      'Adjust your base data so that calories, macros and recommendations are consistent.';

  @override
  String get profileCalculationBase =>
      'Calculation base for goals, tracking and suggestions.';

  @override
  String profileCurrentPhase(Object phase) {
    return 'Current phase: $phase';
  }

  @override
  String get profileGoalAndStrategy => 'Goal and strategy';

  @override
  String get profileGoalAndStrategySubtitle =>
      'What you change here impacts calories, macros and daily adjustments.';

  @override
  String get profileBodyProgress => 'Body progress';

  @override
  String get profileBodyProgressSubtitle =>
      'Weight trend, 7d average and waist';

  @override
  String get profileBodyData => 'Body data';

  @override
  String get profileBodyDataSubtitle =>
      'Weight, height, age and sex so that the base calculation remains accurate.';

  @override
  String get profileGenderLabel => 'Sex';

  @override
  String get profilePhotoOptions => 'Photo options';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profileRemovePhoto => 'Remove photo';

  @override
  String get profileGoalLose => 'Definition';

  @override
  String get profileGoalMaintain => 'Recomp.';

  @override
  String get profileGoalGain => 'Volume';

  @override
  String get profileGoalLoseDesc =>
      'Short and controlled deficit to lose fat without compromising performance or muscle mass.';

  @override
  String get profileGoalMaintainDesc =>
      'Maintain stable weight while prioritizing strength, performance and adherence.';

  @override
  String get profileGoalGainDesc =>
      'Measured surplus to push training, recovery and progression.';

  @override
  String get profileFocusLowerBody =>
      'Today the distribution increases carbs to support a hard leg session.';

  @override
  String get profileFocusUpperBody =>
      'Today the distribution maintains good fuel and clean recovery for torso.';

  @override
  String get profileFocusCardio =>
      'Today the distribution seeks enough energy without adding extra carbs.';

  @override
  String get profileFocusRest =>
      'Today the distribution cuts carbs and maintains high protein to recover.';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageSystemDefaultLabel => 'System default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsSelectLanguageTitle => 'Select language';

  @override
  String get servingsLabel => 'Servings';

  @override
  String get homePerformanceSummary => 'Performance Summary';

  @override
  String get nudgeSmartReminders => 'Smart reminders';

  @override
  String get nudgeNoPendingActions => 'No pending actions for now.';

  @override
  String get nudgeKeepAdherence => 'Only useful alerts to maintain adherence.';

  @override
  String nudgeProteinLeft(Object amount) {
    return 'You have ${amount}g of protein left. Prioritize a high protein meal.';
  }

  @override
  String get nudgeLowHydration =>
      'Low hydration today. Drink water to close at 100%.';

  @override
  String get nudgeDayClosing =>
      'Closing the day: you lack energy for goal. Add a clean closing meal.';

  @override
  String get nudgeNoReminders => 'No pending reminders. Doing great today.';

  @override
  String get weeklyInsightsNoOvereatingPattern => 'No clear overeating pattern';

  @override
  String get weeklyInsightsSlotMorning => 'Morning';

  @override
  String get weeklyInsightsSlotAfternoon => 'Afternoon';

  @override
  String get weeklyInsightsSlotEvening => 'Evening';

  @override
  String get weeklyInsightsSlotLateNight => 'Late night';

  @override
  String get weeklyInsightsSummaryNoDays => 'No days registered this week yet.';

  @override
  String get weeklyInsightsSummarySolid =>
      'Solid week: good caloric adherence and protein consistency.';

  @override
  String get weeklyInsightsSummaryIrregular =>
      'Caloric adherence was irregular this week.';

  @override
  String get weeklyInsightsSummaryProteinGap =>
      'The main gap was protein consistency.';

  @override
  String get weeklyInsightsSummaryStable =>
      'Stable week, with room to improve consistency.';

  @override
  String get weeklyInsightsRecAdherenceLow =>
      'Adherence too low for automatic adjustment. Improve consistency first.';

  @override
  String get weeklyInsightsRecLoseWeightStalled =>
      'Fat loss stalled: suggestion -100 kcal/day.';

  @override
  String get weeklyInsightsRecLoseWeightSlow =>
      'Slow fat loss: suggestion -50 kcal/day.';

  @override
  String get weeklyInsightsRecLoseWeightFast =>
      'Weight dropping too fast: suggestion +50 kcal/day.';

  @override
  String get weeklyInsightsRecLoseWeightCorrect =>
      'Correct definition pace. No kcal change.';

  @override
  String get weeklyInsightsRecMaintainUp =>
      'Weight trending up: suggestion -50 kcal/day.';

  @override
  String get weeklyInsightsRecMaintainDown =>
      'Weight trending down: suggestion +50 kcal/day.';

  @override
  String get weeklyInsightsRecMaintainStable =>
      'Stable maintenance. No kcal change.';

  @override
  String get weeklyInsightsRecGainSlow =>
      'Bulk too slow: suggestion +100 kcal/day.';

  @override
  String get weeklyInsightsRecGainSoft =>
      'Soft bulk pace: suggestion +50 kcal/day.';

  @override
  String get weeklyInsightsRecGainFast =>
      'Weight rising too fast: suggestion -50 kcal/day.';

  @override
  String get weeklyInsightsRecGainCorrect =>
      'Controlled bulk pace. No kcal change.';

  @override
  String weeklyInsightsCurrentAdjustment(Object kcal) {
    return 'Current adjustment: $kcal kcal.';
  }

  @override
  String get bodyProgressTitle => 'Body progress';

  @override
  String get bodyProgressLoadError => 'Body progress could not be loaded.';

  @override
  String get bodyProgressLogData => 'Log body data';

  @override
  String get bodyProgressDay => 'Day';

  @override
  String get bodyProgressWeight => 'Weight';

  @override
  String get bodyProgressWaist => 'Waist';

  @override
  String get bodyProgressNotEnoughData =>
      'Not enough data for this metric yet.';

  @override
  String get historyLabel => 'History';

  @override
  String get logTodayLabel => 'Log today';

  @override
  String get minutesLabel => 'min';

  @override
  String get bodyProgressRecentCheckins => 'Recent check-ins';

  @override
  String get bodyProgressNoCheckins =>
      'No body check-ins yet. Start logging weight and waist to get a usable trend.';

  @override
  String get bodyProgressTrend => 'Trend';

  @override
  String get bodyProgressLatestWeight => 'Latest weight';

  @override
  String get bodyProgress7dAverage => '7d average';

  @override
  String get bodyProgressWeeklyDelta => 'Weekly delta';

  @override
  String get bodyProgressLatestWaist => 'Latest waist';

  @override
  String get bodyProgressAutoRead => 'Auto read';

  @override
  String get bodyProgressTrendWeightNeedData =>
      'Weight trend needs another full week of check-ins.';

  @override
  String get bodyProgressTrendWeightSteady =>
      'Weight is holding steady week over week.';

  @override
  String get bodyProgressTrendWeightDown =>
      'Weight is trending down versus the previous 7-day average.';

  @override
  String get bodyProgressTrendWeightUp =>
      'Weight is trending up versus the previous 7-day average.';

  @override
  String get bodyProgressTrendWaistNeedData =>
      'Waist trend needs at least two waist check-ins.';

  @override
  String get bodyProgressTrendWaistSteady =>
      'Waist is stable across the latest check-ins.';

  @override
  String get bodyProgressTrendWaistDown =>
      'Waist is tightening versus the previous waist check-in.';

  @override
  String get bodyProgressTrendWaistUp =>
      'Waist is up versus the previous waist check-in.';

  @override
  String get bodyProgressTrendNoTrend => 'No trend';

  @override
  String get bodyProgressTrendOnTrack => 'On track';

  @override
  String get bodyProgressTrendOffTrack => 'Off track';

  @override
  String get bodyProgressTrendMixed => 'Mixed';

  @override
  String get bodyProgressTrendChart => 'Trend chart';

  @override
  String get bodyProgressTrendChartWeightSubtitle =>
      'Weight trend with 7d rolling average';

  @override
  String get bodyProgressTrendChartWaistSubtitle => 'Waist trend by check-in';

  @override
  String get bodyProgressAddCheckinsUnlockChart =>
      'Add a few body check-ins to unlock the trend chart.';

  @override
  String get bodyProgressNoCheckinsYet => 'No check-ins yet.';

  @override
  String bodyProgressLatestCheckin(Object date) {
    return 'Latest check-in $date';
  }

  @override
  String get bodyProgressOpenHistoryTooltip => 'Open history';

  @override
  String get bodyProgressDelta => 'Delta';
}
