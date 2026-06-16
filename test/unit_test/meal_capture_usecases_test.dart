import 'dart:io';

import 'package:flutter/services.dart';
import '../fixture/meal_entity_fixtures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/features/meal_capture/data/repository/meal_interpretation_repository.dart';
import 'package:macrotracker/features/meal_capture/data/repository/interpretation_draft_repository.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/ai_food_memory_entry.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/interpret_meal_from_photo_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/interpret_meal_from_text_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/get_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/save_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/commit_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/meal_interpretation_personalization_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_recipe_library_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_frequent_intake_presets_usecase.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/frequent_intake_preset_entity.dart';
import 'package:macrotracker/features/meal_capture/data/data_source/meal_interpretation_remote_data_source.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';
import 'package:macrotracker/core/utils/locator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late HiveDBProvider hiveProvider;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('macrotracker_meal_capture_test_');

    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return tempDir.path;
    });

    hiveProvider = HiveDBProvider();
    final key = Hive.generateSecureKey();
    await hiveProvider.initHiveDB(Uint8List.fromList(key));

    if (locator.isRegistered<HiveDBProvider>()) {
      await locator.unregister<HiveDBProvider>();
    }
    locator.registerSingleton<HiveDBProvider>(hiveProvider);
  });

  tearDown(() async {
    await hiveProvider.clearAllData();
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    await locator.reset();
  });

  group('InterpretMealFromPhotoUsecase', () {
    test('delegates interpretPhoto calls to repository', () async {
      final repo = _FakeMealInterpretationRepository();
      final draft = _dummyDraft();
      repo.dummyDraft = draft;

      final usecase = InterpretMealFromPhotoUsecase(repo);
      final result = await usecase.interpret(
        imageBytes: Uint8List(0),
        fileName: 'test.jpg',
        mimeType: 'image/jpeg',
        locale: 'es',
        unitSystem: 'metric',
      );

      expect(repo.interpretPhotoCalled, isTrue);
      expect(result.id, draft.id);
    });

    test('delegates interpretPhotoWithDiagnostics calls to repository', () async {
      final repo = _FakeMealInterpretationRepository();
      final draft = _dummyDraft();
      final remoteResult = MealInterpretationRemoteResult(
        draft: draft,
        estimatedCostUsd: 0.002,
        diagnostics: const MealInterpretationRemoteDiagnostics(edgeTotalMs: 120),
      );
      repo.dummyResult = remoteResult;

      final usecase = InterpretMealFromPhotoUsecase(repo);
      final result = await usecase.interpretWithDiagnostics(
        imageBytes: Uint8List(0),
        fileName: 'test.jpg',
        mimeType: 'image/jpeg',
        locale: 'es',
        unitSystem: 'metric',
      );

      expect(repo.interpretPhotoWithDiagnosticsCalled, isTrue);
      expect(result.draft.id, draft.id);
      expect(result.estimatedCostUsd, 0.002);
    });
  });

  group('InterpretMealFromTextUsecase', () {
    test('delegates interpretText calls to repository', () async {
      final repo = _FakeMealInterpretationRepository();
      final draft = _dummyDraft();
      repo.dummyDraft = draft;

      final usecase = InterpretMealFromTextUsecase(repo);
      final result = await usecase.interpret(
        text: 'Manzana y platano',
        locale: 'es',
        unitSystem: 'metric',
      );

      expect(repo.interpretTextCalled, isTrue);
      expect(result.id, draft.id);
    });
  });

  group('GetInterpretationDraftUsecase and SaveInterpretationDraftUsecase', () {
    test('saves, retrieves and lists drafts correctly', () async {
      final repo = _FakeInterpretationDraftRepository();
      final saveUsecase = SaveInterpretationDraftUsecase(repo);
      final getUsecase = GetInterpretationDraftUsecase(repo);

      final draft1 = _dummyDraft(id: 'draft-1');
      final draft2 = _dummyDraft(id: 'draft-2');

      await saveUsecase.saveDraft(draft1);
      await saveUsecase.saveDraft(draft2);

      final fetched = await getUsecase.getDraftById('draft-1');
      expect(fetched, isNotNull);
      expect(fetched!.id, 'draft-1');

      final all = await getUsecase.getAllDrafts();
      expect(all.length, 2);
      expect(repo.saveDraftCalled, isTrue);
    });
  });

  group('CommitInterpretationDraftUsecase', () {
    test('commits draft to intakes database, updates tracked day targets and clears draft', () async {
      final repo = _FakeInterpretationDraftRepository();
      final addIntake = _FakeAddIntakeUsecase();
      final addTrackedDay = _FakeAddTrackedDayUsecase();
      final getGymTargets = _FakeGetGymTargetsUsecase();

      final usecase = CommitInterpretationDraftUsecase(
        repo,
        addIntake,
        addTrackedDay,
        getGymTargets,
      );

      final draft = _dummyDraft(id: 'draft-commit');
      await repo.saveDraft(draft);

      final day = DateTime.now();
      await usecase.commitDraft(draft, IntakeTypeEntity.lunch, day);

      expect(addIntake.addedIntake, isNotNull);
      expect(addIntake.addedIntake!.type, IntakeTypeEntity.lunch);
      expect(addIntake.addedIntake!.meal.name, draft.title);
      expect(addIntake.addedIntake!.totalKcal, draft.totalKcal);

      // Tracked day should have been updated/created
      expect(addTrackedDay.addedDay, isNotNull);
      expect(addTrackedDay.addedKcal, 2000);
      expect(addTrackedDay.caloriesAdded, draft.totalKcal);
      expect(addTrackedDay.carbsAdded, draft.totalCarbs);

      // Draft must be deleted
      expect(repo.deleteDraftCalled, isTrue);
      expect(await repo.getDraftById('draft-commit'), isNull);
    });
  });

  group('MealInterpretationPersonalizationUsecase', () {
    late _FakeGetRecipeLibraryUsecase getRecipeLibrary;
    late _FakeGetFrequentIntakePresetsUsecase getPresets;
    late _FakeGetConfigUsecase getConfig;
    late _FakeGetUserUsecase getUser;
    late MealInterpretationPersonalizationUsecase personalizationUsecase;

    setUp(() {
      getRecipeLibrary = _FakeGetRecipeLibraryUsecase();
      getPresets = _FakeGetFrequentIntakePresetsUsecase();
      getConfig = _FakeGetConfigUsecase();
      getUser = _FakeGetUserUsecase();

      personalizationUsecase = MealInterpretationPersonalizationUsecase(
        getRecipeLibrary,
        getPresets,
        getConfig,
        getUser,
      );
    });

    test('buildContext constructs personal context and remote examples', () async {
      final user = UserEntity(
        birthday: DateTime(1990, 1, 1),
        heightCM: 180,
        weightKG: 80,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.sedentary,
      );
      getUser.user = user;

      final config = const ConfigEntity(
        true,
        true,
        true,
        AppThemeEntity.system,
        dailyFocus: DailyFocusEntity.lowerBody,
      );
      getConfig.config = config;

      getRecipeLibrary.recipes = [
        RecipeEntity(
          id: 'recipe-egg',
          name: 'Scrambled Eggs',
          notes: 'Eggs with salt',
          defaultServings: 2,
          yieldQuantity: null,
          yieldUnit: null,
          saved: true,
          pinned: false,
          timesUsed: 5,
          lastUsedAt: null,
          quickCategory: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          ingredients: const [],
        )
      ];

      final context = await personalizationUsecase.buildContext(
        intakeType: IntakeTypeEntity.breakfast,
        freeText: 'Eggs',
      );

      expect(context.promptContext, contains('lower body'));
      expect(context.promptContext, contains('recomposition'));
      expect(context.candidates.isNotEmpty, isTrue);
      expect(context.candidates.any((c) => c.title == 'Scrambled Eggs'), isTrue);
    });

    test('personalizeDraft corrects items using local food memories and enforces macro coherence', () async {
      // Setup local corrections in Hive
      final box = await Hive.openBox(MealInterpretationPersonalizationUsecase.aiMemoryBoxName);
      final memory = AiFoodMemoryEntry(
        key: 'huevos',
        displayLabel: 'Huevos',
        amount: 2,
        unit: 'serving',
        kcal: 140,
        carbs: 2,
        fat: 10,
        protein: 12,
        mealSnapshot: null,
        uses: 3,
        updatedAt: DateTime.now(),
      );
      await box.put(memory.key, memory.toMap());

      final draft = InterpretationDraftEntity(
        id: 'draft-pers',
        sourceType: DraftSourceEntity.text,
        inputText: 'huevos',
        localImagePath: null,
        title: 'Huevos',
        summary: 'Huevos fritos',
        totalKcal: 200,
        totalCarbs: 10,
        totalFat: 15,
        totalProtein: 10,
        confidenceBand: ConfidenceBandEntity.low,
        status: DraftStatusEntity.ready,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        items: const [
          InterpretationDraftItemEntity(
            id: 'item-egg',
            label: 'Huevos',
            matchedMealSnapshot: null,
            amount: 1,
            unit: 'serving',
            kcal: 200,
            carbs: 10,
            fat: 15,
            protein: 10,
            confidenceBand: ConfidenceBandEntity.low,
            editable: true,
            removed: false,
          ),
        ],
      );

      final personalized = await personalizationUsecase.personalizeDraft(
        draft: draft,
        intakeType: IntakeTypeEntity.breakfast,
      );

      // Verify that amounts and macros were updated from the memory
      expect(personalized.items.first.amount, 2);
      expect(personalized.items.first.kcal, 140.0); // 140 is within 15% tolerance of 146, so it's not modified.
      expect(personalized.totalProtein, 12);
    });

    test('suggestMealsForDraft ranks suggestions appropriately', () async {
      final user = UserEntity(
        birthday: DateTime(1995, 5, 5),
        heightCM: 170,
        weightKG: 65,
        gender: UserGenderEntity.female,
        goal: UserWeightGoalEntity.loseWeight,
        pal: UserPALEntity.active,
      );
      getUser.user = user;
      getConfig.config = const ConfigEntity(true, true, true, AppThemeEntity.system);

      getRecipeLibrary.recipes = [
        RecipeEntity(
          id: 'egg-recipe',
          name: 'Fried Eggs',
          notes: null,
          defaultServings: 1,
          yieldQuantity: null,
          yieldUnit: null,
          saved: true,
          pinned: false,
          timesUsed: 2,
          lastUsedAt: null,
          quickCategory: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          ingredients: const [],
        )
      ];

      final draft = _dummyDraft(title: 'Fried Eggs');
      final suggestions = await personalizationUsecase.suggestMealsForDraft(
        draft: draft,
        intakeType: IntakeTypeEntity.breakfast,
      );

      expect(suggestions.isNotEmpty, isTrue);
      expect(suggestions.first.title, 'Fried Eggs');
    });

    test('buildFallbackDraft returns a local match or a zero-kcal draft when remote fails', () async {
      final user = UserEntity(
        birthday: DateTime(1990, 10, 10),
        heightCM: 175,
        weightKG: 70,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.loseWeight,
        pal: UserPALEntity.sedentary,
      );
      getUser.user = user;
      getConfig.config = const ConfigEntity(true, true, true, AppThemeEntity.system);

      final draft = await personalizationUsecase.buildFallbackDraft(
        sourceType: DraftSourceEntity.text,
        title: 'Unknown Food Platter',
        intakeType: IntakeTypeEntity.dinner,
        inputText: 'Unknown Food Platter',
      );

      expect(draft.totalKcal, 0);
      expect(draft.items.first.label, 'Unknown Food Platter');
      expect(draft.confidenceBand, ConfidenceBandEntity.low);
    });

    test('saveMealMemoryFromDraft saves a correct representation to Hive box', () async {
      final draft = _dummyDraft(title: 'Post-workout Shake');
      await personalizationUsecase.saveMealMemoryFromDraft(
        draft: draft,
        intakeType: IntakeTypeEntity.snack,
      );

      final box = await Hive.openBox(MealInterpretationPersonalizationUsecase.aiMealMemoryBoxName);
      expect(box.length, 1);
      final rawEntry = box.values.single;
      expect(rawEntry, isA<Map>());
      expect(rawEntry['title'], 'Post-workout Shake');
    });

    test('personalizeDraft corrects items using local food memories with a meal snapshot', () async {
      final box = await Hive.openBox(MealInterpretationPersonalizationUsecase.aiMemoryBoxName);
      final memory = AiFoodMemoryEntry(
        key: 'manzana',
        displayLabel: 'Manzana',
        amount: 2.0,
        unit: 'medium',
        kcal: 190,
        carbs: 50,
        fat: 0.6,
        protein: 1.0,
        mealSnapshot: MealEntityFixtures.mealOne,
        uses: 3,
        updatedAt: DateTime.now(),
      );
      await box.put(memory.key, memory.toMap());

      final draft = _dummyDraft(title: 'Manzana').copyWith(
        items: const [
          InterpretationDraftItemEntity(
            id: 'item-apple',
            label: 'Manzana',
            matchedMealSnapshot: null,
            amount: 1,
            unit: 'medium',
            kcal: 95,
            carbs: 25,
            fat: 0.3,
            protein: 0.5,
            confidenceBand: ConfidenceBandEntity.high,
            editable: true,
            removed: false,
          ),
        ],
      );
      final personalized = await personalizationUsecase.personalizeDraft(
        draft: draft,
        intakeType: IntakeTypeEntity.breakfast,
      );

      expect(personalized.items.first.amount, 2.0);
      expect(personalized.items.first.unit, 'medium');
      expect(personalized.items.first.matchedMealSnapshot, isNotNull);
    });

    test('personalizeDraft validates macro coherence and adjusts kcal and confidence', () async {
      final draft = InterpretationDraftEntity(
        id: 'draft-coherence',
        sourceType: DraftSourceEntity.text,
        inputText: 'some food',
        localImagePath: null,
        title: 'Non-coherent Food',
        summary: 'Non-coherent macros',
        totalKcal: 300,
        totalCarbs: 10,
        totalFat: 10,
        totalProtein: 10,
        confidenceBand: ConfidenceBandEntity.high,
        status: DraftStatusEntity.ready,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        items: const [
          InterpretationDraftItemEntity(
            id: 'item-coherence',
            label: 'Some food',
            matchedMealSnapshot: null,
            amount: 1,
            unit: 'serving',
            kcal: 300,
            carbs: 10,
            fat: 10,
            protein: 10,
            confidenceBand: ConfidenceBandEntity.high,
            editable: true,
            removed: false,
          ),
        ],
      );

      final personalized = await personalizationUsecase.personalizeDraft(
        draft: draft,
        intakeType: IntakeTypeEntity.breakfast,
      );

      expect(personalized.items.first.kcal, 170.0);
      expect(personalized.items.first.confidenceBand, ConfidenceBandEntity.medium);
    });

    test('buildFallbackDraft returns a local match when it matches a recipe', () async {
      final user = UserEntity(
        birthday: DateTime(1990, 10, 10),
        heightCM: 175,
        weightKG: 70,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.loseWeight,
        pal: UserPALEntity.sedentary,
      );
      getUser.user = user;
      getConfig.config = const ConfigEntity(true, true, true, AppThemeEntity.system);

      getRecipeLibrary.recipes = [
        RecipeEntity(
          id: 'rec-egg-fallback',
          name: 'Healthy Scrambled Eggs',
          notes: 'Eggs with salt',
          defaultServings: 1,
          yieldQuantity: null,
          yieldUnit: null,
          saved: true,
          pinned: false,
          timesUsed: 5,
          lastUsedAt: null,
          quickCategory: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          ingredients: const [],
        )
      ];

      final draft = await personalizationUsecase.buildFallbackDraft(
        sourceType: DraftSourceEntity.text,
        title: 'Healthy Scrambled Eggs',
        intakeType: IntakeTypeEntity.breakfast,
        inputText: 'Healthy Scrambled Eggs',
      );

      expect(draft.items.first.label, 'Healthy Scrambled Eggs');
      expect(draft.confidenceBand, ConfidenceBandEntity.medium);
    });

    test('saveMealMemoryFromDraft handles empty items, empty titles, and empty keys', () async {
      final emptyDraft = InterpretationDraftEntity(
        id: 'draft-empty',
        sourceType: DraftSourceEntity.text,
        inputText: '',
        localImagePath: null,
        title: 'Empty',
        summary: '',
        totalKcal: 0,
        totalCarbs: 0,
        totalFat: 0,
        totalProtein: 0,
        confidenceBand: ConfidenceBandEntity.low,
        status: DraftStatusEntity.ready,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        items: const [],
      );

      await personalizationUsecase.saveMealMemoryFromDraft(
        draft: emptyDraft,
        intakeType: IntakeTypeEntity.snack,
      );

      final draftNoTitle = _dummyDraft(title: '');
      await personalizationUsecase.saveMealMemoryFromDraft(
        draft: draftNoTitle,
        intakeType: IntakeTypeEntity.snack,
      );

      final box = await Hive.openBox(MealInterpretationPersonalizationUsecase.aiMealMemoryBoxName);
      expect(box.length, 1);
    });
  });
}

