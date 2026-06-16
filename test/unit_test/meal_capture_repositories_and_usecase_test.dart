import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';
import 'package:macrotracker/features/meal_capture/data/data_source/interpretation_draft_data_source.dart';
import 'package:macrotracker/features/meal_capture/data/repository/interpretation_draft_repository.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/meal_interpretation_personalization_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_frequent_intake_presets_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_recipe_library_usecase.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/frequent_intake_preset_entity.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fakes
// ─────────────────────────────────────────────────────────────────────────────

class _FakeGetRecipeLibraryUsecase extends Fake
    implements GetRecipeLibraryUsecase {
  @override
  Future<List<RecipeEntity>> getAllRecipes({bool savedOnly = true}) async =>
      const [];
}

class _FakeGetFrequentIntakePresetsUsecase extends Fake
    implements GetFrequentIntakePresetsUsecase {
  @override
  Future<List<FrequentIntakePresetEntity>> getTopPresets({
    int limit = 12,
    int lookbackDays = 45,
  }) async =>
      const [];
}

class _FakeGetConfigUsecase extends Fake implements GetConfigUsecase {
  DailyFocusEntity dailyFocus = DailyFocusEntity.upperBody;

  @override
  Future<ConfigEntity> getConfig() async => ConfigEntity(
        false,
        false,
        false,
        AppThemeEntity.system,
        dailyFocus: dailyFocus,
      );
}

class _FakeGetUserUsecase extends Fake implements GetUserUsecase {
  UserWeightGoalEntity goal = UserWeightGoalEntity.maintainWeight;

