import 'package:macrotracker/features/recipes/data/repository/recipe_repository.dart';

class SetRecipeFavoriteUsecase {
  final RecipeRepository _recipeRepository;

  SetRecipeFavoriteUsecase(this._recipeRepository);

  Future<void> setFavorite(String recipeId, bool isFavorite) async {
    await _recipeRepository.setRecipeFavorite(recipeId, isFavorite);
  }
}
