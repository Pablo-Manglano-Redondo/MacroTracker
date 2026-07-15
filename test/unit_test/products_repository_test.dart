import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:macrotracker/core/data/dbo/meal_dbo.dart';
import 'package:macrotracker/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:macrotracker/features/recipes/data/dbo/recipe_dbo.dart';
import 'package:macrotracker/core/data/dbo/intake_dbo.dart';
import 'package:macrotracker/core/data/dbo/intake_type_dbo.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/add_meal/data/data_source/fdc_data_source.dart';
import 'package:macrotracker/features/add_meal/data/data_source/off_data_source.dart';
import 'package:macrotracker/features/add_meal/data/data_source/sp_fdc_data_source.dart';
import 'package:macrotracker/features/add_meal/data/repository/products_repository.dart';
import 'package:macrotracker/features/add_meal/data/dto/off/off_word_response_dto.dart';
import 'package:macrotracker/features/add_meal/data/dto/off/off_product_dto.dart';
import 'package:macrotracker/features/add_meal/data/dto/off/off_product_nutriments_dto.dart';
import 'package:macrotracker/features/add_meal/data/dto/off/off_product_response_dto.dart';
import 'package:macrotracker/features/add_meal/data/dto/fdc/fdc_word_response_dto.dart';
import 'package:macrotracker/features/add_meal/data/dto/fdc/fdc_food_dto.dart';
import 'package:macrotracker/features/add_meal/data/dto/fdc_sp/sp_fdc_food_dto.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

class _FakeOFFDataSource extends Fake implements OFFDataSource {
  OFFWordResponseDTO? wordResponse;
  OFFProductResponseDTO? barcodeResponse;

  @override
  Future<OFFWordResponseDTO> fetchSearchWordResults(String searchString) async {
    return wordResponse ??
        OFFWordResponseDTO(
          count: 0,
          page: 1,
          page_count: 0,
          page_size: 0,
          products: const [],
        );
  }

  @override
  Future<OFFProductResponseDTO> fetchBarcodeResults(String barcode) async {
    if (barcodeResponse == null) {
      throw Exception('Not found');
    }
    return barcodeResponse!;
  }
}

class _FakeFDCDataSource extends Fake implements FDCDataSource {
  FDCWordResponseDTO? wordResponse;

  @override
  Future<FDCWordResponseDTO> fetchSearchWordResults(String searchString) async {
    return wordResponse ??
        FDCWordResponseDTO(
          totalHits: 0,
          currentPage: 1,
          foods: const [],
        );
  }
}

class _FakeSpFdcDataSource extends Fake implements SpFdcDataSource {
  List<SpFdcFoodDTO>? wordResponse;
  bool shouldThrowUnavailable = false;

  @override
  Future<List<SpFdcFoodDTO>> fetchSearchWordResults(String searchString) async {
    if (shouldThrowUnavailable) {
      throw const SpFdcBackendUnavailableException('Unavailable');
    }
    return wordResponse ?? const [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('ProductsRepository Tests', () {
    late Directory tempDir;
    late HiveDBProvider hiveProvider;
    late ProductsRepository repository;
    late _FakeOFFDataSource offDS;
    late _FakeFDCDataSource fdcDS;
    late _FakeSpFdcDataSource spDS;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp
          .createTemp('macrotracker_products_repo_test_');

      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return tempDir.path;
      });

      hiveProvider = HiveDBProvider();
      final key = Hive.generateSecureKey();
      await hiveProvider.initHiveDB(Uint8List.fromList(key));

      // Register in global locator
      locator.registerSingleton<HiveDBProvider>(hiveProvider);

      offDS = _FakeOFFDataSource();
      fdcDS = _FakeFDCDataSource();
      spDS = _FakeSpFdcDataSource();

      repository = ProductsRepository(offDS, fdcDS, spDS);
    });

