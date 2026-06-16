import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/utils/meal_aggregate_factory.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MealEntity _meal({
  String code = 'M1',
  double? kcal100 = 400.0,
  double? carbs100 = 50.0,
  double? fat100 = 15.0,
  double? protein100 = 20.0,
  double? sugar100,
  double? satFat100,
  double? fiber100,
  String mealUnit = 'g',
  double? servingQuantity,
}) =>
    MealEntity(
      code: code,
      name: 'Meal $code',
      url: null,
      mealQuantity: null,
      mealUnit: mealUnit,
      servingQuantity: servingQuantity,
      servingUnit: mealUnit,
      servingSize: null,
      nutriments: MealNutrimentsEntity(
        energyKcal100: kcal100,
        carbohydrates100: carbs100,
        fat100: fat100,
        proteins100: protein100,
        sugars100: sugar100,
        saturatedFat100: satFat100,
        fiber100: fiber100,
      ),
      source: MealSourceEntity.custom,
    );

RecipeEntity _recipe({
  String name = 'Test Recipe',
  double defaultServings = 1,
  String? notes,
  List<RecipeIngredientEntity> ingredients = const [],
  QuickRecipeCategoryEntity? quickCategory,
}) {
  final now = DateTime(2024, 1, 1);
  return RecipeEntity(
    id: 'R1',
    name: name,
    notes: notes,
    defaultServings: defaultServings,
    yieldQuantity: null,
    yieldUnit: null,
    saved: false,
    pinned: false,
    timesUsed: 0,
    lastUsedAt: null,
    quickCategory: quickCategory,
    createdAt: now,
    updatedAt: now,
    ingredients: ingredients,
  );
}

