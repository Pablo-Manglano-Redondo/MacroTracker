import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/professional_plan/data/repository/proposed_recipes_repository.dart';
import 'package:macrotracker/features/professional_plan/data/data_source/proposed_recipes_data_source.dart';
import 'package:macrotracker/features/recipes/data/repository/recipe_repository.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_recipe_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_checkin_template_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_proposed_recipes_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/checkin_template_entity.dart';
import 'package:macrotracker/features/professional_plan/data/repository/checkin_repository.dart';

void main() {
  group('GetProfessionalRecipeUsecase', () {
    test('fetches recipe by id', () async {
      final repo = _FakeProposedRecipesRepository();
      final recipeData = ProfessionalRecipeData(
        id: 'recipe-123',
        title: 'Protein Pancake',
        kcal: 400,
        protein: 30,
        carbs: 50,
        fat: 10,
      );
      repo.recipes['recipe-123'] = recipeData;

      final usecase = GetProfessionalRecipeUsecase(repo);
      final result = await usecase.execute(recipeId: 'recipe-123');

      expect(result, isNotNull);
      expect(result!.title, 'Protein Pancake');
      expect(result.kcal, 400);
    });
  });

  group('GetCheckinTemplateUsecase', () {
    test('fetches default template', () async {
      final repo = _FakeCheckinRepository();
      repo.template = const CheckinTemplateEntity(
        id: 'tpl-1',
        title: 'Weekly Checkin',
        questions: [],
      );

      final usecase = GetCheckinTemplateUsecase(repo);
      final result = await usecase.execute(professionalId: 'prof-1');

      expect(result, isNotNull);
      expect(result!.title, 'Weekly Checkin');
    });
  });

  group('UpdateProposalStatusUsecase', () {
    test('saves and scales recipe with macros distributed among ingredients', () async {
      final proposedRepo = _FakeProposedRecipesRepository();
      final recipeRepo = _FakeRecipeRepository();
      final usecase = UpdateProposalStatusUsecase(proposedRepo, recipeRepo);

      final recipeData = ProfessionalRecipeData(
        id: 'recipe-456',
        title: 'Tuna Salad',
        kcal: 300,
        protein: 40,
        carbs: 10,
        fat: 10,
        servings: 2,
        description: 'Easy tuna salad',
        instructions: 'Mix everything',
        ingredients: const [
          {'name': 'Tuna', 'amount': 150.0, 'unit': 'g'},
          {'name': 'Mayo', 'amount': 1.0, 'unit': 'oz'}, // converted amount: 28.3495g
        ],
      );

      await usecase.execute(
        proposalId: 'proposal-1',
        status: 'saved',
        recipe: recipeData,
      );

      expect(proposedRepo.updatedProposalId, 'proposal-1');
      expect(proposedRepo.updatedStatus, 'saved');

      expect(recipeRepo.savedRecipe, isNotNull);
      final saved = recipeRepo.savedRecipe!;
      expect(saved.name, 'Tuna Salad');
      expect(saved.defaultServings, 2.0);
      expect(saved.ingredients.length, 2);

      // Check macro distribution math
      // Total converted amount: 150.0 + 28.3495 = 178.3495g
      // factor: 100 / 178.3495 = 0.56070
      // kcal100: 300 * 0.56070 = 168.22
      final ing1 = saved.ingredients[0];
      expect(ing1.mealSnapshot.name, 'Tuna');
      expect(ing1.amount, 150.0);
      expect(ing1.unit, 'g');

      final kcal100 = ing1.mealSnapshot.nutriments.energyKcal100;
      expect(kcal100, closeTo(300 * 100 / (150.0 + 28.3495), 0.01));
    });
  });
}

class _FakeProposedRecipesRepository implements ProposedRecipesRepository {
  final Map<String, ProfessionalRecipeData> recipes = {};
  String? updatedProposalId;
  String? updatedStatus;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<ProfessionalRecipeData?> fetchRecipeById({required String recipeId}) async {
    return recipes[recipeId];
  }

  @override
  Future<void> updateProposalStatus({required String proposalId, required String status}) async {
    updatedProposalId = proposalId;
    updatedStatus = status;
  }
}

class _FakeCheckinRepository implements CheckinRepository {
  CheckinTemplateEntity? template;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<CheckinTemplateEntity?> fetchDefaultTemplate({required String professionalId}) async {
    return template;
  }
}

class _FakeRecipeRepository implements RecipeRepository {
  RecipeEntity? savedRecipe;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> saveRecipe(RecipeEntity recipeEntity) async {
    savedRecipe = recipeEntity;
  }
}
