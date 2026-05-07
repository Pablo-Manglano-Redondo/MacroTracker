import 'dart:io';

import 'package:logging/logging.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/domain/entity/physical_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_user_activity_usercase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/features/daily_habits/data/data_source/health_connect_sleep_data_source.dart';
import 'package:macrotracker/features/daily_habits/data/repository/daily_habit_log_repository.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_connect_sync_status_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_sleep_session_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_connect_workout_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/health_connect_workout_sync_helper.dart';

class SyncSleepFromHealthConnectUsecase {
  final _log = Logger('SyncSleepFromHealthConnectUsecase');
  static const _workoutSyncLookbackDays = 7;

  final HealthConnectSleepDataSource _healthConnectSleepDataSource;
  final DailyHabitLogRepository _dailyHabitLogRepository;
  final ConfigRepository _configRepository;
  final AddUserActivityUsecase _addUserActivityUsecase;
  final GetUserActivityUsecase _getUserActivityUsecase;
  final AddTrackedDayUsecase _addTrackedDayUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;
  final GetKcalGoalUsecase _getKcalGoalUsecase;

  bool _authorizationRequestedThisLaunch = false;
  bool _activityPermissionRequestedThisLaunch = false;
  bool _stepsPermissionRequestedThisLaunch = false;
  bool _workoutSupplementPermissionRequestedThisLaunch = false;

  SyncSleepFromHealthConnectUsecase(
    this._healthConnectSleepDataSource,
    this._dailyHabitLogRepository,
    this._configRepository,
    this._addUserActivityUsecase,
    this._getUserActivityUsecase,
    this._addTrackedDayUsecase,
    this._getMacroGoalUsecase,
    this._getKcalGoalUsecase,
  );

  Future<bool> syncToday({
    bool requestPermissionsIfNeeded = true,
    bool ignoreAutoSyncSetting = false,
  }) async {
    final report = await syncDayWithReport(
      DateTime.now(),
      requestPermissionsIfNeeded: requestPermissionsIfNeeded,
      ignoreAutoSyncSetting: ignoreAutoSyncSetting,
    );
    return report.didUpdate;
  }

  Future<HealthConnectSyncReport> syncDayWithReport(
    DateTime day, {
    bool requestPermissionsIfNeeded = true,
    bool ignoreAutoSyncSetting = false,
  }) async {
    return _syncDayWithReport(
      day,
      requestPermissionsIfNeeded: requestPermissionsIfNeeded,
      ignoreAutoSyncSetting: ignoreAutoSyncSetting,
    );
  }

  Future<bool> syncDay(
    DateTime day, {
    bool requestPermissionsIfNeeded = true,
    bool ignoreAutoSyncSetting = false,
  }) async {
    final report = await _syncDayWithReport(
      day,
      requestPermissionsIfNeeded: requestPermissionsIfNeeded,
      ignoreAutoSyncSetting: ignoreAutoSyncSetting,
    );
    return report.didUpdate;
  }