InterpretationDraftEntity _draft({
  double kcal = 500,
  double carbs = 60,
  double fat = 20,
  double protein = 30,
  double? fiber,
  double? sugar,
}) {
  final now = DateTime(2024, 1, 1);
  return InterpretationDraftEntity(
    id: 'D1',
    sourceType: DraftSourceEntity.text,
    inputText: 'test meal',
    localImagePath: null,
    title: 'Draft Meal',
    summary: 'A test draft',
    totalKcal: kcal,
    totalCarbs: carbs,
    totalFat: fat,
    totalProtein: protein,
    totalFiber: fiber,
    totalSugar: sugar,
    confidenceBand: ConfidenceBandEntity.high,
    status: DraftStatusEntity.ready,
    createdAt: now,
    expiresAt: now.add(const Duration(hours: 24)),
    items: [],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MealAggregateFactory.fromRecipe', () {
    test('creates MealEntity with correct name and unit', () {
      final recipe = _recipe(
        name: 'My Recipe',
        defaultServings: 1,
        ingredients: [
          RecipeIngredientEntity(
            id: 'I1',
            mealSnapshot: _meal(kcal100: 200, carbs100: 30, fat100: 10,
                protein100: 15),
            amount: 100,
            unit: 'g',
            position: 0,
          ),
        ],
      );

      final meal = MealAggregateFactory.fromRecipe(recipe);

      expect(meal.name, 'My Recipe');
      expect(meal.mealUnit, 'serving');
      expect(meal.servingUnit, 'serving');
    });

    test('aggregates single 100g ingredient kcal correctly', () {
      // 100g of a meal with 200 kcal/100g => 200 kcal total in 1 serving
      final recipe = _recipe(
        defaultServings: 1,
        ingredients: [
          RecipeIngredientEntity(
            id: 'I1',
            mealSnapshot: _meal(kcal100: 200, carbs100: 30, fat100: 10,
                protein100: 15),
            amount: 100,
            unit: 'g',
            position: 0,
          ),
        ],
      );

      final meal = MealAggregateFactory.fromRecipe(recipe);

      // energyKcal100 = totalKcal / defaultServings = 200 / 1 = 200
      expect(meal.nutriments.energyKcal100, closeTo(200.0, 0.01));
      expect(meal.nutriments.carbohydrates100, closeTo(30.0, 0.01));
      expect(meal.nutriments.fat100, closeTo(10.0, 0.01));
      expect(meal.nutriments.proteins100, closeTo(15.0, 0.01));
    });

    test('divides by defaultServings when > 1', () {
      // 2 servings: divide total by 2
      final recipe = _recipe(
        defaultServings: 2,
        ingredients: [
          RecipeIngredientEntity(
            id: 'I1',
            mealSnapshot: _meal(kcal100: 400, carbs100: 50, fat100: 15,
                protein100: 20),
            amount: 100,
            unit: 'g',
            position: 0,
          ),
        ],
      );

      final meal = MealAggregateFactory.fromRecipe(recipe);
      // totalKcal = 400, per serving = 200
      expect(meal.nutriments.energyKcal100, closeTo(200.0, 0.01));
    });

    test('uses 1.0 as divisor when defaultServings is 0', () {
      final recipe = _recipe(
        defaultServings: 0,
        ingredients: [
          RecipeIngredientEntity(
            id: 'I1',
            mealSnapshot: _meal(kcal100: 300),
            amount: 100,
            unit: 'g',
            position: 0,
          ),
        ],
      );

      final meal = MealAggregateFactory.fromRecipe(recipe);
      // divisor defaults to 1.0 when <= 0
      expect(meal.nutriments.energyKcal100, closeTo(300.0, 0.01));
    });

    test('aggregates multiple ingredients', () {
      final recipe = _recipe(
        defaultServings: 1,
        ingredients: [
          RecipeIngredientEntity(
            id: 'I1',
            mealSnapshot: _meal(kcal100: 200, carbs100: 30, fat100: 10,
                protein100: 15),
            amount: 100,
            unit: 'g',
            position: 0,
          ),
          RecipeIngredientEntity(
            id: 'I2',
            mealSnapshot: _meal(code: 'M2', kcal100: 100, carbs100: 20,
                fat100: 5, protein100: 10),
            amount: 100,
            unit: 'g',
            position: 1,
          ),
        ],
      );

      final meal = MealAggregateFactory.fromRecipe(recipe);
      // Total kcal = 200 + 100 = 300
      expect(meal.nutriments.energyKcal100, closeTo(300.0, 0.01));
      expect(meal.nutriments.carbohydrates100, closeTo(50.0, 0.01));
    });

    test('aggregates optional fiber and sugar', () {
      final recipe = _recipe(
        defaultServings: 1,
        ingredients: [
          RecipeIngredientEntity(
            id: 'I1',
            mealSnapshot: _meal(
                kcal100: 200, carbs100: 30, fat100: 10, protein100: 15,
                fiber100: 4.0, sugar100: 8.0, satFat100: 2.0),
            amount: 100,
            unit: 'g',
            position: 0,
          ),
        ],
      );

      final meal = MealAggregateFactory.fromRecipe(recipe);
      expect(meal.nutriments.fiber100, closeTo(4.0, 0.01));
      expect(meal.nutriments.sugars100, closeTo(8.0, 0.01));
    });
  });

  group('MealAggregateFactory.fromInterpretationDraft', () {
    test('creates MealEntity with correct macros from draft', () {
      final draft = _draft(kcal: 600, carbs: 70, fat: 25, protein: 35);
      final meal = MealAggregateFactory.fromInterpretationDraft(draft);

      expect(meal.name, 'Draft Meal');
      expect(meal.nutriments.energyKcal100, closeTo(600, 0.01));
      expect(meal.nutriments.carbohydrates100, closeTo(70, 0.01));
      expect(meal.nutriments.fat100, closeTo(25, 0.01));
      expect(meal.nutriments.proteins100, closeTo(35, 0.01));
    });

    test('sets mealUnit and servingUnit to serving', () {
      final draft = _draft();
      final meal = MealAggregateFactory.fromInterpretationDraft(draft);
      expect(meal.mealUnit, 'serving');
      expect(meal.servingUnit, 'serving');
    });
  });

  group('InterpretationDraftEntity.copyWith', () {
    test('preserves fields not overridden', () {
      final draft = _draft(kcal: 500);
      final updated = draft.copyWith(totalKcal: 800);
      expect(updated.totalKcal, 800);
      expect(updated.totalCarbs, draft.totalCarbs);
      expect(updated.id, draft.id);
    });

    test('status can be updated independently', () {
      final draft = _draft();
      final updated = draft.copyWith(status: DraftStatusEntity.failed);
      expect(updated.status, DraftStatusEntity.failed);
      expect(updated.totalKcal, draft.totalKcal);
    });
  });

  group('InterpretationDraftItemEntity.copyWith', () {
    test('clones with updated removed flag', () {
      final item = InterpretationDraftItemEntity(
        id: 'IT1',
        label: 'Rice',
        matchedMealSnapshot: null,
        amount: 200,
        unit: 'g',
        kcal: 260,
        carbs: 56,
        fat: 2,
        protein: 6,
        confidenceBand: ConfidenceBandEntity.high,
        editable: true,
        removed: false,
      );

      final removed = item.copyWith(removed: true);
      expect(removed.removed, isTrue);
      expect(removed.label, 'Rice');
      expect(removed.amount, 200);
    });
  });
}
