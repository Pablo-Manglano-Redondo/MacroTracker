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
import 'package:macrotracker/features/add_meal/data/data_source/fdc_data_source.dart';
import 'package:macrotracker/features/add_meal/data/data_source/off_data_source.dart';
import 'package:macrotracker/features/add_meal/data/data_source/sp_fdc_data_source.dart';
import 'package:macrotracker/features/add_meal/data/dto/fdc/fdc_food_dto.dart';
import 'package:macrotracker/features/add_meal/data/dto/fdc/fdc_food_nutriment_dto.dart';
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
  MockFDCDataSource({this.response});

  final FDCWordResponseDTO? response;

  @override
  Future<FDCWordResponseDTO> fetchSearchWordResults(String searchString) async {
    if (response != null) {
      return response!;
    }
    throw const SocketException('Mocked FDC Network Failure');
  }
}

class MockSpFdcDataSource extends SpFdcDataSource {
  MockSpFdcDataSource({this.throwBackendUnavailable = false});

  final bool throwBackendUnavailable;

  @override
  Future<List<SpFdcFoodDTO>> fetchSearchWordResults(String searchString) async {
    if (throwBackendUnavailable) {
      throw const SpFdcBackendUnavailableException(
        'Supabase FDC cache table is unavailable.',
      );
    }
    throw const SocketException('Mocked SpFDC Network Failure');
  }
}

void main() {
  group('Offline-First Search Fallback Tests', () {
    late Directory tempDir;
    late HiveDBProvider hiveProvider;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir =
          await Directory.systemTemp.createTemp('macrotracker_search_test_');

      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return tempDir.path;
      });

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

    test(
        'searchOfflineCache aggregates matching recipes, previous search caches, and recent intakes',
        () async {
      final repo = ProductsRepository(
        MockOFFDataSource(),
        MockFDCDataSource(),
        MockSpFdcDataSource(),
      );

      final recipeDbo = RecipeDBO(
        id: 'rec_1',
        name: 'Platano Proteico Shake',
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
              name: 'Platano fruta',
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
          ),
        ],
        quickCategory: 'breakfast',
      );
      await hiveProvider.recipeBox.put('rec_1', recipeDbo);

      final intakeDbo = IntakeDBO(
        id: 'int_1',
        unit: 'g',
        amount: 150,
        type: IntakeTypeDBO.breakfast,
        dateTime: DateTime.now(),
        meal: MealDBO(
          code: 'food_platano_hist',
          name: 'Platano frito canario',
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

      final results = await repo.searchOfflineCache('Platano');

      expect(results, hasLength(2));
      final names = results.map((m) => m.name).toList();
      expect(names, contains('Platano Proteico Shake'));
      expect(names, contains('Platano frito canario'));
    });

    test(
        'getSupabaseFDCFoodsByString falls back to USDA FDC when Supabase cache is unavailable',
        () async {
      final repo = ProductsRepository(
        MockOFFDataSource(),
        MockFDCDataSource(
          response: FDCWordResponseDTO(
            totalHits: 1,
            currentPage: 1,
            foods: [
              FDCFoodDTO(
                fdcId: 12345,
                gtinUpc: null,
                description: 'Chicken breast',
                brandOwner: null,
                brandName: null,
                packageWeight: null,
                servingSize: 100,
                foodNutrients: [
                  FDCFoodNutrimentDTO(nutrientId: 1008, amount: 165),
                  FDCFoodNutrimentDTO(nutrientId: 1003, amount: 31),
                  FDCFoodNutrimentDTO(nutrientId: 1004, amount: 3.6),
                  FDCFoodNutrimentDTO(nutrientId: 1005, amount: 0),
                ],
                servingSizeUnit: 'g',
              ),
            ],
          ),
        ),
        MockSpFdcDataSource(throwBackendUnavailable: true),
      );

      final results = await repo.getSupabaseFDCFoodsByString('chicken');

      expect(results, hasLength(1));
      expect(results.first.name, 'Chicken breast');
      expect(results.first.code, '12345');
    });
  });
}
