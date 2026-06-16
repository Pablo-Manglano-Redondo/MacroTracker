import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/physical_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/delete_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/delete_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/update_intake_usecase.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';

void main() {
  late CalendarDayBloc bloc;
  late _FakeGetUserActivityUsecase fakeGetUserActivityUsecase;
  late _FakeGetIntakeUsecase fakeGetIntakeUsecase;
  late _FakeDeleteIntakeUsecase fakeDeleteIntakeUsecase;
  late _FakeDeleteUserActivityUsecase fakeDeleteUserActivityUsecase;
  late _FakeUpdateIntakeUsecase fakeUpdateIntakeUsecase;
  late _FakeGetTrackedDayUsecase fakeGetTrackedDayUsecase;
  late _FakeAddTrackedDayUsecase fakeAddTrackedDayUsecase;
  late _FakeGetGymTargetsUsecase fakeGetGymTargetsUsecase;
  late _FakeDiaryBloc fakeDiaryBloc;
  late _FakeBuildContext fakeContext;

  final testDay = DateTime(2026, 6, 15);

  setUp(() {
    fakeGetUserActivityUsecase = _FakeGetUserActivityUsecase();
    fakeGetIntakeUsecase = _FakeGetIntakeUsecase();
    fakeDeleteIntakeUsecase = _FakeDeleteIntakeUsecase();
    fakeDeleteUserActivityUsecase = _FakeDeleteUserActivityUsecase();
    fakeUpdateIntakeUsecase = _FakeUpdateIntakeUsecase();
    fakeGetTrackedDayUsecase = _FakeGetTrackedDayUsecase();
    fakeAddTrackedDayUsecase = _FakeAddTrackedDayUsecase();
    fakeGetGymTargetsUsecase = _FakeGetGymTargetsUsecase();
    fakeDiaryBloc = _FakeDiaryBloc();
    fakeContext = _FakeBuildContext();

    bloc = CalendarDayBloc(
      fakeGetUserActivityUsecase,
      fakeGetIntakeUsecase,
      fakeDeleteIntakeUsecase,
      fakeDeleteUserActivityUsecase,
      fakeUpdateIntakeUsecase,
      fakeGetTrackedDayUsecase,
      fakeAddTrackedDayUsecase,
    );

    // Register locator dependencies needed for BLoC-to-BLoC communication and helper syncs
    locator.registerSingleton<GetGymTargetsUsecase>(fakeGetGymTargetsUsecase);
    locator.registerSingleton<DiaryBloc>(fakeDiaryBloc);
    locator.registerSingleton<CalendarDayBloc>(bloc);
  });

  tearDown(() async {
    await bloc.close();
    await fakeDiaryBloc.close();
    await locator.reset();
  });

  test('initial state is CalendarDayInitial', () {
    expect(bloc.state, isA<CalendarDayInitial>());
  });

  group('LoadCalendarDayEvent and RefreshCalendarDayEvent', () {
    test('LoadCalendarDayEvent emits loading and loaded with correct data', () async {
      final mockTrackedDay = TrackedDayEntity(
        day: testDay,
        calorieGoal: 2000,
        caloriesTracked: 1500,
      );
      final mockActivity = _makeActivity('act1', 30.0, 200.0, testDay);
      final mockBreakfast = _makeIntake('intake_bf', 100, 100, carbs100: 20, fat100: 2, protein100: 5);

      fakeGetTrackedDayUsecase.trackedDay = mockTrackedDay;
      fakeGetUserActivityUsecase.activities = [mockActivity];
      fakeGetIntakeUsecase.breakfast = [mockBreakfast];

      final states = <CalendarDayState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadCalendarDayEvent(testDay));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<CalendarDayLoading>(),
        isA<CalendarDayLoaded>(),
      ]);

      final loadedState = states.last as CalendarDayLoaded;
      expect(loadedState.trackedDayEntity, mockTrackedDay);
      expect(loadedState.userActivityList, [mockActivity]);
      expect(loadedState.breakfastIntakeList, [mockBreakfast]);
      expect(loadedState.lunchIntakeList, isEmpty);
      expect(loadedState.dinnerIntakeList, isEmpty);
      expect(loadedState.snackIntakeList, isEmpty);
    });

    test('RefreshCalendarDayEvent does nothing if no day has been loaded yet', () async {
      final states = <CalendarDayState>[];
      bloc.stream.listen(states.add);

      bloc.add(const RefreshCalendarDayEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, isEmpty);
    });

    test('RefreshCalendarDayEvent reloads data if a day was previously loaded', () async {
      final mockTrackedDay = TrackedDayEntity(
        day: testDay,
        calorieGoal: 2000,
        caloriesTracked: 1500,
      );
      fakeGetTrackedDayUsecase.trackedDay = mockTrackedDay;

      bloc.add(LoadCalendarDayEvent(testDay));
      await Future.delayed(const Duration(milliseconds: 10));

      final states = <CalendarDayState>[];
      bloc.stream.listen(states.add);

      bloc.add(const RefreshCalendarDayEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<CalendarDayLoading>(),
        isA<CalendarDayLoaded>(),
      ]);

      final loadedState = states.last as CalendarDayLoaded;
      expect(loadedState.trackedDayEntity, mockTrackedDay);
    });
  });

  group('deleteIntakeItem', () {
    test('deletes the intake and removes calories/macros from tracked day', () async {
      final intake = _makeIntake('intake_bf', 150, 100, carbs100: 20, fat100: 2, protein100: 5);

      await bloc.deleteIntakeItem(fakeContext, intake, testDay);

      expect(fakeDeleteIntakeUsecase.deletedIntake, intake);
      expect(fakeAddTrackedDayUsecase.removedCalories, intake.totalKcal);
      expect(fakeAddTrackedDayUsecase.removedCarbs, intake.totalCarbsGram);
      expect(fakeAddTrackedDayUsecase.removedFat, intake.totalFatsGram);
      expect(fakeAddTrackedDayUsecase.removedProtein, intake.totalProteinsGram);
    });
  });

  group('deleteUserActivityItem', () {
    test('deletes the activity, updates diary year, and refreshes calendar day', () async {
      final activity = _makeActivity('act1', 30.0, 200.0, testDay);

      // Load the day first to populate _currentDay
      bloc.add(LoadCalendarDayEvent(testDay));
      await Future.delayed(const Duration(milliseconds: 10));

      fakeAddTrackedDayUsecase.hasDay = true;

      await bloc.deleteUserActivityItem(fakeContext, activity, testDay);

      expect(fakeDeleteUserActivityUsecase.deletedActivity, activity);
      expect(fakeGetGymTargetsUsecase.getTargetsForDayCalled, true);
      expect(fakeAddTrackedDayUsecase.updatedCalorieGoal, 2000);
      expect(fakeAddTrackedDayUsecase.updatedCarbsGoal, 200);
      expect(fakeAddTrackedDayUsecase.updatedFatGoal, 50);
      expect(fakeAddTrackedDayUsecase.updatedProteinGoal, 150);

      // Should update diary year and refresh current day
      expect(fakeDiaryBloc.addedEvents, [const LoadDiaryYearEvent()]);
    });

    test('deletes the activity but skips target sync if hasTrackedDay is false', () async {
      final activity = _makeActivity('act1', 30.0, 200.0, testDay);

      // Load the day first to populate _currentDay
      bloc.add(LoadCalendarDayEvent(testDay));
      await Future.delayed(const Duration(milliseconds: 10));

      fakeAddTrackedDayUsecase.hasDay = false;

      await bloc.deleteUserActivityItem(fakeContext, activity, testDay);

      expect(fakeDeleteUserActivityUsecase.deletedActivity, activity);
      expect(fakeGetGymTargetsUsecase.getTargetsForDayCalled, false);
      expect(fakeAddTrackedDayUsecase.updatedCalorieGoal, isNull);

      expect(fakeDiaryBloc.addedEvents, [const LoadDiaryYearEvent()]);
    });
  });

  group('updateIntakeAmount', () {
    test('does nothing if updatedIntake returns null', () async {
      final intake = _makeIntake('intake_bf', 100, 100, carbs100: 20, fat100: 2, protein100: 5);

      fakeUpdateIntakeUsecase.updatedResult = null;

      await bloc.updateIntakeAmount(intake, testDay, 150);

      expect(fakeUpdateIntakeUsecase.lastUpdatedId, intake.id);
      expect(fakeUpdateIntakeUsecase.lastFields, {'amount': 150.0});
      expect(fakeAddTrackedDayUsecase.addedCalories, 0);
      expect(fakeAddTrackedDayUsecase.removedCalories, 0);
    });

    test('sanitizes amount to 0.1 if newAmount <= 0', () async {
      final intake = _makeIntake('intake_bf', 100, 100, carbs100: 20, fat100: 2, protein100: 5);
      fakeUpdateIntakeUsecase.updatedResult = null;

      await bloc.updateIntakeAmount(intake, testDay, 0.0);

      expect(fakeUpdateIntakeUsecase.lastFields, {'amount': 0.1});
    });

    test('adds calories and macros if delta is positive', () async {
      final intake = _makeIntake('intake_bf', 100, 100, carbs100: 20, fat100: 2, protein100: 5);
      final updated = _makeIntake('intake_bf', 150, 100, carbs100: 20, fat100: 2, protein100: 5);

      fakeUpdateIntakeUsecase.updatedResult = updated;

      await bloc.updateIntakeAmount(intake, testDay, 150);

      final kcalDelta = updated.totalKcal - intake.totalKcal;
      final carbsDelta = updated.totalCarbsGram - intake.totalCarbsGram;
      final fatDelta = updated.totalFatsGram - intake.totalFatsGram;
      final proteinDelta = updated.totalProteinsGram - intake.totalProteinsGram;

      expect(kcalDelta, greaterThan(0));
      expect(fakeAddTrackedDayUsecase.addedCalories, kcalDelta);
      expect(fakeAddTrackedDayUsecase.addedCarbs, carbsDelta);
      expect(fakeAddTrackedDayUsecase.addedFat, fatDelta);
      expect(fakeAddTrackedDayUsecase.addedProtein, proteinDelta);
      expect(fakeAddTrackedDayUsecase.removedCalories, 0);
    });

    test('removes calories and macros if delta is negative', () async {
      final intake = _makeIntake('intake_bf', 150, 100, carbs100: 20, fat100: 2, protein100: 5);
      final updated = _makeIntake('intake_bf', 100, 100, carbs100: 20, fat100: 2, protein100: 5);

      fakeUpdateIntakeUsecase.updatedResult = updated;

      await bloc.updateIntakeAmount(intake, testDay, 100);

      final kcalDelta = updated.totalKcal - intake.totalKcal;
      final carbsDelta = updated.totalCarbsGram - intake.totalCarbsGram;
      final fatDelta = updated.totalFatsGram - intake.totalFatsGram;
      final proteinDelta = updated.totalProteinsGram - intake.totalProteinsGram;

      expect(kcalDelta, lessThan(0));
      expect(fakeAddTrackedDayUsecase.removedCalories, -kcalDelta);
      expect(fakeAddTrackedDayUsecase.removedCarbs, -carbsDelta);
      expect(fakeAddTrackedDayUsecase.removedFat, -fatDelta);
      expect(fakeAddTrackedDayUsecase.removedProtein, -proteinDelta);
      expect(fakeAddTrackedDayUsecase.addedCalories, 0);
    });
  });
}

