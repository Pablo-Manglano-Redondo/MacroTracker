import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:macrotracker/core/data/data_source/tracked_day_data_source.dart';
import 'package:macrotracker/core/data/dbo/tracked_day_dbo.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';

void main() {
  group('TrackedDayDataSource Tests', () {
    late Directory tempDir;
    late HiveDBProvider hiveProvider;
    late TrackedDayDataSource ds;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp
          .createTemp('macrotracker_tracked_day_ds_test_');

      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return tempDir.path;
      });

      hiveProvider = HiveDBProvider();
      final key = Hive.generateSecureKey();
      await hiveProvider.initHiveDB(Uint8List.fromList(key));
      ds = TrackedDayDataSource(hiveProvider.trackedDayBox);
    });

    tearDown(() async {
      await hiveProvider.clearAllData();
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    TrackedDayDBO makeDbo(DateTime date,
        {double calorieGoal = 2000.0, double caloriesTracked = 0.0}) {
      return TrackedDayDBO(
        day: date,
        calorieGoal: calorieGoal,
        caloriesTracked: caloriesTracked,
      );
    }

    test('saveTrackedDay and getTrackedDay and hasTrackedDay work', () async {
      final date = DateTime(2026, 6, 15);
      expect(await ds.hasTrackedDay(date), isFalse);

      final dbo = makeDbo(date, calorieGoal: 2500, caloriesTracked: 1500);
      await ds.saveTrackedDay(dbo);

      expect(await ds.hasTrackedDay(date), isTrue);
      final fetched = await ds.getTrackedDay(date);
      expect(fetched, isNotNull);
      expect(fetched!.calorieGoal, equals(2500.0));
      expect(fetched.caloriesTracked, equals(1500.0));
    });

    test('saveAllTrackedDays and getAllTrackedDays work', () async {
      final d1 = DateTime(2026, 6, 15);
      final d2 = DateTime(2026, 6, 16);
      final list = [
        makeDbo(d1, calorieGoal: 2000),
        makeDbo(d2, calorieGoal: 2200),
      ];

      await ds.saveAllTrackedDays(list);
      final fetchedList = await ds.getAllTrackedDays();
      expect(fetchedList, hasLength(2));

      final fetchedDates = fetchedList.map((x) => x.day).toList();
      expect(fetchedDates, containsAll([d1, d2]));
    });

    test('getTrackedDaysInRange returns correct subset', () async {
      final d1 = DateTime(2026, 6, 1);
      final d2 = DateTime(2026, 6, 10);
      final d3 = DateTime(2026, 6, 20);

      await ds.saveAllTrackedDays([
        makeDbo(d1),
        makeDbo(d2),
        makeDbo(d3),
      ]);

      // Range is exclusive in the implementation: (start, end)
      final inRange = await ds.getTrackedDaysInRange(
        DateTime(2026, 6, 5),
        DateTime(2026, 6, 15),
      );
      expect(inRange, hasLength(1));
      expect(inRange.first.day, equals(d2));
    });

    test('updateDayCalorieGoal, increaseDayCalorieGoal, reduceDayCalorieGoal',
        () async {
      final date = DateTime(2026, 6, 15);
      // Try to update non-existent day (should not crash/do anything)
      await ds.updateDayCalorieGoal(date, 3000);

      final dbo = makeDbo(date, calorieGoal: 2000);
      await ds.saveTrackedDay(dbo);

      await ds.updateDayCalorieGoal(date, 2500);
      expect((await ds.getTrackedDay(date))!.calorieGoal, equals(2500.0));

      await ds.increaseDayCalorieGoal(date, 300);
      expect((await ds.getTrackedDay(date))!.calorieGoal, equals(2800.0));

      await ds.reduceDayCalorieGoal(date, 500);
      expect((await ds.getTrackedDay(date))!.calorieGoal, equals(2300.0));
    });

    test('addDayCaloriesTracked, decreaseDayCaloriesTracked', () async {
      final date = DateTime(2026, 6, 15);
      final dbo = makeDbo(date, caloriesTracked: 1000);
      await ds.saveTrackedDay(dbo);

      await ds.addDayCaloriesTracked(date, 500);
      expect((await ds.getTrackedDay(date))!.caloriesTracked, equals(1500.0));

      await ds.decreaseDayCaloriesTracked(date, 200);
      expect((await ds.getTrackedDay(date))!.caloriesTracked, equals(1300.0));
    });

    test('updateDayMacroGoals updates targets', () async {
      final date = DateTime(2026, 6, 15);
      final dbo = makeDbo(date);
      await ds.saveTrackedDay(dbo);

      await ds.updateDayMacroGoals(date,
          carbsGoal: 200, fatGoal: 60, proteinGoal: 150);
      final fetched = (await ds.getTrackedDay(date))!;
      expect(fetched.carbsGoal, equals(200.0));
      expect(fetched.fatGoal, equals(60.0));
      expect(fetched.proteinGoal, equals(150.0));

      // Partial update
      await ds.updateDayMacroGoals(date, carbsGoal: 250);
      final fetched2 = (await ds.getTrackedDay(date))!;
      expect(fetched2.carbsGoal, equals(250.0));
      expect(fetched2.fatGoal, equals(60.0));
      expect(fetched2.proteinGoal, equals(150.0));
    });

    test('increaseDayMacroGoal and reduceDayMacroGoal modify goals', () async {
      final date = DateTime(2026, 6, 15);
      final dbo = makeDbo(date);
      dbo.carbsGoal = 100;
      dbo.fatGoal = 40;
      dbo.proteinGoal = 100;
      await ds.saveTrackedDay(dbo);

      await ds.increaseDayMacroGoal(date,
          carbsAmount: 50, fatAmount: 10, proteinAmount: 20);
      var fetched = (await ds.getTrackedDay(date))!;
      expect(fetched.carbsGoal, equals(150.0));
      expect(fetched.fatGoal, equals(50.0));
      expect(fetched.proteinGoal, equals(120.0));

      await ds.reduceDayMacroGoal(date,
          carbsAmount: 30, fatAmount: 15, proteinAmount: 40);
      fetched = (await ds.getTrackedDay(date))!;
      expect(fetched.carbsGoal, equals(120.0));
      expect(fetched.fatGoal, equals(35.0));
      expect(fetched.proteinGoal, equals(80.0));
    });

    test('addDayMacroTracked and removeDayMacroTracked modify tracked values',
        () async {
      final date = DateTime(2026, 6, 15);
      final dbo = makeDbo(date);
      dbo.carbsTracked = 50;
      dbo.fatTracked = 20;
      dbo.proteinTracked = 60;
      await ds.saveTrackedDay(dbo);

      await ds.addDayMacroTracked(date,
          carbsAmount: 15, fatAmount: 5, proteinAmount: 10);
      var fetched = (await ds.getTrackedDay(date))!;
      expect(fetched.carbsTracked, equals(65.0));
      expect(fetched.fatTracked, equals(25.0));
      expect(fetched.proteinTracked, equals(70.0));

      await ds.removeDayMacroTracked(date,
          carbsAmount: 10, fatAmount: 10, proteinAmount: 20);
      fetched = (await ds.getTrackedDay(date))!;
      expect(fetched.carbsTracked, equals(55.0));
      expect(fetched.fatTracked, equals(15.0));
      expect(fetched.proteinTracked, equals(50.0));
    });
  });
}
