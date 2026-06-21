import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/add_meal/domain/usecase/search_products_usecase.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/save_recipe_usecase.dart';
import 'package:macrotracker/features/recipes/presentation/recipe_editor_screen.dart';
import 'package:macrotracker/generated/l10n.dart';

void main() {
  late Directory tempDir;
  late _FakeSearchProductsUseCase fakeSearchProductsUseCase;
  late _FakeSaveRecipeUsecase fakeSaveRecipeUsecase;
  FlutterExceptionHandler? originalOnError;

  setUp(() async {
    originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.toString();
      if (message.contains('overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };
    await locator.reset();
    tempDir = await Directory.systemTemp.createTemp('macrotracker_recipe_test_');
    Hive.init(tempDir.path);

    const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async {
      return tempDir.path;
    });

    fakeSearchProductsUseCase = _FakeSearchProductsUseCase();
    fakeSaveRecipeUsecase = _FakeSaveRecipeUsecase();

    locator.registerSingleton<SearchProductsUseCase>(fakeSearchProductsUseCase);
    locator.registerSingleton<SaveRecipeUsecase>(fakeSaveRecipeUsecase);
  });

  tearDown(() async {
    FlutterError.onError = originalOnError;
    await locator.reset();
    if (await tempDir.exists()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  MealEntity buildDummyMeal({
    required String code,
    required String name,
  }) {
    return MealEntity(
      code: code,
      name: name,
      brands: 'Mock Brand',
      url: 'https://mockurl.com',
      mealQuantity: '100',
      mealUnit: 'g',
      servingQuantity: null,
      servingUnit: null,
      servingSize: '100g',
      nutriments: const MealNutrimentsEntity(
        energyKcal100: 150,
        carbohydrates100: 10,
        fat100: 5,
        proteins100: 12,
        sugars100: 2,
        saturatedFat100: 1,
        fiber100: 3,
      ),
      source: MealSourceEntity.custom,
    );
  }

  RecipeEntity buildDummyRecipe({
    required String id,
    required String name,
    List<RecipeIngredientEntity> ingredients = const [],
  }) {
    return RecipeEntity(
      id: id,
      name: name,
      notes: 'Some notes',
      defaultServings: 2,
      yieldQuantity: null,
      yieldUnit: null,
      saved: true,
      pinned: false,
      timesUsed: 0,
      lastUsedAt: null,
      quickCategory: QuickRecipeCategoryEntity.leanMeal,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ingredients: ingredients,
    );
  }

  Widget createTestWidget(RecipeEntity recipe) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: RouteSettings(
            arguments: RecipeEditorScreenArguments(recipe),
          ),
          builder: (context) => const RecipeEditorScreen(),
        );
      },
    );
  }

  testWidgets('renders all initial recipe fields and controls correctly', (tester) async {
    final meal = buildDummyMeal(code: 'm1', name: 'Huevos');
    final recipe = buildDummyRecipe(
      id: 'rec-1',
      name: 'Tortilla Francesa',
      ingredients: [
        RecipeIngredientEntity(
          id: 'ing-1',
          mealSnapshot: meal,
          amount: 150,
          unit: 'g',
          position: 0,
        )
      ],
    );

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(createTestWidget(recipe));
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text(S.current.recipeDetailEditRecipe), findsOneWidget);

    // Verify fields
    expect(find.widgetWithText(TextField, S.current.aiRecipeNameLabel), findsOneWidget);
    expect(find.text('Tortilla Francesa'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // Servings text
    expect(find.text('Some notes'), findsOneWidget);

    // Verify ingredient
    expect(find.text('Huevos'), findsOneWidget);
    expect(find.text('150'), findsOneWidget); // Amount field text
  });

  testWidgets('modifies recipe basic details and saves successfully', (tester) async {
    final meal = buildDummyMeal(code: 'm1', name: 'Huevos');
    final recipe = buildDummyRecipe(
      id: 'rec-1',
      name: 'Tortilla Francesa',
      ingredients: [
        RecipeIngredientEntity(
          id: 'ing-1',
          mealSnapshot: meal,
          amount: 150,
          unit: 'g',
          position: 0,
        )
      ],
    );

    bool popped = false;
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(ctx).push(
                  MaterialPageRoute(
                    settings: RouteSettings(
                      arguments: RecipeEditorScreenArguments(recipe),
                    ),
                    builder: (c) => const RecipeEditorScreen(),
                  ),
                );
                if (result == true) {
                  popped = true;
                }
              },
              child: const Text('Go'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    // Change Name
    final nameField = find.widgetWithText(TextField, S.current.aiRecipeNameLabel);
    await tester.enterText(nameField, 'Super Tortilla');

    // Change Servings
    final servingsField = find.widgetWithText(TextField, S.current.servingsLabel);
    await tester.enterText(servingsField, '4');

    // Change Category
    final categoryDropdown = find.byType(DropdownButtonFormField<RecipeSaveCategoryEntity>).first;
    await tester.tap(categoryDropdown);
    await tester.pumpAndSettle();
    // Choose Snack category:
    await tester.tap(find.text(S.current.snackLabel).last);
    await tester.pumpAndSettle();

    // Change Notes
    final notesField = find.widgetWithText(TextField, S.current.recipeDetailRecipeNotes);
    await tester.enterText(notesField, 'Muy rica');

    // Tap Save
    await tester.tap(find.text(S.current.recipeEditorSaveRecipe));
    await tester.pumpAndSettle();

    // Verify use case was invoked and popped with true
    expect(fakeSaveRecipeUsecase.savedRecipe, isNotNull);
    expect(fakeSaveRecipeUsecase.savedRecipe!.name, equals('Super Tortilla'));
    expect(fakeSaveRecipeUsecase.savedRecipe!.defaultServings, equals(4));
    expect(fakeSaveRecipeUsecase.savedRecipe!.notes, contains('Muy rica'));
    expect(fakeSaveRecipeUsecase.savedRecipe!.quickCategory, equals(QuickRecipeCategoryEntity.leanMeal));
    expect(popped, isTrue);
  });

  testWidgets('displays validation SnackBar when fields are invalid', (tester) async {
    final meal = buildDummyMeal(code: 'm1', name: 'Huevos');
    final recipe = buildDummyRecipe(
      id: 'rec-1',
      name: 'Tortilla Francesa',
      ingredients: [
        RecipeIngredientEntity(
          id: 'ing-1',
          mealSnapshot: meal,
          amount: 150,
          unit: 'g',
          position: 0,
        )
      ],
    );

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(createTestWidget(recipe));
    await tester.pumpAndSettle();

    // 1. Clear Name
    final nameField = find.widgetWithText(TextField, S.current.aiRecipeNameLabel);
    await tester.enterText(nameField, '');
    await tester.tap(find.text(S.current.recipeEditorSaveRecipe));
    await tester.pumpAndSettle();
    expect(find.text(S.current.recipeEditorInvalidRecipe), findsOneWidget);

    // Reset Name, set 0 servings
    await tester.enterText(nameField, 'Tortilla');
    final servingsField = find.widgetWithText(TextField, S.current.servingsLabel);
    await tester.enterText(servingsField, '0');
    await tester.tap(find.text(S.current.recipeEditorSaveRecipe));
    await tester.pumpAndSettle();
    expect(find.text(S.current.recipeEditorInvalidRecipe), findsOneWidget);

    // Reset Servings, remove all ingredients
    await tester.enterText(servingsField, '2');
    final deleteIcon = find.byTooltip(S.current.aiRemoveLabel);
    await tester.tap(deleteIcon);
    await tester.pumpAndSettle();
    expect(find.text(S.current.recipeEditorIngredientsEmpty), findsOneWidget);

    await tester.tap(find.text(S.current.recipeEditorSaveRecipe));
    await tester.pumpAndSettle();
    expect(find.text(S.current.recipeEditorInvalidRecipe), findsOneWidget);
  });

  testWidgets('duplicates and removes ingredients from list', (tester) async {
    final meal = buildDummyMeal(code: 'm1', name: 'Huevos');
    final recipe = buildDummyRecipe(
      id: 'rec-1',
      name: 'Tortilla Francesa',
      ingredients: [
        RecipeIngredientEntity(
          id: 'ing-1',
          mealSnapshot: meal,
          amount: 150,
          unit: 'g',
          position: 0,
        )
      ],
    );

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(createTestWidget(recipe));
    await tester.pumpAndSettle();

    final summaryCard = find.ancestor(
      of: find.text(S.current.recipeEditorNutritionSummary),
      matching: find.byType(Card),
    );

    // Verify 1 ingredient initially
    expect(find.text('Huevos'), findsOneWidget);
    // Total kcal per serving (150g -> 150 * 1.5 = 225 kcal. 2 servings -> 112.5 kcal per serving = 113 kcal)
    expect(find.descendant(of: summaryCard, matching: find.text('113 kcal')), findsOneWidget);

    // Duplicate ingredient
    await tester.tap(find.byTooltip(S.current.recipeEditorDuplicate));
    await tester.pumpAndSettle();

    // Verify 2 ingredients listed
    expect(find.text('Huevos'), findsNWidgets(2));
    // Total kcal per serving: 225 + 225 = 450 kcal. 2 servings -> 225 kcal per serving
    expect(find.descendant(of: summaryCard, matching: find.text('225 kcal')), findsOneWidget);

    // Remove first ingredient
    await tester.tap(find.byTooltip(S.current.aiRemoveLabel).first);
    await tester.pumpAndSettle();

    // Verify 1 ingredient listed again
    expect(find.text('Huevos'), findsOneWidget);
    expect(find.descendant(of: summaryCard, matching: find.text('113 kcal')), findsOneWidget);
  });

  testWidgets('adds new ingredient using bottom sheet meal picker', (tester) async {
    final recipe = buildDummyRecipe(id: 'rec-1', name: 'Ensalada');
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(createTestWidget(recipe));
    await tester.pumpAndSettle();

    expect(find.text(S.current.recipeEditorIngredientsEmpty), findsOneWidget);

    // Set search results
    final searchedMeal = buildDummyMeal(code: 'searched-123', name: 'Lechuga');
    fakeSearchProductsUseCase.searchResults = [searchedMeal];

    // Tap "Añadir"
    await tester.tap(find.text(S.current.addLabel));
    await tester.pumpAndSettle();

    // Verify sheet is open
    expect(find.text(S.current.mealEntrySearchFood), findsOneWidget);

    // Enter search text and submit
    final searchInput = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == S.current.searchFoodPage);
    await tester.enterText(searchInput, 'Lechuga');
    await tester.tap(find.byIcon(Icons.arrow_forward_outlined));
    await tester.pumpAndSettle();

    // Verify search result list tile shows up
    expect(find.widgetWithText(ListTile, 'Lechuga'), findsOneWidget);

    // Tap on result to select
    await tester.tap(find.widgetWithText(ListTile, 'Lechuga'));
    await tester.pumpAndSettle();

    // Verify ingredient is added to recipe
    expect(find.text('Lechuga'), findsOneWidget);
    expect(find.text('100'), findsOneWidget); // Default amount 100g
  });

  testWidgets('replaces an ingredient using bottom sheet meal picker', (tester) async {
    final originalMeal = buildDummyMeal(code: 'm1', name: 'Huevos');
    final recipe = buildDummyRecipe(
      id: 'rec-1',
      name: 'Tortilla Francesa',
      ingredients: [
        RecipeIngredientEntity(
          id: 'ing-1',
          mealSnapshot: originalMeal,
          amount: 150,
          unit: 'g',
          position: 0,
        )
      ],
    );

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(createTestWidget(recipe));
    await tester.pumpAndSettle();

    expect(find.text('Huevos'), findsOneWidget);

    // Set search results
    final newMeal = buildDummyMeal(code: 'm2', name: 'Queso');
    fakeSearchProductsUseCase.searchResults = [newMeal];

    // Tap "Cambiar alimento" swap icon
    await tester.tap(find.byTooltip(S.current.recipeEditorChangeFood));
    await tester.pumpAndSettle();

    // Search and select
    final searchInput = find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == S.current.searchFoodPage);
    await tester.enterText(searchInput, 'Queso');
    await tester.tap(find.byIcon(Icons.arrow_forward_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Queso'));
    await tester.pumpAndSettle();

    // Verify original meal is replaced by Queso
    expect(find.text('Huevos'), findsNothing);
    expect(find.text('Queso'), findsOneWidget);
  });
}

class _FakeSearchProductsUseCase extends Fake implements SearchProductsUseCase {
  List<MealEntity> searchResults = [];
  List<MealEntity> offlineResults = [];
  bool shouldThrow = false;

  @override
  Future<List<MealEntity>> searchOFFProductsByString(String query) async {
    if (shouldThrow) throw Exception("OFF failure");
    return searchResults;
  }

  @override
  Future<List<MealEntity>> searchFDCFoodByString(String query) async {
    if (shouldThrow) throw Exception("FDC failure");
    return searchResults;
  }

  @override
  Future<List<MealEntity>> searchOfflineCache(String query) async {
    if (shouldThrow) throw Exception("Cache failure");
    return offlineResults;
  }
}

class _FakeSaveRecipeUsecase extends Fake implements SaveRecipeUsecase {
  RecipeEntity? savedRecipe;
  @override
  Future<void> saveRecipe(RecipeEntity recipeEntity) async {
    savedRecipe = recipeEntity;
  }
}
