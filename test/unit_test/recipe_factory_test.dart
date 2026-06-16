import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/utils/recipe_factory.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';

MealEntity _meal({
  String code = 'M1',
  double? kcal100 = 400.0,
  double? carbs100 = 50.0,
  double? fat100 = 15.0,
  double? protein100 = 20.0,
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
        sugars100: null,
        saturatedFat100: null,
        fiber100: null,
      ),
      source: MealSourceEntity.custom,
    );

InterpretationDraftItemEntity _item({
  required String label,
  required double amount,
  String unit = 'g',
  required double kcal,
  required double carbs,
  required double fat,
  required double protein,
  bool removed = false,
  MealEntity? matched,
}) {
  return InterpretationDraftItemEntity(
    id: 'IT-$label',
    label: label,
    matchedMealSnapshot: matched,
    amount: amount,
    unit: unit,
    kcal: kcal,
    carbs: carbs,
    fat: fat,
    protein: protein,
    confidenceBand: ConfidenceBandEntity.high,
    editable: true,
    removed: removed,
  );
}

InterpretationDraftEntity _draftWithItems(
    List<InterpretationDraftItemEntity> items) {
  final now = DateTime(2024, 1, 1);
  return InterpretationDraftEntity(
    id: 'D1',
    sourceType: DraftSourceEntity.text,
    inputText: 'test',
    localImagePath: null,
    title: 'My Draft',
    summary: 'Summary',
    totalKcal: 500,
    totalCarbs: 60,
    totalFat: 20,
    totalProtein: 30,
    confidenceBand: ConfidenceBandEntity.high,
    status: DraftStatusEntity.ready,
    createdAt: now,
    expiresAt: now.add(const Duration(hours: 24)),
    items: items,
  );
}

