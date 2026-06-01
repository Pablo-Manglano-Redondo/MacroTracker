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
    final savedRecipes =
        matching.where((preset) => preset.recipe.saved).toList();
    final prioritized = savedRecipes.isNotEmpty ? savedRecipes : matching;

    prioritized.sort((a, b) {
      final pinnedCompare =
          (b.recipe.pinned ? 1 : 0) - (a.recipe.pinned ? 1 : 0);
      if (pinnedCompare != 0) {
        return pinnedCompare;
      }

      final savedCompare = (b.recipe.saved ? 1 : 0) - (a.recipe.saved ? 1 : 0);
      if (savedCompare != 0) {
        return savedCompare;
      }

      final aUsed = a.recipe.lastUsedAt;
      final bUsed = b.recipe.lastUsedAt;
      if (aUsed != null && bUsed != null) {
        final usedCompare = bUsed.compareTo(aUsed);
        if (usedCompare != 0) {
          return usedCompare;
        }
      } else if (aUsed != null || bUsed != null) {
        return bUsed == null ? -1 : 1;
      }

      final usageCompare = b.recipe.timesUsed.compareTo(a.recipe.timesUsed);
      if (usageCompare != 0) {
        return usageCompare;
      }

      return b.recipe.updatedAt.compareTo(a.recipe.updatedAt);
    });

    return prioritized.take(limit).toList(growable: false);
  }
}
