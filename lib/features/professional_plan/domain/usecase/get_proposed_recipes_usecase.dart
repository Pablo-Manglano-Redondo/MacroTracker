import 'package:macrotracker/features/professional_plan/data/repository/proposed_recipes_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/data/data_source/proposed_recipes_data_source.dart';
import 'package:macrotracker/features/recipes/data/repository/recipe_repository.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';

class GetProposedRecipesUsecase {
  final ProposedRecipesRepository _repository;

  GetProposedRecipesUsecase(this._repository);

  Future<List<ProposedRecipeData>> execute(ProfessionalConnectionEntity connection) {
    return _repository.fetchProposedRecipes(connection);
  }
}

class UpdateProposalStatusUsecase {
  final ProposedRecipesRepository _repository;
  final RecipeRepository _recipeRepository;

  UpdateProposalStatusUsecase(this._repository, this._recipeRepository);

  Future<void> execute({
    required String proposalId,
    required String status,
    ProfessionalRecipeData? recipe,
  }) async {
    await _repository.updateProposalStatus(
      proposalId: proposalId,
      status: status,
    );

    if (status == 'saved' && recipe != null) {
      await _cloneRecipeToLocal(recipe);
    }
  }

  Future<void> _cloneRecipeToLocal(ProfessionalRecipeData recipe) async {
    final ingredientsList = <RecipeIngredientEntity>[];
    final rawIngredients = recipe.ingredients ?? const [];

    double totalConvertedAmount = 0.0;
    for (final rawIng in rawIngredients) {
      if (rawIng is! Map) continue;
      final amount = (rawIng['amount'] as num?)?.toDouble() ?? 0.0;
      final unit = rawIng['unit']?.toString() ?? 'g';
      totalConvertedAmount += UnitCalc.imperialToMetricValue(amount, unit);
    }
    if (totalConvertedAmount <= 0.0) {
      totalConvertedAmount = 1.0;
    }

    final double factor = 100.0 / totalConvertedAmount;
    final kcal100 = (recipe.kcal ?? 0.0) * factor;
    final protein100 = (recipe.protein ?? 0.0) * factor;
    final carbs100 = (recipe.carbs ?? 0.0) * factor;
    final fat100 = (recipe.fat ?? 0.0) * factor;

    for (var i = 0; i < rawIngredients.length; i++) {
      final rawIng = rawIngredients[i];
      if (rawIng is! Map) continue;
      final name = rawIng['name']?.toString() ?? '';
      final amount = (rawIng['amount'] as num?)?.toDouble() ?? 0.0;
      final unit = rawIng['unit']?.toString() ?? 'g';

      final isLiquid = unit == 'ml' || unit == 'fl oz' || unit == 'fl.oz';
      final isServingUnit = unit == 'serving' || unit == 'piece' || unit == 'unit' || unit == 'slice';

      final mealSnapshot = MealEntity(
        code: IdGenerator.getUniqueID(),
        name: name,
        brands: null,
        thumbnailImageUrl: null,
        mainImageUrl: null,
        url: null,
        mealQuantity: null,
        mealUnit: isLiquid ? 'ml' : 'g',
        servingQuantity: isServingUnit ? 1.0 : null,
        servingUnit: isServingUnit ? unit : null,
        servingSize: isServingUnit ? unit : '',
        source: MealSourceEntity.custom,
        nutriments: MealNutrimentsEntity(
          energyKcal100: kcal100,
          carbohydrates100: carbs100,
          fat100: fat100,
          proteins100: protein100,
          sugars100: null,
          saturatedFat100: null,
          fiber100: null,
        ),
      );

      ingredientsList.add(RecipeIngredientEntity(
        id: IdGenerator.getUniqueID(),
        mealSnapshot: mealSnapshot,
        amount: amount,
        unit: unit,
        position: i,
      ));
    }

    final String? description = recipe.description;
    final String? instructions = recipe.instructions;
    String notes = '';
    if (description != null && description.trim().isNotEmpty) {
      notes += '$description\n\n';
    }
    if (instructions != null && instructions.trim().isNotEmpty) {
      notes += 'Instrucciones:\n$instructions';
    }
    notes = notes.trim();

    final recipeEntity = RecipeEntity(
      id: IdGenerator.getUniqueID(),
      name: recipe.title,
      notes: notes.isNotEmpty ? notes : null,
      defaultServings: (recipe.servings ?? 1).toDouble(),
      yieldQuantity: (recipe.servings ?? 1).toDouble(),
      yieldUnit: 'serving',
      saved: true,
      pinned: false,
      timesUsed: 0,
      lastUsedAt: null,
      quickCategory: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ingredients: ingredientsList,
    );

    await _recipeRepository.saveRecipe(recipeEntity);
  }
}