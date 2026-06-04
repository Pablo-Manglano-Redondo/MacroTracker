import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrotracker/core/data/dbo/meal_dbo.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/add_meal/data/data_sources/fdc_data_source.dart';
import 'package:macrotracker/features/add_meal/data/data_sources/off_data_source.dart';
import 'package:macrotracker/features/add_meal/data/data_sources/sp_fdc_data_source.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';

class ProductsRepository {
  final OFFDataSource _offDataSource;
  final FDCDataSource _fdcDataSource;
  final SpFdcDataSource _spBackendDataSource;

  ProductsRepository(
      this._offDataSource, this._fdcDataSource, this._spBackendDataSource);

  Box<dynamic> get _cacheBox => locator<HiveDBProvider>().productSearchCacheBox;

  Future<List<MealEntity>> getOFFProductsByString(String searchString) async {
    if (searchString.trim().length < 2) {
      return const [];
    }

    final queryKey = 'search_${searchString.trim().toLowerCase()}';
    final cachedData = _cacheBox.get(queryKey);
    if (cachedData != null) {
      try {
        final envelope = jsonDecode(cachedData as String) as Map<String, dynamic>;
        final cachedAtStr = envelope['cachedAt'] as String?;
        if (cachedAtStr != null) {
          final cachedAt = DateTime.parse(cachedAtStr);
          final age = DateTime.now().difference(cachedAt);
          if (age < const Duration(days: 7)) {
            final List<dynamic> jsonList = envelope['payload'] as List<dynamic>;
            return jsonList
                .map((item) => MealEntity.fromMealDBO(
                    MealDBO.fromJson(item as Map<String, dynamic>)))
                .toList();
          } else {
            await _cacheBox.delete(queryKey);
          }
        }
      } catch (_) {
        // Fallback to network on error
      }
    }

    final offWordResponse =
        await _offDataSource.fetchSearchWordResults(searchString);

    final products = offWordResponse.products
        .map(_tryMapOffProduct)
        .whereType<MealEntity>()
        .where((meal) => (meal.name ?? '').trim().isNotEmpty)
        .toList();

    try {
      final jsonList = products
          .map((meal) => MealDBO.fromMealEntity(meal).toJson())
          .toList();
      final envelope = {
        'cachedAt': DateTime.now().toIso8601String(),
        'payload': jsonList,
      };
      await _cacheBox.put(queryKey, jsonEncode(envelope));
    } catch (_) {}

    return products;
  }

  Future<List<MealEntity>> getFDCFoodsByString(String searchString) async {
    if (searchString.trim().length < 2) {
      return const [];
    }

    final fdcWordResponse =
        await _fdcDataSource.fetchSearchWordResults(searchString);
    final products = fdcWordResponse.foods
        .map((food) => MealEntity.fromFDCFood(food))
        .toList();
    return products;
  }

  Future<List<MealEntity>> getSupabaseFDCFoodsByString(
      String searchString) async {
    if (searchString.trim().length < 2) {
      return const [];
    }

    final queryKey = 'fdc_search_${searchString.trim().toLowerCase()}';
    final cachedData = _cacheBox.get(queryKey);
    if (cachedData != null) {
      try {
        final envelope = jsonDecode(cachedData as String) as Map<String, dynamic>;
        final cachedAtStr = envelope['cachedAt'] as String?;
        if (cachedAtStr != null) {
          final cachedAt = DateTime.parse(cachedAtStr);
          final age = DateTime.now().difference(cachedAt);
          if (age < const Duration(days: 7)) {
            final List<dynamic> jsonList = envelope['payload'] as List<dynamic>;
            return jsonList
                .map((item) => MealEntity.fromMealDBO(
                    MealDBO.fromJson(item as Map<String, dynamic>)))
                .toList();
          } else {
            await _cacheBox.delete(queryKey);
          }
        }
      } catch (_) {
        // Fallback to network on error
      }
    }

    final spFdcWordResponse =
        await _spBackendDataSource.fetchSearchWordResults(searchString);
    final products = spFdcWordResponse
        .map(_tryMapSupabaseFood)
        .whereType<MealEntity>()
        .where((meal) => (meal.name ?? '').trim().isNotEmpty)
        .toList();

    try {
      final jsonList = products
          .map((meal) => MealDBO.fromMealEntity(meal).toJson())
          .toList();
      final envelope = {
        'cachedAt': DateTime.now().toIso8601String(),
        'payload': jsonList,
      };
      await _cacheBox.put(queryKey, jsonEncode(envelope));
    } catch (_) {}

    return products;
  }

