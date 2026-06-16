import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/meal_detail/presentation/bloc/meal_detail_bloc.dart';
import 'package:macrotracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';

void main() {
  late MealDetailBloc bloc;
  late _FakeAddIntakeUsecase fakeAddIntakeUsecase;
  late _FakeAddTrackedDayUsecase fakeAddTrackedDayUsecase;
  late _FakeGetGymTargetsUsecase fakeGetGymTargetsUsecase;
  late _FakeBuildContext fakeContext;

  final testMeal = MealEntity(
    code: '123',
    name: 'Apple',
    url: '',
    mealQuantity: '100',
    mealUnit: 'g',
    servingQuantity: 150,
    servingUnit: 'g',
    servingSize: '1 medium',
    nutriments: const MealNutrimentsEntity(
      energyKcal100: 52,
      carbohydrates100: 14,
      fat100: 0.2,
      proteins100: 0.3,
      sugars100: 10,
      saturatedFat100: 0.05,
      fiber100: 2.4,
    ),
    source: MealSourceEntity.custom,
  );

  setUp(() {
    fakeAddIntakeUsecase = _FakeAddIntakeUsecase();
    fakeAddTrackedDayUsecase = _FakeAddTrackedDayUsecase();
    fakeGetGymTargetsUsecase = _FakeGetGymTargetsUsecase();
    fakeContext = _FakeBuildContext();

    bloc = MealDetailBloc(
      fakeAddIntakeUsecase,
      fakeAddTrackedDayUsecase,
      fakeGetGymTargetsUsecase,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is correct', () {
    expect(bloc.state.totalQuantityConverted, '100');
    expect(bloc.state.selectedUnit, 'g/ml');
    expect(bloc.state.totalKcal, 0);
  });

  group('UpdateKcalEvent', () {
    test('calculates correct values for unit: g', () async {
      final states = <MealDetailState>[];
      bloc.stream.listen(states.add);

      bloc.add(UpdateKcalEvent(
        meal: testMeal,
        totalQuantity: '200',
        selectedUnit: 'g',
      ));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states.length, 1);
      final state = states.first;
      expect(state.totalQuantityConverted, '200.0');
      expect(state.selectedUnit, 'g');
      // 52 kcal per 100g -> 104 kcal for 200g
      expect(state.totalKcal, 104.0);
      expect(state.totalCarbs, closeTo(28.0, 0.01));
      expect(state.totalFat, closeTo(0.4, 0.01));
      expect(state.totalProtein, closeTo(0.6, 0.01));
    });

    test('supports commas in quantity text', () async {
      final states = <MealDetailState>[];
      bloc.stream.listen(states.add);

      bloc.add(UpdateKcalEvent(
        meal: testMeal,
        totalQuantity: '150,5',
        selectedUnit: 'g',
      ));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states.length, 1);
      expect(double.parse(states.first.totalQuantityConverted), closeTo(150.5, 0.01));
    });

    test('handles serving size conversion', () async {
      final states = <MealDetailState>[];
      bloc.stream.listen(states.add);

      bloc.add(UpdateKcalEvent(
        meal: testMeal,
        totalQuantity: '2', // 2 servings
        selectedUnit: 'serving',
      ));
      await Future.delayed(const Duration(milliseconds: 10));

      // servingQuantity is 150g. 2 servings = 300g.
      // 52 kcal per 100g -> 156 kcal for 300g
      expect(states.first.totalQuantityConverted, '300.0');
      expect(states.first.totalKcal, 156.0);
    });

    test('handles oz conversion', () async {
      final states = <MealDetailState>[];
      bloc.stream.listen(states.add);

      bloc.add(UpdateKcalEvent(
        meal: testMeal,
        totalQuantity: '1', // 1 oz
        selectedUnit: 'oz',
      ));
      await Future.delayed(const Duration(milliseconds: 10));

      // 1 oz is 28.3495 g
      expect(double.parse(states.first.totalQuantityConverted), closeTo(28.35, 0.01));
    });

    test('handles fl.oz conversion', () async {
      final states = <MealDetailState>[];
      bloc.stream.listen(states.add);

      bloc.add(UpdateKcalEvent(
        meal: testMeal,
        totalQuantity: '10', // 10 fl.oz
        selectedUnit: 'fl.oz',
      ));
      await Future.delayed(const Duration(milliseconds: 10));

      // 1 fl.oz is 29.5735 ml -> 10 fl.oz is 295.735 ml
      expect(double.parse(states.first.totalQuantityConverted), closeTo(295.735, 0.01));
    });

    test('returns early on empty quantity', () async {
      final states = <MealDetailState>[];
      bloc.stream.listen(states.add);

      bloc.add(UpdateKcalEvent(
        meal: testMeal,
        totalQuantity: '',
        selectedUnit: 'g',
      ));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states.isEmpty, true);
    });

    test('handles parse exception gracefully', () async {
      final states = <MealDetailState>[];
      bloc.stream.listen(states.add);

      bloc.add(UpdateKcalEvent(
        meal: testMeal,
        totalQuantity: 'not a number',
        selectedUnit: 'g',
      ));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states.isEmpty, true); // no state emitted due to try-catch
    });
  });

  group('addIntake', () {
    final testDay = DateTime(2026, 6, 15);

    test('saves intake and updates existing tracked day', () async {
      fakeAddTrackedDayUsecase.hasTrackedDayResult = true;

      bloc.addIntake(
        fakeContext,
        'g',
        '200',
        IntakeTypeEntity.breakfast,
        testMeal,
        testDay,
      );

      await Future.delayed(const Duration(milliseconds: 15));

      // Check intake was saved
      expect(fakeAddIntakeUsecase.addedIntake, isNotNull);
      expect(fakeAddIntakeUsecase.addedIntake!.amount, 200.0);
      expect(fakeAddIntakeUsecase.addedIntake!.meal, testMeal);
      expect(fakeAddIntakeUsecase.addedIntake!.type, IntakeTypeEntity.breakfast);

      // Check tracked day update
      expect(fakeAddTrackedDayUsecase.checkedDay, testDay);
      // It should NOT call addNewTrackedDay since hasTrackedDayResult = true
      expect(fakeAddTrackedDayUsecase.addedDay, isNull);
      
      // But it should add tracked calories and macros
      expect(fakeAddTrackedDayUsecase.caloriesTrackedDay, testDay);
      // 52 kcal per 100g * 2 = 104 kcal
      expect(fakeAddTrackedDayUsecase.caloriesTrackedAmount, 104.0);
      expect(fakeAddTrackedDayUsecase.carbsTrackedAmount, closeTo(28.0, 0.01));
      expect(fakeAddTrackedDayUsecase.fatTrackedAmount, closeTo(0.4, 0.01));
      expect(fakeAddTrackedDayUsecase.proteinTrackedAmount, closeTo(0.6, 0.01));
    });

    test('saves intake and creates new tracked day if not present', () async {
      fakeAddTrackedDayUsecase.hasTrackedDayResult = false;
      fakeGetGymTargetsUsecase.returnedTargets = const GymTargetsEntity(
        kcalGoal: 2500,
        carbsGoal: 300,
        fatGoal: 80,
        proteinGoal: 180,
      );

      bloc.addIntake(
        fakeContext,
        'g',
        '100',
        IntakeTypeEntity.lunch,
        testMeal,
        testDay,
      );

      await Future.delayed(const Duration(milliseconds: 15));

      // Check new tracked day was created
      expect(fakeAddTrackedDayUsecase.addedDay, testDay);
      expect(fakeAddTrackedDayUsecase.addedKcalGoal, 2500.0);
      expect(fakeAddTrackedDayUsecase.addedCarbsGoal, 300.0);
      expect(fakeAddTrackedDayUsecase.addedFatGoal, 80.0);
      expect(fakeAddTrackedDayUsecase.addedProteinGoal, 180.0);

      // And it should add tracked calories and macros
      expect(fakeAddTrackedDayUsecase.caloriesTrackedDay, testDay);
      expect(fakeAddTrackedDayUsecase.caloriesTrackedAmount, 52.0);
    });
  });
}

