import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/data/repository/user_repository.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_measurement_entity.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_progress_summary_entity.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/get_body_progress_usecase.dart';
import 'package:macrotracker/features/weekly_insights/domain/usecase/build_weekly_insights_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';

void main() {
  late _FakeGetTrackedDayUsecase fakeGetTrackedDay;
  late _FakeGetIntakeUsecase fakeGetIntake;
  late _FakeGetBodyProgressUsecase fakeGetBodyProgress;
  late _FakeGetUserUsecase fakeGetUser;
  late _FakeGetConfigUsecase fakeGetConfig;
  late BuildWeeklyInsightsUsecase usecase;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await S.load(const Locale('en'));
  });

  setUp(() {
    fakeGetTrackedDay = _FakeGetTrackedDayUsecase();
    fakeGetIntake = _FakeGetIntakeUsecase();
    fakeGetBodyProgress = _FakeGetBodyProgressUsecase();
    fakeGetUser = _FakeGetUserUsecase();
    fakeGetConfig = _FakeGetConfigUsecase();
    usecase = BuildWeeklyInsightsUsecase(
      fakeGetTrackedDay,
      fakeGetIntake,
      fakeGetBodyProgress,
      fakeGetUser,
      fakeGetConfig,
    );
  });

  group('weekStart calculation', () {
    test('returns Monday for a Wednesday', () {
      // We can't access _weekStart directly since it's private,
      // but we can test indirectly via build() with empty data
    });
  });

  group('build() - empty week', () {
    test('returns zero values when no data exists', () async {
      final focusedDate = DateTime(2026, 6, 10); // Wednesday
      fakeGetTrackedDay.trackedDays = [];
      fakeGetIntake.allIntakes = [];
      fakeGetBodyProgress.summary = const BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: null,
        latestWaistCm: null,
        rollingWeightAverageKg: null,
        previousRollingWeightAverageKg: null,
        weeklyWeightDeltaKg: null,
        latestWaistDeltaCm: null,
      );
      fakeGetUser.user = UserEntity(
        birthday: DateTime(2000, 1, 1),
        heightCM: 180,
        weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.active,
      );
      fakeGetConfig.config = const ConfigEntity(true, true, true, AppThemeEntity.system);

      final result = await usecase.build(focusedDate);

      expect(result.trackedDays, 0);
      expect(result.averageCalories, 0);
      expect(result.averageCarbs, 0);
      expect(result.averageFat, 0);
      expect(result.averageProtein, 0);
      expect(result.goalAdherenceRate, 0);
      expect(result.proteinConsistencyRate, 0);
      expect(result.weeklyWeightDeltaKg, 0);
      expect(result.weekStart.weekday, 1); // Monday
    });
  });

  group('build() - with tracked days', () {
    test('calculates averages correctly', () async {
      final monday = DateTime(2026, 6, 1);
      fakeGetTrackedDay.trackedDays = [
        TrackedDayEntity(
          day: monday,
          calorieGoal: 2500,
          caloriesTracked: 2300,
          carbsGoal: 300,
          carbsTracked: 280,
          fatGoal: 70,
          fatTracked: 65,
          proteinGoal: 150,
          proteinTracked: 140,
        ),
        TrackedDayEntity(
          day: monday.add(const Duration(days: 1)),
          calorieGoal: 2500,
          caloriesTracked: 2600,
          carbsGoal: 300,
          carbsTracked: 310,
          fatGoal: 70,
          fatTracked: 68,
          proteinGoal: 150,
          proteinTracked: 155,
        ),
      ];
      fakeGetIntake.allIntakes = [];
      fakeGetBodyProgress.summary = const BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: null,
        latestWaistCm: null,
        rollingWeightAverageKg: null,
        previousRollingWeightAverageKg: null,
        weeklyWeightDeltaKg: null,
        latestWaistDeltaCm: null,
      );
      fakeGetUser.user = UserEntity(
        birthday: DateTime(2000, 1, 1),
        heightCM: 180,
        weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.active,
      );
      fakeGetConfig.config = const ConfigEntity(true, true, true, AppThemeEntity.system);

      final result = await usecase.build(monday);

      expect(result.trackedDays, 2);
      expect(result.averageCalories, closeTo(2450, 1));
      expect(result.averageCarbs, closeTo(295, 1));
      expect(result.averageFat, closeTo(66.5, 0.1));
      expect(result.averageProtein, closeTo(147.5, 0.1));
    });

    test('computes goal adherence rate correctly', () async {
      final monday = DateTime(2026, 6, 1);
      fakeGetTrackedDay.trackedDays = [
        // Within 250 kcal tolerance
        TrackedDayEntity(
          day: monday,
          calorieGoal: 2500,
          caloriesTracked: 2400, // diff 100 -> within tolerance
        ),
        TrackedDayEntity(
          day: monday.add(const Duration(days: 1)),
          calorieGoal: 2500,
          caloriesTracked: 2600, // diff 100 -> within tolerance
        ),
        // Outside tolerance
        TrackedDayEntity(
          day: monday.add(const Duration(days: 2)),
          calorieGoal: 2500,
          caloriesTracked: 3000, // diff 500 -> outside tolerance
        ),
      ];
      fakeGetIntake.allIntakes = [];
      fakeGetBodyProgress.summary = const BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: null,
        latestWaistCm: null,
        rollingWeightAverageKg: null,
        previousRollingWeightAverageKg: null,
        weeklyWeightDeltaKg: null,
        latestWaistDeltaCm: null,
      );
      fakeGetUser.user = UserEntity(
        birthday: DateTime(2000, 1, 1),
        heightCM: 180, weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.active,
      );
      fakeGetConfig.config = const ConfigEntity(true, true, true, AppThemeEntity.system);

      final result = await usecase.build(monday);

      expect(result.goalAdherenceRate, closeTo(2 / 3, 0.01));
    });

    test('computes protein consistency rate correctly', () async {
      final monday = DateTime(2026, 6, 1);
      fakeGetTrackedDay.trackedDays = [
        TrackedDayEntity(
          day: monday,
          calorieGoal: 2500,
          caloriesTracked: 2300,
          proteinGoal: 150,
          proteinTracked: 140, // 140 >= 135 (90%) -> consistent
        ),
        TrackedDayEntity(
          day: monday.add(const Duration(days: 1)),
          calorieGoal: 2500,
          caloriesTracked: 2400,
          proteinGoal: 150,
          proteinTracked: 130, // 130 < 135 -> not consistent
        ),
      ];
      fakeGetIntake.allIntakes = [];
      fakeGetBodyProgress.summary = const BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: null,
        latestWaistCm: null,
        rollingWeightAverageKg: null,
        previousRollingWeightAverageKg: null,
        weeklyWeightDeltaKg: null,
        latestWaistDeltaCm: null,
      );
      fakeGetUser.user = UserEntity(
        birthday: DateTime(2000, 1, 1),
        heightCM: 180, weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.active,
      );
      fakeGetConfig.config = const ConfigEntity(true, true, true, AppThemeEntity.system);

      final result = await usecase.build(monday);

      expect(result.proteinConsistencyRate, closeTo(0.5, 0.01));
    });
  });

  group('build() - weight delta integration', () {
    test('includes body weight delta', () async {
      final monday = DateTime(2026, 6, 1);
      fakeGetTrackedDay.trackedDays = [
        TrackedDayEntity(day: monday, calorieGoal: 2500, caloriesTracked: 2400),
      ];
      fakeGetIntake.allIntakes = [];
      fakeGetBodyProgress.summary = const BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: 80.0,
        latestWaistCm: null,
        rollingWeightAverageKg: 80.0,
        previousRollingWeightAverageKg: 80.5,
        weeklyWeightDeltaKg: -0.5,
        latestWaistDeltaCm: null,
      );
      fakeGetUser.user = UserEntity(
        birthday: DateTime(2000, 1, 1),
        heightCM: 180, weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.active,
      );
      fakeGetConfig.config = const ConfigEntity(true, true, true, AppThemeEntity.system);

      final result = await usecase.build(monday);

      expect(result.weeklyWeightDeltaKg, closeTo(-0.5, 0.01));
    });
  });

  group('build() - top meals', () {
    test('identifies most frequent meals', () async {
      final monday = DateTime(2026, 6, 1);
      fakeGetTrackedDay.trackedDays = [
        TrackedDayEntity(day: monday, calorieGoal: 2500, caloriesTracked: 2400),
      ];
      fakeGetIntake.allIntakes = [
        _makeIntake('1', 'Chicken Rice', monday),
        _makeIntake('2', 'Chicken Rice', monday),
        _makeIntake('3', 'Oatmeal', monday),
        _makeIntake('4', 'Oatmeal', monday),
        _makeIntake('5', 'Oatmeal', monday),
        _makeIntake('6', 'Salad', monday),
      ];
      fakeGetBodyProgress.summary = const BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: null, latestWaistCm: null,
        rollingWeightAverageKg: null, previousRollingWeightAverageKg: null,
        weeklyWeightDeltaKg: null, latestWaistDeltaCm: null,
      );
      fakeGetUser.user = UserEntity(
        birthday: DateTime(2000, 1, 1),
        heightCM: 180, weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.active,
      );
      fakeGetConfig.config = const ConfigEntity(true, true, true, AppThemeEntity.system);

      final result = await usecase.build(monday);

      expect(result.topMeals.length, lessThanOrEqualTo(3));
      expect(result.topMeals.first.label, 'Oatmeal');
      expect(result.topMeals.first.count, 3);
    });
  });
}

