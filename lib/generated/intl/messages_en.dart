// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) => "${count} active";

  static String m1(mealType) =>
      "Import a meal image, review the editable draft, and save it to ${mealType}.";

  static String m2(item) => "Edit ${item}";

  static String m3(count) => "${count} ingredients";

  static String m4(unit) => "Quantity (${unit})";

  static String m5(source) => "Replaced by ${source} to improve accuracy.";

  static String m6(count) => "${count} servings ready to save";

  static String m7(title) => "Applied suggestion: ${title}";

  static String m8(label) => "Use habitual: ${label}";

  static String m9(versionNumber) => "Version ${versionNumber}";

  static String m10(date) => "Latest check-in ${date}";

  static String m11(pctCarbs, pctFats, pctProteins) =>
      "${pctCarbs}% carbs, ${pctFats}% fats, ${pctProteins}% proteins";

  static String m12(count) => "${count} activities";

  static String m13(percent) => "${percent}% adherence";

  static String m14(count) => "${count}/7 days";

  static String m15(count) => "${count} items";

  static String m16(amount) => "${amount} g remaining";

  static String m17(amount) => "+${amount} kcal";

  static String m18(amount) => "${amount} kcal remaining";

  static String m19(carbsTracked, carbsGoal, fatTracked, fatGoal,
          proteinTracked, proteinGoal) =>
      "Carbs ${carbsTracked}/${carbsGoal} g, fat ${fatTracked}/${fatGoal} g, protein ${proteinTracked}/${proteinGoal} g";

  static String m20(count) => "${count} meals";

  static String m21(amount) => "${amount}g avg protein";

  static String m22(recipe, slot) => "${recipe} added to ${slot}";

  static String m23(count) => "${count} portions";

  static String m24(amount) =>
      "You have ${amount}g of protein left. Prioritize a high protein meal.";

  static String m25(riskValue) => "Risk of comorbidities: ${riskValue}";

  static String m26(phase) => "Current phase: ${phase}";

  static String m27(name) => "${name} added";

  static String m28(count) => "${count} ingredients";

  static String m29(count) => "${count} servings";

  static String m30(count) => "Photo calls: ${count}";

  static String m31(count) => "Text calls: ${count}";

  static String m32(count) => "Total calls: ${count}";

  static String m33(cost) => "This month: ${cost}";

  static String m34(cost) => "Today: ${cost}";

  static String m35(cost) => "Total estimated: ${cost}";

  static String m36(kcal) => "Daily adjustment updated to ${kcal} kcal.";

  static String m37(delta) => "Apply ${delta} kcal/day";

  static String m38(kcal) => "Current adjustment: ${kcal} kcal.";

  static String m39(percent) => "${percent}% of registered days";

  static String m40(count) => "${count} days registered this week";

  static String m41(delta) => "Weight trend: ${delta} kg/week";

  static String m42(age) => "${age} years";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "activityExample": MessageLookupByLibrary.simpleMessage(
            "e.g. running, biking, yoga ..."),
        "activityLabel": MessageLookupByLibrary.simpleMessage("Activity"),
        "addItemLabel": MessageLookupByLibrary.simpleMessage("Add new Item:"),
        "addLabel": MessageLookupByLibrary.simpleMessage("Add"),
        "addMealBarcode": MessageLookupByLibrary.simpleMessage("Barcode"),
        "addMealPhoto": MessageLookupByLibrary.simpleMessage("Photo"),
        "addMealSaved": MessageLookupByLibrary.simpleMessage("Saved"),
        "addMealText": MessageLookupByLibrary.simpleMessage("Text"),
        "additionalInfoLabelCompendium2011": MessageLookupByLibrary.simpleMessage(
            "Information provided\n by the \n\'2011 Compendium\n of Physical Activities\'"),
        "additionalInfoLabelCustom":
            MessageLookupByLibrary.simpleMessage("Custom Meal Item"),
        "additionalInfoLabelFDC": MessageLookupByLibrary.simpleMessage(
            "More Information at\nFoodData Central"),
        "additionalInfoLabelOFF": MessageLookupByLibrary.simpleMessage(
            "More Information at\nOpenFoodFacts"),
        "additionalInfoLabelUnknown":
            MessageLookupByLibrary.simpleMessage("Unknown Meal Item"),
        "ageLabel": MessageLookupByLibrary.simpleMessage("Age"),
        "aiActiveItemsCount": m0,
        "aiAddIngredient":
            MessageLookupByLibrary.simpleMessage("Add ingredient"),
        "aiAmountLabel": MessageLookupByLibrary.simpleMessage("Amount"),
        "aiButtonCapture":
            MessageLookupByLibrary.simpleMessage("Take photo and review"),
        "aiButtonPickGallery":
            MessageLookupByLibrary.simpleMessage("Pick from gallery"),
        "aiButtonUse": MessageLookupByLibrary.simpleMessage("Use"),
        "aiButtonUseText": MessageLookupByLibrary.simpleMessage("Use text"),
        "aiCaptureByPhotoSubtitle": m1,
        "aiCaptureByPhotoTitle":
            MessageLookupByLibrary.simpleMessage("Capture by photo"),
        "aiConfidenceHigh":
            MessageLookupByLibrary.simpleMessage("High confidence"),
        "aiConfidenceLow":
            MessageLookupByLibrary.simpleMessage("Low confidence"),
        "aiConfidenceLowGenericHint": MessageLookupByLibrary.simpleMessage(
            "This ingredient has low certainty. Check amount or replace it with a more precise food."),
        "aiConfidenceLowHint": MessageLookupByLibrary.simpleMessage(
            "This ingredient has low certainty. Your habitual correction is usually the fastest option."),
        "aiConfidenceMedium":
            MessageLookupByLibrary.simpleMessage("Medium confidence"),
        "aiConfidenceMediumHint": MessageLookupByLibrary.simpleMessage(
            "The amount may vary. Check the portion if you see it doesn\'t fit the photo."),
        "aiCropLabel": MessageLookupByLibrary.simpleMessage("Crop"),
        "aiCustomServingsHelper": MessageLookupByLibrary.simpleMessage(
            "Adjust the final portion before saving."),
        "aiCustomServingsLabel":
            MessageLookupByLibrary.simpleMessage("Custom servings"),
        "aiDetectedIngredients":
            MessageLookupByLibrary.simpleMessage("Detected ingredients"),
        "aiDraftNotFound":
            MessageLookupByLibrary.simpleMessage("Draft not found or expired."),
        "aiEditAmountTitle": m2,
        "aiEditableLabel": MessageLookupByLibrary.simpleMessage("Editable"),
        "aiErrorGeneric": MessageLookupByLibrary.simpleMessage(
            "Remote image interpretation failed. Local draft created with memory support."),
        "aiErrorMissingKey": MessageLookupByLibrary.simpleMessage(
            "Remote AI is not configured in backend. Local draft created."),
        "aiErrorPayloadTooLarge": MessageLookupByLibrary.simpleMessage(
            "Image is too large for remote AI. Local draft created."),
        "aiErrorQuotaExceeded": MessageLookupByLibrary.simpleMessage(
            "Remote AI quota/rate limit reached. Local draft created."),
        "aiErrorUnsupportedFormat": MessageLookupByLibrary.simpleMessage(
            "Image format not supported by remote AI. Try JPG/PNG. Local draft created."),
        "aiExcludeFromMeal": MessageLookupByLibrary.simpleMessage(
            "Excluded from the final meal."),
        "aiFavoriteQuickAccess":
            MessageLookupByLibrary.simpleMessage("Favorite for quick access"),
        "aiFitLabel": MessageLookupByLibrary.simpleMessage("Fit"),
        "aiGymLabelBalanced": MessageLookupByLibrary.simpleMessage("Balanced"),
        "aiGymLabelHighProtein":
            MessageLookupByLibrary.simpleMessage("High protein"),
        "aiGymLabelLeanDefinition":
            MessageLookupByLibrary.simpleMessage("Lean for definition"),
        "aiGymLabelPostWorkout":
            MessageLookupByLibrary.simpleMessage("Post-workout"),
        "aiGymLabelPreWorkout":
            MessageLookupByLibrary.simpleMessage("Pre-workout"),
        "aiHintCheckSaucesSubtitle": MessageLookupByLibrary.simpleMessage(
            "The draft is just the first step. Correct hidden calories."),
        "aiHintCheckSaucesTitle":
            MessageLookupByLibrary.simpleMessage("Check sauces and oils"),
        "aiHintGymMealsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Useful for bowls, shakes, post-workouts, and repeated meals."),
        "aiHintGymMealsTitle":
            MessageLookupByLibrary.simpleMessage("Designed for gym meals"),
        "aiHintRecommendations":
            MessageLookupByLibrary.simpleMessage("Recommendations"),
        "aiHintShowFullPlateSubtitle": MessageLookupByLibrary.simpleMessage(
            "Better framing, better ingredient detection."),
        "aiHintShowFullPlateTitle":
            MessageLookupByLibrary.simpleMessage("Show full plate"),
        "aiIngredientsCount": m3,
        "aiMatchGood": MessageLookupByLibrary.simpleMessage("Good match"),
        "aiMatchHigh": MessageLookupByLibrary.simpleMessage("High match"),
        "aiMatchPossible":
            MessageLookupByLibrary.simpleMessage("Possible match"),
        "aiMatchesHint": MessageLookupByLibrary.simpleMessage(
            "Use a frequent meal, recipe, or previous correction if it looks more like what you ate."),
        "aiMealPhotoTitle":
            MessageLookupByLibrary.simpleMessage("AI Meal Photo"),
        "aiMealSaveError":
            MessageLookupByLibrary.simpleMessage("Could not save this meal"),
        "aiMealSavedSuccess":
            MessageLookupByLibrary.simpleMessage("Meal saved"),
        "aiPhotoCaptured":
            MessageLookupByLibrary.simpleMessage("Captured photo"),
        "aiPhotoCapturedHint": MessageLookupByLibrary.simpleMessage(
            "Tap to enlarge. Toggle crop/fit for quick inspection."),
        "aiPhotoPreviewError":
            MessageLookupByLibrary.simpleMessage("Could not load preview"),
        "aiPhotoZoomTitle": MessageLookupByLibrary.simpleMessage("Photo zoom"),
        "aiQuantityUnitLabel": m4,
        "aiQuickAdjustment":
            MessageLookupByLibrary.simpleMessage("Quick adjustment"),
        "aiRecipeNameHelper": MessageLookupByLibrary.simpleMessage(
            "Use names like pre-workout oats, post-workout chicken rice, or shake."),
        "aiRecipeNameLabel":
            MessageLookupByLibrary.simpleMessage("Recipe name"),
        "aiRemoveLabel": MessageLookupByLibrary.simpleMessage("Remove"),
        "aiReplaceEmpty": MessageLookupByLibrary.simpleMessage(
            "Search for a food to replace this ingredient."),
        "aiReplaceError": MessageLookupByLibrary.simpleMessage(
            "Cannot search for food right now."),
        "aiReplaceHint":
            MessageLookupByLibrary.simpleMessage("Search for food"),
        "aiReplaceMinLength": MessageLookupByLibrary.simpleMessage(
            "Enter at least 2 characters."),
        "aiReplaceNoResults":
            MessageLookupByLibrary.simpleMessage("No results found."),
        "aiReplaceTitle":
            MessageLookupByLibrary.simpleMessage("Replace ingredient"),
        "aiReplacedBySummary": m5,
        "aiRestoreLabel": MessageLookupByLibrary.simpleMessage("Restore"),
        "aiRetry": MessageLookupByLibrary.simpleMessage("Retry"),
        "aiReviewDraftTitle":
            MessageLookupByLibrary.simpleMessage("Review AI Draft"),
        "aiSaveAsRecipe":
            MessageLookupByLibrary.simpleMessage("Save as recipe"),
        "aiSaveDraftChangesError": MessageLookupByLibrary.simpleMessage(
            "Could not save draft changes"),
        "aiSaveMeal": MessageLookupByLibrary.simpleMessage("Save meal"),
        "aiSavingMeal": MessageLookupByLibrary.simpleMessage("Saving meal..."),
        "aiServingsReady": m6,
        "aiServingsToSave":
            MessageLookupByLibrary.simpleMessage("Servings to save"),
        "aiSourcePhoto": MessageLookupByLibrary.simpleMessage("AI Photo"),
        "aiSourceText": MessageLookupByLibrary.simpleMessage("AI Text"),
        "aiStatusConsulting":
            MessageLookupByLibrary.simpleMessage("Consulting AI..."),
        "aiStatusPersonalizing":
            MessageLookupByLibrary.simpleMessage("Personalizing..."),
        "aiStatusPreparing":
            MessageLookupByLibrary.simpleMessage("Preparing image..."),
        "aiStepPickImage": MessageLookupByLibrary.simpleMessage("Pick image"),
        "aiStepReviewItems":
            MessageLookupByLibrary.simpleMessage("Review items"),
        "aiStepSaveMeal": MessageLookupByLibrary.simpleMessage("Save meal"),
        "aiSubstituteLabel": MessageLookupByLibrary.simpleMessage("Substitute"),
        "aiSuggestionApplied": m7,
        "aiTextCaptureButton":
            MessageLookupByLibrary.simpleMessage("Interpret meal"),
        "aiTextCaptureDescription": MessageLookupByLibrary.simpleMessage(
            "Describe the meal naturally. The text can be processed remotely to estimate ingredients and macros, and you will always review the draft before saving."),
        "aiTextCaptureError": MessageLookupByLibrary.simpleMessage(
            "Remote interpretation not available. Local draft created with memory support."),
        "aiTextCaptureHint": MessageLookupByLibrary.simpleMessage(
            "Example: 2 eggs, toast with butter and coffee with milk"),
        "aiTextCaptureLoading":
            MessageLookupByLibrary.simpleMessage("Interpreting..."),
        "aiTextCaptureTitle":
            MessageLookupByLibrary.simpleMessage("Meal by text"),
        "aiUseHabitual": m8,
        "aiYourMatches": MessageLookupByLibrary.simpleMessage("Your matches"),
        "allItemsLabel": MessageLookupByLibrary.simpleMessage("All"),
        "alphaVersionName": MessageLookupByLibrary.simpleMessage("[Alpha]"),
        "appDescription": MessageLookupByLibrary.simpleMessage(
            "MacroTracker is a free and open-source calorie and nutrient tracker that respects your privacy."),
        "appLicenseLabel":
            MessageLookupByLibrary.simpleMessage("GPL-3.0 license"),
        "appTitle": MessageLookupByLibrary.simpleMessage("MacroTracker"),
        "appVersionName": m9,
        "baseQuantityLabel":
            MessageLookupByLibrary.simpleMessage("Base quantity (g/ml)"),
        "betaVersionName": MessageLookupByLibrary.simpleMessage("[Beta]"),
        "bmiInfo": MessageLookupByLibrary.simpleMessage(
            "Body Mass Index (BMI) is a index to classify overweight and obesity in adults. It is defined as weight in kilograms divided by the square of height in meters (kg/m²).\n\nBMI does not differentiate between fat and muscle mass and can be misleading for some individuals."),
        "bmiLabel": MessageLookupByLibrary.simpleMessage("BMI"),
        "bodyProgress7dAverage":
            MessageLookupByLibrary.simpleMessage("7d average"),
        "bodyProgressAddCheckinsUnlockChart":
            MessageLookupByLibrary.simpleMessage(
                "Add a few body check-ins to unlock the trend chart."),
        "bodyProgressAutoRead":
            MessageLookupByLibrary.simpleMessage("Auto read"),
        "bodyProgressDay": MessageLookupByLibrary.simpleMessage("Day"),
        "bodyProgressDelta": MessageLookupByLibrary.simpleMessage("Delta"),
        "bodyProgressLatestCheckin": m10,
        "bodyProgressLatestWaist":
            MessageLookupByLibrary.simpleMessage("Latest waist"),
        "bodyProgressLatestWeight":
            MessageLookupByLibrary.simpleMessage("Latest weight"),
        "bodyProgressLoadError": MessageLookupByLibrary.simpleMessage(
            "Body progress could not be loaded."),
        "bodyProgressLogData":
            MessageLookupByLibrary.simpleMessage("Log body data"),
        "bodyProgressNoCheckins": MessageLookupByLibrary.simpleMessage(
            "No body check-ins yet. Start logging weight and waist to get a usable trend."),
        "bodyProgressNoCheckinsYet":
            MessageLookupByLibrary.simpleMessage("No check-ins yet."),
        "bodyProgressNotEnoughData": MessageLookupByLibrary.simpleMessage(
            "Not enough data for this metric yet."),
        "bodyProgressOpenHistoryTooltip":
            MessageLookupByLibrary.simpleMessage("Open history"),
        "bodyProgressRecentCheckins":
            MessageLookupByLibrary.simpleMessage("Recent check-ins"),
        "bodyProgressTitle":
            MessageLookupByLibrary.simpleMessage("Body progress"),
        "bodyProgressTrend": MessageLookupByLibrary.simpleMessage("Trend"),
        "bodyProgressTrendChart":
            MessageLookupByLibrary.simpleMessage("Trend chart"),
        "bodyProgressTrendChartWaistSubtitle":
            MessageLookupByLibrary.simpleMessage("Waist trend by check-in"),
        "bodyProgressTrendChartWeightSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Weight trend with 7d rolling average"),
        "bodyProgressTrendMixed": MessageLookupByLibrary.simpleMessage("Mixed"),
        "bodyProgressTrendNoTrend":
            MessageLookupByLibrary.simpleMessage("No trend"),
        "bodyProgressTrendOffTrack":
            MessageLookupByLibrary.simpleMessage("Off track"),
        "bodyProgressTrendOnTrack":
            MessageLookupByLibrary.simpleMessage("On track"),
        "bodyProgressTrendWaistDown": MessageLookupByLibrary.simpleMessage(
            "Waist is tightening versus the previous waist check-in."),
        "bodyProgressTrendWaistNeedData": MessageLookupByLibrary.simpleMessage(
            "Waist trend needs at least two waist check-ins."),
        "bodyProgressTrendWaistSteady": MessageLookupByLibrary.simpleMessage(
            "Waist is stable across the latest check-ins."),
        "bodyProgressTrendWaistUp": MessageLookupByLibrary.simpleMessage(
            "Waist is up versus the previous waist check-in."),
        "bodyProgressTrendWeightDown": MessageLookupByLibrary.simpleMessage(
            "Weight is trending down versus the previous 7-day average."),
        "bodyProgressTrendWeightNeedData": MessageLookupByLibrary.simpleMessage(
            "Weight trend needs another full week of check-ins."),
        "bodyProgressTrendWeightSteady": MessageLookupByLibrary.simpleMessage(
            "Weight is holding steady week over week."),
        "bodyProgressTrendWeightUp": MessageLookupByLibrary.simpleMessage(
            "Weight is trending up versus the previous 7-day average."),
        "bodyProgressWaist": MessageLookupByLibrary.simpleMessage("Waist"),
        "bodyProgressWeeklyDelta":
            MessageLookupByLibrary.simpleMessage("Weekly delta"),
        "bodyProgressWeight": MessageLookupByLibrary.simpleMessage("Weight"),
        "breakfastExample": MessageLookupByLibrary.simpleMessage(
            "e.g. cereal, milk, coffee ..."),
        "breakfastLabel": MessageLookupByLibrary.simpleMessage("Breakfast"),
        "burnedLabel": MessageLookupByLibrary.simpleMessage("burned"),
        "buttonNextLabel": MessageLookupByLibrary.simpleMessage("NEXT"),
        "buttonResetLabel": MessageLookupByLibrary.simpleMessage("Reset"),
        "buttonSaveLabel": MessageLookupByLibrary.simpleMessage("Save"),
        "buttonStartLabel": MessageLookupByLibrary.simpleMessage("START"),
        "buttonYesLabel": MessageLookupByLibrary.simpleMessage("YES"),
        "calculationsMacronutrientsDistributionLabel":
            MessageLookupByLibrary.simpleMessage("Macros distribution"),
        "calculationsMacrosDistribution": m11,
        "calculationsRecommendedLabel":
            MessageLookupByLibrary.simpleMessage("(recommended)"),
        "calculationsTDEEIOM2006Label": MessageLookupByLibrary.simpleMessage(
            "Institute of Medicine Equation"),
        "calculationsTDEELabel":
            MessageLookupByLibrary.simpleMessage("TDEE equation"),
        "carbohydrateLabel":
            MessageLookupByLibrary.simpleMessage("carbohydrate"),
        "carbsLabel": MessageLookupByLibrary.simpleMessage("carbs"),
        "chooseWeightGoalLabel":
            MessageLookupByLibrary.simpleMessage("Choose Weight Goal"),
        "cmLabel": MessageLookupByLibrary.simpleMessage("cm"),
        "copyDialogTitle": MessageLookupByLibrary.simpleMessage(
            "Which meal type do you want to copy to?"),
        "copyOrDeleteTimeDialogContent": MessageLookupByLibrary.simpleMessage(
            "With \"Copy to today\" you can copy the meal to today. With \"Delete\" you can delete the meal."),
        "copyOrDeleteTimeDialogTitle":
            MessageLookupByLibrary.simpleMessage("What do you want to do?"),
        "createCustomDialogContent": MessageLookupByLibrary.simpleMessage(
            "Do you want create a custom meal item?"),
        "createCustomDialogTitle":
            MessageLookupByLibrary.simpleMessage("Create custom meal item?"),
        "dailyKcalAdjustmentLabel":
            MessageLookupByLibrary.simpleMessage("Daily Kcal adjustment:"),
        "dataCollectionLabel": MessageLookupByLibrary.simpleMessage(
            "Support development by providing anonymous usage data"),
        "dayLabel": MessageLookupByLibrary.simpleMessage("day"),
        "deleteAllLabel": MessageLookupByLibrary.simpleMessage("Delete all"),
        "deleteTimeDialogContent": MessageLookupByLibrary.simpleMessage(
            "Do want to delete the selected item?"),
        "deleteTimeDialogPluralContent": MessageLookupByLibrary.simpleMessage(
            "Do want to delete all items of this meal?"),
        "deleteTimeDialogPluralTitle":
            MessageLookupByLibrary.simpleMessage("Delete Items?"),
        "deleteTimeDialogTitle":
            MessageLookupByLibrary.simpleMessage("Delete Item?"),
        "dialogCancelLabel": MessageLookupByLibrary.simpleMessage("CANCEL"),
        "dialogCopyLabel":
            MessageLookupByLibrary.simpleMessage("Copy to today"),
        "dialogDeleteLabel": MessageLookupByLibrary.simpleMessage("DELETE"),
        "dialogOKLabel": MessageLookupByLibrary.simpleMessage("OK"),
        "diaryActivitiesPill": m12,
        "diaryAdherencePill": m13,
        "diaryCopyDayToToday":
            MessageLookupByLibrary.simpleMessage("Copy day to today"),
        "diaryCurrentWeek":
            MessageLookupByLibrary.simpleMessage("Current week"),
        "diaryDayCopied":
            MessageLookupByLibrary.simpleMessage("Day copied to today"),
        "diaryDaysPill": m14,
        "diaryElementsSection": m15,
        "diaryEmptySection": MessageLookupByLibrary.simpleMessage("Empty"),
        "diaryGoalReached":
            MessageLookupByLibrary.simpleMessage("Goal reached"),
        "diaryGramsRemaining": m16,
        "diaryInGoal": MessageLookupByLibrary.simpleMessage("In goal"),
        "diaryKcalOver": m17,
        "diaryKcalRemaining": m18,
        "diaryLabel": MessageLookupByLibrary.simpleMessage("Diary"),
        "diaryMacrosSummary": m19,
        "diaryMealsPill": m20,
        "diaryNextDayTooltip": MessageLookupByLibrary.simpleMessage("Next day"),
        "diaryPreviousDayTooltip":
            MessageLookupByLibrary.simpleMessage("Previous day"),
        "diaryProteinPill": m21,
        "diarySelectedDayLabel":
            MessageLookupByLibrary.simpleMessage("Selected day"),
        "diaryStatusAbove": MessageLookupByLibrary.simpleMessage("Above"),
        "diaryStatusBelow": MessageLookupByLibrary.simpleMessage("Below"),
        "diaryStatusInRange": MessageLookupByLibrary.simpleMessage("In range"),
        "diarySummaryTitle":
            MessageLookupByLibrary.simpleMessage("Day summary"),
        "dinnerExample": MessageLookupByLibrary.simpleMessage(
            "e.g. soup, chicken, wine ..."),
        "dinnerLabel": MessageLookupByLibrary.simpleMessage("Dinner"),
        "disclaimerText": MessageLookupByLibrary.simpleMessage(
            "MacroTracker is not a medical application. All data provided is not validated and should be used with caution. Please maintain a healthy lifestyle and consult a professional if you have any problems. Use during illness, pregnancy or lactation is not recommended."),
        "editItemDialogTitle":
            MessageLookupByLibrary.simpleMessage("Edit item"),
        "editMealLabel": MessageLookupByLibrary.simpleMessage("Edit meal"),
        "energyLabel": MessageLookupByLibrary.simpleMessage("energy"),
        "errorFetchingProductData": MessageLookupByLibrary.simpleMessage(
            "Error while fetching product data"),
        "errorLoadingActivities": MessageLookupByLibrary.simpleMessage(
            "Error while loading activities"),
        "errorMealSave": MessageLookupByLibrary.simpleMessage(
            "Error while saving meal. Did you input the correct meal information?"),
        "errorOpeningBrowser": MessageLookupByLibrary.simpleMessage(
            "Error while opening browser app"),
        "errorOpeningEmail": MessageLookupByLibrary.simpleMessage(
            "Error while opening email app"),
        "errorProductNotFound":
            MessageLookupByLibrary.simpleMessage("Product not found"),
        "exportAction": MessageLookupByLibrary.simpleMessage("Export"),
        "exportImportDescription": MessageLookupByLibrary.simpleMessage(
            "You can export the app data to a zip file and import it later. This is useful if you want to backup your data or transfer it to another device.\n\nThe app does not use any cloud service to store your data."),
        "exportImportErrorLabel":
            MessageLookupByLibrary.simpleMessage("Export / Import error"),
        "exportImportLabel":
            MessageLookupByLibrary.simpleMessage("Export / Import data"),
        "exportImportSuccessLabel":
            MessageLookupByLibrary.simpleMessage("Export / Import successful"),
        "fatLabel": MessageLookupByLibrary.simpleMessage("fat"),
        "fiberLabel": MessageLookupByLibrary.simpleMessage("fiber"),
        "flOzUnit": MessageLookupByLibrary.simpleMessage("fl.oz"),
        "ftLabel": MessageLookupByLibrary.simpleMessage("ft"),
        "genderFemaleLabel": MessageLookupByLibrary.simpleMessage("♀ female"),
        "genderLabel": MessageLookupByLibrary.simpleMessage("Gender"),
        "genderMaleLabel": MessageLookupByLibrary.simpleMessage("♂ male"),
        "goalGainWeight": MessageLookupByLibrary.simpleMessage("Gain Weight"),
        "goalLabel": MessageLookupByLibrary.simpleMessage("Goal"),
        "goalLoseWeight": MessageLookupByLibrary.simpleMessage("Lose Weight"),
        "goalMaintainWeight":
            MessageLookupByLibrary.simpleMessage("Maintain Weight"),
        "gramMilliliterUnit": MessageLookupByLibrary.simpleMessage("g/ml"),
        "gramUnit": MessageLookupByLibrary.simpleMessage("g"),
        "habitSourceHealthConnect":
            MessageLookupByLibrary.simpleMessage("Health Connect"),
        "habitSourceManual": MessageLookupByLibrary.simpleMessage("Manual"),
        "healthConnectAutoSyncDisabledMessage":
            MessageLookupByLibrary.simpleMessage(
                "Health Connect auto-sync disabled."),
        "healthConnectAutoSyncEnabledMessage":
            MessageLookupByLibrary.simpleMessage(
                "Health Connect auto-sync enabled."),
        "healthConnectAutoSyncSubtitle": MessageLookupByLibrary.simpleMessage(
            "Sync sleep and steps automatically on app open."),
        "healthConnectAutoSyncTitle":
            MessageLookupByLibrary.simpleMessage("Health Connect auto-sync"),
        "healthConnectStatusActivityPermissionRequired":
            MessageLookupByLibrary.simpleMessage(
                "Activity Recognition permission is required for steps."),
        "healthConnectStatusAutoSyncDisabled":
            MessageLookupByLibrary.simpleMessage(
                "Connected. Auto-sync is currently disabled."),
        "healthConnectStatusChecking": MessageLookupByLibrary.simpleMessage(
            "Checking Health Connect status..."),
        "healthConnectStatusPermissionsRequired":
            MessageLookupByLibrary.simpleMessage(
                "Health permissions are required to read sleep and steps."),
        "healthConnectStatusReady": MessageLookupByLibrary.simpleMessage(
            "Connected. Sleep and steps can sync automatically."),
        "healthConnectStatusUnavailable": MessageLookupByLibrary.simpleMessage(
            "Health Connect is not available on this device."),
        "healthConnectSyncNoChanges": MessageLookupByLibrary.simpleMessage(
            "No new Health Connect data was imported."),
        "healthConnectSyncNowTitle":
            MessageLookupByLibrary.simpleMessage("Sync Health Connect now"),
        "healthConnectSyncSuccess":
            MessageLookupByLibrary.simpleMessage("Health Connect data synced."),
        "heightLabel": MessageLookupByLibrary.simpleMessage("Height"),
        "historyLabel": MessageLookupByLibrary.simpleMessage("History"),
        "homeLabel": MessageLookupByLibrary.simpleMessage("Home"),
        "homePerformanceSummary":
            MessageLookupByLibrary.simpleMessage("Performance Summary"),
        "homeWeeklyInsightsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Check averages, adherence, protein and top meals"),
        "hydrationAddWater": MessageLookupByLibrary.simpleMessage("Add water"),
        "hydrationGoalReached":
            MessageLookupByLibrary.simpleMessage("Goal reached!"),
        "hydrationRemoveWater":
            MessageLookupByLibrary.simpleMessage("Remove water"),
        "hydrationTitle": MessageLookupByLibrary.simpleMessage("Hydration"),
        "importAction": MessageLookupByLibrary.simpleMessage("Import"),
        "infoAddedActivityLabel":
            MessageLookupByLibrary.simpleMessage("Added new activity"),
        "infoAddedIntakeLabel":
            MessageLookupByLibrary.simpleMessage("Added new intake"),
        "itemDeletedSnackbar":
            MessageLookupByLibrary.simpleMessage("Item deleted"),
        "itemUpdatedSnackbar":
            MessageLookupByLibrary.simpleMessage("Item updated"),
        "kcalLabel": MessageLookupByLibrary.simpleMessage("kcal"),
        "kcalLeftLabel": MessageLookupByLibrary.simpleMessage("kcal left"),
        "kgLabel": MessageLookupByLibrary.simpleMessage("kg"),
        "lbsLabel": MessageLookupByLibrary.simpleMessage("lbs"),
        "logTodayLabel": MessageLookupByLibrary.simpleMessage("Log today"),
        "lunchExample":
            MessageLookupByLibrary.simpleMessage("e.g. pizza, salad, rice ..."),
        "lunchLabel": MessageLookupByLibrary.simpleMessage("Lunch"),
        "macroDistributionLabel":
            MessageLookupByLibrary.simpleMessage("Macronutrient Distribution:"),
        "macroSuggestionsAddedTo": m22,
        "macroSuggestionsEmpty": MessageLookupByLibrary.simpleMessage(
            "Save some recipes and this section will start suggesting based on your training day."),
        "macroSuggestionsServingsPortions": m23,
        "macroSuggestionsSubtitleDefault": MessageLookupByLibrary.simpleMessage(
            "Saved meals based on what you are still missing today."),
        "macroSuggestionsSubtitleGym": MessageLookupByLibrary.simpleMessage(
            "Recommended meals to perform and recover better."),
        "macroSuggestionsSubtitleLoseWeight":
            MessageLookupByLibrary.simpleMessage(
                "High protein options with controlled calories."),
        "macroSuggestionsSubtitleRest": MessageLookupByLibrary.simpleMessage(
            "Clean closings with high protein and no caloric excess."),
        "macroSuggestionsTitleCardio":
            MessageLookupByLibrary.simpleMessage("Options for cardio"),
        "macroSuggestionsTitleDef":
            MessageLookupByLibrary.simpleMessage("Options for definition"),
        "macroSuggestionsTitleLeg":
            MessageLookupByLibrary.simpleMessage("Options for legs"),
        "macroSuggestionsTitleRest":
            MessageLookupByLibrary.simpleMessage("Options for rest"),
        "macroSuggestionsTitleTorso":
            MessageLookupByLibrary.simpleMessage("Options for torso"),
        "mealBrandsLabel": MessageLookupByLibrary.simpleMessage("Brands"),
        "mealCarbsLabel": MessageLookupByLibrary.simpleMessage("carbs per"),
        "mealFatLabel": MessageLookupByLibrary.simpleMessage("fat per"),
        "mealKcalLabel": MessageLookupByLibrary.simpleMessage("kcal per"),
        "mealNameLabel": MessageLookupByLibrary.simpleMessage("Meal name"),
        "mealProteinLabel":
            MessageLookupByLibrary.simpleMessage("protein per 100 g/ml"),
        "mealSizeLabel":
            MessageLookupByLibrary.simpleMessage("Meal size (g/ml)"),
        "mealSizeLabelImperial":
            MessageLookupByLibrary.simpleMessage("Meal size (oz/fl oz)"),
        "mealUnitLabel": MessageLookupByLibrary.simpleMessage("Meal unit"),
        "milliliterUnit": MessageLookupByLibrary.simpleMessage("ml"),
        "minutesLabel": MessageLookupByLibrary.simpleMessage("min"),
        "missingProductInfo": MessageLookupByLibrary.simpleMessage(
            "Product missing required kcal or macronutrients information"),
        "noActivityRecentlyAddedLabel":
            MessageLookupByLibrary.simpleMessage("No activity recently added"),
        "noMealsRecentlyAddedLabel":
            MessageLookupByLibrary.simpleMessage("No meals recently added"),
        "noResultsFound":
            MessageLookupByLibrary.simpleMessage("No results found"),
        "notAvailableLabel": MessageLookupByLibrary.simpleMessage("N/A"),
        "nothingAddedLabel":
            MessageLookupByLibrary.simpleMessage("Nothing added"),
        "nudgeDayClosing": MessageLookupByLibrary.simpleMessage(
            "Closing the day: you lack energy for goal. Add a clean closing meal."),
        "nudgeKeepAdherence": MessageLookupByLibrary.simpleMessage(
            "Only useful alerts to maintain adherence."),
        "nudgeLowHydration": MessageLookupByLibrary.simpleMessage(
            "Low hydration today. Drink water to close at 100%."),
        "nudgeNoPendingActions":
            MessageLookupByLibrary.simpleMessage("No pending actions for now."),
        "nudgeNoReminders": MessageLookupByLibrary.simpleMessage(
            "No pending reminders. Doing great today."),
        "nudgeProteinLeft": m24,
        "nudgeSmartReminders":
            MessageLookupByLibrary.simpleMessage("Smart reminders"),
        "nutritionInfoLabel":
            MessageLookupByLibrary.simpleMessage("Nutrition Information"),
        "nutritionalStatusNormalWeight":
            MessageLookupByLibrary.simpleMessage("Normal Weight"),
        "nutritionalStatusObeseClassI":
            MessageLookupByLibrary.simpleMessage("Obesity Class I"),
        "nutritionalStatusObeseClassII":
            MessageLookupByLibrary.simpleMessage("Obesity Class II"),
        "nutritionalStatusObeseClassIII":
            MessageLookupByLibrary.simpleMessage("Obesity Class III"),
        "nutritionalStatusPreObesity":
            MessageLookupByLibrary.simpleMessage("Pre-obesity"),
        "nutritionalStatusRiskAverage":
            MessageLookupByLibrary.simpleMessage("Average"),
        "nutritionalStatusRiskIncreased":
            MessageLookupByLibrary.simpleMessage("Increased"),
        "nutritionalStatusRiskLabel": m25,
        "nutritionalStatusRiskLow": MessageLookupByLibrary.simpleMessage(
            "Low \n(but risk of other \nclinical problems increased)"),
        "nutritionalStatusRiskModerate":
            MessageLookupByLibrary.simpleMessage("Moderate"),
        "nutritionalStatusRiskSevere":
            MessageLookupByLibrary.simpleMessage("Severe"),
        "nutritionalStatusRiskVerySevere":
            MessageLookupByLibrary.simpleMessage("Very severe"),
        "nutritionalStatusUnderweight":
            MessageLookupByLibrary.simpleMessage("Underweight"),
        "offDisclaimer": MessageLookupByLibrary.simpleMessage(
            "The data provided to you by this app are retrieved from the Open Food Facts database. No guarantees can be made for the accuracy, completeness, or reliability of the information provided. The data are provided “as is” and the originating source for the data (Open Food Facts) is not liable for any damages arising out of the use of the data."),
        "onboardingActivityQuestionSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "How active are you? (without workouts)"),
        "onboardingBirthdayHint":
            MessageLookupByLibrary.simpleMessage("Enter Date"),
        "onboardingBirthdayQuestionSubtitle":
            MessageLookupByLibrary.simpleMessage("When is your birthday?"),
        "onboardingEnterBirthdayLabel":
            MessageLookupByLibrary.simpleMessage("Birthday"),
        "onboardingGenderQuestionSubtitle":
            MessageLookupByLibrary.simpleMessage("What\'s your gender?"),
        "onboardingGoalQuestionSubtitle": MessageLookupByLibrary.simpleMessage(
            "What\'s your current weight goal?"),
        "onboardingHeightExampleHintCm":
            MessageLookupByLibrary.simpleMessage("e.g. 170"),
        "onboardingHeightExampleHintFt":
            MessageLookupByLibrary.simpleMessage("e.g. 5.8"),
        "onboardingHeightQuestionSubtitle":
            MessageLookupByLibrary.simpleMessage("Whats your current height?"),
        "onboardingIntroDescription": MessageLookupByLibrary.simpleMessage(
            "To start, the app needs some information about you to calculate your daily calorie goal.\nAll information about you is stored securely on your device."),
        "onboardingKcalPerDayLabel":
            MessageLookupByLibrary.simpleMessage("kcal per day"),
        "onboardingOverviewLabel":
            MessageLookupByLibrary.simpleMessage("Overview"),
        "onboardingSaveUserError": MessageLookupByLibrary.simpleMessage(
            "Wrong input, please try again"),
        "onboardingWeightExampleHintKg":
            MessageLookupByLibrary.simpleMessage("e.g. 60"),
        "onboardingWeightExampleHintLbs":
            MessageLookupByLibrary.simpleMessage("e.g. 132"),
        "onboardingWeightQuestionSubtitle":
            MessageLookupByLibrary.simpleMessage("Whats your current weight?"),
        "onboardingWelcomeLabel":
            MessageLookupByLibrary.simpleMessage("Welcome to"),
        "onboardingWrongHeightLabel":
            MessageLookupByLibrary.simpleMessage("Enter correct height"),
        "onboardingWrongWeightLabel":
            MessageLookupByLibrary.simpleMessage("Enter correct weight"),
        "onboardingYourGoalLabel":
            MessageLookupByLibrary.simpleMessage("Your calorie goal:"),
        "onboardingYourMacrosGoalLabel":
            MessageLookupByLibrary.simpleMessage("Your macronutrient goals:"),
        "ozUnit": MessageLookupByLibrary.simpleMessage("oz"),
        "paAmericanFootballGeneral":
            MessageLookupByLibrary.simpleMessage("football"),
        "paAmericanFootballGeneralDesc":
            MessageLookupByLibrary.simpleMessage("touch, flag, general"),
        "paArcheryGeneral": MessageLookupByLibrary.simpleMessage("archery"),
        "paArcheryGeneralDesc":
            MessageLookupByLibrary.simpleMessage("non-hunting"),
        "paAutoRacing": MessageLookupByLibrary.simpleMessage("auto racing"),
        "paAutoRacingDesc": MessageLookupByLibrary.simpleMessage("open wheel"),
        "paBackpackingGeneral":
            MessageLookupByLibrary.simpleMessage("backpacking"),
        "paBackpackingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paBadmintonGeneral": MessageLookupByLibrary.simpleMessage("badminton"),
        "paBadmintonGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "social singles and doubles, general"),
        "paBasketballGeneral":
            MessageLookupByLibrary.simpleMessage("basketball"),
        "paBasketballGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paBicyclingGeneral": MessageLookupByLibrary.simpleMessage("bicycling"),
        "paBicyclingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paBicyclingMountainGeneral":
            MessageLookupByLibrary.simpleMessage("bicycling, mountain"),
        "paBicyclingMountainGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paBicyclingStationaryGeneral":
            MessageLookupByLibrary.simpleMessage("bicycling, stationary"),
        "paBicyclingStationaryGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paBilliardsGeneral": MessageLookupByLibrary.simpleMessage("billiards"),
        "paBilliardsGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paBowlingGeneral": MessageLookupByLibrary.simpleMessage("bowling"),
        "paBowlingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paBoxingBag": MessageLookupByLibrary.simpleMessage("boxing"),
        "paBoxingBagDesc": MessageLookupByLibrary.simpleMessage("punching bag"),
        "paBoxingGeneral": MessageLookupByLibrary.simpleMessage("boxing"),
        "paBoxingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("in ring, general"),
        "paBroomball": MessageLookupByLibrary.simpleMessage("broomball"),
        "paBroomballDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paCalisthenicsGeneral":
            MessageLookupByLibrary.simpleMessage("calisthenics"),
        "paCalisthenicsGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "light or moderate effort, general (e.g., back exercises)"),
        "paCanoeingGeneral": MessageLookupByLibrary.simpleMessage("canoeing"),
        "paCanoeingGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "rowing, for pleasure, general"),
        "paCatch": MessageLookupByLibrary.simpleMessage("football or baseball"),
        "paCatchDesc": MessageLookupByLibrary.simpleMessage("playing catch"),
        "paCheerleading": MessageLookupByLibrary.simpleMessage("cheerleading"),
        "paCheerleadingDesc": MessageLookupByLibrary.simpleMessage(
            "gymnastic moves, competitive"),
        "paChildrenGame":
            MessageLookupByLibrary.simpleMessage("children’s games"),
        "paChildrenGameDesc": MessageLookupByLibrary.simpleMessage(
            "(e.g., hopscotch, 4-square, dodgeball, playground apparatus, t-ball, tetherball, marbles, arcade games), moderate effort"),
        "paClimbingHillsNoLoadGeneral":
            MessageLookupByLibrary.simpleMessage("climbing hills, no load"),
        "paClimbingHillsNoLoadGeneralDesc":
            MessageLookupByLibrary.simpleMessage("no load"),
        "paCricket": MessageLookupByLibrary.simpleMessage("cricket"),
        "paCricketDesc":
            MessageLookupByLibrary.simpleMessage("batting, bowling, fielding"),
        "paCroquet": MessageLookupByLibrary.simpleMessage("croquet"),
        "paCroquetDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paCurling": MessageLookupByLibrary.simpleMessage("curling"),
        "paCurlingDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paDancingAerobicGeneral":
            MessageLookupByLibrary.simpleMessage("aerobic"),
        "paDancingAerobicGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paDancingGeneral":
            MessageLookupByLibrary.simpleMessage("general dancing"),
        "paDancingGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "e.g. disco, folk, Irish step dancing, line dancing, polka, country"),
        "paDartsWall": MessageLookupByLibrary.simpleMessage("darts"),
        "paDartsWallDesc": MessageLookupByLibrary.simpleMessage("wall or lawn"),
        "paDivingGeneral": MessageLookupByLibrary.simpleMessage("diving"),
        "paDivingGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "skindiving, scuba diving, general"),
        "paDivingSpringboardPlatform":
            MessageLookupByLibrary.simpleMessage("diving"),
        "paDivingSpringboardPlatformDesc":
            MessageLookupByLibrary.simpleMessage("springboard or platform"),
        "paFencing": MessageLookupByLibrary.simpleMessage("fencing"),
        "paFencingDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paFrisbee": MessageLookupByLibrary.simpleMessage("frisbee playing"),
        "paFrisbeeDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paGolfGeneral": MessageLookupByLibrary.simpleMessage("golf"),
        "paGolfGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paGymnasticsGeneral":
            MessageLookupByLibrary.simpleMessage("gymnastics"),
        "paGymnasticsGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paHackySack": MessageLookupByLibrary.simpleMessage("hacky sack"),
        "paHackySackDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paHandballGeneral": MessageLookupByLibrary.simpleMessage("handball"),
        "paHandballGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paHangGliding": MessageLookupByLibrary.simpleMessage("hang gliding"),
        "paHangGlidingDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paHeadingBicycling": MessageLookupByLibrary.simpleMessage("bicycling"),
        "paHeadingConditionalExercise":
            MessageLookupByLibrary.simpleMessage("conditioning exercise"),
        "paHeadingDancing": MessageLookupByLibrary.simpleMessage("dancing"),
        "paHeadingRunning": MessageLookupByLibrary.simpleMessage("running"),
        "paHeadingSports": MessageLookupByLibrary.simpleMessage("sports"),
        "paHeadingWalking": MessageLookupByLibrary.simpleMessage("walking"),
        "paHeadingWaterActivities":
            MessageLookupByLibrary.simpleMessage("water activities"),
        "paHeadingWinterActivities":
            MessageLookupByLibrary.simpleMessage("winter activities"),
        "paHikingCrossCountry": MessageLookupByLibrary.simpleMessage("hiking"),
        "paHikingCrossCountryDesc":
            MessageLookupByLibrary.simpleMessage("cross country"),
        "paHockeyField": MessageLookupByLibrary.simpleMessage("hockey, field"),
        "paHockeyFieldDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paHorseRidingGeneral":
            MessageLookupByLibrary.simpleMessage("horseback riding"),
        "paHorseRidingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paIceHockeyGeneral":
            MessageLookupByLibrary.simpleMessage("ice hockey"),
        "paIceHockeyGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paIceSkatingGeneral":
            MessageLookupByLibrary.simpleMessage("ice skating"),
        "paIceSkatingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paJaiAlai": MessageLookupByLibrary.simpleMessage("jai alai"),
        "paJaiAlaiDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paJoggingGeneral": MessageLookupByLibrary.simpleMessage("jogging"),
        "paJoggingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paJuggling": MessageLookupByLibrary.simpleMessage("juggling"),
        "paJugglingDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paKayakingModerate": MessageLookupByLibrary.simpleMessage("kayaking"),
        "paKayakingModerateDesc":
            MessageLookupByLibrary.simpleMessage("moderate effort"),
        "paKickball": MessageLookupByLibrary.simpleMessage("kickball"),
        "paKickballDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paLacrosse": MessageLookupByLibrary.simpleMessage("lacrosse"),
        "paLacrosseDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paLawnBowling": MessageLookupByLibrary.simpleMessage("lawn bowling"),
        "paLawnBowlingDesc":
            MessageLookupByLibrary.simpleMessage("bocce ball, outdoor"),
        "paMartialArtsModerate":
            MessageLookupByLibrary.simpleMessage("martial arts"),
        "paMartialArtsModerateDesc": MessageLookupByLibrary.simpleMessage(
            "different types, moderate pace (e.g., judo, jujitsu, karate, kick boxing, tae kwan do, tai-bo, Muay Thai boxing)"),
        "paMartialArtsSlower":
            MessageLookupByLibrary.simpleMessage("martial arts"),
        "paMartialArtsSlowerDesc": MessageLookupByLibrary.simpleMessage(
            "different types, slower pace, novice performers, practice"),
        "paMotoCross": MessageLookupByLibrary.simpleMessage("moto-cross"),
        "paMotoCrossDesc": MessageLookupByLibrary.simpleMessage(
            "off-road motor sports, all-terrain vehicle, general"),
        "paMountainClimbing": MessageLookupByLibrary.simpleMessage("climbing"),
        "paMountainClimbingDesc":
            MessageLookupByLibrary.simpleMessage("rock or mountain climbing"),
        "paOrienteering": MessageLookupByLibrary.simpleMessage("orienteering"),
        "paOrienteeringDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paPaddleBoarding":
            MessageLookupByLibrary.simpleMessage("paddle boarding"),
        "paPaddleBoardingDesc":
            MessageLookupByLibrary.simpleMessage("standing"),
        "paPaddleBoat": MessageLookupByLibrary.simpleMessage("paddle boat"),
        "paPaddleBoatDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paPaddleball": MessageLookupByLibrary.simpleMessage("paddleball"),
        "paPaddleballDesc":
            MessageLookupByLibrary.simpleMessage("casual, general"),
        "paPoloHorse": MessageLookupByLibrary.simpleMessage("polo"),
        "paPoloHorseDesc": MessageLookupByLibrary.simpleMessage("on horseback"),
        "paRacquetball": MessageLookupByLibrary.simpleMessage("racquetball"),
        "paRacquetballDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paResistanceTraining":
            MessageLookupByLibrary.simpleMessage("resistance training"),
        "paResistanceTrainingDesc": MessageLookupByLibrary.simpleMessage(
            "weight lifting, free weight, nautilus or universal"),
        "paRodeoSportGeneralModerate":
            MessageLookupByLibrary.simpleMessage("rodeo sports"),
        "paRodeoSportGeneralModerateDesc":
            MessageLookupByLibrary.simpleMessage("general, moderate effort"),
        "paRollerbladingLight":
            MessageLookupByLibrary.simpleMessage("rollerblading"),
        "paRollerbladingLightDesc":
            MessageLookupByLibrary.simpleMessage("in-line skating"),
        "paRopeJumpingGeneral":
            MessageLookupByLibrary.simpleMessage("rope jumping"),
        "paRopeJumpingGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "moderate pace, 100-120 skips/min, general, 2 foot skip, plain bounce"),
        "paRopeSkippingGeneral":
            MessageLookupByLibrary.simpleMessage("rope skipping"),
        "paRopeSkippingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paRugbyCompetitive": MessageLookupByLibrary.simpleMessage("rugby"),
        "paRugbyCompetitiveDesc":
            MessageLookupByLibrary.simpleMessage("union, team, competitive"),
        "paRugbyNonCompetitive": MessageLookupByLibrary.simpleMessage("rugby"),
        "paRugbyNonCompetitiveDesc":
            MessageLookupByLibrary.simpleMessage("touch, non-competitive"),
        "paRunningGeneral": MessageLookupByLibrary.simpleMessage("running"),
        "paRunningGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paSailingGeneral": MessageLookupByLibrary.simpleMessage("sailing"),
        "paSailingGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "boat and board sailing, windsurfing, ice sailing, general"),
        "paShuffleboard": MessageLookupByLibrary.simpleMessage("shuffleboard"),
        "paShuffleboardDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paSkateboardingGeneral":
            MessageLookupByLibrary.simpleMessage("skateboarding"),
        "paSkateboardingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general, moderate effort"),
        "paSkatingRoller":
            MessageLookupByLibrary.simpleMessage("roller skating"),
        "paSkatingRollerDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paSkiingGeneral": MessageLookupByLibrary.simpleMessage("skiing"),
        "paSkiingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paSkiingWaterWakeboarding":
            MessageLookupByLibrary.simpleMessage("water skiing"),
        "paSkiingWaterWakeboardingDesc":
            MessageLookupByLibrary.simpleMessage("water or wakeboarding"),
        "paSkydiving": MessageLookupByLibrary.simpleMessage("skydiving"),
        "paSkydivingDesc": MessageLookupByLibrary.simpleMessage(
            "skydiving, base jumping, bungee jumping"),
        "paSnorkeling": MessageLookupByLibrary.simpleMessage("snorkeling"),
        "paSnorkelingDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paSnowShovingModerate":
            MessageLookupByLibrary.simpleMessage("snow shoveling"),
        "paSnowShovingModerateDesc":
            MessageLookupByLibrary.simpleMessage("by hand, moderate effort"),
        "paSoccerGeneral": MessageLookupByLibrary.simpleMessage("soccer"),
        "paSoccerGeneralDesc":
            MessageLookupByLibrary.simpleMessage("casual, general"),
        "paSoftballBaseballGeneral":
            MessageLookupByLibrary.simpleMessage("softball / baseball"),
        "paSoftballBaseballGeneralDesc":
            MessageLookupByLibrary.simpleMessage("fast or slow pitch, general"),
        "paSquashGeneral": MessageLookupByLibrary.simpleMessage("squash"),
        "paSquashGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paSurfing": MessageLookupByLibrary.simpleMessage("surfing"),
        "paSurfingDesc":
            MessageLookupByLibrary.simpleMessage("body or board, general"),
        "paSwimmingGeneral": MessageLookupByLibrary.simpleMessage("swimming"),
        "paSwimmingGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "treading water, moderate effort, general"),
        "paTableTennisGeneral":
            MessageLookupByLibrary.simpleMessage("table tennis"),
        "paTableTennisGeneralDesc":
            MessageLookupByLibrary.simpleMessage("table tennis, ping pong"),
        "paTaiChiQiGongGeneral":
            MessageLookupByLibrary.simpleMessage("tai chi, qi gong"),
        "paTaiChiQiGongGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paTennisGeneral": MessageLookupByLibrary.simpleMessage("tennis"),
        "paTennisGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paTrackField": MessageLookupByLibrary.simpleMessage("track and field"),
        "paTrackField1Desc": MessageLookupByLibrary.simpleMessage(
            "(e.g. shot, discus, hammer throw)"),
        "paTrackField2Desc": MessageLookupByLibrary.simpleMessage(
            "(e.g. high jump, long jump, triple jump, javelin, pole vault)"),
        "paTrackField3Desc": MessageLookupByLibrary.simpleMessage(
            "(e.g. steeplechase, hurdles)"),
        "paTrampolineLight": MessageLookupByLibrary.simpleMessage("trampoline"),
        "paTrampolineLightDesc":
            MessageLookupByLibrary.simpleMessage("recreational"),
        "paUnicyclingGeneral":
            MessageLookupByLibrary.simpleMessage("unicycling"),
        "paUnicyclingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paVolleyballGeneral":
            MessageLookupByLibrary.simpleMessage("volleyball"),
        "paVolleyballGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "non-competitive, 6 - 9 member team, general"),
        "paWalkingForPleasure": MessageLookupByLibrary.simpleMessage("walking"),
        "paWalkingForPleasureDesc":
            MessageLookupByLibrary.simpleMessage("for pleasure"),
        "paWalkingTheDog":
            MessageLookupByLibrary.simpleMessage("walking the dog"),
        "paWalkingTheDogDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paWallyball": MessageLookupByLibrary.simpleMessage("wallyball"),
        "paWallyballDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paWaterAerobics":
            MessageLookupByLibrary.simpleMessage("water exercise"),
        "paWaterAerobicsDesc": MessageLookupByLibrary.simpleMessage(
            "water aerobics, water calisthenics"),
        "paWaterPolo": MessageLookupByLibrary.simpleMessage("water polo"),
        "paWaterPoloDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paWaterVolleyball":
            MessageLookupByLibrary.simpleMessage("water volleyball"),
        "paWaterVolleyballDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paWateraerobicsCalisthenics":
            MessageLookupByLibrary.simpleMessage("water aerobics"),
        "paWateraerobicsCalisthenicsDesc": MessageLookupByLibrary.simpleMessage(
            "water aerobics, water calisthenics"),
        "paWrestling": MessageLookupByLibrary.simpleMessage("wrestling"),
        "paWrestlingDesc": MessageLookupByLibrary.simpleMessage("general"),
        "palActiveDescriptionLabel": MessageLookupByLibrary.simpleMessage(
            "Mostly standing or walking in job and active free time activities"),
        "palActiveLabel": MessageLookupByLibrary.simpleMessage("Active"),
        "palLowActiveDescriptionLabel": MessageLookupByLibrary.simpleMessage(
            "e.g. sitting or standing in job and light free time activities"),
        "palLowLActiveLabel":
            MessageLookupByLibrary.simpleMessage("Low Active"),
        "palSedentaryDescriptionLabel": MessageLookupByLibrary.simpleMessage(
            "e.g. office job and mostly sitting free time activities"),
        "palSedentaryLabel": MessageLookupByLibrary.simpleMessage("Sedentary"),
        "palVeryActiveDescriptionLabel": MessageLookupByLibrary.simpleMessage(
            "Mostly walking, running or carrying weight in job and active free time activities"),
        "palVeryActiveLabel":
            MessageLookupByLibrary.simpleMessage("Very Active"),
        "per100gmlLabel": MessageLookupByLibrary.simpleMessage("Per 100g/ml"),
        "perServingLabel": MessageLookupByLibrary.simpleMessage("Per Serving"),
        "privacyPolicyLabel":
            MessageLookupByLibrary.simpleMessage("Privacy policy"),
        "profileBodyData": MessageLookupByLibrary.simpleMessage("Body data"),
        "profileBodyDataSubtitle": MessageLookupByLibrary.simpleMessage(
            "Weight, height, age and sex so that the base calculation remains accurate."),
        "profileBodyProgress":
            MessageLookupByLibrary.simpleMessage("Body progress"),
        "profileBodyProgressSubtitle": MessageLookupByLibrary.simpleMessage(
            "Weight trend, 7d average and waist"),
        "profileCalculationBase": MessageLookupByLibrary.simpleMessage(
            "Calculation base for goals, tracking and suggestions."),
        "profileChangePhoto":
            MessageLookupByLibrary.simpleMessage("Change photo"),
        "profileCurrentPhase": m26,
        "profileFocusCardio": MessageLookupByLibrary.simpleMessage(
            "Today the distribution seeks enough energy without adding extra carbs."),
        "profileFocusLowerBody": MessageLookupByLibrary.simpleMessage(
            "Today the distribution increases carbs to support a hard leg session."),
        "profileFocusRest": MessageLookupByLibrary.simpleMessage(
            "Today the distribution cuts carbs and maintains high protein to recover."),
        "profileFocusUpperBody": MessageLookupByLibrary.simpleMessage(
            "Today the distribution maintains good fuel and clean recovery for torso."),
        "profileGenderLabel": MessageLookupByLibrary.simpleMessage("Sex"),
        "profileGoalAndStrategy":
            MessageLookupByLibrary.simpleMessage("Goal and strategy"),
        "profileGoalAndStrategySubtitle": MessageLookupByLibrary.simpleMessage(
            "What you change here impacts calories, macros and daily adjustments."),
        "profileGoalGain": MessageLookupByLibrary.simpleMessage("Volume"),
        "profileGoalGainDesc": MessageLookupByLibrary.simpleMessage(
            "Measured surplus to push training, recovery and progression."),
        "profileGoalLose": MessageLookupByLibrary.simpleMessage("Definition"),
        "profileGoalLoseDesc": MessageLookupByLibrary.simpleMessage(
            "Short and controlled deficit to lose fat without compromising performance or muscle mass."),
        "profileGoalMaintain": MessageLookupByLibrary.simpleMessage("Recomp."),
        "profileGoalMaintainDesc": MessageLookupByLibrary.simpleMessage(
            "Maintain stable weight while prioritizing strength, performance and adherence."),
        "profileLabel": MessageLookupByLibrary.simpleMessage("Profile"),
        "profilePhotoOptions":
            MessageLookupByLibrary.simpleMessage("Photo options"),
        "profileRemovePhoto":
            MessageLookupByLibrary.simpleMessage("Remove photo"),
        "profileSportsProfile":
            MessageLookupByLibrary.simpleMessage("Sports profile"),
        "profileYourProfile":
            MessageLookupByLibrary.simpleMessage("Your profile"),
        "profileYourProfileSubtitle": MessageLookupByLibrary.simpleMessage(
            "Adjust your base data so that calories, macros and recommendations are consistent."),
        "proteinLabel": MessageLookupByLibrary.simpleMessage("protein"),
        "quantityLabel": MessageLookupByLibrary.simpleMessage("Quantity"),
        "readLabel": MessageLookupByLibrary.simpleMessage(
            "I have read and accept the privacy policy."),
        "recentlyAddedLabel": MessageLookupByLibrary.simpleMessage("Recently"),
        "recipeLibraryAddedSnackbar": m27,
        "recipeLibraryEmpty": MessageLookupByLibrary.simpleMessage(
            "No saved meals yet.\nSave meals as recipes to reuse them."),
        "recipeLibraryFavorite":
            MessageLookupByLibrary.simpleMessage("Favorite"),
        "recipeLibraryIngredientsCount": m28,
        "recipeLibraryMarkFavorite":
            MessageLookupByLibrary.simpleMessage("Mark favorite"),
        "recipeLibraryRemoveFavorite":
            MessageLookupByLibrary.simpleMessage("Remove favorite"),
        "recipeLibrarySearchHint":
            MessageLookupByLibrary.simpleMessage("Search saved meals"),
        "recipeLibraryServingsCount": m29,
        "recipeLibraryTitle":
            MessageLookupByLibrary.simpleMessage("Saved meals"),
        "recipeSavedSnackbar":
            MessageLookupByLibrary.simpleMessage("Recipe saved"),
        "reportErrorDialogText": MessageLookupByLibrary.simpleMessage(
            "Do you want to report an error to the developer?"),
        "retryLabel": MessageLookupByLibrary.simpleMessage("Retry"),
        "saturatedFatLabel":
            MessageLookupByLibrary.simpleMessage("saturated fat"),
        "scanProductLabel":
            MessageLookupByLibrary.simpleMessage("Scan Product"),
        "searchDefaultLabel":
            MessageLookupByLibrary.simpleMessage("Please enter a search word"),
        "searchFoodPage": MessageLookupByLibrary.simpleMessage("Food"),
        "searchLabel": MessageLookupByLibrary.simpleMessage("Search"),
        "searchProductsPage": MessageLookupByLibrary.simpleMessage("Products"),
        "searchResultsLabel":
            MessageLookupByLibrary.simpleMessage("Search results"),
        "selectGenderDialogLabel":
            MessageLookupByLibrary.simpleMessage("Select Gender"),
        "selectHeightDialogLabel":
            MessageLookupByLibrary.simpleMessage("Select Height"),
        "selectPalCategoryLabel":
            MessageLookupByLibrary.simpleMessage("Select Activity Level"),
        "selectWeightDialogLabel":
            MessageLookupByLibrary.simpleMessage("Select Weight"),
        "sendAnonymousUserData":
            MessageLookupByLibrary.simpleMessage("Send anonymous usage data"),
        "servingLabel": MessageLookupByLibrary.simpleMessage("Serving"),
        "servingSizeLabelImperial":
            MessageLookupByLibrary.simpleMessage("Serving size (oz/fl oz)"),
        "servingSizeLabelMetric":
            MessageLookupByLibrary.simpleMessage("Serving size (g/ml)"),
        "servingsLabel": MessageLookupByLibrary.simpleMessage("Servings"),
        "settingAboutLabel": MessageLookupByLibrary.simpleMessage("About"),
        "settingFeedbackLabel":
            MessageLookupByLibrary.simpleMessage("Feedback"),
        "settingsAiCallsPhoto": m30,
        "settingsAiCallsText": m31,
        "settingsAiCallsTotal": m32,
        "settingsAiCostDescription": MessageLookupByLibrary.simpleMessage(
            "Based on real token usage per backend request."),
        "settingsAiCostLabel": MessageLookupByLibrary.simpleMessage("AI Cost"),
        "settingsAiCostMonth": m33,
        "settingsAiCostToday": m34,
        "settingsAiCostTotal": m35,
        "settingsCalculationsLabel":
            MessageLookupByLibrary.simpleMessage("Calculations"),
        "settingsDisclaimerLabel":
            MessageLookupByLibrary.simpleMessage("Disclaimer"),
        "settingsDistanceLabel":
            MessageLookupByLibrary.simpleMessage("Distance"),
        "settingsImperialLabel":
            MessageLookupByLibrary.simpleMessage("Imperial (lbs, ft, oz)"),
        "settingsLabel": MessageLookupByLibrary.simpleMessage("Settings"),
        "settingsLanguageEnglish":
            MessageLookupByLibrary.simpleMessage("English"),
        "settingsLanguageLabel":
            MessageLookupByLibrary.simpleMessage("Language"),
        "settingsLanguageSpanish":
            MessageLookupByLibrary.simpleMessage("Spanish"),
        "settingsLanguageSystemDefaultLabel":
            MessageLookupByLibrary.simpleMessage("System default"),
        "settingsLicensesLabel":
            MessageLookupByLibrary.simpleMessage("Licenses"),
        "settingsMassLabel": MessageLookupByLibrary.simpleMessage("Mass"),
        "settingsMetricLabel":
            MessageLookupByLibrary.simpleMessage("Metric (kg, cm, ml)"),
        "settingsPrivacySettings":
            MessageLookupByLibrary.simpleMessage("Privacy Settings"),
        "settingsReportErrorLabel":
            MessageLookupByLibrary.simpleMessage("Report Error"),
        "settingsResetLabel": MessageLookupByLibrary.simpleMessage("Reset"),
        "settingsSelectLanguageTitle":
            MessageLookupByLibrary.simpleMessage("Select language"),
        "settingsSourceCodeLabel":
            MessageLookupByLibrary.simpleMessage("Source Code"),
        "settingsSystemLabel": MessageLookupByLibrary.simpleMessage("System"),
        "settingsThemeDarkLabel": MessageLookupByLibrary.simpleMessage("Dark"),
        "settingsThemeLabel": MessageLookupByLibrary.simpleMessage("Theme"),
        "settingsThemeLightLabel":
            MessageLookupByLibrary.simpleMessage("Light"),
        "settingsThemeSystemDefaultLabel":
            MessageLookupByLibrary.simpleMessage("System default"),
        "settingsUnitsLabel": MessageLookupByLibrary.simpleMessage("Units"),
        "settingsVolumeLabel": MessageLookupByLibrary.simpleMessage("Volume"),
        "snackExample": MessageLookupByLibrary.simpleMessage(
            "e.g. apple, ice cream, chocolate ..."),
        "snackLabel": MessageLookupByLibrary.simpleMessage("Snack"),
        "sugarLabel": MessageLookupByLibrary.simpleMessage("sugar"),
        "suppliedLabel": MessageLookupByLibrary.simpleMessage("supplied"),
        "todayLabel": MessageLookupByLibrary.simpleMessage("Today"),
        "unitLabel": MessageLookupByLibrary.simpleMessage("Unit"),
        "weeklyInsightsAdherence":
            MessageLookupByLibrary.simpleMessage("Adherence"),
        "weeklyInsightsAdjustmentSuccess": m36,
        "weeklyInsightsApplyAdjustment": m37,
        "weeklyInsightsAverages":
            MessageLookupByLibrary.simpleMessage("Weekly Averages"),
        "weeklyInsightsCheckup":
            MessageLookupByLibrary.simpleMessage("Smart Weekly Checkup"),
        "weeklyInsightsCoverage":
            MessageLookupByLibrary.simpleMessage("Coverage"),
        "weeklyInsightsCurrentAdjustment": m38,
        "weeklyInsightsError": MessageLookupByLibrary.simpleMessage(
            "Could not load weekly insights."),
        "weeklyInsightsNoFrequentMeals": MessageLookupByLibrary.simpleMessage(
            "No repeated meals detected this week."),
        "weeklyInsightsNoOvereatingPattern":
            MessageLookupByLibrary.simpleMessage("No clear overeating pattern"),
        "weeklyInsightsOvereatingPattern":
            MessageLookupByLibrary.simpleMessage("Overeating Pattern"),
        "weeklyInsightsProteinConsistency":
            MessageLookupByLibrary.simpleMessage("Protein Consistency"),
        "weeklyInsightsRecAdherenceLow": MessageLookupByLibrary.simpleMessage(
            "Adherence too low for automatic adjustment. Improve consistency first."),
        "weeklyInsightsRecGainCorrect": MessageLookupByLibrary.simpleMessage(
            "Controlled bulk pace. No kcal change."),
        "weeklyInsightsRecGainFast": MessageLookupByLibrary.simpleMessage(
            "Weight rising too fast: suggestion -50 kcal/day."),
        "weeklyInsightsRecGainSlow": MessageLookupByLibrary.simpleMessage(
            "Bulk too slow: suggestion +100 kcal/day."),
        "weeklyInsightsRecGainSoft": MessageLookupByLibrary.simpleMessage(
            "Soft bulk pace: suggestion +50 kcal/day."),
        "weeklyInsightsRecLoseWeightCorrect":
            MessageLookupByLibrary.simpleMessage(
                "Correct definition pace. No kcal change."),
        "weeklyInsightsRecLoseWeightFast": MessageLookupByLibrary.simpleMessage(
            "Weight dropping too fast: suggestion +50 kcal/day."),
        "weeklyInsightsRecLoseWeightSlow": MessageLookupByLibrary.simpleMessage(
            "Slow fat loss: suggestion -50 kcal/day."),
        "weeklyInsightsRecLoseWeightStalled":
            MessageLookupByLibrary.simpleMessage(
                "Fat loss stalled: suggestion -100 kcal/day."),
        "weeklyInsightsRecMaintainDown": MessageLookupByLibrary.simpleMessage(
            "Weight trending down: suggestion +50 kcal/day."),
        "weeklyInsightsRecMaintainStable": MessageLookupByLibrary.simpleMessage(
            "Stable maintenance. No kcal change."),
        "weeklyInsightsRecMaintainUp": MessageLookupByLibrary.simpleMessage(
            "Weight trending up: suggestion -50 kcal/day."),
        "weeklyInsightsRegisteredDays": m39,
        "weeklyInsightsSlotAfternoon":
            MessageLookupByLibrary.simpleMessage("Afternoon"),
        "weeklyInsightsSlotEvening":
            MessageLookupByLibrary.simpleMessage("Evening"),
        "weeklyInsightsSlotLateNight":
            MessageLookupByLibrary.simpleMessage("Late night"),
        "weeklyInsightsSlotMorning":
            MessageLookupByLibrary.simpleMessage("Morning"),
        "weeklyInsightsSummary":
            MessageLookupByLibrary.simpleMessage("Summary"),
        "weeklyInsightsSummaryIrregular": MessageLookupByLibrary.simpleMessage(
            "Caloric adherence was irregular this week."),
        "weeklyInsightsSummaryNoDays": MessageLookupByLibrary.simpleMessage(
            "No days registered this week yet."),
        "weeklyInsightsSummaryProteinGap": MessageLookupByLibrary.simpleMessage(
            "The main gap was protein consistency."),
        "weeklyInsightsSummarySolid": MessageLookupByLibrary.simpleMessage(
            "Solid week: good caloric adherence and protein consistency."),
        "weeklyInsightsSummaryStable": MessageLookupByLibrary.simpleMessage(
            "Stable week, with room to improve consistency."),
        "weeklyInsightsTitle":
            MessageLookupByLibrary.simpleMessage("Weekly Insights"),
        "weeklyInsightsTopMeals":
            MessageLookupByLibrary.simpleMessage("Most Frequent Meals"),
        "weeklyInsightsTrackedDays": m40,
        "weeklyInsightsTrend": m41,
        "weightLabel": MessageLookupByLibrary.simpleMessage("Weight"),
        "yearsLabel": m42
      };
}
