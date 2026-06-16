import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';

DailyHabitLogEntity _log({
  bool creatine = false,
  bool whey = false,
  bool caffeine = false,
  double water = 0,
  double sleep = 0,
  int steps = 0,
  int energyLevel = 0,
  bool sleepSynced = false,
  bool stepsSynced = false,
}) =>
    DailyHabitLogEntity(
      day: DateTime(2024, 6, 15),
      creatineTaken: creatine,
      wheyTaken: whey,
      caffeineTaken: caffeine,
      waterLiters: water,
      sleepHours: sleep,
      steps: steps,
      energyLevel: energyLevel,
      sleepSyncedFromHealthConnect: sleepSynced,
      stepsSyncedFromHealthConnect: stepsSynced,
    );

void main() {
  group('DailyHabitLogEntity.empty', () {
    test('creates empty instance with default values', () {
      final day = DateTime(2024, 6, 15);
      final log = DailyHabitLogEntity.empty(day);
      expect(log.creatineTaken, isFalse);
      expect(log.wheyTaken, isFalse);
      expect(log.caffeineTaken, isFalse);
      expect(log.waterLiters, 0);
      expect(log.sleepHours, 0);
      expect(log.steps, 0);
      expect(log.energyLevel, 0);
    });

    test('normalizes day to midnight (no time component)', () {
      final day = DateTime(2024, 6, 15, 13, 45, 30);
      final log = DailyHabitLogEntity.empty(day);
      expect(log.day, DateTime(2024, 6, 15));
    });
  });

  group('DailyHabitLogEntity.hasAnyData', () {
    test('returns false for fully empty log', () {
      expect(_log().hasAnyData, isFalse);
    });

    test('returns true when creatine is taken', () {
      expect(_log(creatine: true).hasAnyData, isTrue);
    });

    test('returns true when whey is taken', () {
      expect(_log(whey: true).hasAnyData, isTrue);
    });

    test('returns true when caffeine is taken', () {
      expect(_log(caffeine: true).hasAnyData, isTrue);
    });

    test('returns true when water > 0', () {
      expect(_log(water: 0.5).hasAnyData, isTrue);
    });

    test('returns true when sleep > 0', () {
      expect(_log(sleep: 7.5).hasAnyData, isTrue);
    });

    test('returns true when steps > 0', () {
      expect(_log(steps: 5000).hasAnyData, isTrue);
    });

    test('returns true when energy level > 0', () {
      expect(_log(energyLevel: 3).hasAnyData, isTrue);
    });
  });

  group('DailyHabitLogEntity.meetsHydrationGoal', () {
    test('returns true when water equals goal exactly', () {
      expect(_log(water: 2.0).meetsHydrationGoal(2.0), isTrue);
    });

    test('returns true when water exceeds goal', () {
      expect(_log(water: 2.5).meetsHydrationGoal(2.0), isTrue);
    });

    test('returns false when water is below goal', () {
      expect(_log(water: 1.5).meetsHydrationGoal(2.0), isFalse);
    });
  });

  group('DailyHabitLogEntity.meetsSleepGoal', () {
    test('returns true when sleep equals goal', () {
      expect(_log(sleep: 8.0).meetsSleepGoal(8.0), isTrue);
    });

    test('returns false when sleep is below goal', () {
      expect(_log(sleep: 6.0).meetsSleepGoal(8.0), isFalse);
    });
  });

  group('DailyHabitLogEntity.meetsStepGoal', () {
    test('returns true when steps meet goal', () {
      expect(_log(steps: 10000).meetsStepGoal(10000), isTrue);
    });

    test('returns false when steps are below goal', () {
      expect(_log(steps: 7500).meetsStepGoal(10000), isFalse);
    });
  });

  group('DailyHabitLogEntity.hydrationProgress', () {
    test('returns 0 when goal is 0 (prevents division by zero)', () {
      expect(_log(water: 1.5).hydrationProgress(0), 0);
    });

    test('returns 1.0 when exactly at goal', () {
      expect(_log(water: 2.0).hydrationProgress(2.0), 1.0);
    });

    test('returns partial progress', () {
      expect(_log(water: 1.0).hydrationProgress(2.0), closeTo(0.5, 0.001));
    });

    test('clamps at 1.0 when exceeding goal', () {
      expect(_log(water: 3.0).hydrationProgress(2.0), 1.0);
    });

    test('returns 0 when no water consumed', () {
      expect(_log(water: 0).hydrationProgress(2.0), 0);
    });
  });

  group('DailyHabitLogEntity.completedCount', () {
    test('returns 0 for fully empty log', () {
      final count = _log().completedCount(
          hydrationGoalLiters: 2.0, sleepGoalHours: 8.0, stepGoal: 10000);
      expect(count, 0);
    });

    test('counts creatine', () {
      final count = _log(creatine: true).completedCount(
          hydrationGoalLiters: 2.0, sleepGoalHours: 8.0, stepGoal: 10000);
      expect(count, 1);
    });

    test('counts whey', () {
      final count = _log(whey: true).completedCount(
          hydrationGoalLiters: 2.0, sleepGoalHours: 8.0, stepGoal: 10000);
      expect(count, 1);
    });

    test('counts caffeine', () {
      final count = _log(caffeine: true).completedCount(
          hydrationGoalLiters: 2.0, sleepGoalHours: 8.0, stepGoal: 10000);
      expect(count, 1);
    });

    test('counts hydration when goal is met', () {
      final count = _log(water: 2.5).completedCount(
          hydrationGoalLiters: 2.0, sleepGoalHours: 8.0, stepGoal: 10000);
      expect(count, 1);
    });

    test('counts sleep when goal is met', () {
      final count = _log(sleep: 9.0).completedCount(
          hydrationGoalLiters: 2.0, sleepGoalHours: 8.0, stepGoal: 10000);
      expect(count, 1);
    });

    test('counts steps when goal is met', () {
      final count = _log(steps: 12000).completedCount(
          hydrationGoalLiters: 2.0, sleepGoalHours: 8.0, stepGoal: 10000);
      expect(count, 1);
    });

    test('counts energy level when > 0', () {
      final count = _log(energyLevel: 2).completedCount(
          hydrationGoalLiters: 2.0, sleepGoalHours: 8.0, stepGoal: 10000);
      expect(count, 1);
    });

    test('counts all 7 habits when fully completed', () {
      final count = _log(
        creatine: true,
        whey: true,
        caffeine: true,
        water: 2.5,
        sleep: 9.0,
        steps: 12000,
        energyLevel: 5,
      ).completedCount(
          hydrationGoalLiters: 2.0, sleepGoalHours: 8.0, stepGoal: 10000);
      expect(count, 7);
    });
  });

  group('DailyHabitLogEntity.copyWith', () {
    test('preserves unchanged fields', () {
      final log = _log(creatine: true, water: 1.5);
      final updated = log.copyWith(waterLiters: 2.0);
      expect(updated.creatineTaken, isTrue);
      expect(updated.waterLiters, 2.0);
    });

    test('can update individual boolean habits', () {
      final log = _log();
      final updated = log.copyWith(wheyTaken: true);
      expect(updated.wheyTaken, isTrue);
      expect(updated.creatineTaken, isFalse);
    });

    test('equality holds when same values', () {
      final a = _log(creatine: true, water: 1.5);
      final b = _log(creatine: true, water: 1.5);
      expect(a, equals(b));
    });

    test('inequality when values differ', () {
      final a = _log(water: 1.5);
      final b = _log(water: 2.0);
      expect(a, isNot(equals(b)));
    });
  });
}
