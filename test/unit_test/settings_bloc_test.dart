import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/macro_goal_mode_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/services/meal_reminder_service.dart';
import 'package:macrotracker/core/services/cloud_account_deletion_service.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_connect_sync_status_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/sync_sleep_from_health_connect_usecase.dart';
import 'package:macrotracker/features/settings/presentation/bloc/settings_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsBloc bloc;
  late _FakeGetConfigUsecase fakeGetConfigUsecase;
  late _FakeAddConfigUsecase fakeAddConfigUsecase;
  late _FakeAddTrackedDayUsecase fakeAddTrackedDayUsecase;
  late _FakeGetKcalGoalUsecase fakeGetKcalGoalUsecase;
  late _FakeGetMacroGoalUsecase fakeGetMacroGoalUsecase;
  late _FakeGetUserUsecase fakeGetUserUsecase;
  late _FakeSyncSleepFromHealthConnectUsecase fakeSyncSleepFromHealthConnectUsecase;
  late _FakeMealReminderService fakeMealReminderService;
  late _FakeCloudAccountDeletionService fakeCloudAccountDeletionService;

  final testDay = DateTime(2026, 6, 15);

  setUp(() {
    fakeGetConfigUsecase = _FakeGetConfigUsecase();
    fakeAddConfigUsecase = _FakeAddConfigUsecase();
    fakeAddTrackedDayUsecase = _FakeAddTrackedDayUsecase();
    fakeGetKcalGoalUsecase = _FakeGetKcalGoalUsecase();
    fakeGetMacroGoalUsecase = _FakeGetMacroGoalUsecase();
    fakeGetUserUsecase = _FakeGetUserUsecase();
    fakeSyncSleepFromHealthConnectUsecase = _FakeSyncSleepFromHealthConnectUsecase();
    fakeMealReminderService = _FakeMealReminderService();
    fakeCloudAccountDeletionService = _FakeCloudAccountDeletionService();

    bloc = SettingsBloc(
      fakeGetConfigUsecase,
      fakeAddConfigUsecase,
      fakeAddTrackedDayUsecase,
      fakeGetKcalGoalUsecase,
      fakeGetMacroGoalUsecase,
      fakeGetUserUsecase,
      fakeSyncSleepFromHealthConnectUsecase,
      fakeMealReminderService,
      fakeCloudAccountDeletionService,
    );

    // Mock PackageInfo channel
    const channel = MethodChannel('dev.fluttercommunity.plus/package_info');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return {
          'appName': 'MacroTracker',
          'packageName': 'com.epsait.macrotracker',
          'version': '1.2.3',
          'buildNumber': '45',
          'buildSignature': '',
        };
      }
      return null;
    });
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is SettingsInitial', () {
    expect(bloc.state, isA<SettingsInitial>());
  });

  group('LoadSettingsEvent', () {
    test('emits SettingsLoadingState and SettingsLoadedState with package and config details', () async {
      fakeGetConfigUsecase.config = const ConfigEntity(
        true,
        true,
        true,
        AppThemeEntity.dark,
        usesImperialUnits: true,
        aiEstimatedCostTotalUsd: 1.50,
        aiEstimatedCostTodayUsd: 0.10,
        aiEstimatedCostMonthUsd: 0.50,
        aiTextCallsTotal: 10,
        aiPhotoCallsTotal: 5,
        selectedLocale: 'es',
        healthConnectAutoSyncEnabled: false,
        mealRemindersEnabled: true,
        mealReminderMorningMinutes: 500,
        mealReminderLunchMinutes: 900,
        mealReminderAfternoonMinutes: 1100,
        mealReminderEveningMinutes: 1300,
        macroGoalMode: MacroGoalModeEntity.gramsPerKg,
      );

      final states = <SettingsState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadSettingsEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<SettingsLoadingState>(),
        isA<SettingsLoadedState>(),
      ]);

      final loadedState = states.last as SettingsLoadedState;
      expect(loadedState.versionNumber, '1.2.3');
      expect(loadedState.sendAnonymousData, true);
      expect(loadedState.appTheme, AppThemeEntity.dark);
      expect(loadedState.usesImperialUnits, true);
      expect(loadedState.aiEstimatedCostTotalUsd, 1.50);
      expect(loadedState.aiEstimatedCostTodayUsd, 0.10);
      expect(loadedState.aiEstimatedCostMonthUsd, 0.50);
      expect(loadedState.aiTextCallsTotal, 10);
      expect(loadedState.aiPhotoCallsTotal, 5);
      expect(loadedState.currentLocale, 'es');
      expect(loadedState.healthConnectAutoSyncEnabled, false);
      expect(loadedState.mealRemindersEnabled, true);
      expect(loadedState.mealReminderMorningMinutes, 500);
      expect(loadedState.mealReminderLunchMinutes, 900);
      expect(loadedState.mealReminderAfternoonMinutes, 1100);
      expect(loadedState.mealReminderEveningMinutes, 1300);
      expect(loadedState.macroGoalMode, MacroGoalModeEntity.gramsPerKg);
    });
  });

  group('DeleteAccountEvent', () {
    test('emits loading then deleted state on success', () async {
      final states = <SettingsState>[];
      bloc.stream.listen(states.add);

      bloc.add(DeleteAccountEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(fakeCloudAccountDeletionService.deleteCurrentAccountCalled, true);
      expect(states, [
        isA<SettingsLoadingState>(),
        isA<SettingsAccountDeletedState>(),
      ]);
    });

    test('emits loading then failed state with custom message when deletion throws CloudAccountDeletionException', () async {
      fakeCloudAccountDeletionService.errorToThrow = const CloudAccountDeletionException('API limit reached');

      final states = <SettingsState>[];
      bloc.stream.listen(states.add);

      bloc.add(DeleteAccountEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<SettingsLoadingState>(),
        isA<SettingsAccountDeletionFailedState>().having((s) => s.message, 'message', 'API limit reached'),
      ]);
    });

    test('emits loading then failed state with generic message on generic error', () async {
      fakeCloudAccountDeletionService.errorToThrow = Exception('Network crash');

      final states = <SettingsState>[];
      bloc.stream.listen(states.add);

      bloc.add(DeleteAccountEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<SettingsLoadingState>(),
        isA<SettingsAccountDeletionFailedState>().having((s) => s.message, 'message', 'We could not delete your account right now.'),
      ]);
    });
  });

  group('Config Setters', () {
    test('setHasAcceptedAnonymousData updates config', () async {
      await bloc.setHasAcceptedAnonymousData(false);
      expect(fakeAddConfigUsecase.savedAnonymousData, false);
    });

    test('setAppTheme updates config', () async {
      bloc.setAppTheme(AppThemeEntity.light);
      expect(fakeAddConfigUsecase.savedAppTheme, AppThemeEntity.light);
    });

    test('setLocale updates config', () async {
      bloc.setLocale('en');
      expect(fakeAddConfigUsecase.savedLocale, 'en');
    });

    test('setUsesImperialUnits updates config', () async {
      bloc.setUsesImperialUnits(true);
      expect(fakeAddConfigUsecase.savedUsesImperialUnits, true);
    });

    test('setKcalAdjustment updates config', () async {
      await bloc.setKcalAdjustment(-150);
      expect(fakeAddConfigUsecase.savedKcalAdjustment, -150);
    });

    test('setMacroGoals updates config as fractions', () async {
      await bloc.setMacroGoals(40, 30, 30);
      expect(fakeAddConfigUsecase.savedCarbsGoalPct, 0.40);
      expect(fakeAddConfigUsecase.savedProteinGoalPct, 0.30);
      expect(fakeAddConfigUsecase.savedFatGoalPct, 0.30);
    });

    test('setMacroGoalMode updates config', () async {
      await bloc.setMacroGoalMode(MacroGoalModeEntity.gramsPerKg);
      expect(fakeAddConfigUsecase.savedMacroGoalMode, MacroGoalModeEntity.gramsPerKg);
    });

    test('setMacroGoalsGramPerKg updates config', () async {
      await bloc.setMacroGoalsGramPerKg(3.5, 2.0, 0.8);
      expect(fakeAddConfigUsecase.savedCarbsGoalGram, 3.5);
      expect(fakeAddConfigUsecase.savedProteinGoalGram, 2.0);
      expect(fakeAddConfigUsecase.savedFatGoalGram, 0.8);
    });

    test('resetAiCostTracking updates config', () async {
      await bloc.resetAiCostTracking();
      expect(fakeAddConfigUsecase.aiCostTrackingReset, true);
    });

    test('setHealthConnectAutoSyncEnabled updates config', () async {
      await bloc.setHealthConnectAutoSyncEnabled(true);
      expect(fakeAddConfigUsecase.healthConnectAutoSyncEnabled, true);
    });
  });

  group('Meal Reminder Config & Rollback', () {
    test('returns true and schedules reminders if sync succeeds', () async {
      fakeMealReminderService.syncResult = true;

      final result = await bloc.setMealReminderConfig(
        enabled: true,
        morningMinutes: 480,
        lunchMinutes: 840,
        afternoonMinutes: 1020,
        eveningMinutes: 1260,
      );

      expect(result, true);
      expect(fakeAddConfigUsecase.savedReminderEnabled, true);
      expect(fakeAddConfigUsecase.savedMorningMinutes, 480);
      expect(fakeMealReminderService.syncFromConfigCalled, true);
      expect(fakeMealReminderService.lastRequestPermission, true);
    });

    test('rolls back to disabled if sync fails when reminders are enabled', () async {
      fakeMealReminderService.syncResult = false;

      final result = await bloc.setMealReminderConfig(
        enabled: true,
        morningMinutes: 480,
        lunchMinutes: 840,
        afternoonMinutes: 1020,
        eveningMinutes: 1260,
      );

      expect(result, false);
      // It should initially set config to enabled, but roll back to disabled when sync fails.
      expect(fakeAddConfigUsecase.savedReminderEnabled, false);
    });
  });

  group('Config & User Getters', () {
    test('getKcalAdjustment reads config', () async {
      fakeGetConfigUsecase.config = const ConfigEntity(true, true, true, AppThemeEntity.system, userKcalAdjustment: 250);
      final value = await bloc.getKcalAdjustment();
      expect(value, 250);
    });

    test('getUserCarbGoalPct reads config', () async {
      fakeGetConfigUsecase.config = const ConfigEntity(true, true, true, AppThemeEntity.system, userCarbGoalPct: 0.45);
      final value = await bloc.getUserCarbGoalPct();
      expect(value, 0.45);
    });

    test('getUserProteinGoalPct reads config', () async {
      fakeGetConfigUsecase.config = const ConfigEntity(true, true, true, AppThemeEntity.system, userProteinGoalPct: 0.35);
      final value = await bloc.getUserProteinGoalPct();
      expect(value, 0.35);
    });

    test('getUserFatGoalPct reads config', () async {
      fakeGetConfigUsecase.config = const ConfigEntity(true, true, true, AppThemeEntity.system, userFatGoalPct: 0.20);
      final value = await bloc.getUserFatGoalPct();
      expect(value, 0.20);
    });

    test('getMacroGoalMode reads config', () async {
      fakeGetConfigUsecase.config = const ConfigEntity(true, true, true, AppThemeEntity.system, macroGoalMode: MacroGoalModeEntity.gramsPerKg);
      final value = await bloc.getMacroGoalMode();
      expect(value, MacroGoalModeEntity.gramsPerKg);
    });

    test('getUserCarbGoalGramPerKg reads config', () async {
      fakeGetConfigUsecase.config = const ConfigEntity(true, true, true, AppThemeEntity.system, userCarbGoalGramPerKg: 3.2);
      final value = await bloc.getUserCarbGoalGramPerKg();
      expect(value, 3.2);
    });

    test('getUserProteinGoalGramPerKg reads config', () async {
      fakeGetConfigUsecase.config = const ConfigEntity(true, true, true, AppThemeEntity.system, userProteinGoalGramPerKg: 2.2);
      final value = await bloc.getUserProteinGoalGramPerKg();
      expect(value, 2.2);
    });

    test('getUserFatGoalGramPerKg reads config', () async {
      fakeGetConfigUsecase.config = const ConfigEntity(true, true, true, AppThemeEntity.system, userFatGoalGramPerKg: 1.0);
      final value = await bloc.getUserFatGoalGramPerKg();
      expect(value, 1.0);
    });

    test('getUserWeightKg reads user data', () async {
      fakeGetUserUsecase.user = _buildUser(weightKG: 75.5);
      final value = await bloc.getUserWeightKg();
      expect(value, 75.5);
    });
  });

  group('Health Connect', () {
    test('getHealthConnectStatus delegates to usecase', () async {
      final mockStatus = const HealthConnectSyncStatusEntity(
        isAvailable: true,
        hasHealthPermissions: true,
        hasActivityRecognitionPermission: true,
        isAutoSyncEnabled: true,
      );
      fakeSyncSleepFromHealthConnectUsecase.status = mockStatus;

      final result = await bloc.getHealthConnectStatus();
      expect(result, mockStatus);
    });

    test('requestHealthConnectPermissions delegates to usecase', () async {
      final mockStatus = const HealthConnectSyncStatusEntity(
        isAvailable: true,
        hasHealthPermissions: true,
        hasActivityRecognitionPermission: true,
        isAutoSyncEnabled: true,
      );
      fakeSyncSleepFromHealthConnectUsecase.status = mockStatus;

      final result = await bloc.requestHealthConnectPermissions();
      expect(result, mockStatus);
    });

    test('syncHealthConnectNow delegates to usecase', () async {
      fakeSyncSleepFromHealthConnectUsecase.syncTodayResult = true;

      final result = await bloc.syncHealthConnectNow();
      expect(result, true);
      expect(fakeSyncSleepFromHealthConnectUsecase.syncTodayCalled, true);
    });

    test('syncHealthConnectNowWithReport delegates to usecase', () async {
      final mockReport = const HealthConnectSyncReport(
        didUpdate: true,
        reason: HealthConnectSyncSkipReason.none,
      );
      fakeSyncSleepFromHealthConnectUsecase.syncReport = mockReport;

      final result = await bloc.syncHealthConnectNowWithReport();
      expect(result, mockReport);
    });
  });

  group('updateTrackedDay', () {
    test('updates tracked day targets if hasTrackedDay is true', () async {
      fakeAddTrackedDayUsecase.hasDay = true;
      fakeGetConfigUsecase.config = const ConfigEntity(
        true,
        true,
        true,
        AppThemeEntity.system,
        usesImperialUnits: false,
        dailyFocus: DailyFocusEntity.lowerBody,
        macroGoalMode: MacroGoalModeEntity.percentage,
      );

      fakeGetUserUsecase.user = _buildUser(heightCM: 180, weightKG: 80, goal: UserWeightGoalEntity.maintainWeight);
      fakeGetKcalGoalUsecase.kcalGoal = 2000;
      fakeGetMacroGoalUsecase.carbsGoal = 200;
      fakeGetMacroGoalUsecase.fatGoal = 50;
      fakeGetMacroGoalUsecase.proteinGoal = 150;

      bloc.updateTrackedDay(testDay);
      await Future.delayed(const Duration(milliseconds: 10));

      // 2000 kcal * DailyFocusEntity.lowerBody scale 1.1 = 2200 kcal
      expect(fakeAddTrackedDayUsecase.updatedCalorieGoal, 2200.0);
      expect(fakeAddTrackedDayUsecase.updatedCarbsGoal, 220.0);
      expect(fakeAddTrackedDayUsecase.updatedFatGoal, 55.0);
      expect(fakeAddTrackedDayUsecase.updatedProteinGoal, 165.0);
    });

    test('skips updating targets if hasTrackedDay is false', () async {
      fakeAddTrackedDayUsecase.hasDay = false;
      fakeGetUserUsecase.user = _buildUser(heightCM: 180, weightKG: 80);

      bloc.updateTrackedDay(testDay);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(fakeAddTrackedDayUsecase.updatedCalorieGoal, isNull);
    });
  });
}