  Future<HealthConnectSyncReport> _syncDayWithReport(
    DateTime day, {
    required bool requestPermissionsIfNeeded,
    required bool ignoreAutoSyncSetting,
  }) async {
    try {
      if (!Platform.isAndroid) {
        return HealthConnectSyncReport(
          didUpdate: false,
          reason: HealthConnectSyncSkipReason.notAndroid,
        );
      }

      final config = await _configRepository.getConfig();
      if (!ignoreAutoSyncSetting && !config.healthConnectAutoSyncEnabled) {
        _log.fine('Health Connect auto sync disabled by user');
        return HealthConnectSyncReport(
          didUpdate: false,
          reason: HealthConnectSyncSkipReason.autoSyncDisabled,
        );
      }

      final normalizedDay = DateTime(day.year, day.month, day.day);
      final dayEnd = normalizedDay.add(const Duration(days: 1));

      await _healthConnectSleepDataSource.configure();

      if (!await _healthConnectSleepDataSource.isAvailable()) {
        _log.fine('Health Connect is not available on this device');
        return HealthConnectSyncReport(
          didUpdate: false,
          reason: HealthConnectSyncSkipReason.notAvailable,
        );
      }

      var hasPermission =
          await _healthConnectSleepDataSource.hasReadPermission();
      if (!hasPermission &&
          requestPermissionsIfNeeded &&
          !_authorizationRequestedThisLaunch) {
        _authorizationRequestedThisLaunch = true;
        hasPermission =
            await _healthConnectSleepDataSource.requestReadPermission();
      }

      if (!hasPermission) {
        _log.fine('Health Connect read permissions not granted');
        return HealthConnectSyncReport(
          didUpdate: false,
          reason: HealthConnectSyncSkipReason.permissionsMissing,
        );
      }

      var hasActivityRecognition = await _healthConnectSleepDataSource
          .hasActivityRecognitionPermission();
      if (!hasActivityRecognition &&
          requestPermissionsIfNeeded &&
          !_activityPermissionRequestedThisLaunch) {
        _activityPermissionRequestedThisLaunch = true;
        hasActivityRecognition = await _healthConnectSleepDataSource
            .requestActivityRecognitionPermission();
      }

      var hasStepsPermission =
          await _healthConnectSleepDataSource.hasStepsReadPermission();
      if (!hasStepsPermission &&
          requestPermissionsIfNeeded &&
          !_stepsPermissionRequestedThisLaunch) {
        _stepsPermissionRequestedThisLaunch = true;
        hasStepsPermission =
            await _healthConnectSleepDataSource.requestStepsReadPermission();
      }

      var hasWorkoutSupplementPermission = await _healthConnectSleepDataSource
          .hasWorkoutSupplementReadPermission();
      if (!hasWorkoutSupplementPermission &&
          requestPermissionsIfNeeded &&
          !_workoutSupplementPermissionRequestedThisLaunch) {
        _workoutSupplementPermissionRequestedThisLaunch = true;
        hasWorkoutSupplementPermission = await _healthConnectSleepDataSource
            .requestWorkoutSupplementReadPermission();
      }

      final sessions = await _healthConnectSleepDataSource.readSleepSessions(
        normalizedDay.subtract(const Duration(days: 1)),
        dayEnd,
      );
      final selectedSession = _selectSessionForDay(normalizedDay, sessions);
      final syncedSleepHours = selectedSession == null
          ? null
          : _roundHours(selectedSession.duration);
      final currentLog = await _dailyHabitLogRepository.getLog(normalizedDay) ??
          DailyHabitLogEntity.empty(normalizedDay);
      final syncedSteps = hasActivityRecognition && hasStepsPermission
          ? await _healthConnectSleepDataSource.readStepCount(
              normalizedDay,
              dayEnd,
            )
          : currentLog.steps;
      final workouts = hasWorkoutSupplementPermission
          ? await _healthConnectSleepDataSource.readWorkouts(
              normalizedDay
                  .subtract(const Duration(days: _workoutSyncLookbackDays)),
              dayEnd,
            )
          : const <HealthConnectWorkoutEntity>[];
      final discardedIds =
          await _configRepository.getDiscardedHealthConnectActivityIds();
      final existingActivities = await _getUserActivityUsecase.getAllUserActivity();
      final existingExternalIds = existingActivities
          .where(
            (activity) =>
                activity.source == UserActivitySourceEntity.healthConnect &&
                activity.externalId != null,
          )
          .map((activity) => activity.externalId!)
          .toSet();
      final workoutsToImport = filterHealthConnectWorkoutsToImport(
        workouts,
        existingExternalIds: existingExternalIds,
        discardedExternalIds: discardedIds,
        windowStart: normalizedDay.subtract(const Duration(days: _workoutSyncLookbackDays)),
        windowEnd: dayEnd,
      );

      final forceSync = ignoreAutoSyncSetting;
      final sleepChanged = syncedSleepHours != null &&
          ((currentLog.sleepHours - syncedSleepHours).abs() >= 0.01 ||
              (forceSync && currentLog.sleepSyncedFromHealthConnect != true));
      final stepsChanged = hasActivityRecognition && hasStepsPermission &&
          (currentLog.steps != syncedSteps ||
              (forceSync && currentLog.stepsSyncedFromHealthConnect != true));

      if (!hasActivityRecognition) {
        _log.fine(
          'Activity recognition permission not granted. '
          'Skipping steps sync but continuing with sleep/workouts.',
        );
      } else if (!hasStepsPermission) {
        _log.fine(
          'Health Connect steps permission missing. '
          'Skipping steps sync but continuing with sleep/workouts.',
        );
      }
      if (!hasWorkoutSupplementPermission) {
        _log.fine(
          'Health Connect workout supplement permissions missing. '
          'Skipping workouts sync but continuing with sleep/steps.',
        );
      }

      if (!sleepChanged && !stepsChanged && workoutsToImport.isEmpty) {
        return HealthConnectSyncReport(
          didUpdate: false,
          reason: HealthConnectSyncSkipReason.noChanges,
          workoutsRead: workouts.length,
          workoutsFiltered: workoutsToImport.length,
          workoutsImported: 0,
          sleepChanged: sleepChanged,
          stepsChanged: stepsChanged,
          hasActivityRecognition: hasActivityRecognition,
          hasStepsPermission: hasStepsPermission,
          hasWorkoutSupplementPermission: hasWorkoutSupplementPermission,
        );
      }

      await _dailyHabitLogRepository.saveLog(
        currentLog.copyWith(
          day: normalizedDay,
          sleepHours: sleepChanged ? syncedSleepHours : null,
          steps: stepsChanged ? syncedSteps : null,
          sleepSyncedFromHealthConnect: sleepChanged ? true : null,
          stepsSyncedFromHealthConnect: stepsChanged ? true : null,
        ),
      );
      _log.info(
        'Synced Health Connect daily habits for $normalizedDay: '
        'sleep=${sleepChanged ? syncedSleepHours : currentLog.sleepHours}, '
        'steps=${stepsChanged ? syncedSteps : currentLog.steps}, '
        'workoutsRead=${workouts.length}, workoutsToImport=${workoutsToImport.length}',
      );
      var importedWorkouts = 0;
      for (final workout in workoutsToImport) {
        final workoutDay = DateTime(
          workout.startTime.year,
          workout.startTime.month,
          workout.startTime.day,
        );
        final activity = UserActivityEntity(
          IdGenerator.getUniqueID(),
          workout.durationMinutes,
          workout.burnedKcal,
          workoutDay,
          PhysicalActivityEntity(
            workout.activityCode,
            workout.displayName,
            workout.description,
            0,
            const ['health-connect'],
            _mapWorkoutType(workout.activityCode),
          ),
          source: UserActivitySourceEntity.healthConnect,
          externalId: workout.externalId,
        );
        await _addUserActivityUsecase.addUserActivity(activity);
        await _updateTrackedDay(workoutDay);
        existingExternalIds.add(workout.externalId);
        importedWorkouts++;
      }
      _log.info('Imported $importedWorkouts Health Connect workouts');
      return HealthConnectSyncReport(
        didUpdate: sleepChanged || stepsChanged || importedWorkouts > 0,
        reason: HealthConnectSyncSkipReason.none,
        workoutsRead: workouts.length,
        workoutsFiltered: workoutsToImport.length,
        workoutsImported: importedWorkouts,
        sleepChanged: sleepChanged,
        stepsChanged: stepsChanged,
        hasActivityRecognition: hasActivityRecognition,
        hasStepsPermission: hasStepsPermission,
        hasWorkoutSupplementPermission: hasWorkoutSupplementPermission,
      );
    } catch (error, stackTrace) {
      _log.warning('Health Connect sync failed', error, stackTrace);
      return HealthConnectSyncReport(
        didUpdate: false,
        reason: HealthConnectSyncSkipReason.error,
      );
    }
  }

