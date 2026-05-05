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

  Future<List<MealEntity>> getOFFProductsByString(String searchString) async {
    if (searchString.trim().length < 2) {
      return const [];
    }

    final offWordResponse =
        await _offDataSource.fetchSearchWordResults(searchString);

    final products = offWordResponse.products
        .map(_tryMapOffProduct)
        .whereType<MealEntity>()
        .where((meal) => (meal.name ?? '').trim().isNotEmpty)
        .toList();

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

    final spFdcWordResponse =
        await _spBackendDataSource.fetchSearchWordResults(searchString);
    final products = spFdcWordResponse
        .map(_tryMapSupabaseFood)
        .whereType<MealEntity>()
        .where((meal) => (meal.name ?? '').trim().isNotEmpty)
        .toList();
    return products;
  }

  Future<MealEntity> getOFFProductByBarcode(String barcode) async {
    final productResponse = await _offDataSource.fetchBarcodeResults(barcode);

    return MealEntity.fromOFFProduct(productResponse.product);
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
