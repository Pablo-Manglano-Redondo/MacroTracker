import 'dart:math' as math;

import 'package:macrotracker/core/domain/entity/food_quality_score_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';

class CalculateFoodQualityScoreUsecase {
  FoodQualityScoreEntity scoreMeal(MealEntity meal) {
    return _scoreInput(_FoodQualityInput.fromMeal(meal));
  }

  FoodQualityScoreEntity scoreDraft(InterpretationDraftEntity draft) {
    return _scoreInput(_FoodQualityInput.fromDraft(draft));
  }

  bool canScoreMeal(MealEntity meal) {
    return _FoodQualityInput.fromMeal(meal).hasAnySignal;
  }

  FoodQualityDailySummaryEntity summarizeIntakes(
      Iterable<IntakeEntity> intakes) {
    double weightedScore = 0;
    double totalWeight = 0;
    var mealsCount = 0;

    for (final intake in intakes) {
      if (!canScoreMeal(intake.meal)) {
        continue;
      }
      final score = scoreMeal(intake.meal);
      final weight = intake.totalKcal > 0 ? intake.totalKcal : 1.0;
      weightedScore += score.score * weight;
      totalWeight += weight;
      mealsCount++;
    }

    if (mealsCount == 0 || totalWeight <= 0) {
      return const FoodQualityDailySummaryEntity(
        score: 0,
        band: FoodQualityBandEntity.fair,
        mealsCount: 0,
      );
    }

    final average = weightedScore / totalWeight;
    return FoodQualityDailySummaryEntity(
      score: average,
      band: _bandForScore(average.round()),
      mealsCount: mealsCount,
    );
  }

  FoodQualityScoreEntity _scoreInput(_FoodQualityInput input) {
    var score = 50.0;
    final contributions = <_ReasonContribution>[];
    var knownSignals = 0;

    if (input.fiber != null) {
      final normalized =
          _normalizeLinear(input.fiber!, 0, input.isServingBased ? 8 : 10);
      final contribution = normalized * 20;
      score += contribution;
      knownSignals++;
      if (contribution >= 6) {
        contributions.add(
          _ReasonContribution(
              FoodQualityReasonCode.highFiber, contribution.abs()),
        );
      }
    }

    if (input.protein != null) {
      final normalized = _normalizeLinear(input.protein!, 0, 20);
      final contribution = normalized * 15;
      score += contribution;
      knownSignals++;
      if (contribution >= 5) {
        contributions.add(
          _ReasonContribution(
              FoodQualityReasonCode.goodProtein, contribution.abs()),
        );
      }
    }

    if (input.sugar != null) {
      final sugarStart = input.isServingBased ? 10.0 : 5.0;
      final sugarEnd = input.isServingBased ? 30.0 : 25.0;
      final normalized = _normalizeLinear(input.sugar!, sugarStart, sugarEnd);
      final contribution = normalized * -20;
      score += contribution;
      knownSignals++;
      if (contribution <= -6) {
        contributions.add(
          _ReasonContribution(
              FoodQualityReasonCode.highSugar, contribution.abs()),
        );
      } else if (input.sugar! <= sugarStart) {
        contributions.add(
          _ReasonContribution(FoodQualityReasonCode.lowSugar, 4),
        );
      }
    }

    if (input.energy != null) {
      final contribution = _energyContribution(
        input.energy!,
        isServingBased: input.isServingBased,
      );
      score += contribution;
      knownSignals++;
      if (contribution >= 6) {
        contributions.add(
          _ReasonContribution(
              FoodQualityReasonCode.lowEnergyDensity, contribution.abs()),
        );
      } else if (contribution <= -6) {
        contributions.add(
          _ReasonContribution(
              FoodQualityReasonCode.highEnergyDensity, contribution.abs()),
        );
      }
    }

    if (input.saturatedFat != null) {
      final normalized = _normalizeLinear(
        input.saturatedFat!,
        input.isServingBased ? 3 : 3,
        input.isServingBased ? 10 : 10,
      );
      final contribution = normalized * -10;
      score += contribution;
      knownSignals++;
      if (contribution <= -4) {
        contributions.add(
          _ReasonContribution(
              FoodQualityReasonCode.highSaturatedFat, contribution.abs()),
        );
      }
    }

    final balanceBonus = _balanceBonus(input);
    score += balanceBonus;
    if (balanceBonus >= 4) {
      contributions.add(
        _ReasonContribution(
            FoodQualityReasonCode.balancedProfile, balanceBonus.abs()),
      );
    }

    final roundedScore = score.round().clamp(0, 100);
    final isPartial = knownSignals < 4;

    contributions.sort((a, b) => b.weight.compareTo(a.weight));
    final reasons = contributions
        .map((entry) => entry.code)
        .where((code) => code != FoodQualityReasonCode.partialData)
        .toList();

    final visibleReasons = <FoodQualityReasonCode>[];
    for (final reason in reasons) {
      if (visibleReasons.contains(reason)) {
        continue;
      }
      visibleReasons.add(reason);
      if (visibleReasons.length == 3) {
        break;
      }
    }
    if (isPartial) {
      visibleReasons.add(FoodQualityReasonCode.partialData);
    }

    return FoodQualityScoreEntity(
      score: roundedScore,
      band: _bandForScore(roundedScore),
      reasons: visibleReasons,
      isPartial: isPartial,
    );
  }