InterpretationDraftEntity _dummyDraft({String id = 'draft-id', String title = 'Manzana'}) {
  return InterpretationDraftEntity(
    id: id,
    sourceType: DraftSourceEntity.text,
    inputText: 'manzana',
    localImagePath: null,
    title: title,
    summary: 'Una manzana roja fresca.',
    totalKcal: 95,
    totalCarbs: 25,
    totalFat: 0.3,
    totalProtein: 0.5,
    confidenceBand: ConfidenceBandEntity.high,
    status: DraftStatusEntity.ready,
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(days: 1)),
    items: const [
      InterpretationDraftItemEntity(
        id: 'item-apple',
        label: 'Manzana roja',
        matchedMealSnapshot: null,
        amount: 1,
        unit: 'medium',
        kcal: 95,
        carbs: 25,
        fat: 0.3,
        protein: 0.5,
        confidenceBand: ConfidenceBandEntity.high,
        editable: true,
        removed: false,
      ),
    ],
  );
}

class _FakeMealInterpretationRepository implements MealInterpretationRepository {
  InterpretationDraftEntity? dummyDraft;
  MealInterpretationRemoteResult? dummyResult;
  bool interpretPhotoCalled = false;
  bool interpretTextCalled = false;
  bool interpretPhotoWithDiagnosticsCalled = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<InterpretationDraftEntity> interpretText({
    required String text,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
    String? analysisContext,
    List<Map<String, dynamic>> personalExamples = const [],
  }) async {
    interpretTextCalled = true;
    return dummyDraft!;
  }

