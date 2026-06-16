import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/add_meal/presentation/bloc/food_bloc.dart';
import 'package:macrotracker/features/add_meal/domain/usecase/search_products_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

void main() {
  late FoodBloc bloc;
  late _FakeSearchProductsUseCase fakeSearchProductUseCase;
  late _FakeGetConfigUsecase fakeGetConfigUsecase;

  final mealFdc = MealEntity(
    code: 'fdc1',
    name: 'FDC Food Item',
    url: '',
    mealQuantity: '100',
    mealUnit: 'g',
    servingQuantity: 100,
    servingUnit: 'g',
    servingSize: '1 serving',
    nutriments: MealNutrimentsEntity.empty(),
    source: MealSourceEntity.fdc,
  );

  setUp(() {
    fakeSearchProductUseCase = _FakeSearchProductsUseCase();
    fakeGetConfigUsecase = _FakeGetConfigUsecase();
    bloc = FoodBloc(fakeSearchProductUseCase, fakeGetConfigUsecase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is FoodInitial', () {
    expect(bloc.state, isA<FoodInitial>());
  });

  group('LoadFoodEvent', () {
    test('emits FoodLoadingState and FoodLoadedState with FDC products', () async {
      fakeSearchProductUseCase.fdcResults = [mealFdc];

      final states = <FoodState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadFoodEvent(searchString: 'apple'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<FoodLoadingState>(),
        FoodLoadedState(food: [mealFdc], usesImperialUnits: false),
      ]);
      expect(fakeSearchProductUseCase.fdcSearchQuery, 'apple');
    });

    test('emits FoodLoadingState and FoodFailedState on exception', () async {
      fakeSearchProductUseCase.shouldThrow = true;

      final states = <FoodState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadFoodEvent(searchString: 'apple'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<FoodLoadingState>(),
        isA<FoodFailedState>(),
      ]);
    });
  });

  group('RefreshFoodEvent', () {
    test('emits FoodLoadingState and FoodLoadedState using previous search string', () async {
      // First Load
      fakeSearchProductUseCase.fdcResults = [mealFdc];
      bloc.add(const LoadFoodEvent(searchString: 'apple'));
      await Future.delayed(const Duration(milliseconds: 10));

      // Reset mock and call Refresh
      fakeSearchProductUseCase.fdcSearchQuery = null;
      fakeSearchProductUseCase.fdcResults = [mealFdc, mealFdc];

      final states = <FoodState>[];
      bloc.stream.listen(states.add);

      bloc.add(const RefreshFoodEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<FoodLoadingState>(),
        // Note: RefreshFoodState emitted doesn't pass usesImperialUnits parameter (defaults to false)
        FoodLoadedState(food: [mealFdc, mealFdc], usesImperialUnits: false),
      ]);
      expect(fakeSearchProductUseCase.fdcSearchQuery, 'apple');
    });

    test('emits FoodLoadingState and FoodFailedState on exception during Refresh', () async {
      // First Load
      fakeSearchProductUseCase.fdcResults = [mealFdc];
      bloc.add(const LoadFoodEvent(searchString: 'apple'));
      await Future.delayed(const Duration(milliseconds: 10));

      // Enable throw
      fakeSearchProductUseCase.shouldThrow = true;

      final states = <FoodState>[];
      bloc.stream.listen(states.add);

      bloc.add(const RefreshFoodEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<FoodLoadingState>(),
        isA<FoodFailedState>(),
      ]);
    });
  });
}

class _FakeSearchProductsUseCase implements SearchProductsUseCase {
  List<MealEntity> fdcResults = [];
  String? fdcSearchQuery;
  bool shouldThrow = false;

  @override
  Future<List<MealEntity>> searchFDCFoodByString(String searchString) async {
    fdcSearchQuery = searchString;
    if (shouldThrow) {
      throw Exception('FDC service failed');
    }
    return fdcResults;
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
