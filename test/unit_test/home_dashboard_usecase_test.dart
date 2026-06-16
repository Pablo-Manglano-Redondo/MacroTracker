import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/physical_activity_entity.dart';
import 'package:macrotracker/core/domain/usecase/calculate_food_quality_score_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/get_body_progress_usecase.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_progress_summary_entity.dart';
import 'package:macrotracker/features/home/domain/usecase/load_home_dashboard_usecase.dart';
import 'package:macrotracker/features/home/domain/usecase/sync_home_tracked_day_usecase.dart';
import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_plan_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/process_pending_syncs_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/upload_professional_snapshot_usecase.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import '../fixture/user_entity_fixtures.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

class _FakeGetConfigUsecase extends Fake implements GetConfigUsecase {
  @override
  Future<ConfigEntity> getConfig() async => const ConfigEntity(
        false,
        false,
        false,
        AppThemeEntity.system,
      );
}

class _FakeGetUserUsecase extends Fake implements GetUserUsecase {
  final UserEntity user;
  _FakeGetUserUsecase(this.user);

  @override
  Future<UserEntity> getUserData() async => user;
}

class _FakeGetIntakeUsecase extends Fake implements GetIntakeUsecase {
  final List<IntakeEntity> intakes;
  _FakeGetIntakeUsecase(this.intakes);

  @override
  Future<List<IntakeEntity>> getTodayBreakfastIntake() async =>
      intakes.where((i) => i.type == IntakeTypeEntity.breakfast).toList();

  @override
  Future<List<IntakeEntity>> getTodayLunchIntake() async =>
      intakes.where((i) => i.type == IntakeTypeEntity.lunch).toList();

  @override
  Future<List<IntakeEntity>> getTodayDinnerIntake() async =>
      intakes.where((i) => i.type == IntakeTypeEntity.dinner).toList();

  @override
  Future<List<IntakeEntity>> getTodaySnackIntake() async =>
      intakes.where((i) => i.type == IntakeTypeEntity.snack).toList();
}

class _FakeGetUserActivityUsecase extends Fake
    implements GetUserActivityUsecase {
  final List<UserActivityEntity> activities;
  _FakeGetUserActivityUsecase(this.activities);

  @override
  Future<List<UserActivityEntity>> getTodayUserActivity() async => activities;
}

class _FakeGetKcalGoalUsecase extends Fake implements GetKcalGoalUsecase {
  @override
  Future<double> getKcalGoal(
          {UserEntity? userEntity,
          double? totalKcalActivitiesParam,
          double? kcalUserAdjustment}) async =>
      2000.0;
}

class _FakeGetMacroGoalUsecase extends Fake implements GetMacroGoalUsecase {
  @override
  Future<double> getCarbsGoal(double kcalGoal) async => 250.0;
  @override
  Future<double> getFatsGoal(double kcalGoal) async => 60.0;
  @override
  Future<double> getProteinsGoal(double kcalGoal) async => 120.0;
}

class _FakeGetProfessionalPlanUsecase extends Fake
    implements GetProfessionalPlanUsecase {
  final ProfessionalConnectionEntity? connection;
  _FakeGetProfessionalPlanUsecase(this.connection);

  @override
  Future<ProfessionalConnectionEntity?> getActiveConnection(
          {bool refreshRemotePlan = false}) async =>
      connection;
}

class _FakeUploadProfessionalSnapshotUsecase extends Fake
    implements UploadProfessionalSnapshotUsecase {
  int uploadCalls = 0;

  @override
  Future<void> uploadDailySnapshot({
    required ProfessionalConnectionEntity connection,
    required DateTime day,
    required double kcalActual,
    required double kcalTarget,
    required double carbsActual,
    required double carbsTarget,
    required double fatActual,
    required double fatTarget,
    required double proteinActual,
    required double proteinTarget,
    required int mealsLogged,
    String? notes,
    double? weightKg,
    double? waistCm,
  }) async {
    uploadCalls++;
  }
}

class _FakeProcessPendingSyncsUsecase extends Fake
    implements ProcessPendingSyncsUsecase {
  int processCalls = 0;

  @override
  Future<void> execute() async {
    processCalls++;
  }
}

class _FakeGetBodyProgressUsecase extends Fake
    implements GetBodyProgressUsecase {
  @override
  Future<BodyProgressSummaryEntity> getSummary(
          {DateTime? referenceDay}) async =>
      BodyProgressSummaryEntity(
        latestMeasurementDay: DateTime.now(),
        latestWeightKg: 80.0,
        latestWaistCm: 85.0,
        rollingWeightAverageKg: 80.0,
        previousRollingWeightAverageKg: 80.0,
        weeklyWeightDeltaKg: 0.0,
        latestWaistDeltaCm: 0.0,
      );
}