  @override
  Future<InterpretationDraftEntity> interpretPhoto({
    required Uint8List imageBytes,
    required String fileName,
    required String mimeType,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
    String? analysisContext,
    List<Map<String, dynamic>> personalExamples = const [],
  }) async {
    interpretPhotoCalled = true;
    return dummyDraft!;
  }

  @override
  Future<MealInterpretationRemoteResult> interpretPhotoWithDiagnostics({
    required Uint8List imageBytes,
    required String fileName,
    required String mimeType,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
    String? analysisContext,
    List<Map<String, dynamic>> personalExamples = const [],
  }) async {
    interpretPhotoWithDiagnosticsCalled = true;
    return dummyResult!;
  }
}

class _FakeInterpretationDraftRepository implements InterpretationDraftRepository {
  final Map<String, InterpretationDraftEntity> drafts = {};
  bool saveDraftCalled = false;
  bool deleteDraftCalled = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> saveDraft(InterpretationDraftEntity draftEntity) async {
    saveDraftCalled = true;
    drafts[draftEntity.id] = draftEntity;
  }

  @override
  Future<InterpretationDraftEntity?> getDraftById(String draftId) async {
    return drafts[draftId];
  }

  @override
  Future<List<InterpretationDraftEntity>> getAllDrafts() async {
    return drafts.values.toList();
  }

