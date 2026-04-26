import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:macrotracker/core/data/data_source/user_activity_dbo.dart';
import 'package:macrotracker/core/data/dbo/intake_dbo.dart';
import 'package:macrotracker/core/data/dbo/tracked_day_dbo.dart';
import 'package:macrotracker/core/data/repository/intake_repository.dart';
import 'package:macrotracker/core/data/repository/tracked_day_repository.dart';
import 'package:macrotracker/core/data/repository/user_activity_repository.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/body_progress/data/dbo/body_measurement_dbo.dart';
import 'package:macrotracker/features/body_progress/data/repository/body_measurement_repository.dart';
import 'package:macrotracker/features/daily_habits/data/dbo/daily_habit_log_dbo.dart';
import 'package:macrotracker/features/daily_habits/data/repository/daily_habit_log_repository.dart';
import 'package:macrotracker/features/recipes/data/dbo/recipe_dbo.dart';
import 'package:macrotracker/features/recipes/data/repository/recipe_repository.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';

class ImportDataUsecase {
  final UserActivityRepository _userActivityRepository;
  final IntakeRepository _intakeRepository;
  final TrackedDayRepository _trackedDayRepository;
  final RecipeRepository _recipeRepository;
  final BodyMeasurementRepository _bodyMeasurementRepository;
  final DailyHabitLogRepository _dailyHabitLogRepository;

  ImportDataUsecase(
      this._userActivityRepository,
      this._intakeRepository,
      this._trackedDayRepository,
      this._recipeRepository,
      this._bodyMeasurementRepository,
      this._dailyHabitLogRepository);

  /// Imports user activity, intake, and tracked day data from a zip file
  /// containing JSON files.
  ///
  /// Returns true if import was successful, false otherwise.
  Future<bool> importData(
      String userActivityJsonFileName,
      String userIntakeJsonFileName,
      String trackedDayJsonFileName,
      String recipeJsonFileName,
      String bodyMeasurementJsonFileName,
      String dailyHabitJsonFileName) async {
    // Allow user to pick a zip file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      // allowedExtensions: ['zip'],
    );

    if (result == null || result.files.single.path == null) {
      throw Exception('No file selected');
    }

    // Read the file bytes using the file path
    final file = File(result.files.single.path!);
    final zipBytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(zipBytes);

    // Extract and process user activity data
    final userActivityFile = archive.findFile(userActivityJsonFileName);
    if (userActivityFile != null) {
      final userActivityJsonString =
          utf8.decode(userActivityFile.content as List<int>);
      final userActivityList = (jsonDecode(userActivityJsonString) as List)
          .cast<Map<String, dynamic>>();

      final userActivityDBOs = userActivityList
          .map((json) => UserActivityDBO.fromJson(json))
          .toList();

      await _userActivityRepository.addAllUserActivityDBOs(userActivityDBOs);
    } else {
      throw Exception('User activity file not found in the archive');
    }

    // Extract and process intake data
    final intakeFile = archive.findFile(userIntakeJsonFileName);
    if (intakeFile != null) {
      final intakeJsonString = utf8.decode(intakeFile.content as List<int>);
      final intakeList =
          (jsonDecode(intakeJsonString) as List).cast<Map<String, dynamic>>();

      final intakeDBOs =
          intakeList.map((json) => IntakeDBO.fromJson(json)).toList();

      await _intakeRepository.addAllIntakeDBOs(intakeDBOs);
    } else {
      throw Exception('Intake file not found in the archive');
    }

    // Extract and process tracked day data
    final trackedDayFile = archive.findFile(trackedDayJsonFileName);
    if (trackedDayFile != null) {
      final trackedDayJsonString =
          utf8.decode(trackedDayFile.content as List<int>);
      final trackedDayList = (jsonDecode(trackedDayJsonString) as List)
          .cast<Map<String, dynamic>>();

      final trackedDayDBOs =
          trackedDayList.map((json) => TrackedDayDBO.fromJson(json)).toList();

      await _trackedDayRepository.addAllTrackedDays(trackedDayDBOs);
    } else {
      throw Exception('Tracked day file not found in the archive');
    }

    final recipeFile = archive.findFile(recipeJsonFileName);
    if (recipeFile != null) {
      final recipeJsonString = utf8.decode(recipeFile.content as List<int>);
      final recipeList =
          (jsonDecode(recipeJsonString) as List).cast<Map<String, dynamic>>();

      final recipeDBOs =
          recipeList.map((json) => RecipeDBO.fromJson(json)).toList();

      for (final recipe in recipeDBOs) {
        await _recipeRepository.saveRecipe(_mapRecipe(recipe));
      }
    }

    final bodyMeasurementFile = archive.findFile(bodyMeasurementJsonFileName);
    if (bodyMeasurementFile != null) {
      final bodyMeasurementJsonString =
          utf8.decode(bodyMeasurementFile.content as List<int>);
      final bodyMeasurementList =
          (jsonDecode(bodyMeasurementJsonString) as List)
              .cast<Map<String, dynamic>>();
      final bodyMeasurementDBOs = bodyMeasurementList
          .map((json) => BodyMeasurementDBO.fromJson(json))
          .toList();
      await _bodyMeasurementRepository.addAllMeasurements(bodyMeasurementDBOs);
    }

    final dailyHabitFile = archive.findFile(dailyHabitJsonFileName);
    if (dailyHabitFile != null) {
      final dailyHabitJsonString =
          utf8.decode(dailyHabitFile.content as List<int>);
      final dailyHabitList = (jsonDecode(dailyHabitJsonString) as List)
          .cast<Map<String, dynamic>>();
      final dailyHabitDBOs = dailyHabitList
          .map((json) => DailyHabitLogDBO.fromJson(json))
          .toList();
      await _dailyHabitLogRepository.addAllLogs(dailyHabitDBOs);
    }

    return true;
  }

  RecipeEntity _mapRecipe(RecipeDBO recipeDBO) {
    return RecipeEntity(
      id: recipeDBO.id,
      name: recipeDBO.name,
      notes: recipeDBO.notes,
      defaultServings: recipeDBO.defaultServings,
      yieldQuantity: recipeDBO.yieldQuantity,
      yieldUnit: recipeDBO.yieldUnit,
      favorite: recipeDBO.favorite,
      createdAt: recipeDBO.createdAt,
      updatedAt: recipeDBO.updatedAt,
      ingredients: recipeDBO.ingredients
          .map((ingredient) => RecipeIngredientEntity(
                id: ingredient.id,
                mealSnapshot: MealEntity.fromMealDBO(ingredient.mealSnapshot),
                amount: ingredient.amount,
                unit: ingredient.unit,
                position: ingredient.position,
              ))
          .toList(),
    );
  }
}