  @override
  Future<UserEntity> getUserData() async => UserEntity(
        birthday: DateTime.now().subtract(const Duration(days: 25 * 365)),
        heightCM: 175.0,
        weightKG: 70.0,
        gender: UserGenderEntity.male,
        goal: goal,
        pal: UserPALEntity.active,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('Meal Capture Repository and Personalization Usecase Tests', () {
    late Directory tempDir;
    late HiveDBProvider hiveProvider;
    late InterpretationDraftRepository draftRepo;
    late MealInterpretationPersonalizationUsecase personalizationUsecase;
    late _FakeGetConfigUsecase configUsecase;
    late _FakeGetUserUsecase userUsecase;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp
          .createTemp('macrotracker_meal_capture_test_');

      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return tempDir.path;
      });

      hiveProvider = HiveDBProvider();
      final key = Hive.generateSecureKey();
      await hiveProvider.initHiveDB(Uint8List.fromList(key));

      final draftDs =
          InterpretationDraftDataSource(hiveProvider.interpretationDraftBox);
      draftRepo = InterpretationDraftRepository(draftDs);

      configUsecase = _FakeGetConfigUsecase();
      userUsecase = _FakeGetUserUsecase();

      personalizationUsecase = MealInterpretationPersonalizationUsecase(
        _FakeGetRecipeLibraryUsecase(),
        _FakeGetFrequentIntakePresetsUsecase(),
        configUsecase,
        userUsecase,
      );
    });

    tearDown(() async {
      await hiveProvider.clearAllData();
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // ── InterpretationDraftRepository ─────────────────────────────────────────
    group('InterpretationDraftRepository', () {
      final now = DateTime.now();

      test('saveDraft, getDraftById, getAllDrafts, deleteDraft, expiredDrafts',
          () async {
        expect(await draftRepo.getAllDrafts(), isEmpty);
        expect(await draftRepo.getDraftById('d1'), isNull);

        final draft = InterpretationDraftEntity(
          id: 'd1',
          sourceType: DraftSourceEntity.text,
          inputText: 'banana',
          localImagePath: null,
          title: 'Banana',
          summary: 'Banana summary',
          totalKcal: 89,
          totalCarbs: 23,
          totalFat: 0.3,
          totalProtein: 1.1,
          confidenceBand: ConfidenceBandEntity.high,
          status: DraftStatusEntity.ready,
          createdAt: now,
          expiresAt: now.add(const Duration(hours: 1)),
          items: const [
            InterpretationDraftItemEntity(
              id: 'item1',
              label: 'Banana',
              matchedMealSnapshot: null,
              amount: 1,
              unit: 'unit',
              kcal: 89,
              carbs: 23,
              fat: 0.3,
              protein: 1.1,
              confidenceBand: ConfidenceBandEntity.high,
              editable: true,
              removed: false,
            )
          ],
        );

        await draftRepo.saveDraft(draft);

        final fetched = await draftRepo.getDraftById('d1');
        expect(fetched, isNotNull);
        expect(fetched!.title, equals('Banana'));
        expect(fetched.items, hasLength(1));
        expect(fetched.items.first.label, equals('Banana'));

        expect(await draftRepo.getAllDrafts(), hasLength(1));

        await draftRepo.deleteDraft('d1');
        expect(await draftRepo.getAllDrafts(), isEmpty);

        // Expired check
        final expiredDraft = draft.copyWith(
          id: 'd2',
          expiresAt: now.subtract(const Duration(minutes: 10)),
        );
        await draftRepo.saveDraft(expiredDraft);
        expect(await draftRepo.getAllDrafts(), hasLength(1));

        await draftRepo.deleteExpiredDrafts(now);
        expect(await draftRepo.getAllDrafts(), isEmpty);
      });
    });

    // ── MealInterpretationPersonalizationUsecase ──────────────────────────────
    group('MealInterpretationPersonalizationUsecase', () {
      test(
          'buildContext builds default context with candidates and covers all goals and focus types',
          () async {
        for (final goal in UserWeightGoalEntity.values) {
          for (final focus in DailyFocusEntity.values) {
            configUsecase.dailyFocus = focus;
            userUsecase.goal = goal;

            final context = await personalizationUsecase.buildContext(
              intakeType: IntakeTypeEntity.breakfast,
              freeText: 'desayuno saludable',
            );

            expect(context.promptContext, contains('User nutrition context:'));
          }
        }
      });

      test('personalizeDraft and validateMacroCoherence checks derived kcal',
          () async {
        final draft = InterpretationDraftEntity(
          id: 'd1',
          sourceType: DraftSourceEntity.text,
          inputText: 'rice and chicken',
          localImagePath: null,
          title: 'Meal',
          summary: 'Meal summary',
          totalKcal:
              500, // Incoherent with macros: 100g carbs (400kcal), 50g protein (200kcal) = 600kcal
          totalCarbs: 100,
          totalFat: 0,
          totalProtein: 50,
          confidenceBand: ConfidenceBandEntity.high,
          status: DraftStatusEntity.ready,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          items: const [
            InterpretationDraftItemEntity(
              id: 'item1',
              label: 'Rice',
              matchedMealSnapshot: null,
              amount: 1,
              unit: 'unit',
              kcal: 500,
              carbs: 100,
              fat: 0,
              protein: 50,
              confidenceBand: ConfidenceBandEntity.high,
              editable: true,
              removed: false,
            )
          ],
        );

        // Under personalization, macro validation will adjust kcal
        final personalized = await personalizationUsecase.personalizeDraft(
          draft: draft,
          intakeType: IntakeTypeEntity.lunch,
        );

        // Kcal should adjust to (100 * 4) + (50 * 4) = 600
        expect(personalized.totalKcal, equals(600.0));
      });

      test('suggestMealsForDraft and fallbackDraft return valid options',
          () async {
        final draft = InterpretationDraftEntity(
          id: 'd1',
          sourceType: DraftSourceEntity.text,
          inputText: 'apple',
          localImagePath: null,
          title: 'Apple',
          summary: 'Apple summary',
          totalKcal: 52,
          totalCarbs: 14,
          totalFat: 0.2,
          totalProtein: 0.3,
          confidenceBand: ConfidenceBandEntity.high,
          status: DraftStatusEntity.ready,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          items: const [
            InterpretationDraftItemEntity(
              id: 'item1',
              label: 'Apple',
              matchedMealSnapshot: null,
              amount: 1,
              unit: 'unit',
              kcal: 52,
              carbs: 14,
              fat: 0.2,
              protein: 0.3,
              confidenceBand: ConfidenceBandEntity.high,
              editable: true,
              removed: false,
            )
          ],
        );

        final suggestions = await personalizationUsecase.suggestMealsForDraft(
          draft: draft,
          intakeType: IntakeTypeEntity.snack,
        );
        expect(suggestions, isEmpty); // no candidates matching

        final fallback = await personalizationUsecase.buildFallbackDraft(
          sourceType: DraftSourceEntity.text,
          title: 'Banana',
          intakeType: IntakeTypeEntity.breakfast,
        );
        expect(fallback.title, equals('Banana'));
        expect(fallback.totalKcal,
            equals(0.0)); // since no candidate found, fallback to 0
      });
    });
  });
}
