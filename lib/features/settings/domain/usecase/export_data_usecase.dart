import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:macrotracker/core/data/repository/intake_repository.dart';
import 'package:macrotracker/core/data/repository/tracked_day_repository.dart';
import 'package:macrotracker/core/data/repository/user_activity_repository.dart';
import 'package:macrotracker/features/body_progress/data/repository/body_measurement_repository.dart';
import 'package:macrotracker/features/daily_habits/data/repository/daily_habit_log_repository.dart';
import 'package:macrotracker/features/recipes/data/repository/recipe_repository.dart';
import 'package:macrotracker/core/data/repository/user_repository.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';

class ExportDataUsecase {
  final UserActivityRepository _userActivityRepository;
  final IntakeRepository _intakeRepository;
  final TrackedDayRepository _trackedDayRepository;
  final RecipeRepository _recipeRepository;
  final BodyMeasurementRepository _bodyMeasurementRepository;
  final DailyHabitLogRepository _dailyHabitLogRepository;
  final UserRepository _userRepository;
  final ConfigRepository _configRepository;

  ExportDataUsecase(
      this._userActivityRepository,
      this._intakeRepository,
      this._trackedDayRepository,
      this._recipeRepository,
      this._bodyMeasurementRepository,
      this._dailyHabitLogRepository,
      this._userRepository,
      this._configRepository);

  /// Exports user activity, intake, and tracked day data to a zip of json
  /// files at a user specified location.
  Future<String?> exportData(
      String exportZipFileName,
      String userActivityJsonFileName,
      String userIntakeJsonFileName,
      String trackedDayJsonFileName,
      String recipeJsonFileName,
      String bodyMeasurementJsonFileName,
      String dailyHabitJsonFileName,
      String userJsonFileName,
      String configJsonFileName,
      {String? customOutputPath}) async {
    // Export user activity data to Json File Bytes
    final fullUserActivity =
        await _userActivityRepository.getAllUserActivityDBO();
    final fullUserActivityJson = jsonEncode(
        fullUserActivity.map((activity) => activity.toJson()).toList());
    final userActivityJsonBytes = utf8.encode(fullUserActivityJson);

    // Export intake data to Json File Bytes
    final fullIntake = await _intakeRepository.getAllIntakesDBO();
    final fullIntakeJson =
        jsonEncode(fullIntake.map((intake) => intake.toJson()).toList());
    final intakeJsonBytes = utf8.encode(fullIntakeJson);

    // Export tracked day data to Json File Bytes
    final fullTrackedDay = await _trackedDayRepository.getAllTrackedDaysDBO();
    final fullTrackedDayJson = jsonEncode(
        fullTrackedDay.map((trackedDay) => trackedDay.toJson()).toList());
    final trackedDayJsonBytes = utf8.encode(fullTrackedDayJson);

    final fullRecipes = await _recipeRepository.getAllRecipesDBO();
    final fullRecipesJson =
        jsonEncode(fullRecipes.map((recipe) => recipe.toJson()).toList());
    final recipeJsonBytes = utf8.encode(fullRecipesJson);
    final fullBodyMeasurements =
        await _bodyMeasurementRepository.getAllMeasurementsDBO();
    final fullBodyMeasurementsJson = jsonEncode(fullBodyMeasurements
        .map((measurement) => measurement.toJson())
        .toList());
    final bodyMeasurementJsonBytes = utf8.encode(fullBodyMeasurementsJson);
    final fullHabitLogs = await _dailyHabitLogRepository.getAllLogsDBO();
    final fullHabitLogsJson =
        jsonEncode(fullHabitLogs.map((log) => log.toJson()).toList());
    final dailyHabitJsonBytes = utf8.encode(fullHabitLogsJson);

    final userDBO = await _userRepository.getUserDBO();
    final userJsonBytes = utf8.encode(jsonEncode(userDBO.toJson()));

    final configDBO = await _configRepository.getConfigDBO();
    final configJsonBytes = utf8.encode(jsonEncode(configDBO.toJson()));

    // Create a zip file with the exported data
    final archive = Archive();
    archive.addFile(
      ArchiveFile(userActivityJsonFileName, userActivityJsonBytes.length,
          userActivityJsonBytes),
    );
    archive.addFile(
      ArchiveFile(
          userIntakeJsonFileName, intakeJsonBytes.length, intakeJsonBytes),
    );
    archive.addFile(
      ArchiveFile(trackedDayJsonFileName, trackedDayJsonBytes.length,
          trackedDayJsonBytes),
    );
    archive.addFile(
      ArchiveFile(recipeJsonFileName, recipeJsonBytes.length, recipeJsonBytes),
    );
    archive.addFile(
      ArchiveFile(bodyMeasurementJsonFileName, bodyMeasurementJsonBytes.length,
          bodyMeasurementJsonBytes),
    );
    archive.addFile(
      ArchiveFile(dailyHabitJsonFileName, dailyHabitJsonBytes.length,
          dailyHabitJsonBytes),
    );
    archive.addFile(
      ArchiveFile(userJsonFileName, userJsonBytes.length, userJsonBytes),
    );
    archive.addFile(
      ArchiveFile(configJsonFileName, configJsonBytes.length, configJsonBytes),
    );

    // Save the zip file
    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) return null;

    if (customOutputPath != null) {
      final file = File(customOutputPath);
      await file.writeAsBytes(zipBytes);
      return file.path;
    } else {
      final result = await FilePicker.platform.saveFile(
        fileName: exportZipFileName,
        type: FileType.custom,
        allowedExtensions: ['zip'],
        bytes: Uint8List.fromList(zipBytes),
      );
      return result;
    }
  }
}
