import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/food_quality_score_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/calculate_food_quality_score_usecase.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

void main() {
  final usecase = CalculateFoodQualityScoreUsecase();

  MealEntity buildMeal({
    required String code,
    required double kcal100,
    required double carbs100,
    required double fat100,
    required double protein100,
    double? sugar100,
    double? fiber100,
    double? saturatedFat100,
  }) {
    return MealEntity(
      code: code,
      name: code,
      brands: null,
      thumbnailImageUrl: null,
      mainImageUrl: null,
      url: null,
      mealQuantity: '100',
      mealUnit: 'g',
      servingQuantity: null,
      servingUnit: 'g',
      servingSize: null,
      nutriments: MealNutrimentsEntity(
        energyKcal100: kcal100,
        carbohydrates100: carbs100,
        fat100: fat100,
        proteins100: protein100,
        sugars100: sugar100,
        saturatedFat100: saturatedFat100,
        fiber100: fiber100,
      ),
      source: MealSourceEntity.custom,
    );
  }

  test('scores a high-fiber high-protein food above a sugary dense food', () {
    final healthyMeal = buildMeal(
      code: 'healthy',
      kcal100: 160,
      carbs100: 18,
      fat100: 5,
      protein100: 19,
      sugar100: 3,
      fiber100: 9,
      saturatedFat100: 1.2,
    );
    final poorMeal = buildMeal(
      code: 'poor',
      kcal100: 520,
      carbs100: 58,
      fat100: 28,
      protein100: 4,
      sugar100: 34,
      fiber100: 1,
      saturatedFat100: 12,
    );

    final healthyScore = usecase.scoreMeal(healthyMeal);
    final poorScore = usecase.scoreMeal(poorMeal);

    expect(healthyScore.score, greaterThan(poorScore.score));
    expect(healthyScore.score, greaterThanOrEqualTo(70));
    expect(poorScore.score, lessThan(50));
  });

  test('marks partial scores when key nutrients are missing', () {
    final partialMeal = buildMeal(
      code: 'partial',
      kcal100: 210,
      carbs100: 24,
      fat100: 8,
      protein100: 11,
    );

    final score = usecase.scoreMeal(partialMeal);

    expect(score.isPartial, isTrue);
    expect(score.reasons, contains(FoodQualityReasonCode.partialData));
  });

  test('computes a kcal-weighted daily average across intakes', () {
    final lightMeal = buildMeal(
      code: 'light',
      kcal100: 140,
      carbs100: 16,
      fat100: 4,
      protein100: 18,
      sugar100: 2,
      fiber100: 8,
      saturatedFat100: 1,
    );
    final heavyMeal = buildMeal(
      code: 'heavy',
      kcal100: 510,
      carbs100: 62,
      fat100: 26,
      protein100: 5,
      sugar100: 30,
      fiber100: 1,
      saturatedFat100: 10,
    );

    final lightIntake = IntakeEntity(
      id: '1',
      unit: 'g',
      amount: 100,
      type: IntakeTypeEntity.breakfast,
      meal: lightMeal,
      dateTime: DateTime(2026, 5, 16),
    );
    final heavyIntake = IntakeEntity(
      id: '2',
      unit: 'g',
      amount: 300,
      type: IntakeTypeEntity.lunch,
      meal: heavyMeal,
      dateTime: DateTime(2026, 5, 16),
    );

    final summary = usecase.summarizeIntakes([lightIntake, heavyIntake]);

    expect(summary.mealsCount, 2);
    expect(summary.score, lessThan(usecase.scoreMeal(lightMeal).score.toDouble()));
    expect(summary.score, greaterThan(usecase.scoreMeal(heavyMeal).score.toDouble()));
  });
}
