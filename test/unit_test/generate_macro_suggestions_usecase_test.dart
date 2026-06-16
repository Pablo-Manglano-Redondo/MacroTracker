import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/suggestions/domain/usecase/generate_macro_suggestions_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_recipe_library_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_frequent_intake_presets_usecase.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/frequent_intake_preset_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';

void main() {
  late GenerateMacroSuggestionsUsecase usecase;
  late _FakeGetRecipeLibraryUsecase fakeGetRecipeLibraryUsecase;
  late _FakeGetFrequentIntakePresetsUsecase fakeGetFrequentIntakePresetsUsecase;

  // Since energyPerUnit is calculated as energyKcal100 / 100,
  // we scale up our mock nutriments by 100 so they evaluate to the correct values per serving/gram.
  final testMealShake = MealEntity(
    code: 'shake1',
    name: 'Protein Shake',
    brands: '',
    url: '',
    mealQuantity: '100',
    mealUnit: 'ml',
    servingQuantity: 250,
    servingUnit: 'ml',
    servingSize: '1 glass',
    nutriments: const MealNutrimentsEntity(
      energyKcal100: 8000,      // 80 kcal per unit
      carbohydrates100: 400,    // 4g carbs per unit
      fat100: 150,              // 1.5g fat per unit
      proteins100: 1200,        // 12g protein per unit
      sugars100: 200,
      saturatedFat100: 20,
      fiber100: 50,
    ),
    source: MealSourceEntity.custom,
  );

  final testMealPW = MealEntity(
    code: 'pw1',
    name: 'Chicken Rice Bowl',
    brands: '',
    url: '',
    mealQuantity: '100',
    mealUnit: 'g',
    servingQuantity: 300,
    servingUnit: 'g',
    servingSize: '1 bowl',
    nutriments: const MealNutrimentsEntity(
      energyKcal100: 15000,    // 150 kcal per unit
      carbohydrates100: 2000,  // 20g carbs per unit
      fat100: 200,             // 2g fat per unit
      proteins100: 1200,       // 12g protein per unit
      sugars100: 100,
      saturatedFat100: 30,
      fiber100: 200,
    ),
    source: MealSourceEntity.custom,
  );

  final testRecipeShake = RecipeEntity(
    id: 'rec_shake',
    name: 'Whey Protein Shake',
    notes: 'Simple protein shake',
    defaultServings: 1.0,
    yieldQuantity: 1.0,
    yieldUnit: 'serving',
    saved: true,
    pinned: false,
    timesUsed: 5,
    lastUsedAt: DateTime(2026, 6, 15),
    quickCategory: QuickRecipeCategoryEntity.shake,
    createdAt: DateTime(2026, 6, 15),
    updatedAt: DateTime(2026, 6, 15),
    ingredients: [
      RecipeIngredientEntity(
        id: 'ing1',
        mealSnapshot: testMealShake,
        amount: 250.0,
        unit: 'ml',
        position: 0,
      ),
    ],
  );

  final testRecipePostWorkout = RecipeEntity(
    id: 'rec_pw',
    name: 'Huge Post Workout Rice',
    notes: 'Perfect for leg days',
    defaultServings: 1.0,
    yieldQuantity: 1.0,
    yieldUnit: 'serving',
    saved: false,
    pinned: false,
    timesUsed: 10,
    lastUsedAt: DateTime(2026, 6, 15),
    quickCategory: QuickRecipeCategoryEntity.postWorkout,
    createdAt: DateTime(2026, 6, 15),
    updatedAt: DateTime(2026, 6, 15),
    ingredients: [
      RecipeIngredientEntity(
        id: 'ing2',
        mealSnapshot: testMealPW,
        amount: 300.0,
        unit: 'g',
        position: 0,
      ),
    ],
  );

  setUp(() {
    fakeGetRecipeLibraryUsecase = _FakeGetRecipeLibraryUsecase();
    fakeGetFrequentIntakePresetsUsecase = _FakeGetFrequentIntakePresetsUsecase();
    usecase = GenerateMacroSuggestionsUsecase(
      fakeGetRecipeLibraryUsecase,
      fakeGetFrequentIntakePresetsUsecase,
    );
  });

  test('returns empty suggestions if remaining calories and proteins are non-positive', () async {
    final result = await usecase.generate(
      dailyFocus: DailyFocusEntity.lowerBody,
      nutritionPhase: UserWeightGoalEntity.maintainWeight,
      remainingKcal: 0,
      remainingCarbs: 100,
      remainingFat: 50,
      remainingProtein: 0,
    );

    expect(result, isEmpty);
  });

  test('returns empty suggestions if there are no recipes or presets available', () async {
    fakeGetRecipeLibraryUsecase.recipes = [];
    fakeGetFrequentIntakePresetsUsecase.presets = [];

    final result = await usecase.generate(
      dailyFocus: DailyFocusEntity.lowerBody,
      nutritionPhase: UserWeightGoalEntity.maintainWeight,
      remainingKcal: 500,
      remainingCarbs: 100,
      remainingFat: 50,
      remainingProtein: 30,
    );

    expect(result, isEmpty);
  });

  test('skips recipes with zero energy per serving', () async {
    final zeroKcalMeal = MealEntity(
      code: 'zero1',
      name: 'Water',
      url: '',
      mealQuantity: '100',
      mealUnit: 'ml',
      servingQuantity: 250,
      servingUnit: 'ml',
      servingSize: '1 glass',
      nutriments: MealNutrimentsEntity.empty(), // 0 kcal
      source: MealSourceEntity.custom,
    );

    final zeroKcalRecipe = RecipeEntity(
      id: 'rec_zero',
      name: 'Glass of Water',
      notes: null,
      defaultServings: 1.0,
      yieldQuantity: 1.0,
      yieldUnit: 'serving',
      saved: true,
      pinned: false,
      timesUsed: 0,
      lastUsedAt: null,
      quickCategory: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ingredients: [
        RecipeIngredientEntity(
          id: 'ing_zero',
          mealSnapshot: zeroKcalMeal,
          amount: 250,
          unit: 'ml',
          position: 0,
        ),
      ],
    );

    fakeGetRecipeLibraryUsecase.recipes = [zeroKcalRecipe];

    final result = await usecase.generate(
      dailyFocus: DailyFocusEntity.lowerBody,
      nutritionPhase: UserWeightGoalEntity.maintainWeight,
      remainingKcal: 500,
      remainingCarbs: 100,
      remainingFat: 50,
      remainingProtein: 30,
    );

    expect(result, isEmpty);
  });

  test('generates suggestions with scoring and rationales for shake category', () async {
    fakeGetRecipeLibraryUsecase.recipes = [testRecipeShake];

    final result = await usecase.generate(
      dailyFocus: DailyFocusEntity.cardio,
      nutritionPhase: UserWeightGoalEntity.maintainWeight,
      remainingKcal: 300,
      remainingCarbs: 50,
      remainingFat: 20,
      remainingProtein: 20,
      languageCode: 'es',
    );

    expect(result, isNotEmpty);
    final suggestion = result.first;
    expect(suggestion.recipe.id, testRecipeShake.id);
    expect(suggestion.category, QuickRecipeCategoryEntity.shake);
    expect(suggestion.recommendedIntakeType, IntakeTypeEntity.snack);
    expect(suggestion.suggestedServings, greaterThan(0));
    
    // Check rationales are generated in Spanish for shake
    expect(suggestion.rationale, contains('Batido ligero'));
  });

  test('generates suggestions and applies training body focus bonuses and post-workout rationales', () async {
    fakeGetRecipeLibraryUsecase.recipes = [testRecipePostWorkout];

    final result = await usecase.generate(
      dailyFocus: DailyFocusEntity.lowerBody,
      nutritionPhase: UserWeightGoalEntity.gainWeight,
      remainingKcal: 800,
      remainingCarbs: 150,
      remainingFat: 40,
      remainingProtein: 60,
      languageCode: 'en',
    );

    expect(result, isNotEmpty);
    final suggestion = result.first;
    expect(suggestion.recipe.id, testRecipePostWorkout.id);
    expect(suggestion.category, QuickRecipeCategoryEntity.postWorkout);
    expect(suggestion.rationale, contains('Post-workout recovery'));
  });

  test('includes frequent presets as virtual recipes', () async {
    final preset = FrequentIntakePresetEntity(
      key: 'presetKey',
      title: 'Preset Meal',
      meal: testMealShake,
      intakeType: IntakeTypeEntity.breakfast,
      unit: 'ml',
      amount: 250.0,
      uses: 10,
    );

    fakeGetFrequentIntakePresetsUsecase.presets = [preset];

    final result = await usecase.generate(
      dailyFocus: DailyFocusEntity.rest,
      nutritionPhase: UserWeightGoalEntity.maintainWeight,
      remainingKcal: 500,
      remainingCarbs: 100,
      remainingFat: 50,
      remainingProtein: 50,
    );

    expect(result, isNotEmpty);
    expect(result.first.recipe.id, 'frequent|presetKey');
    expect(result.first.recipe.name, 'Preset Meal');
  });

  test('scores suggestions lower body pre workout case', () async {
    final preWorkoutMeal = MealEntity(
      code: 'pre1',
      name: 'Oats and honey',
      url: '',
      mealQuantity: '100',
      mealUnit: 'g',
      servingQuantity: 100,
      servingUnit: 'g',
      servingSize: '1 bowl',
      nutriments: const MealNutrimentsEntity(
        energyKcal100: 30000,
        carbohydrates100: 6000,
        fat100: 200,
        proteins100: 1000,
        sugars100: 1500,
        saturatedFat100: 10,
        fiber100: 500,
      ),
      source: MealSourceEntity.custom,
    );

    final preWorkoutRecipe = RecipeEntity(
      id: 'rec_pre',
      name: 'Oatmeal Pre',
      notes: null,
      defaultServings: 1.0,
      yieldQuantity: 1.0,
      yieldUnit: 'serving',
      saved: false,
      pinned: false,
      timesUsed: 2,
      lastUsedAt: null,
      quickCategory: QuickRecipeCategoryEntity.preWorkout,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ingredients: [
        RecipeIngredientEntity(
          id: 'ing_pre',
          mealSnapshot: preWorkoutMeal,
          amount: 100,
          unit: 'g',
          position: 0,
        ),
      ],
    );

    fakeGetRecipeLibraryUsecase.recipes = [preWorkoutRecipe];

    final result = await usecase.generate(
      dailyFocus: DailyFocusEntity.lowerBody,
      nutritionPhase: UserWeightGoalEntity.maintainWeight,
      remainingKcal: 400,
      remainingCarbs: 100,
      remainingFat: 30,
      remainingProtein: 20,
      languageCode: 'en',
    );

    expect(result, isNotEmpty);
    expect(result.first.rationale, contains('pre-workout fuel'));
  });

  test('rationales for protein close or clean fit calorie margins', () async {
    final leanMeal = MealEntity(
      code: 'lean1',
      name: 'Turkey Breast',
      url: '',
      mealQuantity: '100',
      mealUnit: 'g',
      servingQuantity: 100,
      servingUnit: 'g',
      servingSize: '1 portion',
      nutriments: const MealNutrimentsEntity(
        energyKcal100: 11000,
        carbohydrates100: 100,
        fat100: 100,
        proteins100: 2400,
        sugars100: 0,
        saturatedFat100: 10,
        fiber100: 0,
      ),
      source: MealSourceEntity.custom,
    );

    final leanRecipe = RecipeEntity(
      id: 'rec_lean',
      name: 'Grilled Turkey',
      notes: null,
      defaultServings: 1.0,
      yieldQuantity: 1.0,
      yieldUnit: 'serving',
      saved: false,
      pinned: false,
      timesUsed: 2,
      lastUsedAt: null,
      quickCategory: QuickRecipeCategoryEntity.leanMeal,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ingredients: [
        RecipeIngredientEntity(
          id: 'ing_lean',
          mealSnapshot: leanMeal,
          amount: 100,
          unit: 'g',
          position: 0,
        ),
      ],
    );

    fakeGetRecipeLibraryUsecase.recipes = [leanRecipe];

    // High remaining protein, lean recipe suggestions
    final result1 = await usecase.generate(
      dailyFocus: DailyFocusEntity.rest,
      nutritionPhase: UserWeightGoalEntity.maintainWeight,
      remainingKcal: 300,
      remainingCarbs: 20,
      remainingFat: 20,
      remainingProtein: 50,
      languageCode: 'en',
    );
    expect(result1, isNotEmpty);
    expect(result1.first.rationale, contains('Protein-first close'));

    // Remaining calories close to the recipe's kcal
    final result2 = await usecase.generate(
      dailyFocus: DailyFocusEntity.rest,
      nutritionPhase: UserWeightGoalEntity.maintainWeight,
      remainingKcal: 120,
      remainingCarbs: 10,
      remainingFat: 10,
      remainingProtein: 10,
      languageCode: 'en',
    );
    expect(result2, isNotEmpty);
    expect(result2.first.rationale, contains('Clean fit for the calories'));
  });
}

class _FakeGetRecipeLibraryUsecase implements GetRecipeLibraryUsecase {
  List<RecipeEntity> recipes = [];

  @override
  Future<List<RecipeEntity>> getAllRecipes({bool savedOnly = true}) async {
    return recipes;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetFrequentIntakePresetsUsecase implements GetFrequentIntakePresetsUsecase {
  List<FrequentIntakePresetEntity> presets = [];

  @override
  Future<List<FrequentIntakePresetEntity>> getTopPresets({
    int limit = 12,
    int lookbackDays = 45,
  }) async {
    return presets;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
