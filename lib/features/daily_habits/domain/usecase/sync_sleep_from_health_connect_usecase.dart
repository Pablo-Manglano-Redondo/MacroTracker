import 'dart:io';

import 'package:logging/logging.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/domain/entity/physical_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_user_activity_usercase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/features/daily_habits/data/data_source/health_connect_sleep_data_source.dart';
import 'package:macrotracker/features/daily_habits/data/repository/daily_habit_log_repository.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_connect_sync_status_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_sleep_session_entity.dart';

class SyncSleepFromHealthConnectUsecase {
  final _log = Logger('SyncSleepFromHealthConnectUsecase');
  static const _workoutSyncLookbackDays = 7;

  final HealthConnectSleepDataSource _healthConnectSleepDataSource;
  final DailyHabitLogRepository _dailyHabitLogRepository;
  final ConfigRepository _configRepository;
  final AddUserActivityUsecase _addUserActivityUsecase;
  final GetUserActivityUsecase _getUserActivityUsecase;

  bool _authorizationRequestedThisLaunch = false;
  bool _activityPermissionRequestedThisLaunch = false;

  SyncSleepFromHealthConnectUsecase(
    this._healthConnectSleepDataSource,
    this._dailyHabitLogRepository,
    this._configRepository,
    this._addUserActivityUsecase,
    this._getUserActivityUsecase,
  );

  Future<bool> syncToday({
    bool requestPermissionsIfNeeded = true,
    bool ignoreAutoSyncSetting = false,
  }) async {
    return syncDay(
      DateTime.now(),
      requestPermissionsIfNeeded: requestPermissionsIfNeeded,
      ignoreAutoSyncSetting: ignoreAutoSyncSetting,
    );
  }

  Future<bool> syncDay(
    DateTime day, {
    bool requestPermissionsIfNeeded = true,
    bool ignoreAutoSyncSetting = false,
  }) async {
    try {
      if (!Platform.isAndroid) {
        return false;
      }

      final config = await _configRepository.getConfig();
      if (!ignoreAutoSyncSetting && !config.healthConnectAutoSyncEnabled) {
        _log.fine('Health Connect auto sync disabled by user');
        return false;
      }

      final normalizedDay = DateTime(day.year, day.month, day.day);
      final dayEnd = normalizedDay.add(const Duration(days: 1));

      await _healthConnectSleepDataSource.configure();

      if (!await _healthConnectSleepDataSource.isAvailable()) {
        _log.fine('Health Connect is not available on this device');
        return false;
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
        return false;
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
      final syncedSteps = hasActivityRecognition
          ? await _healthConnectSleepDataSource.readStepCount(
              normalizedDay,
              dayEnd,
            )
          : currentLog.steps;
      final workouts = await _healthConnectSleepDataSource.readWorkouts(
        normalizedDay.subtract(const Duration(days: _workoutSyncLookbackDays)),
        dayEnd,
      );
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

      final forceSync = ignoreAutoSyncSetting;
      final sleepChanged = syncedSleepHours != null &&
          ((currentLog.sleepHours - syncedSleepHours).abs() >= 0.01 ||
              (forceSync && currentLog.sleepSyncedFromHealthConnect != true));
      final stepsChanged = hasActivityRecognition &&
          (currentLog.steps != syncedSteps ||
              (forceSync && currentLog.stepsSyncedFromHealthConnect != true));

      if (!hasActivityRecognition) {
        _log.fine(
          'Activity recognition permission not granted. '
          'Skipping steps sync but continuing with sleep/workouts.',
        );
      }

      if (!sleepChanged && !stepsChanged && workouts.isEmpty) {
        return false;
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
        'workoutsRead=${workouts.length}',
      );
      var importedWorkouts = 0;
      for (final workout in workouts) {
        if (existingExternalIds.contains(workout.externalId) ||
            discardedIds.contains(workout.externalId)) {
          continue;
        }

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
        existingExternalIds.add(workout.externalId);
        importedWorkouts++;
      }
      _log.info('Imported $importedWorkouts Health Connect workouts');
      return sleepChanged || stepsChanged || importedWorkouts > 0;
    } catch (error, stackTrace) {
      _log.warning('Health Connect sync failed', error, stackTrace);
      return false;
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

      return HealthConnectSyncStatusEntity(
        isAvailable: true,
        hasHealthPermissions: hasHealthPermissions,
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
}
