import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/daily_habits/data/repository/daily_habit_log_repository.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/update_daily_habit_log_usecase.dart';
import 'package:macrotracker/features/home_widget/domain/usecase/update_home_widget_usecase.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/user_bmi_entity.dart';
import 'package:macrotracker/core/domain/entity/macro_goal_mode_entity.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

class _FakeDailyHabitLogRepository extends Fake
    implements DailyHabitLogRepository {
  final Map<String, DailyHabitLogEntity> _store = {};
  int saveCalls = 0;

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  @override
  Future<void> saveLog(DailyHabitLogEntity log) async {
    saveCalls++;
    _store[_key(log.day)] = log;
  }

  @override
  Future<DailyHabitLogEntity?> getLog(DateTime day) async =>
      _store[_key(day)];
}

class _FakeUpdateHomeWidgetUsecase extends Fake
    implements UpdateHomeWidgetUsecase {
  int refreshCalls = 0;
  @override
  Future<void> refreshToday() async => refreshCalls++;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── DailyHabitLogEntity ───────────────────────────────────────────────────
  group('DailyHabitLogEntity', () {
    final day = DateTime(2024, 6, 1);

    test('empty() creates log with all zero values', () {
      final log = DailyHabitLogEntity.empty(day);
      expect(log.creatineTaken, isFalse);
      expect(log.waterLiters, 0);
      expect(log.sleepHours, 0);
      expect(log.steps, 0);
      expect(log.energyLevel, 0);
      expect(log.hasAnyData, isFalse);
    });

    test('copyWith updates specified fields only', () {
      final log = DailyHabitLogEntity.empty(day);
      final updated = log.copyWith(waterLiters: 2.5, creatineTaken: true);
      expect(updated.waterLiters, 2.5);
      expect(updated.creatineTaken, isTrue);
      expect(updated.sleepHours, 0); // unchanged
    });

    test('hasAnyData is true when any field is set', () {
      expect(DailyHabitLogEntity(day: day, steps: 1000).hasAnyData, isTrue);
      expect(DailyHabitLogEntity(day: day, creatineTaken: true).hasAnyData,
          isTrue);
      expect(DailyHabitLogEntity(day: day, waterLiters: 0.5).hasAnyData,
          isTrue);
    });

    test('meetsHydrationGoal', () {
      final log = DailyHabitLogEntity(day: day, waterLiters: 2.0);
      expect(log.meetsHydrationGoal(2.0), isTrue);
      expect(log.meetsHydrationGoal(2.5), isFalse);
    });

    test('meetsSleepGoal', () {
      final log = DailyHabitLogEntity(day: day, sleepHours: 7.5);
      expect(log.meetsSleepGoal(7.0), isTrue);
      expect(log.meetsSleepGoal(8.0), isFalse);
    });

    test('meetsStepGoal', () {
      final log = DailyHabitLogEntity(day: day, steps: 10000);
      expect(log.meetsStepGoal(10000), isTrue);
      expect(log.meetsStepGoal(12000), isFalse);
    });

    test('hydrationProgress clamps between 0 and 1', () {
      final log = DailyHabitLogEntity(day: day, waterLiters: 5.0);
      expect(log.hydrationProgress(2.0), 1.0); // clamped
      expect(log.hydrationProgress(10.0), closeTo(0.5, 0.01));
      expect(log.hydrationProgress(0), 0); // zero goal
    });

    test('completedCount counts all completed habits', () {
      final log = DailyHabitLogEntity(
        day: day,
        creatineTaken: true,
        wheyTaken: true,
        caffeineTaken: false,
        waterLiters: 3.0,
        sleepHours: 8.0,
        steps: 10000,
        energyLevel: 3,
      );
      final count = log.completedCount(
        hydrationGoalLiters: 2.5,
        sleepGoalHours: 7.0,
        stepGoal: 8000,
      );
      // creatine + whey + water + sleep + steps + energy = 6
      expect(count, 6);
    });

    test('completedCount is 0 for empty log', () {
      final log = DailyHabitLogEntity.empty(day);
      expect(
          log.completedCount(
              hydrationGoalLiters: 2.0, sleepGoalHours: 7.0, stepGoal: 8000),
          0);
    });
  });

  // ── UpdateDailyHabitLogUsecase ────────────────────────────────────────────
  group('UpdateDailyHabitLogUsecase', () {
    late _FakeDailyHabitLogRepository repo;
    late _FakeUpdateHomeWidgetUsecase widget;
    late UpdateDailyHabitLogUsecase usecase;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    setUp(() {
      repo = _FakeDailyHabitLogRepository();
      widget = _FakeUpdateHomeWidgetUsecase();
      usecase = UpdateDailyHabitLogUsecase(repo, widget);
    });

    test('saveForDay creates new empty log when no existing log found',
        () async {
      final result = await usecase.saveForDay(day: today);
      expect(result.waterLiters, 0);
      expect(repo.saveCalls, 1);
    });

    test('saveForDay merges into existing log', () async {
      await usecase.saveForDay(day: today, waterLiters: 1.0);
      final result = await usecase.saveForDay(day: today, creatineTaken: true);
      // water from first call is preserved, creatine from second
      expect(result.creatineTaken, isTrue);
    });

    test('saveForDay clamps waterLiters to [0, 8]', () async {
      final result = await usecase.saveForDay(day: today, waterLiters: 99.0);
      expect(result.waterLiters, 8.0);
    });

    test('saveForDay clamps sleepHours to [0, 16]', () async {
      final result = await usecase.saveForDay(day: today, sleepHours: 20.0);
      expect(result.sleepHours, 16.0);
    });

    test('saveForDay clamps steps to [0, 50000]', () async {
      final result = await usecase.saveForDay(day: today, steps: 100000);
      expect(result.steps, 50000);
    });

    test('saveForDay clamps energyLevel to [0, 5]', () async {
      final result = await usecase.saveForDay(day: today, energyLevel: 10);
      expect(result.energyLevel, 5);
    });

    test('saveForDay normalises day to midnight', () async {
      final withTime = DateTime(today.year, today.month, today.day, 15, 30);
      final result = await usecase.saveForDay(day: withTime);
      expect(result.day.hour, 0);
      expect(result.day.minute, 0);
    });

    test('saveForDay refreshes widget for today', () async {
      await usecase.saveForDay(day: today);
      expect(widget.refreshCalls, 1);
    });

    test('saveForDay does NOT refresh widget for past days', () async {
      await usecase.saveForDay(day: yesterday);
      expect(widget.refreshCalls, 0);
    });

    test('adjustWater adds delta and clamps', () async {
      await usecase.saveForDay(day: today, waterLiters: 1.5);
      final result = await usecase.adjustWater(day: today, deltaLiters: 0.5);
      expect(result.waterLiters, closeTo(2.0, 0.01));
    });

    test('adjustWater clamps at maximum 8L', () async {
      await usecase.saveForDay(day: today, waterLiters: 7.8);
      final result = await usecase.adjustWater(day: today, deltaLiters: 1.0);
      expect(result.waterLiters, 8.0);
    });

    test('adjustSleep adds delta and marks sync as manual', () async {
      await usecase.saveForDay(
          day: today,
          sleepHours: 6.0,
          sleepSyncedFromHealthConnect: true);
      final result =
          await usecase.adjustSleep(day: today, deltaHours: 1.5);
      expect(result.sleepHours, closeTo(7.5, 0.01));
      expect(result.sleepSyncedFromHealthConnect, isFalse);
    });

    test('adjustSteps adds delta and marks sync as manual', () async {
      await usecase.saveForDay(
          day: today, steps: 5000, stepsSyncedFromHealthConnect: true);
      final result = await usecase.adjustSteps(day: today, deltaSteps: 2000);
      expect(result.steps, 7000);
      expect(result.stepsSyncedFromHealthConnect, isFalse);
    });

    test('adjustSteps clamps at max 50000', () async {
      await usecase.saveForDay(day: today, steps: 49000);
      final result = await usecase.adjustSteps(day: today, deltaSteps: 5000);
      expect(result.steps, 50000);
    });
  });

  // ── ConfigEntity ──────────────────────────────────────────────────────────
  group('ConfigEntity', () {
    test('default constructor sets expected defaults', () {
      const config = ConfigEntity(
        false, false, false, AppThemeEntity.system,
      );
      expect(config.usesImperialUnits, isFalse);
      expect(config.macroGoalMode, MacroGoalModeEntity.percentage);
      expect(config.mealRemindersEnabled, isFalse);
      expect(config.healthConnectAutoSyncEnabled, isTrue);
      expect(config.googleDriveAutoBackupEnabled, isFalse);
      expect(config.discardedHealthConnectActivityIds, isEmpty);
    });

    test('equality holds for same values', () {
      const a = ConfigEntity(true, false, true, AppThemeEntity.dark);
      const b = ConfigEntity(true, false, true, AppThemeEntity.dark);
      expect(a, equals(b));
    });

    test('inequality when a field differs', () {
      const a = ConfigEntity(true, false, false, AppThemeEntity.dark);
      const b = ConfigEntity(false, false, false, AppThemeEntity.dark);
      expect(a, isNot(equals(b)));
    });
  });

  // ── UserBMIEntity and UserNutritionalStatus ───────────────────────────────
  group('UserBMIEntity', () {
    test('equality holds for same bmi and status', () {
      const a = UserBMIEntity(
          bmiValue: 22.5, nutritionalStatus: UserNutritionalStatus.normalWeight);
      const b = UserBMIEntity(
          bmiValue: 22.5, nutritionalStatus: UserNutritionalStatus.normalWeight);
      expect(a, equals(b));
    });

    test('inequality when bmi differs', () {
      const a = UserBMIEntity(
          bmiValue: 22.5, nutritionalStatus: UserNutritionalStatus.normalWeight);
      const b = UserBMIEntity(
          bmiValue: 30.0, nutritionalStatus: UserNutritionalStatus.normalWeight);
      expect(a, isNot(equals(b)));
    });

    test('all UserNutritionalStatus values are enumerable', () {
      expect(UserNutritionalStatus.values.length, 6);
      expect(UserNutritionalStatus.values,
          containsAll(UserNutritionalStatus.values));
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Re-export entity enum for tests above
// ─────────────────────────────────────────────────────────────────────────────

