import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/commit_interpretation_draft_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/features/meal_capture/data/repository/interpretation_draft_repository.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeDraftRepository implements InterpretationDraftRepository {
  final Map<String, InterpretationDraftEntity> _store = {};
  final List<String> deletedIds = [];

  void seed(InterpretationDraftEntity draft) => _store[draft.id] = draft;

  @override
  Future<InterpretationDraftEntity?> getDraftById(String id) async =>
      _store[id];

  @override
  Future<void> deleteDraft(String id) async => deletedIds.add(id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddIntakeUsecase implements AddIntakeUsecase {
  final List<IntakeEntity> added = [];

  @override
  Future<void> addIntake(IntakeEntity intake) async => added.add(intake);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddTrackedDayUsecase implements AddTrackedDayUsecase {
  bool hasDay = false;
  final List<String> calls = [];

  @override
  Future<bool> hasTrackedDay(DateTime day) async => hasDay;

  @override
  Future<void> addNewTrackedDay(DateTime day, double totalKcalGoal,
      double? totalCarbsGoal, double? totalFatGoal,
      double? totalProteinGoal) async =>
      calls.add('addNewTrackedDay');

  @override
  Future<void> addDayCaloriesTracked(DateTime day, double kcal) async =>
      calls.add('addDayCaloriesTracked');

  @override
  Future<void> addDayMacrosTracked(DateTime day,
      {double? carbsTracked,
      double? fatTracked,
      double? proteinTracked}) async =>
      calls.add('addDayMacrosTracked');

  @override
  Future<void> updateDayCalorieGoal(DateTime day, double kcalGoal) async {}

  @override
  Future<void> updateDayMacroGoals(DateTime day,
      {double? carbsGoal, double? fatGoal, double? proteinGoal}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetGymTargetsUsecase implements GetGymTargetsUsecase {
  final GymTargetsEntity targets;

  _FakeGetGymTargetsUsecase(this.targets);

  @override
  Future<GymTargetsEntity> getTargetsForDay(
    DateTime day, {
    UserEntity? userEntity,
    UserWeightGoalEntity? phase,
    DailyFocusEntity? dailyFocus,
    double? totalKcalActivities,
  }) async =>
      targets;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

InterpretationDraftEntity _draft({
  String id = 'D1',
  double kcal = 500,
  double carbs = 60,
  double fat = 20,
  double protein = 30,
}) {
  final now = DateTime(2024, 1, 1);
  return InterpretationDraftEntity(
    id: id,
    sourceType: DraftSourceEntity.text,
    inputText: 'chicken rice',
    localImagePath: null,
    title: 'Chicken and Rice',
    summary: null,
    totalKcal: kcal,
    totalCarbs: carbs,
    totalFat: fat,
    totalProtein: protein,
    confidenceBand: ConfidenceBandEntity.high,
    status: DraftStatusEntity.ready,
    createdAt: now,
    expiresAt: now.add(const Duration(hours: 24)),
    items: [],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeDraftRepository fakeRepo;
  late _FakeAddIntakeUsecase fakeAddIntake;
  late _FakeAddTrackedDayUsecase fakeAddTrackedDay;
  late _FakeGetGymTargetsUsecase fakeGymTargets;
  late CommitInterpretationDraftUsecase usecase;

  const defaultTargets = GymTargetsEntity(
    kcalGoal: 2000,
    carbsGoal: 250,
    fatGoal: 70,
    proteinGoal: 150,
  );

  setUp(() {
    fakeRepo = _FakeDraftRepository();
    fakeAddIntake = _FakeAddIntakeUsecase();
    fakeAddTrackedDay = _FakeAddTrackedDayUsecase();
    fakeGymTargets = _FakeGetGymTargetsUsecase(defaultTargets);

    usecase = CommitInterpretationDraftUsecase(
      fakeRepo,
      fakeAddIntake,
      fakeAddTrackedDay,
      fakeGymTargets,
    );
  });

  group('CommitInterpretationDraftUsecase.getDraftById', () {
    test('returns null for non-existent draft', () async {
      final result = await usecase.getDraftById('nonexistent');
      expect(result, isNull);
    });

    test('returns seeded draft by id', () async {
      final draft = _draft(id: 'D-42');
      fakeRepo.seed(draft);

      final result = await usecase.getDraftById('D-42');
      expect(result, equals(draft));
    });
  });

  group('CommitInterpretationDraftUsecase.commitDraft', () {
    final day = DateTime(2024, 6, 15);

    test('adds one intake when commit is called', () async {
      final draft = _draft(kcal: 600, carbs: 70, fat: 25, protein: 35);

      await usecase.commitDraft(draft, IntakeTypeEntity.lunch, day);

      expect(fakeAddIntake.added.length, 1);
    });

    test('intake amount defaults to 1 serving', () async {
      final draft = _draft();
      await usecase.commitDraft(draft, IntakeTypeEntity.breakfast, day);

      final intake = fakeAddIntake.added.first;
      expect(intake.amount, 1.0);
      expect(intake.unit, 'serving');
    });

    test('intake amount respects custom servings', () async {
      final draft = _draft();
      await usecase.commitDraft(draft, IntakeTypeEntity.lunch, day,
          servings: 2.5);

      final intake = fakeAddIntake.added.first;
      expect(intake.amount, 2.5);
    });

    test('intake type matches the provided intake type', () async {
      final draft = _draft();
      await usecase.commitDraft(draft, IntakeTypeEntity.dinner, day);

      final intake = fakeAddIntake.added.first;
      expect(intake.type, IntakeTypeEntity.dinner);
    });

    test('deletes draft after commit', () async {
      final draft = _draft(id: 'D99');
      fakeRepo.seed(draft);

      await usecase.commitDraft(draft, IntakeTypeEntity.snack, day);

      expect(fakeRepo.deletedIds, contains('D99'));
    });

    test('creates tracked day when not already existing', () async {
      fakeAddTrackedDay.hasDay = false;
      final draft = _draft();

      await usecase.commitDraft(draft, IntakeTypeEntity.lunch, day);

      expect(fakeAddTrackedDay.calls,
          contains('addNewTrackedDay'));
      expect(fakeAddTrackedDay.calls,
          contains('addDayCaloriesTracked'));
      expect(fakeAddTrackedDay.calls,
          contains('addDayMacrosTracked'));
    });

    test('does NOT create tracked day when one already exists', () async {
      fakeAddTrackedDay.hasDay = true;
      final draft = _draft();

      await usecase.commitDraft(draft, IntakeTypeEntity.lunch, day);

      expect(fakeAddTrackedDay.calls,
          isNot(contains('addNewTrackedDay')));
      // But still updates tracked macros/kcal
      expect(fakeAddTrackedDay.calls,
          contains('addDayCaloriesTracked'));
    });

    test('intake dateTime is set to the provided day', () async {
      final draft = _draft();
      await usecase.commitDraft(draft, IntakeTypeEntity.lunch, day);

      final intake = fakeAddIntake.added.first;
      expect(intake.dateTime, day);
    });
  });
}
