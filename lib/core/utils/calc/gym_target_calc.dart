import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/macro_goal_mode_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';

class GymTargetCalc {
  static GymTargetsEntity buildTargets({
    required UserWeightGoalEntity phase,
    required DailyFocusEntity dailyFocus,
    required MacroGoalModeEntity macroGoalMode,
    required double baseKcalGoal,
    required double baseCarbsGoal,
    required double baseFatGoal,
    required double baseProteinGoal,
    double? userWeightKg,
    double? userHeightCm,
  }) {
    final adjustedKcalGoal = dailyFocus.adjustKcalGoal(baseKcalGoal);

    if (macroGoalMode == MacroGoalModeEntity.gramsPerKg) {
      final adjustedCarbsGoal = _deriveCarbsGoalFromRemainingKcal(
        totalKcalGoal: adjustedKcalGoal,
        fatGoal: baseFatGoal,
        proteinGoal: baseProteinGoal,
      );
      return GymTargetsEntity(
        kcalGoal: adjustedKcalGoal,
        proteinGoal: baseProteinGoal.roundToDouble(),
        fatGoal: baseFatGoal.roundToDouble(),
        carbsGoal: adjustedCarbsGoal,
      );
    }
    final kcalScale = _resolveKcalScale(
      baseKcalGoal: baseKcalGoal,
      adjustedKcalGoal: adjustedKcalGoal,
    );

    return GymTargetsEntity(
      kcalGoal: adjustedKcalGoal,
      proteinGoal: (baseProteinGoal * kcalScale).roundToDouble(),
      fatGoal: (baseFatGoal * kcalScale).roundToDouble(),
      carbsGoal: (baseCarbsGoal * kcalScale).roundToDouble(),
    );
  }

  static double _resolveKcalScale({
    required double baseKcalGoal,
    required double adjustedKcalGoal,
  }) {
    if (baseKcalGoal <= 0) {
      return 1;
    }
    return adjustedKcalGoal / baseKcalGoal;
  }

  static double _deriveCarbsGoalFromRemainingKcal({
    required double totalKcalGoal,
    required double fatGoal,
    required double proteinGoal,
  }) {
    final remainingKcal = totalKcalGoal - (proteinGoal * 4) - (fatGoal * 9);
    if (remainingKcal <= 0) {
      return 0;
    }
    return (remainingKcal / 4).roundToDouble();
  }
}
