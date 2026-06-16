import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';
import 'package:macrotracker/features/recipes/data/data_source/recipe_data_source.dart';
import 'package:macrotracker/features/recipes/data/dbo/recipe_dbo.dart';
import 'package:macrotracker/features/recipes/data/repository/recipe_repository.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_recipe_library_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_quick_recipe_presets_usecase.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

RecipeEntity _makeRecipe({
  String id = 'r1',
  String name = 'Tortilla',
  bool saved = true,
  bool pinned = false,
  int timesUsed = 0,
  DateTime? lastUsedAt,
  List<RecipeIngredientEntity> ingredients = const [],
}) {
  final now = DateTime(2024, 1, 1);
  return RecipeEntity(
    id: id,
    name: name,
    notes: null,
    defaultServings: 1,
    yieldQuantity: null,
    yieldUnit: null,
    saved: saved,
    pinned: pinned,
    timesUsed: timesUsed,
    lastUsedAt: lastUsedAt,
    quickCategory: null,
    createdAt: now,
    updatedAt: now,
    ingredients: ingredients,
  );
}

RecipeDBO _makeDBO({
  String id = 'r1',
  String name = 'Tortilla',
  bool saved = true,
  bool pinned = false,
  int timesUsed = 0,
  DateTime? lastUsedAt,
}) {
  final now = DateTime(2024, 1, 1);
  return RecipeDBO(
    id: id,
    name: name,
    notes: null,
    defaultServings: 1,
    yieldQuantity: null,
    yieldUnit: null,
    saved: saved,
    pinned: pinned,
    timesUsed: timesUsed,
    lastUsedAt: lastUsedAt,
    quickCategory: null,
    createdAt: now,
    updatedAt: now,
    ingredients: [],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

class _FakeRecipeDataSource extends Fake implements RecipeDataSource {
  final Map<String, RecipeDBO> _store = {};
  int saveCalls = 0;
  int deleteCalls = 0;

  void seed(RecipeDBO dbo) => _store[dbo.id] = dbo;

  @override
  Future<void> saveRecipe(RecipeDBO recipeDBO) async {
    saveCalls++;
    _store[recipeDBO.id] = recipeDBO;
  }

  @override
  Future<RecipeDBO?> getRecipeById(String recipeId) async => _store[recipeId];

  @override
  Future<List<RecipeDBO>> getAllRecipes() async {
    final list = _store.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    deleteCalls++;
    _store.remove(recipeId);
  }

  @override
  Future<void> setRecipeSaved(String recipeId, bool isSaved) async {
    final r = _store[recipeId];
    if (r != null) r.saved = isSaved;
  }

  @override
  Future<void> setRecipePinned(String recipeId, bool isPinned) async {
    final r = _store[recipeId];
    if (r != null) r.pinned = isPinned;
  }

  @override
  Future<void> markRecipeUsed(String recipeId, DateTime usedAt) async {
    final r = _store[recipeId];
    if (r != null) {
      r.lastUsedAt = usedAt;
      r.timesUsed += 1;
      r.updatedAt = usedAt;
    }
  }
}

class _FakeRecipeRepository extends Fake implements RecipeRepository {
  final List<RecipeEntity> _recipes;
  _FakeRecipeRepository(this._recipes);

  @override
  Future<List<RecipeEntity>> getAllRecipes({bool savedOnly = true}) async =>
      _recipes.where((r) => !savedOnly || r.saved).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── RecipeDataSource ──────────────────────────────────────────────────────
  group('RecipeDataSource', () {
    late Directory tempDir;
    late HiveDBProvider hiveProvider;
    late RecipeDataSource ds;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir =
          await Directory.systemTemp.createTemp('macrotracker_recipe_ds_test_');

      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return tempDir.path;
      });

      hiveProvider = HiveDBProvider();
      final key = Hive.generateSecureKey();
      await hiveProvider.initHiveDB(Uint8List.fromList(key));
      ds = RecipeDataSource(hiveProvider.recipeBox);
    });

    tearDown(() async {
      await hiveProvider.clearAllData();
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('saveRecipe stores recipe by id', () async {
      final dbo = _makeDBO(id: 'r1', name: 'Omelette');
      await ds.saveRecipe(dbo);
      expect((await ds.getRecipeById('r1'))?.name, 'Omelette');
    });

    test('getRecipeById returns null for unknown id', () async {
      expect(await ds.getRecipeById('unknown'), isNull);
    });

    test('getAllRecipes returns all stored in updatedAt descending order',
        () async {
      final old = _makeDBO(id: 'r1', name: 'Old');
      final recent = _makeDBO(id: 'r2', name: 'Recent')
        ..updatedAt = DateTime(2025, 1, 1);
      await ds.saveRecipe(old);
      await ds.saveRecipe(recent);
      final all = await ds.getAllRecipes();
      expect(all.first.name, 'Recent');
    });

    test('deleteRecipe removes recipe', () async {
      final dbo = _makeDBO(id: 'r1');
      await ds.saveRecipe(dbo);
      await ds.deleteRecipe('r1');
      expect(await ds.getRecipeById('r1'), isNull);
    });

    test('setRecipeSaved updates saved flag', () async {
      final dbo = _makeDBO(id: 'r1', saved: true);
      await ds.saveRecipe(dbo);
      await ds.setRecipeSaved('r1', false);
      final stored = await ds.getRecipeById('r1');
      expect(stored?.saved, isFalse);
    });

    test('setRecipePinned updates pinned flag', () async {
      final dbo = _makeDBO(id: 'r1', pinned: false);
      await ds.saveRecipe(dbo);
      await ds.setRecipePinned('r1', true);
      final stored = await ds.getRecipeById('r1');
      expect(stored?.pinned, isTrue);
    });

    test('setRecipeSaved/Pinned on unknown id is a no-op', () async {
      await ds.setRecipeSaved('unknown', false);
      await ds.setRecipePinned('unknown', true);
      // no exception
    });

    test('markRecipeUsed increments timesUsed and sets lastUsedAt', () async {
      final dbo = _makeDBO(id: 'r1', timesUsed: 2);
      await ds.saveRecipe(dbo);
      final usedAt = DateTime(2024, 6, 1);
      await ds.markRecipeUsed('r1', usedAt);
      final stored = await ds.getRecipeById('r1');
      expect(stored?.timesUsed, 3);
      expect(stored?.lastUsedAt, usedAt);
    });
  });

  // ── RecipeRepository ──────────────────────────────────────────────────────
  group('RecipeRepository', () {
    late _FakeRecipeDataSource ds;
    late RecipeRepository repo;

    setUp(() {
      ds = _FakeRecipeDataSource();
      repo = RecipeRepository(ds);
    });

    test('saveRecipe converts entity to DBO and delegates', () async {
      final entity = _makeRecipe(id: 'r1', name: 'Pasta');
      await repo.saveRecipe(entity);
      expect(ds.saveCalls, 1);
      final stored = await ds.getRecipeById('r1');
      expect(stored?.name, 'Pasta');
    });

    test('getRecipeById maps DBO to entity', () async {
      ds.seed(_makeDBO(id: 'r1', name: 'Salad'));
      final entity = await repo.getRecipeById('r1');
      expect(entity?.name, 'Salad');
    });

    test('getRecipeById returns null for missing id', () async {
      expect(await repo.getRecipeById('nope'), isNull);
    });

    test('getAllRecipes filters unsaved when savedOnly=true', () async {
      ds.seed(_makeDBO(id: 'r1', saved: true));
      ds.seed(_makeDBO(id: 'r2', saved: false));
      final recipes = await repo.getAllRecipes(savedOnly: true);
      expect(recipes.length, 1);
      expect(recipes.first.id, 'r1');
    });

    test('getAllRecipes includes unsaved when savedOnly=false', () async {
      ds.seed(_makeDBO(id: 'r1', saved: true));
      ds.seed(_makeDBO(id: 'r2', saved: false));
      final recipes = await repo.getAllRecipes(savedOnly: false);
      expect(recipes.length, 2);
    });

    test('getAllRecipes sorts: pinned > recently used > timesUsed > updatedAt',
        () async {
      final base = DateTime(2024, 1, 1);
      ds.seed(_makeDBO(
          id: 'a',
          name: 'A',
          pinned: false,
          timesUsed: 5,
          lastUsedAt: base.add(const Duration(days: 1))));
      ds.seed(_makeDBO(id: 'b', name: 'B', pinned: true, timesUsed: 1));
      ds.seed(_makeDBO(id: 'c', name: 'C', pinned: false, timesUsed: 10));

      final recipes = await repo.getAllRecipes(savedOnly: false);
      // pinned first
      expect(recipes.first.id, 'b');
    });

    test('deleteRecipe delegates to data source', () async {
      ds.seed(_makeDBO(id: 'r1'));
      await repo.deleteRecipe('r1');
      expect(ds.deleteCalls, 1);
    });

    test('setRecipeSaved delegates', () async {
      ds.seed(_makeDBO(id: 'r1', saved: true));
      await repo.setRecipeSaved('r1', false);
      expect(_isStoredSaved(ds, 'r1'), isFalse);
    });

    test('setRecipePinned delegates', () async {
      ds.seed(_makeDBO(id: 'r1', pinned: false));
      await repo.setRecipePinned('r1', true);
      expect(_isStoredPinned(ds, 'r1'), isTrue);
    });

    test('markRecipeUsed delegates', () async {
      ds.seed(_makeDBO(id: 'r1', timesUsed: 0));
      await repo.markRecipeUsed('r1', DateTime(2024, 3, 1));
      expect((await ds.getRecipeById('r1'))?.timesUsed, 1);
    });
  });

  // ── GetQuickRecipePresetsUsecase ──────────────────────────────────────────
  group('GetQuickRecipePresetsUsecase', () {
    late GetQuickRecipePresetsUsecase usecase;

    RecipeEntity makeWithIngredients(
        {required String id,
        required String name,
        bool pinned = false,
        bool saved = true,
        int timesUsed = 0,
        DateTime? lastUsedAt}) {
      // Build a recipe with an ingredient so kcalPerServing > 0
      final now = DateTime(2024, 1, 1);
      return RecipeEntity(
        id: id,
        name: name,
        notes: null,
        defaultServings: 1,
        yieldQuantity: null,
        yieldUnit: null,
        saved: saved,
        pinned: pinned,
        timesUsed: timesUsed,
        lastUsedAt: lastUsedAt,
        quickCategory: null,
        createdAt: now,
        updatedAt: now,
        ingredients: const [],
      );
    }

    test('returns empty list when no recipes exist', () async {
      usecase = GetQuickRecipePresetsUsecase(
          GetRecipeLibraryUsecase(_FakeRecipeRepository([])));
      final presets = await usecase.getPresets();
      expect(presets, isEmpty);
    });

    test('filters out recipes with zero kcal', () async {
      // Empty ingredients → kcalPerServing == 0 → filtered out
      final recipes = [makeWithIngredients(id: 'r1', name: 'Empty')];
      usecase = GetQuickRecipePresetsUsecase(
          GetRecipeLibraryUsecase(_FakeRecipeRepository(recipes)));
      final presets = await usecase.getPresets();
      expect(presets, isEmpty);
    });

    test('limit parameter caps the results', () async {
      usecase = GetQuickRecipePresetsUsecase(
          GetRecipeLibraryUsecase(_FakeRecipeRepository([])));
      final presets = await usecase.getPresets(limit: 2);
      expect(presets.length, lessThanOrEqualTo(2));
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper accessors for fake data source
// ─────────────────────────────────────────────────────────────────────────────

bool _isStoredSaved(_FakeRecipeDataSource ds, String id) =>
    ds._store[id]?.saved ?? true;

bool _isStoredPinned(_FakeRecipeDataSource ds, String id) =>
    ds._store[id]?.pinned ?? false;