class _FakeProfessionalPlanRepository extends Fake
    implements ProfessionalPlanRepository {
  int uploadDiaryCalls = 0;

  @override
  Future<String?> getDailyNote(DateTime day) async => 'Test note';

  @override
  Future<void> uploadDiaryEntries({
    required ProfessionalConnectionEntity connection,
    required DateTime day,
    required List<Map<String, dynamic>> entries,
  }) async {
    uploadDiaryCalls++;
  }
}

class _FakeSyncHomeTrackedDayUsecase extends Fake
    implements SyncHomeTrackedDayUsecase {
  int syncCalls = 0;

  @override
  Future<bool> execute({
    required DateTime day,
    UserWeightGoalEntity? phase,
    DailyFocusEntity? dailyFocus,
    UserEntity? user,
    ProfessionalConnectionEntity? professionalConnection,
  }) async {
    syncCalls++;
    return true;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('LoadHomeDashboardUsecase Tests', () {
    final day = DateTime(2026, 6, 16);
    final user = UserEntityFixtures.youngSedentaryMaleWantingToMaintainWeight;

    test('Loads dashboard successfully without professional plan', () async {
      final meal = MealEntity(
        code: 'm1',
        name: 'Meal 1',
        url: null,
        mealQuantity: null,
        mealUnit: 'g',
        servingQuantity: null,
        servingUnit: 'g',
        servingSize: '',
        source: MealSourceEntity.custom,
        nutriments: const MealNutrimentsEntity(
          energyKcal100: 100,
          carbohydrates100: 20,
          fat100: 5,
          proteins100: 10,
          sugars100: 0,
          saturatedFat100: 0,
          fiber100: 0,
        ),
      );
      final intake = IntakeEntity(
        id: 'i1',
        amount: 100,
        unit: 'g',
        dateTime: day,
        type: IntakeTypeEntity.breakfast,
        meal: meal,
      );

      final activity = UserActivityEntity(
        'a1',
        30,
        200,
        day,
        const PhysicalActivityEntity(
          'running',
          'Running',
          'Running',
          8.0,
          [],
          PhysicalActivityTypeEntity.running,
        ),
      );

      final loadUsecase = LoadHomeDashboardUsecase(
        _FakeGetConfigUsecase(),
        _FakeGetUserUsecase(user),
        _FakeGetIntakeUsecase([intake]),
        _FakeGetUserActivityUsecase([activity]),
        _FakeGetKcalGoalUsecase(),
        _FakeGetMacroGoalUsecase(),
        CalculateFoodQualityScoreUsecase(),
        _FakeGetProfessionalPlanUsecase(null),
        _FakeUploadProfessionalSnapshotUsecase(),
        _FakeProcessPendingSyncsUsecase(),
        _FakeGetBodyProgressUsecase(),
        _FakeProfessionalPlanRepository(),
        _FakeSyncHomeTrackedDayUsecase(),
      );

      final data = await loadUsecase.execute(day: day);

      expect(data.breakfastIntakeList, hasLength(1));
      expect(data.totalKcalIntake, equals(100.0));
      expect(data.totalKcalActivities, equals(200.0));
      expect(data.professionalConnection, isNull);
    });

    test(
        'Consents and uploads snapshot when connection sharingMode is detailed',
        () async {
      final connection = ProfessionalConnectionEntity(
        relationshipId: 'c1',
        professionalId: 'prof1',
        clientId: 'client1',
        professionalName: 'Coach A',
        connectedAt: DateTime.now(),
        consentAcceptedAt: DateTime.now(),
        lastPlanSyncAt: null,
        lastSnapshotSyncAt: null,
        pendingSyncCount: 0,
        sharingMode: 'detailed',
        messagesEnabled: true,
        connectionStatus: 'active',
        activePlan: NutritionPlanEntity(
          id: 'p1',
          professionalId: 'prof1',
          clientId: 'client1',
          name: 'Nutrition Plan',
          objective: 'Maintain',
          notes: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          startsOn: DateTime.now(),
          endsOn: null,
          days: const [],
          meals: const [],
        ),
      );

      final uploader = _FakeUploadProfessionalSnapshotUsecase();
      final profRepo = _FakeProfessionalPlanRepository();

      final loadUsecase = LoadHomeDashboardUsecase(
        _FakeGetConfigUsecase(),
        _FakeGetUserUsecase(user),
        _FakeGetIntakeUsecase([]),
        _FakeGetUserActivityUsecase([]),
        _FakeGetKcalGoalUsecase(),
        _FakeGetMacroGoalUsecase(),
        CalculateFoodQualityScoreUsecase(),
        _FakeGetProfessionalPlanUsecase(connection),
        uploader,
        _FakeProcessPendingSyncsUsecase(),
        _FakeGetBodyProgressUsecase(),
        profRepo,
        _FakeSyncHomeTrackedDayUsecase(),
      );

      await loadUsecase.execute(
        day: day,
        uploadProfessionalSnapshot: true,
      );

      expect(uploader.uploadCalls, equals(1));
    });
  });
}
