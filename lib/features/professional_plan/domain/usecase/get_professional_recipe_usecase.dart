import 'package:macrotracker/features/professional_plan/data/repository/proposed_recipes_repository.dart';
import 'package:macrotracker/features/professional_plan/data/data_source/proposed_recipes_data_source.dart';

class GetProfessionalRecipeUsecase {
  final ProposedRecipesRepository _repository;

  GetProfessionalRecipeUsecase(this._repository);

  Future<ProfessionalRecipeData?> execute({required String recipeId}) {
    return _repository.fetchRecipeById(recipeId: recipeId);
  }
}
