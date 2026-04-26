import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';

class GymTargetCalc {
  static GymTargetsEntity buildTargets({
    required UserWeightGoalEntity phase,
    required DailyFocusEntity dailyFocus,
    required double baseKcalGoal,
    required double baseCarbsGoal,
    required double baseFatGoal,
    required double baseProteinGoal,
  }) {
    final phaseCarbsGoal = phase.adjustCarbGoal(baseCarbsGoal);
    final phaseFatGoal = phase.adjustFatGoal(baseFatGoal);
    final phaseProteinGoal = phase.adjustProteinGoal(baseProteinGoal);

    return GymTargetsEntity(
      kcalGoal: dailyFocus.adjustKcalGoal(baseKcalGoal),
      carbsGoal: dailyFocus.adjustCarbGoal(phaseCarbsGoal),
      fatGoal: dailyFocus.adjustFatGoal(phaseFatGoal),
      proteinGoal: dailyFocus.adjustProteinGoal(phaseProteinGoal),
    );
  }
}
