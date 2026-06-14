import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/food_quality_score_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_user_usecase.dart';
import 'package:macrotracker/core/domain/usecase/delete_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/delete_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/domain/usecase/update_intake_usecase.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/home/domain/entity/home_dashboard_data_entity.dart';
import 'package:macrotracker/features/home/domain/usecase/load_home_dashboard_usecase.dart';
import 'package:macrotracker/features/home/domain/usecase/sync_home_tracked_day_usecase.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

void main() {
  group('HomeBloc', () {
    test('get total helpers aggregate intake macros', () {
      final bloc = _makeBloc(
        loadUsecase: _FakeLoadHomeDashboardUsecase(_buildDashboardData()),
      );

      final intakes = [
        _makeIntake('1', 100, 10, carbs100: 20, fat100: 15, protein100: 12),
        _makeIntake('2', 200, 5, carbs100: 30, fat100: 25, protein100: 18),
      ];

      expect(bloc.getTotalKcal(intakes), closeTo(20, 0.01));
      expect(bloc.getTotalCarbs(intakes), closeTo(80, 0.01));
      expect(bloc.getTotalFats(intakes), closeTo(65, 0.01));
      expect(bloc.getTotalProteins(intakes), closeTo(48, 0.01));
    });

    test('LoadItemsEvent emits loading and loaded state from dashboard data',
        () async {
      final data = _buildDashboardData(
        config: const ConfigEntity(
          false,
          true,
          true,
          AppThemeEntity.system,
          usesImperialUnits: true,
          dailyFocus: DailyFocusEntity.upperBody,
        ),
        user: _buildUser(goal: UserWeightGoalEntity.gainWeight),
        targets: const GymTargetsEntity(
          kcalGoal: 2500,
          carbsGoal: 300,
          fatGoal: 70,
          proteinGoal: 160,
        ),
        totalKcalIntake: 1800,
        totalKcalActivities: 320,
      );
      final bloc = _makeBloc(
        loadUsecase: _FakeLoadHomeDashboardUsecase(data),
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<HomeLoadingState>(),
          isA<HomeLoadedState>().having(
            (state) => state.totalKcalLeft,
            'totalKcalLeft',
            700,
          ).having(
            (state) => state.usesImperialUnits,
            'usesImperialUnits',
            true,
          ).having(
            (state) => state.nutritionPhase,
            'nutritionPhase',
            UserWeightGoalEntity.gainWeight,
          ),
        ]),
      );

      bloc.add(const LoadItemsEvent(
        refreshRemotePlan: true,
        uploadProfessionalSnapshot: true,
      ));

      await expectation;
      await bloc.close();
    });

    test('setDailyFocus syncs tracked day with the selected focus', () async {
      final syncUsecase = _FakeSyncHomeTrackedDayUsecase();
      final bloc = _makeBloc(
        loadUsecase: _FakeLoadHomeDashboardUsecase(_buildDashboardData()),
        syncUsecase: syncUsecase,
      );

      await bloc.setDailyFocus(DailyFocusEntity.lowerBody);

      expect(syncUsecase.lastDailyFocus, DailyFocusEntity.lowerBody);
      await bloc.close();
    });
  });
}

HomeBloc _makeBloc({
  required _FakeLoadHomeDashboardUsecase loadUsecase,
  _FakeSyncHomeTrackedDayUsecase? syncUsecase,
}) {
  return HomeBloc(
    _FakeAddConfigUsecase(),
    _FakeGetUserUsecase(),
    _FakeAddUserUsecase(),
    _FakeGetIntakeUsecase(),
    _FakeDeleteIntakeUsecase(),
    _FakeUpdateIntakeUsecase(),
    _FakeDeleteUserActivityUsecase(),
    _FakeAddTrackedDayUsecase(),
    loadUsecase,
    syncUsecase ?? _FakeSyncHomeTrackedDayUsecase(),
  );
}

HomeDashboardDataEntity _buildDashboardData({
  ConfigEntity? config,
  UserEntity? user,
  GymTargetsEntity? targets,
  double totalKcalIntake = 0,
  double totalCarbsIntake = 0,
  double totalFatsIntake = 0,
  double totalProteinsIntake = 0,
  double totalKcalActivities = 0,
}) {
  return HomeDashboardDataEntity(
    config: config ??
        const ConfigEntity(
          true,
          true,
          true,
          AppThemeEntity.system,
          dailyFocus: DailyFocusEntity.upperBody,
        ),
    user: user ?? _buildUser(),
    breakfastIntakeList: const [],
    lunchIntakeList: const [],
    dinnerIntakeList: const [],
    snackIntakeList: const [],
    userActivities: const [],
    foodQualitySummary: const FoodQualityDailySummaryEntity(
      score: 85,
      band: FoodQualityBandEntity.good,
      mealsCount: 3,
    ),
    targets: targets ??
        const GymTargetsEntity(
          kcalGoal: 2200,
          carbsGoal: 250,
          fatGoal: 65,
          proteinGoal: 150,
        ),
    professionalConnection: null,
    totalKcalIntake: totalKcalIntake,
    totalCarbsIntake: totalCarbsIntake,
    totalFatsIntake: totalFatsIntake,
    totalProteinsIntake: totalProteinsIntake,
    totalKcalActivities: totalKcalActivities,
  );
}

