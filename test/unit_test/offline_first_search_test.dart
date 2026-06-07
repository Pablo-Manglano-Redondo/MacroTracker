import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:macrotracker/core/data/dbo/intake_dbo.dart';
import 'package:macrotracker/core/data/dbo/intake_type_dbo.dart';
import 'package:macrotracker/core/data/dbo/meal_dbo.dart';
import 'package:macrotracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/add_meal/data/data_sources/fdc_data_source.dart';
import 'package:macrotracker/features/add_meal/data/data_sources/off_data_source.dart';
import 'package:macrotracker/features/add_meal/data/data_sources/sp_fdc_data_source.dart';
import 'package:macrotracker/features/add_meal/data/dto/fdc/fdc_word_response_dto.dart';
import 'package:macrotracker/features/add_meal/data/dto/fdc_sp/sp_fdc_food_dto.dart';
import 'package:macrotracker/features/add_meal/data/dto/off/off_word_response_dto.dart';
import 'package:macrotracker/features/add_meal/data/repository/products_repository.dart';
import 'package:macrotracker/features/recipes/data/dbo/recipe_dbo.dart';
import 'package:macrotracker/features/recipes/data/dbo/recipe_ingredient_dbo.dart';

class MockOFFDataSource extends OFFDataSource {
  @override
  Future<OFFWordResponseDTO> fetchSearchWordResults(String searchString) async {
    throw const SocketException('Mocked OFF Network Failure');
  }
}

class MockFDCDataSource extends FDCDataSource {
  @override
  Future<FDCWordResponseDTO> fetchSearchWordResults(String searchString) async {
    throw const SocketException('Mocked FDC Network Failure');
  }
}

class MockSpFdcDataSource extends SpFdcDataSource {
  @override
  Future<List<SpFdcFoodDTO>> fetchSearchWordResults(String searchString) async {
    throw const SocketException('Mocked SpFDC Network Failure');
  }
}

void main() {
  group('Offline-First Search Fallback Tests', () {
    late Directory tempDir;
    late HiveDBProvider hiveProvider;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp.createTemp('macrotracker_search_test_');

      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return tempDir.path;
      });

      // Setup GetIt/Locator mock boxes
      hiveProvider = HiveDBProvider();
      final key = Hive.generateSecureKey();
      await hiveProvider.initHiveDB(Uint8List.fromList(key));
      if (locator.isRegistered<HiveDBProvider>()) {
        await locator.unregister<HiveDBProvider>();
      }
      locator.registerSingleton<HiveDBProvider>(hiveProvider);
    });

    tearDown(() async {
      await hiveProvider.clearAllData();
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      await locator.reset();
    });

    test('searchOfflineCache aggregates matching recipes, previous search caches, and recent intakes', () async {
      final repo = ProductsRepository(
        MockOFFDataSource(),
        MockFDCDataSource(),
        MockSpFdcDataSource(),
      );

      // 1. Populate custom local recipe
      final recipeDbo = RecipeDBO(
        id: 'rec_1',
        name: 'Plátano Proteico Shake',
        notes: 'Batido saludable',
        defaultServings: 1.0,
        yieldQuantity: null,
        yieldUnit: null,
        saved: true,
        pinned: false,
        timesUsed: 1,
        lastUsedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ingredients: [
          RecipeIngredientDBO(
            id: 'ing_1',
            mealSnapshot: MealDBO(
              code: 'food_platano',
              name: 'Plátano fruta',
              brands: 'Generic',
              thumbnailImageUrl: null,
              mainImageUrl: null,
              url: null,
              mealQuantity: '120',
              mealUnit: 'g',
              servingQuantity: 120,
              servingUnit: 'g',
              servingSize: '120g',
              nutriments: MealNutrimentsDBO(
                energyKcal100: 89,
                carbohydrates100: 23,
                fat100: 0.3,
                proteins100: 1.1,
                sugars100: 12,
                saturatedFat100: 0.1,
                fiber100: 2.6,
              ),
              source: MealSourceDBO.custom,
            ),
            amount: 1,
            unit: 'serving',
            position: 1,
          )
        ],
        quickCategory: 'breakfast',
      );
      await hiveProvider.recipeBox.put('rec_1', recipeDbo);

      // 2. Populate historical intake
      final intakeDbo = IntakeDBO(
        id: 'int_1',
        unit: 'g',
        amount: 150,
        type: IntakeTypeDBO.breakfast,
        dateTime: DateTime.now(),
        meal: MealDBO(
          code: 'food_platano_hist',
          name: 'Plátano frito canario',
          brands: 'Canarias',
          thumbnailImageUrl: null,
          mainImageUrl: null,
          url: null,
          mealQuantity: '100',
          mealUnit: 'g',
          servingQuantity: 100,
          servingUnit: 'g',
          servingSize: '100g',
          nutriments: MealNutrimentsDBO(
            energyKcal100: 120,
            carbohydrates100: 28,
            fat100: 0.1,
            proteins100: 1.2,
            sugars100: null,
            saturatedFat100: null,
            fiber100: null,
          ),
          source: MealSourceDBO.custom,
        ),
      );
      await hiveProvider.intakeBox.put('int_1', intakeDbo);

      // 3. Perform searchOfflineCache
      final results = await repo.searchOfflineCache('Plátano');

      expect(results, hasLength(2));
      final names = results.map((m) => m.name).toList();
      expect(names, contains('Plátano Proteico Shake'));
      expect(names, contains('Plátano frito canario'));
    });
  });
}
