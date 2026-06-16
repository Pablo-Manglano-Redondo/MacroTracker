import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/add_meal/presentation/bloc/products_bloc.dart';
import 'package:macrotracker/features/add_meal/domain/usecase/search_products_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

void main() {
  late ProductsBloc bloc;
  late _FakeSearchProductsUseCase fakeSearchProductUseCase;
  late _FakeGetConfigUsecase fakeGetConfigUsecase;

  final mealOff = MealEntity(
    code: 'off1',
    name: 'OFF Product',
    url: '',
    mealQuantity: '100',
    mealUnit: 'g',
    servingQuantity: 100,
    servingUnit: 'g',
    servingSize: '1 serving',
    nutriments: MealNutrimentsEntity.empty(),
    source: MealSourceEntity.off,
  );

  final mealFdc = MealEntity(
    code: 'fdc1',
    name: 'FDC Food',
    url: '',
    mealQuantity: '100',
    mealUnit: 'g',
    servingQuantity: 100,
    servingUnit: 'g',
    servingSize: '1 serving',
    nutriments: MealNutrimentsEntity.empty(),
    source: MealSourceEntity.fdc,
  );

  final mealCached = MealEntity(
    code: 'cached1',
    name: 'Cached Product',
    url: '',
    mealQuantity: '100',
    mealUnit: 'g',
    servingQuantity: 100,
    servingUnit: 'g',
    servingSize: '1 serving',
    nutriments: MealNutrimentsEntity.empty(),
    source: MealSourceEntity.custom,
  );

  setUp(() {
    fakeSearchProductUseCase = _FakeSearchProductsUseCase();
    fakeGetConfigUsecase = _FakeGetConfigUsecase();
    bloc = ProductsBloc(fakeSearchProductUseCase, fakeGetConfigUsecase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is ProductsInitial', () {
    expect(bloc.state, isA<ProductsInitial>());
  });

  group('LoadProductsEvent', () {
    test('returns ProductsInitial on empty search string', () async {
      final states = <ProductsState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadProductsEvent(searchString: '   '));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [isA<ProductsInitial>()]);
    });

    test('emits ProductsLoadingState and ProductsLoadedState with OFF products when found', () async {
      fakeSearchProductUseCase.offResults = [mealOff];
      fakeSearchProductUseCase.fdcResults = [mealFdc]; // shouldn't be called because OFF is not empty

      final states = <ProductsState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadProductsEvent(searchString: 'pizza'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ProductsLoadingState>(),
        ProductsLoadedState(products: [mealOff], usesImperialUnits: false),
      ]);
      expect(fakeSearchProductUseCase.offSearchQuery, 'pizza');
      expect(fakeSearchProductUseCase.fdcSearchQuery, isNull);
    });

    test('emits ProductsLoadingState and ProductsLoadedState with FDC products when OFF is empty', () async {
      fakeSearchProductUseCase.offResults = [];
      fakeSearchProductUseCase.fdcResults = [mealFdc];

      final states = <ProductsState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadProductsEvent(searchString: 'pizza'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ProductsLoadingState>(),
        ProductsLoadedState(products: [mealFdc], usesImperialUnits: false),
      ]);
      expect(fakeSearchProductUseCase.offSearchQuery, 'pizza');
      expect(fakeSearchProductUseCase.fdcSearchQuery, 'pizza');
    });

    test('emits ProductsLoadingState and ProductsFailedState on standard exception', () async {
      fakeSearchProductUseCase.shouldThrowStandard = true;

      final states = <ProductsState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadProductsEvent(searchString: 'pizza'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ProductsLoadingState>(),
        isA<ProductsFailedState>(),
      ]);
    });

    test('emits ProductsOfflineState on SocketException and offline search success', () async {
      fakeSearchProductUseCase.shouldThrowSocket = true;
      fakeSearchProductUseCase.cachedResults = [mealCached];

      final states = <ProductsState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadProductsEvent(searchString: 'pizza'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ProductsLoadingState>(),
        ProductsOfflineState(cachedProducts: [mealCached]),
      ]);
      expect(fakeSearchProductUseCase.offlineSearchQuery, 'pizza');
    });

    test('emits ProductsFailedState on SocketException and offline search failure', () async {
      fakeSearchProductUseCase.shouldThrowSocket = true;
      fakeSearchProductUseCase.shouldThrowOnOffline = true;

      final states = <ProductsState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadProductsEvent(searchString: 'pizza'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ProductsLoadingState>(),
        isA<ProductsFailedState>(),
      ]);
    });
  });

  group('RefreshProductsEvent', () {
    test('emits ProductsInitial if no search string was loaded', () async {
      final states = <ProductsState>[];
      bloc.stream.listen(states.add);

      bloc.add(const RefreshProductsEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [isA<ProductsInitial>()]);
    });

    test('emits ProductsLoadingState and ProductsLoadedState using previous search string', () async {
      // First, search for "burger"
      fakeSearchProductUseCase.offResults = [mealOff];
      bloc.add(const LoadProductsEvent(searchString: 'burger'));
      await Future.delayed(const Duration(milliseconds: 10));
      
      // Reset mocks and search again with Refresh
      fakeSearchProductUseCase.offSearchQuery = null;
      fakeSearchProductUseCase.offResults = [mealOff, mealFdc];

      final states = <ProductsState>[];
      bloc.stream.listen(states.add);

      bloc.add(const RefreshProductsEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ProductsLoadingState>(),
        ProductsLoadedState(products: [mealOff, mealFdc], usesImperialUnits: false),
      ]);
      expect(fakeSearchProductUseCase.offSearchQuery, 'burger');
    });
  });
}

class _FakeSearchProductsUseCase implements SearchProductsUseCase {
  List<MealEntity> offResults = [];
  List<MealEntity> fdcResults = [];
  List<MealEntity> cachedResults = [];
  
  String? offSearchQuery;
  String? fdcSearchQuery;
  String? offlineSearchQuery;

  bool shouldThrowStandard = false;
  bool shouldThrowSocket = false;
  bool shouldThrowOnOffline = false;

  @override
  Future<List<MealEntity>> searchOFFProductsByString(String searchString) async {
    offSearchQuery = searchString;
    if (shouldThrowStandard) {
      throw Exception('General database error');
    }
    if (shouldThrowSocket) {
      throw const SocketException('No Internet Connection');
    }
    return offResults;
  }

  @override
  Future<List<MealEntity>> searchFDCFoodByString(String searchString) async {
    fdcSearchQuery = searchString;
    if (shouldThrowStandard) {
      throw Exception('General database error');
    }
    if (shouldThrowSocket) {
      throw const SocketException('No Internet Connection');
    }
    return fdcResults;
  }

  @override
  Future<List<MealEntity>> searchOfflineCache(String searchString) async {
    offlineSearchQuery = searchString;
    if (shouldThrowOnOffline) {
      throw Exception('Cache database error');
    }
    return cachedResults;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetConfigUsecase implements GetConfigUsecase {
  ConfigEntity config = const ConfigEntity(
    true,
    true,
    true,
    AppThemeEntity.system,
    usesImperialUnits: false,
  );

  @override
  Future<ConfigEntity> getConfig() async => config;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