void main() {
  group('RecipeFactory.fromSingleMeal', () {
    test('creates recipe with one ingredient and 1 serving', () {
      final meal = _meal(code: 'M1');
      final recipe = RecipeFactory.fromSingleMeal(
        name: 'Single Meal Recipe',
        meal: meal,
        amount: 200,
        unit: 'g',
        quickCategory: QuickRecipeCategoryEntity.leanMeal,
      );

      expect(recipe.name, 'Single Meal Recipe');
      expect(recipe.defaultServings, 1);
      expect(recipe.ingredients.length, 1);
      expect(recipe.ingredients.first.amount, 200);
      expect(recipe.ingredients.first.unit, 'g');
      expect(recipe.ingredients.first.mealSnapshot.code, 'M1');
      expect(recipe.saved, isFalse);
      expect(recipe.pinned, isFalse);
      expect(recipe.timesUsed, 0);
    });

    test('assigns correct quickCategory', () {
      final meal = _meal();
      final recipe = RecipeFactory.fromSingleMeal(
        name: 'Pre Workout',
        meal: meal,
        amount: 100,
        unit: 'g',
        quickCategory: QuickRecipeCategoryEntity.preWorkout,
      );
      expect(recipe.quickCategory, QuickRecipeCategoryEntity.preWorkout);
    });
  });

  group('RecipeFactory.fromInterpretationDraft', () {
    test('creates recipe with correct name and draft summary as notes', () {
      final draft = _draftWithItems([
        _item(
            label: 'Rice',
            amount: 200,
            kcal: 260,
            carbs: 56,
            fat: 2,
            protein: 6),
      ]);

      final recipe = RecipeFactory.fromInterpretationDraft(
        name: 'Draft Recipe',
        draft: draft,
        quickCategory: QuickRecipeCategoryEntity.leanMeal,
      );

      expect(recipe.name, 'Draft Recipe');
      expect(recipe.notes, 'Summary');
    });

    test('excludes removed items from ingredients', () {
      final draft = _draftWithItems([
        _item(
            label: 'Rice',
            amount: 200,
            kcal: 260,
            carbs: 56,
            fat: 2,
            protein: 6),
        _item(
            label: 'Chicken',
            amount: 150,
            kcal: 250,
            carbs: 0,
            fat: 5,
            protein: 45,
            removed: true),
        _item(
            label: 'Broccoli',
            amount: 100,
            kcal: 35,
            carbs: 7,
            fat: 0,
            protein: 3),
      ]);

      final recipe = RecipeFactory.fromInterpretationDraft(
        name: 'Draft Recipe',
        draft: draft,
        quickCategory: QuickRecipeCategoryEntity.leanMeal,
      );

      // Only Rice and Broccoli (Chicken was removed)
      expect(recipe.ingredients.length, 2);
      final labels =
          recipe.ingredients.map((i) => i.mealSnapshot.name).toList();
      expect(labels, contains('Rice'));
      expect(labels, contains('Broccoli'));
    });

    test('uses matchedMealSnapshot when available', () {
      final matchedMeal = _meal(code: 'FDC-1234');
      final draft = _draftWithItems([
        _item(
            label: 'Oats',
            amount: 100,
            kcal: 380,
            carbs: 66,
            fat: 7,
            protein: 13,
            matched: matchedMeal),
      ]);

      final recipe = RecipeFactory.fromInterpretationDraft(
        name: 'Oats Recipe',
        draft: draft,
        quickCategory: QuickRecipeCategoryEntity.shake,
      );

      expect(recipe.ingredients.first.mealSnapshot.code, 'FDC-1234');
    });

    test('builds synthetic snapshot when no matched meal', () {
      final draft = _draftWithItems([
        _item(
          label: 'Unknown Food',
          amount: 100,
          unit: 'g',
          kcal: 200,
          carbs: 30,
          fat: 8,
          protein: 12,
        ),
      ]);

      final recipe = RecipeFactory.fromInterpretationDraft(
        name: 'Unknown Recipe',
        draft: draft,
        quickCategory: QuickRecipeCategoryEntity.leanMeal,
      );

      expect(recipe.ingredients.length, 1);
      final snapshot = recipe.ingredients.first.mealSnapshot;
      // name from label
      expect(snapshot.name, 'Unknown Food');
      // nutriments scaled: kcal/100g = (200 / 100) * 100 = 200
      expect(snapshot.nutriments.energyKcal100, closeTo(200.0, 0.01));
    });

    test('assigns positions in order', () {
      final draft = _draftWithItems([
        _item(
            label: 'A', amount: 100, kcal: 100, carbs: 20, fat: 5, protein: 8),
        _item(
            label: 'B',
            amount: 200,
            kcal: 200,
            carbs: 40,
            fat: 10,
            protein: 16),
      ]);

      final recipe = RecipeFactory.fromInterpretationDraft(
        name: 'Ordered Recipe',
        draft: draft,
        quickCategory: QuickRecipeCategoryEntity.leanMeal,
      );

      expect(recipe.ingredients[0].position, 0);
      expect(recipe.ingredients[1].position, 1);
    });

    test('normalizes oz amount for synthetic snapshot', () {
      // 1 oz = ~28.35g; kcal=200 for 1oz => per unit = 200/28.35 * 100 ≈ 705
      final draft = _draftWithItems([
        _item(
          label: 'Butter',
          amount: 1,
          unit: 'oz',
          kcal: 200,
          carbs: 0,
          fat: 22,
          protein: 0,
        ),
      ]);

      final recipe = RecipeFactory.fromInterpretationDraft(
        name: 'Oz Recipe',
        draft: draft,
        quickCategory: QuickRecipeCategoryEntity.leanMeal,
      );

      final snapshot = recipe.ingredients.first.mealSnapshot;
      // normalizedAmount = UnitCalc.ozToG(1) ≈ 28.35
      // kcal100 = (200 / 28.35) * 100 ≈ 705.5
      expect(snapshot.nutriments.energyKcal100, closeTo(705.5, 1.0));
    });

    test('default recipe fields are correct', () {
      final draft = _draftWithItems([]);
      final recipe = RecipeFactory.fromInterpretationDraft(
        name: 'Empty Draft Recipe',
        draft: draft,
        quickCategory: QuickRecipeCategoryEntity.postWorkout,
      );

      expect(recipe.defaultServings, 1);
      expect(recipe.saved, isFalse);
      expect(recipe.pinned, isFalse);
      expect(recipe.timesUsed, 0);
      expect(recipe.lastUsedAt, isNull);
      expect(recipe.quickCategory, QuickRecipeCategoryEntity.postWorkout);
      expect(recipe.ingredients, isEmpty);
    });
  });

  group('QuickRecipeCategoryEntityX.inferLegacyFromRecipe', () {
    RecipeEntity makeRecipe(String name, {String? notes}) {
      final now = DateTime(2024, 1, 1);
      return RecipeEntity(
        id: 'R1',
        name: name,
        notes: notes,
        defaultServings: 1,
        yieldQuantity: null,
        yieldUnit: null,
        saved: false,
        pinned: false,
        timesUsed: 0,
        lastUsedAt: null,
        quickCategory: null,
        createdAt: now,
        updatedAt: now,
        ingredients: [],
      );
    }

    test('infers postWorkout from "post workout" in name', () {
      final recipe = makeRecipe('Post Workout Shake');
      expect(QuickRecipeCategoryEntityX.inferLegacyFromRecipe(recipe),
          QuickRecipeCategoryEntity.postWorkout);
    });

    test('infers shake from "whey" in name', () {
      final recipe = makeRecipe('Whey Protein Bowl');
      expect(QuickRecipeCategoryEntityX.inferLegacyFromRecipe(recipe),
          QuickRecipeCategoryEntity.shake);
    });

    test('infers preWorkout from "pre entreno" in notes', () {
      final recipe = makeRecipe('Morning Meal', notes: 'pre entreno ligero');
      expect(QuickRecipeCategoryEntityX.inferLegacyFromRecipe(recipe),
          QuickRecipeCategoryEntity.preWorkout);
    });

    test('defaults to leanMeal when no keywords match', () {
      final recipe = makeRecipe('Avocado Toast');
      expect(QuickRecipeCategoryEntityX.inferLegacyFromRecipe(recipe),
          QuickRecipeCategoryEntity.leanMeal);
    });

    test('inferTaggedIntakeType detects #breakfast tag', () {
      final recipe = makeRecipe('My Breakfast', notes: '#breakfast oats');
      expect(
          QuickRecipeCategoryEntityX.inferTaggedIntakeType(recipe), isNotNull);
    });

    test('inferTaggedIntakeType returns null when no tags', () {
      final recipe = makeRecipe('Plain Rice');
      expect(QuickRecipeCategoryEntityX.inferTaggedIntakeType(recipe), isNull);
    });
  });

  group('RecipeSaveCategoryEntityX.quickCategory mapping', () {
    test('maps breakfast to leanMeal', () {
      expect(RecipeSaveCategoryEntity.breakfast.quickCategory,
          QuickRecipeCategoryEntity.leanMeal);
    });

    test('maps preWorkout to preWorkout', () {
      expect(RecipeSaveCategoryEntity.preWorkout.quickCategory,
          QuickRecipeCategoryEntity.preWorkout);
    });

    test('maps shake to shake', () {
      expect(RecipeSaveCategoryEntity.shake.quickCategory,
          QuickRecipeCategoryEntity.shake);
    });
  });
}