IntakeEntity _makeIntake(
  String id,
  double amount,
  double kcal100, {
  double carbs100 = 0,
  double fat100 = 0,
  double protein100 = 0,
}) {
  return IntakeEntity(
    id: id,
    unit: 'g',
    amount: amount,
    type: IntakeTypeEntity.breakfast,
    meal: MealEntity(
      code: id,
      name: 'Meal $id',
      brands: null,
      thumbnailImageUrl: null,
      mainImageUrl: null,
      url: null,
      mealQuantity: '100',
      mealUnit: 'g',
      servingQuantity: null,
      servingUnit: 'g',
      servingSize: null,
      nutriments: MealNutrimentsEntity(
        energyKcal100: kcal100,
        carbohydrates100: carbs100,
        fat100: fat100,
        proteins100: protein100,
        sugars100: null,
        saturatedFat100: null,
        fiber100: null,
      ),
      source: MealSourceEntity.custom,
    ),
    dateTime: DateTime.now(),
  );
}

UserActivityEntity _makeActivity(
  String id,
  double duration,
  double burnedKcal,
  DateTime date,
) {
  return UserActivityEntity(
    id,
    duration,
    burnedKcal,
    date,
    const PhysicalActivityEntity(
      '01015',
      'cycling',
      'cycling desc',
      6.0,
      [],
      PhysicalActivityTypeEntity.bicycling,
    ),
  );
}

