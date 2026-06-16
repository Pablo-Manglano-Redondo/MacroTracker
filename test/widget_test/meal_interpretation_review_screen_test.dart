import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/calculate_food_quality_score_usecase.dart';
import 'package:macrotracker/core/services/app_review_service.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/commit_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/meal_interpretation_personalization_usecase.dart';
import 'package:macrotracker/features/meal_capture/domain/usecase/save_interpretation_draft_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/save_recipe_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_interpretation_review_screen.dart';

void main() {
  late Directory tempDir;
  late _FakeCommitInterpretationDraftUsecase fakeCommitUsecase;
  late _FakeSaveInterpretationDraftUsecase fakeSaveUsecase;
  late _FakeMealInterpretationPersonalizationUsecase fakePersonalizationUsecase;
  late _FakeSaveRecipeUsecase fakeSaveRecipeUsecase;
  late _FakeMonetizationService fakeMonetizationService;
  late _FakeConversionAnalyticsService fakeConversionAnalyticsService;
  late _FakeAppReviewService fakeAppReviewService;

  late _FakeHomeBloc fakeHomeBloc;
  late _FakeDiaryBloc fakeDiaryBloc;
  late _FakeCalendarDayBloc fakeCalendarDayBloc;

  setUp(() async {
    await locator.reset();
    tempDir = await Directory.systemTemp.createTemp('macrotracker_review_screen_test_');
    Hive.init(tempDir.path);

    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return tempDir.path;
    });

    fakeCommitUsecase = _FakeCommitInterpretationDraftUsecase();
    fakeSaveUsecase = _FakeSaveInterpretationDraftUsecase();
    fakePersonalizationUsecase = _FakeMealInterpretationPersonalizationUsecase();
    fakeSaveRecipeUsecase = _FakeSaveRecipeUsecase();
    fakeMonetizationService = _FakeMonetizationService();
    fakeConversionAnalyticsService = _FakeConversionAnalyticsService();
    fakeAppReviewService = _FakeAppReviewService();

    fakeHomeBloc = _FakeHomeBloc();
    fakeDiaryBloc = _FakeDiaryBloc();
    fakeCalendarDayBloc = _FakeCalendarDayBloc();

    locator.registerSingleton<CalculateFoodQualityScoreUsecase>(CalculateFoodQualityScoreUsecase());
    locator.registerSingleton<CommitInterpretationDraftUsecase>(fakeCommitUsecase);
    locator.registerSingleton<SaveInterpretationDraftUsecase>(fakeSaveUsecase);
    locator.registerSingleton<MealInterpretationPersonalizationUsecase>(fakePersonalizationUsecase);
    locator.registerSingleton<SaveRecipeUsecase>(fakeSaveRecipeUsecase);
    locator.registerSingleton<MonetizationService>(fakeMonetizationService);
    locator.registerSingleton<ConversionAnalyticsService>(fakeConversionAnalyticsService);
    locator.registerSingleton<AppReviewService>(fakeAppReviewService);

    locator.registerSingleton<HomeBloc>(fakeHomeBloc);
    locator.registerSingleton<DiaryBloc>(fakeDiaryBloc);
    locator.registerSingleton<CalendarDayBloc>(fakeCalendarDayBloc);
  });

  tearDown(() async {
    await fakeHomeBloc.close();
    await fakeDiaryBloc.close();
    await fakeCalendarDayBloc.close();
    await locator.reset();
    if (await tempDir.exists()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {
        // Temporary directories can be locked briefly by platform channels on Windows.
      }
    }
  });

  Widget createTestWidget(String draftId) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: RouteSettings(
            arguments: MealInterpretationReviewScreenArguments(
              draftId,
              DateTime(2026, 6, 15),
              IntakeTypeEntity.breakfast,
            ),
          ),
          builder: (context) => const MealInterpretationReviewScreen(),
        );
      },
    );
  }

  InterpretationDraftEntity buildDummyDraft({
    required String id,
    required String title,
  }) {
    return InterpretationDraftEntity(
      id: id,
      sourceType: DraftSourceEntity.text,
      inputText: '2 eggs and 1 banana',
      localImagePath: null,
      title: title,
      summary: 'A simple breakfast draft',
      totalKcal: 250,
      totalCarbs: 27,
      totalFat: 10,
      totalProtein: 14,
      totalFiber: 3,
      totalSugar: 12,
      confidenceBand: ConfidenceBandEntity.high,
      status: DraftStatusEntity.ready,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      items: [
        InterpretationDraftItemEntity(
          id: 'item-1',
          label: 'Eggs',
          matchedMealSnapshot: null,
          amount: 2,
          unit: 'serving',
          kcal: 150,
          carbs: 1,
          fat: 10,
          protein: 12,
          fiber: 0,
          sugar: 0,
          confidenceBand: ConfidenceBandEntity.high,
          editable: true,
          removed: false,
        ),
        InterpretationDraftItemEntity(
          id: 'item-2',
          label: 'Banana',
          matchedMealSnapshot: null,
          amount: 1,
          unit: 'serving',
          kcal: 100,
          carbs: 26,
          fat: 0,
          protein: 2,
          fiber: 3,
          sugar: 12,
          confidenceBand: ConfidenceBandEntity.high,
          editable: true,
          removed: false,
        ),
      ],
    );
  }

  Future<void> waitForLoadedState(WidgetTester tester) async {
    int retryCount = 0;
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty && retryCount < 50) {
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 10));
      });
      await tester.pump();
      retryCount++;
    }
  }

  Future<void> scrollDownUntilVisible(WidgetTester tester, Finder finder) async {
    int iterations = 0;
    while (iterations < 15) {
      if (finder.evaluate().isNotEmpty) {
        final RenderBox renderBox = tester.renderObject(finder.first);
        final position = renderBox.localToGlobal(Offset.zero);
        if (position.dy >= 50 && position.dy < 400) {
          break;
        }
      }
      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pumpAndSettle();
      iterations++;
    }
  }

  Future<void> scrollUpUntilVisible(WidgetTester tester, Finder finder) async {
    int iterations = 0;
    while (iterations < 15) {
      if (finder.evaluate().isNotEmpty) {
        final RenderBox renderBox = tester.renderObject(finder.first);
        final position = renderBox.localToGlobal(Offset.zero);
        if (position.dy >= 50 && position.dy < 400) {
          break;
        }
      }
      await tester.drag(find.byType(ListView), const Offset(0, 100));
      await tester.pumpAndSettle();
      iterations++;
    }
  }

  testWidgets('renders review screen with loading, then displays draft details', (tester) async {
    final draft = buildDummyDraft(id: 'draft-123', title: 'Desayuno Proteico');
    fakeCommitUsecase.draft = draft;

    await tester.pumpWidget(createTestWidget('draft-123'));

    // Loading spinner initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await waitForLoadedState(tester);

    // Verify draft details are rendered
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Desayuno Proteico'), findsOneWidget);

    // Scroll down to expose Macro card
    final macroFinder = find.text('250 kcal');
    await scrollDownUntilVisible(tester, macroFinder);
    expect(macroFinder, findsOneWidget); // Total kcal

    // Scroll down to expose first ingredient card (Eggs)
    final eggsFinder = find.text('Eggs');
    await scrollDownUntilVisible(tester, eggsFinder);
    expect(eggsFinder, findsOneWidget);

    // Scroll down further to expose second ingredient card (Banana)
    final bananaFinder = find.text('Banana');
    await scrollDownUntilVisible(tester, bananaFinder);
    expect(bananaFinder, findsOneWidget);

    // Dispose the widget tree
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('clicking save meal commits draft and handles navigation', (tester) async {
    final draft = buildDummyDraft(id: 'draft-123', title: 'Desayuno Proteico');
    fakeCommitUsecase.draft = draft;

    await tester.pumpWidget(createTestWidget('draft-123'));
    await waitForLoadedState(tester);

    // Tap "Guardar comida" button
    final saveButton = find.text('Guardar comida');
    expect(saveButton, findsOneWidget);

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(fakeCommitUsecase.commitCalled, isTrue);

    // Dispose the widget tree
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('toggling ingredient removal updates macro count', (tester) async {
    final draft = buildDummyDraft(id: 'draft-123', title: 'Desayuno Proteico');
    fakeCommitUsecase.draft = draft;

    await tester.pumpWidget(createTestWidget('draft-123'));
    await waitForLoadedState(tester);

    // Scroll down to expose first ingredient card (Eggs)
    final eggsFinder = find.text('Eggs');
    await scrollDownUntilVisible(tester, eggsFinder);

    // Toggle the switch for Eggs (which is the first Switch)
    final switchFinder = find.byType(Switch).first;
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // Scroll back to the top to expose the Macro card with 100 kcal
    final macroFinder = find.text('100 kcal');
    await scrollUpUntilVisible(tester, macroFinder);

    expect(macroFinder, findsOneWidget);

    // Dispose the widget tree
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('toggling ingredient preset updates amount and macros', (tester) async {
    final draft = buildDummyDraft(id: 'draft-123', title: 'Desayuno Proteico');
    fakeCommitUsecase.draft = draft;

    await tester.pumpWidget(createTestWidget('draft-123'));
    await waitForLoadedState(tester);

    // Find the "+50 %" preset chip for Eggs and tap it
    final presetFinder = find.text('+50 %');
    await scrollDownUntilVisible(tester, presetFinder);
    await tester.tap(presetFinder.first);
    await tester.pumpAndSettle();

    // Scroll back to the top to expose the Macro card with 325 kcal
    // Eggs was 150 kcal. +50% makes it 225 kcal.
    // Total kcal should now be 225 + 100 = 325 kcal.
    final macroFinder = find.text('325 kcal');
    await scrollUpUntilVisible(tester, macroFinder);

    expect(macroFinder, findsOneWidget);

    // Dispose the widget tree
    await tester.pumpWidget(const SizedBox());
  });


  testWidgets('saving as recipe opens dialog and saves recipe', (tester) async {
    final draft = buildDummyDraft(id: 'draft-123', title: 'Desayuno Proteico');
    fakeCommitUsecase.draft = draft;

    await tester.pumpWidget(createTestWidget('draft-123'));
    await waitForLoadedState(tester);

    // Tap the recipe bookmark button in the AppBar
    final bookmarkIconFinder = find.byIcon(Icons.bookmark_add_outlined).first;
    await tester.tap(bookmarkIconFinder);
    await tester.pumpAndSettle();

    // Dialog should be displayed with title "Guardar como receta"
    expect(find.text('Guardar como receta'), findsOneWidget);

    // Tap the "Guardar" text button in dialog actions
    final saveDialogButtonFinder = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Guardar'),
    );
    await tester.tap(saveDialogButtonFinder);
    await tester.pumpAndSettle();

    // Recipe should have been saved
    expect(fakeSaveRecipeUsecase.saveCalled, isTrue);

    // Dispose the widget tree
    await tester.pumpWidget(const SizedBox());
  });
}

class _FakeCommitInterpretationDraftUsecase extends Fake implements CommitInterpretationDraftUsecase {
  InterpretationDraftEntity? draft;
  bool commitCalled = false;

  @override
  Future<InterpretationDraftEntity?> getDraftById(String id) => SynchronousFuture(draft);

  @override
  Future<void> commitDraft(
    InterpretationDraftEntity draft,
    IntakeTypeEntity intakeType,
    DateTime day, {
    double servings = 1.0,
  }) {
    commitCalled = true;
    return SynchronousFuture(null);
  }
}

class _FakeSaveInterpretationDraftUsecase extends Fake implements SaveInterpretationDraftUsecase {
  InterpretationDraftEntity? savedDraft;

  @override
  Future<void> saveDraft(InterpretationDraftEntity draft) {
    savedDraft = draft;
    return SynchronousFuture(null);
  }
}

class _FakeMealInterpretationPersonalizationUsecase extends Fake implements MealInterpretationPersonalizationUsecase {
  @override
  Future<List<MealInterpretationSuggestion>> suggestMealsForDraft({
    required InterpretationDraftEntity draft,
    required IntakeTypeEntity intakeType,
  }) => SynchronousFuture([]);

  @override
  Future<void> saveMealMemoryFromDraft({
    required InterpretationDraftEntity draft,
    required IntakeTypeEntity intakeType,
  }) => SynchronousFuture(null);
}

class _FakeSaveRecipeUsecase extends Fake implements SaveRecipeUsecase {
  bool saveCalled = false;

  @override
  Future<void> saveRecipe(dynamic recipe) {
    saveCalled = true;
    return SynchronousFuture(null);
  }
}

class _FakeMonetizationService extends Fake implements MonetizationService {
  AiTrialState trialState = const AiTrialState(
    isPremium: true,
    used: 0,
    limit: 5,
    fullLimit: 5,
    aiMealsSaved: 0,
  );

  @override
  Future<AiTrialState> getAiTrialState() => SynchronousFuture(trialState);

  @override
  Future<void> recordAiMealSaved({required bool consumeTrialUse}) => SynchronousFuture(null);
}

class _FakeConversionAnalyticsService extends Fake implements ConversionAnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) => SynchronousFuture(null);
}

class _FakeAppReviewService extends Fake implements AppReviewService {
  @override
  Future<void> recordAiMealCommitted() => SynchronousFuture(null);
}

class _FakeHomeBloc extends Bloc<HomeEvent, HomeState> implements HomeBloc {
  _FakeHomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) {});
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDiaryBloc extends Bloc<DiaryEvent, DiaryState> implements DiaryBloc {
  _FakeDiaryBloc() : super(DiaryInitial()) {
    on<DiaryEvent>((event, emit) {});
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCalendarDayBloc extends Bloc<CalendarDayEvent, CalendarDayState> implements CalendarDayBloc {
  _FakeCalendarDayBloc() : super(CalendarDayInitial()) {
    on<CalendarDayEvent>((event, emit) {});
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
