import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:macrotracker/core/data/data_source/config_data_source.dart';
import 'package:macrotracker/core/data/data_source/tracked_day_data_source.dart';
import 'package:macrotracker/core/data/data_source/user_activity_data_source.dart';
import 'package:macrotracker/core/data/dbo/tracked_day_dbo.dart';
import 'package:macrotracker/core/data/dbo/user_activity_dbo.dart';
import 'package:macrotracker/core/data/dbo/physical_activity_dbo.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/data/repository/tracked_day_repository.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/macro_goal_mode_entity.dart';
import 'package:macrotracker/core/domain/entity/training_day_template_entity.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';

void main() {
  group('Core Repositories and UserActivityDataSource Tests', () {
    late Directory tempDir;
    late HiveDBProvider hiveProvider;
    late ConfigRepository configRepo;
    late TrackedDayRepository trackedDayRepo;
    late UserActivityDataSource userActivityDs;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp
          .createTemp('macrotracker_core_repos_test_');

      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return tempDir.path;
      });

      hiveProvider = HiveDBProvider();
      final key = Hive.generateSecureKey();
      await hiveProvider.initHiveDB(Uint8List.fromList(key));

      final configDs = ConfigDataSource(hiveProvider.configBox);
      await configDs.initializeConfig();
      configRepo = ConfigRepository(configDs);

      final trackedDayDs = TrackedDayDataSource(hiveProvider.trackedDayBox);
      trackedDayRepo = TrackedDayRepository(trackedDayDs);

      userActivityDs = UserActivityDataSource(hiveProvider.userActivityBox);
    });

    tearDown(() async {
      await hiveProvider.clearAllData();
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // ── ConfigRepository ──────────────────────────────────────────────────────
    group('ConfigRepository', () {
      test('Initial default config fields mapping', () async {
        final config = await configRepo.getConfig();
        expect(config.hasAcceptedDisclaimer, isFalse);
        expect(config.appTheme, equals(AppThemeEntity.system));
      });

      test('disclaimer, anonymous data, locale, theme setters and getters',
          () async {
        await configRepo.setConfigDisclaimer(true);
        expect((await configRepo.getConfig()).hasAcceptedDisclaimer, isTrue);

        await configRepo.setConfigHasAcceptedAnonymousData(true);
        expect(await configRepo.getConfigHasAcceptedAnonymousData(), isTrue);

        await configRepo.setConfigLocale('es');
        expect(await configRepo.getConfigLocale(), equals('es'));

        await configRepo.setConfigAppTheme(AppThemeEntity.dark);
        expect(
            await configRepo.getConfigAppTheme(), equals(AppThemeEntity.dark));
      });

      test('updateConfig, goals, training template, adjustment, sync toggles',
          () async {
        final initialConfig = await configRepo.getConfig();
        final updated = ConfigEntity(
          initialConfig.hasAcceptedDisclaimer,
          initialConfig.hasAcceptedPolicy,
          initialConfig.hasAcceptedSendAnonymousData,
          initialConfig.appTheme,
          usesImperialUnits: true,
          macroGoalMode: MacroGoalModeEntity.gramsPerKg,
        );
        await configRepo.updateConfig(updated);
        final fetched = await configRepo.getConfig();
        expect(fetched.usesImperialUnits, isTrue);
        expect(fetched.macroGoalMode, equals(MacroGoalModeEntity.gramsPerKg));

        await configRepo.setConfigUsesImperialUnits(false);
        expect((await configRepo.getConfig()).usesImperialUnits, isFalse);

        await configRepo.setConfigKcalAdjustment(250.0);
        expect(await configRepo.getConfigKcalAdjustment(), equals(250.0));

        await configRepo.setUserMacroPct(0.50, 0.25, 0.25);
        final pctCfg = await configRepo.getConfig();
        expect(pctCfg.userCarbGoalPct, equals(0.50));
        expect(pctCfg.userProteinGoalPct, equals(0.25));
        expect(pctCfg.userFatGoalPct, equals(0.25));

        await configRepo.setUserMacroGoalsGramPerKg(2.5, 2.0, 1.0);
        final gCfg = await configRepo.getConfig();
        expect(gCfg.userCarbGoalGramPerKg, equals(2.5));
        expect(gCfg.userProteinGoalGramPerKg, equals(2.0));
        expect(gCfg.userFatGoalGramPerKg, equals(1.0));

        await configRepo.setMacroGoalMode(MacroGoalModeEntity.percentage);
        expect((await configRepo.getConfig()).macroGoalMode,
            equals(MacroGoalModeEntity.percentage));

        await configRepo.setDailyFocus(DailyFocusEntity.lowerBody);
        expect((await configRepo.getConfig()).dailyFocus,
            equals(DailyFocusEntity.lowerBody));

        await configRepo.setTrainingDayTemplate(TrainingDayTemplateEntity.rest);
        expect((await configRepo.getConfig()).trainingDayTemplate,
            equals(TrainingDayTemplateEntity.rest));

        await configRepo.setHealthConnectAutoSyncEnabled(false);
        expect((await configRepo.getConfig()).healthConnectAutoSyncEnabled,
            isFalse);

        await configRepo.setGoogleDriveAutoBackupEnabled(true);
        expect((await configRepo.getConfig()).googleDriveAutoBackupEnabled,
            isTrue);

        await configRepo.setGoogleDriveBackupStatus(
          attemptedAtIso: '2026-06-16T12:00:00Z',
          successAtIso: '2026-06-16T12:01:00Z',
          errorMessage: 'No error',
        );
        final driveCfg = await configRepo.getConfig();
        expect(driveCfg.googleDriveLastBackupAttemptAt,
            equals('2026-06-16T12:00:00Z'));
        expect(driveCfg.googleDriveLastBackupSuccessAt,
            equals('2026-06-16T12:01:00Z'));
        expect(driveCfg.googleDriveLastBackupError, equals('No error'));

        await configRepo.addDiscardedHealthConnectActivityId('id-123');
        expect(await configRepo.getDiscardedHealthConnectActivityIds(),
            contains('id-123'));

        await configRepo.addAiEstimatedCost(isPhoto: true, usdCost: 0.05);
        expect((await configRepo.getConfigDBO()).aiEstimatedCostTotalUsd,
            equals(0.05));

        await configRepo.resetAiCostTracking();
        expect((await configRepo.getConfigDBO()).aiEstimatedCostTotalUsd,
            equals(0));

        await configRepo.setMealReminderConfig(
          enabled: true,
          morningMinutes: 500,
          lunchMinutes: 700,
          afternoonMinutes: 900,
          eveningMinutes: 1100,
        );
        expect((await configRepo.getConfig()).mealRemindersEnabled, isTrue);
      });
    });

    // ── TrackedDayRepository ──────────────────────────────────────────────────
    group('TrackedDayRepository', () {
      final day = DateTime(2026, 6, 16);

      test('CRUD operations mapping to data source and entities', () async {
        expect(await trackedDayRepo.hasTrackedDay(day), isFalse);
        expect(await trackedDayRepo.getTrackedDay(day), isNull);

        await trackedDayRepo.addNewTrackedDay(day, 2000, 250, 60, 120);
        expect(await trackedDayRepo.hasTrackedDay(day), isTrue);

        final fetched = (await trackedDayRepo.getTrackedDay(day))!;
        expect(fetched.calorieGoal, equals(2000.0));
        expect(fetched.carbsGoal, equals(250.0));
        expect(fetched.fatGoal, equals(60.0));
        expect(fetched.proteinGoal, equals(120.0));

        await trackedDayRepo.updateDayCalorieGoal(day, 2200);
        expect((await trackedDayRepo.getTrackedDay(day))!.calorieGoal,
            equals(2200.0));

        await trackedDayRepo.increaseDayCalorieGoal(day, 100);
        expect((await trackedDayRepo.getTrackedDay(day))!.calorieGoal,
            equals(2300.0));

        await trackedDayRepo.reduceDayCalorieGoal(day, 200);
        expect((await trackedDayRepo.getTrackedDay(day))!.calorieGoal,
            equals(2100.0));

        await trackedDayRepo.updateDayMacroGoal(day,
            carbGoal: 200, fatGoal: 50, proteinGoal: 100);
        var macroFetched = (await trackedDayRepo.getTrackedDay(day))!;
        expect(macroFetched.carbsGoal, equals(200.0));
        expect(macroFetched.fatGoal, equals(50.0));
        expect(macroFetched.proteinGoal, equals(100.0));

        await trackedDayRepo.increaseDayMacroGoal(day,
            carbGoal: 10, fatGoal: 5, proteinGoal: 15);
        macroFetched = (await trackedDayRepo.getTrackedDay(day))!;
        expect(macroFetched.carbsGoal, equals(210.0));
        expect(macroFetched.fatGoal, equals(55.0));
        expect(macroFetched.proteinGoal, equals(115.0));

        await trackedDayRepo.reduceDayMacroGoal(day,
            carbGoal: 20, fatGoal: 10, proteinGoal: 25);
        macroFetched = (await trackedDayRepo.getTrackedDay(day))!;
        expect(macroFetched.carbsGoal, equals(190.0));
        expect(macroFetched.fatGoal, equals(45.0));
        expect(macroFetched.proteinGoal, equals(90.0));
      });

      test('tracked values and range checks', () async {
        await trackedDayRepo.addNewTrackedDay(day, 2000, 200, 50, 100);

        await trackedDayRepo.addDayTrackedCalories(day, 500);
        expect((await trackedDayRepo.getTrackedDay(day))!.caloriesTracked,
            equals(500.0));

        await trackedDayRepo.removeDayTrackedCalories(day, 200);
        expect((await trackedDayRepo.getTrackedDay(day))!.caloriesTracked,
            equals(300.0));

        await trackedDayRepo.addDayMacrosTracked(day,
            carbsTracked: 30, fatTracked: 10, proteinTracked: 20);
        var macroFetched = (await trackedDayRepo.getTrackedDay(day))!;
        expect(macroFetched.carbsTracked, equals(30.0));
        expect(macroFetched.fatTracked, equals(10.0));
        expect(macroFetched.proteinTracked, equals(20.0));

        await trackedDayRepo.removeDayMacrosTracked(day,
            carbsTracked: 10, fatTracked: 5, proteinTracked: 10);
        macroFetched = (await trackedDayRepo.getTrackedDay(day))!;
        expect(macroFetched.carbsTracked, equals(20.0));
        expect(macroFetched.fatTracked, equals(5.0));
        expect(macroFetched.proteinTracked, equals(10.0));

        final nextDay = day.add(const Duration(days: 1));
        await trackedDayRepo.addNewTrackedDay(nextDay, 2500, 300, 70, 150);

        final list = await trackedDayRepo.getAllTrackedDaysDBO();
        expect(list, hasLength(2));

        final rangeList = await trackedDayRepo.getTrackedDayByRange(
            day.subtract(const Duration(minutes: 1)),
            nextDay.add(const Duration(minutes: 1)));
        expect(rangeList, hasLength(2));

        final dbos = [
          TrackedDayDBO(
              day: day.add(const Duration(days: 2)),
              calorieGoal: 1800,
              caloriesTracked: 0),
          TrackedDayDBO(
              day: day.add(const Duration(days: 3)),
              calorieGoal: 1900,
              caloriesTracked: 0),
        ];
        await trackedDayRepo.addAllTrackedDays(dbos);
        expect(await trackedDayRepo.getAllTrackedDaysDBO(), hasLength(4));
      });
    });

    // ── UserActivityDataSource ────────────────────────────────────────────────
    group('UserActivityDataSource', () {
      final date = DateTime(2026, 6, 16);
      final physicalDbo1 = PhysicalActivityDBO(
        'running',
        'Running',
        'Running outside',
        8.0,
        ['running', 'cardio'],
        PhysicalActivityTypeDBO.running,
      );
      final physicalDbo2 = PhysicalActivityDBO(
        'cycling',
        'Cycling',
        'Cycling outside',
        6.0,
        ['cycling', 'cardio'],
        PhysicalActivityTypeDBO.bicycling,
      );

      test('addUserActivity, getAllUserActivities, deleteIntakeFromId, range',
          () async {
        expect(await userActivityDs.getAllUserActivities(), isEmpty);

        final act1 = UserActivityDBO(
          'a1',
          30,
          250,
          date,
          physicalDbo1,
          source: 'manual',
        );
        await userActivityDs.addUserActivity(act1);

        final list = await userActivityDs.getAllUserActivities();
        expect(list, hasLength(1));
        expect(list.first.id, equals('a1'));

        final byDateList =
            await userActivityDs.getAllUserActivitiesByDate(date);
        expect(byDateList, hasLength(1));

        final otherDate = date.add(const Duration(days: 1));
        final act2 = UserActivityDBO(
          'a2',
          45,
          400,
          otherDate,
          physicalDbo2,
          source: 'manual',
        );
        await userActivityDs.addUserActivity(act2);
        expect(await userActivityDs.getAllUserActivities(), hasLength(2));

        final recentList =
            await userActivityDs.getRecentlyAddedUserActivity(number: 2);
        // It sorts by date during retrieval, so both should be returned
        expect(recentList, hasLength(2));

        await userActivityDs.deleteIntakeFromId('a1');
        expect(await userActivityDs.getAllUserActivities(), hasLength(1));
        expect((await userActivityDs.getAllUserActivities()).first.id,
            equals('a2'));

        final listToBatch = [
          UserActivityDBO('a3', 10, 100, date, physicalDbo1, source: 'manual'),
          UserActivityDBO('a4', 20, 200, date, physicalDbo2, source: 'manual'),
        ];
        await userActivityDs.addAllUserActivities(listToBatch);
        expect(await userActivityDs.getAllUserActivities(), hasLength(3));
      });
    });
  });
}