class _FakeGetUserActivityUsecase implements GetUserActivityUsecase {
  List<UserActivityEntity> activities = [];

  @override
  Future<List<UserActivityEntity>> getUserActivityByDay(DateTime day) async {
    return activities;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetIntakeUsecase implements GetIntakeUsecase {
  List<IntakeEntity> breakfast = [];
  List<IntakeEntity> lunch = [];
  List<IntakeEntity> dinner = [];
  List<IntakeEntity> snack = [];

  @override
  Future<List<IntakeEntity>> getBreakfastIntakeByDay(dynamic day) async => breakfast;

  @override
  Future<List<IntakeEntity>> getLunchIntakeByDay(dynamic day) async => lunch;

  @override
  Future<List<IntakeEntity>> getDinnerIntakeByDay(dynamic day) async => dinner;

  @override
  Future<List<IntakeEntity>> getSnackIntakeByDay(dynamic day) async => snack;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDeleteIntakeUsecase implements DeleteIntakeUsecase {
  IntakeEntity? deletedIntake;

  @override
  Future<void> deleteIntake(IntakeEntity intakeEntity) async {
    deletedIntake = intakeEntity;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDeleteUserActivityUsecase implements DeleteUserActivityUsecase {
  UserActivityEntity? deletedActivity;

  @override
  Future<void> deleteUserActivity(UserActivityEntity entity) async {
    deletedActivity = entity;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUpdateIntakeUsecase implements UpdateIntakeUsecase {
  IntakeEntity? updatedResult;
  String? lastUpdatedId;
  Map<String, dynamic>? lastFields;

  @override
  Future<IntakeEntity?> updateIntake(String id, Map<String, dynamic> fields) async {
    lastUpdatedId = id;
    lastFields = fields;
    return updatedResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetTrackedDayUsecase implements GetTrackedDayUsecase {
  TrackedDayEntity? trackedDay;

  @override
  Future<TrackedDayEntity?> getTrackedDay(DateTime day) async => trackedDay;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddTrackedDayUsecase implements AddTrackedDayUsecase {
  bool hasDay = false;
  double? updatedCalorieGoal;
  double? updatedCarbsGoal;
  double? updatedFatGoal;
  double? updatedProteinGoal;

  double addedCalories = 0;
  double removedCalories = 0;

  double addedCarbs = 0;
  double addedFat = 0;
  double addedProtein = 0;

  double removedCarbs = 0;
  double removedFat = 0;
  double removedProtein = 0;

  @override
  Future<bool> hasTrackedDay(DateTime day) async => hasDay;

  @override
  Future<void> updateDayCalorieGoal(DateTime day, double goal) async {
    updatedCalorieGoal = goal;
  }

  @override
  Future<void> updateDayMacroGoals(
    DateTime day, {
    double? carbsGoal,
    double? fatGoal,
    double? proteinGoal,
  }) async {
    updatedCarbsGoal = carbsGoal;
    updatedFatGoal = fatGoal;
    updatedProteinGoal = proteinGoal;
  }

  @override
  Future<void> addDayCaloriesTracked(DateTime day, double kcal) async {
    addedCalories += kcal;
  }

  @override
  Future<void> removeDayCaloriesTracked(DateTime day, double kcal) async {
    removedCalories += kcal;
  }

  @override
  Future<void> addDayMacrosTracked(
    DateTime day, {
    double? carbsTracked,
    double? fatTracked,
    double? proteinTracked,
  }) async {
    addedCarbs += carbsTracked ?? 0;
    addedFat += fatTracked ?? 0;
    addedProtein += proteinTracked ?? 0;
  }

  @override
  Future<void> removeDayMacrosTracked(
    DateTime day, {
    double? carbsTracked,
    double? fatTracked,
    double? proteinTracked,
  }) async {
    removedCarbs += carbsTracked ?? 0;
    removedFat += fatTracked ?? 0;
    removedProtein += proteinTracked ?? 0;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetGymTargetsUsecase implements GetGymTargetsUsecase {
  bool getTargetsForDayCalled = false;
  GymTargetsEntity targets = const GymTargetsEntity(
    kcalGoal: 2000,
    carbsGoal: 200,
    fatGoal: 50,
    proteinGoal: 150,
  );

  @override
  Future<GymTargetsEntity> getTargetsForDay(
    DateTime day, {
    UserEntity? userEntity,
    UserWeightGoalEntity? phase,
    DailyFocusEntity? dailyFocus,
    double? totalKcalActivities,
  }) async {
    getTargetsForDayCalled = true;
    return targets;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDiaryBloc extends Bloc<DiaryEvent, DiaryState> implements DiaryBloc {
  final List<DiaryEvent> addedEvents = [];

  _FakeDiaryBloc() : super(DiaryInitial());

  @override
  void add(DiaryEvent event) {
    addedEvents.add(event);
  }

  @override
  DateTime get currentDay => DateTime.now();

  @override
  set currentDay(DateTime val) {}

  @override
  void updateHomePage() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
