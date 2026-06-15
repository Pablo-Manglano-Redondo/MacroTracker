import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/utils/meal_aggregate_factory.dart';
import 'package:macrotracker/core/utils/meal_portion_nutrition.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';

void main() {
  group('serving nutrition', () {
    test('recipe aggregate stores one serving without multiplying by 100', () {
      final recipe = _recipeWith(
        ingredients: [
          RecipeIngredientEntity(
            id: 'ingredient-1',
            mealSnapshot: _meal(
              kcal100: 200,
              carbs100: 10,
              fat100: 8,
              protein100: 20,
            ),
            amount: 150,
            unit: 'g',
            position: 0,
          ),
        ],
      );

      final aggregate = MealAggregateFactory.fromRecipe(recipe);
      final nutrition =
          MealPortionCalculator.calculate(aggregate, 1, 'serving');
      final intake = _intake(aggregate, amount: 1);

      expect(aggregate.nutriments.energyKcal100, 300);
      expect(aggregate.nutriments.carbohydrates100, 15);
      expect(aggregate.nutriments.fat100, 12);
      expect(aggregate.nutriments.proteins100, 30);
      expect(aggregate.servingQuantity, 100);
      expect(nutrition.kcal, 300);
      expect(intake.totalKcal, 300);
      expect(intake.totalCarbsGram, 15);
      expect(intake.totalFatsGram, 12);
      expect(intake.totalProteinsGram, 30);
    });

    test('interpretation draft aggregate logs one serving totals directly', () {
      final draft = InterpretationDraftEntity(
        id: 'draft-1',
        sourceType: DraftSourceEntity.photo,
        inputText: null,
        localImagePath: null,
        title: 'Bowl',
        summary: null,
        totalKcal: 520,
        totalCarbs: 64,
        totalFat: 18,
        totalProtein: 28,
        totalFiber: 8,
        totalSugar: 12,
        confidenceBand: ConfidenceBandEntity.medium,
        status: DraftStatusEntity.ready,
        createdAt: DateTime.utc(2026),
        expiresAt: DateTime.utc(2026, 1, 2),
        items: const [],
      );

      final aggregate = MealAggregateFactory.fromInterpretationDraft(draft);
      final intake = _intake(aggregate, amount: 1);

      expect(aggregate.nutriments.energyKcal100, 520);
      expect(aggregate.nutriments.carbohydrates100, 64);
      expect(aggregate.nutriments.fat100, 18);
      expect(aggregate.nutriments.proteins100, 28);
      expect(aggregate.nutriments.fiber100, 8);
      expect(aggregate.nutriments.sugars100, 12);
      expect(intake.totalKcal, 520);
      expect(intake.totalCarbsGram, 64);
      expect(intake.totalFatsGram, 18);
      expect(intake.totalProteinsGram, closeTo(28, 0.0001));
    });

    test('legacy converted serving intakes are not converted twice', () {
      final meal = _meal(
        kcal100: 250,
        carbs100: 20,
        fat100: 10,
        protein100: 15,
        servingQuantity: 50,
      );

      final legacyIntake = _intake(meal, amount: 50);
      final newIntake = _intake(meal, amount: 1);

      expect(legacyIntake.totalKcal, 125);
      expect(newIntake.totalKcal, 125);
    });
  });
}

MealEntity _meal({
  required double kcal100,
  required double carbs100,
  required double fat100,
  required double protein100,
  double? servingQuantity,
}) {
  return MealEntity(
    code: 'meal-1',
    name: 'Meal',
    url: null,
    mealQuantity: null,
    mealUnit: 'g',
    servingQuantity: servingQuantity,
    servingUnit: servingQuantity == null ? null : 'g',
    servingSize: servingQuantity == null ? null : '${servingQuantity}g',
    nutriments: MealNutrimentsEntity(
      energyKcal100: kcal100,
      carbohydrates100: carbs100,
      fat100: fat100,
      proteins100: protein100,
      sugars100: null,
      saturatedFat100: null,
      fiber100: null,
    ),
    source: MealSourceEntity.custom,
  );
}

RecipeEntity _recipeWith({required List<RecipeIngredientEntity> ingredients}) {
  return RecipeEntity(
    id: 'recipe-1',
    name: 'Saved recipe',
    notes: null,
    defaultServings: 1,
    yieldQuantity: null,
    yieldUnit: null,
    saved: true,
    pinned: false,
    timesUsed: 0,
    lastUsedAt: null,
    quickCategory: null,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    ingredients: ingredients,
  );
}

IntakeEntity _intake(MealEntity meal, {required double amount}) {
  return IntakeEntity(
    id: 'intake-1',
    unit: 'serving',
    amount: amount,
    type: IntakeTypeEntity.lunch,
    meal: meal,
    dateTime: DateTime.utc(2026),
  );
}
