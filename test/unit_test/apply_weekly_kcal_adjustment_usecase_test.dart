import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/features/weekly_insights/domain/usecase/apply_weekly_kcal_adjustment_usecase.dart';

void main() {
  late ApplyWeeklyKcalAdjustmentUsecase usecase;
  late _FakeGetConfigUsecase fakeGetConfig;
  late _FakeAddConfigUsecase fakeAddConfig;
  late _FakeGetGymTargetsUsecase fakeGetGymTargets;
  late _FakeAddTrackedDayUsecase fakeAddTrackedDay;

  setUp(() {
    fakeGetConfig = _FakeGetConfigUsecase();
    fakeAddConfig = _FakeAddConfigUsecase();
    fakeGetGymTargets = _FakeGetGymTargetsUsecase();
    fakeAddTrackedDay = _FakeAddTrackedDayUsecase();
    usecase = ApplyWeeklyKcalAdjustmentUsecase(
      fakeGetConfig,
      fakeAddConfig,
      fakeGetGymTargets,
      fakeAddTrackedDay,
    );
  });

  test('adds delta to existing adjustment', () async {
    fakeGetConfig.config = const ConfigEntity(true, true, true, AppThemeEntity.system,
        userKcalAdjustment: 100);

    final result = await usecase.apply(
        day: DateTime(2026, 6, 1), deltaKcal: -50);

    expect(result, 50); // 100 - 50
    expect(fakeAddConfig.savedAdjustment, 50);
  });

  test('handles null initial adjustment', () async {
    final result = await usecase.apply(
        day: DateTime(2026, 6, 1), deltaKcal: -100);

    expect(result, -100);
  });

  test('updates day calorie goals when tracked day exists', () async {
    fakeAddTrackedDay.hasDay = true;
    fakeGetGymTargets.targets = const GymTargetsEntity(
      kcalGoal: 2400, carbsGoal: 280, fatGoal: 65, proteinGoal: 140,
    );

    await usecase.apply(day: DateTime(2026, 6, 1), deltaKcal: -50);

    expect(fakeAddTrackedDay.updatedGoalDay, DateTime(2026, 6, 1));
    expect(fakeAddTrackedDay.updatedKcalGoal, 2400);
    expect(fakeAddTrackedDay.updatedCarbsGoal, 280);
    expect(fakeAddTrackedDay.updatedFatGoal, 65);
    expect(fakeAddTrackedDay.updatedProteinGoal, 140);
  });

  test('skips day goal update when no tracked day exists', () async {
    fakeAddTrackedDay.hasDay = false;

    await usecase.apply(day: DateTime(2026, 6, 1), deltaKcal: 100);

    expect(fakeAddTrackedDay.updatedGoalDay, isNull);
  });
}

class _FakeGetConfigUsecase implements GetConfigUsecase {
  ConfigEntity config = const ConfigEntity(true, true, true, AppThemeEntity.system);

  @override
  Future<ConfigEntity> getConfig() async => config;
}

class _FakeAddConfigUsecase implements AddConfigUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  double? savedAdjustment;

  @override
  Future<void> setConfigKcalAdjustment(double adjustment) async {
    savedAdjustment = adjustment;
  }

  @override
  Future<void> setConfigDisclaimer(bool v) async {}
  @override
  Future<void> setConfigDailyFocus(DailyFocusEntity v) async {}
}

class _FakeGetGymTargetsUsecase implements GetGymTargetsUsecase {
  GymTargetsEntity targets = const GymTargetsEntity(
    kcalGoal: 2500, carbsGoal: 300, fatGoal: 70, proteinGoal: 150,
  );

  @override
  Future<GymTargetsEntity> getTargetsForDay(
    DateTime day, {
    UserEntity? userEntity,
    UserWeightGoalEntity? phase,
    DailyFocusEntity? dailyFocus,
    double? totalKcalActivities,
  }) async => targets;
}

class _FakeAddTrackedDayUsecase implements AddTrackedDayUsecase {
  bool hasDay = false;
  DateTime? updatedGoalDay;
  double? updatedKcalGoal;
  double? updatedCarbsGoal;
  double? updatedFatGoal;
  double? updatedProteinGoal;

  @override
  Future<bool> hasTrackedDay(DateTime day) async => hasDay;

  @override
  Future<void> updateDayCalorieGoal(DateTime day, double goal) async {
    updatedGoalDay = day;
    updatedKcalGoal = goal;
  }

  @override
  Future<void> updateDayMacroGoals(DateTime day,
      {double? carbsGoal, double? fatGoal, double? proteinGoal}) async {
    updatedCarbsGoal = carbsGoal;
    updatedFatGoal = fatGoal;
    updatedProteinGoal = proteinGoal;
  }

  @override
  Future<void> addDayCaloriesTracked(DateTime day, double kcal) async {}
  @override
  Future<void> removeDayCaloriesTracked(DateTime day, double kcal) async {}
  @override
  Future<void> addDayMacrosTracked(DateTime day,
      {double? carbsTracked, double? fatTracked, double? proteinTracked}) async {}
  @override
  Future<void> removeDayMacrosTracked(DateTime day,
      {double? carbsTracked, double? fatTracked, double? proteinTracked}) async {}
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
