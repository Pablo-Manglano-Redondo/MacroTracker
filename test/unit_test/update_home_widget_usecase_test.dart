import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/get_daily_habit_log_usecase.dart';
import 'package:macrotracker/features/home_widget/domain/usecase/update_home_widget_usecase.dart';
import '../fixture/user_entity_fixtures.dart';

class _FakeGetTrackedDayUsecase extends Fake implements GetTrackedDayUsecase {
  TrackedDayEntity? trackedDay;
  @override
  Future<TrackedDayEntity?> getTrackedDay(DateTime day) async => trackedDay;
}

class _FakeGetDailyHabitLogUsecase extends Fake implements GetDailyHabitLogUsecase {
  DailyHabitLogEntity? logEntity;
  @override
  Future<DailyHabitLogEntity> getForDay(DateTime day) async => logEntity ?? DailyHabitLogEntity.empty(day);
}

class _FakeGetGymTargetsUsecase extends Fake implements GetGymTargetsUsecase {
  GymTargetsEntity targets = const GymTargetsEntity(
    kcalGoal: 2000,
    carbsGoal: 250,
    fatGoal: 60,
    proteinGoal: 150,
  );
  @override
  Future<GymTargetsEntity> getTargetsForDay(DateTime day, {UserEntity? userEntity, dynamic phase, dynamic dailyFocus, double? totalKcalActivities}) async {
    return targets;
  }
}

class _FakeGetConfigUsecase extends Fake implements GetConfigUsecase {
  ConfigEntity config = const ConfigEntity(
    true, true, true, AppThemeEntity.dark,
    usesImperialUnits: false,
    dailyFocus: DailyFocusEntity.upperBody,
  );
  @override
  Future<ConfigEntity> getConfig() async => config;
}

class _FakeGetUserUsecase extends Fake implements GetUserUsecase {
  UserEntity user = UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;
  @override
  Future<UserEntity> getUserData() async => user;
}

