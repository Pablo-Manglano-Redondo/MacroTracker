import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';

class GymTargetCalc {
  static const _customWeightKg = 78.0;
  static const _customHeightCm = 173.0;
  static const _weightToleranceKg = 7.0;
  static const _heightToleranceCm = 8.0;

  static const _maintainKcal = 2750.0;
  static const _maintainProtein = 160.0;
  static const _maintainFat = 75.0;

  static const _cutDeficitKcal = 175.0; // mild 150-200 kcal deficit midpoint
  static const _cutProtein = 165.0;
  static const _cutFat = 72.0;

  static const _bulkSurplusKcal = 175.0;
  static const _bulkProtein = 160.0;
  static const _bulkFat = 80.0;

  static GymTargetsEntity buildTargets({
    required UserWeightGoalEntity phase,
    required DailyFocusEntity dailyFocus,
    required double baseKcalGoal,
    required double baseCarbsGoal,
    required double baseFatGoal,
    required double baseProteinGoal,
    double? userWeightKg,
    double? userHeightCm,
  }) {
    final useCustomProfile = _shouldUseCustomProfile(
      userWeightKg: userWeightKg,
      userHeightCm: userHeightCm,
    );

    if (useCustomProfile) {
      return _buildCustomTargets(
        phase: phase,
        dailyFocus: dailyFocus,
      );
    }

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

  static bool _shouldUseCustomProfile({
    required double? userWeightKg,
    required double? userHeightCm,
  }) {
    if (userWeightKg == null || userHeightCm == null) {
      return false;
    }
    final weightDelta = (userWeightKg - _customWeightKg).abs();
    final heightDelta = (userHeightCm - _customHeightCm).abs();
    return weightDelta <= _weightToleranceKg &&
        heightDelta <= _heightToleranceCm;
  }

  static GymTargetsEntity _buildCustomTargets({
    required UserWeightGoalEntity phase,
    required DailyFocusEntity dailyFocus,
  }) {
    final phaseBase = _phaseBase(phase);
    final adjusted = _applyCustomDailyFocus(dailyFocus: dailyFocus, base: phaseBase);
    final kcal = adjusted.kcal;
    final protein = adjusted.protein;
    final fat = adjusted.fat;
    final carbs = _carbsFromKcal(kcal: kcal, protein: protein, fat: fat);

    return GymTargetsEntity(
      kcalGoal: kcal.roundToDouble(),
      carbsGoal: carbs.roundToDouble(),
      fatGoal: fat.roundToDouble(),
      proteinGoal: protein.roundToDouble(),
    );
  }

  static _PhaseBase _applyCustomDailyFocus({
    required DailyFocusEntity dailyFocus,
    required _PhaseBase base,
  }) {
    switch (dailyFocus) {
      case DailyFocusEntity.lowerBody:
        return _PhaseBase(
          kcal: base.kcal + 140,
          protein: base.protein + 6,
          fat: (base.fat - 3).clamp(50, 120).toDouble(),
        );
      case DailyFocusEntity.upperBody:
        return _PhaseBase(
          kcal: base.kcal + 70,
          protein: base.protein + 3,
          fat: (base.fat - 1).clamp(50, 120).toDouble(),
        );
      case DailyFocusEntity.cardio:
        return _PhaseBase(
          kcal: base.kcal + 40,
          protein: base.protein,
          fat: (base.fat - 1).clamp(50, 120).toDouble(),
        );
      case DailyFocusEntity.rest:
        return _PhaseBase(
          kcal: base.kcal - 90,
          protein: base.protein + 5,
          fat: (base.fat + 3).clamp(50, 120).toDouble(),
        );
    }
  }

  static _PhaseBase _phaseBase(UserWeightGoalEntity phase) {
    switch (phase) {
      case UserWeightGoalEntity.loseWeight:
        return const _PhaseBase(
          kcal: _maintainKcal - _cutDeficitKcal,
          protein: _cutProtein,
          fat: _cutFat,
        );
      case UserWeightGoalEntity.maintainWeight:
        return const _PhaseBase(
          kcal: _maintainKcal,
          protein: _maintainProtein,
          fat: _maintainFat,
        );
      case UserWeightGoalEntity.gainWeight:
        return const _PhaseBase(
          kcal: _maintainKcal + _bulkSurplusKcal,
          protein: _bulkProtein,
          fat: _bulkFat,
        );
    }
  }

  static double _carbsFromKcal({
    required double kcal,
    required double protein,
    required double fat,
  }) {
    final carbKcal = kcal - (protein * 4) - (fat * 9);
    if (carbKcal <= 0) {
      return 0;
    }
    return carbKcal / 4;
  }
}

class _PhaseBase {
  final double kcal;
  final double protein;
  final double fat;

  const _PhaseBase({
    required this.kcal,
    required this.protein,
    required this.fat,
  });
}