IntakeEntity _makeIntake(String id, String name, DateTime day) {
  return IntakeEntity(
    id: id,
    unit: 'g',
    amount: 100,
    type: IntakeTypeEntity.breakfast,
    meal: MealEntity(
      code: id,
      name: name,
      url: null,
      mealQuantity: '100',
      mealUnit: 'g',
      servingQuantity: null,
      servingUnit: 'g',
      servingSize: null,
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
    ),
    dateTime: day,
  );
}

class _FakeGetTrackedDayUsecase implements GetTrackedDayUsecase {
  List<TrackedDayEntity> trackedDays = [];

  @override
  Future<TrackedDayEntity?> getTrackedDay(DateTime day) async => null;

  @override
  Future<List<TrackedDayEntity>> getTrackedDaysByRange(
      DateTime start, DateTime end) async {
    return trackedDays;
  }
}

class _FakeGetIntakeUsecase implements GetIntakeUsecase {
  List<IntakeEntity> allIntakes = [];

  @override
  Future<List<IntakeEntity>> getAllIntakes() async => allIntakes;

  @override
  Future<List<IntakeEntity>> getRecentIntake() async => [];

  @override
  Future<IntakeEntity?> getIntakeById(String id) async => null;

  @override
  Future<List<IntakeEntity>> getBreakfastIntakeByDay(day) async => [];