UserEntity _buildUser({
  UserWeightGoalEntity goal = UserWeightGoalEntity.maintainWeight,
}) {
  return UserEntity(
    birthday: DateTime(2000, 1, 1),
    heightCM: 180,
    weightKG: 80,
    gender: UserGenderEntity.male,
    goal: goal,
    pal: UserPALEntity.active,
    targetSteps: 8000,
    targetSleepHours: 8,
    targetWaterLiters: 2.5,
  );
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

class _FakeAddConfigUsecase implements AddConfigUsecase {
  DailyFocusEntity? savedDailyFocus;

  @override
  Future<void> setConfigDailyFocus(DailyFocusEntity value) async {
    savedDailyFocus = value;
  }

  @override
  Future<void> setConfigDisclaimer(bool value) async {}

  @override
  Future<void> setConfigKcalAdjustment(double adjustment) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetUserUsecase implements GetUserUsecase {
  @override
  Future<UserEntity> getUserData() async => _buildUser();

  @override
  Future<bool> hasUserData() async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddUserUsecase implements AddUserUsecase {
  UserEntity? savedUser;

  @override
  Future<void> addUser(UserEntity user) async {
    savedUser = user;
  }
}

class _FakeGetIntakeUsecase implements GetIntakeUsecase {
  @override
  Future<List<IntakeEntity>> getAllIntakes() async => const [];

  @override
  Future<List<IntakeEntity>> getRecentIntake() async => const [];

  @override
  Future<IntakeEntity?> getIntakeById(String id) async => null;

  @override
  Future<List<IntakeEntity>> getBreakfastIntakeByDay(day) async => const [];

  @override
  Future<List<IntakeEntity>> getTodayBreakfastIntake() async => const [];

  @override
  Future<List<IntakeEntity>> getLunchIntakeByDay(day) async => const [];

  @override
  Future<List<IntakeEntity>> getTodayLunchIntake() async => const [];

  @override
  Future<List<IntakeEntity>> getDinnerIntakeByDay(day) async => const [];

  @override
  Future<List<IntakeEntity>> getTodayDinnerIntake() async => const [];

  @override
  Future<List<IntakeEntity>> getSnackIntakeByDay(day) async => const [];

  @override
  Future<List<IntakeEntity>> getTodaySnackIntake() async => const [];
}

class _FakeDeleteIntakeUsecase implements DeleteIntakeUsecase {
  @override
  Future<void> deleteIntake(IntakeEntity intake) async {}
}

class _FakeUpdateIntakeUsecase implements UpdateIntakeUsecase {
  @override
  Future<IntakeEntity?> updateIntake(
    String id,
    Map<String, dynamic> fields,
  ) async =>
      null;
}

class _FakeDeleteUserActivityUsecase implements DeleteUserActivityUsecase {
  @override
  Future<void> deleteUserActivity(UserActivityEntity entity) async {}
}

class _FakeAddTrackedDayUsecase implements AddTrackedDayUsecase {
  @override
  Future<bool> hasTrackedDay(DateTime day) async => false;

  @override
  Future<void> updateDayCalorieGoal(DateTime day, double goal) async {}

  @override
  Future<void> updateDayMacroGoals(
    DateTime day, {
    double? carbsGoal,
    double? fatGoal,
    double? proteinGoal,
  }) async {}

  @override
  Future<void> addDayCaloriesTracked(DateTime day, double kcal) async {}

  @override
  Future<void> removeDayCaloriesTracked(DateTime day, double kcal) async {}

  @override
  Future<void> addDayMacrosTracked(
    DateTime day, {
    double? carbsTracked,
    double? fatTracked,
    double? proteinTracked,
  }) async {}

  @override
  Future<void> removeDayMacrosTracked(
    DateTime day, {
    double? carbsTracked,
    double? fatTracked,
    double? proteinTracked,
  }) async {}

  @override
  Future<void> increaseDayCalorieGoal(DateTime day, double amount) async {}

  @override
  Future<void> reduceDayCalorieGoal(DateTime day, double amount) async {}

  @override
  Future<void> addNewTrackedDay(
    DateTime day,
    double kcal,
    double carbs,
    double fat,
    double protein,
  ) async {}

  @override
  Future<void> increaseDayMacroGoals(
    DateTime day, {
    double? carbsAmount,
    double? fatAmount,
    double? proteinAmount,
  }) async {}

  @override
  Future<void> reduceDayMacroGoals(
    DateTime day, {
    double? carbsAmount,
    double? fatAmount,
    double? proteinAmount,
  }) async {}
}

class _FakeLoadHomeDashboardUsecase implements LoadHomeDashboardUsecase {
  final HomeDashboardDataEntity response;

  _FakeLoadHomeDashboardUsecase(this.response);

  @override
  Future<HomeDashboardDataEntity> execute({
    required DateTime day,
    bool refreshRemotePlan = false,
    bool uploadProfessionalSnapshot = false,
  }) async {
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSyncHomeTrackedDayUsecase implements SyncHomeTrackedDayUsecase {
  DailyFocusEntity? lastDailyFocus;

  @override
  Future<bool> execute({
    required DateTime day,
    UserWeightGoalEntity? phase,
    DailyFocusEntity? dailyFocus,
    UserEntity? user,
    ProfessionalConnectionEntity? professionalConnection,
  }) async {
    lastDailyFocus = dailyFocus;
    return false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
