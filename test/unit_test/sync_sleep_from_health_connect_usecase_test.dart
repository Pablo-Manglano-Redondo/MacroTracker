import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/sync_sleep_from_health_connect_usecase.dart';
import 'package:macrotracker/features/daily_habits/data/data_source/health_connect_sleep_data_source.dart';
import 'package:macrotracker/features/daily_habits/data/repository/daily_habit_log_repository.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/domain/usecase/add_user_activity_usercase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/core/data/repository/user_activity_repository.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';

import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_sleep_session_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_connect_workout_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/physical_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';


void main() {
  group('SyncSleepFromHealthConnectUsecase', () {
    late SyncSleepFromHealthConnectUsecase usecase;
    late _FakeHealthConnectSleepDataSource fakeSleepDataSource;
    late _FakeDailyHabitLogRepository fakeDailyHabitLogRepository;
    late _FakeConfigRepository fakeConfigRepository;
    late _FakeAddUserActivityUsecase fakeAddUserActivityUsecase;
    late _FakeGetUserActivityUsecase fakeGetUserActivityUsecase;
    late _FakeUserActivityRepository fakeUserActivityRepository;
    late _FakeAddTrackedDayUsecase fakeAddTrackedDayUsecase;
    late _FakeGetMacroGoalUsecase fakeGetMacroGoalUsecase;
    late _FakeGetKcalGoalUsecase fakeGetKcalGoalUsecase;

    final testDay = DateTime(2026, 6, 15);

    setUp(() {
      fakeSleepDataSource = _FakeHealthConnectSleepDataSource();
      fakeDailyHabitLogRepository = _FakeDailyHabitLogRepository();
      fakeConfigRepository = _FakeConfigRepository();
      fakeAddUserActivityUsecase = _FakeAddUserActivityUsecase();
      fakeGetUserActivityUsecase = _FakeGetUserActivityUsecase();
      fakeUserActivityRepository = _FakeUserActivityRepository();
      fakeAddTrackedDayUsecase = _FakeAddTrackedDayUsecase();
      fakeGetMacroGoalUsecase = _FakeGetMacroGoalUsecase();
      fakeGetKcalGoalUsecase = _FakeGetKcalGoalUsecase();

      usecase = SyncSleepFromHealthConnectUsecase(
        fakeSleepDataSource,
        fakeDailyHabitLogRepository,
        fakeConfigRepository,
        fakeAddUserActivityUsecase,
        fakeGetUserActivityUsecase,
        fakeUserActivityRepository,
        fakeAddTrackedDayUsecase,
        fakeGetMacroGoalUsecase,
        fakeGetKcalGoalUsecase,
      );
    });

    test('returns notAndroid when platform is not android/ios and debug bypass is false', () async {
      usecase.debugBypassPlatformCheck = false;
      final report = await usecase.syncDayWithReport(testDay);

      expect(report.didUpdate, isFalse);
      expect(report.reason, HealthConnectSyncSkipReason.notAndroid);
    });

    test('returns autoSyncDisabled when auto sync is disabled in config', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeConfigRepository.healthConnectAutoSyncEnabled = false;

      final report = await usecase.syncDayWithReport(
        testDay,
        ignoreAutoSyncSetting: false,
      );

      expect(report.didUpdate, isFalse);
      expect(report.reason, HealthConnectSyncSkipReason.autoSyncDisabled);
    });

    test('proceeds when auto sync is disabled but ignoreAutoSyncSetting is true', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeConfigRepository.healthConnectAutoSyncEnabled = false;
      fakeSleepDataSource.isHcAvailable = false; // should skip at availability check

      final report = await usecase.syncDayWithReport(
        testDay,
        ignoreAutoSyncSetting: true,
      );

      expect(report.didUpdate, isFalse);
      expect(report.reason, HealthConnectSyncSkipReason.notAvailable);
    });

    test('returns notAvailable when Health Connect is not available on device', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.isHcAvailable = false;

      final report = await usecase.syncDayWithReport(testDay);

      expect(report.didUpdate, isFalse);
      expect(report.reason, HealthConnectSyncSkipReason.notAvailable);
      expect(fakeSleepDataSource.configureCalled, isTrue);
    });

    test('returns permissionsMissing when read permissions are denied and requestPermissionsIfNeeded is false', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.isHcAvailable = true;
      fakeSleepDataSource.hasReadPerm = false;

      final report = await usecase.syncDayWithReport(
        testDay,
        requestPermissionsIfNeeded: false,
      );

      expect(report.didUpdate, isFalse);
      expect(report.reason, HealthConnectSyncSkipReason.permissionsMissing);
      expect(fakeSleepDataSource.requestReadPermissionCalled, isFalse);
    });

    test('requests read permission when permissions are missing and requestPermissionsIfNeeded is true', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.isHcAvailable = true;
      fakeSleepDataSource.hasReadPerm = false;

      final report = await usecase.syncDayWithReport(
        testDay,
        requestPermissionsIfNeeded: true,
      );

      expect(report.didUpdate, isFalse);
      expect(report.reason, HealthConnectSyncSkipReason.permissionsMissing);
      expect(fakeSleepDataSource.requestReadPermissionCalled, isTrue);
    });

    test('requests activity, steps, and workout permissions if missing', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.isHcAvailable = true;
      fakeSleepDataSource.hasReadPerm = true;
      fakeSleepDataSource.hasActivityPerm = false;
      fakeSleepDataSource.hasStepsPerm = false;
      fakeSleepDataSource.hasWorkoutSupplementPerm = false;

      await usecase.syncDayWithReport(
        testDay,
        requestPermissionsIfNeeded: true,
      );

      expect(fakeSleepDataSource.requestActivityPermissionCalled, isTrue);
      expect(fakeSleepDataSource.requestStepsPermissionCalled, isTrue);
      expect(fakeSleepDataSource.requestWorkoutSupplementPermissionCalled, isTrue);
    });

    test('returns noChanges when sleep, steps, and workouts have not changed', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.isHcAvailable = true;
      fakeSleepDataSource.hasReadPerm = true;
      fakeSleepDataSource.hasActivityPerm = true;
      fakeSleepDataSource.hasStepsPerm = true;

      // Existing log has sleep 8.0, steps 5000
      final existingLog = DailyHabitLogEntity(
        day: testDay,
        sleepHours: 8.0,
        steps: 5000,
        sleepSyncedFromHealthConnect: true,
        stepsSyncedFromHealthConnect: true,
      );
      await fakeDailyHabitLogRepository.saveLog(existingLog);

      // Synced sleep 8.0, steps 5000
      fakeSleepDataSource.sleepSessions = [
        HealthSleepSessionEntity(
          startTime: DateTime(2026, 6, 14, 22),
          endTime: DateTime(2026, 6, 15, 6), // 8 hours
        )
      ];
      fakeSleepDataSource.stepsCount = 5000;

      final report = await usecase.syncDayWithReport(testDay);

      expect(report.didUpdate, isFalse);
      expect(report.reason, HealthConnectSyncSkipReason.noChanges);
    });

    test('updates sleep and steps in log when they change', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.isHcAvailable = true;
      fakeSleepDataSource.hasReadPerm = true;
      fakeSleepDataSource.hasActivityPerm = true;
      fakeSleepDataSource.hasStepsPerm = true;

      final existingLog = DailyHabitLogEntity(
        day: testDay,
        sleepHours: 6.0,
        steps: 3000,
        sleepSyncedFromHealthConnect: false,
        stepsSyncedFromHealthConnect: false,
      );
      await fakeDailyHabitLogRepository.saveLog(existingLog);

      fakeSleepDataSource.sleepSessions = [
        HealthSleepSessionEntity(
          startTime: DateTime(2026, 6, 14, 23),
          endTime: DateTime(2026, 6, 15, 7, 30), // 8.5 hours
        )
      ];
      fakeSleepDataSource.stepsCount = 10000;

      final report = await usecase.syncDayWithReport(testDay);

      expect(report.didUpdate, isTrue);
      expect(report.sleepChanged, isTrue);
      expect(report.stepsChanged, isTrue);

      final updatedLog = await fakeDailyHabitLogRepository.getLog(testDay);
      expect(updatedLog?.sleepHours, 8.5);
      expect(updatedLog?.steps, 10000);
      expect(updatedLog?.sleepSyncedFromHealthConnect, isTrue);
      expect(updatedLog?.stepsSyncedFromHealthConnect, isTrue);
    });

    test('selects the longest sleep session for the day', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.isHcAvailable = true;
      fakeSleepDataSource.hasReadPerm = true;

      // Two sessions on same day
      fakeSleepDataSource.sleepSessions = [
        HealthSleepSessionEntity(
          startTime: DateTime(2026, 6, 15, 14),
          endTime: DateTime(2026, 6, 15, 15), // 1 hour nap
        ),
        HealthSleepSessionEntity(
          startTime: DateTime(2026, 6, 14, 23),
          endTime: DateTime(2026, 6, 15, 7), // 8 hours
        ),
      ];

      final report = await usecase.syncDayWithReport(testDay);

      expect(report.didUpdate, isTrue);
      final updatedLog = await fakeDailyHabitLogRepository.getLog(testDay);
      expect(updatedLog?.sleepHours, 8.0);
    });

    test('syncs and imports new workouts correctly, updating tracked day goals', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.isHcAvailable = true;
      fakeSleepDataSource.hasReadPerm = true;

      // Workout for today
      fakeSleepDataSource.workouts = [
        HealthConnectWorkoutEntity(
          externalId: 'w1',
          activityCode: 'hc:running',
          displayName: 'Running',
          description: 'Outdoor Run',
          startTime: DateTime(2026, 6, 15, 8),
          endTime: DateTime(2026, 6, 15, 8, 45),
          durationMinutes: 45.0,
          burnedKcal: 500.0,
        )
      ];

      fakeGetUserActivityUsecase.activities = [];

      final report = await usecase.syncDayWithReport(testDay);

      expect(report.didUpdate, isTrue);
      expect(report.workoutsImported, 1);
      expect(fakeAddUserActivityUsecase.addedActivities, hasLength(1));

      final imported = fakeAddUserActivityUsecase.addedActivities.first;
      expect(imported.externalId, 'w1');
      expect(imported.duration, 45.0);
      expect(imported.burnedKcal, 500.0);
      expect(imported.physicalActivityEntity.code, 'hc:running');

      // Tracked day should have been updated/added
      expect(fakeAddTrackedDayUsecase.trackedDays.contains(testDay), isTrue);
      expect(fakeAddTrackedDayUsecase.kcalGoals[testDay], 2000.0);
    });

    test('updates/repairs modified workouts on sync', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.isHcAvailable = true;
      fakeSleepDataSource.hasReadPerm = true;

      // Existing workout in DB with ID w1, but duration/kcal differs from what's now in HC
      final existingActivity = UserActivityEntity(
        'existing_id',
        30.0,
        300.0,
        testDay,
        PhysicalActivityEntity(
          'hc:running',
          'Running',
          'Outdoor Run',
          0,
          const ['health-connect'],
          PhysicalActivityTypeEntity.running,
        ),
        source: UserActivitySourceEntity.healthConnect,
        externalId: 'w1',
      );
      fakeGetUserActivityUsecase.activities = [existingActivity];

      // New workout stats in Health Connect for w1
      fakeSleepDataSource.workouts = [
        HealthConnectWorkoutEntity(
          externalId: 'w1',
          activityCode: 'hc:running',
          displayName: 'Running',
          description: 'Outdoor Run',
          startTime: DateTime(2026, 6, 15, 8),
          endTime: DateTime(2026, 6, 15, 8, 45), // duration changed to 45 mins
          durationMinutes: 45.0,
          burnedKcal: 450.0,
        )
      ];

      final report = await usecase.syncDayWithReport(testDay);

      expect(report.didUpdate, isTrue);
      expect(report.workoutsUpdated, 1);
      expect(report.workoutsImported, 1);
      expect(fakeUserActivityRepository.deletedActivities, hasLength(1));
      expect(fakeUserActivityRepository.deletedActivities.first.externalId, 'w1');
      expect(fakeAddUserActivityUsecase.addedActivities, hasLength(1));
      expect(fakeAddUserActivityUsecase.addedActivities.first.duration, 45.0);
    });

    test('syncToday calls syncDayWithReport internally', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.isHcAvailable = false; // quick skip

      final didUpdate = await usecase.syncToday();
      expect(didUpdate, isFalse);
    });

    test('syncDay returns didUpdate status', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.isHcAvailable = false; // quick skip

      final didUpdate = await usecase.syncDay(testDay);
      expect(didUpdate, isFalse);
    });

    test('getStatus returns correct status entity', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.isHcAvailable = true;
      fakeSleepDataSource.hasReadPerm = true;
      fakeSleepDataSource.hasStepsPerm = true;
      fakeSleepDataSource.hasWorkoutSupplementPerm = true;
      fakeSleepDataSource.hasActivityPerm = true;
      fakeConfigRepository.healthConnectAutoSyncEnabled = true;

      final status = await usecase.getStatus();

      expect(status.isAvailable, isTrue);
      expect(status.hasHealthPermissions, isTrue);
      expect(status.hasActivityRecognitionPermission, isTrue);
      expect(status.hasStepsPermission, isTrue);
      expect(status.hasWorkoutSupplementPermission, isTrue);
      expect(status.isAutoSyncEnabled, isTrue);
    });

    test('getStatus returns isAvailable false when platform is not supported', () async {
      usecase.debugBypassPlatformCheck = false; // running on Windows test host
      final status = await usecase.getStatus();

      expect(status.isAvailable, isFalse);
    });

    test('setAutoSyncEnabled updates config repository', () async {
      await usecase.setAutoSyncEnabled(false);
      expect(fakeConfigRepository.healthConnectAutoSyncEnabled, isFalse);

      await usecase.setAutoSyncEnabled(true);
      expect(fakeConfigRepository.healthConnectAutoSyncEnabled, isTrue);
    });

    test('requestPermissions triggers permission flows and returns status', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.isHcAvailable = true;
      fakeSleepDataSource.hasReadPerm = false;
      fakeSleepDataSource.hasActivityPerm = false;
      fakeSleepDataSource.hasStepsPerm = false;
      fakeSleepDataSource.hasWorkoutSupplementPerm = false;

      final status = await usecase.requestPermissions();

      expect(fakeSleepDataSource.requestReadPermissionCalled, isTrue);
      expect(fakeSleepDataSource.requestActivityPermissionCalled, isTrue);
      expect(fakeSleepDataSource.requestStepsPermissionCalled, isTrue);
      expect(fakeSleepDataSource.requestWorkoutSupplementPermissionCalled, isTrue);
      expect(status.isAvailable, isTrue);
    });

    test('requestPermissions returns unavailable on unsupported platform', () async {
      usecase.debugBypassPlatformCheck = false;
      final status = await usecase.requestPermissions();
      expect(status.isAvailable, isFalse);
    });

    test('returns error skip reason when exception is thrown during sync', () async {
      usecase.debugBypassPlatformCheck = true;
      // Throw exception on isAvailable call
      fakeSleepDataSource.isHcAvailable = true;
      fakeSleepDataSource.throwOnConfigure = true;

      final report = await usecase.syncDayWithReport(testDay);

      expect(report.didUpdate, isFalse);
      expect(report.reason, HealthConnectSyncSkipReason.error);
    });

    test('getStatus returns default false status when exception is thrown', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.throwOnConfigure = true;

      final status = await usecase.getStatus();

      expect(status.isAvailable, isFalse);
    });

    test('requestPermissions returns default false status when exception is thrown', () async {
      usecase.debugBypassPlatformCheck = true;
      fakeSleepDataSource.throwOnConfigure = true;

      final status = await usecase.requestPermissions();

      expect(status.isAvailable, isFalse);
    });
  });
}

