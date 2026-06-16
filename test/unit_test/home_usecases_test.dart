import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/data/repository/user_repository.dart';
import 'package:macrotracker/core/data/dbo/config_dbo.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/physical_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/data/repository/tracked_day_repository.dart';
import 'package:macrotracker/core/data/dbo/tracked_day_dbo.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/features/home/domain/usecase/sync_home_tracked_day_usecase.dart';
import 'package:macrotracker/features/home_widget/domain/usecase/update_home_widget_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_plan_usecase.dart';
import '../fixture/user_entity_fixtures.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

class _FakeTrackedDayRepository extends Fake implements TrackedDayRepository {
  final Map<String, TrackedDayDBO> _store = {};
  int updateCalorieGoalCalls = 0;
  int updateMacroGoalCalls = 0;
  double? lastCalorieGoal;

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  void seed(DateTime day, {double calorieGoal = 2000}) {
    _store[_key(day)] = TrackedDayDBO(
      day: day,
      calorieGoal: calorieGoal,
      caloriesTracked: 0,
      carbsGoal: 300,
      carbsTracked: 0,
      fatGoal: 55,
      fatTracked: 0,
      proteinGoal: 100,
      proteinTracked: 0,
    );
  }

  @override
  Future<bool> hasTrackedDay(DateTime day) async =>
      _store.containsKey(_key(day));

  @override
  Future<TrackedDayEntity?> getTrackedDay(DateTime day) async {
    final dbo = _store[_key(day)];
    return dbo == null ? null : TrackedDayEntity.fromTrackedDayDBO(dbo);
  }

  @override
  Future<void> addNewTrackedDay(
      DateTime day,
      double totalKcalGoal,
      double totalCarbsGoal,
      double totalFatGoal,
      double totalProteinGoal) async {
    _store[_key(day)] = TrackedDayDBO(
      day: day,
      calorieGoal: totalKcalGoal,
      caloriesTracked: 0,
      carbsGoal: totalCarbsGoal,
      carbsTracked: 0,
      fatGoal: totalFatGoal,
      fatTracked: 0,
      proteinGoal: totalProteinGoal,
      proteinTracked: 0,
    );
  }

  @override
  Future<void> updateDayCalorieGoal(DateTime day, double calorieGoal) async {
    updateCalorieGoalCalls++;
    lastCalorieGoal = calorieGoal;
    final dbo = _store[_key(day)];
    if (dbo != null) dbo.calorieGoal = calorieGoal;
  }

  @override
  Future<void> updateDayMacroGoal(DateTime day,
      {double? carbGoal, double? fatGoal, double? proteinGoal}) async {
    updateMacroGoalCalls++;
  }

  @override
  Future<void> increaseDayCalorieGoal(DateTime day, double amount) async {}
  @override
  Future<void> reduceDayCalorieGoal(DateTime day, double amount) async {}
  @override
  Future<void> addDayTrackedCalories(DateTime day, double cal) async {}
  @override
  Future<void> removeDayTrackedCalories(DateTime day, double cal) async {}
  @override
  Future<void> increaseDayMacroGoal(DateTime day,
      {double? carbGoal, double? fatGoal, double? proteinGoal}) async {}
  @override
  Future<void> reduceDayMacroGoal(DateTime day,
      {double? carbGoal, double? fatGoal, double? proteinGoal}) async {}
  @override
  Future<void> addDayMacrosTracked(DateTime day,
      {double? carbsTracked,
      double? fatTracked,
      double? proteinTracked}) async {}
  @override
  Future<void> removeDayMacrosTracked(DateTime day,
      {double? carbsTracked,
      double? fatTracked,
      double? proteinTracked}) async {}
}

class _FakeUpdateHomeWidgetUsecase extends Fake
    implements UpdateHomeWidgetUsecase {
  @override
  Future<void> refreshToday() async {}
}

class _FakeConfigRepository extends Fake implements ConfigRepository {
  final ConfigDBO _dbo = ConfigDBO.empty();

  @override
  Future<ConfigEntity> getConfig() async => ConfigEntity.fromConfigDBO(_dbo);
}

class _FakeUserRepository extends Fake implements UserRepository {
  final UserEntity _user;
  _FakeUserRepository([UserEntity? user])
      : _user = user ??
            UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;
  @override
  Future<UserEntity> getUserData() async => _user;
}

class _FakeGetUserActivityUsecase extends Fake
    implements GetUserActivityUsecase {
  final List<UserActivityEntity> _activities;
  _FakeGetUserActivityUsecase([this._activities = const []]);

  @override
  Future<List<UserActivityEntity>> getUserActivityByDay(DateTime day) async =>
      _activities;
}

