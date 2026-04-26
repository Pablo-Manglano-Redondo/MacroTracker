import 'package:macrotracker/features/recipes/data/repository/recipe_repository.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';

class GetRecipeLibraryUsecase {
  final RecipeRepository _recipeRepository;

  GetRecipeLibraryUsecase(this._recipeRepository);

  Future<List<RecipeEntity>> getAllRecipes() async {
    return _recipeRepository.getAllRecipes();
  }
}
