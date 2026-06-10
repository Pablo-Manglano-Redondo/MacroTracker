import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/scanner/data/product_not_found_exception.dart';
import 'package:macrotracker/features/scanner/domain/usecase/search_product_by_barcode_usecase.dart';
import 'package:macrotracker/features/scanner/presentation/bloc/scanner_bloc.dart';

void main() {
  late ScannerBloc bloc;
  late _FakeSearchProductByBarcodeUsecase fakeSearch;
  late _FakeGetConfigUsecase fakeConfig;

  setUp(() {
    fakeSearch = _FakeSearchProductByBarcodeUsecase();
    fakeConfig = _FakeGetConfigUsecase();
    bloc = ScannerBloc(fakeSearch, fakeConfig);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is ScannerInitial', () {
    expect(bloc.state, isA<ScannerInitial>());
  });

  group('ScannerLoadProductEvent', () {
    test('emits [ScannerLoadingState, ScannerLoadedState] on success', () async {
      fakeSearch.result = MealEntity(
        code: '123456789',
        name: 'Test Product',
        brands: 'TestBrand',
        url: null,
        mealQuantity: '100',
        mealUnit: 'g',
        servingQuantity: null,
        servingUnit: 'g',
        servingSize: null,
        nutriments: const MealNutrimentsEntity(
          energyKcal100: 250,
          carbohydrates100: 30,
          fat100: 10,
          proteins100: 12,
          sugars100: null,
          saturatedFat100: null,
          fiber100: null,
        ),
        source: MealSourceEntity.off,
      );

      final states = <Type>[];
      bloc.stream.listen((state) => states.add(state.runtimeType));

      bloc.add(const ScannerLoadProductEvent(barcode: '123456789'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, contains(ScannerLoadingState));
      expect(states, contains(ScannerLoadedState));

      final finalState = bloc.state;
      expect(finalState, isA<ScannerLoadedState>());
      expect((finalState as ScannerLoadedState).product.code, '123456789');
      expect((finalState).product.name, 'Test Product');
    });

    test('emits ScannerFailedState(productNotFound) when product not found',
        () async {
      fakeSearch.errorToThrow = ProductNotFoundException();

      bloc.add(const ScannerLoadProductEvent(barcode: '000000000'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(bloc.state, isA<ScannerFailedState>());
      expect((bloc.state as ScannerFailedState).type,
          ScannerFailedStateType.productNotFound);
    });

    test('emits ScannerFailedState(error) on generic exception', () async {
      fakeSearch.errorToThrow = Exception('Network error');

      bloc.add(const ScannerLoadProductEvent(barcode: '999999999'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(bloc.state, isA<ScannerFailedState>());
      expect((bloc.state as ScannerFailedState).type,
          ScannerFailedStateType.error);
    });
  });

  group('ScannerResetEvent', () {
    test('resets to initial state', () async {
      fakeSearch.result = MealEntity(
        code: '1', name: 'P', brands: null, url: null,
        mealQuantity: '100', mealUnit: 'g',
        servingQuantity: null, servingUnit: 'g', servingSize: null,
        nutriments: const MealNutrimentsEntity(
          energyKcal100: 100,
          carbohydrates100: 10,
          fat100: 5,
          proteins100: 5,
          sugars100: null,
          saturatedFat100: null,
          fiber100: null,
        ),
        source: MealSourceEntity.custom,
      );

      bloc.add(const ScannerLoadProductEvent(barcode: '1'));
      await Future.delayed(const Duration(milliseconds: 10));
      expect(bloc.state, isA<ScannerLoadedState>());

      bloc.add(ScannerResetEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(bloc.state, isA<ScannerInitial>());
    });
  });
}

class _FakeSearchProductByBarcodeUsecase
    implements SearchProductByBarcodeUseCase {
  MealEntity? result;
  Object? errorToThrow;

  @override
  Future<MealEntity> searchProductByBarcode(String barcode) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return result!;
  }
}

class _FakeGetConfigUsecase implements GetConfigUsecase {
  @override
  Future<ConfigEntity> getConfig() async =>
      const ConfigEntity(true, true, true, AppThemeEntity.system);
}
