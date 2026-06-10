import 'package:macrotracker/features/professional_plan/data/data_source/proposed_recipes_data_source.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

class ProposedRecipesRepository {
  final ProposedRecipesDataSource _dataSource;

  ProposedRecipesRepository(this._dataSource);

  Future<List<ProposedRecipeData>> fetchProposedRecipes(
      ProfessionalConnectionEntity connection) {
    return _dataSource.fetchProposedRecipes(
      professionalClientId: connection.relationshipId,
      clientId: connection.clientId,
    );
  }

  Future<void> updateProposalStatus({
    required String proposalId,
    required String status,
  }) {
    return _dataSource.updateProposalStatus(
      proposalId: proposalId,
      status: status,
    );
  }

  Future<ProfessionalRecipeData?> fetchRecipeById({
    required String recipeId,
  }) {
    return _dataSource.fetchRecipeById(recipeId: recipeId);
  }
}