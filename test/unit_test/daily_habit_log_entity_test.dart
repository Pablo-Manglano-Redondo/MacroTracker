import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';

void main() {
  group('DailyHabitLogEntity', () {
    test('counts completed checks including hydration goal', () {
      final log = DailyHabitLogEntity(
        day: DateTime(2026, 4, 26),
        creatineTaken: true,
        wheyTaken: false,
        caffeineTaken: true,
        waterLiters: 3.6,
        sleepHours: 8,
        steps: 9000,
        energyLevel: 4,
      );

      expect(
        log.completedCount(
          hydrationGoalLiters: 3.5,
          sleepGoalHours: 8,
          stepGoal: 8000,
        ),
        6,
      );
      expect(log.meetsHydrationGoal(3.5), isTrue);
      expect(log.meetsSleepGoal(8), isTrue);
      expect(log.meetsStepGoal(8000), isTrue);
    });

    test('clamps hydration progress to one and reports empty state', () {
      final log = DailyHabitLogEntity(
        day: DateTime(2026, 4, 26),
        waterLiters: 5,
        energyLevel: 0,
      );

      expect(log.hydrationProgress(3.5), 1);
      expect(log.hasAnyData, isTrue);
      expect(
          DailyHabitLogEntity.empty(DateTime(2026, 4, 26)).hasAnyData, isFalse);
    });
  });
}
