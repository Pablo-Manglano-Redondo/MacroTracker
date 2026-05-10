import 'package:macrotracker/features/recipes/data/repository/recipe_repository.dart';

class SetRecipePinnedUsecase {
  final RecipeRepository _recipeRepository;

  SetRecipePinnedUsecase(this._recipeRepository);

  Future<void> setPinned(String recipeId, bool isPinned) async {
    await _recipeRepository.setRecipePinned(recipeId, isPinned);
  }
}
