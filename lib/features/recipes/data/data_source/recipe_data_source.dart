import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/features/recipes/data/dbo/recipe_dbo.dart';

class RecipeDataSource {
  final _log = Logger('RecipeDataSource');
  final Box<RecipeDBO> _recipeBox;

  RecipeDataSource(this._recipeBox);

  Future<void> saveRecipe(RecipeDBO recipeDBO) async {
    _log.fine('Saving recipe ${recipeDBO.id}');
    await _recipeBox.put(recipeDBO.id, recipeDBO);
  }

  Future<RecipeDBO?> getRecipeById(String recipeId) async {
    return _recipeBox.get(recipeId);
  }

  Future<List<RecipeDBO>> getAllRecipes() async {
    final recipes = _recipeBox.values.toList();
    recipes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return recipes;
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _recipeBox.delete(recipeId);
  }

  Future<void> setRecipeFavorite(String recipeId, bool isFavorite) async {
    final recipe = _recipeBox.get(recipeId);
    if (recipe == null) {
      return;
    }

    recipe.favorite = isFavorite;
    recipe.updatedAt = DateTime.now();
    await recipe.save();
  }
}