UserEntity _buildUser({
  double heightCM = 180,
  double weightKG = 80,
  UserWeightGoalEntity goal = UserWeightGoalEntity.maintainWeight,
}) {
  return UserEntity(
    birthday: DateTime(2000, 1, 1),
    heightCM: heightCM,
    weightKG: weightKG,
    gender: UserGenderEntity.male,
    goal: goal,
    pal: UserPALEntity.active,
    targetSteps: 8000,
    targetSleepHours: 8,
    targetWaterLiters: 2.5,
  );
}

class _FakeGetConfigUsecase implements GetConfigUsecase {
  ConfigEntity config = const ConfigEntity(
    true,
    true,
    true,
    AppThemeEntity.system,
  );

  @override
  Future<ConfigEntity> getConfig() async => config;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddConfigUsecase implements AddConfigUsecase {
  bool? savedAnonymousData;
  AppThemeEntity? savedAppTheme;
  String? savedLocale;
  bool? savedUsesImperialUnits;
  double? savedKcalAdjustment;
  double? savedCarbsGoalPct;
  double? savedProteinGoalPct;
  double? savedFatGoalPct;
  MacroGoalModeEntity? savedMacroGoalMode;
  double? savedCarbsGoalGram;
  double? savedProteinGoalGram;
  double? savedFatGoalGram;
  bool? aiCostTrackingReset;
  bool? healthConnectAutoSyncEnabled;

  bool? savedReminderEnabled;
  int? savedMorningMinutes;
  int? savedLunchMinutes;
  int? savedAfternoonMinutes;
  int? savedEveningMinutes;

  @override
  Future<void> setConfigHasAcceptedAnonymousData(bool value) async {
    savedAnonymousData = value;
  }

  @override
  Future<void> setConfigAppTheme(AppThemeEntity value) async {
    savedAppTheme = value;
  }

  @override
  Future<void> setConfigLocale(String? value) async {
    savedLocale = value;
  }

  @override
  Future<void> setConfigUsesImperialUnits(bool value) async {
    savedUsesImperialUnits = value;
  }

  @override
  Future<void> setConfigKcalAdjustment(double value) async {
    savedKcalAdjustment = value;
  }

  @override
  Future<void> setConfigMacroGoalPct(double carbs, double protein, double fat) async {
    savedCarbsGoalPct = carbs;
    savedProteinGoalPct = protein;
    savedFatGoalPct = fat;
  }

  @override
  Future<void> setMacroGoalMode(MacroGoalModeEntity value) async {
    savedMacroGoalMode = value;
  }

  @override
  Future<void> setConfigMacroGoalGramPerKg(double carbs, double protein, double fat) async {
    savedCarbsGoalGram = carbs;
    savedProteinGoalGram = protein;
    savedFatGoalGram = fat;
  }

  @override
  Future<void> resetAiCostTracking() async {
    aiCostTrackingReset = true;
  }

  @override
  Future<void> setHealthConnectAutoSyncEnabled(bool value) async {
    healthConnectAutoSyncEnabled = value;
  }

  @override
  Future<void> setMealReminderConfig({
    required bool enabled,
    required int morningMinutes,
    required int lunchMinutes,
    required int afternoonMinutes,
    required int eveningMinutes,
  }) async {
    savedReminderEnabled = enabled;
    savedMorningMinutes = morningMinutes;
    savedLunchMinutes = lunchMinutes;
    savedAfternoonMinutes = afternoonMinutes;
    savedEveningMinutes = eveningMinutes;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddTrackedDayUsecase implements AddTrackedDayUsecase {
  bool hasDay = false;
  double? updatedCalorieGoal;
  double? updatedCarbsGoal;
  double? updatedFatGoal;
  double? updatedProteinGoal;

  @override
  Future<bool> hasTrackedDay(DateTime day) async => hasDay;

  @override
  Future<void> updateDayCalorieGoal(DateTime day, double goal) async {
    updatedCalorieGoal = goal;
  }

  @override
  Future<void> updateDayMacroGoals(
    DateTime day, {
    double? carbsGoal,
    double? fatGoal,
    double? proteinGoal,
  }) async {
    updatedCarbsGoal = carbsGoal;
    updatedFatGoal = fatGoal;
    updatedProteinGoal = proteinGoal;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetKcalGoalUsecase implements GetKcalGoalUsecase {
  double kcalGoal = 2000;

  @override
  Future<double> getKcalGoal({
    UserEntity? userEntity,
    double? totalKcalActivitiesParam,
    double? kcalUserAdjustment,
  }) async => kcalGoal;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetMacroGoalUsecase implements GetMacroGoalUsecase {
  double carbsGoal = 250;
  double fatGoal = 65;
  double proteinGoal = 150;

  @override
  Future<double> getCarbsGoal(double kcal) async => carbsGoal;

  @override
  Future<double> getFatsGoal(double kcal) async => fatGoal;

  @override
  Future<double> getProteinsGoal(double kcal) async => proteinGoal;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetUserUsecase implements GetUserUsecase {
  UserEntity user = _buildUser();

  @override
  Future<UserEntity> getUserData() async => user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSyncSleepFromHealthConnectUsecase implements SyncSleepFromHealthConnectUsecase {
  HealthConnectSyncStatusEntity status = const HealthConnectSyncStatusEntity(
    isAvailable: false,
    hasHealthPermissions: false,
    hasActivityRecognitionPermission: false,
    isAutoSyncEnabled: false,
  );

  bool syncTodayResult = false;
  bool syncTodayCalled = false;
  HealthConnectSyncReport syncReport = const HealthConnectSyncReport(
    didUpdate: false,
    reason: HealthConnectSyncSkipReason.none,
  );

  @override
  Future<HealthConnectSyncStatusEntity> getStatus() async => status;

  @override
  Future<HealthConnectSyncStatusEntity> requestPermissions() async => status;

  @override
  Future<bool> syncToday({
    bool requestPermissionsIfNeeded = true,
    bool ignoreAutoSyncSetting = false,
  }) async {
    syncTodayCalled = true;
    return syncTodayResult;
  }

  @override
  Future<HealthConnectSyncReport> syncDayWithReport(
    DateTime day, {
    bool requestPermissionsIfNeeded = true,
    bool ignoreAutoSyncSetting = false,
  }) async => syncReport;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMealReminderService implements MealReminderService {
  bool syncResult = true;
  bool syncFromConfigCalled = false;
  bool lastRequestPermission = false;

  @override
  Future<bool> syncFromConfig({bool requestPermissionIfNeeded = false}) async {
    syncFromConfigCalled = true;
    lastRequestPermission = requestPermissionIfNeeded;
    return syncResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCloudAccountDeletionService implements CloudAccountDeletionService {
  Object? errorToThrow;
  bool deleteCurrentAccountCalled = false;

  @override
  Future<void> deleteCurrentAccount() async {
    deleteCurrentAccountCalled = true;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