class _FakeHealthConnectSleepDataSource implements HealthConnectSleepDataSource {
  bool isHcAvailable = true;
  bool hasReadPerm = true;
  bool hasActivityPerm = true;
  bool hasStepsPerm = true;
  bool hasWorkoutSupplementPerm = true;

  List<HealthSleepSessionEntity> sleepSessions = [];
  int stepsCount = 0;
  List<HealthConnectWorkoutEntity> workouts = [];

  bool configureCalled = false;
  bool requestReadPermissionCalled = false;
  bool requestActivityPermissionCalled = false;
  bool requestStepsPermissionCalled = false;
  bool requestWorkoutSupplementPermissionCalled = false;

  bool throwOnConfigure = false;

  @override
  Future<void> configure() async {
    configureCalled = true;
    if (throwOnConfigure) {
      throw Exception('Mock Configuration Failure');
    }
  }

  @override
  Future<bool> isAvailable() async => isHcAvailable;

  @override
  Future<bool> hasReadPermission() async => hasReadPerm;

  @override
  Future<bool> requestReadPermission() async {
    requestReadPermissionCalled = true;
    return hasReadPerm;
  }

  @override
  Future<bool> hasActivityRecognitionPermission() async => hasActivityPerm;

  @override
  Future<bool> requestActivityRecognitionPermission() async {
    requestActivityPermissionCalled = true;
    return hasActivityPerm;
  }

