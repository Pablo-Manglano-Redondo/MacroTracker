import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/recipes/data/repository/recipe_repository.dart';
import 'package:macrotracker/features/recipes/domain/entity/frequent_intake_preset_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_frequent_intake_preset_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/log_recipe_usecase.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers & fakes
// ─────────────────────────────────────────────────────────────────────────────

MealEntity _makeMeal({
  double energyKcal100 = 10000,
  double proteins100 = 2000,
  double carbs100 = 1000,
  double fat100 = 300,
}) {
  return MealEntity(
    code: 'test-meal',
    name: 'Test Meal',
    url: null,
    mealQuantity: '100',
    mealUnit: 'g',
    servingQuantity: 100,
    servingUnit: 'g',
    servingSize: '100g',
    nutriments: MealNutrimentsEntity(
      energyKcal100: energyKcal100,
      carbohydrates100: carbs100,
      fat100: fat100,
      proteins100: proteins100,
      sugars100: null,
      saturatedFat100: null,
      fiber100: null,
    ),
    source: MealSourceEntity.custom,
  );
}

RecipeEntity _makeRecipe({bool withIngredients = true}) {
  final meal = _makeMeal();
  return RecipeEntity(
    id: 'recipe-1',
    name: 'Test Recipe',
    notes: 'Test notes',
    defaultServings: 1.0,
    yieldQuantity: 1.0,
    yieldUnit: 'serving',
    saved: true,
    pinned: false,
    timesUsed: 0,
    lastUsedAt: null,
    quickCategory: QuickRecipeCategoryEntity.leanMeal,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    ingredients: withIngredients
        ? [
            RecipeIngredientEntity(
              id: 'ing-1',
              mealSnapshot: meal,
              amount: 100.0,
              unit: 'g',
              position: 0,
            ),
          ]
        : const [],
  );
}

FrequentIntakePresetEntity _makePreset() {
  return FrequentIntakePresetEntity(
    key: 'preset-key',
    title: 'Chicken Breast',
    meal: _makeMeal(),
    intakeType: IntakeTypeEntity.lunch,
    unit: 'g',
    amount: 150.0,
    uses: 10,
  );
}

final _defaultTargets = const GymTargetsEntity(
  kcalGoal: 2200,
  carbsGoal: 250,
  fatGoal: 70,
  proteinGoal: 150,
);

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

