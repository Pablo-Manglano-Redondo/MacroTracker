import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/features/add_activity/presentation/bloc/recent_activities_bloc.dart';
import 'package:macrotracker/features/activity_detail/presentation/bloc/activity_detail_bloc.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_user_activity_usercase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';

import '../fixture/user_entity_fixtures.dart';
import '../fixture/physical_activity_entity_fixtures.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeGetUserActivityUsecase implements GetUserActivityUsecase {
  List<UserActivityEntity> recentActivities = [];
  bool shouldThrow = false;

  @override
  Future<List<UserActivityEntity>> getRecentUserActivity() async {
    if (shouldThrow) throw Exception('DB error');
    return recentActivities;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetUserUsecase implements GetUserUsecase {
  UserEntity user =
      UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;

  @override
  Future<UserEntity> getUserData() async => user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddUserActivityUsecase implements AddUserActivityUsecase {
  UserActivityEntity? lastAdded;

  @override
  Future<void> addUserActivity(UserActivityEntity userActivityEntity) async {
    lastAdded = userActivityEntity;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddTrackedDayUsecase implements AddTrackedDayUsecase {
  bool hasDay = false;

  @override
  Future<bool> hasTrackedDay(DateTime day) async => hasDay;

  @override
  Future<void> addNewTrackedDay(DateTime day, double totalKcalGoal,
      double? totalCarbsGoal, double? totalFatGoal,
      double? totalProteinGoal) async {}

  @override
  Future<void> updateDayCalorieGoal(DateTime day, double kcalGoal) async {}

  @override
  Future<void> updateDayMacroGoals(DateTime day,
      {double? carbsGoal, double? fatGoal, double? proteinGoal}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetKcalGoalUsecase implements GetKcalGoalUsecase {
  @override
  Future<double> getKcalGoal({
    UserEntity? userEntity,
    double? totalKcalActivitiesParam,
    double? kcalUserAdjustment,
  }) async =>
      2000.0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetMacroGoalUsecase implements GetMacroGoalUsecase {
  @override
  Future<double> getCarbsGoal(double totalCalorieGoal) async => 250.0;

  @override
  Future<double> getFatsGoal(double totalCalorieGoal) async => 70.0;

  @override
  Future<double> getProteinsGoal(double totalCalorieGoal) async => 150.0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Minimal BuildContext fake
class _FakeBuildContext extends Fake implements BuildContext {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RecentActivitiesBloc', () {
    late RecentActivitiesBloc bloc;
    late _FakeGetUserActivityUsecase fakeUsecase;

    final activity1 = UserActivityEntity(
      'UA-1',
      45.0,
      350.0,
      DateTime(2024, 1, 1),
      PhysicalActivityFixtures.vigorousRunning,
    );

    final activity2 = UserActivityEntity(
      'UA-2',
      30.0,
      150.0,
      DateTime(2024, 1, 1),
      PhysicalActivityFixtures.lightDancing,
    );

    setUp(() {
      fakeUsecase = _FakeGetUserActivityUsecase();
      bloc = RecentActivitiesBloc(fakeUsecase);
    });

    tearDown(() => bloc.close());

    test('initial state is RecentActivitiesInitial', () {
      expect(bloc.state, isA<RecentActivitiesInitial>());
    });

    test('emits loading then loaded with activities on success', () async {
      fakeUsecase.recentActivities = [activity1, activity2];

      final states = <RecentActivitiesState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadRecentActivitiesEvent(context: _FakeBuildContext()));
      await Future.delayed(const Duration(milliseconds: 20));

      expect(states.length, 2);
      expect(states[0], isA<RecentActivitiesLoadingState>());
      final loaded = states[1] as RecentActivitiesLoadedState;
      expect(loaded.recentActivities.length, 2);
      expect(loaded.recentActivities[0].code,
          PhysicalActivityFixtures.vigorousRunning.code);
      expect(loaded.recentActivities[1].code,
          PhysicalActivityFixtures.lightDancing.code);
    });

    test('emits loaded with empty list when no activities', () async {
      fakeUsecase.recentActivities = [];

      final states = <RecentActivitiesState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadRecentActivitiesEvent(context: _FakeBuildContext()));
      await Future.delayed(const Duration(milliseconds: 20));

      expect(states[0], isA<RecentActivitiesLoadingState>());
      final loaded = states[1] as RecentActivitiesLoadedState;
      expect(loaded.recentActivities, isEmpty);
    });

    test('emits failed state on exception', () async {
      fakeUsecase.shouldThrow = true;

      final states = <RecentActivitiesState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadRecentActivitiesEvent(context: _FakeBuildContext()));
      await Future.delayed(const Duration(milliseconds: 20));

      expect(states[0], isA<RecentActivitiesLoadingState>());
      expect(states[1], isA<RecentActivitiesFailedState>());
    });
  });

  group('ActivityDetailBloc', () {
    late ActivityDetailBloc bloc;
    late _FakeGetUserUsecase fakeGetUser;
    late _FakeAddUserActivityUsecase fakeAddActivity;
    late _FakeAddTrackedDayUsecase fakeAddTrackedDay;
    late _FakeGetKcalGoalUsecase fakeKcalGoal;
    late _FakeGetMacroGoalUsecase fakeMacroGoal;

    setUp(() {
      fakeGetUser = _FakeGetUserUsecase();
      fakeAddActivity = _FakeAddUserActivityUsecase();
      fakeAddTrackedDay = _FakeAddTrackedDayUsecase();
      fakeKcalGoal = _FakeGetKcalGoalUsecase();
      fakeMacroGoal = _FakeGetMacroGoalUsecase();

      bloc = ActivityDetailBloc(
        fakeGetUser,
        fakeAddActivity,
        fakeAddTrackedDay,
        fakeKcalGoal,
        fakeMacroGoal,
      );
    });

    tearDown(() => bloc.close());

    test('initial state is ActivityDetailInitial', () {
      expect(bloc.state, isA<ActivityDetailInitial>());
    });

    test('emits loading then loaded on LoadActivityDetailEvent', () async {
      const activity = PhysicalActivityFixtures.vigorousRunning;
      final ctx = _FakeBuildContext();

      final states = <ActivityDetailState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadActivityDetailEvent(ctx, activity));
      await Future.delayed(const Duration(milliseconds: 20));

      expect(states[0], isA<ActivityDetailLoadingState>());
      expect(states[1], isA<ActivityDetailLoadedState>());

      final loaded = states[1] as ActivityDetailLoadedState;
      // Default quantity = 60 min
      expect(loaded.quantityMin, 60);
      expect(loaded.userEntity, isA<UserEntity>());
      expect(loaded.totalKcalBurned, greaterThan(0));
    });

    test('getTotalKcalBurned returns positive value for vigorous running', () {
      final user =
          UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;
      const activity = PhysicalActivityFixtures.vigorousRunning;
      final kcal = bloc.getTotalKcalBurned(user, activity, 60.0);
      expect(kcal, greaterThan(0));
    });

    test('getTotalKcalBurned is proportional to duration', () {
      final user =
          UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;
      const activity = PhysicalActivityFixtures.moderateBicycling;
      final kcal30 = bloc.getTotalKcalBurned(user, activity, 30.0);
      final kcal60 = bloc.getTotalKcalBurned(user, activity, 60.0);
      expect(kcal60, closeTo(kcal30 * 2, 1.0));
    });
  });
}
