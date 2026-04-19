import 'package:collection/collection.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/core/utils/meal_portion_nutrition.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:opennutritracker/features/recipes/domain/entity/recipe_entity.dart';

class MealAggregateFactory {
  static MealEntity fromRecipe(RecipeEntity recipe) {
    final totalKcal = _getRecipeTotalKcal(recipe);
    final totalCarbs = _getRecipeTotalCarbs(recipe);
    final totalFat = _getRecipeTotalFat(recipe);
    final totalProtein = _getRecipeTotalProtein(recipe);
    final perServingDivisor =
        recipe.defaultServings <= 0 ? 1.0 : recipe.defaultServings;

    final kcalPerServing = totalKcal / perServingDivisor;
    final carbsPerServing = totalCarbs / perServingDivisor;
    final fatPerServing = totalFat / perServingDivisor;
    final proteinPerServing = totalProtein / perServingDivisor;

    return MealEntity(
      code: recipe.id,
      name: recipe.name,
      brands: null,
      thumbnailImageUrl: recipe.ingredients.firstOrNull?.mealSnapshot.thumbnailImageUrl,
      mainImageUrl: recipe.ingredients.firstOrNull?.mealSnapshot.mainImageUrl,
      url: null,
      mealQuantity: recipe.defaultServings.toString(),
      mealUnit: 'serving',
      servingQuantity: null,
      servingUnit: null,
      servingSize: null,
      nutriments: MealNutrimentsEntity(
        energyKcal100: kcalPerServing * 100,
        carbohydrates100: carbsPerServing * 100,
        fat100: fatPerServing * 100,
        proteins100: proteinPerServing * 100,
        sugars100: null,
        saturatedFat100: null,
        fiber100: null,
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
      servingQuantity: null,
      servingUnit: null,
      servingSize: null,
      nutriments: MealNutrimentsEntity(
        energyKcal100: draft.totalKcal * 100,
        carbohydrates100: draft.totalCarbs * 100,
        fat100: draft.totalFat * 100,
        proteins100: draft.totalProtein * 100,
        sugars100: null,
        saturatedFat100: null,
        fiber100: null,
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
}
