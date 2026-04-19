import 'package:opennutritracker/features/recipes/data/repository/recipe_repository.dart';
import 'package:opennutritracker/features/recipes/domain/entity/recipe_entity.dart';

class SaveRecipeUsecase {
  final RecipeRepository _recipeRepository;

  SaveRecipeUsecase(this._recipeRepository);

  Future<void> saveRecipe(RecipeEntity recipeEntity) async {
    await _recipeRepository.saveRecipe(recipeEntity);
  }
}
