import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:macrotracker/core/data/data_source/config_data_source.dart';
import 'package:macrotracker/core/data/dbo/app_theme_dbo.dart';
import 'package:macrotracker/core/data/dbo/config_dbo.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';

void main() {
  group('ConfigDataSource Tests', () {
    late Directory tempDir;
    late HiveDBProvider hiveProvider;
    late ConfigDataSource ds;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir =
          await Directory.systemTemp.createTemp('macrotracker_config_ds_test_');

      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return tempDir.path;
      });

      hiveProvider = HiveDBProvider();
      final key = Hive.generateSecureKey();
      await hiveProvider.initHiveDB(Uint8List.fromList(key));
      ds = ConfigDataSource(hiveProvider.configBox);
    });

    tearDown(() async {
      await hiveProvider.clearAllData();
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('configInitialized and initializeConfig work correctly', () async {
      expect(await ds.configInitialized(), isFalse);

      await ds.initializeConfig();
      expect(await ds.configInitialized(), isTrue);

      final config = await ds.getConfig();
      expect(config.hasAcceptedDisclaimer, isFalse);
    });

    test('addConfig saves a custom ConfigDBO', () async {
      final custom = ConfigDBO.empty();
      custom.selectedLocale = 'fr';

      await ds.addConfig(custom);
      expect(await ds.configInitialized(), isTrue);
      expect(await ds.getLocale(), 'fr');
    });

    test('setConfigDisclaimer updates hasAcceptedDisclaimer', () async {
      await ds.initializeConfig();
      await ds.setConfigDisclaimer(true);

      final config = await ds.getConfig();
      expect(config.hasAcceptedDisclaimer, isTrue);
    });

    test('setConfigAcceptedAnonymousData updates hasAcceptedSendAnonymousData',
        () async {
      await ds.initializeConfig();
      await ds.setConfigAcceptedAnonymousData(true);

      expect(await ds.getHasAcceptedAnonymousData(), isTrue);
    });

    test('AppTheme options: getAppTheme and setConfigAppTheme', () async {
      await ds.initializeConfig();
      expect(await ds.getAppTheme(), AppThemeDBO.defaultTheme);

      await ds.setConfigAppTheme(AppThemeDBO.dark);
      expect(await ds.getAppTheme(), AppThemeDBO.dark);
    });

    test('setConfigUsesImperialUnits updates usesImperialUnits', () async {
      await ds.initializeConfig();
      await ds.setConfigUsesImperialUnits(true);

      final config = await ds.getConfig();
      expect(config.usesImperialUnits, isTrue);
    });

    test('Locale options: getLocale and setConfigLocale', () async {
      await ds.initializeConfig();
      expect(await ds.getLocale(), isNull);

      await ds.setConfigLocale('es');
      expect(await ds.getLocale(), 'es');
    });

    test('getKcalAdjustment and setConfigKcalAdjustment', () async {
      await ds.initializeConfig();
      expect(await ds.getKcalAdjustment(), 0);

      await ds.setConfigKcalAdjustment(200.0);
      expect(await ds.getKcalAdjustment(), 200.0);
    });

    test('setConfigCarbGoalPct, setConfigProteinGoalPct, setConfigFatGoalPct',
        () async {
      await ds.initializeConfig();
      await ds.setConfigCarbGoalPct(0.5);
      await ds.setConfigProteinGoalPct(0.3);
      await ds.setConfigFatGoalPct(0.2);

      final config = await ds.getConfig();
      expect(config.userCarbGoalPct, 0.5);
      expect(config.userProteinGoalPct, 0.3);
      expect(config.userFatGoalPct, 0.2);
    });

    test('setMacroGoalMode updates macroGoalMode', () async {
      await ds.initializeConfig();
      await ds.setMacroGoalMode('percentage');

      final config = await ds.getConfig();
      expect(config.macroGoalMode, 'percentage');
    });

    test(
        'setConfigCarbGoalGramPerKg, setConfigProteinGoalGramPerKg, setConfigFatGoalGramPerKg',
        () async {
      await ds.initializeConfig();
      await ds.setConfigCarbGoalGramPerKg(2.5);
      await ds.setConfigProteinGoalGramPerKg(2.0);
      await ds.setConfigFatGoalGramPerKg(1.0);

      final config = await ds.getConfig();
      expect(config.userCarbGoalGramPerKg, 2.5);
      expect(config.userProteinGoalGramPerKg, 2.0);
      expect(config.userFatGoalGramPerKg, 1.0);
    });

    test('setConfigDailyFocus updates dailyFocus', () async {
      await ds.initializeConfig();
      await ds.setConfigDailyFocus('legs');

      final config = await ds.getConfig();
      expect(config.dailyFocus, 'legs');
    });

    test('setConfigTrainingDayTemplate updates trainingDayTemplate', () async {
      await ds.initializeConfig();
      await ds.setConfigTrainingDayTemplate('upper');

      final config = await ds.getConfig();
      expect(config.trainingDayTemplate, 'upper');
    });

    test('setHealthConnectAutoSyncEnabled updates healthConnectAutoSyncEnabled',
        () async {
      await ds.initializeConfig();
      await ds.setHealthConnectAutoSyncEnabled(true);

      final config = await ds.getConfig();
      expect(config.healthConnectAutoSyncEnabled, isTrue);
    });

    test('setMealReminderConfig updates meal reminder minutes and status',
        () async {
      await ds.initializeConfig();
      await ds.setMealReminderConfig(
        enabled: true,
        morningMinutes: 480,
        lunchMinutes: 780,
        afternoonMinutes: 1020,
        eveningMinutes: 1260,
      );

      final config = await ds.getConfig();
      expect(config.mealRemindersEnabled, isTrue);
      expect(config.mealReminderMorningMinutes, 480);
      expect(config.mealReminderLunchMinutes, 780);
      expect(config.mealReminderAfternoonMinutes, 1020);
      expect(config.mealReminderEveningMinutes, 1260);
    });

    test('setGoogleDriveAutoBackupEnabled and setGoogleDriveBackupStatus',
        () async {
      await ds.initializeConfig();
      await ds.setGoogleDriveAutoBackupEnabled(true);

      var config = await ds.getConfig();
      expect(config.googleDriveAutoBackupEnabled, isTrue);

      await ds.setGoogleDriveBackupStatus(
        attemptedAtIso: '2026-06-15T12:00:00Z',
        successAtIso: '2026-06-15T12:00:01Z',
        errorMessage: 'Connection lost',
      );

      config = await ds.getConfig();
      expect(config.googleDriveLastBackupAttemptAt, '2026-06-15T12:00:00Z');
      expect(config.googleDriveLastBackupSuccessAt, '2026-06-15T12:00:01Z');
      expect(config.googleDriveLastBackupError, 'Connection lost');

      await ds.setGoogleDriveAutoBackupEnabled(false);
      config = await ds.getConfig();
      expect(config.googleDriveAutoBackupEnabled, isFalse);
      expect(config.googleDriveLastBackupError, isNull);
    });

    test(
        'getDiscardedHealthConnectActivityIds and addDiscardedHealthConnectActivityId',
        () async {
      await ds.initializeConfig();
      expect(await ds.getDiscardedHealthConnectActivityIds(), isEmpty);

      await ds.addDiscardedHealthConnectActivityId('activity-1');
      await ds.addDiscardedHealthConnectActivityId('activity-2');
      await ds
          .addDiscardedHealthConnectActivityId('activity-1'); // Duplicate check

      final ids = await ds.getDiscardedHealthConnectActivityIds();
      expect(ids, hasLength(2));
      expect(ids, containsAll(['activity-1', 'activity-2']));
    });

    test(
        'addAiEstimatedCost updates daily, monthly, total costs and call counts',
        () async {
      await ds.initializeConfig();
      await ds.addAiEstimatedCost(isPhoto: false, usdCost: 0.015);

      var config = await ds.getConfig();
      expect(config.aiEstimatedCostTotalUsd, 0.015);
      expect(config.aiEstimatedCostTodayUsd, 0.015);
      expect(config.aiEstimatedCostMonthUsd, 0.015);
      expect(config.aiTextCallsTotal, 1);
      expect(config.aiPhotoCallsTotal, 0);

      await ds.addAiEstimatedCost(isPhoto: true, usdCost: 0.05);
      config = await ds.getConfig();
      expect(config.aiEstimatedCostTotalUsd, closeTo(0.065, 0.0001));
      expect(config.aiPhotoCallsTotal, 1);
      expect(config.aiTextCallsTotal, 1);
    });

    test('resetAiCostTracking resets all cost tracking counters', () async {
      await ds.initializeConfig();
      await ds.addAiEstimatedCost(isPhoto: true, usdCost: 0.05);

      await ds.resetAiCostTracking();
      final config = await ds.getConfig();
      expect(config.aiEstimatedCostTotalUsd, 0);
      expect(config.aiEstimatedCostTodayUsd, 0);
      expect(config.aiEstimatedCostMonthUsd, 0);
      expect(config.aiTextCallsTotal, 0);
      expect(config.aiPhotoCallsTotal, 0);
      expect(config.aiCostTodayDate, isNull);
      expect(config.aiCostMonthKey, isNull);
    });
  });
}
