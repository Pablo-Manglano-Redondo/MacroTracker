import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/add_meal/presentation/bloc/recent_meal_bloc.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

void main() {
  late RecentMealBloc bloc;
  late _FakeGetIntakeUsecase fakeGetIntakeUsecase;
  late _FakeGetConfigUsecase fakeGetConfigUsecase;

  final mealApple = MealEntity(
    code: '1',
    name: 'Apple Pie',
    brands: 'McDonalds',
    url: '',
    mealQuantity: '100',
    mealUnit: 'g',
    servingQuantity: 100,
    servingUnit: 'g',
    servingSize: '1 slice',
    nutriments: MealNutrimentsEntity.empty(),
    source: MealSourceEntity.custom,
  );

  final mealBanana = MealEntity(
    code: '2',
    name: 'Banana Cake',
    brands: 'Bakery',
    url: '',
    mealQuantity: '150',
    mealUnit: 'g',
    servingQuantity: 150,
    servingUnit: 'g',
    servingSize: '1 piece',
    nutriments: MealNutrimentsEntity.empty(),
    source: MealSourceEntity.custom,
  );

  final intake1 = IntakeEntity(
    id: 'i1',
    unit: 'g',
    amount: 100,
    type: IntakeTypeEntity.breakfast,
    meal: mealApple,
    dateTime: DateTime(2026, 6, 15),
  );

  final intake2 = IntakeEntity(
    id: 'i2',
    unit: 'g',
    amount: 150,
    type: IntakeTypeEntity.lunch,
    meal: mealBanana,
    dateTime: DateTime(2026, 6, 15),
  );

  setUp(() {
    fakeGetIntakeUsecase = _FakeGetIntakeUsecase();
    fakeGetConfigUsecase = _FakeGetConfigUsecase();
    bloc = RecentMealBloc(fakeGetIntakeUsecase, fakeGetConfigUsecase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is RecentMealInitial', () {
    expect(bloc.state, isA<RecentMealInitial>());
  });

  group('LoadRecentMealEvent', () {
    test('emits RecentMealLoadingState and RecentMealLoadedState with all meals when search string is empty', () async {
      fakeGetConfigUsecase.config = const ConfigEntity(
        true,
        true,
        true,
        AppThemeEntity.system,
        usesImperialUnits: true,
      );
      fakeGetIntakeUsecase.recentIntakes = [intake1, intake2];

      final states = <RecentMealState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadRecentMealEvent(searchString: ''));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<RecentMealLoadingState>(),
        RecentMealLoadedState(
          recentMeals: [mealApple, mealBanana],
          usesImperialUnits: true,
        ),
      ]);
    });

    test('emits RecentMealLoadingState and RecentMealLoadedState with filtered meals based on meal name', () async {
      fakeGetIntakeUsecase.recentIntakes = [intake1, intake2];

      final states = <RecentMealState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadRecentMealEvent(searchString: 'apple'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<RecentMealLoadingState>(),
        RecentMealLoadedState(
          recentMeals: [mealApple],
          usesImperialUnits: false,
        ),
      ]);
    });

    test('emits RecentMealLoadingState and RecentMealLoadedState with filtered meals based on brand', () async {
      fakeGetIntakeUsecase.recentIntakes = [intake1, intake2];

      final states = <RecentMealState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadRecentMealEvent(searchString: 'bakery'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<RecentMealLoadingState>(),
        RecentMealLoadedState(
          recentMeals: [mealBanana],
          usesImperialUnits: false,
        ),
      ]);
    });

    test('emits RecentMealLoadingState and RecentMealFailedState on exception', () async {
      fakeGetIntakeUsecase.shouldThrow = true;

      final states = <RecentMealState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadRecentMealEvent(searchString: ''));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<RecentMealLoadingState>(),
        isA<RecentMealFailedState>(),
      ]);
    });
  });
}

class _FakeGetIntakeUsecase implements GetIntakeUsecase {
  List<IntakeEntity> recentIntakes = [];
  bool shouldThrow = false;

  @override
  Future<List<IntakeEntity>> getRecentIntake() async {
    if (shouldThrow) {
      throw Exception('Database error');
    }
    return recentIntakes;
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