class _FakeAddIntakeUsecase implements AddIntakeUsecase {
  IntakeEntity? addedIntake;

  @override
  Future<void> addIntake(IntakeEntity intakeEntity) async {
    addedIntake = intakeEntity;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddTrackedDayUsecase implements AddTrackedDayUsecase {
  bool hasTrackedDayResult = true;
  DateTime? checkedDay;
  
  DateTime? addedDay;
  double? addedKcalGoal;
  double? addedCarbsGoal;
  double? addedFatGoal;
  double? addedProteinGoal;

  DateTime? caloriesTrackedDay;
  double? caloriesTrackedAmount;

  DateTime? macrosTrackedDay;
  double? carbsTrackedAmount;
  double? fatTrackedAmount;
  double? proteinTrackedAmount;

  @override
  Future<bool> hasTrackedDay(DateTime day) async {
    checkedDay = day;
    return hasTrackedDayResult;
  }

  @override
  Future<void> addNewTrackedDay(
    DateTime day,
    double totalKcalGoal,
    double totalCarbsGoal,
    double totalFatGoal,
    double totalProteinGoal,
  ) async {
    addedDay = day;
    addedKcalGoal = totalKcalGoal;
    addedCarbsGoal = totalCarbsGoal;
    addedFatGoal = totalFatGoal;
    addedProteinGoal = totalProteinGoal;
  }

  @override
  Future<void> addDayCaloriesTracked(DateTime day, double caloriesTracked) async {
    caloriesTrackedDay = day;
    caloriesTrackedAmount = caloriesTracked;
  }

  @override
  Future<void> addDayMacrosTracked(
    DateTime day, {
    double? carbsTracked,
    double? fatTracked,
    double? proteinTracked,
  }) async {
    macrosTrackedDay = day;
    carbsTrackedAmount = carbsTracked;
    fatTrackedAmount = fatTracked;
    proteinTrackedAmount = proteinTracked;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetGymTargetsUsecase implements GetGymTargetsUsecase {
  GymTargetsEntity returnedTargets = const GymTargetsEntity(
    kcalGoal: 2000,
    carbsGoal: 200,
    fatGoal: 70,
    proteinGoal: 150,
  );
  DateTime? requestedDay;

  @override
  Future<GymTargetsEntity> getTargetsForDay(
    DateTime day, {
    dynamic userEntity,
    dynamic phase,
    dynamic dailyFocus,
    double? totalKcalActivities,
  }) async {
    requestedDay = day;
    return returnedTargets;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