  @override
  Future<void> deleteDraft(String draftId) async {
    deleteDraftCalled = true;
    drafts.remove(draftId);
  }
}

class _FakeAddIntakeUsecase implements AddIntakeUsecase {
  IntakeEntity? addedIntake;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> addIntake(IntakeEntity intakeEntity) async {
    addedIntake = intakeEntity;
  }
}

class _FakeAddTrackedDayUsecase implements AddTrackedDayUsecase {
  bool hasDay = false;
  DateTime? addedDay;
  double? addedKcal;
  double? addedCarbs;
  double? addedFat;
  double? addedProtein;
  double? caloriesAdded;
  double? carbsAdded;
  double? fatAdded;
  double? proteinAdded;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<bool> hasTrackedDay(DateTime day) async {
    return hasDay;
  }

  @override
  Future<void> addNewTrackedDay(
    DateTime day,
    double kcalGoal,
    double carbsGoal,
    double fatGoal,
    double proteinGoal,
  ) async {
    addedDay = day;
    addedKcal = kcalGoal;
    addedCarbs = carbsGoal;
    addedFat = fatGoal;
    addedProtein = proteinGoal;
  }

  @override
  Future<void> addDayCaloriesTracked(DateTime day, double calories) async {
    caloriesAdded = calories;
  }

