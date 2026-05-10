import 'package:macrotracker/features/recipes/data/repository/recipe_repository.dart';

class SetRecipeSavedUsecase {
  final RecipeRepository _recipeRepository;

  SetRecipeSavedUsecase(this._recipeRepository);

  Future<void> setSaved(String recipeId, bool isSaved) async {
    await _recipeRepository.setRecipeSaved(recipeId, isSaved);
  }
}
