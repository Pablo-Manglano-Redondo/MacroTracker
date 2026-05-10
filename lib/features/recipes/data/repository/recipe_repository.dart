import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/recipes/data/data_source/recipe_data_source.dart';
import 'package:macrotracker/features/recipes/data/dbo/recipe_dbo.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';

class RecipeRepository {
  final RecipeDataSource _recipeDataSource;

  RecipeRepository(this._recipeDataSource);

  Future<void> saveRecipe(RecipeEntity recipeEntity) async {
    await _recipeDataSource.saveRecipe(RecipeDBO.fromEntity(recipeEntity));
  }

  Future<RecipeEntity?> getRecipeById(String recipeId) async {
    final result = await _recipeDataSource.getRecipeById(recipeId);
    return result == null ? null : _mapRecipe(result);
  }

  Future<List<RecipeEntity>> getAllRecipes({bool savedOnly = true}) async {
    final recipes = await _recipeDataSource.getAllRecipes();
    final mapped = recipes
        .map(_mapRecipe)
        .where((recipe) => !savedOnly || recipe.saved)
        .toList(growable: false);
    mapped.sort(_compareRecipes);
    return mapped;
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _recipeDataSource.deleteRecipe(recipeId);
  }

  Future<void> setRecipeSaved(String recipeId, bool isSaved) async {
    await _recipeDataSource.setRecipeSaved(recipeId, isSaved);
  }

  Future<void> setRecipePinned(String recipeId, bool isPinned) async {
    await _recipeDataSource.setRecipePinned(recipeId, isPinned);
  }

  Future<void> markRecipeUsed(String recipeId, DateTime usedAt) async {
    await _recipeDataSource.markRecipeUsed(recipeId, usedAt);
  }

  Future<List<RecipeDBO>> getAllRecipesDBO() async {
    return _recipeDataSource.getAllRecipes();
  }

  RecipeEntity _mapRecipe(RecipeDBO recipeDBO) {
    return RecipeEntity(
      id: recipeDBO.id,
      name: recipeDBO.name,
      notes: recipeDBO.notes,
      defaultServings: recipeDBO.defaultServings,
      yieldQuantity: recipeDBO.yieldQuantity,
      yieldUnit: recipeDBO.yieldUnit,
      saved: recipeDBO.saved,
      pinned: recipeDBO.pinned,
      timesUsed: recipeDBO.timesUsed,
      lastUsedAt: recipeDBO.lastUsedAt,
      quickCategory: recipeDBO.quickCategoryEntity,
      createdAt: recipeDBO.createdAt,
      updatedAt: recipeDBO.updatedAt,
      ingredients: recipeDBO.ingredients
          .map((ingredient) => RecipeIngredientEntity(
                id: ingredient.id,
                mealSnapshot:
                    MealEntity.fromMealDBO(ingredient.mealSnapshot),
                amount: ingredient.amount,
                unit: ingredient.unit,
                position: ingredient.position,
              ))
          .toList(),
    );
  }

  int _compareRecipes(RecipeEntity a, RecipeEntity b) {
    final pinnedCompare = (b.pinned ? 1 : 0) - (a.pinned ? 1 : 0);
    if (pinnedCompare != 0) {
      return pinnedCompare;
    }

    final aUsed = a.lastUsedAt;
    final bUsed = b.lastUsedAt;
    if (aUsed != null && bUsed != null) {
      final lastUsedCompare = bUsed.compareTo(aUsed);
      if (lastUsedCompare != 0) {
        return lastUsedCompare;
      }
    } else if (aUsed != null || bUsed != null) {
      return bUsed == null ? -1 : 1;
    }

    final usageCompare = b.timesUsed.compareTo(a.timesUsed);
    if (usageCompare != 0) {
      return usageCompare;
    }

    return b.updatedAt.compareTo(a.updatedAt);
  }
}