  Future<MealEntity> getOFFProductByBarcode(String barcode) async {
    final barcodeKey = 'barcode_$barcode';
    final cachedData = _cacheBox.get(barcodeKey);
    if (cachedData != null) {
      try {
        final envelope = jsonDecode(cachedData as String) as Map<String, dynamic>;
        final cachedAtStr = envelope['cachedAt'] as String?;
        if (cachedAtStr != null) {
          final cachedAt = DateTime.parse(cachedAtStr);
          final age = DateTime.now().difference(cachedAt);
          if (age < const Duration(days: 30)) {
            final Map<String, dynamic> jsonMap = envelope['payload'] as Map<String, dynamic>;
            return MealEntity.fromMealDBO(MealDBO.fromJson(jsonMap));
          } else {
            await _cacheBox.delete(barcodeKey);
          }
        }
      } catch (_) {
        // Fallback to network on error
      }
    }

    final productResponse = await _offDataSource.fetchBarcodeResults(barcode);
    final meal = MealEntity.fromOFFProduct(productResponse.product);

    try {
      final jsonMap = MealDBO.fromMealEntity(meal).toJson();
      final envelope = {
        'cachedAt': DateTime.now().toIso8601String(),
        'payload': jsonMap,
      };
      await _cacheBox.put(barcodeKey, jsonEncode(envelope));
    } catch (_) {}

    return meal;
  }

  Future<List<MealEntity>> searchOfflineCache(String query) async {
    final results = <MealEntity>[];
    final normalizedQuery = query.toLowerCase().trim();
    if (normalizedQuery.isEmpty) return results;

    try {
      for (final key in _cacheBox.keys) {
        final cachedRaw = _cacheBox.get(key);
        if (cachedRaw is String) {
          final envelope = jsonDecode(cachedRaw) as Map<String, dynamic>;
          final payload = envelope['payload'];
          if (payload is Map) {
            final mealDbo = MealDBO.fromJson(Map<String, dynamic>.from(payload));
            final name = mealDbo.name?.toLowerCase() ?? '';
            final brand = mealDbo.brands?.toLowerCase() ?? '';
            if (name.contains(normalizedQuery) || brand.contains(normalizedQuery)) {
              results.add(MealEntity.fromMealDBO(mealDbo));
            }
          } else if (payload is List) {
            for (final item in payload) {
              if (item is Map) {
                final mealDbo = MealDBO.fromJson(Map<String, dynamic>.from(item));
                final name = mealDbo.name?.toLowerCase() ?? '';
                final brand = mealDbo.brands?.toLowerCase() ?? '';
                if (name.contains(normalizedQuery) || brand.contains(normalizedQuery)) {
                  results.add(MealEntity.fromMealDBO(mealDbo));
                }
              }
            }
          }
        }
      }
    } catch (_) {}

    final unique = <String, MealEntity>{};
    for (final meal in results) {
      if (meal.code != null) {
        unique[meal.code!] = meal;
      }
    }
    return unique.values.toList();
  }

  MealEntity? _tryMapOffProduct(dynamic offProduct) {
    try {
      return MealEntity.fromOFFProduct(offProduct);
    } catch (_) {
      return null;
    }
  }

  MealEntity? _tryMapSupabaseFood(dynamic foodItem) {
    try {
      return MealEntity.fromSpFDCFood(foodItem);
    } catch (_) {
      return null;
    }
  }
}
