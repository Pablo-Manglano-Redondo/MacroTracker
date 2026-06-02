import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrotracker/core/data/data_source/user_activity_dbo.dart';
import 'package:macrotracker/core/data/dbo/app_theme_dbo.dart';
import 'package:macrotracker/core/data/dbo/config_dbo.dart';
import 'package:macrotracker/core/data/dbo/intake_dbo.dart';
import 'package:macrotracker/core/data/dbo/intake_type_dbo.dart';
import 'package:macrotracker/core/data/dbo/physical_activity_dbo.dart';
import 'package:macrotracker/core/data/dbo/meal_dbo.dart';
import 'package:macrotracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:macrotracker/core/data/dbo/tracked_day_dbo.dart';
import 'package:macrotracker/core/data/dbo/user_dbo.dart';
import 'package:macrotracker/core/data/dbo/user_gender_dbo.dart';
import 'package:macrotracker/core/data/dbo/user_pal_dbo.dart';
import 'package:macrotracker/core/data/dbo/user_weight_goal_dbo.dart';
import 'package:macrotracker/features/body_progress/data/dbo/body_measurement_dbo.dart';
import 'package:macrotracker/features/daily_habits/data/dbo/daily_habit_log_dbo.dart';
import 'package:macrotracker/features/meal_capture/data/dbo/interpretation_draft_dbo.dart';
import 'package:macrotracker/features/meal_capture/data/dbo/interpretation_draft_item_dbo.dart';
import 'package:macrotracker/features/recipes/data/dbo/recipe_dbo.dart';
import 'package:macrotracker/features/recipes/data/dbo/recipe_ingredient_dbo.dart';

class HiveDBProvider extends ChangeNotifier {
  static const configBoxName = 'ConfigBox';
  static const intakeBoxName = 'IntakeBox';
  static const userActivityBoxName = 'UserActivityBox';
  static const userBoxName = 'UserBox';
  static const trackedDayBoxName = 'TrackedDayBox';
  static const recipeBoxName = 'RecipeBox';
  static const interpretationDraftBoxName = 'InterpretationDraftBox';
  static const bodyMeasurementBoxName = 'BodyMeasurementBox';
  static const dailyHabitLogBoxName = 'DailyHabitLogBox';
  static const monetizationBoxName = 'MonetizationBox';
  static const professionalPlanBoxName = 'ProfessionalPlanBox';

  late Box<ConfigDBO> configBox;
  late Box<IntakeDBO> intakeBox;
  late Box<UserActivityDBO> userActivityBox;
  late Box<UserDBO> userBox;
  late Box<TrackedDayDBO> trackedDayBox;
  late Box<RecipeDBO> recipeBox;
  late Box<InterpretationDraftDBO> interpretationDraftBox;
  late Box<BodyMeasurementDBO> bodyMeasurementBox;
  late Box<DailyHabitLogDBO> dailyHabitLogBox;
  late Box<dynamic> monetizationBox;
  late Box<dynamic> professionalPlanBox;

  Future<void> initHiveDB(Uint8List encryptionKey) async {
    final encryptionCypher = HiveAesCipher(encryptionKey);
    await Hive.initFlutter();
    Hive.registerAdapter(ConfigDBOAdapter());
    Hive.registerAdapter(IntakeDBOAdapter());
    Hive.registerAdapter(MealDBOAdapter());
    Hive.registerAdapter(MealNutrimentsDBOAdapter());
    Hive.registerAdapter(MealSourceDBOAdapter());
    Hive.registerAdapter(IntakeTypeDBOAdapter());
    Hive.registerAdapter(UserDBOAdapter());
    Hive.registerAdapter(UserGenderDBOAdapter());
    Hive.registerAdapter(UserWeightGoalDBOAdapter());
    Hive.registerAdapter(UserPALDBOAdapter());
    Hive.registerAdapter(TrackedDayDBOAdapter());
    Hive.registerAdapter(UserActivityDBOAdapter());
    Hive.registerAdapter(PhysicalActivityDBOAdapter());
    Hive.registerAdapter(PhysicalActivityTypeDBOAdapter());
    Hive.registerAdapter(AppThemeDBOAdapter());
    Hive.registerAdapter(ConfidenceBandDBOAdapter());
    Hive.registerAdapter(RecipeIngredientDBOAdapter());
    Hive.registerAdapter(RecipeDBOAdapter());
    Hive.registerAdapter(BodyMeasurementDBOAdapter());
    Hive.registerAdapter(DailyHabitLogDBOAdapter());
    Hive.registerAdapter(DraftSourceDBOAdapter());
    Hive.registerAdapter(DraftStatusDBOAdapter());
    Hive.registerAdapter(InterpretationDraftItemDBOAdapter());
    Hive.registerAdapter(InterpretationDraftDBOAdapter());

    configBox = await _openEncryptedBox(configBoxName, encryptionCypher);
    intakeBox = await _openEncryptedBox(intakeBoxName, encryptionCypher);
    userActivityBox =
        await _openEncryptedBox(userActivityBoxName, encryptionCypher);
    userBox = await _openEncryptedBox(userBoxName, encryptionCypher);
    trackedDayBox =
        await _openEncryptedBox(trackedDayBoxName, encryptionCypher);
    recipeBox = await _openEncryptedBox(recipeBoxName, encryptionCypher);
    interpretationDraftBox =
        await _openEncryptedBox(interpretationDraftBoxName, encryptionCypher);
    bodyMeasurementBox =
        await _openEncryptedBox(bodyMeasurementBoxName, encryptionCypher);
    dailyHabitLogBox =
        await _openEncryptedBox(dailyHabitLogBoxName, encryptionCypher);
    monetizationBox =
        await _openEncryptedBox<dynamic>(monetizationBoxName, encryptionCypher);
    professionalPlanBox = await _openEncryptedBox<dynamic>(
        professionalPlanBoxName, encryptionCypher);
  }

  Future<Box<T>> _openEncryptedBox<T>(
    String boxName,
    HiveAesCipher encryptionCypher,
  ) async {
    try {
      return await Hive.openBox<T>(
        boxName,
        encryptionCipher: encryptionCypher,
      );
    } catch (error) {
      throw HiveError('Failed to open $boxName: $error');
    }
  }

  static generateNewHiveEncryptionKey() => Hive.generateSecureKey();
}
