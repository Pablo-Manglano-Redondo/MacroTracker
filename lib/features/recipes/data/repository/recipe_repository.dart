import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/recipes/data/data_source/recipe_data_source.dart';
import 'package:opennutritracker/features/recipes/data/dbo/recipe_dbo.dart';
import 'package:opennutritracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:opennutritracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';

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

  Future<List<RecipeEntity>> getAllRecipes() async {
    final recipes = await _recipeDataSource.getAllRecipes();
    return recipes.map(_mapRecipe).toList();
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _recipeDataSource.deleteRecipe(recipeId);
  }

  Future<void> setRecipeFavorite(String recipeId, bool isFavorite) async {
    await _recipeDataSource.setRecipeFavorite(recipeId, isFavorite);
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
      favorite: recipeDBO.favorite,
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
}