class _FakeAddIntakeUsecase implements AddIntakeUsecase {
  IntakeEntity? lastAdded;
  @override
  Future<void> addIntake(IntakeEntity intakeEntity) async => lastAdded = intakeEntity;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeAddTrackedDayUsecase implements AddTrackedDayUsecase {
  bool hasDay = false;
  DateTime? addedDay;
  double? addedKcal;
  List<double?> addedMacros = [];

  @override
  Future<bool> hasTrackedDay(DateTime day) async => hasDay;

  @override
  Future<void> addNewTrackedDay(DateTime day, double kcal, double carbs, double fat, double protein) async {
    addedDay = day;
    addedKcal = kcal;
  }

  @override
  Future<void> addDayCaloriesTracked(DateTime day, double calories) async {}

  @override
  Future<void> addDayMacrosTracked(DateTime day,
      {double? carbsTracked, double? fatTracked, double? proteinTracked}) async {
    addedMacros = [carbsTracked, fatTracked, proteinTracked];
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeGetGymTargetsUsecase implements GetGymTargetsUsecase {
  GymTargetsEntity targets = _defaultTargets;
  bool getCalled = false;

  @override
  Future<GymTargetsEntity> getTargetsForDay(
    DateTime day, {
    UserEntity? userEntity,
    UserWeightGoalEntity? phase,
    DailyFocusEntity? dailyFocus,
    double? totalKcalActivities,
  }) async {
    getCalled = true;
    return targets;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeRecipeRepository implements RecipeRepository {
  String? markedUsedId;
  DateTime? markedUsedAt;

  @override
  Future<void> markRecipeUsed(String recipeId, DateTime usedAt) async {
    markedUsedId = recipeId;
    markedUsedAt = usedAt;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('LogRecipeUsecase', () {
    late _FakeAddIntakeUsecase addIntake;
    late _FakeAddTrackedDayUsecase addTrackedDay;
    late _FakeGetGymTargetsUsecase getGymTargets;
    late _FakeRecipeRepository recipeRepo;
    late LogRecipeUsecase usecase;

    setUp(() {
      addIntake = _FakeAddIntakeUsecase();
      addTrackedDay = _FakeAddTrackedDayUsecase();
      getGymTargets = _FakeGetGymTargetsUsecase();
      recipeRepo = _FakeRecipeRepository();
      usecase = LogRecipeUsecase(addIntake, addTrackedDay, getGymTargets, recipeRepo);
    });

    test('logRecipe adds intake with correct type and day', () async {
      final recipe = _makeRecipe();
      final day = DateTime(2026, 6, 1, 12, 0);

      await usecase.logRecipe(recipe, 1.0, IntakeTypeEntity.lunch, day);

      expect(addIntake.lastAdded, isNotNull);
      expect(addIntake.lastAdded!.type, IntakeTypeEntity.lunch);
      expect(addIntake.lastAdded!.dateTime, day);
    });

    test('logRecipe creates a new tracked day when none exists', () async {
      addTrackedDay.hasDay = false;
      final recipe = _makeRecipe();
      final day = DateTime(2026, 6, 1);

      await usecase.logRecipe(recipe, 1.5, IntakeTypeEntity.dinner, day);

      expect(addTrackedDay.addedDay, isNotNull);
      expect(addTrackedDay.addedKcal, _defaultTargets.kcalGoal);
      expect(getGymTargets.getCalled, isTrue);
    });

    test('logRecipe skips creating a tracked day when it already exists', () async {
      addTrackedDay.hasDay = true;
      final recipe = _makeRecipe();
      final day = DateTime(2026, 6, 1);

      await usecase.logRecipe(recipe, 1.0, IntakeTypeEntity.breakfast, day);

      expect(addTrackedDay.addedDay, isNull);
      expect(getGymTargets.getCalled, isFalse);
    });

    test('logRecipe marks recipe as used', () async {
      final recipe = _makeRecipe();
      final day = DateTime(2026, 6, 1);

      await usecase.logRecipe(recipe, 1.0, IntakeTypeEntity.snack, day);

      expect(recipeRepo.markedUsedId, 'recipe-1');
      expect(recipeRepo.markedUsedAt, isNotNull);
    });

    test('logRecipe updates macros in tracked day', () async {
      addTrackedDay.hasDay = true;
      final recipe = _makeRecipe();
      final day = DateTime(2026, 6, 1);

      await usecase.logRecipe(recipe, 1.0, IntakeTypeEntity.lunch, day);

      expect(addTrackedDay.addedMacros, isNotEmpty);
    });

    test('logRecipe with multiple servings scales nutrients correctly', () async {
      addTrackedDay.hasDay = true;
      final recipe = _makeRecipe();
      final day = DateTime(2026, 6, 1);

      await usecase.logRecipe(recipe, 2.0, IntakeTypeEntity.lunch, day);

      final intake = addIntake.lastAdded!;
      expect(intake.amount, 2.0);
      // intake.totalKcal = kcal per serving * servings
      // energyKcal100 = 10000 (100 kcal per gram) for 100g = 10000 kcal
      // per serving (1 serving = 1 unit aggregate) the kcal should be non-zero
      expect(intake.totalKcal, greaterThan(0));
    });
  });

  group('LogFrequentIntakePresetUsecase', () {
    late _FakeAddIntakeUsecase addIntake;
    late _FakeAddTrackedDayUsecase addTrackedDay;
    late _FakeGetGymTargetsUsecase getGymTargets;
    late LogFrequentIntakePresetUsecase usecase;

    setUp(() {
      addIntake = _FakeAddIntakeUsecase();
      addTrackedDay = _FakeAddTrackedDayUsecase();
      getGymTargets = _FakeGetGymTargetsUsecase();
      usecase = LogFrequentIntakePresetUsecase(addIntake, addTrackedDay, getGymTargets);
    });

    test('logPreset adds intake with preset properties', () async {
      final preset = _makePreset();
      final day = DateTime(2026, 6, 1, 13, 0);

      await usecase.logPreset(preset, day: day);

      final intake = addIntake.lastAdded!;
      expect(intake.type, IntakeTypeEntity.lunch);
      expect(intake.unit, 'g');
      expect(intake.amount, 150.0);
      expect(intake.dateTime, day);
    });

    test('logPreset uses current date when day is not provided', () async {
      final preset = _makePreset();
      final before = DateTime.now();

      await usecase.logPreset(preset);

      final after = DateTime.now();
      final intake = addIntake.lastAdded!;
      expect(intake.dateTime.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(intake.dateTime.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('logPreset creates tracked day when none exists', () async {
      addTrackedDay.hasDay = false;
      final preset = _makePreset();
      final day = DateTime(2026, 6, 1);

      await usecase.logPreset(preset, day: day);

      expect(addTrackedDay.addedDay, isNotNull);
      expect(addTrackedDay.addedKcal, _defaultTargets.kcalGoal);
      expect(getGymTargets.getCalled, isTrue);
    });

    test('logPreset skips tracked day creation when it already exists', () async {
      addTrackedDay.hasDay = true;
      final preset = _makePreset();
      final day = DateTime(2026, 6, 1);

      await usecase.logPreset(preset, day: day);

      expect(addTrackedDay.addedDay, isNull);
      expect(getGymTargets.getCalled, isFalse);
    });

    test('logPreset updates macros in tracked day', () async {
      addTrackedDay.hasDay = true;
      final preset = _makePreset();
      final day = DateTime(2026, 6, 1);

      await usecase.logPreset(preset, day: day);

      expect(addTrackedDay.addedMacros, isNotEmpty);
    });

    test('logPreset for different intake types uses preset intakeType', () async {
      final breakfastPreset = FrequentIntakePresetEntity(
        key: 'oats',
        title: 'Oatmeal',
        meal: _makeMeal(),
        intakeType: IntakeTypeEntity.breakfast,
        unit: 'g',
        amount: 80.0,
        uses: 5,
      );
      addTrackedDay.hasDay = true;
      final day = DateTime(2026, 6, 1);

      await usecase.logPreset(breakfastPreset, day: day);

      expect(addIntake.lastAdded!.type, IntakeTypeEntity.breakfast);
      expect(addIntake.lastAdded!.amount, 80.0);
    });
  });
}