  @override
  Future<void> addDayMacrosTracked(
    DateTime day, {
    double? carbsTracked,
    double? fatTracked,
    double? proteinTracked,
  }) async {
    carbsAdded = carbsTracked;
    fatAdded = fatTracked;
    proteinAdded = proteinTracked;
  }
}

class _FakeGetGymTargetsUsecase implements GetGymTargetsUsecase {
  GymTargetsEntity targets = const GymTargetsEntity(
    kcalGoal: 2000,
    carbsGoal: 250,
    fatGoal: 65,
    proteinGoal: 120,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<GymTargetsEntity> getTargetsForDay(DateTime day, {
    UserEntity? userEntity,
    UserWeightGoalEntity? phase,
    DailyFocusEntity? dailyFocus,
    double? totalKcalActivities,
  }) async {
    return targets;
  }
}

class _FakeGetRecipeLibraryUsecase implements GetRecipeLibraryUsecase {
  List<RecipeEntity> recipes = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<RecipeEntity>> getAllRecipes({bool savedOnly = true}) async {
    return recipes;
  }
}

class _FakeGetFrequentIntakePresetsUsecase implements GetFrequentIntakePresetsUsecase {
  List<FrequentIntakePresetEntity> presets = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<FrequentIntakePresetEntity>> getTopPresets({
    int limit = 12,
    int lookbackDays = 45,
  }) async {
    return presets;
  }
}

class _FakeGetConfigUsecase implements GetConfigUsecase {
  ConfigEntity config = const ConfigEntity(true, true, true, AppThemeEntity.system);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<ConfigEntity> getConfig() async {
    return config;
  }
}

class _FakeGetUserUsecase implements GetUserUsecase {
  UserEntity user = UserEntity(
    birthday: DateTime(1990, 1, 1),
    heightCM: 180,
    weightKG: 75,
    gender: UserGenderEntity.male,
    goal: UserWeightGoalEntity.maintainWeight,
    pal: UserPALEntity.sedentary,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<UserEntity> getUserData() async {
    return user;
  }
}
