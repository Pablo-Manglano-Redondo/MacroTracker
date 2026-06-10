import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/data/repository/user_repository.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/entity/food_quality_score_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_user_usecase.dart';
import 'package:macrotracker/core/domain/usecase/calculate_food_quality_score_usecase.dart';
import 'package:macrotracker/core/domain/usecase/delete_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/delete_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/domain/usecase/update_intake_usecase.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_measurement_entity.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_progress_summary_entity.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/get_body_progress_usecase.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_plan_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/process_pending_syncs_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/upload_professional_snapshot_usecase.dart';

void main() {
  group('HomeBloc - total calculation helpers', () {
    late HomeBloc homeBloc;

    setUp(() {
      homeBloc = HomeBloc(
        _FakeGetConfigUsecase(),
        _FakeAddConfigUsecase(),
        _FakeGetUserUsecase(),
        _FakeAddUserUsecase(),
        _FakeGetIntakeUsecase(),
        _FakeDeleteIntakeUsecase(),
        _FakeUpdateIntakeUsecase(),
        _FakeGetUserActivityUsecase(),
        _FakeDeleteUserActivityUsecase(),
        _FakeAddTrackedDayUsecase(),
        _FakeGetKcalGoalUsecase(),
        _FakeGetMacroGoalUsecase(),
        _FakeCalculateFoodQualityScoreUsecase(),
        _FakeGetProfessionalPlanUsecase(),
        _FakeUploadProfessionalSnapshotUsecase(),
        _FakeProcessPendingSyncsUsecase(),
        _FakeGetBodyProgressUsecase(),
      );
    });

    test('getTotalKcal sums all intake calories', () {
      final intakes = [
        _makeIntake('1', 100, 10),
        _makeIntake('2', 200, 5),
        _makeIntake('3', 300, 20),
      ];

      final total = homeBloc.getTotalKcal(intakes);

      expect(total, closeTo((100 * 10 + 200 * 5 + 300 * 20) / 100, 0.01));
    });

    test('getTotalKcal returns 0 for empty list', () {
      expect(homeBloc.getTotalKcal([]), 0);
    });

    test('getTotalCarbs sums all intake carbs', () {
      final intakes = [
        _makeIntake('1', 100, 10, carbs100: 20),
        _makeIntake('2', 200, 5, carbs100: 30),
      ];

      final total = homeBloc.getTotalCarbs(intakes);

      expect(total, closeTo(100 * 20 / 100 + 200 * 30 / 100, 0.01));
    });

    test('getTotalFats sums all intake fats', () {
      final intakes = [
        _makeIntake('1', 100, 10, fat100: 15),
        _makeIntake('2', 200, 5, fat100: 25),
      ];

      final total = homeBloc.getTotalFats(intakes);

      expect(total, closeTo(100 * 15 / 100 + 200 * 25 / 100, 0.01));
    });

    test('getTotalProteins sums all intake proteins', () {
      final intakes = [
        _makeIntake('1', 100, 10, protein100: 12),
        _makeIntake('2', 200, 5, protein100: 18),
      ];

      final total = homeBloc.getTotalProteins(intakes);

      expect(total, closeTo(100 * 12 / 100 + 200 * 18 / 100, 0.01));
    });

    test('all total helpers handle empty list', () {
      expect(homeBloc.getTotalCarbs([]), 0);
      expect(homeBloc.getTotalFats([]), 0);
      expect(homeBloc.getTotalProteins([]), 0);
    });

    test('getTotalKcal handles single intake', () {
      final intakes = [_makeIntake('1', 150, 8)];
      expect(homeBloc.getTotalKcal(intakes), closeTo(150 * 8 / 100, 0.01));
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

class _FakeGetConfigUsecase implements GetConfigUsecase {
  @override
  Future<ConfigEntity> getConfig() async => const ConfigEntity(true, true, true, AppThemeEntity.system);
}

class _FakeAddConfigUsecase implements AddConfigUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> setConfigKcalAdjustment(double adj) async {}
  @override
  Future<void> setConfigDisclaimer(bool v) async {}
  @override
  Future<void> setConfigDailyFocus(DailyFocusEntity v) async {}
}

class _FakeGetUserUsecase implements GetUserUsecase {
  @override
  UserRepository get userRepository => throw UnimplementedError();

  @override
  Future<UserEntity> getUserData() async => UserEntity(
        birthday: DateTime(2000, 1, 1),
        heightCM: 180, weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.active,
      );
  @override
  Future<bool> hasUserData() async => true;
}

class _FakeAddUserUsecase implements AddUserUsecase {
  @override
  Future<void> addUser(UserEntity user) async {}
}

class _FakeGetIntakeUsecase implements GetIntakeUsecase {
  @override
  Future<List<IntakeEntity>> getAllIntakes() async => [];
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

class _FakeDeleteIntakeUsecase implements DeleteIntakeUsecase {
  @override
  Future<void> deleteIntake(IntakeEntity intake) async {}
}

class _FakeUpdateIntakeUsecase implements UpdateIntakeUsecase {
  @override
  Future<IntakeEntity?> updateIntake(String id, Map<String, dynamic> fields) async => null;
}

class _FakeGetUserActivityUsecase implements GetUserActivityUsecase {
  @override
  Future<List<UserActivityEntity>> getTodayUserActivity() async => [];
  @override
  Future<List<UserActivityEntity>> getUserActivityByDay(DateTime day) async => [];
  @override
  Future<List<UserActivityEntity>> getRecentUserActivity() async => [];
  @override
  Future<List<UserActivityEntity>> getAllUserActivity() async => [];
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
  Future<void> updateDayMacroGoals(DateTime day, {double? carbsGoal, double? fatGoal, double? proteinGoal}) async {}
  @override
  Future<void> addDayCaloriesTracked(DateTime day, double kcal) async {}
  @override
  Future<void> removeDayCaloriesTracked(DateTime day, double kcal) async {}
  @override
  Future<void> addDayMacrosTracked(DateTime day, {double? carbsTracked, double? fatTracked, double? proteinTracked}) async {}
  @override
  Future<void> removeDayMacrosTracked(DateTime day, {double? carbsTracked, double? fatTracked, double? proteinTracked}) async {}
  @override
  Future<void> increaseDayCalorieGoal(DateTime day, double amount) async {}
  @override
  Future<void> reduceDayCalorieGoal(DateTime day, double amount) async {}
  @override
  Future<void> addNewTrackedDay(DateTime day, double kcal, double carbs, double fat, double protein) async {}
  @override
  Future<void> increaseDayMacroGoals(DateTime day, {double? carbsAmount, double? fatAmount, double? proteinAmount}) async {}
  @override
  Future<void> reduceDayMacroGoals(DateTime day, {double? carbsAmount, double? fatAmount, double? proteinAmount}) async {}
}

class _FakeGetKcalGoalUsecase implements GetKcalGoalUsecase {
  @override
  Future<double> getKcalGoal({UserEntity? userEntity, double? totalKcalActivitiesParam, double? kcalUserAdjustment}) async => 2500;
}

class _FakeGetMacroGoalUsecase implements GetMacroGoalUsecase {
  @override
  Future<double> getCarbsGoal(double totalKcalGoal) async => 300;
  @override
  Future<double> getFatsGoal(double totalKcalGoal) async => 70;
  @override
  Future<double> getProteinsGoal(double totalKcalGoal) async => 150;
}

class _FakeCalculateFoodQualityScoreUsecase implements CalculateFoodQualityScoreUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  FoodQualityScoreEntity scoreMeal(MealEntity meal) => const FoodQualityScoreEntity(score: 50, band: FoodQualityBandEntity.fair, reasons: [], isPartial: false);
  @override
  FoodQualityDailySummaryEntity summarizeIntakes(Iterable<IntakeEntity> intakes) => const FoodQualityDailySummaryEntity(score: 50, band: FoodQualityBandEntity.fair, mealsCount: 0);
}

class _FakeGetProfessionalPlanUsecase implements GetProfessionalPlanUsecase {
  @override
  Future<ProfessionalConnectionEntity?> getActiveConnection({bool refreshRemotePlan = false}) async => null;
}

class _FakeUploadProfessionalSnapshotUsecase implements UploadProfessionalSnapshotUsecase {
  @override
  Future<void> uploadDailySnapshot({required ProfessionalConnectionEntity connection, required DateTime day, required double kcalActual, required double kcalTarget, required double carbsActual, required double carbsTarget, required double fatActual, required double fatTarget, required double proteinActual, required double proteinTarget, required int mealsLogged, String? notes, double? weightKg, double? waistCm}) async {}
}

class _FakeProcessPendingSyncsUsecase implements ProcessPendingSyncsUsecase {
  @override
  Future<void> execute() async {}
}

class _FakeGetBodyProgressUsecase implements GetBodyProgressUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<BodyProgressSummaryEntity> getSummary({DateTime? referenceDay}) async => const BodyProgressSummaryEntity(
    latestMeasurementDay: null, latestWeightKg: null, latestWaistCm: null,
    rollingWeightAverageKg: null, previousRollingWeightAverageKg: null,
    weeklyWeightDeltaKg: null, latestWaistDeltaCm: null,
  );
  @override
  Future<List<BodyMeasurementEntity>> getRecentMeasurements({int limit = 30}) async => [];
  @override
  Future<BodyMeasurementEntity?> getMeasurementForDay(DateTime day) async => null;
}
