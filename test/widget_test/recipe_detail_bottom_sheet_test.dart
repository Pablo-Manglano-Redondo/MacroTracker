import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/presentation/widgets/recipe_detail_bottom_sheet.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';
import 'package:macrotracker/generated/l10n.dart';

void main() {
  testWidgets('normal recipe detail shows recipe notes without coach copy',
      (tester) async {
    await tester.pumpWidget(_TestApp(
      child: RecipeDetailBottomSheet(
        recipe: _recipe(notes: '#breakfast Prep para semana'),
        category: QuickRecipeCategoryEntity.leanMeal,
        intakeType: IntakeTypeEntity.breakfast,
        servings: 1,
        kcal: 240,
        carbs: 20,
        fat: 8,
        protein: 30,
        rationale: '#breakfast Prep para semana',
        isCoachSuggestion: false,
        onLogPressed: () {},
        onEditPressed: () {},
      ),
    ));

    expect(find.text(S.current.recipeDetailRecipeNotes), findsOneWidget);
    expect(find.text('Prep para semana'), findsOneWidget);
    expect(find.textContaining('#breakfast'), findsNothing);
    expect(find.text(S.current.recipeDetailCoachRecommendation), findsNothing);
    expect(find.text(S.current.recipeDetailCustomizeRecipe), findsNothing);
    expect(find.text(S.current.recipeDetailEditRecipe), findsOneWidget);
  });

  testWidgets('coach recipe detail keeps coach recommendation copy',
      (tester) async {
    await tester.pumpWidget(_TestApp(
      child: RecipeDetailBottomSheet(
        recipe: _recipe(),
        category: QuickRecipeCategoryEntity.postWorkout,
        intakeType: IntakeTypeEntity.snack,
        servings: 1,
        kcal: 240,
        carbs: 20,
        fat: 8,
        protein: 30,
        rationale: 'Recuperacion post-entreno con proteina.',
        isCoachSuggestion: true,
        onLogPressed: () {},
        onEditPressed: () {},
      ),
    ));

    expect(find.text(S.current.recipeDetailCoachRecommendation), findsOneWidget);
    expect(find.text('Recuperacion post-entreno con proteina.'), findsOneWidget);
    expect(find.text(S.current.recipeDetailCustomizeRecipe), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(body: child),
    );
  }
}

RecipeEntity _recipe({String? notes}) {
  final now = DateTime(2026, 1, 1);
  return RecipeEntity(
    id: 'recipe-1',
    name: 'Bowl de pollo',
    notes: notes,
    defaultServings: 1,
    yieldQuantity: null,
    yieldUnit: null,
    saved: true,
    pinned: false,
    timesUsed: 0,
    lastUsedAt: null,
    quickCategory: QuickRecipeCategoryEntity.leanMeal,
    createdAt: now,
    updatedAt: now,
    ingredients: [
      RecipeIngredientEntity(
        id: 'ingredient-1',
        mealSnapshot: _meal(),
        amount: 100,
        unit: 'g',
        position: 0,
      ),
    ],
  );
}

MealEntity _meal() {
  return const MealEntity(
    code: 'meal-1',
    name: 'Pechuga de pollo',
    brands: 'Test',
    thumbnailImageUrl: null,
    mainImageUrl: null,
    url: null,
    mealQuantity: '100',
    mealUnit: 'g',
    servingQuantity: null,
    servingUnit: null,
    servingSize: null,
    nutriments: MealNutrimentsEntity(
      energyKcal100: 240,
      carbohydrates100: 20,
      fat100: 8,
      proteins100: 30,
      sugars100: null,
      saturatedFat100: null,
      fiber100: null,
    ),
    source: MealSourceEntity.custom,
  );
}