  @override
  Future<List<IntakeEntity>> getTodayBreakfastIntake() async => [];

  @override
  Future<List<IntakeEntity>> getLunchIntakeByDay(day) async => [];

  @override
  Future<List<IntakeEntity>> getTodayLunchIntake() async => [];

  @override
  Future<List<IntakeEntity>> getDinnerIntakeByDay(day) async => [];

  @override
  Future<List<IntakeEntity>> getTodayDinnerIntake() async => [];

  @override
  Future<List<IntakeEntity>> getSnackIntakeByDay(day) async => [];

  @override
  Future<List<IntakeEntity>> getTodaySnackIntake() async => [];
}

class _FakeGetBodyProgressUsecase implements GetBodyProgressUsecase {
  BodyProgressSummaryEntity summary = const BodyProgressSummaryEntity(
    latestMeasurementDay: null,
    latestWeightKg: null, latestWaistCm: null,
    rollingWeightAverageKg: null, previousRollingWeightAverageKg: null,
    weeklyWeightDeltaKg: null, latestWaistDeltaCm: null,
  );

  @override
  Future<BodyProgressSummaryEntity> getSummary({DateTime? referenceDay}) async =>
      summary;

  @override
  Future<List<BodyMeasurementEntity>> getRecentMeasurements({int limit = 30}) async => [];

  @override
  Future<BodyMeasurementEntity?> getMeasurementForDay(DateTime day) async => null;
}

class _FakeGetUserUsecase implements GetUserUsecase {
  UserEntity user = UserEntity(
    birthday: DateTime(2000, 1, 1),
    heightCM: 170, weightKG: 70,
    gender: UserGenderEntity.male,
    goal: UserWeightGoalEntity.maintainWeight,
    pal: UserPALEntity.active,
  );

  @override
  UserRepository get userRepository => throw UnimplementedError();

  @override
  Future<UserEntity> getUserData() async => user;

  @override
  Future<bool> hasUserData() async => true;
}

class _FakeGetConfigUsecase implements GetConfigUsecase {
  ConfigEntity config = const ConfigEntity(true, true, true, AppThemeEntity.system);

  @override
  Future<ConfigEntity> getConfig() async => config;
}