  @override
  Future<bool> hasStepsReadPermission() async => hasStepsPerm;

  @override
  Future<bool> requestStepsReadPermission() async {
    requestStepsPermissionCalled = true;
    return hasStepsPerm;
  }

  @override
  Future<bool> hasWorkoutSupplementReadPermission() async => hasWorkoutSupplementPerm;

  @override
  Future<bool> requestWorkoutSupplementReadPermission() async {
    requestWorkoutSupplementPermissionCalled = true;
    return hasWorkoutSupplementPerm;
  }

  @override
  Future<List<HealthSleepSessionEntity>> readSleepSessions(DateTime startTime, DateTime endTime) async {
    return sleepSessions;
  }

  @override
  Future<int> readStepCount(DateTime startTime, DateTime endTime) async {
    return stepsCount;
  }

  @override
  Future<List<HealthConnectWorkoutEntity>> readWorkouts(DateTime startTime, DateTime endTime) async {
    return workouts;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDailyHabitLogRepository implements DailyHabitLogRepository {
  final logs = <DateTime, DailyHabitLogEntity>{};

  @override
  Future<DailyHabitLogEntity?> getLog(DateTime day) async {
    final normalized = DateTime(day.year, day.month, day.day);
    return logs[normalized];
  }

  @override
  Future<void> saveLog(DailyHabitLogEntity log) async {
    final normalized = DateTime(log.day.year, log.day.month, log.day.day);
    logs[normalized] = log;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConfigRepository implements ConfigRepository {
  bool healthConnectAutoSyncEnabled = true;
  final discardedWorkoutIds = <String>{};

  @override
  Future<ConfigEntity> getConfig() async {
    return ConfigEntity(
      true,
      true,
      true,
      AppThemeEntity.system,
      healthConnectAutoSyncEnabled: healthConnectAutoSyncEnabled,
    );
  }

  @override
  Future<void> setHealthConnectAutoSyncEnabled(bool enabled) async {
    healthConnectAutoSyncEnabled = enabled;
  }

  @override
  Future<List<String>> getDiscardedHealthConnectActivityIds() async {
    return discardedWorkoutIds.toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddUserActivityUsecase implements AddUserActivityUsecase {
  final addedActivities = <UserActivityEntity>[];

  @override
  Future<void> addUserActivity(UserActivityEntity activity) async {
    addedActivities.add(activity);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetUserActivityUsecase implements GetUserActivityUsecase {
  List<UserActivityEntity> activities = [];

  @override
  Future<List<UserActivityEntity>> getAllUserActivity() async {
    return activities;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserActivityRepository implements UserActivityRepository {
  final deletedActivities = <UserActivityEntity>[];

  @override
  Future<void> deleteUserActivity(UserActivityEntity activity) async {
    deletedActivities.add(activity);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddTrackedDayUsecase implements AddTrackedDayUsecase {
  final trackedDays = <DateTime>{};
  final kcalGoals = <DateTime, double>{};
  final carbsGoals = <DateTime, double>{};
  final fatGoals = <DateTime, double>{};
  final proteinGoals = <DateTime, double>{};

  @override
  Future<bool> hasTrackedDay(DateTime day) async {
    final normalized = DateTime(day.year, day.month, day.day);
    return trackedDays.contains(normalized);
  }

  @override
  Future<void> addNewTrackedDay(
    DateTime day,
    double kcalGoal,
    double carbsGoal,
    double fatGoal,
    double proteinGoal,
  ) async {
    final normalized = DateTime(day.year, day.month, day.day);
    trackedDays.add(normalized);
    kcalGoals[normalized] = kcalGoal;
    carbsGoals[normalized] = carbsGoal;
    fatGoals[normalized] = fatGoal;
    proteinGoals[normalized] = proteinGoal;
  }

  @override
  Future<void> updateDayCalorieGoal(DateTime day, double kcalGoal) async {
    final normalized = DateTime(day.year, day.month, day.day);
    kcalGoals[normalized] = kcalGoal;
  }

  @override
  Future<void> updateDayMacroGoals(
    DateTime day, {
    double? carbsGoal,
    double? fatGoal,
    double? proteinGoal,
  }) async {
    final normalized = DateTime(day.year, day.month, day.day);
    if (carbsGoal != null) carbsGoals[normalized] = carbsGoal;
    if (fatGoal != null) fatGoals[normalized] = fatGoal;
    if (proteinGoal != null) proteinGoals[normalized] = proteinGoal;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetMacroGoalUsecase implements GetMacroGoalUsecase {
  @override
  Future<double> getCarbsGoal(double kcalGoal) async => kcalGoal * 0.4 / 4;

  @override
  Future<double> getFatsGoal(double kcalGoal) async => kcalGoal * 0.3 / 9;

  @override
  Future<double> getProteinsGoal(double kcalGoal) async => kcalGoal * 0.3 / 4;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetKcalGoalUsecase implements GetKcalGoalUsecase {
  @override
  Future<double> getKcalGoal({
    UserEntity? userEntity,
    double? totalKcalActivitiesParam,
    double? kcalUserAdjustment,
  }) async => 2000.0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
