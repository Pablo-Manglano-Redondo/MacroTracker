import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/macro_goal_mode_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/utils/calc/gym_target_calc.dart';

void main() {
  const baseKcal = 2500.0;
  const baseCarbs = 375.0;
  const baseFat = 69.0;
  const baseProtein = 94.0;

  group('GymTargetCalc.buildTargets - percentage mode', () {
    test('builds targets for upper body day', () {
      final targets = GymTargetCalc.buildTargets(
        phase: UserWeightGoalEntity.maintainWeight,
        dailyFocus: DailyFocusEntity.upperBody,
        macroGoalMode: MacroGoalModeEntity.percentage,
        baseKcalGoal: baseKcal,
        baseCarbsGoal: baseCarbs,
        baseFatGoal: baseFat,
        baseProteinGoal: baseProtein,
      );

      expect(targets.kcalGoal, closeTo(2650, 1)); // 2500 * 1.06
      expect(targets.proteinGoal, greaterThan(0));
      expect(targets.fatGoal, greaterThan(0));
      expect(targets.carbsGoal, greaterThan(0));
    });

    test('builds targets for rest day', () {
      final targets = GymTargetCalc.buildTargets(
        phase: UserWeightGoalEntity.maintainWeight,
        dailyFocus: DailyFocusEntity.rest,
        macroGoalMode: MacroGoalModeEntity.percentage,
        baseKcalGoal: baseKcal,
        baseCarbsGoal: baseCarbs,
        baseFatGoal: baseFat,
        baseProteinGoal: baseProtein,
      );

      expect(targets.kcalGoal, closeTo(2350, 1)); // 2500 * 0.94
    });

    test('builds targets for lower body day', () {
      final targets = GymTargetCalc.buildTargets(
        phase: UserWeightGoalEntity.maintainWeight,
        dailyFocus: DailyFocusEntity.lowerBody,
        macroGoalMode: MacroGoalModeEntity.percentage,
        baseKcalGoal: baseKcal,
        baseCarbsGoal: baseCarbs,
        baseFatGoal: baseFat,
        baseProteinGoal: baseProtein,
      );

      expect(targets.kcalGoal, closeTo(2750, 1)); // 2500 * 1.10
    });

    test('builds targets for cardio day', () {
      final targets = GymTargetCalc.buildTargets(
        phase: UserWeightGoalEntity.maintainWeight,
        dailyFocus: DailyFocusEntity.cardio,
        macroGoalMode: MacroGoalModeEntity.percentage,
        baseKcalGoal: baseKcal,
        baseCarbsGoal: baseCarbs,
        baseFatGoal: baseFat,
        baseProteinGoal: baseProtein,
      );

      expect(targets.kcalGoal, closeTo(2550, 1)); // 2500 * 1.02
    });

    test('kcal scale preserves macro ratios in percentage mode', () {
      final targets = GymTargetCalc.buildTargets(
        phase: UserWeightGoalEntity.maintainWeight,
        dailyFocus: DailyFocusEntity.upperBody,
        macroGoalMode: MacroGoalModeEntity.percentage,
        baseKcalGoal: baseKcal,
        baseCarbsGoal: baseCarbs,
        baseFatGoal: baseFat,
        baseProteinGoal: baseProtein,
      );

      final kcalRatio = targets.kcalGoal / baseKcal;
      expect(targets.proteinGoal, closeTo((baseProtein * kcalRatio).roundToDouble(), 1));
      expect(targets.fatGoal, closeTo((baseFat * kcalRatio).roundToDouble(), 1));
      expect(targets.carbsGoal, closeTo((baseCarbs * kcalRatio).roundToDouble(), 1));
    });
  });

  group('GymTargetCalc.buildTargets - gramsPerKg mode', () {
    test('builds targets in gramsPerKg mode without scaling carbs from focus', () {
      final targets = GymTargetCalc.buildTargets(
        phase: UserWeightGoalEntity.maintainWeight,
        dailyFocus: DailyFocusEntity.upperBody,
        macroGoalMode: MacroGoalModeEntity.gramsPerKg,
        baseKcalGoal: baseKcal,
        baseCarbsGoal: baseCarbs,
        baseFatGoal: baseFat,
        baseProteinGoal: baseProtein,
        userWeightKg: 80,
        userHeightCm: 180,
      );

      expect(targets.kcalGoal, closeTo(2650, 1)); // kcal still adjusted by focus
      expect(targets.proteinGoal, baseProtein.roundToDouble());
      expect(targets.fatGoal, baseFat.roundToDouble());
    });
  });

  group('GymTargetCalc.buildTargets - edge cases', () {
    test('zero base kcal goal does not crash', () {
      final targets = GymTargetCalc.buildTargets(
        phase: UserWeightGoalEntity.loseWeight,
        dailyFocus: DailyFocusEntity.rest,
        macroGoalMode: MacroGoalModeEntity.percentage,
        baseKcalGoal: 0,
        baseCarbsGoal: 0,
        baseFatGoal: 0,
        baseProteinGoal: 0,
      );

      expect(targets.kcalGoal, 0);
      expect(targets.proteinGoal, 0);
      expect(targets.fatGoal, 0);
      expect(targets.carbsGoal, 0);
    });

    test('works with loseWeight phase', () {
      final targets = GymTargetCalc.buildTargets(
        phase: UserWeightGoalEntity.loseWeight,
        dailyFocus: DailyFocusEntity.upperBody,
        macroGoalMode: MacroGoalModeEntity.percentage,
        baseKcalGoal: baseKcal,
        baseCarbsGoal: baseCarbs,
        baseFatGoal: baseFat,
        baseProteinGoal: baseProtein,
      );

      expect(targets.kcalGoal, greaterThan(0));
      expect(targets.proteinGoal, greaterThan(0));
    });

    test('works with gainWeight phase', () {
      final targets = GymTargetCalc.buildTargets(
        phase: UserWeightGoalEntity.gainWeight,
        dailyFocus: DailyFocusEntity.lowerBody,
        macroGoalMode: MacroGoalModeEntity.percentage,
        baseKcalGoal: baseKcal,
        baseCarbsGoal: baseCarbs,
        baseFatGoal: baseFat,
        baseProteinGoal: baseProtein,
      );

      expect(targets.kcalGoal, greaterThan(0));
      expect(targets.proteinGoal, greaterThan(0));
    });
  });
}