  double _balanceBonus(_FoodQualityInput input) {
    if (input.protein == null ||
        input.fiber == null ||
        input.sugar == null ||
        input.energy == null) {
      return 0;
    }

    final fiberThreshold = input.isServingBased ? 6.0 : 6.0;
    final proteinThreshold = input.isServingBased ? 15.0 : 12.0;
    final sugarThreshold = input.isServingBased ? 12.0 : 10.0;
    final energyUpperBound = input.isServingBased ? 450.0 : 250.0;

    if (input.fiber! >= fiberThreshold &&
        input.protein! >= proteinThreshold &&
        input.sugar! <= sugarThreshold &&
        input.energy! <= energyUpperBound) {
      return 10;
    }
    if (input.fiber! >= fiberThreshold / 2 &&
        input.protein! >= proteinThreshold / 2 &&
        input.sugar! <= sugarThreshold * 1.25) {
      return 4;
    }
    return 0;
  }

  double _energyContribution(double value, {required bool isServingBased}) {
    if (isServingBased) {
      if (value <= 150) {
        return 10;
      }
      if (value <= 250) {
        return 4;
      }
      if (value <= 400) {
        return 0;
      }
      if (value <= 650) {
        return -8;
      }
      return -15;
    }

    if (value <= 150) {
      return 10;
    }
    if (value <= 250) {
      return 4;
    }
    if (value <= 400) {
      return 0;
    }
    if (value <= 550) {
      return -8;
    }
    return -15;
  }

  double _normalizeLinear(double value, double start, double end) {
    if (end <= start) {
      return 0;
    }
    return ((value - start) / (end - start)).clamp(0, 1).toDouble();
  }

  FoodQualityBandEntity _bandForScore(int score) {
    if (score >= 85) {
      return FoodQualityBandEntity.excellent;
    }
    if (score >= 70) {
      return FoodQualityBandEntity.good;
    }
    if (score >= 50) {
      return FoodQualityBandEntity.fair;
    }
    return FoodQualityBandEntity.poor;
  }
}

class _ReasonContribution {
  final FoodQualityReasonCode code;
  final double weight;

  const _ReasonContribution(this.code, this.weight);
}

class _FoodQualityInput {
  final double? energy;
  final double? protein;
  final double? sugar;
  final double? fiber;
  final double? saturatedFat;
  final bool isServingBased;

  const _FoodQualityInput({
    required this.energy,
    required this.protein,
    required this.sugar,
    required this.fiber,
    required this.saturatedFat,
    required this.isServingBased,
  });

  bool get hasAnySignal =>
      energy != null ||
      protein != null ||
      sugar != null ||
      fiber != null ||
      saturatedFat != null;

  factory _FoodQualityInput.fromMeal(MealEntity meal) {
    final servingBased = meal.mealUnit == 'serving';
    if (servingBased) {
      return _FoodQualityInput(
        energy: meal.nutriments.energyPerUnit,
        protein: meal.nutriments.proteinsPerUnit,
        sugar: meal.nutriments.sugarsPerUnit,
        fiber: meal.nutriments.fiberPerUnit,
        saturatedFat: meal.nutriments.saturatedFatPerUnit,
        isServingBased: true,
      );
    }

    return _FoodQualityInput(
      energy: meal.nutriments.energyKcal100,
      protein: meal.nutriments.proteins100,
      sugar: meal.nutriments.sugars100,
      fiber: meal.nutriments.fiber100,
      saturatedFat: meal.nutriments.saturatedFat100,
      isServingBased: false,
    );
  }

  factory _FoodQualityInput.fromDraft(InterpretationDraftEntity draft) {
    return _FoodQualityInput(
      energy: math.max(0.0, draft.totalKcal).toDouble(),
      protein: math.max(0.0, draft.totalProtein).toDouble(),
      sugar: draft.totalSugar == null
          ? null
          : math.max(0.0, draft.totalSugar!).toDouble(),
      fiber: draft.totalFiber == null
          ? null
          : math.max(0.0, draft.totalFiber!).toDouble(),
      saturatedFat: null,
      isServingBased: true,
    );
  }
}