  Future<HealthConnectSyncStatusEntity> getStatus() async {
    final config = await _configRepository.getConfig();
    try {
      if (!Platform.isAndroid) {
        return HealthConnectSyncStatusEntity(
          isAvailable: false,
          hasHealthPermissions: false,
          hasActivityRecognitionPermission: false,
          isAutoSyncEnabled: config.healthConnectAutoSyncEnabled,
        );
      }

      await _healthConnectSleepDataSource.configure();
      final isAvailable = await _healthConnectSleepDataSource.isAvailable();
      if (!isAvailable) {
        return HealthConnectSyncStatusEntity(
          isAvailable: false,
          hasHealthPermissions: false,
          hasActivityRecognitionPermission: false,
          isAutoSyncEnabled: config.healthConnectAutoSyncEnabled,
        );
      }

      return HealthConnectSyncStatusEntity(
        isAvailable: true,
        hasHealthPermissions:
            await _healthConnectSleepDataSource.hasReadPermission(),
        hasActivityRecognitionPermission: await _healthConnectSleepDataSource
            .hasActivityRecognitionPermission(),
        isAutoSyncEnabled: config.healthConnectAutoSyncEnabled,
      );
    } catch (error, stackTrace) {
      _log.warning('Health Connect status check failed', error, stackTrace);
      return HealthConnectSyncStatusEntity(
        isAvailable: false,
        hasHealthPermissions: false,
        hasActivityRecognitionPermission: false,
        isAutoSyncEnabled: config.healthConnectAutoSyncEnabled,
      );
    }
  }

