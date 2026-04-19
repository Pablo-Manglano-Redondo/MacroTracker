import 'package:opennutritracker/core/utils/calc/unit_calc.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:opennutritracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:opennutritracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';

class RecipeFactory {
  static RecipeEntity fromSingleMeal({
    required String name,
    required MealEntity meal,
    required double amount,
    required String unit,
  }) {
    final now = DateTime.now();
    return RecipeEntity(
      id: IdGenerator.getUniqueID(),
      name: name,
      notes: null,
      defaultServings: 1,
      yieldQuantity: null,
      yieldUnit: null,
      favorite: false,
      createdAt: now,
      updatedAt: now,
      ingredients: [
        RecipeIngredientEntity(
          id: IdGenerator.getUniqueID(),
          mealSnapshot: meal,
          amount: amount,
          unit: unit,
          position: 0,
        ),
      ],
    );
  }

  static RecipeEntity fromInterpretationDraft({
    required String name,
    required InterpretationDraftEntity draft,
  }) {
    final now = DateTime.now();
    final activeItems =
        draft.items.where((item) => !item.removed).toList(growable: false);

    return RecipeEntity(
      id: IdGenerator.getUniqueID(),
      name: name,
      notes: draft.summary,
      defaultServings: 1,
      yieldQuantity: null,
      yieldUnit: null,
      favorite: false,
      createdAt: now,
      updatedAt: now,
      ingredients: activeItems
          .asMap()
          .entries
          .map(
            (entry) => RecipeIngredientEntity(
              id: IdGenerator.getUniqueID(),
              mealSnapshot: _resolveMealSnapshot(entry.value),
              amount: entry.value.amount,
              unit: entry.value.unit,
              position: entry.key,
            ),
          )
          .toList(growable: false),
    );
  }

  static MealEntity _resolveMealSnapshot(InterpretationDraftItemEntity item) {
    return item.matchedMealSnapshot ?? _buildSyntheticMealSnapshot(item);
  }

  static MealEntity _buildSyntheticMealSnapshot(
      InterpretationDraftItemEntity item) {
    final normalizedAmount = _normalizeAmount(item.amount, item.unit);
    final safeDivisor = normalizedAmount <= 0 ? 1.0 : normalizedAmount;

    return MealEntity(
      code: IdGenerator.getUniqueID(),
      name: item.label,
      brands: null,
      thumbnailImageUrl: null,
      mainImageUrl: null,
      url: null,
      mealQuantity: item.amount.toString(),
      mealUnit: item.unit,
      servingQuantity: item.unit == 'serving' ? 1 : null,
      servingUnit: item.unit == 'serving' ? 'serving' : null,
      servingSize: item.unit == 'serving' ? '1 serving' : item.unit,
      nutriments: MealNutrimentsEntity(
        energyKcal100: (item.kcal / safeDivisor) * 100,
        carbohydrates100: (item.carbs / safeDivisor) * 100,
        fat100: (item.fat / safeDivisor) * 100,
        proteins100: (item.protein / safeDivisor) * 100,
        sugars100: null,
        saturatedFat100: null,
        fiber100: null,
      ),
      source: MealSourceEntity.custom,
    );
  }

  static double _normalizeAmount(double amount, String unit) {
    switch (unit) {
      case 'oz':
        return UnitCalc.ozToG(amount);
      case 'fl oz':
      case 'fl.oz':
        return UnitCalc.flOzToMl(amount);
      default:
        return amount;
    }
  }
}