void main() {
  group('UpdateHomeWidgetUsecase Tests', () {
    late _FakeGetTrackedDayUsecase getTrackedDayUsecase;
    late _FakeGetDailyHabitLogUsecase getDailyHabitLogUsecase;
    late _FakeGetGymTargetsUsecase getGymTargetsUsecase;
    late _FakeGetConfigUsecase getConfigUsecase;
    late _FakeGetUserUsecase getUserUsecase;
    late UpdateHomeWidgetUsecase usecase;

    final Map<String, dynamic> savedWidgetData = {};
    final List<String> updatedWidgets = [];

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      savedWidgetData.clear();
      updatedWidgets.clear();

      getTrackedDayUsecase = _FakeGetTrackedDayUsecase();
      getDailyHabitLogUsecase = _FakeGetDailyHabitLogUsecase();
      getGymTargetsUsecase = _FakeGetGymTargetsUsecase();
      getConfigUsecase = _FakeGetConfigUsecase();
      getUserUsecase = _FakeGetUserUsecase();

      usecase = UpdateHomeWidgetUsecase(
        getTrackedDayUsecase,
        getDailyHabitLogUsecase,
        getGymTargetsUsecase,
        getConfigUsecase,
        getUserUsecase,
      );
      usecase.debugBypassPlatformCheck = true;

      // Mock Method Channels for home_widget
      const mainChannel = MethodChannel('es.antonborri.home_widget/main');
      const classChannel = MethodChannel('class.packagedg.home_widget');
      const homeWidgetChannel = MethodChannel('home_widget');

      Future<dynamic> handler(MethodCall methodCall) async {
        if (methodCall.method == 'saveWidgetData') {
          final id = methodCall.arguments['id'];
          final data = methodCall.arguments['data'];
          savedWidgetData[id] = data;
          return true;
        } else if (methodCall.method == 'updateWidget') {
          final androidName = methodCall.arguments['android'];
          if (androidName != null) {
            updatedWidgets.add(androidName);
          }
          return true;
        }
        return null;
      }

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(mainChannel, handler);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(classChannel, handler);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(homeWidgetChannel, handler);
    });

    tearDown(() {
      const mainChannel = MethodChannel('es.antonborri.home_widget/main');
      const classChannel = MethodChannel('class.packagedg.home_widget');
      const homeWidgetChannel = MethodChannel('home_widget');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(mainChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(classChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(homeWidgetChannel, null);
    });

    test('refreshes home widget with tracked day data (metric units)', () async {
      getTrackedDayUsecase.trackedDay = TrackedDayEntity(
        day: DateTime.now(),
        calorieGoal: 2200,
        caloriesTracked: 1500,
        carbsGoal: 280,
        carbsTracked: 180,
        fatGoal: 70,
        fatTracked: 50,
        proteinGoal: 160,
        proteinTracked: 120,
      );

      final log = DailyHabitLogEntity(
        day: DateTime.now(),
        creatineTaken: false,
        wheyTaken: false,
        caffeineTaken: false,
        waterLiters: 2.5,
        sleepHours: 7.5,
        steps: 9500,
        energyLevel: 0,
      );
      getDailyHabitLogUsecase.logEntity = log;

      getConfigUsecase.config = const ConfigEntity(
        true, true, true, AppThemeEntity.dark,
        usesImperialUnits: false,
        dailyFocus: DailyFocusEntity.upperBody,
        selectedLocale: 'es_ES',
      );

      getUserUsecase.user = UserEntity(
        birthday: DateTime.now(),
        heightCM: 180,
        weightKG: 80,
        gender: getUserUsecase.user.gender,
        goal: getUserUsecase.user.goal,
        pal: getUserUsecase.user.pal,
        targetSteps: 10000,
        targetSleepHours: 8.0,
        targetWaterLiters: 3.0,
      );

      await usecase.refreshToday();

      // Check remaining calories
      expect(savedWidgetData['widget_kcal_remaining'], '700'); // 2200 - 1500

      // Check macro progress formatting
      expect(savedWidgetData['widget_carbs_progress'], '180/280');
      expect(savedWidgetData['widget_fat_progress'], '50/70');
      expect(savedWidgetData['widget_protein_progress'], '120/160');

      // Check hydration formatting (metric)
      expect(savedWidgetData['widget_water_progress'], '2.5/3.0L');

      // Check steps and sleep
      expect(savedWidgetData['widget_steps_progress'], '9500 / 10000');
      expect(savedWidgetData['widget_sleep_progress'], '7.5 / 8.0h');

      // Check focus label Spanish/English translation (selectedLocale is es_ES)
      expect(savedWidgetData['widget_focus_label'], 'Torso');

      // Check widgets updated
      expect(updatedWidgets, containsAll([
        'MacroTrackerSummaryWidgetProvider',
        'MacroTrackerQuickActionsWidgetProvider',
        'MacroTrackerCircularProgressWidgetProvider',
        'MacroTrackerHabitsWidgetProvider',
      ]));
    });

    test('refreshes home widget using gym targets fallback and imperial units', () async {
      // No tracked day -> uses fallback targets
      getTrackedDayUsecase.trackedDay = null;

      getGymTargetsUsecase.targets = const GymTargetsEntity(
        kcalGoal: 1800,
        carbsGoal: 200,
        fatGoal: 50,
        proteinGoal: 130,
      );

      final log = DailyHabitLogEntity(
        day: DateTime.now(),
        creatineTaken: false,
        wheyTaken: false,
        caffeineTaken: false,
        waterLiters: 1.0,
        sleepHours: 6.0,
        steps: 5000,
        energyLevel: 0,
      );
      getDailyHabitLogUsecase.logEntity = log;

      getConfigUsecase.config = const ConfigEntity(
        true, true, true, AppThemeEntity.dark,
        usesImperialUnits: true, // Imperial
        dailyFocus: DailyFocusEntity.cardio,
        selectedLocale: 'en_US',
      );

      // No custom targets on user -> uses focus defaults
      getUserUsecase.user = UserEntity(
        birthday: DateTime.now(),
        heightCM: 180,
        weightKG: 80,
        gender: getUserUsecase.user.gender,
        goal: getUserUsecase.user.goal,
        pal: getUserUsecase.user.pal,
        targetSteps: null,
        targetSleepHours: null,
        targetWaterLiters: null,
      );

      await usecase.refreshToday();

      expect(savedWidgetData['widget_kcal_remaining'], '1800'); // 1800 - 0
      expect(savedWidgetData['widget_carbs_progress'], '0/200');
      expect(savedWidgetData['widget_fat_progress'], '0/50');
      expect(savedWidgetData['widget_protein_progress'], '0/130');

      // Check hydration formatting (imperial). 
      // 1.0L is 1000ml. mlToFlOz(1000) is 33.814 -> round to 34 oz.
      // Cardio fallback water is 3.75L = 3750ml. mlToFlOz(3750) is 126.8 -> round to 127 oz.
      expect(savedWidgetData['widget_water_progress'], '34/127 oz');

      // Check steps progress (Cardio focus fallback steps = 12000)
      expect(savedWidgetData['widget_steps_progress'], '5000 / 12000');

      // Check focus label English translation
      expect(savedWidgetData['widget_focus_label'], 'Cardio');
    });
  });
}
