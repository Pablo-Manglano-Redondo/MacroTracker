import 'package:collection/collection.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/core/utils/meal_portion_nutrition.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';

class MealAggregateFactory {
  static MealEntity fromRecipe(RecipeEntity recipe) {
    final totalKcal = _getRecipeTotalKcal(recipe);
    final totalCarbs = _getRecipeTotalCarbs(recipe);
    final totalFat = _getRecipeTotalFat(recipe);
    final totalProtein = _getRecipeTotalProtein(recipe);
    final totalFiber = _getRecipeTotalFiber(recipe);
    final totalSugar = _getRecipeTotalSugar(recipe);
    final totalSaturatedFat = _getRecipeTotalSaturatedFat(recipe);
    final perServingDivisor =
        recipe.defaultServings <= 0 ? 1.0 : recipe.defaultServings;

    final kcalPerServing = totalKcal / perServingDivisor;
    final carbsPerServing = totalCarbs / perServingDivisor;
    final fatPerServing = totalFat / perServingDivisor;
    final proteinPerServing = totalProtein / perServingDivisor;
    final fiberPerServing = totalFiber / perServingDivisor;
    final sugarPerServing = totalSugar / perServingDivisor;
    final saturatedFatPerServing = totalSaturatedFat / perServingDivisor;

    return MealEntity(
      code: recipe.id,
      name: recipe.name,
      brands: null,
      thumbnailImageUrl:
          recipe.ingredients.firstOrNull?.mealSnapshot.thumbnailImageUrl,
      mainImageUrl: recipe.ingredients.firstOrNull?.mealSnapshot.mainImageUrl,
      url: null,
      mealQuantity: recipe.defaultServings.toString(),
      mealUnit: 'serving',
      servingQuantity: 100,
      servingUnit: 'serving',
      servingSize: '1 serving',
      nutriments: MealNutrimentsEntity(
        energyKcal100: kcalPerServing,
        carbohydrates100: carbsPerServing,
        fat100: fatPerServing,
        proteins100: proteinPerServing,
        sugars100: sugarPerServing,
        saturatedFat100: saturatedFatPerServing,
        fiber100: fiberPerServing,
      ),
      source: MealSourceEntity.custom,
    );
  }

  static MealEntity fromInterpretationDraft(InterpretationDraftEntity draft) {
    return MealEntity(
      code: IdGenerator.getUniqueID(),
      name: draft.title,
      brands: null,
      thumbnailImageUrl: null,
      mainImageUrl: null,
      url: null,
      mealQuantity: '1',
      mealUnit: 'serving',
      servingQuantity: 100,
      servingUnit: 'serving',
      servingSize: '1 serving',
      nutriments: MealNutrimentsEntity(
        energyKcal100: draft.totalKcal,
        carbohydrates100: draft.totalCarbs,
        fat100: draft.totalFat,
        proteins100: draft.totalProtein,
        sugars100: draft.totalSugar,
        saturatedFat100: null,
        fiber100: draft.totalFiber,
        sodium100: draft.totalSodium,
        potassium100: draft.totalPotassium,
        calcium100: draft.totalCalcium,
        iron100: draft.totalIron,
        vitaminC100: draft.totalVitaminC,
        vitaminD100: draft.totalVitaminD,
        novaGroup: draft.items.map((e) => e.novaGroup).whereType<int>().maxOrNull,
      ),
      source: MealSourceEntity.custom,
    );
  }

  static double _getRecipeTotalKcal(RecipeEntity recipe) {
    return recipe.ingredients.fold(
      0,
      (sum, ingredient) =>
          sum +
          MealPortionCalculator.calculate(
            ingredient.mealSnapshot,
            ingredient.amount,
            ingredient.unit,
          ).kcal,
    );
  }

  static double _getRecipeTotalCarbs(RecipeEntity recipe) {
    return recipe.ingredients.fold(
      0,
      (sum, ingredient) =>
          sum +
          MealPortionCalculator.calculate(
            ingredient.mealSnapshot,
            ingredient.amount,
            ingredient.unit,
          ).carbs,
    );
  }

  static double _getRecipeTotalFat(RecipeEntity recipe) {
    return recipe.ingredients.fold(
      0,
      (sum, ingredient) =>
          sum +
          MealPortionCalculator.calculate(
            ingredient.mealSnapshot,
            ingredient.amount,
            ingredient.unit,
          ).fat,
    );
  }

  static double _getRecipeTotalProtein(RecipeEntity recipe) {
    return recipe.ingredients.fold(
      0,
      (sum, ingredient) =>
          sum +
          MealPortionCalculator.calculate(
            ingredient.mealSnapshot,
            ingredient.amount,
            ingredient.unit,
          ).protein,
    );
  }

  static double _getRecipeTotalFiber(RecipeEntity recipe) {
    return recipe.ingredients.fold(
      0,
      (sum, ingredient) =>
          sum +
          (MealPortionCalculator.calculate(
                ingredient.mealSnapshot,
                ingredient.amount,
                ingredient.unit,
              ).fiber ??
              0),
    );
  }

  static double _getRecipeTotalSugar(RecipeEntity recipe) {
    return recipe.ingredients.fold(
      0,
      (sum, ingredient) =>
          sum +
          (MealPortionCalculator.calculate(
                ingredient.mealSnapshot,
                ingredient.amount,
                ingredient.unit,
              ).sugar ??
              0),
    );
  }

  static double _getRecipeTotalSaturatedFat(RecipeEntity recipe) {
    return recipe.ingredients.fold(
      0,
      (sum, ingredient) =>
          sum +
          (MealPortionCalculator.calculate(
                ingredient.mealSnapshot,
                ingredient.amount,
                ingredient.unit,
              ).saturatedFat ??
              0),
    );
  }
}
