import 'package:macrotracker/core/utils/meal_aggregate_factory.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_preset_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_recipe_library_usecase.dart';

class GetQuickRecipePresetsUsecase {
  final GetRecipeLibraryUsecase _getRecipeLibraryUsecase;

  GetQuickRecipePresetsUsecase(this._getRecipeLibraryUsecase);

  Future<List<QuickRecipePresetEntity>> getPresets({
    QuickRecipeCategoryEntity? category,
    int limit = 4,
  }) async {
    final recipes = await _getRecipeLibraryUsecase.getAllRecipes();
    final presets = recipes
        .map((recipe) {
          final aggregate = MealAggregateFactory.fromRecipe(recipe);
          final inferredCategory =
              QuickRecipeCategoryEntityX.inferFromRecipe(recipe);
          return QuickRecipePresetEntity(
            recipe: recipe,
            category: inferredCategory,
            defaultIntakeType: QuickRecipeCategoryEntityX.inferIntakeType(
              recipe,
              inferredCategory,
            ),
            kcalPerServing: aggregate.nutriments.energyPerUnit ?? 0,
            carbsPerServing: aggregate.nutriments.carbohydratesPerUnit ?? 0,
            fatPerServing: aggregate.nutriments.fatPerUnit ?? 0,
            proteinPerServing: aggregate.nutriments.proteinsPerUnit ?? 0,
          );
        })
        .where((preset) => preset.kcalPerServing > 0)
        .toList(growable: false);

    final matching = category == null
        ? presets
        : presets.where((preset) => preset.category == category).toList();
    final favorites =
        matching.where((preset) => preset.recipe.favorite).toList();
    final prioritized = favorites.isNotEmpty ? favorites : matching;

    prioritized.sort((a, b) {
      final favoriteCompare =
          (b.recipe.favorite ? 1 : 0) - (a.recipe.favorite ? 1 : 0);
      if (favoriteCompare != 0) {
        return favoriteCompare;
      }
      return b.recipe.updatedAt.compareTo(a.recipe.updatedAt);
    });

    return prioritized.take(limit).toList(growable: false);
  }
}
