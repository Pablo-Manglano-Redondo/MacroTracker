import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_plan_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_section_summary_usecase.dart';
import 'package:macrotracker/features/professional_plan/data/repository/proposed_recipes_repository.dart';
import 'package:macrotracker/features/professional_plan/data/data_source/proposed_recipes_data_source.dart';
import 'package:macrotracker/features/recipes/data/repository/recipe_repository.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_recipe_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_checkin_template_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_proposed_recipes_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/checkin_template_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/features/professional_plan/data/repository/checkin_repository.dart';
import '../fixture/meal_entity_fixtures.dart';

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
    test('saves and scales recipe with macros distributed among ingredients',
        () async {
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
          {
            'name': 'Mayo',
            'amount': 1.0,
            'unit': 'oz'
          }, // converted amount: 28.3495g
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

  group('GetProfessionalPlanUsecase', () {
    test('getActiveConnection delegates directly', () async {
      final repo = _FakeProfessionalPlanRepository();
      final conn = ProfessionalConnectionEntity(
        relationshipId: 'r-1',
        professionalId: 'p-1',
        clientId: 'c-1',
        professionalName: 'Coach A',
        connectedAt: DateTime(2026, 6, 1),
        consentAcceptedAt: DateTime(2026, 6, 1),
        lastPlanSyncAt: null,
        lastSnapshotSyncAt: null,
        pendingSyncCount: 0,
        sharingMode: 'aggregate',
        messagesEnabled: true,
        connectionStatus: 'active',
        activePlan: null,
      );
      repo.connection = conn;

      final usecase = GetProfessionalPlanUsecase(repo);
      final result =
          await usecase.getActiveConnection(refreshRemotePlan: false);
      expect(result, conn);
    });

    test('getActiveConnection refreshes and returns refreshed connection',
        () async {
      final repo = _FakeProfessionalPlanRepository();
      final conn1 = ProfessionalConnectionEntity(
        relationshipId: 'r-1',
        professionalId: 'p-1',
        clientId: 'c-1',
        professionalName: 'Coach A',
        connectedAt: DateTime(2026, 6, 1),
        consentAcceptedAt: DateTime(2026, 6, 1),
        lastPlanSyncAt: null,
        lastSnapshotSyncAt: null,
        pendingSyncCount: 0,
        sharingMode: 'aggregate',
        messagesEnabled: true,
        connectionStatus: 'active',
        activePlan: null,
      );
      final conn2 = ProfessionalConnectionEntity(
        relationshipId: 'r-1',
        professionalId: 'p-1',
        clientId: 'c-1',
        professionalName: 'Coach A Refreshed',
        connectedAt: DateTime(2026, 6, 1),
        consentAcceptedAt: DateTime(2026, 6, 1),
        lastPlanSyncAt: null,
        lastSnapshotSyncAt: null,
        pendingSyncCount: 0,
        sharingMode: 'aggregate',
        messagesEnabled: true,
        connectionStatus: 'active',
        activePlan: null,
      );
      repo.connection = conn1;
      repo.refreshedConnection = conn2;

      final usecase = GetProfessionalPlanUsecase(repo);
      final result = await usecase.getActiveConnection(refreshRemotePlan: true);
      expect(result, conn2);
    });

    test('getActiveConnection returns cached connection when refresh fails',
        () async {
      final repo = _FakeProfessionalPlanRepository();
      final conn1 = ProfessionalConnectionEntity(
        relationshipId: 'r-1',
        professionalId: 'p-1',
        clientId: 'c-1',
        professionalName: 'Coach A',
        connectedAt: DateTime(2026, 6, 1),
        consentAcceptedAt: DateTime(2026, 6, 1),
        lastPlanSyncAt: null,
        lastSnapshotSyncAt: null,
        pendingSyncCount: 0,
        sharingMode: 'aggregate',
        messagesEnabled: true,
        connectionStatus: 'active',
        activePlan: null,
      );
      repo.connection = conn1;
      repo.shouldThrowOnRefresh = true;

      final usecase = GetProfessionalPlanUsecase(repo);
      final result = await usecase.getActiveConnection(refreshRemotePlan: true);
      expect(result, conn1);
    });
  });

  group('GetProfessionalSectionSummaryUsecase', () {
    test('returns null if there is no active connection', () async {
      final repo = _FakeProfessionalPlanRepository();
      final getTrackedDayUsecase = _FakeGetTrackedDayUsecase();
      final getIntakeUsecase = _FakeGetIntakeUsecase();
      repo.connection = null;

      final usecase = GetProfessionalSectionSummaryUsecase(
        repo,
        getTrackedDayUsecase,
        getIntakeUsecase,
      );

      final result = await usecase.execute();
      expect(result, isNull);
    });

    test('calculates summary adherence slice correctly when days are tracked',
        () async {
      final repo = _FakeProfessionalPlanRepository();
      final getTrackedDayUsecase = _FakeGetTrackedDayUsecase();
      final getIntakeUsecase = _FakeGetIntakeUsecase();

      final plan = NutritionPlanEntity(
        id: 'plan-1',
        professionalId: 'p-1',
        clientId: 'c-1',
        name: 'Plan 1',
        objective: 'bulk',
        notes: null,
        createdAt: null,
        updatedAt: null,
        startsOn: null,
        endsOn: null,
        days: const [
          NutritionPlanDayEntity(
            dateKey: null,
            weekday: 1, // Monday
            kcalGoal: 2000,
            carbsGoal: 250,
            fatGoal: 60,
            proteinGoal: 150,
          )
        ],
        meals: const [],
      );

      final conn = ProfessionalConnectionEntity(
        relationshipId: 'r-1',
        professionalId: 'p-1',
        clientId: 'c-1',
        professionalName: 'Coach A',
        connectedAt: DateTime(2026, 6, 1),
        consentAcceptedAt: DateTime(2026, 6, 1),
        lastPlanSyncAt: null,
        lastSnapshotSyncAt: null,
        pendingSyncCount: 3,
        sharingMode: 'aggregate',
        messagesEnabled: true,
        connectionStatus: 'active',
        activePlan: plan,
      );

      repo.connection = conn;
      repo.refreshedConnection = conn;
      repo.pendingSyncCount = 3;

      final now = DateTime.now();
      // Ensure the test data date matches the current local time day of week
      final todayDate = DateTime(now.year, now.month, now.day);
      final comparisonDate = now.weekday == DateTime.monday
          ? todayDate.add(const Duration(days: 1))
          : todayDate.subtract(const Duration(days: 1));

      repo.dailyNotes[
              '${todayDate.year}-${todayDate.month.toString().padLeft(2, '0')}-${todayDate.day.toString().padLeft(2, '0')}'] =
          'Felt good today';

      final trackedDay1 = TrackedDayEntity(
        day: comparisonDate,
        calorieGoal: 2000,
        caloriesTracked: 1900,
        carbsGoal: 250,
        carbsTracked: 240,
        fatGoal: 60,
        fatTracked: 55,
        proteinGoal: 150,
        proteinTracked: 140,
      );
      final trackedDay2 = TrackedDayEntity(
        day: todayDate,
        calorieGoal: 2000,
        caloriesTracked: 2100,
        carbsGoal: 250,
        carbsTracked: 260,
        fatGoal: 60,
        fatTracked: 65,
        proteinGoal: 150,
        proteinTracked: 160,
      );

      getTrackedDayUsecase.trackedDays = [trackedDay1, trackedDay2];

      // Add intake
      final intake = IntakeEntity(
        id: 'i-1',
        unit: 'g',
        amount: 100,
        type: IntakeTypeEntity.breakfast,
        meal: MealEntityFixtures.mealOne,
        dateTime: comparisonDate,
      );
      final key =
          '${comparisonDate.year}-${comparisonDate.month.toString().padLeft(2, '0')}-${comparisonDate.day.toString().padLeft(2, '0')}-breakfast';
      getIntakeUsecase.intakesByDay[key] = [intake];

      final usecase = GetProfessionalSectionSummaryUsecase(
        repo,
        getTrackedDayUsecase,
        getIntakeUsecase,
      );

      final result = await usecase.execute(refreshRemotePlan: true);
      expect(result, isNotNull);
      expect(result!.connection.pendingSyncCount, 3);
      expect(result.dailyNote, 'Felt good today');

      // Check adherence slice
      expect(result.today.kcalTarget, 2000);
      expect(result.today.kcalActual, 2100);
      expect(result.today.carbsActual, 260);

      expect(result.week.kcalTarget, 4000); // 2 days tracked
      expect(result.week.kcalActual, 4000);
      expect(result.week.mealsLogged, 1);
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
  Future<ProfessionalRecipeData?> fetchRecipeById(
      {required String recipeId}) async {
    return recipes[recipeId];
  }

  @override
  Future<void> updateProposalStatus(
      {required String proposalId, required String status}) async {
    updatedProposalId = proposalId;
    updatedStatus = status;
  }
}

class _FakeCheckinRepository implements CheckinRepository {
  CheckinTemplateEntity? template;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<CheckinTemplateEntity?> fetchDefaultTemplate(
      {required String professionalId}) async {
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

class _FakeProfessionalPlanRepository extends Fake
    implements ProfessionalPlanRepository {
  ProfessionalConnectionEntity? connection;
  ProfessionalConnectionEntity? refreshedConnection;
  bool shouldThrowOnRefresh = false;
  int pendingSyncCount = 0;
  final Map<String, String> dailyNotes = {};

  @override
  Future<ProfessionalConnectionEntity?> getActiveConnection() async =>
      connection;

  @override
  Future<ProfessionalConnectionEntity?> refreshActivePlan() async {
    if (shouldThrowOnRefresh) {
      throw Exception('Failed to refresh');
    }
    return refreshedConnection;
  }

  @override
  Future<int> getPendingSyncCount() async => pendingSyncCount;

  @override
  Future<String?> getDailyNote(DateTime day) async {
    final key =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return dailyNotes[key];
  }

  @override
  Future<ProfessionalCheckinRequestEntity?> getPendingCheckinRequest({
    required ProfessionalConnectionEntity connection,
  }) async => null;

  @override
  Future<int> getPendingRecipeProposalCount({
    required ProfessionalConnectionEntity connection,
  }) async => 0;

  @override
  Future<ProfessionalMessageThreadEntity> getMessages({
    required ProfessionalConnectionEntity connection,
  }) async => const ProfessionalMessageThreadEntity(
        threadId: '',
        isSupported: false,
        messagesEnabled: false,
        messages: [],
      );
}

class _FakeGetTrackedDayUsecase extends Fake implements GetTrackedDayUsecase {
  List<TrackedDayEntity> trackedDays = [];

  @override
  Future<List<TrackedDayEntity>> getTrackedDaysByRange(
      DateTime start, DateTime end) async {
    return trackedDays
        .where((d) =>
            (d.day.isAfter(start) || d.day.isAtSameMomentAs(start)) &&
            (d.day.isBefore(end) || d.day.isAtSameMomentAs(end)))
        .toList();
  }
}

class _FakeGetIntakeUsecase extends Fake implements GetIntakeUsecase {
  final Map<String, List<IntakeEntity>> intakesByDay = {};

  String _key(DateTime day, String mealType) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}-$mealType';
  }

  @override
  Future<List<IntakeEntity>> getBreakfastIntakeByDay(dynamic day) async =>
      intakesByDay[_key(day as DateTime, 'breakfast')] ?? const [];

  @override
  Future<List<IntakeEntity>> getLunchIntakeByDay(dynamic day) async =>
      intakesByDay[_key(day as DateTime, 'lunch')] ?? const [];

  @override
  Future<List<IntakeEntity>> getDinnerIntakeByDay(dynamic day) async =>
      intakesByDay[_key(day as DateTime, 'dinner')] ?? const [];

  @override
  Future<List<IntakeEntity>> getSnackIntakeByDay(dynamic day) async =>
      intakesByDay[_key(day as DateTime, 'snack')] ?? const [];
}