  Future<void> setAutoSyncEnabled(bool enabled) async {
    await _configRepository.setHealthConnectAutoSyncEnabled(enabled);
  }

  Future<HealthConnectSyncStatusEntity> requestPermissions() async {
    final config = await _configRepository.getConfig();
    try {
      if (!Platform.isAndroid) {
        return HealthConnectSyncStatusEntity(
          isAvailable: false,
          hasHealthPermissions: false,
          hasActivityRecognitionPermission: false,
          isAutoSyncEnabled: config.healthConnectAutoSyncEnabled,
        );
      }

      await _healthConnectSleepDataSource.configure();
      final isAvailable = await _healthConnectSleepDataSource.isAvailable();
      if (!isAvailable) {
        return HealthConnectSyncStatusEntity(
          isAvailable: false,
          hasHealthPermissions: false,
          hasActivityRecognitionPermission: false,
          isAutoSyncEnabled: config.healthConnectAutoSyncEnabled,
        );
      }

      var hasActivityRecognition = await _healthConnectSleepDataSource
          .hasActivityRecognitionPermission();
      if (!hasActivityRecognition) {
        hasActivityRecognition = await _healthConnectSleepDataSource
            .requestActivityRecognitionPermission();
      }

      var hasHealthPermissions =
          await _healthConnectSleepDataSource.hasReadPermission();
      if (!hasHealthPermissions) {
        hasHealthPermissions =
            await _healthConnectSleepDataSource.requestReadPermission();
      }

      var hasStepsPermission =
          await _healthConnectSleepDataSource.hasStepsReadPermission();
      if (!hasStepsPermission) {
        hasStepsPermission =
            await _healthConnectSleepDataSource.requestStepsReadPermission();
      }

      var hasWorkoutSupplementPermission = await _healthConnectSleepDataSource
          .hasWorkoutSupplementReadPermission();
      if (!hasWorkoutSupplementPermission) {
        hasWorkoutSupplementPermission = await _healthConnectSleepDataSource
            .requestWorkoutSupplementReadPermission();
      }

      return HealthConnectSyncStatusEntity(
        isAvailable: true,
        hasHealthPermissions: hasHealthPermissions &&
            hasStepsPermission &&
            hasWorkoutSupplementPermission,
        hasActivityRecognitionPermission: hasActivityRecognition,
        isAutoSyncEnabled: config.healthConnectAutoSyncEnabled,
      );
    } catch (error, stackTrace) {
      _log.warning('Health Connect permission flow failed', error, stackTrace);
      return HealthConnectSyncStatusEntity(
        isAvailable: false,
        hasHealthPermissions: false,
        hasActivityRecognitionPermission: false,
        isAutoSyncEnabled: config.healthConnectAutoSyncEnabled,
      );
    }
  }

