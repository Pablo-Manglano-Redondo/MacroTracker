import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/edit_meal/presentation/bloc/edit_meal_bloc.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

void main() {
  late EditMealBloc bloc;
  late _FakeGetConfigUsecase fakeGetConfigUsecase;

  final oldMeal = MealEntity(
    code: '123',
    name: 'Old Name',
    url: 'old_url',
    thumbnailImageUrl: 'old_thumb',
    mainImageUrl: 'old_main',
    mealQuantity: '100',
    mealUnit: 'g',
    servingQuantity: 50,
    servingUnit: 'g',
    servingSize: '50 g',
    nutriments: const MealNutrimentsEntity(
      energyKcal100: 100,
      carbohydrates100: 10,
      fat100: 2,
      proteins100: 5,
      sugars100: 4,
      saturatedFat100: 0.5,
      fiber100: 1,
    ),
    source: MealSourceEntity.custom,
  );

  setUp(() {
    fakeGetConfigUsecase = _FakeGetConfigUsecase();
    bloc = EditMealBloc(fakeGetConfigUsecase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is EditMealInitial', () {
    expect(bloc.state, isA<EditMealInitial>());
  });

  group('InitializeEditMealEvent', () {
    test('emits EditMealLoadingState and EditMealLoadedState with correct config properties', () async {
      fakeGetConfigUsecase.config = const ConfigEntity(
        true,
        true,
        true,
        AppThemeEntity.dark,
        usesImperialUnits: true,
      );

      final states = <EditMealState>[];
      bloc.stream.listen(states.add);

      bloc.add(const InitializeEditMealEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<EditMealLoadingState>(),
        const EditMealLoadedState(usesImperialUnits: true),
      ]);
    });
  });

  group('createNewMealEntity', () {
    test('creates new MealEntity and scales nutriments properly based on baseQuantity (50g)', () {
      // Inputs corresponding to a 50g base quantity portion size
      // oldMeal has sugars100: 4, saturatedFat100: 0.5, fiber100: 1
      final newMeal = bloc.createNewMealEntity(
        oldMeal,
        'New Name',
        'New Brand',
        '200', // mealQuantityText
        '100', // servingQuantityText
        '50',  // baseQuantity (implies multiplier is 100 / 50 = 2)
        'g',   // unitText
        '50',  // kcalText
        '10',  // carbsText
        '2',   // fatText
        '5',   // proteinText
      );

      expect(newMeal.code, oldMeal.code);
      expect(newMeal.name, 'New Name');
      expect(newMeal.brands, 'New Brand');
      expect(newMeal.mealQuantity, '200');
      expect(newMeal.servingQuantity, 100.0);
      expect(newMeal.servingUnit, 'g');
      expect(newMeal.servingSize, '100 g');
      expect(newMeal.source, oldMeal.source);

      // Nutrition per 100g should be multiplied by 2
      expect(newMeal.nutriments.energyKcal100, closeTo(100.0, 0.01));
      expect(newMeal.nutriments.carbohydrates100, closeTo(20.0, 0.01));
      expect(newMeal.nutriments.fat100, closeTo(4.0, 0.01));
      expect(newMeal.nutriments.proteins100, closeTo(10.0, 0.01));
      expect(newMeal.nutriments.sugars100, closeTo(8.0, 0.01));
      expect(newMeal.nutriments.saturatedFat100, closeTo(1.0, 0.01));
      expect(newMeal.nutriments.fiber100, closeTo(2.0, 0.01));
    });

    test('creates new MealEntity and uses factor of 1 if baseQuantity is invalid', () {
      final newMeal = bloc.createNewMealEntity(
        oldMeal,
        'New Name',
        'New Brand',
        '200',
        '100',
        'invalid',  // baseQuantity parses as null, factor defaults to 1
        'g',
        '50',
        '10',
        '2',
        '5',
      );

      // Nutrition should not be scaled (factor = 1)
      expect(newMeal.nutriments.energyKcal100, closeTo(50.0, 0.01));
      expect(newMeal.nutriments.carbohydrates100, closeTo(10.0, 0.01));
      expect(newMeal.nutriments.fat100, closeTo(2.0, 0.01));
      expect(newMeal.nutriments.proteins100, closeTo(5.0, 0.01));
      expect(newMeal.nutriments.sugars100, closeTo(4.0, 0.01));
      expect(newMeal.nutriments.saturatedFat100, closeTo(0.5, 0.01));
      expect(newMeal.nutriments.fiber100, closeTo(1.0, 0.01));
    });

    test('handles empty servingQuantityText and null unitText gracefully', () {
      final newMeal = bloc.createNewMealEntity(
        oldMeal,
        'New Name',
        'New Brand',
        '200',
        '',  // servingQuantityText
        '100',
        null, // unitText
        '50',
        '10',
        '2',
        '5',
      );

      expect(newMeal.servingQuantity, isNull);
      expect(newMeal.servingUnit, isNull);
      expect(newMeal.servingSize, isNull);
    });
  });
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
