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

  static String m2(count, kcal) =>
      "${count} ingredients detected, about ${kcal} kcal. Upgrade to save unlimited AI meals.";

  static String m3(count, kcal) =>
      "${count} ingredients detected, about ${kcal} kcal. You can save without using trials.";

  static String m4(count, kcal, remaining) =>
      "${count} ingredients detected, about ${kcal} kcal. Reviewing is free; saving uses 1 of your ${remaining} trials.";

  static String m5(item) => "Edit ${item}";

  static String m6(count) => "${count} ingredients";

  static String m7(unit) => "Quantity (${unit})";

  static String m8(source) => "Replaced by ${source} to improve accuracy.";

  static String m9(count) => "${count} servings ready to save";

  static String m10(title) => "Applied suggestion: ${title}";

  static String m11(count) =>
      "You have used the guest allowance. Protect your account to unlock ${count} more free uses.";

  static String m12(count) => "You have used your ${count} AI trials.";

  static String m13(count) => "${count} free AI trials remaining.";

  static String m14(label) => "Use habitual: ${label}";

  static String m15(versionNumber) => "Version ${versionNumber}";

  static String m16(date) => "Latest check-in ${date}";

  static String m17(weight) =>
      "Protein and fat will be calculated by multiplying each value by ${weight}. Carbs will fill the remaining kcal from the automatic target.";

  static String m18(pctCarbs, pctFats, pctProteins) =>
      "${pctCarbs}% carbs, ${pctFats}% fats, ${pctProteins}% proteins";

  static String m19(count) => "${count} activities";

  static String m20(percent) => "${percent}% adherence";

  static String m21(count) => "${count}/7 days";

  static String m22(count) => "${count} items";

  static String m23(amount) => "${amount} g remaining";

  static String m24(amount) => "+${amount} kcal";

  static String m25(amount) => "${amount} kcal remaining";

  static String m26(carbsTracked, carbsGoal, fatTracked, fatGoal,
          proteinTracked, proteinGoal) =>
      "Carbs ${carbsTracked}/${carbsGoal} g, fat ${fatTracked}/${fatGoal} g, protein ${proteinTracked}/${proteinGoal} g";

  static String m27(count) => "${count} meals";

  static String m28(amount) => "${amount}g avg protein";

  static String m29(step, unit) =>
      "Adjust the logged amount in steps of ${step} ${unit}.";

  static String m30(fileName) =>
      "Backup uploaded to Google Drive: ${fileName}.";

  static String m31(current, total) => "Step ${current} / ${total}";

  static String m32(count) => "${count}/7 today";

  static String m33(goal) => "Prioritize fluids today: ${goal}.";

  static String m34(goal) => "Higher hydration target for leg day: ${goal}.";

  static String m35(goal) => "Keep hydration steady today: ${goal}.";

  static String m36(goal) => "Keep hydration high today: ${goal}.";

  static String m37(amount) => "Goal ${amount} h";

  static String m38(amount) => "Goal ${amount}";

  static String m39(integration) =>
      "${integration} connected. If sync fails, review permissions.";

  static String m40(integration) =>
      "${integration} connected. Sleep, steps, and workouts can sync automatically.";

  static String m41(integration) =>
      "${integration} connected. If sync fails, review permissions.";

  static String m42(integration) =>
      "${integration} is not available on this device.";

  static String m43(integration) =>
      "Your ${integration} data is already up to date.";

  static String m44(integration) => "${integration} data successfully synced.";

  static String m45(integration, imported, updated) =>
      "${integration}: ${imported} new workouts and ${updated} updated.";

  static String m46(count) => "${count} burned";

  static String m47(count) => "Daily average across ${count} meals";

  static String m48(current, goal) => "${current} of ${goal} kcal";

  static String m49(amount) => "${amount}g left";

  static String m50(count) =>
      "${Intl.plural(count, one: '1 meal', other: '${count} meals')}";

  static String m51(count) =>
      "${Intl.plural(count, one: '1 session', other: '${count} sessions')}";

  static String m52(recipe, slot) => "${recipe} added to ${slot}";

  static String m53(count) => "${count} portions";

  static String m54(count) => "Frequent meal (${count}x)";

  static String m55(mealType) =>
      "Choose how to log it. The meal will be saved to ${mealType}.";

  static String m56(amount) =>
      "You have ${amount}g of protein left. Prioritize a high protein meal.";

  static String m57(riskValue) => "Risk of comorbidities: ${riskValue}";

  static String m58(count) => "${count} AI meals saved";

  static String m59(count) => "${count} AI trials remaining";

  static String m60(count) =>
      "You have used the guest allowance. Protect your account and unlock ${count} more free uses without losing progress.";

  static String m61(count, minutes) =>
      "${count} AI meals saved. ${minutes} min saved.";

  static String m62(date) => "Last plan sync: ${date}";

  static String m63(kcal) => "${kcal} kcal today";

  static String m64(count) => "${count} pending";

  static String m65(count) => "Messages (${count})";

  static String m66(title, kcal, slotName) =>
      "Do you want to add \"${title}\" (${kcal} kcal) to today\'s diary under \"${slotName}\"?";

  static String m67(title) => "\"${title}\" logged successfully.";

  static String m68(error) => "Error loading recipe: ${error}";

  static String m69(kcal) => "${kcal} kcal left on the plan.";

  static String m70(kcal) => "+${kcal} kcal over today\'s plan.";

  static String m71(date) => "Consent active since ${date}.";

  static String m72(error) => "Could not update recipe proposal: ${error}";

  static String m73(count) =>
      "Your coach sees the real active sharing level. If there are ${count} pending snapshots, they will sync when connectivity returns.";

  static String m74(time) => "Synced: ${time}";

  static String m75(percent) => "Estimated adherence: ${percent}%";

  static String m76(count) => "${count} meals logged";

  static String m77(percent) => "${percent}% of today kcal target";

  static String m78(delta, unit) => "${delta}${unit} vs target";

  static String m79(actual, target, percent) =>
      "Weekly total: ${actual} kcal / ${target} kcal (${percent}%)";

  static String m80(phase) => "Current phase: ${phase}";

  static String m81(unit) =>
      "Set your daily water goal (${unit}). If left empty, the default value based on the day will be used.";

  static String m82(unit) => "Water target (${unit})";

  static String m83(recipe, slot) => "${recipe} added to ${slot}";

  static String m84(carbs, fat, protein) =>
      "C ${carbs} | F ${fat} | P ${protein}";

  static String m85(amount) => "P ${amount}";

  static String m86(servings, unit) => "Serving: ${servings} ${unit}";

  static String m87(servings, unit) => "Suggested intake: ${servings} ${unit}";

  static String m88(kcal) => "Per serving. Full recipe: ${kcal} kcal.";

  static String m89(name) => "${name} added";

  static String m90(count) => "${count} times";

  static String m91(count) => "${count} ingredients";

  static String m92(count) => "${count} servings";

  static String m93(count) => "${count} uses";

  static String m94(barcode) => "Barcode: ${barcode}";

  static String m95(count) => "Photo calls: ${count}";

  static String m96(count) => "Text calls: ${count}";

  static String m97(count) => "Total calls: ${count}";

  static String m98(cost) => "This month: ${cost}";

  static String m99(cost) => "Today: ${cost}";

  static String m100(cost) => "Total estimated: ${cost}";

  static String m101(target) =>
      "To confirm, type \"${target}\" in the box below:";

  static String m102(count) =>
      "You have used the guest allowance. Protect your account to unlock ${count} more free uses.";

  static String m103(used, count) =>
      "${used} used - unlock ${count} more with Google";

  static String m104(count, minutes) =>
      "${count} AI meals saved - ${minutes} min saved";

  static String m105(used, remaining) =>
      "${used} used - ${remaining} remaining";

  static String m106(code, url) =>
      "Try MacroTracker! Log meals with AI in seconds. Use my referral code: ${code} and we both get extra free AI uses. ${url}";

  static String m107(platform) =>
      "Please describe the bug here:\n\n\n\n---\nSystem info:\nPlatform: ${platform}\n";

  static String m108(remaining, limit, count) =>
      "${remaining} of ${limit} free uses available now. Protect your account to keep them and unlock ${count} more.";

  static String m109(remaining, limit) =>
      "${remaining} of ${limit} free AI uses available.";

  static String m110(kcal) => "Daily adjustment updated to ${kcal} kcal.";

  static String m111(delta) => "Apply ${delta} kcal/day";

  static String m112(kcal) => "Current adjustment: ${kcal} kcal.";

  static String m113(count) => "${count} times";

  static String m114(percent) => "${percent}% of registered days";

  static String m115(count) => "${count} days registered this week";

  static String m116(delta) => "Weight trend: ${delta} kg/week";

  static String m117(count) => "${count} of 7 days logged";

  static String m118(age) => "${age} years";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "activityExample": MessageLookupByLibrary.simpleMessage(
            "e.g. running, biking, yoga ..."),
        "activityLabel": MessageLookupByLibrary.simpleMessage("Activity"),
        "activityMetLabel": MessageLookupByLibrary.simpleMessage("MET"),
        "activitySummaryLabel":
            MessageLookupByLibrary.simpleMessage("Activity summary"),
        "addItemLabel": MessageLookupByLibrary.simpleMessage("Add new Item:"),
        "addLabel": MessageLookupByLibrary.simpleMessage("Add"),
        "addMealBarcode": MessageLookupByLibrary.simpleMessage("Barcode"),
        "addMealOfflineCachedResults": MessageLookupByLibrary.simpleMessage(
            "Offline. Showing cached results."),
        "addMealOfflineNoCachedResults": MessageLookupByLibrary.simpleMessage(
            "Offline. No cached results found."),
        "addMealPhoto": MessageLookupByLibrary.simpleMessage("Photo"),
        "addMealQuickActionsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Start with barcode, photo, text, or saved meals. If you search, use Food or Recent history."),
        "addMealQuickActionsTitle":
            MessageLookupByLibrary.simpleMessage("Quick shortcuts"),
        "addMealRecentEmpty": MessageLookupByLibrary.simpleMessage(
            "No recent meals yet.\nLog a meal once and it will appear here."),
        "addMealSaved": MessageLookupByLibrary.simpleMessage("Saved"),
        "addMealSearchPromptGeneric": MessageLookupByLibrary.simpleMessage(
            "Search a generic food like rice, eggs, or yogurt."),
        "addMealSearchPromptPackaged": MessageLookupByLibrary.simpleMessage(
            "Search any food or use barcode."),
        "addMealSearchPromptRecent": MessageLookupByLibrary.simpleMessage(
            "Search your recent history or open saved meals."),
        "addMealSectionGenericResults":
            MessageLookupByLibrary.simpleMessage("Generic food results"),
        "addMealSectionPackagedResults":
            MessageLookupByLibrary.simpleMessage("Food results"),
        "addMealSectionRecentResults":
            MessageLookupByLibrary.simpleMessage("Recent meals"),
        "addMealTabGeneric":
            MessageLookupByLibrary.simpleMessage("Generic foods"),
        "addMealTabGenericHelper": MessageLookupByLibrary.simpleMessage(
            "Use this for simple foods like rice, chicken, fruit, or oats."),
        "addMealTabPackaged": MessageLookupByLibrary.simpleMessage("Food"),
        "addMealTabPackagedHelper": MessageLookupByLibrary.simpleMessage(
            "Use this for any food search, including branded items."),
        "addMealTabRecent":
            MessageLookupByLibrary.simpleMessage("Recent history"),
        "addMealTabRecentHelper": MessageLookupByLibrary.simpleMessage(
            "Reuse something you logged recently."),
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
        "aiCaptureDraftReviewNotice": MessageLookupByLibrary.simpleMessage(
            "AI is preparing a draft. You will be able to review, edit, or remove ingredients before saving."),
        "aiCaptureProcessingTime": MessageLookupByLibrary.simpleMessage(
            "This usually takes 5 to 10 seconds."),
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
        "aiContinueManually":
            MessageLookupByLibrary.simpleMessage("Continue manually"),
        "aiCropLabel": MessageLookupByLibrary.simpleMessage("Crop"),
        "aiCustomServingsHelper": MessageLookupByLibrary.simpleMessage(
            "Adjust the final portion before saving."),
        "aiCustomServingsLabel":
            MessageLookupByLibrary.simpleMessage("Custom servings"),
        "aiDetectedIngredients":
            MessageLookupByLibrary.simpleMessage("Detected ingredients"),
        "aiDraftBlockedMessage": m2,
        "aiDraftNotFound":
            MessageLookupByLibrary.simpleMessage("Draft not found or expired."),
        "aiDraftPremiumMessage": m3,
        "aiDraftReadyTitle":
            MessageLookupByLibrary.simpleMessage("AI draft ready"),
        "aiDraftTrialMessage": m4,
        "aiDraftUpgradeAction": MessageLookupByLibrary.simpleMessage("Upgrade"),
        "aiEditAmountTitle": m5,
        "aiEditMacrosLabel": MessageLookupByLibrary.simpleMessage("Macros"),
        "aiEditMacrosTitle":
            MessageLookupByLibrary.simpleMessage("Edit macros"),
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
        "aiFailureCloudSessionInvalid": MessageLookupByLibrary.simpleMessage(
            "Your cloud session is no longer valid. Reopen or protect your cloud account and retry."),
        "aiFailureInvalidResponseManualDraft": MessageLookupByLibrary.simpleMessage(
            "The AI response could not be used. Retry or continue with a manual draft."),
        "aiFailureNoNetworkManualReview": MessageLookupByLibrary.simpleMessage(
            "No network connection. Retry when you are back online or continue with a manual review."),
        "aiFailureTimeoutManualReview": MessageLookupByLibrary.simpleMessage(
            "The AI request timed out. Retry or continue with a manual review."),
        "aiFailureUnavailableManual": MessageLookupByLibrary.simpleMessage(
            "AI meal interpretation is temporarily unavailable. Retry or continue manually."),
        "aiFavoriteQuickAccess":
            MessageLookupByLibrary.simpleMessage("Saved for quick access"),
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
        "aiIngredientsCount": m6,
        "aiMatchGood": MessageLookupByLibrary.simpleMessage("Good match"),
        "aiMatchHigh": MessageLookupByLibrary.simpleMessage("High match"),
        "aiMatchPossible":
            MessageLookupByLibrary.simpleMessage("Possible match"),
        "aiMatchesHint": MessageLookupByLibrary.simpleMessage(
            "Use a frequent meal, recipe, or previous correction if it looks more like what you ate."),
        "aiMatchesReferenceHint": MessageLookupByLibrary.simpleMessage(
            "This is only a reference. It will never be added to your meal automatically."),
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
        "aiPhotoChooseGallery":
            MessageLookupByLibrary.simpleMessage("Choose from gallery"),
        "aiPhotoCorrectionHint": MessageLookupByLibrary.simpleMessage(
            "You will be able to correct ingredients before saving."),
        "aiPhotoHintSubtitle": MessageLookupByLibrary.simpleMessage(
            "Open this if you want better detection."),
        "aiPhotoOpeningAnalysis":
            MessageLookupByLibrary.simpleMessage("Opening photo analysis..."),
        "aiPhotoPreviewError":
            MessageLookupByLibrary.simpleMessage("Could not load preview"),
        "aiPhotoPreviewSubtitle": MessageLookupByLibrary.simpleMessage(
            "Confirm the photo looks good before sending it to AI."),
        "aiPhotoPreviewTitle": MessageLookupByLibrary.simpleMessage("Preview"),
        "aiPhotoRemovePhoto":
            MessageLookupByLibrary.simpleMessage("Remove photo"),
        "aiPhotoRetakePhoto":
            MessageLookupByLibrary.simpleMessage("Retake photo"),
        "aiPhotoReviewNotice": MessageLookupByLibrary.simpleMessage(
            "AI suggests ingredients and macros. You review everything before saving."),
        "aiPhotoTakePhoto": MessageLookupByLibrary.simpleMessage("Take photo"),
        "aiPhotoUseThisPhoto":
            MessageLookupByLibrary.simpleMessage("Use this photo"),
        "aiPhotoZoomTitle": MessageLookupByLibrary.simpleMessage("Photo zoom"),
        "aiQuantityUnitLabel": m7,
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
        "aiReplacedBySummary": m8,
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
        "aiServingsReady": m9,
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
        "aiSuggestionApplied": m10,
        "aiTextAnalyzingIngredients": MessageLookupByLibrary.simpleMessage(
            "Analyzing ingredients and quantities"),
        "aiTextBestPracticesSubtitle": MessageLookupByLibrary.simpleMessage(
            "Open this if you want better results."),
        "aiTextBestPracticesTitle":
            MessageLookupByLibrary.simpleMessage("What works best?"),
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
        "aiTextClear": MessageLookupByLibrary.simpleMessage("Clear"),
        "aiTextCreateDraft":
            MessageLookupByLibrary.simpleMessage("Create AI draft"),
        "aiTextDescribeMealSubtitle": MessageLookupByLibrary.simpleMessage(
            "Write ingredients, quantities, or a full meal so AI can prepare a draft for you."),
        "aiTextDescribeMealTitle":
            MessageLookupByLibrary.simpleMessage("Describe your meal"),
        "aiTextExampleAmountsLabel":
            MessageLookupByLibrary.simpleMessage("Meal with amounts"),
        "aiTextExampleAmountsValue": MessageLookupByLibrary.simpleMessage(
            "180 g salmon, 220 g roasted potato, and salad with 10 ml olive oil"),
        "aiTextExampleQuickDinnerLabel":
            MessageLookupByLibrary.simpleMessage("Quick dinner"),
        "aiTextExampleQuickDinnerValue": MessageLookupByLibrary.simpleMessage(
            "Chicken burrito with cheese, guacamole, and a Coke Zero"),
        "aiTextExampleSimpleBreakfastLabel":
            MessageLookupByLibrary.simpleMessage("Simple breakfast"),
        "aiTextExampleSimpleBreakfastValue":
            MessageLookupByLibrary.simpleMessage(
                "Coffee with milk, toast with tomato, and two eggs"),
        "aiTextHintAmountsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Grams, units, or tablespoons help estimate more accurately."),
        "aiTextHintAmountsTitle": MessageLookupByLibrary.simpleMessage(
            "Include amounts if you know them"),
        "aiTextHintDishSubtitle": MessageLookupByLibrary.simpleMessage(
            "Do not write only \"pasta\"; better \"pasta with tuna and tomato\"."),
        "aiTextHintDishTitle": MessageLookupByLibrary.simpleMessage(
            "Write the dish and the sides"),
        "aiTextHintSaucesSubtitle": MessageLookupByLibrary.simpleMessage(
            "They often change the final calories quite a bit."),
        "aiTextHintSaucesTitle": MessageLookupByLibrary.simpleMessage(
            "Do not forget drinks and sauces"),
        "aiTextInputHint": MessageLookupByLibrary.simpleMessage(
            "Example: 200 g chicken, 150 g rice, salad with olive oil, and a Greek yogurt"),
        "aiTextQuickExamples":
            MessageLookupByLibrary.simpleMessage("Quick examples"),
        "aiTextReviewNotice": MessageLookupByLibrary.simpleMessage(
            "AI creates an editable draft. You review ingredients and macros before saving."),
        "aiTextSpecificityHint": MessageLookupByLibrary.simpleMessage(
            "The more specific you are, the better the draft will be."),
        "aiTextWhatDidYouEat":
            MessageLookupByLibrary.simpleMessage("What did you eat"),
        "aiTrialGoogleAction": MessageLookupByLibrary.simpleMessage("Google"),
        "aiTrialGuestAllowanceUsed": m11,
        "aiTrialLimitUsed": m12,
        "aiTrialRemaining": m13,
        "aiTrialUpgradeAction": MessageLookupByLibrary.simpleMessage("Upgrade"),
        "aiUnavailableTitle":
            MessageLookupByLibrary.simpleMessage("AI unavailable"),
        "aiUseHabitual": m14,
        "aiYourMatches": MessageLookupByLibrary.simpleMessage("Your matches"),
        "allItemsLabel": MessageLookupByLibrary.simpleMessage("All"),
        "alphaVersionName": MessageLookupByLibrary.simpleMessage("[Alpha]"),
        "amountPrefixLabel": MessageLookupByLibrary.simpleMessage("Amount: "),
        "appDescription": MessageLookupByLibrary.simpleMessage(
            "MacroTracker by EPSAIT is a professional calorie and nutrient tracker with local-first privacy."),
        "appLicenseLabel":
            MessageLookupByLibrary.simpleMessage("GPL-3.0 license"),
        "appTitle": MessageLookupByLibrary.simpleMessage("MacroTracker"),
        "appVersionName": m15,
        "appleHealthAutoSyncDisabledMessage":
            MessageLookupByLibrary.simpleMessage(
                "Apple Health auto-sync disabled."),
        "appleHealthAutoSyncEnabledMessage":
            MessageLookupByLibrary.simpleMessage(
                "Apple Health auto-sync enabled."),
        "appleHealthAutoSyncSubtitle": MessageLookupByLibrary.simpleMessage(
            "Sync sleep, steps, and workouts automatically on app open."),
        "appleHealthAutoSyncTitle":
            MessageLookupByLibrary.simpleMessage("Apple Health auto-sync"),
        "appleHealthLabel":
            MessageLookupByLibrary.simpleMessage("Apple Health"),
        "appleHealthSyncNowTitle":
            MessageLookupByLibrary.simpleMessage("Sync Apple Health now"),
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
        "bodyProgressBodyFatLabel":
            MessageLookupByLibrary.simpleMessage("Body fat (%)"),
        "bodyProgressDay": MessageLookupByLibrary.simpleMessage("Day"),
        "bodyProgressDelta": MessageLookupByLibrary.simpleMessage("Delta"),
        "bodyProgressLatestCheckin": m16,
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
        "calculationsCurrentWeightFallback":
            MessageLookupByLibrary.simpleMessage("your current weight"),
        "calculationsGramPerKgHint": m17,
        "calculationsMacroModeGramsPerKg":
            MessageLookupByLibrary.simpleMessage("Grams/kg"),
        "calculationsMacroModePercentage":
            MessageLookupByLibrary.simpleMessage("Percentage"),
        "calculationsMacronutrientsDistributionLabel":
            MessageLookupByLibrary.simpleMessage("Macros distribution"),
        "calculationsMacrosDistribution": m18,
        "calculationsRecommendedLabel":
            MessageLookupByLibrary.simpleMessage("(recommended)"),
        "calculationsTDEEIOM2006Label": MessageLookupByLibrary.simpleMessage(
            "Institute of Medicine Equation"),
        "calculationsTDEELabel":
            MessageLookupByLibrary.simpleMessage("TDEE equation"),
        "carbohydrateLabel":
            MessageLookupByLibrary.simpleMessage("carbohydrate"),
        "carbsLabel": MessageLookupByLibrary.simpleMessage("carbs"),
        "checkinTabAdditionalNotes":
            MessageLookupByLibrary.simpleMessage("Additional notes"),
        "checkinTabAnswerHint":
            MessageLookupByLibrary.simpleMessage("Type your answer..."),
        "checkinTabEnergyLevel":
            MessageLookupByLibrary.simpleMessage("Energy Level"),
        "checkinTabHigh": MessageLookupByLibrary.simpleMessage("High"),
        "checkinTabHowFeeling":
            MessageLookupByLibrary.simpleMessage("How are you feeling?"),
        "checkinTabLow": MessageLookupByLibrary.simpleMessage("Low"),
        "checkinTabMoodHint": MessageLookupByLibrary.simpleMessage(
            "e.g. Energized, tired, motivated..."),
        "checkinTabNotesHint": MessageLookupByLibrary.simpleMessage(
            "Any challenges or wins this week?"),
        "checkinTabNutritionistQuestions":
            MessageLookupByLibrary.simpleMessage("Nutritionist questions"),
        "checkinTabReviewShortly": MessageLookupByLibrary.simpleMessage(
            "Your nutritionist will review it shortly."),
        "checkinTabShareSubtitle":
            MessageLookupByLibrary.simpleMessage("Share how your week went"),
        "checkinTabSleepHours":
            MessageLookupByLibrary.simpleMessage("Sleep Hours"),
        "checkinTabSubmitAnother":
            MessageLookupByLibrary.simpleMessage("Submit another"),
        "checkinTabSubmitButton":
            MessageLookupByLibrary.simpleMessage("Submit Check-in"),
        "checkinTabSubmitted":
            MessageLookupByLibrary.simpleMessage("Check-in submitted!"),
        "checkinTabSubmitting":
            MessageLookupByLibrary.simpleMessage("Submitting..."),
        "checkinTabWeeklyTitle":
            MessageLookupByLibrary.simpleMessage("Weekly Check-in"),
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
            "Help improve stability by sending anonymous crash and diagnostic reports"),
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
        "dialogNoLabel": MessageLookupByLibrary.simpleMessage("No"),
        "dialogOKLabel": MessageLookupByLibrary.simpleMessage("OK"),
        "dialogYesLabel": MessageLookupByLibrary.simpleMessage("Yes"),
        "diaryActivitiesPill": m19,
        "diaryAddMealAction": MessageLookupByLibrary.simpleMessage("Add meal"),
        "diaryAdherencePill": m20,
        "diaryCopyDayToToday":
            MessageLookupByLibrary.simpleMessage("Copy day to today"),
        "diaryCurrentWeek":
            MessageLookupByLibrary.simpleMessage("Current week"),
        "diaryDayCopied":
            MessageLookupByLibrary.simpleMessage("Day copied to today"),
        "diaryDaysPill": m21,
        "diaryElementsSection": m22,
        "diaryEmptyDaySubtitle": MessageLookupByLibrary.simpleMessage(
            "There are no meals or activities on this day yet."),
        "diaryEmptyDayTitle":
            MessageLookupByLibrary.simpleMessage("No logs for this day"),
        "diaryEmptySection": MessageLookupByLibrary.simpleMessage("Empty"),
        "diaryGoalReached":
            MessageLookupByLibrary.simpleMessage("Goal reached"),
        "diaryGramsRemaining": m23,
        "diaryInGoal": MessageLookupByLibrary.simpleMessage("In goal"),
        "diaryKcalOver": m24,
        "diaryKcalRemaining": m25,
        "diaryLabel": MessageLookupByLibrary.simpleMessage("Diary"),
        "diaryMacrosSummary": m26,
        "diaryMealsPill": m27,
        "diaryNextDayTooltip": MessageLookupByLibrary.simpleMessage("Next day"),
        "diaryPreviousDayTooltip":
            MessageLookupByLibrary.simpleMessage("Previous day"),
        "diaryProteinPill": m28,
        "diaryQuickAmountDecrease":
            MessageLookupByLibrary.simpleMessage("Reduce amount"),
        "diaryQuickAmountIncrease":
            MessageLookupByLibrary.simpleMessage("Increase amount"),
        "diaryQuickAmountSubtitle": m29,
        "diaryQuickAmountTitle":
            MessageLookupByLibrary.simpleMessage("Meal actions"),
        "diarySelectedDayLabel":
            MessageLookupByLibrary.simpleMessage("Selected day"),
        "diaryStatusAbove": MessageLookupByLibrary.simpleMessage("Above"),
        "diaryStatusBelow": MessageLookupByLibrary.simpleMessage("Below"),
        "diaryStatusInRange": MessageLookupByLibrary.simpleMessage("In range"),
        "diarySummaryTitle":
            MessageLookupByLibrary.simpleMessage("Day summary"),
        "diaryWeeklyAdherenceLabel":
            MessageLookupByLibrary.simpleMessage("adherence"),
        "diaryWeeklyDaysLabel": MessageLookupByLibrary.simpleMessage("days"),
        "diaryWeeklyProteinLabel":
            MessageLookupByLibrary.simpleMessage("protein"),
        "dinnerExample": MessageLookupByLibrary.simpleMessage(
            "e.g. soup, chicken, wine ..."),
        "dinnerLabel": MessageLookupByLibrary.simpleMessage("Dinner"),
        "disclaimerText": MessageLookupByLibrary.simpleMessage(
            "MacroTracker is not a medical application. All data provided is not validated and should be used with caution. Please maintain a healthy lifestyle and consult a professional if you have any problems. Use during illness, pregnancy or lactation is not recommended."),
        "driveBackupAccountConnected":
            MessageLookupByLibrary.simpleMessage("Drive account connected"),
        "driveBackupConnect":
            MessageLookupByLibrary.simpleMessage("Connect Drive"),
        "driveBackupConnectedSnack": MessageLookupByLibrary.simpleMessage(
            "Google Drive connected. This does not change your cloud account."),
        "driveBackupDailyConnectFirstBody":
            MessageLookupByLibrary.simpleMessage(
                "Connect Google Drive first to enable daily backups."),
        "driveBackupDailyDisabledSnack":
            MessageLookupByLibrary.simpleMessage("Daily backup disabled."),
        "driveBackupDailyEnabledSnack": MessageLookupByLibrary.simpleMessage(
            "Daily backup enabled on Android."),
        "driveBackupDailyScheduleNote": MessageLookupByLibrary.simpleMessage(
            "The first run is scheduled for the next overnight window. Android may shift it by minutes or hours depending on battery, network, and power-saving rules."),
        "driveBackupDailySignedInBody": MessageLookupByLibrary.simpleMessage(
            "Android will schedule one backup per day when the system allows background work to run."),
        "driveBackupDailyTitle":
            MessageLookupByLibrary.simpleMessage("Daily automatic backup"),
        "driveBackupDefaultFileName":
            MessageLookupByLibrary.simpleMessage("file"),
        "driveBackupDisconnect":
            MessageLookupByLibrary.simpleMessage("Disconnect"),
        "driveBackupDisconnectedSnack":
            MessageLookupByLibrary.simpleMessage("Google Drive disconnected."),
        "driveBackupLastAttemptFailed":
            MessageLookupByLibrary.simpleMessage("Last attempt failed"),
        "driveBackupLastCompleted":
            MessageLookupByLibrary.simpleMessage("Last backup completed"),
        "driveBackupNoTimestamp":
            MessageLookupByLibrary.simpleMessage("No timestamp"),
        "driveBackupNoUploadYet": MessageLookupByLibrary.simpleMessage(
            "No backup has been uploaded yet."),
        "driveBackupNoneYet":
            MessageLookupByLibrary.simpleMessage("No backups yet"),
        "driveBackupNotConnected":
            MessageLookupByLibrary.simpleMessage("Not connected"),
        "driveBackupOAuthMissing": MessageLookupByLibrary.simpleMessage(
            "Google Drive OAuth is still missing for this platform. See docs/google-drive-backup-setup.md."),
        "driveBackupPending": MessageLookupByLibrary.simpleMessage("Pending"),
        "driveBackupReady": MessageLookupByLibrary.simpleMessage("Ready"),
        "driveBackupRunNow":
            MessageLookupByLibrary.simpleMessage("Back up now"),
        "driveBackupStatusTitle":
            MessageLookupByLibrary.simpleMessage("Backup status"),
        "driveBackupSubtitle": MessageLookupByLibrary.simpleMessage(
            "Creates an encrypted ZIP of your data and stores it in your own Drive. This is separate from your MacroTracker cloud account."),
        "driveBackupTitle":
            MessageLookupByLibrary.simpleMessage("Google Drive backup"),
        "driveBackupUploadedSnack": m30,
        "durationLabel": MessageLookupByLibrary.simpleMessage("Duration"),
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
            "Export ZIP creates a local manual copy that you can import later. MacroTracker is local-first; Cuenta cloud, Google Drive backup, AI, and coach connections are optional and separate."),
        "exportImportErrorLabel":
            MessageLookupByLibrary.simpleMessage("Export / Import error"),
        "exportImportLabel":
            MessageLookupByLibrary.simpleMessage("Export / Import data"),
        "exportImportSuccessLabel":
            MessageLookupByLibrary.simpleMessage("Export / Import successful"),
        "fatLabel": MessageLookupByLibrary.simpleMessage("fat"),
        "featureTourBack": MessageLookupByLibrary.simpleMessage("Back"),
        "featureTourDesc0": MessageLookupByLibrary.simpleMessage(
            "We will show you how the application works to help you track your nutrition, workouts, and daily habits in just 1 minute."),
        "featureTourDesc1": MessageLookupByLibrary.simpleMessage(
            "Tap the (+) button to log food quickly:\n• Scan barcodes.\n• Use our private text or photo AI (fully anonymous).\n• Enter calories and macros manually.\n\nTap it right now to see it open!"),
        "featureTourDesc10": MessageLookupByLibrary.simpleMessage(
            "Access here to adjust your caloric requirements, change the language, metric/imperial units, or the application theme.\n\nTap the \'Profile\' tab to continue."),
        "featureTourDesc11": MessageLookupByLibrary.simpleMessage(
            "Link your account to sync your data in the cloud and schedule automatic encrypted backups to your Google Drive account."),
        "featureTourDesc12": MessageLookupByLibrary.simpleMessage(
            "You have completed the interactive tour. Start logging your meals and habits today to reach your physical goal. Good luck!"),
        "featureTourDesc2": MessageLookupByLibrary.simpleMessage(
            "Your central panel calculates remaining calories in real time:\n• Adds base goals and subtracts food intake.\n• Monitors proteins, carbs, and fats to balance your day."),
        "featureTourDesc3": MessageLookupByLibrary.simpleMessage(
            "Track your steps, sleep, and water. MacroTracker syncs automatically with Health Connect to import your data effortlessly."),
        "featureTourDesc4": MessageLookupByLibrary.simpleMessage(
            "Track your evolution by logging body weight and measurements. View interactive trend charts to stay motivated."),
        "featureTourDesc5": MessageLookupByLibrary.simpleMessage(
            "Receive smart weekly reports generated from your progress. The app will advise you how to adjust your plan to avoid plateaus."),
        "featureTourDesc6": MessageLookupByLibrary.simpleMessage(
            "If your nutritionist uses the platform, you can link your account using their invite code to let them supervise and adapt your plan in real time."),
        "featureTourDesc7": MessageLookupByLibrary.simpleMessage(
            "Organize your intakes by time of day (breakfast, lunch, snack, dinner) and perform continuous tracking of your habits.\n\nTap the \'Diary\' tab on the bottom bar to continue."),
        "featureTourDesc8": MessageLookupByLibrary.simpleMessage(
            "Review your daily intake. Tap any food to edit its grams or swipe to delete it if you made a mistake."),
        "featureTourDesc9": MessageLookupByLibrary.simpleMessage(
            "Save your frequent meals in your library. Also, copy the link of any web recipe and our AI will import its ingredients automatically."),
        "featureTourNext": MessageLookupByLibrary.simpleMessage("Next"),
        "featureTourSkip": MessageLookupByLibrary.simpleMessage("Skip"),
        "featureTourStart": MessageLookupByLibrary.simpleMessage("Start"),
        "featureTourStepCounter": m31,
        "featureTourTapHighlightedArea":
            MessageLookupByLibrary.simpleMessage("Tap highlighted area"),
        "featureTourTitle0": MessageLookupByLibrary.simpleMessage("Welcome!"),
        "featureTourTitle1":
            MessageLookupByLibrary.simpleMessage("Log with a Tap"),
        "featureTourTitle10":
            MessageLookupByLibrary.simpleMessage("Profile & Settings"),
        "featureTourTitle11":
            MessageLookupByLibrary.simpleMessage("Cloud Backup & Account"),
        "featureTourTitle12": MessageLookupByLibrary.simpleMessage("All Set!"),
        "featureTourTitle2":
            MessageLookupByLibrary.simpleMessage("Daily Calories & Macros"),
        "featureTourTitle3":
            MessageLookupByLibrary.simpleMessage("Habits & Connected Health"),
        "featureTourTitle4":
            MessageLookupByLibrary.simpleMessage("Progress & Weight History"),
        "featureTourTitle5":
            MessageLookupByLibrary.simpleMessage("Weekly Summary & Insights"),
        "featureTourTitle6":
            MessageLookupByLibrary.simpleMessage("Nutritionist & Invites"),
        "featureTourTitle7":
            MessageLookupByLibrary.simpleMessage("Your Diary History"),
        "featureTourTitle8":
            MessageLookupByLibrary.simpleMessage("Diary Management"),
        "featureTourTitle9":
            MessageLookupByLibrary.simpleMessage("Recipes & AI Web Importer"),
        "feedbackDescriptionHint": MessageLookupByLibrary.simpleMessage(
            "Please describe your suggestion or the problem you encountered..."),
        "feedbackDescriptionLabel":
            MessageLookupByLibrary.simpleMessage("Details"),
        "feedbackDialogTitle":
            MessageLookupByLibrary.simpleMessage("Send Feedback"),
        "feedbackEmptyFieldsWarning": MessageLookupByLibrary.simpleMessage(
            "Please fill in all fields before submitting"),
        "feedbackErrorSnackbar": MessageLookupByLibrary.simpleMessage(
            "Failed to send feedback. Please try again later."),
        "feedbackSubmitButton": MessageLookupByLibrary.simpleMessage("Submit"),
        "feedbackSubmittingButton":
            MessageLookupByLibrary.simpleMessage("Sending..."),
        "feedbackSuccessSnackbar": MessageLookupByLibrary.simpleMessage(
            "Thank you! Your feedback has been sent successfully."),
        "feedbackTitleLabel": MessageLookupByLibrary.simpleMessage("Subject"),
        "feedbackTypeBug": MessageLookupByLibrary.simpleMessage("Report a bug"),
        "feedbackTypeFeature":
            MessageLookupByLibrary.simpleMessage("Suggest a feature"),
        "feedbackTypeLabel":
            MessageLookupByLibrary.simpleMessage("Feedback Type"),
        "fiberLabel": MessageLookupByLibrary.simpleMessage("fiber"),
        "flOzUnit": MessageLookupByLibrary.simpleMessage("fl.oz"),
        "fluidOunceUnitLabel": MessageLookupByLibrary.simpleMessage("fl oz"),
        "foodQualityBandExcellent":
            MessageLookupByLibrary.simpleMessage("Excellent"),
        "foodQualityBandFair": MessageLookupByLibrary.simpleMessage("Fair"),
        "foodQualityBandGood": MessageLookupByLibrary.simpleMessage("Good"),
        "foodQualityBandPoor": MessageLookupByLibrary.simpleMessage("Poor"),
        "foodQualityPartialSubtitle": MessageLookupByLibrary.simpleMessage(
            "Estimate based on partial data"),
        "foodQualityReasonBalancedProfile":
            MessageLookupByLibrary.simpleMessage("Balanced profile"),
        "foodQualityReasonGoodProtein":
            MessageLookupByLibrary.simpleMessage("Good protein"),
        "foodQualityReasonHighEnergyDensity":
            MessageLookupByLibrary.simpleMessage("Calorie dense"),
        "foodQualityReasonHighFiber":
            MessageLookupByLibrary.simpleMessage("High fiber"),
        "foodQualityReasonHighSaturatedFat":
            MessageLookupByLibrary.simpleMessage("High saturated fat"),
        "foodQualityReasonHighSugar":
            MessageLookupByLibrary.simpleMessage("High sugar"),
        "foodQualityReasonLowEnergyDensity":
            MessageLookupByLibrary.simpleMessage("Reasonable calorie density"),
        "foodQualityReasonLowSugar":
            MessageLookupByLibrary.simpleMessage("Moderate sugar"),
        "foodQualityReasonPartialData":
            MessageLookupByLibrary.simpleMessage("Partial data"),
        "foodQualitySubtitle":
            MessageLookupByLibrary.simpleMessage("Estimated nutrition score"),
        "foodQualityTitle":
            MessageLookupByLibrary.simpleMessage("Food quality"),
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
        "gymHabitsCaffeineShort": MessageLookupByLibrary.simpleMessage("Caf."),
        "gymHabitsCompletedToday": m32,
        "gymHabitsCreatineShort":
            MessageLookupByLibrary.simpleMessage("Creat."),
        "gymHabitsEnergyTitle": MessageLookupByLibrary.simpleMessage("Energy"),
        "gymHabitsFocusCardio":
            MessageLookupByLibrary.simpleMessage("Cardio day"),
        "gymHabitsFocusLowerBody":
            MessageLookupByLibrary.simpleMessage("Leg day"),
        "gymHabitsFocusRest": MessageLookupByLibrary.simpleMessage("Rest day"),
        "gymHabitsFocusUpperBody":
            MessageLookupByLibrary.simpleMessage("Upper body day"),
        "gymHabitsHydrationHintCardio": m33,
        "gymHabitsHydrationHintLowerBody": m34,
        "gymHabitsHydrationHintRest": m35,
        "gymHabitsHydrationHintUpperBody": m36,
        "gymHabitsManualAdjustHint": MessageLookupByLibrary.simpleMessage(
            "Use +/- only if you need to correct the value."),
        "gymHabitsProteinShort": MessageLookupByLibrary.simpleMessage("Prot."),
        "gymHabitsReadinessImproving":
            MessageLookupByLibrary.simpleMessage("Could improve"),
        "gymHabitsReadinessOffTarget":
            MessageLookupByLibrary.simpleMessage("Off target"),
        "gymHabitsReadinessOnTarget":
            MessageLookupByLibrary.simpleMessage("On target"),
        "gymHabitsSleepTarget": m37,
        "gymHabitsSleepTitle": MessageLookupByLibrary.simpleMessage("Sleep"),
        "gymHabitsSourceHealthConnectDetail":
            MessageLookupByLibrary.simpleMessage(
                "Main value from Health Connect"),
        "gymHabitsSourceManualDetail":
            MessageLookupByLibrary.simpleMessage("Main value entered manually"),
        "gymHabitsStepsTarget": m38,
        "gymHabitsStepsTitle": MessageLookupByLibrary.simpleMessage("Steps"),
        "gymHabitsTitle":
            MessageLookupByLibrary.simpleMessage("Habits and recovery"),
        "habitSourceHealthConnect":
            MessageLookupByLibrary.simpleMessage("Health Connect"),
        "habitSourceManual": MessageLookupByLibrary.simpleMessage("Manual"),
        "habitSourceManualAdjust":
            MessageLookupByLibrary.simpleMessage("Manual adjustment"),
        "habitSourceSynced":
            MessageLookupByLibrary.simpleMessage("Synced source"),
        "healthConnectAutoSyncDisabledMessage":
            MessageLookupByLibrary.simpleMessage(
                "Health Connect auto-sync disabled."),
        "healthConnectAutoSyncEnabledMessage":
            MessageLookupByLibrary.simpleMessage(
                "Health Connect auto-sync enabled."),
        "healthConnectAutoSyncSubtitle": MessageLookupByLibrary.simpleMessage(
            "Sync sleep, steps, and workouts automatically on app open."),
        "healthConnectAutoSyncTitle":
            MessageLookupByLibrary.simpleMessage("Health Connect auto-sync"),
        "healthConnectGrantPermissionsSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Open the permission flow for sleep, steps, and workouts."),
        "healthConnectGrantPermissionsTitle":
            MessageLookupByLibrary.simpleMessage(
                "Grant Health Connect permissions"),
        "healthConnectPermissionsMissing": MessageLookupByLibrary.simpleMessage(
            "Health Connect permissions are still missing."),
        "healthConnectPermissionsUpdated": MessageLookupByLibrary.simpleMessage(
            "Health Connect permissions updated."),
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
                "Health permissions are required to read sleep, steps, and workouts."),
        "healthConnectStatusReady": MessageLookupByLibrary.simpleMessage(
            "Connected. Sleep, steps, and workouts can sync automatically."),
        "healthConnectStatusUnavailable": MessageLookupByLibrary.simpleMessage(
            "Health Connect is not available on this device."),
        "healthConnectSyncNoChanges": MessageLookupByLibrary.simpleMessage(
            "No new Health Connect data or workouts were imported."),
        "healthConnectSyncNowTitle":
            MessageLookupByLibrary.simpleMessage("Sync Health Connect now"),
        "healthConnectSyncSuccess": MessageLookupByLibrary.simpleMessage(
            "Health Connect data synced, including workouts."),
        "healthStatusPermissionsReview": m39,
        "healthStatusReadyName": m40,
        "healthStatusReviewPermissions": m41,
        "healthStatusStepsPermissionMissing":
            MessageLookupByLibrary.simpleMessage(
                "Steps permission missing. Sync will be partial."),
        "healthStatusUnavailableName": m42,
        "healthStatusWorkoutPermissionMissing":
            MessageLookupByLibrary.simpleMessage(
                "Workout detail permissions missing. Some calories may stay at 0."),
        "healthSyncAlreadyCurrent": m43,
        "healthSyncSuccessName": m44,
        "healthSyncWorkoutSummary": m45,
        "heightLabel": MessageLookupByLibrary.simpleMessage("Height"),
        "historyLabel": MessageLookupByLibrary.simpleMessage("History"),
        "homeChangeFocusTooltip":
            MessageLookupByLibrary.simpleMessage("Change focus"),
        "homeChangeGoalTooltip":
            MessageLookupByLibrary.simpleMessage("Change goal"),
        "homeDailyBoardTitle":
            MessageLookupByLibrary.simpleMessage("Daily board"),
        "homeDashboardBurnedChip": m46,
        "homeDashboardEmpty": MessageLookupByLibrary.simpleMessage(
            "Log a meal or workout to unlock better guidance."),
        "homeDashboardEmptyAction":
            MessageLookupByLibrary.simpleMessage("Take AI photo"),
        "homeDashboardEmptySubtitle": MessageLookupByLibrary.simpleMessage(
            "Take a photo of your meal and AI does the rest."),
        "homeDashboardEmptyTitle":
            MessageLookupByLibrary.simpleMessage("Start logging your day!"),
        "homeDashboardFocusLabel":
            MessageLookupByLibrary.simpleMessage("Focus"),
        "homeDashboardFoodQualityAverage": m47,
        "homeDashboardGoalLabel": MessageLookupByLibrary.simpleMessage("Goal"),
        "homeDashboardKcalProgress": m48,
        "homeDashboardKcalRemaining":
            MessageLookupByLibrary.simpleMessage("Kcal left"),
        "homeDashboardMacroDone":
            MessageLookupByLibrary.simpleMessage("Goal reached"),
        "homeDashboardMacroRemaining": m49,
        "homeDashboardMealsChip": m50,
        "homeDashboardNoFoodQualityData":
            MessageLookupByLibrary.simpleMessage("No food quality data yet."),
        "homeDashboardOverGoal":
            MessageLookupByLibrary.simpleMessage("Over goal"),
        "homeDashboardProteinRemaining":
            MessageLookupByLibrary.simpleMessage("Protein left"),
        "homeDashboardSessionsChip": m51,
        "homeDashboardStatusBulkOpen": MessageLookupByLibrary.simpleMessage(
            "You still have room. Add easy carbs and protein."),
        "homeDashboardStatusCarbWindow": MessageLookupByLibrary.simpleMessage(
            "You still have carb room. Good moment for training fuel."),
        "homeDashboardStatusDefClosing": MessageLookupByLibrary.simpleMessage(
            "Definition on track. Keep the last meal high in protein."),
        "homeDashboardStatusDefault": MessageLookupByLibrary.simpleMessage(
            "Good pace. Keep it simple and close the day clean."),
        "homeDashboardStatusOverGoal": MessageLookupByLibrary.simpleMessage(
            "You are above target. Keep the rest of the day tighter."),
        "homeDashboardStatusProteinGap": MessageLookupByLibrary.simpleMessage(
            "Protein is still the main gap. Prioritize it next meal."),
        "homeDashboardStatusRestClosing": MessageLookupByLibrary.simpleMessage(
            "Rest day almost closed. Finish light and protein-first."),
        "homeDashboardSubtitle":
            MessageLookupByLibrary.simpleMessage("Today at a glance."),
        "homeDashboardTitle":
            MessageLookupByLibrary.simpleMessage("Gym nutrition"),
        "homeFocusCardio": MessageLookupByLibrary.simpleMessage("Cardio"),
        "homeFocusLowerBody": MessageLookupByLibrary.simpleMessage("Legs"),
        "homeFocusRest": MessageLookupByLibrary.simpleMessage("Rest"),
        "homeFocusUpperBody": MessageLookupByLibrary.simpleMessage("Upper"),
        "homeLabel": MessageLookupByLibrary.simpleMessage("Home"),
        "homeNutritionistPromoAction":
            MessageLookupByLibrary.simpleMessage("Connect account"),
        "homeNutritionistPromoSubtitle": MessageLookupByLibrary.simpleMessage(
            "Sync macros, get tailored meal guides, and chat directly with your professional."),
        "homeNutritionistPromoTitle": MessageLookupByLibrary.simpleMessage(
            "Working with a nutritionist?"),
        "homePerformanceSummary":
            MessageLookupByLibrary.simpleMessage("Performance Summary"),
        "homeTodayActionsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Suggestions and ready meals to close macros without friction."),
        "homeTodayActionsTitle":
            MessageLookupByLibrary.simpleMessage("Today actions"),
        "homeTrackingSubtitle": MessageLookupByLibrary.simpleMessage(
            "Adherence, progress, and trends for better adjustments."),
        "homeTrackingTitle": MessageLookupByLibrary.simpleMessage("Tracking"),
        "homeWeeklyInsightsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Check averages, adherence, protein and top meals"),
        "hydrationAddWater": MessageLookupByLibrary.simpleMessage("Add water"),
        "hydrationGoalReached":
            MessageLookupByLibrary.simpleMessage("Goal reached!"),
        "hydrationRemoveWater":
            MessageLookupByLibrary.simpleMessage("Remove water"),
        "hydrationTitle": MessageLookupByLibrary.simpleMessage("Hydration"),
        "importAction": MessageLookupByLibrary.simpleMessage("Import"),
        "inchUnitLabel": MessageLookupByLibrary.simpleMessage("in"),
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
        "literUnitLabel": MessageLookupByLibrary.simpleMessage("L"),
        "logTodayLabel": MessageLookupByLibrary.simpleMessage("Log today"),
        "loggedEntryDetailsLabel":
            MessageLookupByLibrary.simpleMessage("Logged entry details"),
        "loggedMacrosLabel":
            MessageLookupByLibrary.simpleMessage("Logged macros"),
        "lunchExample":
            MessageLookupByLibrary.simpleMessage("e.g. pizza, salad, rice ..."),
        "lunchLabel": MessageLookupByLibrary.simpleMessage("Lunch"),
        "macroCoachLockedSubtitle": MessageLookupByLibrary.simpleMessage(
            "Personalized suggestions tailored to your remaining macros."),
        "macroCoachLockedTitle":
            MessageLookupByLibrary.simpleMessage("Premium suggestions"),
        "macroCoachPreviewChicken": MessageLookupByLibrary.simpleMessage(
            "Teriyaki chicken with broccoli"),
        "macroCoachPreviewOmelette":
            MessageLookupByLibrary.simpleMessage("Spinach and turkey omelette"),
        "macroCoachSubtitleCut": MessageLookupByLibrary.simpleMessage(
            "Close the day with high protein and controlled calories."),
        "macroCoachSubtitleDefault": MessageLookupByLibrary.simpleMessage(
            "Choose what to eat now based on what is left today."),
        "macroCoachSubtitleRest": MessageLookupByLibrary.simpleMessage(
            "Light options to keep adherence without overshooting."),
        "macroCoachSubtitleTraining": MessageLookupByLibrary.simpleMessage(
            "Premium adjusts real meals to your workout and remaining macros."),
        "macroCoachTitleCardio":
            MessageLookupByLibrary.simpleMessage("Cardio day macro coach"),
        "macroCoachTitleCut":
            MessageLookupByLibrary.simpleMessage("Cut-focused macro coach"),
        "macroCoachTitleLeg":
            MessageLookupByLibrary.simpleMessage("Leg day macro coach"),
        "macroCoachTitleToday":
            MessageLookupByLibrary.simpleMessage("Today\'s macro coach"),
        "macroCoachTitleUpper":
            MessageLookupByLibrary.simpleMessage("Upper body macro coach"),
        "macroCoachUnlockAction":
            MessageLookupByLibrary.simpleMessage("Unlock coach"),
        "macroDistributionLabel":
            MessageLookupByLibrary.simpleMessage("Macronutrient Distribution:"),
        "macroKcalLabel": MessageLookupByLibrary.simpleMessage("Kcal"),
        "macroSuggestionsAddedTo": m52,
        "macroSuggestionsEmpty": MessageLookupByLibrary.simpleMessage(
            "Save some recipes and this section will start suggesting based on your training day."),
        "macroSuggestionsRationaleCalorieFit":
            MessageLookupByLibrary.simpleMessage(
                "Clean fit for the calories you still have left."),
        "macroSuggestionsRationaleCutClose": MessageLookupByLibrary.simpleMessage(
            "Lean close for cut days: protein-first with calories kept tight."),
        "macroSuggestionsRationaleDefault": MessageLookupByLibrary.simpleMessage(
            "Solid gym-friendly option that keeps the day moving in the right direction."),
        "macroSuggestionsRationalePostWorkout":
            MessageLookupByLibrary.simpleMessage(
                "Post-workout recovery hit with enough carbs and protein to reload."),
        "macroSuggestionsRationalePreWorkout": MessageLookupByLibrary.simpleMessage(
            "Good pre-workout fuel: useful carbs without much digestive drag."),
        "macroSuggestionsRationaleProteinClose":
            MessageLookupByLibrary.simpleMessage(
                "Protein-first close to finish the day without guessing."),
        "macroSuggestionsRationaleShakeLight": MessageLookupByLibrary.simpleMessage(
            "Fast protein touch when you want something light and easy to log."),
        "macroSuggestionsServingsPortions": m53,
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
        "mainWaterAddedSnack":
            MessageLookupByLibrary.simpleMessage("+250 ml of water registered"),
        "mealBrandsLabel": MessageLookupByLibrary.simpleMessage("Brands"),
        "mealCaptureFallbackDetectedItem":
            MessageLookupByLibrary.simpleMessage("Detected item"),
        "mealCaptureFallbackEstimatedSummary":
            MessageLookupByLibrary.simpleMessage(
                "Estimated meal interpretation."),
        "mealCaptureFallbackPhotoMealTitle":
            MessageLookupByLibrary.simpleMessage("Photo meal"),
        "mealCaptureFallbackReviewDraftSummary":
            MessageLookupByLibrary.simpleMessage(
                "Remote interpretation was unavailable. Review the draft and use your saved suggestions to adjust it quickly."),
        "mealCaptureFallbackSimilarMealSummary":
            MessageLookupByLibrary.simpleMessage(
                "Remote interpretation was unavailable. MacroTracker suggested a similar meal from your history to speed up review."),
        "mealCaptureSourceFrequentCorrection":
            MessageLookupByLibrary.simpleMessage("Your frequent correction"),
        "mealCaptureSourceFrequentMealCount": m54,
        "mealCaptureSourceFrequentSavedMeal":
            MessageLookupByLibrary.simpleMessage("Your frequent meal"),
        "mealCaptureSourceSavedCorrection":
            MessageLookupByLibrary.simpleMessage("Your correction"),
        "mealCaptureSourceSavedMeal":
            MessageLookupByLibrary.simpleMessage("Your saved meal"),
        "mealCaptureSourceSavedRecipe":
            MessageLookupByLibrary.simpleMessage("Saved recipe"),
        "mealCarbsLabel": MessageLookupByLibrary.simpleMessage("carbs per"),
        "mealEntryActivitySubtitle":
            MessageLookupByLibrary.simpleMessage("Workout or extra burn"),
        "mealEntryAiPhoto": MessageLookupByLibrary.simpleMessage("AI photo"),
        "mealEntryAiText": MessageLookupByLibrary.simpleMessage("AI text"),
        "mealEntryRecipesAndFrequent":
            MessageLookupByLibrary.simpleMessage("Recipes and frequent"),
        "mealEntryRecipesAndFrequentSubtitle":
            MessageLookupByLibrary.simpleMessage("Saved meals and presets"),
        "mealEntryReviewBeforeSaving": MessageLookupByLibrary.simpleMessage(
            "Review amounts before saving"),
        "mealEntryScanBarcode":
            MessageLookupByLibrary.simpleMessage("Scan barcode"),
        "mealEntryScanBarcodeSubtitle":
            MessageLookupByLibrary.simpleMessage("Packaged food"),
        "mealEntrySearchFood":
            MessageLookupByLibrary.simpleMessage("Search food"),
        "mealEntrySearchFoodSubtitle":
            MessageLookupByLibrary.simpleMessage("Database and recent meals"),
        "mealEntrySubtitle": m55,
        "mealEntryTitle": MessageLookupByLibrary.simpleMessage("Add meal"),
        "mealFatLabel": MessageLookupByLibrary.simpleMessage("fat per"),
        "mealKcalLabel": MessageLookupByLibrary.simpleMessage("kcal per"),
        "mealNameLabel": MessageLookupByLibrary.simpleMessage("Meal name"),
        "mealProteinLabel":
            MessageLookupByLibrary.simpleMessage("protein per 100 g/ml"),
        "mealReminderAfterLunch":
            MessageLookupByLibrary.simpleMessage("After lunch"),
        "mealReminderAfternoon":
            MessageLookupByLibrary.simpleMessage("Afternoon"),
        "mealReminderBreakfastBody": MessageLookupByLibrary.simpleMessage(
            "Do not forget to log your breakfast."),
        "mealReminderBreakfastTitle":
            MessageLookupByLibrary.simpleMessage("Breakfast reminder"),
        "mealReminderChannelDescription": MessageLookupByLibrary.simpleMessage(
            "Daily reminders to log your meals."),
        "mealReminderChannelName":
            MessageLookupByLibrary.simpleMessage("Meal reminders"),
        "mealReminderDinner": MessageLookupByLibrary.simpleMessage("Dinner"),
        "mealReminderDinnerBody": MessageLookupByLibrary.simpleMessage(
            "Close the day by logging dinner."),
        "mealReminderDinnerTitle":
            MessageLookupByLibrary.simpleMessage("Dinner reminder"),
        "mealReminderDisabledMessage":
            MessageLookupByLibrary.simpleMessage("Reminders disabled."),
        "mealReminderDisabledStatus":
            MessageLookupByLibrary.simpleMessage("Disabled"),
        "mealReminderEnableLabel":
            MessageLookupByLibrary.simpleMessage("Enable reminders"),
        "mealReminderLunchBody": MessageLookupByLibrary.simpleMessage(
            "Log your lunch when you are done."),
        "mealReminderLunchTitle":
            MessageLookupByLibrary.simpleMessage("Lunch reminder"),
        "mealReminderMorning": MessageLookupByLibrary.simpleMessage("Morning"),
        "mealReminderPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
            "Could not enable reminders because Android permission was denied."),
        "mealReminderSavedMessage": MessageLookupByLibrary.simpleMessage(
            "Reminders saved and scheduled."),
        "mealReminderSnackBody": MessageLookupByLibrary.simpleMessage(
            "You can still log your snack."),
        "mealReminderSnackTitle":
            MessageLookupByLibrary.simpleMessage("Snack reminder"),
        "mealReminderSubtitle": MessageLookupByLibrary.simpleMessage(
            "Android will remind you to log breakfast, lunch, snack, and dinner."),
        "mealReminderTitle":
            MessageLookupByLibrary.simpleMessage("Meal reminders"),
        "mealReplacementUnnamedMeal":
            MessageLookupByLibrary.simpleMessage("Unnamed meal"),
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
        "nudgeProteinLeft": m56,
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
        "nutritionalStatusRiskLabel": m57,
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
        "onboardingCloudProtectBody": MessageLookupByLibrary.simpleMessage(
            "MacroTracker is ready without sign-up. If you protect your account with Google, you can recover it on a new phone and use professional nutritionist connections. This does not enable Google Drive."),
        "onboardingCloudProtectTitle":
            MessageLookupByLibrary.simpleMessage("Protect your cloud account"),
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
        "onboardingNotNow": MessageLookupByLibrary.simpleMessage("Not now"),
        "onboardingOverviewDataFootnote": MessageLookupByLibrary.simpleMessage(
            "You can adjust these targets later from Profile. Your data starts on this device; after this you can optionally protect a cloud account for recovery."),
        "onboardingOverviewLabel":
            MessageLookupByLibrary.simpleMessage("Overview"),
        "onboardingSaveUserError": MessageLookupByLibrary.simpleMessage(
            "Wrong input, please try again"),
        "onboardingUseGoogle":
            MessageLookupByLibrary.simpleMessage("Use Google"),
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
        "paywallAiLimitSubtitle": MessageLookupByLibrary.simpleMessage(
            "You have tried AI logging. Premium keeps the fast flow available."),
        "paywallAiLimitTitle":
            MessageLookupByLibrary.simpleMessage("Unlock unlimited AI logging"),
        "paywallAiMealsSavedBadge": m58,
        "paywallAiPhotoSubtitle": MessageLookupByLibrary.simpleMessage(
            "Use camera or gallery to create an ingredient and macro draft."),
        "paywallAiPhotoTitle":
            MessageLookupByLibrary.simpleMessage("Log from a photo"),
        "paywallAiTextSubtitle": MessageLookupByLibrary.simpleMessage(
            "Describe a meal and review an editable draft before saving it."),
        "paywallAiTextTitle":
            MessageLookupByLibrary.simpleMessage("Turn text into macros"),
        "paywallBenefitAdjustedServings": MessageLookupByLibrary.simpleMessage(
            "Servings adjusted to your remaining calories and protein"),
        "paywallBenefitAiDrafts": MessageLookupByLibrary.simpleMessage(
            "AI meal drafts from text and photos"),
        "paywallBenefitCloseTodayMacros": MessageLookupByLibrary.simpleMessage(
            "Concrete options to close today\'s macros"),
        "paywallBenefitEditableReview": MessageLookupByLibrary.simpleMessage(
            "Editable review before saving"),
        "paywallBenefitFasterTracking": MessageLookupByLibrary.simpleMessage(
            "Faster macro and progress tracking"),
        "paywallBenefitGoalExplanation": MessageLookupByLibrary.simpleMessage(
            "Explanation for why it fits today\'s goal"),
        "paywallBenefitLearnsCorrections": MessageLookupByLibrary.simpleMessage(
            "AI learns from your usual corrections"),
        "paywallBenefitOneTapLog": MessageLookupByLibrary.simpleMessage(
            "Log the recommendation to the right meal with one tap"),
        "paywallBestAnnualValue": MessageLookupByLibrary.simpleMessage(
            "Best value for AI meal logging all year."),
        "paywallBestWithThreeDaysBadge":
            MessageLookupByLibrary.simpleMessage("Best with 3+ days"),
        "paywallComparisonAutomatic":
            MessageLookupByLibrary.simpleMessage("Automatic"),
        "paywallComparisonCloudSyncBackup":
            MessageLookupByLibrary.simpleMessage("Cloud sync and backup"),
        "paywallComparisonDailyAiLogging":
            MessageLookupByLibrary.simpleMessage("Daily AI logging"),
        "paywallComparisonFiveMealsDay":
            MessageLookupByLibrary.simpleMessage("5 meals/day"),
        "paywallComparisonIncluded":
            MessageLookupByLibrary.simpleMessage("Included"),
        "paywallComparisonLocked":
            MessageLookupByLibrary.simpleMessage("Locked"),
        "paywallComparisonMacroCoach":
            MessageLookupByLibrary.simpleMessage("Macro Coach suggestions"),
        "paywallComparisonUnlimited":
            MessageLookupByLibrary.simpleMessage("Unlimited"),
        "paywallComparisonWeeklyAdjustments":
            MessageLookupByLibrary.simpleMessage("Weekly adjustments"),
        "paywallGoogleComplete": MessageLookupByLibrary.simpleMessage(
            "Complete Google and return to MacroTracker."),
        "paywallGoogleLinkStartFailed": MessageLookupByLibrary.simpleMessage(
            "Could not start Google linking."),
        "paywallGoogleOpenFailed":
            MessageLookupByLibrary.simpleMessage("Could not open Google."),
        "paywallLaunchAnnualOfferBadge":
            MessageLookupByLibrary.simpleMessage("Launch annual offer"),
        "paywallLaunchOfferBadge":
            MessageLookupByLibrary.simpleMessage("Launch offer"),
        "paywallMacroCoachSubtitle": MessageLookupByLibrary.simpleMessage(
            "Premium turns your remaining macros into concrete meals, adjusted servings, and fast logging."),
        "paywallMacroCoachTitle":
            MessageLookupByLibrary.simpleMessage("Unlock your Macro Coach"),
        "paywallManualTrackingFooter": MessageLookupByLibrary.simpleMessage(
            "You can keep using manual tracking for free."),
        "paywallMonthShort": MessageLookupByLibrary.simpleMessage("mo"),
        "paywallNoActivePurchases": MessageLookupByLibrary.simpleMessage(
            "No active purchases were found."),
        "paywallOnboardingSubtitle": MessageLookupByLibrary.simpleMessage(
            "Premium unlocks AI that turns real meals into editable macros in seconds."),
        "paywallOnboardingTitle":
            MessageLookupByLibrary.simpleMessage("Speed up your first log"),
        "paywallPremiumActive": MessageLookupByLibrary.simpleMessage(
            "MacroTracker Premium is active."),
        "paywallPremiumNotConfigured": MessageLookupByLibrary.simpleMessage(
            "Premium is not configured for this build. Please contact support."),
        "paywallPremiumRecommendationBadge":
            MessageLookupByLibrary.simpleMessage("Premium recommendation"),
        "paywallPremiumTitle":
            MessageLookupByLibrary.simpleMessage("MacroTracker Premium"),
        "paywallPremiumUnavailable": MessageLookupByLibrary.simpleMessage(
            "Premium plans are not available right now."),
        "paywallProcessing":
            MessageLookupByLibrary.simpleMessage("Processing..."),
        "paywallProtectWithGoogle":
            MessageLookupByLibrary.simpleMessage("Protect with Google"),
        "paywallPurchaseFailed": MessageLookupByLibrary.simpleMessage(
            "The purchase could not be completed."),
        "paywallRestorePurchases":
            MessageLookupByLibrary.simpleMessage("Restore purchases"),
        "paywallSettingsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Unlock AI meal interpretation from text and photos."),
        "paywallStartPremium":
            MessageLookupByLibrary.simpleMessage("Start Premium"),
        "paywallTermsOfUseEula":
            MessageLookupByLibrary.simpleMessage("Terms of Use (EULA)"),
        "paywallTrialRemainingBadge": m59,
        "paywallTrialUsedBadge":
            MessageLookupByLibrary.simpleMessage("Trial used"),
        "paywallUnlockFreeUsesBody": m60,
        "paywallUnlockFreeUsesTitle": MessageLookupByLibrary.simpleMessage(
            "Unlock your remaining free uses with Google"),
        "paywallUsageValueStrip": m61,
        "paywallWeeklyInsightsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Premium combines AI, adherence, and progress to decide what to change this week."),
        "paywallWeeklyInsightsTitle": MessageLookupByLibrary.simpleMessage(
            "Turn your data into adjustments"),
        "per100gmlLabel": MessageLookupByLibrary.simpleMessage("Per 100g/ml"),
        "perServingLabel": MessageLookupByLibrary.simpleMessage("Per Serving"),
        "privacyPolicyLabel":
            MessageLookupByLibrary.simpleMessage("Privacy policy"),
        "professionalAcceptAndConnect":
            MessageLookupByLibrary.simpleMessage("Accept and connect"),
        "professionalActionRefreshSection":
            MessageLookupByLibrary.simpleMessage("Refresh section"),
        "professionalActionRevokeAccess":
            MessageLookupByLibrary.simpleMessage("Revoke access"),
        "professionalConnectedNoPlan": MessageLookupByLibrary.simpleMessage(
            "Connected, no plan published"),
        "professionalConsentNotSharedToday":
            MessageLookupByLibrary.simpleMessage("What is not shared today"),
        "professionalConsentNotSharedTodayBody":
            MessageLookupByLibrary.simpleMessage(
                "full raw diary and per-meal detail unless you enable detailed sharing later"),
        "professionalConsentReviewEyebrow":
            MessageLookupByLibrary.simpleMessage("Consent review"),
        "professionalConsentReviewSubtitle": MessageLookupByLibrary.simpleMessage(
            "Before connecting, you can review exactly what is shared today and what stays outside."),
        "professionalConsentRevokeHint": MessageLookupByLibrary.simpleMessage(
            "You can revoke access at any time from the privacy section."),
        "professionalConsentSharedToday":
            MessageLookupByLibrary.simpleMessage("What is shared today"),
        "professionalConsentSharedTodayBody": MessageLookupByLibrary.simpleMessage(
            "kcal, macros, logged meals, aggregate adherence by day, and bidirectional messaging"),
        "professionalDisconnectBody": MessageLookupByLibrary.simpleMessage(
            "Access will be revoked, this section will disappear, and aggregate sync will stop."),
        "professionalDisconnectTitle":
            MessageLookupByLibrary.simpleMessage("Revoke professional access"),
        "professionalEmptyPlanBody": MessageLookupByLibrary.simpleMessage(
            "Your coach is already connected to you, but has not published an active plan yet. When they do, this section will show daily targets, follow-up, and suggested meals."),
        "professionalEmptyPlanSync": m62,
        "professionalErrorAction": MessageLookupByLibrary.simpleMessage(
            "The action could not be completed. Try again."),
        "professionalErrorCloudIdentity": MessageLookupByLibrary.simpleMessage(
            "Could not create the cloud identity required to connect the plan."),
        "professionalErrorOffline": MessageLookupByLibrary.simpleMessage(
            "Could not connect. Check your connection and try again."),
        "professionalHeroConnectTitle": MessageLookupByLibrary.simpleMessage(
            "Connect with your nutritionist"),
        "professionalHeroConnectedTitle": MessageLookupByLibrary.simpleMessage(
            "Your patient-professional section"),
        "professionalHubKcalToday": m63,
        "professionalHubNoOfflineQueue":
            MessageLookupByLibrary.simpleMessage("No offline queue"),
        "professionalHubNoPublishedPlan": MessageLookupByLibrary.simpleMessage(
            "Connected with no published plan yet"),
        "professionalHubNoTodayTarget":
            MessageLookupByLibrary.simpleMessage("No target today"),
        "professionalHubPendingCount": m64,
        "professionalHubPlanDailyTargets":
            MessageLookupByLibrary.simpleMessage("Plan daily targets"),
        "professionalInviteCodeEyebrow":
            MessageLookupByLibrary.simpleMessage("Code"),
        "professionalInviteCodeLabel":
            MessageLookupByLibrary.simpleMessage("Invite code"),
        "professionalInviteExpired":
            MessageLookupByLibrary.simpleMessage("This invite has expired."),
        "professionalInviteNotFound": MessageLookupByLibrary.simpleMessage(
            "No pending invite was found for that code."),
        "professionalInvitePillClearPrivacy":
            MessageLookupByLibrary.simpleMessage("Clear privacy"),
        "professionalInvitePillConsent":
            MessageLookupByLibrary.simpleMessage("Consent"),
        "professionalInvitePillInvite":
            MessageLookupByLibrary.simpleMessage("Invite"),
        "professionalInvitePrivateActivation":
            MessageLookupByLibrary.simpleMessage("Private activation"),
        "professionalInviteReviewAction":
            MessageLookupByLibrary.simpleMessage("Review invite"),
        "professionalInviteReviewBeforeSharing":
            MessageLookupByLibrary.simpleMessage(
                "Enter the invite to review it before sharing anything."),
        "professionalInviteSectionBody": MessageLookupByLibrary.simpleMessage(
            "You need an invite and consent. You will get professional follow-up, plan, privacy, and access control without mixing it with Google Drive."),
        "professionalInviteSectionTitle": MessageLookupByLibrary.simpleMessage(
            "Activate the Nutritionist section"),
        "professionalMacroCalories":
            MessageLookupByLibrary.simpleMessage("Calories"),
        "professionalMacroCarbs": MessageLookupByLibrary.simpleMessage("Carbs"),
        "professionalMacroFat": MessageLookupByLibrary.simpleMessage("Fat"),
        "professionalMacroProtein":
            MessageLookupByLibrary.simpleMessage("Protein"),
        "professionalMessagesAuthorClientFull":
            MessageLookupByLibrary.simpleMessage("You (Client)"),
        "professionalMessagesAuthorClientShort":
            MessageLookupByLibrary.simpleMessage("You"),
        "professionalMessagesAuthorProfessionalFull":
            MessageLookupByLibrary.simpleMessage("Your professional"),
        "professionalMessagesAuthorProfessionalShort":
            MessageLookupByLibrary.simpleMessage("Professional"),
        "professionalMessagesChatThreadTitle":
            MessageLookupByLibrary.simpleMessage("Chat thread"),
        "professionalMessagesConversationEyebrow":
            MessageLookupByLibrary.simpleMessage("Conversation"),
        "professionalMessagesCopied":
            MessageLookupByLibrary.simpleMessage("Message copied to clipboard"),
        "professionalMessagesDisabled": MessageLookupByLibrary.simpleMessage(
            "Messaging exists, but it is disabled for this connection."),
        "professionalMessagesEmpty": MessageLookupByLibrary.simpleMessage(
            "There are no messages in this conversation yet."),
        "professionalMessagesFullMessage":
            MessageLookupByLibrary.simpleMessage("Full message"),
        "professionalMessagesGotIt":
            MessageLookupByLibrary.simpleMessage("Got it"),
        "professionalMessagesHeaderSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Chat and resolve questions with your nutritionist."),
        "professionalMessagesInputHint": MessageLookupByLibrary.simpleMessage(
            "Example: today I fell short on protein and want to adjust dinner"),
        "professionalMessagesMarkRead":
            MessageLookupByLibrary.simpleMessage("Mark read"),
        "professionalMessagesNewEyebrow":
            MessageLookupByLibrary.simpleMessage("New message"),
        "professionalMessagesSend":
            MessageLookupByLibrary.simpleMessage("Send"),
        "professionalMessagesTabWithCount": m65,
        "professionalMessagesThreadSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Unread professional messages are marked read when tapped."),
        "professionalMessagesUnavailableBody": MessageLookupByLibrary.simpleMessage(
            "The client shell is ready, but async messaging backend support is not available in this version yet."),
        "professionalMessagesUnavailableHint": MessageLookupByLibrary.simpleMessage(
            "For now, you will receive plan changes and follow-up from the rest of this section."),
        "professionalMessagesWriteSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Keep it brief and actionable."),
        "professionalMessagesWriteTitle":
            MessageLookupByLibrary.simpleMessage("Write to your professional"),
        "professionalNever": MessageLookupByLibrary.simpleMessage("Never"),
        "professionalNotesCategoryAssessment":
            MessageLookupByLibrary.simpleMessage("Assessment"),
        "professionalNotesCategoryBilling":
            MessageLookupByLibrary.simpleMessage("Billing"),
        "professionalNotesCategoryGeneral":
            MessageLookupByLibrary.simpleMessage("General"),
        "professionalNotesCategoryMedical":
            MessageLookupByLibrary.simpleMessage("Medical"),
        "professionalNotesCategoryOther":
            MessageLookupByLibrary.simpleMessage("Other"),
        "professionalNotesCategoryProgress":
            MessageLookupByLibrary.simpleMessage("Progress"),
        "professionalNotesEmptyBody": MessageLookupByLibrary.simpleMessage(
            "Your nutritionist has not written any notes."),
        "professionalNotesEmptyTitle":
            MessageLookupByLibrary.simpleMessage("No notes yet"),
        "professionalNotesFallbackTitle":
            MessageLookupByLibrary.simpleMessage("Note"),
        "professionalNotesHeaderSubtitle": MessageLookupByLibrary.simpleMessage(
            "Recommendations and observations shared by your professional."),
        "professionalNotesHeaderTitle":
            MessageLookupByLibrary.simpleMessage("Nutritionist Notes"),
        "professionalOpeningGoogle":
            MessageLookupByLibrary.simpleMessage("Opening Google"),
        "professionalPlanActiveEyebrow":
            MessageLookupByLibrary.simpleMessage("Active plan"),
        "professionalPlanAdherence":
            MessageLookupByLibrary.simpleMessage("Adherence"),
        "professionalPlanDaysLabel":
            MessageLookupByLibrary.simpleMessage("Days"),
        "professionalPlanDefaultObjective": MessageLookupByLibrary.simpleMessage(
            "Your professional prepared this structure to guide your week."),
        "professionalPlanEquivalentSubstitutes":
            MessageLookupByLibrary.simpleMessage("Equivalent substitutes"),
        "professionalPlanEquivalentSubstitutesSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Portions scaled to match the exact target macronutrients of this meal."),
        "professionalPlanLogMeal":
            MessageLookupByLibrary.simpleMessage("Log meal"),
        "professionalPlanLogSuggestedMealBody": m66,
        "professionalPlanLogSuggestedMealError":
            MessageLookupByLibrary.simpleMessage("Could not log the meal."),
        "professionalPlanLogSuggestedMealSuccess": m67,
        "professionalPlanLogSuggestedMealTitle":
            MessageLookupByLibrary.simpleMessage("Log suggested meal?"),
        "professionalPlanLogToDiary":
            MessageLookupByLibrary.simpleMessage("Log to Diary"),
        "professionalPlanLogToTodaysDiary":
            MessageLookupByLibrary.simpleMessage("Log to today\'s Diary"),
        "professionalPlanMacroEnergySplit":
            MessageLookupByLibrary.simpleMessage("Macronutrient energy split"),
        "professionalPlanMealGuideEyebrow":
            MessageLookupByLibrary.simpleMessage("Meal guide"),
        "professionalPlanMealGuideSubtitle": MessageLookupByLibrary.simpleMessage(
            "Tap a meal to view its macronutrient breakdown, or use \"+\" to add it to today\'s diary."),
        "professionalPlanMealsLabel":
            MessageLookupByLibrary.simpleMessage("Meals"),
        "professionalPlanNoSuggestedMeals":
            MessageLookupByLibrary.simpleMessage("No suggested meals"),
        "professionalPlanNutritionistGuidelines":
            MessageLookupByLibrary.simpleMessage("Nutritionist guidelines"),
        "professionalPlanOnTarget":
            MessageLookupByLibrary.simpleMessage("On target"),
        "professionalPlanOverPlan":
            MessageLookupByLibrary.simpleMessage("Over plan"),
        "professionalPlanRecipeCook":
            MessageLookupByLibrary.simpleMessage("Cook"),
        "professionalPlanRecipeDetails":
            MessageLookupByLibrary.simpleMessage("Recipe details"),
        "professionalPlanRecipeIngredients":
            MessageLookupByLibrary.simpleMessage("Ingredients"),
        "professionalPlanRecipeInstructions":
            MessageLookupByLibrary.simpleMessage("Instructions"),
        "professionalPlanRecipeLoadError": m68,
        "professionalPlanRecipeLoadUnavailable":
            MessageLookupByLibrary.simpleMessage("Could not load recipe."),
        "professionalPlanRecipeNoIngredients":
            MessageLookupByLibrary.simpleMessage("No ingredients specified"),
        "professionalPlanRecipeNoInstructions":
            MessageLookupByLibrary.simpleMessage("No instructions"),
        "professionalPlanRecipePrep":
            MessageLookupByLibrary.simpleMessage("Prep"),
        "professionalPlanRecipeServings":
            MessageLookupByLibrary.simpleMessage("Servings"),
        "professionalPlanRemaining":
            MessageLookupByLibrary.simpleMessage("Left"),
        "professionalPlanSlotBreakfast":
            MessageLookupByLibrary.simpleMessage("Breakfast"),
        "professionalPlanSlotDinner":
            MessageLookupByLibrary.simpleMessage("Dinner"),
        "professionalPlanSlotLunch":
            MessageLookupByLibrary.simpleMessage("Lunch"),
        "professionalPlanSlotSnack":
            MessageLookupByLibrary.simpleMessage("Snack"),
        "professionalPlanSpecificTarget":
            MessageLookupByLibrary.simpleMessage("Specific target"),
        "professionalPlanStatusExact": MessageLookupByLibrary.simpleMessage(
            "You are exactly on today\'s target."),
        "professionalPlanStatusLeft": m69,
        "professionalPlanStatusOver": m70,
        "professionalPlanSuggestedMeals":
            MessageLookupByLibrary.simpleMessage("Suggested meals"),
        "professionalPlanSuggestedPlanMeal":
            MessageLookupByLibrary.simpleMessage("Suggested plan meal"),
        "professionalPlanTemplateDays":
            MessageLookupByLibrary.simpleMessage("Template days"),
        "professionalPlanUpdated":
            MessageLookupByLibrary.simpleMessage("Updated"),
        "professionalPlanUpdatedLabel":
            MessageLookupByLibrary.simpleMessage("Updated"),
        "professionalPlanViewPlan":
            MessageLookupByLibrary.simpleMessage("View plan"),
        "professionalPlanViewRecipe":
            MessageLookupByLibrary.simpleMessage("View recipe"),
        "professionalPlanVsActual":
            MessageLookupByLibrary.simpleMessage("Plan vs actual"),
        "professionalPlanWeeklyView":
            MessageLookupByLibrary.simpleMessage("Weekly view"),
        "professionalPlanWeeklyViewSubtitle": MessageLookupByLibrary.simpleMessage(
            "Tap a day to view its detailed calorie breakdown and log its meals."),
        "professionalPrivacyAccessControl":
            MessageLookupByLibrary.simpleMessage("Access control"),
        "professionalPrivacyAccessControlBody":
            MessageLookupByLibrary.simpleMessage(
                "If you revoke access, this section disappears and the professional stops receiving new snapshots."),
        "professionalPrivacyAccessEyebrow":
            MessageLookupByLibrary.simpleMessage("Access"),
        "professionalPrivacyAccessLevelEyebrow":
            MessageLookupByLibrary.simpleMessage("Access level"),
        "professionalPrivacyAggregateDailyAdherence":
            MessageLookupByLibrary.simpleMessage("aggregate daily adherence"),
        "professionalPrivacyAggregateModeBody":
            MessageLookupByLibrary.simpleMessage(
                "Your professional only sees your daily summaries (total calories and macronutrients). They cannot see the details of your meals, individual ingredients, or the specific foods you log in your diary."),
        "professionalPrivacyAggregateOnly":
            MessageLookupByLibrary.simpleMessage("Aggregate only"),
        "professionalPrivacyAggregateTargets":
            MessageLookupByLibrary.simpleMessage(
                "goal vs actual kcal and macros in aggregate form"),
        "professionalPrivacyAggregateTrackedDaysMeals":
            MessageLookupByLibrary.simpleMessage(
                "tracked days and number of logged meals"),
        "professionalPrivacyConsentSince": m71,
        "professionalPrivacyControlEyebrow":
            MessageLookupByLibrary.simpleMessage("Privacy control"),
        "professionalPrivacyCurrentLevel":
            MessageLookupByLibrary.simpleMessage("Current shared data level"),
        "professionalPrivacyCurrentLevelSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "This section describes the real level of data being shared right now, without promising more than what is active."),
        "professionalPrivacyDetailed":
            MessageLookupByLibrary.simpleMessage("Detailed"),
        "professionalPrivacyDetailedModeBody": MessageLookupByLibrary.simpleMessage(
            "Your professional has access to the full details of your diary: they can see exactly what foods you log, their ingredients, quantities, and in which meal (breakfast, lunch, dinner, etc.) you consumed them."),
        "professionalPrivacyHeaderSubtitle": MessageLookupByLibrary.simpleMessage(
            "Control what information you share with your nutrition professional and manage their access level."),
        "professionalPrivacyNextAvailable":
            MessageLookupByLibrary.simpleMessage("Next available level"),
        "professionalPrivacyNotSharedYet":
            MessageLookupByLibrary.simpleMessage("Not shared today"),
        "professionalPrivacyPerMealDetail":
            MessageLookupByLibrary.simpleMessage(
                "full per-meal or slot detail"),
        "professionalPrivacyPerMealDetailWhenReady":
            MessageLookupByLibrary.simpleMessage(
                "per-meal detail when backend, legal copy, and consent are ready"),
        "professionalPrivacyRawDiary":
            MessageLookupByLibrary.simpleMessage("your full raw diary"),
        "professionalPrivacyRealtimeMessages":
            MessageLookupByLibrary.simpleMessage(
                "real-time bidirectional messaging"),
        "professionalPrivacySharedNow":
            MessageLookupByLibrary.simpleMessage("Shared today"),
        "professionalPrivacySharingModeSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Aggregate keeps targets, adherence, snapshots, and messaging. Detailed also unlocks your raw diary for this professional until you change it again."),
        "professionalPrivacySharingModeTitle":
            MessageLookupByLibrary.simpleMessage(
                "Choose between aggregate-only or detailed diary sharing"),
        "professionalProtectAccountAction":
            MessageLookupByLibrary.simpleMessage("Link Google"),
        "professionalProtectAccountBody": MessageLookupByLibrary.simpleMessage(
            "To connect with a nutritionist, protect your cloud account with Google first. This keeps your account recoverable and preserves consent if you change phones. This does not enable Google Drive."),
        "professionalProtectAccountOpenError":
            MessageLookupByLibrary.simpleMessage("Could not open Google."),
        "professionalProtectAccountReturnHint":
            MessageLookupByLibrary.simpleMessage(
                "Complete Google and return to accept the invite."),
        "professionalProtectAccountTitle":
            MessageLookupByLibrary.simpleMessage("Protect your account"),
        "professionalRecipesDecline":
            MessageLookupByLibrary.simpleMessage("Decline"),
        "professionalRecipesDeclined":
            MessageLookupByLibrary.simpleMessage("Declined"),
        "professionalRecipesEmptyBody": MessageLookupByLibrary.simpleMessage(
            "Your nutritionist will send you recipes here."),
        "professionalRecipesEmptyTitle":
            MessageLookupByLibrary.simpleMessage("No recipe proposals yet"),
        "professionalRecipesHeaderSubtitle": MessageLookupByLibrary.simpleMessage(
            "Recipes recommended by your nutritionist. Save the ones you like to your cookbook."),
        "professionalRecipesHeaderTitle":
            MessageLookupByLibrary.simpleMessage("Recipe Proposals"),
        "professionalRecipesRecipeFallback":
            MessageLookupByLibrary.simpleMessage("Recipe"),
        "professionalRecipesSaveToMine":
            MessageLookupByLibrary.simpleMessage("Save to my recipes"),
        "professionalRecipesUpdateError": m72,
        "professionalRevokeNow":
            MessageLookupByLibrary.simpleMessage("Revoke access now"),
        "professionalScreenTitle":
            MessageLookupByLibrary.simpleMessage("Nutritionist"),
        "professionalSectionConnectSubtitle": MessageLookupByLibrary.simpleMessage(
            "Activate this section with an invite and consent. Here you will see plan, follow-up, privacy, and messages."),
        "professionalSectionConnectedSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "This is where you control your plan, real follow-up, shared privacy, and professional notes."),
        "professionalSectionLoadErrorTitle":
            MessageLookupByLibrary.simpleMessage(
                "Could not load the full section"),
        "professionalSectionRetryHint":
            MessageLookupByLibrary.simpleMessage("Try refreshing again."),
        "professionalSharingAggregateEnabled":
            MessageLookupByLibrary.simpleMessage(
                "Switched back to aggregate-only sharing."),
        "professionalSharingDetailedEnabled":
            MessageLookupByLibrary.simpleMessage(
                "Detailed diary enabled successfully."),
        "professionalSharingModeGenericError": MessageLookupByLibrary.simpleMessage(
            "Could not change the privacy level for this relationship. Try again in a few seconds."),
        "professionalSharingModeNotPersistedError":
            MessageLookupByLibrary.simpleMessage(
                "The change was not persisted on the server. Close and reopen this section before trying again."),
        "professionalSharingModeOfflineError": MessageLookupByLibrary.simpleMessage(
            "Could not change the privacy level because the device is offline. Try again when the phone has network access."),
        "professionalSharingModePermissionError":
            MessageLookupByLibrary.simpleMessage(
                "Could not update the permission with this professional. The relationship may have been revoked or the backend is still blocking this change."),
        "professionalSharingModeSessionError": MessageLookupByLibrary.simpleMessage(
            "Your cloud session is no longer valid for changing this permission. Sign in again and try once more."),
        "professionalSharingPendingSnapshots": m73,
        "professionalStatusActive":
            MessageLookupByLibrary.simpleMessage("Active"),
        "professionalStatusConnected":
            MessageLookupByLibrary.simpleMessage("Connected"),
        "professionalStatusInviteOnly":
            MessageLookupByLibrary.simpleMessage("Invite only"),
        "professionalSummaryActivePlan":
            MessageLookupByLibrary.simpleMessage("Active plan"),
        "professionalSummaryCalorieProgressBody":
            MessageLookupByLibrary.simpleMessage(
                "Daily progress compared to targets assigned by your nutritionist."),
        "professionalSummaryConnectionStatus":
            MessageLookupByLibrary.simpleMessage("Connection status"),
        "professionalSummaryDailyContextHint":
            MessageLookupByLibrary.simpleMessage("Write your note here..."),
        "professionalSummaryDailyContextSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Share details of your day (energy, digestion, events) with your nutritionist."),
        "professionalSummaryDailyContextTitle":
            MessageLookupByLibrary.simpleMessage("Daily context note"),
        "professionalSummaryLastPlanUpdate":
            MessageLookupByLibrary.simpleMessage("Last plan update"),
        "professionalSummaryLastSnapshot":
            MessageLookupByLibrary.simpleMessage("Last snapshot sent"),
        "professionalSummaryNoPlan":
            MessageLookupByLibrary.simpleMessage("No plan"),
        "professionalSummaryNoPublishedPlan":
            MessageLookupByLibrary.simpleMessage("No published plan"),
        "professionalSummaryNoteSavedError":
            MessageLookupByLibrary.simpleMessage(
                "Error saving note. Please check your connection."),
        "professionalSummaryNoteSavedSuccess":
            MessageLookupByLibrary.simpleMessage(
                "Note saved and sent to your nutritionist!"),
        "professionalSummaryNoteSent":
            MessageLookupByLibrary.simpleMessage("Sent!"),
        "professionalSummaryOfflineQueue":
            MessageLookupByLibrary.simpleMessage("Offline queue"),
        "professionalSummaryOperationsEyebrow":
            MessageLookupByLibrary.simpleMessage("Operations"),
        "professionalSummaryOperationsSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Active plan, today target, and sync status."),
        "professionalSummaryPending":
            MessageLookupByLibrary.simpleMessage("Pending"),
        "professionalSummaryRemainingKcal":
            MessageLookupByLibrary.simpleMessage("Remaining kcal"),
        "professionalSummarySaveNote":
            MessageLookupByLibrary.simpleMessage("Save note"),
        "professionalSummarySavingNote":
            MessageLookupByLibrary.simpleMessage("Saving..."),
        "professionalSummarySubtext": MessageLookupByLibrary.simpleMessage(
            "Your nutritionist automatically receives your daily macros and context notes."),
        "professionalSummarySyncedAt": m74,
        "professionalSummaryTargetExceeded":
            MessageLookupByLibrary.simpleMessage("Target exceeded"),
        "professionalSummaryTodayPlanVsReality":
            MessageLookupByLibrary.simpleMessage("Today plan vs reality"),
        "professionalSummaryTodayTarget":
            MessageLookupByLibrary.simpleMessage("Today target"),
        "professionalSummaryUndo": MessageLookupByLibrary.simpleMessage("Undo"),
        "professionalTabCheckin":
            MessageLookupByLibrary.simpleMessage("Check-in"),
        "professionalTabMessages":
            MessageLookupByLibrary.simpleMessage("Messages"),
        "professionalTabNotes": MessageLookupByLibrary.simpleMessage("Notes"),
        "professionalTabPlan": MessageLookupByLibrary.simpleMessage("Plan"),
        "professionalTabPrivacy":
            MessageLookupByLibrary.simpleMessage("Privacy"),
        "professionalTabRecipes":
            MessageLookupByLibrary.simpleMessage("Recipes"),
        "professionalTabSummary":
            MessageLookupByLibrary.simpleMessage("Summary"),
        "professionalTabTracking":
            MessageLookupByLibrary.simpleMessage("Tracking"),
        "professionalTrackingAdherenceHistory":
            MessageLookupByLibrary.simpleMessage("Adherence history"),
        "professionalTrackingConsumed":
            MessageLookupByLibrary.simpleMessage("Consumed"),
        "professionalTrackingDailyEyebrow":
            MessageLookupByLibrary.simpleMessage("Daily follow-up"),
        "professionalTrackingDailySubtitle": MessageLookupByLibrary.simpleMessage(
            "Quick adherence read so you know how the day is going against the plan."),
        "professionalTrackingEstimatedAdherence": m75,
        "professionalTrackingExceeded":
            MessageLookupByLibrary.simpleMessage("Exceeded"),
        "professionalTrackingFollowUpDays":
            MessageLookupByLibrary.simpleMessage("Tracked days"),
        "professionalTrackingMealsLogged":
            MessageLookupByLibrary.simpleMessage("Meals logged"),
        "professionalTrackingMealsLoggedCount": m76,
        "professionalTrackingOnTarget":
            MessageLookupByLibrary.simpleMessage("On target"),
        "professionalTrackingPlanTarget":
            MessageLookupByLibrary.simpleMessage("Plan target"),
        "professionalTrackingTapBarHint":
            MessageLookupByLibrary.simpleMessage("Tap a column to view detail"),
        "professionalTrackingTodayKcalTarget": m77,
        "professionalTrackingTodayTitle":
            MessageLookupByLibrary.simpleMessage("Today follow-up"),
        "professionalTrackingTrackedDays":
            MessageLookupByLibrary.simpleMessage("Tracked days"),
        "professionalTrackingVsTarget": m78,
        "professionalTrackingWeekKcal":
            MessageLookupByLibrary.simpleMessage("Week kcal"),
        "professionalTrackingWeekTitle": MessageLookupByLibrary.simpleMessage(
            "Current week: plan vs reality"),
        "professionalTrackingWeeklyCalories":
            MessageLookupByLibrary.simpleMessage("Weekly Calories"),
        "professionalTrackingWeeklyCaloriesVsTarget":
            MessageLookupByLibrary.simpleMessage("Weekly calories vs target"),
        "professionalTrackingWeeklyChartSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Daily visual comparison of calories consumed vs nutritionist targets."),
        "professionalTrackingWeeklyEyebrow":
            MessageLookupByLibrary.simpleMessage("Weekly perspective"),
        "professionalTrackingWeeklySubtitle": MessageLookupByLibrary.simpleMessage(
            "This shows whether the week keeps its direction, not only whether a single day was perfect."),
        "professionalTrackingWeeklyTotal": m79,
        "professionalWeekNoTarget":
            MessageLookupByLibrary.simpleMessage("No target"),
        "professionalWeekTemplate":
            MessageLookupByLibrary.simpleMessage("template"),
        "professionalWeekdayFriday":
            MessageLookupByLibrary.simpleMessage("Friday"),
        "professionalWeekdayInitialFriday":
            MessageLookupByLibrary.simpleMessage("F"),
        "professionalWeekdayInitialMonday":
            MessageLookupByLibrary.simpleMessage("M"),
        "professionalWeekdayInitialSaturday":
            MessageLookupByLibrary.simpleMessage("S"),
        "professionalWeekdayInitialSunday":
            MessageLookupByLibrary.simpleMessage("S"),
        "professionalWeekdayInitialThursday":
            MessageLookupByLibrary.simpleMessage("T"),
        "professionalWeekdayInitialTuesday":
            MessageLookupByLibrary.simpleMessage("T"),
        "professionalWeekdayInitialWednesday":
            MessageLookupByLibrary.simpleMessage("W"),
        "professionalWeekdayMonday":
            MessageLookupByLibrary.simpleMessage("Monday"),
        "professionalWeekdaySaturday":
            MessageLookupByLibrary.simpleMessage("Saturday"),
        "professionalWeekdaySunday":
            MessageLookupByLibrary.simpleMessage("Sunday"),
        "professionalWeekdayThursday":
            MessageLookupByLibrary.simpleMessage("Thursday"),
        "professionalWeekdayTuesday":
            MessageLookupByLibrary.simpleMessage("Tuesday"),
        "professionalWeekdayWednesday":
            MessageLookupByLibrary.simpleMessage("Wednesday"),
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
        "profileCurrentPhase": m80,
        "profileDailyStepsGoalBody": MessageLookupByLibrary.simpleMessage(
            "Set your daily steps goal. If left empty, the default value based on the day will be used."),
        "profileDailyStepsGoalTitle":
            MessageLookupByLibrary.simpleMessage("Daily steps goal"),
        "profileDailyWaterGoalBody": m81,
        "profileDailyWaterGoalTitle":
            MessageLookupByLibrary.simpleMessage("Daily water goal"),
        "profileDefaultTarget": MessageLookupByLibrary.simpleMessage("Default"),
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
        "profileReviewAction": MessageLookupByLibrary.simpleMessage("Review"),
        "profileSleepGoal":
            MessageLookupByLibrary.simpleMessage("Sleep hours goal"),
        "profileSleepHoursExampleHint":
            MessageLookupByLibrary.simpleMessage("e.g. 8.0"),
        "profileSleepHoursGoalBody": MessageLookupByLibrary.simpleMessage(
            "Set your daily sleep hours goal. If left empty, the default value based on the day will be used."),
        "profileSleepHoursGoalTitle":
            MessageLookupByLibrary.simpleMessage("Sleep hours goal"),
        "profileSleepHoursTargetLabel":
            MessageLookupByLibrary.simpleMessage("Sleep hours target"),
        "profileSportsProfile":
            MessageLookupByLibrary.simpleMessage("Sports profile"),
        "profileStepsExampleHint":
            MessageLookupByLibrary.simpleMessage("e.g. 10000"),
        "profileStepsGoal": MessageLookupByLibrary.simpleMessage("Steps goal"),
        "profileStepsTargetLabel":
            MessageLookupByLibrary.simpleMessage("Steps target"),
        "profileTargetsRecalculatedSnack": MessageLookupByLibrary.simpleMessage(
            "Targets recalculated. You can review the strategy."),
        "profileWaterExampleHintImperial":
            MessageLookupByLibrary.simpleMessage("e.g. 100"),
        "profileWaterExampleHintMetric":
            MessageLookupByLibrary.simpleMessage("e.g. 3.0"),
        "profileWaterGoal": MessageLookupByLibrary.simpleMessage("Water goal"),
        "profileWaterTargetLabel": m82,
        "profileYourProfile":
            MessageLookupByLibrary.simpleMessage("Your profile"),
        "profileYourProfileSubtitle": MessageLookupByLibrary.simpleMessage(
            "Adjust your base data so that calories, macros and recommendations are consistent."),
        "proteinLabel": MessageLookupByLibrary.simpleMessage("protein"),
        "quantityLabel": MessageLookupByLibrary.simpleMessage("Quantity"),
        "quickCategoryLeanMeal":
            MessageLookupByLibrary.simpleMessage("Light meal"),
        "quickCategoryPostWorkout":
            MessageLookupByLibrary.simpleMessage("Post-workout"),
        "quickCategoryPreWorkout":
            MessageLookupByLibrary.simpleMessage("Pre-workout"),
        "quickCategoryShake": MessageLookupByLibrary.simpleMessage("Shake"),
        "quickMealsAddedTo": m83,
        "quickMealsEmptyAll": MessageLookupByLibrary.simpleMessage(
            "Save meals as recipes to keep them one tap away here."),
        "quickMealsEmptyFiltered": MessageLookupByLibrary.simpleMessage(
            "No quick meals in this lane yet. Use clear workout-style names so they are easier to recognize later."),
        "quickMealsFilterAll": MessageLookupByLibrary.simpleMessage("All"),
        "quickMealsFilterLight":
            MessageLookupByLibrary.simpleMessage("Light meal"),
        "quickMealsFilterPostWorkout":
            MessageLookupByLibrary.simpleMessage("After workout"),
        "quickMealsFilterPreWorkout":
            MessageLookupByLibrary.simpleMessage("Before workout"),
        "quickMealsFilterShake": MessageLookupByLibrary.simpleMessage("Shake"),
        "quickMealsLogServing":
            MessageLookupByLibrary.simpleMessage("Log one serving"),
        "quickMealsMacrosSummary": m84,
        "quickMealsProteinShort": m85,
        "quickMealsSavedTooltip":
            MessageLookupByLibrary.simpleMessage("Open saved meals"),
        "quickMealsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Use your saved recipes first. One tap logs a serving fast."),
        "quickMealsTitle": MessageLookupByLibrary.simpleMessage("Quick meals"),
        "readLabel": MessageLookupByLibrary.simpleMessage(
            "I have read and accept the privacy policy."),
        "recentlyAddedLabel": MessageLookupByLibrary.simpleMessage("Recently"),
        "recipeDetailCoachRecommendation":
            MessageLookupByLibrary.simpleMessage("Coach recommendation"),
        "recipeDetailCustomizeRecipe":
            MessageLookupByLibrary.simpleMessage("Customize recipe"),
        "recipeDetailEditRecipe":
            MessageLookupByLibrary.simpleMessage("Edit recipe"),
        "recipeDetailIngredientFallback":
            MessageLookupByLibrary.simpleMessage("Ingredient"),
        "recipeDetailNoDetailedIngredients":
            MessageLookupByLibrary.simpleMessage(
                "No detailed ingredients for this recipe."),
        "recipeDetailRecipeNotes":
            MessageLookupByLibrary.simpleMessage("Recipe notes"),
        "recipeDetailServing": m86,
        "recipeDetailServingUnitPlural":
            MessageLookupByLibrary.simpleMessage("servings"),
        "recipeDetailServingUnitSingular":
            MessageLookupByLibrary.simpleMessage("serving"),
        "recipeDetailSuggestedIntake": m87,
        "recipeEditorChangeFood":
            MessageLookupByLibrary.simpleMessage("Change food"),
        "recipeEditorDuplicate":
            MessageLookupByLibrary.simpleMessage("Duplicate"),
        "recipeEditorIngredientsEmpty": MessageLookupByLibrary.simpleMessage(
            "Add foods to adjust this recipe."),
        "recipeEditorInvalidRecipe": MessageLookupByLibrary.simpleMessage(
            "Check name, servings, and ingredients."),
        "recipeEditorLocalCacheResults":
            MessageLookupByLibrary.simpleMessage("Local cache results"),
        "recipeEditorNutritionSummary":
            MessageLookupByLibrary.simpleMessage("Nutrition summary"),
        "recipeEditorPerServingSummary": m88,
        "recipeEditorSaveRecipe":
            MessageLookupByLibrary.simpleMessage("Save recipe"),
        "recipeEditorSearchPrompt": MessageLookupByLibrary.simpleMessage(
            "Search for a food to add it to the recipe."),
        "recipeEditorSearchUnavailable": MessageLookupByLibrary.simpleMessage(
            "Search is unavailable right now. Check the connection and try again."),
        "recipeEditorServingsHelper": MessageLookupByLibrary.simpleMessage(
            "Default serving amount when logging this recipe."),
        "recipeLibraryActions": MessageLookupByLibrary.simpleMessage("Actions"),
        "recipeLibraryAddedSnackbar": m89,
        "recipeLibraryAllFilter": MessageLookupByLibrary.simpleMessage("All"),
        "recipeLibraryEdit": MessageLookupByLibrary.simpleMessage("Edit"),
        "recipeLibraryEmpty": MessageLookupByLibrary.simpleMessage(
            "No saved meals yet.\nSave meals as recipes to reuse them."),
        "recipeLibraryFavorite": MessageLookupByLibrary.simpleMessage("Saved"),
        "recipeLibraryFrequentSectionSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Detected from your history so you can repeat them faster."),
        "recipeLibraryFrequentSectionTitle":
            MessageLookupByLibrary.simpleMessage("Repeated suggestions"),
        "recipeLibraryFrequentUses": m90,
        "recipeLibraryImportFromWeb":
            MessageLookupByLibrary.simpleMessage("Import from web"),
        "recipeLibraryIngredientsCount": m91,
        "recipeLibraryIntro": MessageLookupByLibrary.simpleMessage(
            "One library, two sources: meals you save manually and repeated meals detected automatically."),
        "recipeLibraryIntroCard": MessageLookupByLibrary.simpleMessage(
            "Filter by real category, pin key recipes, and edit them directly from the library."),
        "recipeLibraryManualSectionSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "You save these on purpose to reuse them whenever you want."),
        "recipeLibraryManualSectionTitle":
            MessageLookupByLibrary.simpleMessage("Saved recipes"),
        "recipeLibraryMarkFavorite":
            MessageLookupByLibrary.simpleMessage("Save"),
        "recipeLibraryPin": MessageLookupByLibrary.simpleMessage("Pin"),
        "recipeLibraryPinned": MessageLookupByLibrary.simpleMessage("Pinned"),
        "recipeLibraryRemoveFavorite":
            MessageLookupByLibrary.simpleMessage("Remove saved"),
        "recipeLibrarySearchHint":
            MessageLookupByLibrary.simpleMessage("Search saved meals"),
        "recipeLibraryServingsCount": m92,
        "recipeLibraryTitle":
            MessageLookupByLibrary.simpleMessage("Saved meals"),
        "recipeLibraryUnpin": MessageLookupByLibrary.simpleMessage("Unpin"),
        "recipeLibraryUses": m93,
        "recipeQuickCategoryLabel":
            MessageLookupByLibrary.simpleMessage("Quick category"),
        "recipeSavedSnackbar":
            MessageLookupByLibrary.simpleMessage("Recipe saved"),
        "recipeScraperInvalidUrl":
            MessageLookupByLibrary.simpleMessage("Please enter a valid URL."),
        "recipeScraperLoading": MessageLookupByLibrary.simpleMessage(
            "Extracting recipe with AI..."),
        "recipeScraperSubtitle": MessageLookupByLibrary.simpleMessage(
            "Paste a link to a cooking blog or recipe and the AI will extract it automatically."),
        "recipeScraperTitle":
            MessageLookupByLibrary.simpleMessage("Import recipe with AI"),
        "recipeScraperUrlHint":
            MessageLookupByLibrary.simpleMessage("https://..."),
        "recipeScraperUrlLabel":
            MessageLookupByLibrary.simpleMessage("Recipe URL"),
        "recipeScraperUrlSchemeError": MessageLookupByLibrary.simpleMessage(
            "URL must start with http:// or https://"),
        "reportErrorDialogText": MessageLookupByLibrary.simpleMessage(
            "Do you want to report an error to the developer?"),
        "retryLabel": MessageLookupByLibrary.simpleMessage("Retry"),
        "saturatedFatLabel":
            MessageLookupByLibrary.simpleMessage("saturated fat"),
        "scanProductLabel":
            MessageLookupByLibrary.simpleMessage("Scan Product"),
        "scannerBarcodeExampleHint":
            MessageLookupByLibrary.simpleMessage("e.g. 8410012345678"),
        "scannerBarcodeNumberLabel":
            MessageLookupByLibrary.simpleMessage("Barcode number"),
        "scannerBarcodeValue": m94,
        "scannerCreateFoodManually":
            MessageLookupByLibrary.simpleMessage("Create food manually"),
        "scannerEnterCodeTooltip":
            MessageLookupByLibrary.simpleMessage("Enter code"),
        "scannerErrorTitle": MessageLookupByLibrary.simpleMessage("Error"),
        "scannerManualBarcodeTitle":
            MessageLookupByLibrary.simpleMessage("Enter barcode"),
        "scannerNotFoundTitle":
            MessageLookupByLibrary.simpleMessage("Not found"),
        "scannerRetryScanning":
            MessageLookupByLibrary.simpleMessage("Retry scanning"),
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
        "sendAnonymousUserData": MessageLookupByLibrary.simpleMessage(
            "Send anonymous crash and diagnostic reports"),
        "servingLabel": MessageLookupByLibrary.simpleMessage("Serving"),
        "servingSizeLabelImperial":
            MessageLookupByLibrary.simpleMessage("Serving size (oz/fl oz)"),
        "servingSizeLabelMetric":
            MessageLookupByLibrary.simpleMessage("Serving size (g/ml)"),
        "servingsLabel": MessageLookupByLibrary.simpleMessage("Servings"),
        "settingAboutLabel": MessageLookupByLibrary.simpleMessage("About"),
        "settingFeedbackLabel":
            MessageLookupByLibrary.simpleMessage("Feedback"),
        "settingsAboutModelLabel":
            MessageLookupByLibrary.simpleMessage("Model"),
        "settingsAboutModelValue": MessageLookupByLibrary.simpleMessage(
            "Local-first app with optional sync and AI-assisted meal interpretation."),
        "settingsAboutProjectLabel":
            MessageLookupByLibrary.simpleMessage("Project"),
        "settingsAboutProjectValue": MessageLookupByLibrary.simpleMessage(
            "Calorie, macro, habit, activity, and local/Drive backup tracking."),
        "settingsAccountAlreadyRegisteredBody":
            MessageLookupByLibrary.simpleMessage(
                "This Google account is already linked to another user. Do you want to sign in with it on this device to recover your professional plan and cloud status?"),
        "settingsAccountAlreadyRegisteredConfirm":
            MessageLookupByLibrary.simpleMessage("Sign in"),
        "settingsAccountAlreadyRegisteredTitle":
            MessageLookupByLibrary.simpleMessage("Account Already Registered"),
        "settingsAccountBackupsSection":
            MessageLookupByLibrary.simpleMessage("Account and backups"),
        "settingsAccountDeletedMessage": MessageLookupByLibrary.simpleMessage(
            "Cloud account and device data deleted."),
        "settingsAccountProtectedStatus":
            MessageLookupByLibrary.simpleMessage("Protected"),
        "settingsActivatePremium": MessageLookupByLibrary.simpleMessage(
            "Activate MacroTracker Premium"),
        "settingsActiveStatus": MessageLookupByLibrary.simpleMessage("Active"),
        "settingsAiCallsPhoto": m95,
        "settingsAiCallsText": m96,
        "settingsAiCallsTotal": m97,
        "settingsAiCostDescription": MessageLookupByLibrary.simpleMessage(
            "Based on real token usage per backend request."),
        "settingsAiCostLabel": MessageLookupByLibrary.simpleMessage("AI Cost"),
        "settingsAiCostMonth": m98,
        "settingsAiCostToday": m99,
        "settingsAiCostTotal": m100,
        "settingsAnonymousDataSubtitle": MessageLookupByLibrary.simpleMessage(
            "You can turn this on or off at any time."),
        "settingsAppSection": MessageLookupByLibrary.simpleMessage("App"),
        "settingsAppearanceSection":
            MessageLookupByLibrary.simpleMessage("Appearance"),
        "settingsCalculationGramsKgMode": MessageLookupByLibrary.simpleMessage(
            "Grams per kg distribution (g/kg)"),
        "settingsCalculationPercentageMode":
            MessageLookupByLibrary.simpleMessage("Percentage distribution (%)"),
        "settingsCalculationsLabel":
            MessageLookupByLibrary.simpleMessage("Calculations"),
        "settingsCloudIdentityFallback": MessageLookupByLibrary.simpleMessage(
            "Identity for recovery and nutritionist connections"),
        "settingsCopyReferralTooltip":
            MessageLookupByLibrary.simpleMessage("Copy"),
        "settingsDailyDriveBackup":
            MessageLookupByLibrary.simpleMessage("Daily Drive"),
        "settingsDeleteCloudAccountSubtitle": MessageLookupByLibrary.simpleMessage(
            "Permanently deletes your profile, local logs, and linked cloud data."),
        "settingsDeleteCloudAccountTitle": MessageLookupByLibrary.simpleMessage(
            "Delete cloud account and data"),
        "settingsDeleteConfirmBody": MessageLookupByLibrary.simpleMessage(
            "This action is irreversible. MacroTracker will first delete your current cloud account and its linked remote data. Only after that succeeds will it erase the local data on this device."),
        "settingsDeleteConfirmFailureGuard": MessageLookupByLibrary.simpleMessage(
            "If cloud deletion fails, MacroTracker will not show the account as deleted and your local device data will be kept."),
        "settingsDeleteConfirmTitle": MessageLookupByLibrary.simpleMessage(
            "Delete cloud account and data?"),
        "settingsDeleteConfirmTypePrompt": m101,
        "settingsDeleteConfirmationTarget":
            MessageLookupByLibrary.simpleMessage("DELETE"),
        "settingsDeleteErrorCloudUnreachable": MessageLookupByLibrary.simpleMessage(
            "Could not reach the cloud service. Check the connection and try again."),
        "settingsDeleteErrorGeneric": MessageLookupByLibrary.simpleMessage(
            "Could not delete the cloud account right now."),
        "settingsDeleteErrorLocalKept": MessageLookupByLibrary.simpleMessage(
            "Could not delete the cloud account right now. Local data has been kept on this device."),
        "settingsDeleteErrorSessionInvalid": MessageLookupByLibrary.simpleMessage(
            "Your cloud session is no longer valid. Sign in again and repeat the deletion."),
        "settingsDisclaimerLabel":
            MessageLookupByLibrary.simpleMessage("Disclaimer"),
        "settingsDistanceLabel":
            MessageLookupByLibrary.simpleMessage("Distance"),
        "settingsEnterReferralCodeHint":
            MessageLookupByLibrary.simpleMessage("Enter their code"),
        "settingsExportZipBody": MessageLookupByLibrary.simpleMessage(
            "Manual local copy to store or move data."),
        "settingsExportZipTitle":
            MessageLookupByLibrary.simpleMessage("Export ZIP"),
        "settingsFeatureRequestEmailBody": MessageLookupByLibrary.simpleMessage(
            "Describe the feature you would like to see:\n\n\n"),
        "settingsFeatureRequestEmailSubject":
            MessageLookupByLibrary.simpleMessage(
                "MacroTracker - Feature request"),
        "settingsFeatureTourTitle":
            MessageLookupByLibrary.simpleMessage("View Feature Tour"),
        "settingsFoundingMember":
            MessageLookupByLibrary.simpleMessage("Founding Member"),
        "settingsFreePlan": MessageLookupByLibrary.simpleMessage("Free plan"),
        "settingsGoogleAccountBody": MessageLookupByLibrary.simpleMessage(
            "Link Google to recover your account."),
        "settingsGoogleAccountTitle":
            MessageLookupByLibrary.simpleMessage("Google account"),
        "settingsGoogleDriveBackupBody": MessageLookupByLibrary.simpleMessage(
            "Store an encrypted copy in your own Drive."),
        "settingsGuestAllowanceUsedBody": m102,
        "settingsImperialLabel":
            MessageLookupByLibrary.simpleMessage("Imperial (lbs, ft, oz)"),
        "settingsInviteFriendsBody": MessageLookupByLibrary.simpleMessage(
            "Share your invitation code with a friend and you both get extra free AI uses when they redeem it."),
        "settingsInviteFriendsTitle":
            MessageLookupByLibrary.simpleMessage("Invite friends"),
        "settingsInvitedByFriendQuestion": MessageLookupByLibrary.simpleMessage(
            "Were you invited by a friend?"),
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
        "settingsManualDriveBackup":
            MessageLookupByLibrary.simpleMessage("Manual Drive"),
        "settingsManualStatus": MessageLookupByLibrary.simpleMessage("Manual"),
        "settingsMassLabel": MessageLookupByLibrary.simpleMessage("Mass"),
        "settingsMetricLabel":
            MessageLookupByLibrary.simpleMessage("Metric (kg, cm, ml)"),
        "settingsNoAccountStatus":
            MessageLookupByLibrary.simpleMessage("No account"),
        "settingsNotLinkedStatus":
            MessageLookupByLibrary.simpleMessage("Not linked"),
        "settingsNutritionistConnectionBody": MessageLookupByLibrary.simpleMessage(
            "Connect your account with a professional by invite and consent."),
        "settingsNutritionistConnectionTitle":
            MessageLookupByLibrary.simpleMessage("Nutritionist connection"),
        "settingsPlanLockedProgress": m103,
        "settingsPlanMetricAiMeals": m104,
        "settingsPlanProgress": m105,
        "settingsPlanTitle": MessageLookupByLibrary.simpleMessage("My plan"),
        "settingsPremiumUnlockedMessage": MessageLookupByLibrary.simpleMessage(
            "Text and photo AI logging is unlocked."),
        "settingsPrivacyDataSection":
            MessageLookupByLibrary.simpleMessage("Privacy and data"),
        "settingsPrivacySettings":
            MessageLookupByLibrary.simpleMessage("Privacy Settings"),
        "settingsProfessionalNutritionistSection":
            MessageLookupByLibrary.simpleMessage("Professional nutritionist"),
        "settingsProfessionalStatus":
            MessageLookupByLibrary.simpleMessage("Professional"),
        "settingsProtectAccountBackupsBody":
            MessageLookupByLibrary.simpleMessage(
                "Protect your account and configure backups."),
        "settingsPurchasesRestored":
            MessageLookupByLibrary.simpleMessage("Purchases restored."),
        "settingsRedeemReferralButton":
            MessageLookupByLibrary.simpleMessage("Redeem"),
        "settingsReferralAlreadyRedeemedMessage":
            MessageLookupByLibrary.simpleMessage(
                "You have already redeemed an invitation code."),
        "settingsReferralCodeLabel":
            MessageLookupByLibrary.simpleMessage("YOUR REFERRAL CODE"),
        "settingsReferralCodeNotFound":
            MessageLookupByLibrary.simpleMessage("Invitation code not found."),
        "settingsReferralCopiedMessage": MessageLookupByLibrary.simpleMessage(
            "Invitation link and code copied to clipboard."),
        "settingsReferralLoginRequired":
            MessageLookupByLibrary.simpleMessage("Log in to redeem codes."),
        "settingsReferralRedeemError": MessageLookupByLibrary.simpleMessage(
            "Error redeeming code. Please try again."),
        "settingsReferralRedeemSuccess": MessageLookupByLibrary.simpleMessage(
            "Code redeemed successfully. You earned free AI uses."),
        "settingsReferralSelfReferral": MessageLookupByLibrary.simpleMessage(
            "You cannot redeem your own code."),
        "settingsReferralShareMessage": m106,
        "settingsReportBugEmailBody": m107,
        "settingsReportBugEmailSubject":
            MessageLookupByLibrary.simpleMessage("MacroTracker - Bug report"),
        "settingsReportBugSubtitle": MessageLookupByLibrary.simpleMessage(
            "Let us know about an issue in the app."),
        "settingsReportBugTitle":
            MessageLookupByLibrary.simpleMessage("Report a bug"),
        "settingsReportErrorLabel":
            MessageLookupByLibrary.simpleMessage("Report Error"),
        "settingsResetLabel": MessageLookupByLibrary.simpleMessage("Reset"),
        "settingsSelectLanguageTitle":
            MessageLookupByLibrary.simpleMessage("Select language"),
        "settingsSourceCodeLabel":
            MessageLookupByLibrary.simpleMessage("Source Code"),
        "settingsSubscriptionActive": MessageLookupByLibrary.simpleMessage(
            "Your subscription is active on this device."),
        "settingsSuggestFeatureSubtitle": MessageLookupByLibrary.simpleMessage(
            "What would you like to see in MacroTracker?"),
        "settingsSuggestFeatureTitle":
            MessageLookupByLibrary.simpleMessage("Suggest a feature"),
        "settingsSupportSection":
            MessageLookupByLibrary.simpleMessage("Support and feedback"),
        "settingsSystemLabel": MessageLookupByLibrary.simpleMessage("System"),
        "settingsThemeDarkLabel": MessageLookupByLibrary.simpleMessage("Dark"),
        "settingsThemeLabel": MessageLookupByLibrary.simpleMessage("Theme"),
        "settingsThemeLightLabel":
            MessageLookupByLibrary.simpleMessage("Light"),
        "settingsThemeSystemDefaultLabel":
            MessageLookupByLibrary.simpleMessage("System default"),
        "settingsTrackingSection":
            MessageLookupByLibrary.simpleMessage("Tracking"),
        "settingsTrialProtectBody": m108,
        "settingsTrialRemainingBody": m109,
        "settingsUnitsLabel": MessageLookupByLibrary.simpleMessage("Units"),
        "settingsViewPremium":
            MessageLookupByLibrary.simpleMessage("View Premium"),
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
        "weeklyInsightsAdjustmentSuccess": m110,
        "weeklyInsightsApplyAdjustment": m111,
        "weeklyInsightsAverages":
            MessageLookupByLibrary.simpleMessage("Weekly Averages"),
        "weeklyInsightsCalorieIntake":
            MessageLookupByLibrary.simpleMessage("Calorie intake"),
        "weeklyInsightsCarbShort": MessageLookupByLibrary.simpleMessage("Carb"),
        "weeklyInsightsCheckup":
            MessageLookupByLibrary.simpleMessage("Smart Weekly Checkup"),
        "weeklyInsightsConsistentDays":
            MessageLookupByLibrary.simpleMessage("Consistent days"),
        "weeklyInsightsCoverage":
            MessageLookupByLibrary.simpleMessage("Coverage"),
        "weeklyInsightsCurrentAdjustment": m112,
        "weeklyInsightsDailyAverages":
            MessageLookupByLibrary.simpleMessage("Daily averages"),
        "weeklyInsightsDaysMet":
            MessageLookupByLibrary.simpleMessage("Days met"),
        "weeklyInsightsDaysSuffix":
            MessageLookupByLibrary.simpleMessage("days"),
        "weeklyInsightsError": MessageLookupByLibrary.simpleMessage(
            "Could not load weekly insights."),
        "weeklyInsightsFatShort": MessageLookupByLibrary.simpleMessage("Fat"),
        "weeklyInsightsLockedAdjustmentBody": MessageLookupByLibrary.simpleMessage(
            "Your weight trends and intake indicate you should adjust your daily calories. Premium calculates the exact change and applies it automatically."),
        "weeklyInsightsMealCountTimes": m113,
        "weeklyInsightsNewDailyTarget":
            MessageLookupByLibrary.simpleMessage("New daily target"),
        "weeklyInsightsNoFrequentMeals": MessageLookupByLibrary.simpleMessage(
            "No repeated meals detected this week."),
        "weeklyInsightsNoOvereatingPattern":
            MessageLookupByLibrary.simpleMessage("No clear overeating pattern"),
        "weeklyInsightsOvereatingPattern":
            MessageLookupByLibrary.simpleMessage("Overeating Pattern"),
        "weeklyInsightsOvereatingPeriods":
            MessageLookupByLibrary.simpleMessage("Periods of overeating"),
        "weeklyInsightsPerDay": MessageLookupByLibrary.simpleMessage("day"),
        "weeklyInsightsProteinConsistency":
            MessageLookupByLibrary.simpleMessage("Protein Consistency"),
        "weeklyInsightsProteinConsistencyShort":
            MessageLookupByLibrary.simpleMessage("Protein cons."),
        "weeklyInsightsProteinShort":
            MessageLookupByLibrary.simpleMessage("Prot"),
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
        "weeklyInsightsRegisteredDays": m114,
        "weeklyInsightsRevealAdjustment": MessageLookupByLibrary.simpleMessage(
            "Reveal recommended adjustment"),
        "weeklyInsightsSlotAfternoon":
            MessageLookupByLibrary.simpleMessage("Afternoon"),
        "weeklyInsightsSlotEvening":
            MessageLookupByLibrary.simpleMessage("Evening"),
        "weeklyInsightsSlotLateNight":
            MessageLookupByLibrary.simpleMessage("Late night"),
        "weeklyInsightsSlotMorning":
            MessageLookupByLibrary.simpleMessage("Morning"),
        "weeklyInsightsSmartAdjustmentRecommendation":
            MessageLookupByLibrary.simpleMessage(
                "Smart adjustment recommendation"),
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
        "weeklyInsightsTrackedDays": m115,
        "weeklyInsightsTrend": m116,
        "weeklyInsightsWeeklyChangeLabel":
            MessageLookupByLibrary.simpleMessage("Weekly change"),
        "weeklyInsightsWeeklySummary":
            MessageLookupByLibrary.simpleMessage("Weekly summary"),
        "weeklyInsightsWeightTrendLabel":
            MessageLookupByLibrary.simpleMessage("Weight trend"),
        "weeklyShareCardCarbsUpper":
            MessageLookupByLibrary.simpleMessage("CARBS"),
        "weeklyShareCardDailyAverageUpper":
            MessageLookupByLibrary.simpleMessage("DAILY AVERAGE"),
        "weeklyShareCardDaysLogged": m117,
        "weeklyShareCardFatUpper": MessageLookupByLibrary.simpleMessage("FAT"),
        "weeklyShareCardFooter": MessageLookupByLibrary.simpleMessage(
            "MY WEEKLY TRACKING WITH MACROTRACKER"),
        "weeklyShareCardGoalAdherenceUpper":
            MessageLookupByLibrary.simpleMessage("GOAL ADHERENCE"),
        "weeklyShareCardKcalPerDay":
            MessageLookupByLibrary.simpleMessage("kcal / day"),
        "weeklyShareCardProteinConsistencyUpper":
            MessageLookupByLibrary.simpleMessage("PROTEIN CONS."),
        "weeklyShareCardProteinUpper":
            MessageLookupByLibrary.simpleMessage("PROTEIN"),
        "weeklyShareCardWeightChangeUpper":
            MessageLookupByLibrary.simpleMessage("WEIGHT CHANGE"),
        "weeklyShareCopiedSnackbar": MessageLookupByLibrary.simpleMessage(
            "Summary copied to clipboard successfully."),
        "weeklyShareCopyText":
            MessageLookupByLibrary.simpleMessage("Copy text"),
        "weeklyShareImageError": MessageLookupByLibrary.simpleMessage(
            "Could not generate the progress card image."),
        "weeklyShareImageText": MessageLookupByLibrary.simpleMessage(
            "My weekly progress on MacroTracker"),
        "weeklyShareShareCard":
            MessageLookupByLibrary.simpleMessage("Share card"),
        "weeklyShareTextReportAverageCalories":
            MessageLookupByLibrary.simpleMessage("Average calories"),
        "weeklyShareTextReportAverageCarbs":
            MessageLookupByLibrary.simpleMessage("Average carbs"),
        "weeklyShareTextReportAverageFat":
            MessageLookupByLibrary.simpleMessage("Average fat"),
        "weeklyShareTextReportAverageProtein":
            MessageLookupByLibrary.simpleMessage("Average protein"),
        "weeklyShareTextReportDayUnit":
            MessageLookupByLibrary.simpleMessage("day"),
        "weeklyShareTextReportDaysTracked":
            MessageLookupByLibrary.simpleMessage("Days tracked"),
        "weeklyShareTextReportFooter":
            MessageLookupByLibrary.simpleMessage("Sent from MacroTracker."),
        "weeklyShareTextReportGoalAdherence":
            MessageLookupByLibrary.simpleMessage("Goal adherence"),
        "weeklyShareTextReportProteinConsistency":
            MessageLookupByLibrary.simpleMessage("Protein consistency"),
        "weeklyShareTextReportRange":
            MessageLookupByLibrary.simpleMessage("Range"),
        "weeklyShareTextReportTitle": MessageLookupByLibrary.simpleMessage(
            "My weekly progress (MacroTracker)"),
        "weeklyShareTextReportWeightDelta":
            MessageLookupByLibrary.simpleMessage("Weight change"),
        "weeklyShareTitle":
            MessageLookupByLibrary.simpleMessage("Share progress"),
        "weightLabel": MessageLookupByLibrary.simpleMessage("Weight"),
        "yearsLabel": m118
      };
}