  HealthSleepSessionEntity? _selectSessionForDay(
    DateTime normalizedDay,
    List<HealthSleepSessionEntity> sessions,
  ) {
    final dayEnd = normalizedDay.add(const Duration(days: 1));
    final sameDaySessions = sessions
        .where(
          (session) =>
              !session.endTime.isBefore(normalizedDay) &&
              session.endTime.isBefore(dayEnd) &&
              session.duration.inMinutes > 0,
        )
        .toList();

    if (sameDaySessions.isEmpty) {
      return null;
    }

    sameDaySessions.sort((left, right) {
      final byDuration = right.duration.compareTo(left.duration);
      if (byDuration != 0) {
        return byDuration;
      }
      return right.endTime.compareTo(left.endTime);
    });

    return sameDaySessions.first;
  }

  double _roundHours(Duration duration) {
    final hours = duration.inMinutes / 60;
    final normalizedHours = hours < 0
        ? 0.0
        : hours > 16
            ? 16.0
            : hours;
    return double.parse(normalizedHours.toStringAsFixed(1));
  }

  PhysicalActivityTypeEntity _mapWorkoutType(String activityCode) {
    if (activityCode.contains('run') || activityCode.contains('walk')) {
      return PhysicalActivityTypeEntity.running;
    }
    if (activityCode.contains('bike') || activityCode.contains('cycling')) {
      return PhysicalActivityTypeEntity.bicycling;
    }
    if (activityCode.contains('swim') || activityCode.contains('row')) {
      return PhysicalActivityTypeEntity.waterActivities;
    }
    if (activityCode.contains('ski')) {
      return PhysicalActivityTypeEntity.winterActivities;
    }
    return PhysicalActivityTypeEntity.conditioningExercise;
  }

  Future<void> _updateTrackedDay(DateTime day) async {
    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(day);
    if (!hasTrackedDay) {
      final totalKcalGoal = await _getKcalGoalUsecase.getKcalGoal(
          totalKcalActivitiesParam: 0); // Exclude persisted activities
      final totalCarbsGoal =
          await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
      final totalFatGoal =
          await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
      final totalProteinGoal =
          await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);

      await _addTrackedDayUsecase.addNewTrackedDay(
          day, totalKcalGoal, totalCarbsGoal, totalFatGoal, totalProteinGoal);
    }

    final totalKcalGoal =
        await _getKcalGoalUsecase.getKcalGoal(totalKcalActivitiesParam: 0);
    final totalCarbsGoal =
        await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
    final totalFatGoal = await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
    final totalProteinGoal =
        await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);

    await _addTrackedDayUsecase.updateDayCalorieGoal(day, totalKcalGoal);
    await _addTrackedDayUsecase.updateDayMacroGoals(
      day,
      carbsGoal: totalCarbsGoal,
      fatGoal: totalFatGoal,
      proteinGoal: totalProteinGoal,
    );
  }
}

enum HealthConnectSyncSkipReason {
  none,
  notAndroid,
  autoSyncDisabled,
  notAvailable,
  permissionsMissing,
  noChanges,
  error,
}

class HealthConnectSyncReport {
  final bool didUpdate;
  final HealthConnectSyncSkipReason reason;
  final int workoutsRead;
  final int workoutsFiltered;
  final int workoutsImported;
  final bool sleepChanged;
  final bool stepsChanged;
  final bool hasActivityRecognition;
  final bool hasStepsPermission;
  final bool hasWorkoutSupplementPermission;

  const HealthConnectSyncReport({
    required this.didUpdate,
    required this.reason,
    this.workoutsRead = 0,
    this.workoutsFiltered = 0,
    this.workoutsImported = 0,
    this.sleepChanged = false,
    this.stepsChanged = false,
    this.hasActivityRecognition = false,
    this.hasStepsPermission = false,
    this.hasWorkoutSupplementPermission = false,
  });
}
