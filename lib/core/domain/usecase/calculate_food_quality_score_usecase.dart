import 'dart:math' as math;

import 'package:macrotracker/core/domain/entity/food_quality_score_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:collection/collection.dart';

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

    final double energyVal = input.energy ?? 0;
    final double baseKcal = energyVal > 0 ? energyVal : 100.0;

    if (input.novaGroup != null) {
      final nova = input.novaGroup!;
      if (nova == 1) {
        score += 10.0;
        contributions.add(const _ReasonContribution(FoodQualityReasonCode.unprocessedFood, 10.0));
      } else if (nova == 3) {
        score -= 10.0;
      } else if (nova == 4) {
        score -= 25.0;
        contributions.add(const _ReasonContribution(FoodQualityReasonCode.ultraProcessedFood, 25.0));
      }
      knownSignals++;
    }

    int micronutrientsPresent = 0;
    if (input.sodium != null && input.sodium! > 0) micronutrientsPresent++;
    if (input.potassium != null && input.potassium! > 0) micronutrientsPresent++;
    if (input.calcium != null && input.calcium! > 0) micronutrientsPresent++;
    if (input.iron != null && input.iron! > 0) micronutrientsPresent++;
    if (input.vitaminC != null && input.vitaminC! > 0) micronutrientsPresent++;
    if (input.vitaminD != null && input.vitaminD! > 0) micronutrientsPresent++;

    if (micronutrientsPresent >= 3) {
      final bonus = micronutrientsPresent * 2.0; // up to 12 points
      score += bonus;
      contributions.add(_ReasonContribution(FoodQualityReasonCode.highMicronutrients, bonus));
      knownSignals++;
    }

    if (input.fiber != null) {
      final fiberVal = input.fiber!;
      final fiberDensity = (fiberVal / baseKcal) * 100.0; // g per 100 kcal
      final normalized = _normalizeLinear(fiberDensity, 0.0, 2.0);
      final contribution = normalized * 20.0;
      score += contribution;
      knownSignals++;
      if (contribution >= 6.0) {
        contributions.add(
          _ReasonContribution(
              FoodQualityReasonCode.highFiber, contribution.abs()),
        );
      }
    }

    if (input.protein != null) {
      final proteinVal = input.protein!;
      final proteinDensity = (proteinVal / baseKcal) * 100.0; // g per 100 kcal
      final normalized = _normalizeLinear(proteinDensity, 0.0, 8.0);
      final contribution = normalized * 20.0;
      score += contribution;
      knownSignals++;
      if (contribution >= 6.0) {
        contributions.add(
          _ReasonContribution(
              FoodQualityReasonCode.goodProtein, contribution.abs()),
        );
      }
    }

    if (input.sugar != null) {
      final sugarVal = input.sugar!;
      final sugarKcal = sugarVal * 4.0;
      final sugarPct = (sugarKcal / baseKcal) * 100.0; // % of energy from sugar
      final normalized = _normalizeLinear(sugarPct, 10.0, 25.0);
      final contribution = normalized * -20.0;
      score += contribution;
      knownSignals++;

      if (contribution <= -6.0) {
        contributions.add(
          _ReasonContribution(
              FoodQualityReasonCode.highSugar, contribution.abs()),
        );
      } else if (sugarPct <= 5.0) {
        contributions.add(
          _ReasonContribution(FoodQualityReasonCode.lowSugar, 4.0),
        );
      }
    }

    if (input.energy != null && !input.isServingBased) {
      final densityKcal = input.energy!; // kcal/100g
      double contribution = 0.0;
      if (densityKcal < 150.0) {
        contribution = 5.0;
      } else if (densityKcal > 350.0) {
        contribution = -10.0;
      }
      score += contribution;
      knownSignals++;

      if (contribution >= 5.0) {
        contributions.add(
          _ReasonContribution(
              FoodQualityReasonCode.lowEnergyDensity, contribution.abs()),
        );
      } else if (contribution <= -6.0) {
        contributions.add(
          _ReasonContribution(
              FoodQualityReasonCode.highEnergyDensity, contribution.abs()),
        );
      }
    }

    if (input.saturatedFat != null) {
      final satFatVal = input.saturatedFat!;
      final satFatKcal = satFatVal * 9.0;
      final satFatPct = (satFatKcal / baseKcal) * 100.0; // % of energy from sat fat
      final normalized = _normalizeLinear(satFatPct, 10.0, 20.0);
      final contribution = normalized * -15.0;
      score += contribution;
      knownSignals++;

      if (contribution <= -4.0) {
        contributions.add(
          _ReasonContribution(
              FoodQualityReasonCode.highSaturatedFat, contribution.abs()),
        );
      }
    }

    final balanceBonus = _balanceBonus(input, baseKcal);
    score += balanceBonus;
    if (balanceBonus >= 4.0) {
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

  double _balanceBonus(_FoodQualityInput input, double baseKcal) {
    if (input.protein == null ||
        input.fiber == null ||
        input.sugar == null ||
        input.energy == null) {
      return 0.0;
    }

    final proteinDensity = (input.protein! / baseKcal) * 100.0;
    final fiberDensity = (input.fiber! / baseKcal) * 100.0;
    final sugarPct = (input.sugar! * 4.0 / baseKcal) * 100.0;

    if (fiberDensity >= 1.0 &&
        proteinDensity >= 4.0 &&
        sugarPct <= 10.0) {
      return 10.0;
    }
    if (fiberDensity >= 0.5 &&
        proteinDensity >= 2.0 &&
        sugarPct <= 15.0) {
      return 4.0;
    }
    return 0.0;
  }

  double _normalizeLinear(double value, double start, double end) {
    if (end <= start) {
      return 0.0;
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
  final int? novaGroup;
  final double? sodium;
  final double? potassium;
  final double? calcium;
  final double? iron;
  final double? vitaminC;
  final double? vitaminD;
  final bool isServingBased;

  const _FoodQualityInput({
    required this.energy,
    required this.protein,
    required this.sugar,
    required this.fiber,
    required this.saturatedFat,
    this.novaGroup,
    this.sodium,
    this.potassium,
    this.calcium,
    this.iron,
    this.vitaminC,
    this.vitaminD,
    required this.isServingBased,
  });

  bool get hasAnySignal =>
      energy != null ||
      protein != null ||
      sugar != null ||
      fiber != null ||
      saturatedFat != null ||
      novaGroup != null ||
      sodium != null ||
      potassium != null ||
      calcium != null ||
      iron != null ||
      vitaminC != null ||
      vitaminD != null;

  factory _FoodQualityInput.fromMeal(MealEntity meal) {
    final servingBased = meal.mealUnit == 'serving';
    if (servingBased) {
      return _FoodQualityInput(
        energy: meal.nutriments.energyPerUnit,
        protein: meal.nutriments.proteinsPerUnit,
        sugar: meal.nutriments.sugarsPerUnit,
        fiber: meal.nutriments.fiberPerUnit,
        saturatedFat: meal.nutriments.saturatedFatPerUnit,
        novaGroup: meal.nutriments.novaGroup,
        sodium: meal.nutriments.sodiumPerUnit,
        potassium: meal.nutriments.potassiumPerUnit,
        calcium: meal.nutriments.calciumPerUnit,
        iron: meal.nutriments.ironPerUnit,
        vitaminC: meal.nutriments.vitaminCPerUnit,
        vitaminD: meal.nutriments.vitaminDPerUnit,
        isServingBased: true,
      );
    }

    return _FoodQualityInput(
      energy: meal.nutriments.energyKcal100,
      protein: meal.nutriments.proteins100,
      sugar: meal.nutriments.sugars100,
      fiber: meal.nutriments.fiber100,
      saturatedFat: meal.nutriments.saturatedFat100,
      novaGroup: meal.nutriments.novaGroup,
      sodium: meal.nutriments.sodium100,
      potassium: meal.nutriments.potassium100,
      calcium: meal.nutriments.calcium100,
      iron: meal.nutriments.iron100,
      vitaminC: meal.nutriments.vitaminC100,
      vitaminD: meal.nutriments.vitaminD100,
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
      novaGroup: draft.items.map((e) => e.novaGroup).whereType<int>().maxOrNull,
      sodium: draft.totalSodium,
      potassium: draft.totalPotassium,
      calcium: draft.totalCalcium,
      iron: draft.totalIron,
      vitaminC: draft.totalVitaminC,
      vitaminD: draft.totalVitaminD,
      isServingBased: true,
    );
  }
}
