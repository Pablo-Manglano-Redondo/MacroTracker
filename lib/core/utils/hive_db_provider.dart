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

  late Box<ConfigDBO> configBox;
  late Box<IntakeDBO> intakeBox;
  late Box<UserActivityDBO> userActivityBox;
  late Box<UserDBO> userBox;
  late Box<TrackedDayDBO> trackedDayBox;
  late Box<RecipeDBO> recipeBox;
  late Box<InterpretationDraftDBO> interpretationDraftBox;

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
    Hive.registerAdapter(DraftSourceDBOAdapter());
    Hive.registerAdapter(DraftStatusDBOAdapter());
    Hive.registerAdapter(InterpretationDraftItemDBOAdapter());
    Hive.registerAdapter(InterpretationDraftDBOAdapter());

    configBox =
        await Hive.openBox(configBoxName, encryptionCipher: encryptionCypher);
    intakeBox =
        await Hive.openBox(intakeBoxName, encryptionCipher: encryptionCypher);
    userActivityBox = await Hive.openBox(userActivityBoxName,
        encryptionCipher: encryptionCypher);
    userBox =
        await Hive.openBox(userBoxName, encryptionCipher: encryptionCypher);
    trackedDayBox = await Hive.openBox(trackedDayBoxName,
        encryptionCipher: encryptionCypher);
    recipeBox =
        await Hive.openBox(recipeBoxName, encryptionCipher: encryptionCypher);
    interpretationDraftBox = await Hive.openBox(interpretationDraftBoxName,
        encryptionCipher: encryptionCypher);
  }

  static generateNewHiveEncryptionKey() => Hive.generateSecureKey();
}