    tearDown(() async {
      locator.unregister<HiveDBProvider>();
      await hiveProvider.clearAllData();
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('getOFFProductsByString handles cache hits, misses, and short strings',
        () async {
      // 1. Short string
      expect(await repository.getOFFProductsByString('a'), isEmpty);

      // 2. Cache miss, fetches from network and saves to cache
      final offProduct = OFFProductDTO(
        code: '123',
        quantity: '100g',
        product_quantity: 100,
        serving_quantity: 100,
        serving_size: '100g',
        image_front_thumb_url: 'thumb',
        image_front_url: 'main',
        image_ingredients_url: 'ingredients',
        image_nutrition_url: 'nutrition',
        image_url: 'url',
        url: 'url',
        brands: 'Brand A',
        product_name: 'Manzana',
        product_name_en: 'Apple',
        product_name_fr: 'Pomme',
        product_name_de: 'Apfel',
        nova_group: 1,
        nutriments: OFFProductNutrimentsDTO(
          energy_kcal_100g: 52,
          carbohydrates_100g: 14,
          fat_100g: 0.2,
          proteins_100g: 0.3,
          sugars_100g: 10,
          saturated_fat_100g: 0.1,
          fiber_100g: 2.4,
        ),
      );

      offDS.wordResponse = OFFWordResponseDTO(
        count: 1,
        page: 1,
        page_count: 1,
        page_size: 1,
        products: [offProduct],
      );

      final results = await repository.getOFFProductsByString('apple');
      expect(results, hasLength(1));
      expect(results.first.code, equals('123'));
      expect(results.first.name, equals('Apple'));

      // Check if cache contains the item
      final cached = hiveProvider.productSearchCacheBox.get('search_apple');
      expect(cached, isNotNull);

      // 3. Cache hit within 7 days
      // We alter the fake response to prove it loads from cache instead
      offDS.wordResponse = OFFWordResponseDTO(
        count: 0,
        page: 1,
        page_count: 0,
        page_size: 0,
        products: const [],
      );

      final cachedResults = await repository.getOFFProductsByString('apple');
      expect(cachedResults, hasLength(1));
      expect(cachedResults.first.code, equals('123'));
    });

    test('getFDCFoodsByString calls data source and maps correctly', () async {
      expect(await repository.getFDCFoodsByString(' '), isEmpty);

      final fdcFood = FDCFoodDTO(
        fdcId: 456,
        gtinUpc: 'upc456',
        description: 'Banana',
        brandOwner: 'Chiquita owner',
        brandName: 'Chiquita',
        packageWeight: '150g',
        servingSize: 150,
        servingSizeUnit: 'g',
        foodNutrients: const [],
      );

      fdcDS.wordResponse = FDCWordResponseDTO(
        totalHits: 1,
        currentPage: 1,
        foods: [fdcFood],
      );

      final results = await repository.getFDCFoodsByString('banana');
      expect(results, hasLength(1));
      expect(results.first.code, equals('456'));
      expect(results.first.name, equals('Banana'));
    });

    test(
        'getSupabaseFDCFoodsByString handles cache hits, misses, and USDA fallback',
        () async {
      expect(await repository.getSupabaseFDCFoodsByString(''), isEmpty);

      // Miss, Supabase fetches fine
      final spFood = SpFdcFoodDTO(
        fdcId: 789,
        descriptionEn: 'Orange',
        descriptionDe: 'Apfelsine',
        portions: const [],
        nutrients: const [],
      );
      spDS.wordResponse = [spFood];

      final results = await repository.getSupabaseFDCFoodsByString('orange');
      expect(results, hasLength(1));
      expect(results.first.code, equals('789'));

      // Check cache
      expect(hiveProvider.productSearchCacheBox.get('fdc_search_orange'),
          isNotNull);

      // Cache hit
      spDS.wordResponse = const [];
      final cachedResults =
          await repository.getSupabaseFDCFoodsByString('orange');
      expect(cachedResults, hasLength(1));

      // Backend unavailable fallback to USDA FDCDataSource
      spDS.shouldThrowUnavailable = true;
      final fdcFood = FDCFoodDTO(
        fdcId: 101,
        gtinUpc: 'upc101',
        description: 'Grape',
        brandOwner: 'G Owner',
        brandName: 'Brand G',
        packageWeight: '100g',
        servingSize: 100,
        servingSizeUnit: 'g',
        foodNutrients: const [],
      );
      fdcDS.wordResponse =
          FDCWordResponseDTO(totalHits: 1, currentPage: 1, foods: [fdcFood]);

      final fallbackResults =
          await repository.getSupabaseFDCFoodsByString('grape');
      expect(fallbackResults, hasLength(1));
      expect(fallbackResults.first.code, equals('101'));
    });

    test('getOFFProductByBarcode handles cache and barcode lookup', () async {
      final offProduct = OFFProductDTO(
        code: 'bar123',
        quantity: '100g',
        product_quantity: 100,
        serving_quantity: 100,
        serving_size: '100g',
        image_front_thumb_url: 'thumb',
        image_front_url: 'main',
        image_ingredients_url: 'ingredients',
        image_nutrition_url: 'nutrition',
        image_url: 'url',
        url: 'url',
        brands: 'Brand B',
        product_name: 'Pera',
        product_name_en: 'Pear',
        product_name_fr: 'Poire',
        product_name_de: 'Birne',
        nova_group: 1,
        nutriments: OFFProductNutrimentsDTO(
          energy_kcal_100g: 57,
          carbohydrates_100g: 15,
          fat_100g: 0.1,
          proteins_100g: 0.4,
          sugars_100g: 10,
          saturated_fat_100g: 0.0,
          fiber_100g: 3.1,
        ),
      );

      offDS.barcodeResponse = OFFProductResponseDTO(
        status: 1,
        status_verbose: 'found',
        product: offProduct,
      );

      final meal = await repository.getOFFProductByBarcode('bar123');
      expect(meal.code, equals('bar123'));
      expect(meal.name, equals('Pear'));

      // Cache hit
      offDS.barcodeResponse = null; // Will cause exception if called
      final cachedMeal = await repository.getOFFProductByBarcode('bar123');
      expect(cachedMeal.code, equals('bar123'));
    });

    test(
        'searchOfflineCache searches cache, recipes, and historical intakes with deduplication',
        () async {
      // 1. Setup cache
      final cacheMeal = MealDBO(
        code: 'c1',
        name: 'Cached Oats',
        brands: 'Quaker',
        thumbnailImageUrl: '',
        mainImageUrl: '',
        url: '',
        mealQuantity: '100',
        mealUnit: 'g',
        servingQuantity: 100,
        servingUnit: 'g',
        servingSize: '',
        nutriments: MealNutrimentsDBO(
          energyKcal100: 389,
          carbohydrates100: 66,
          fat100: 6.9,
          proteins100: 16.9,
          sugars100: 0,
          saturatedFat100: 0,
          fiber100: 0,
        ),
        source: MealSourceDBO.custom,
      );

      final envelope = {
        'cachedAt': DateTime.now().toIso8601String(),
        'payload': cacheMeal.toJson(),
      };
      await hiveProvider.productSearchCacheBox
          .put('barcode_c1', jsonEncode(envelope));

      // 2. Setup recipe
      final recipe = RecipeDBO(
        id: 'r1',
        name: 'Oats Porridge',
        notes: 'Delicious breakfast',
        defaultServings: 1,
        yieldQuantity: 1,
        yieldUnit: 'serving',
        saved: true,
        pinned: false,
        timesUsed: 1,
        lastUsedAt: DateTime.now(),
        quickCategory: 'breakfast',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ingredients: const [],
      );
      await hiveProvider.recipeBox.put('r1', recipe);

      // 3. Setup historical intake
      final intake = IntakeDBO(
        id: 'in1',
        unit: 'g',
        amount: 50,
        type: IntakeTypeDBO.breakfast,
        dateTime: DateTime.now(),
        meal: cacheMeal,
      );
      await hiveProvider.intakeBox.put('in1', intake);

      // 4. Search
      final searchResults = await repository.searchOfflineCache('oats');
      // Should find Quaker Oats (from cache & intake, deduplicated) and Oats Porridge (from recipe)
      expect(searchResults, hasLength(2));

      final names = searchResults.map((m) => m.name).toList();
      expect(names, contains('Cached Oats'));
      expect(names, contains('Oats Porridge'));
    });
  });
}