class _FakeGetProfessionalPlanUsecase extends Fake
    implements GetProfessionalPlanUsecase {
  @override
  Future<ProfessionalConnectionEntity?> getActiveConnection(
          {bool refreshRemotePlan = false}) async =>
      null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers to build the usecase chain
// ─────────────────────────────────────────────────────────────────────────────

SyncHomeTrackedDayUsecase _buildSync({
  _FakeTrackedDayRepository? trackedDayRepo,
  _FakeConfigRepository? configRepo,
  _FakeUserRepository? userRepo,
  _FakeGetUserActivityUsecase? activityUsecase,
}) {
  final tRepo = trackedDayRepo ?? _FakeTrackedDayRepository();
  final cRepo = configRepo ?? _FakeConfigRepository();
  final uRepo = userRepo ?? _FakeUserRepository();
  final aUsecase = activityUsecase ?? _FakeGetUserActivityUsecase();
  final widget = _FakeUpdateHomeWidgetUsecase();

  final addTrackedDay = AddTrackedDayUsecase(tRepo, widget);
  final getConfig = GetConfigUsecase(cRepo);
  final getUser = GetUserUsecase(uRepo);
  final getKcal = GetKcalGoalUsecase(uRepo, cRepo);
  final getMacro = GetMacroGoalUsecase(cRepo, uRepo);
  final getPlan = _FakeGetProfessionalPlanUsecase();

  return SyncHomeTrackedDayUsecase(
    addTrackedDay,
    getConfig,
    getUser,
    aUsecase,
    getKcal,
    getMacro,
    getPlan,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── SyncHomeTrackedDayUsecase ─────────────────────────────────────────────
  group('SyncHomeTrackedDayUsecase', () {
    final today = DateTime.now();

    test('returns false and does nothing when tracked day does not exist',
        () async {
      final tRepo = _FakeTrackedDayRepository(); // empty store
      final sync = _buildSync(trackedDayRepo: tRepo);
      final result = await sync.execute(day: today);
      expect(result, isFalse);
      expect(tRepo.updateCalorieGoalCalls, 0);
    });

    test('returns true and updates goals when tracked day exists', () async {
      final tRepo = _FakeTrackedDayRepository();
      tRepo.seed(today);
      final sync = _buildSync(trackedDayRepo: tRepo);
      final result = await sync.execute(day: today);
      expect(result, isTrue);
      expect(tRepo.updateCalorieGoalCalls, 1);
      expect(tRepo.updateMacroGoalCalls, 1);
    });

    test('calorie goal is positive for healthy user', () async {
      final tRepo = _FakeTrackedDayRepository();
      tRepo.seed(today);
      final sync = _buildSync(trackedDayRepo: tRepo);
      await sync.execute(day: today);
      expect(tRepo.lastCalorieGoal, isNotNull);
      expect(tRepo.lastCalorieGoal!, greaterThan(1000));
    });

    test('uses provided user directly without fetching from repo', () async {
      final tRepo = _FakeTrackedDayRepository();
      tRepo.seed(today);
      // user with much higher weight → different kcal
      final heavyUser =
          UserEntityFixtures.youngVeryActiveOverweightFemaleWantingToLoseWeight;
      final sync = _buildSync(trackedDayRepo: tRepo);
      final result = await sync.execute(
        day: today,
        user: heavyUser,
        dailyFocus: DailyFocusEntity.upperBody,
      );
      expect(result, isTrue);
    });

    test('uses provided professionalConnection instead of fetching', () async {
      final tRepo = _FakeTrackedDayRepository();
      tRepo.seed(today);
      final sync = _buildSync(trackedDayRepo: tRepo);
      // no active connection → falls back to app targets
      final result = await sync.execute(
        day: today,
        professionalConnection: null,
      );
      expect(result, isTrue);
    });

    test('activities burned kcal are NOT added to kcal goal', () async {
      final tRepo = _FakeTrackedDayRepository();
      tRepo.seed(today);
      // Add a 300 kcal activity
      final activity = UserActivityEntity(
        'a1',
        45,
        300,
        today,
        const PhysicalActivityEntity(
          'running',
          'Running',
          'Running',
          8.0,
          [],
          PhysicalActivityTypeEntity.running,
        ),
      );
      final syncWithActivity = _buildSync(
        trackedDayRepo: tRepo,
        activityUsecase: _FakeGetUserActivityUsecase([activity]),
      );
      await syncWithActivity.execute(day: today);
      // goal should be identical to baseline without activity
      final syncNoActivity = _FakeTrackedDayRepository();
      syncNoActivity.seed(today);
      final syncBaseline = _buildSync(trackedDayRepo: syncNoActivity);
      await syncBaseline.execute(day: today);
      expect(tRepo.lastCalorieGoal!, equals(syncNoActivity.lastCalorieGoal));
    });
  });

  // ── GetConfigUsecase ──────────────────────────────────────────────────────
  group('GetConfigUsecase', () {
    test('returns config from repository', () async {
      final repo = _FakeConfigRepository();
      final usecase = GetConfigUsecase(repo);
      final config = await usecase.getConfig();
      expect(config, isA<ConfigEntity>());
    });
  });

  // ── GetKcalGoalUsecase ────────────────────────────────────────────────────
  group('GetKcalGoalUsecase', () {
    test('returns positive kcal goal for typical user', () async {
      final uRepo = _FakeUserRepository();
      final cRepo = _FakeConfigRepository();
      final usecase = GetKcalGoalUsecase(uRepo, cRepo);
      final goal = await usecase.getKcalGoal(
        userEntity:
            UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight,
        totalKcalActivitiesParam: 0,
      );
      expect(goal, greaterThan(1200));
    });

    test('kcal goal remains same when activities are added', () async {
      final uRepo = _FakeUserRepository();
      final cRepo = _FakeConfigRepository();
      final usecase = GetKcalGoalUsecase(uRepo, cRepo);
      final user = UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;
      final base = await usecase.getKcalGoal(
          userEntity: user, totalKcalActivitiesParam: 0);
      final withActivity = await usecase.getKcalGoal(
          userEntity: user, totalKcalActivitiesParam: 300);
      expect(withActivity, equals(base));
    });

    test('fetches user from repo when not provided', () async {
      final uRepo = _FakeUserRepository();
      final cRepo = _FakeConfigRepository();
      final usecase = GetKcalGoalUsecase(uRepo, cRepo);
      final goal = await usecase.getKcalGoal();
      expect(goal, greaterThan(0));
    });
  });

  // ── GetUserUsecase ────────────────────────────────────────────────────────
  group('GetUserUsecase', () {
    test('getUserData returns user from repository', () async {
      final repo = _FakeUserRepository();
      final usecase = GetUserUsecase(repo);
      final user = await usecase.getUserData();
      expect(user.weightKG, 80.0);
    });
  });
}
