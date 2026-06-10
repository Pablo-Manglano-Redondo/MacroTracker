import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/data/repository/user_repository.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_user_usecase.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/features/body_progress/data/dbo/body_measurement_dbo.dart';
import 'package:macrotracker/features/body_progress/data/repository/body_measurement_repository.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_measurement_entity.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/save_body_measurement_usecase.dart';

void main() {
  late SaveBodyMeasurementUsecase usecase;
  late _FakeBodyMeasurementRepository fakeRepo;
  late _FakeGetUserUsecase fakeGetUser;
  late _FakeAddUserUsecase fakeAddUser;
  late _FakeAddTrackedDayUsecase fakeAddTrackedDay;
  late _FakeGetGymTargetsUsecase fakeGetGymTargets;

  setUp(() {
    fakeRepo = _FakeBodyMeasurementRepository();
    fakeGetUser = _FakeGetUserUsecase();
    fakeAddUser = _FakeAddUserUsecase();
    fakeAddTrackedDay = _FakeAddTrackedDayUsecase();
    fakeGetGymTargets = _FakeGetGymTargetsUsecase();
    usecase = SaveBodyMeasurementUsecase(
      fakeRepo,
      fakeGetUser,
      fakeAddUser,
      fakeAddTrackedDay,
      fakeGetGymTargets,
    );
  });

  test('saves weight measurement', () async {
    final day = DateTime(2026, 6, 1);

    await usecase.saveMeasurement(day: day, weightKg: 80);

    expect(fakeRepo.savedMeasurement, isNotNull);
    expect(fakeRepo.savedMeasurement!.weightKg, 80);
    expect(fakeRepo.savedMeasurement!.waistCm, isNull);
  });

  test('saves waist measurement', () async {
    final day = DateTime(2026, 6, 1);

    await usecase.saveMeasurement(day: day, waistCm: 82);

    expect(fakeRepo.savedMeasurement, isNotNull);
    expect(fakeRepo.savedMeasurement!.waistCm, 82);
    expect(fakeRepo.savedMeasurement!.weightKg, isNull);
  });

  test('saves full measurement with all fields', () async {
    final day = DateTime(2026, 6, 1);

    await usecase.saveMeasurement(
        day: day, weightKg: 80, waistCm: 82, bodyFatPct: 15);

    expect(fakeRepo.savedMeasurement!.weightKg, 80);
    expect(fakeRepo.savedMeasurement!.waistCm, 82);
    expect(fakeRepo.savedMeasurement!.bodyFatPct, 15);
    expect(fakeRepo.savedMeasurement!.day, DateTime(2026, 6, 1));
  });

  test('returns early when all fields are null', () async {
    await usecase.saveMeasurement(day: DateTime(2026, 6, 1));

    expect(fakeRepo.savedMeasurement, isNull);
  });

  test('merges with existing measurement', () async {
    final day = DateTime(2026, 6, 1);
    fakeRepo.existingMeasurement = BodyMeasurementEntity(
      day: day,
      weightKg: 80,
      waistCm: 82,
    );

    await usecase.saveMeasurement(day: day, bodyFatPct: 15);

    expect(fakeRepo.savedMeasurement!.weightKg, 80); // from existing
    expect(fakeRepo.savedMeasurement!.waistCm, 82); // from existing
    expect(fakeRepo.savedMeasurement!.bodyFatPct, 15); // new value
  });

  test('updates user weight when weight is saved for today', () async {
    final today = DateTime.now();
    fakeGetUser.user = UserEntity(
      birthday: DateTime(2000, 1, 1),
      heightCM: 180,
      weightKG: 80,
      gender: UserGenderEntity.male,
      goal: UserWeightGoalEntity.maintainWeight,
      pal: UserPALEntity.active,
    );
    fakeAddTrackedDay.hasDay = true;

    await usecase.saveMeasurement(day: today, weightKg: 82);

    expect(fakeAddUser.savedUser!.weightKG, 82);
    expect(fakeAddTrackedDay.updatedGoalDay, today);
  });

  test('does not update user weight when saving non-today measurement',
      () async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    await usecase.saveMeasurement(day: yesterday, weightKg: 82);

    expect(fakeAddUser.savedUser, isNull);
  });
}

class _FakeBodyMeasurementRepository implements BodyMeasurementRepository {
  BodyMeasurementEntity? savedMeasurement;
  BodyMeasurementEntity? existingMeasurement;

  @override
  Future<void> saveMeasurement(BodyMeasurementEntity measurement) async {
    savedMeasurement = measurement;
  }

  @override
  Future<BodyMeasurementEntity?> getMeasurement(DateTime day) async =>
      existingMeasurement;

  @override
  Future<List<BodyMeasurementEntity>> getAllMeasurements() async => [];

  @override
  Future<List<BodyMeasurementDBO>> getAllMeasurementsDBO() async => [];

  @override
  Future<void> addAllMeasurements(List<BodyMeasurementDBO> measurements) async {}
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

class _FakeAddUserUsecase implements AddUserUsecase {
  UserEntity? savedUser;

  @override
  Future<void> addUser(UserEntity user) async {
    savedUser = user;
  }
}

class _FakeAddTrackedDayUsecase implements AddTrackedDayUsecase {
  bool hasDay = true;
  DateTime? updatedGoalDay;

  @override
  Future<bool> hasTrackedDay(DateTime day) async => hasDay;

  @override
  Future<void> updateDayCalorieGoal(DateTime day, double goal) async {
    updatedGoalDay = day;
  }

  @override
  Future<void> updateDayMacroGoals(DateTime day,
      {double? carbsGoal, double? fatGoal, double? proteinGoal}) async {}

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

class _FakeGetGymTargetsUsecase implements GetGymTargetsUsecase {
  @override
  Future<GymTargetsEntity> getTargetsForDay(
    DateTime day, {
    UserEntity? userEntity,
    UserWeightGoalEntity? phase,
    DailyFocusEntity? dailyFocus,
    double? totalKcalActivities,
  }) async => const GymTargetsEntity(
        kcalGoal: 2500, carbsGoal: 300, fatGoal: 70, proteinGoal: 150,
      );
}
