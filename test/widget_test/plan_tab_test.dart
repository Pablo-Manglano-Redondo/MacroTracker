import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_recipe_usecase.dart';
import 'package:macrotracker/features/professional_plan/data/data_source/proposed_recipes_data_source.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/plan_tab.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/generated/l10n.dart';

void main() {
  late _FakeAddIntakeUsecase fakeAddIntake;
  late _FakeAddTrackedDayUsecase fakeAddTrackedDay;
  late _FakeGetGymTargetsUsecase fakeGymTargets;
  late _FakeGetProfessionalRecipeUsecase fakeGetProfessionalRecipe;

  late _FakeHomeBloc fakeHomeBloc;
  late _FakeDiaryBloc fakeDiaryBloc;
  late _FakeCalendarDayBloc fakeCalendarDayBloc;

  setUp(() async {
    await locator.reset();

    fakeAddIntake = _FakeAddIntakeUsecase();
    fakeAddTrackedDay = _FakeAddTrackedDayUsecase();
    fakeGymTargets = _FakeGetGymTargetsUsecase();
    fakeGetProfessionalRecipe = _FakeGetProfessionalRecipeUsecase();

    fakeHomeBloc = _FakeHomeBloc();
    fakeDiaryBloc = _FakeDiaryBloc();
    fakeCalendarDayBloc = _FakeCalendarDayBloc();

    locator.registerSingleton<AddIntakeUsecase>(fakeAddIntake);
    locator.registerSingleton<AddTrackedDayUsecase>(fakeAddTrackedDay);
    locator.registerSingleton<GetGymTargetsUsecase>(fakeGymTargets);
    locator.registerSingleton<GetProfessionalRecipeUsecase>(fakeGetProfessionalRecipe);

    locator.registerSingleton<HomeBloc>(fakeHomeBloc);
    locator.registerSingleton<DiaryBloc>(fakeDiaryBloc);
    locator.registerSingleton<CalendarDayBloc>(fakeCalendarDayBloc);
  });

  tearDown(() async {
    await fakeHomeBloc.close();
    await fakeDiaryBloc.close();
    await fakeCalendarDayBloc.close();
    await locator.reset();
  });

  void prepareViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget createTestWidget(ProfessionalSectionSummaryEntity summary) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: PlanTab(summary: summary),
        ),
      ),
    );
  }

  final connection = ProfessionalConnectionEntity(
    relationshipId: 'rel-123',
    professionalId: 'prof-123',
    clientId: 'client-123',
    professionalName: 'Coach Studio',
    connectedAt: DateTime(2026, 6, 15),
    consentAcceptedAt: DateTime(2026, 6, 15),
    lastPlanSyncAt: DateTime(2026, 6, 15),
    lastSnapshotSyncAt: DateTime(2026, 6, 15),
    pendingSyncCount: 0,
    sharingMode: 'aggregate',
    messagesEnabled: true,
    connectionStatus: 'active',
    activePlan: null,
  );

  const todayAdherence = ProfessionalAdherenceSliceEntity(
    kcalTarget: 2000,
    kcalActual: 1800,
    carbsTarget: 250,
    carbsActual: 220,
    fatTarget: 70,
    fatActual: 65,
    proteinTarget: 150,
    proteinActual: 140,
    mealsLogged: 3,
    trackedDays: 1,
  );

  const weekAdherence = ProfessionalAdherenceSliceEntity(
    kcalTarget: 14000,
    kcalActual: 12000,
    carbsTarget: 1750,
    carbsActual: 1500,
    fatTarget: 490,
    fatActual: 450,
    proteinTarget: 1050,
    proteinActual: 980,
    mealsLogged: 21,
    trackedDays: 7,
  );

  final syncStatus = ProfessionalSyncStatusEntity(
    lastPlanSyncAt: DateTime(2026, 6, 15),
    lastSnapshotSyncAt: DateTime(2026, 6, 15),
    pendingSyncCount: 0,
    connectionStatus: 'active',
  );

  testWidgets('renders empty plan card when activePlan is null', (tester) async {
    prepareViewport(tester);
    final summary = ProfessionalSectionSummaryEntity(
      connection: connection,
      activePlan: null,
      todayTarget: null,
      weekPlan: const [],
      today: todayAdherence,
      week: weekAdherence,
      syncStatus: syncStatus,
    );

    await tester.pumpWidget(createTestWidget(summary));
    await tester.pumpAndSettle();

    expect(find.text(S.current.professionalSummaryNoPublishedPlan), findsOneWidget);
    expect(find.text('Coach Studio'), findsOneWidget);
  });

  testWidgets('renders plan metadata, weekly view, and suggested meals', (tester) async {
    prepareViewport(tester);
    final activePlan = NutritionPlanEntity(
      id: 'plan-123',
      professionalId: 'prof-123',
      clientId: 'client-123',
      name: 'Plan de Hipertrofia',
      objective: 'Aumento de masa muscular magra',
      notes: 'Pautas: Beber 3L de agua.',
      createdAt: DateTime(2026, 6, 15),
      updatedAt: DateTime(2026, 6, 15),
      startsOn: DateTime(2026, 6, 15),
      endsOn: DateTime(2026, 6, 22),
      days: [
        NutritionPlanDayEntity(
          dateKey: '2026-06-15',
          weekday: 1,
          kcalGoal: 2200,
          carbsGoal: 270,
          fatGoal: 75,
          proteinGoal: 160,
        ),
      ],
      meals: [
        NutritionPlanMealEntity(
          id: 'meal-123',
          slot: 'breakfast',
          title: 'Tortilla y Avena',
          notes: '3 claras de huevo + 50g avena',
          kcal: 450,
          carbs: 45,
          fat: 10,
          protein: 30,
          recipeId: 'recipe-456',
        ),
      ],
    );

    final summary = ProfessionalSectionSummaryEntity(
      connection: connection,
      activePlan: activePlan,
      todayTarget: activePlan.days.first,
      weekPlan: [
        NutritionPlanResolvedDayEntity(
          effectiveDate: DateTime(2026, 6, 15),
          target: activePlan.days.first,
          usesWeekdayFallback: false,
          isToday: true,
        ),
      ],
      today: todayAdherence,
      week: weekAdherence,
      syncStatus: syncStatus,
    );

    await tester.pumpWidget(createTestWidget(summary));
    await tester.pumpAndSettle();

    // Verify Active Plan Info
    expect(find.text('Plan de Hipertrofia'), findsOneWidget);
    expect(find.text('Aumento de masa muscular magra'), findsOneWidget);
    expect(find.text('Pautas: Beber 3L de agua.'), findsOneWidget);

    // Verify Weekly View Day (2026-06-15 is a Monday, formatted as "Lunes 15/06")
    expect(find.text('${S.current.professionalWeekdayMonday} 15/06'), findsOneWidget);
    expect(find.text('2200 kcal'), findsOneWidget);
    expect(find.text('160g P'), findsOneWidget);
    expect(find.text('270g C'), findsOneWidget);
    expect(find.text('75g F'), findsOneWidget);

    // Verify Suggested Meals Guide
    expect(find.text('Tortilla y Avena'), findsOneWidget);
    expect(find.text(S.current.breakfastLabel), findsOneWidget);
    expect(find.text('450 kcal'), findsOneWidget);
    expect(find.text('30g P | 45g C | 10g F'), findsOneWidget);
  });

  testWidgets('tapping weekly day row opens WeekdayDetailBottomSheet', (tester) async {
    prepareViewport(tester);
    final activePlan = NutritionPlanEntity(
      id: 'plan-123',
      professionalId: 'prof-123',
      clientId: 'client-123',
      name: 'Plan de Hipertrofia',
      objective: 'Masa magra',
      notes: '',
      createdAt: DateTime(2026, 6, 15),
      updatedAt: DateTime(2026, 6, 15),
      startsOn: DateTime(2026, 6, 15),
      endsOn: DateTime(2026, 6, 22),
      days: [
        NutritionPlanDayEntity(
          dateKey: '2026-06-15',
          weekday: 1,
          kcalGoal: 2200,
          carbsGoal: 270,
          fatGoal: 75,
          proteinGoal: 160,
        ),
      ],
      meals: [],
    );

    final summary = ProfessionalSectionSummaryEntity(
      connection: connection,
      activePlan: activePlan,
      todayTarget: activePlan.days.first,
      weekPlan: [
        NutritionPlanResolvedDayEntity(
          effectiveDate: DateTime(2026, 6, 15),
          target: activePlan.days.first,
          usesWeekdayFallback: false,
          isToday: true,
        ),
      ],
      today: todayAdherence,
      week: weekAdherence,
      syncStatus: syncStatus,
    );

    await tester.pumpWidget(createTestWidget(summary));
    await tester.pumpAndSettle();

    // Tap day row
    await tester.tap(find.text('${S.current.professionalWeekdayMonday} 15/06'));
    await tester.pumpAndSettle();

    // Bottom sheet should render with details
    expect(find.text('${S.current.professionalWeekdayMonday} 15/06'), findsNWidgets(2)); // One in background list, one in sheet
    expect(find.text(S.current.professionalPlanSpecificTarget), findsOneWidget);
    expect(find.text('2200 kcal'), findsNWidgets(2));
    expect(find.text('160 g'), findsOneWidget); // Protein
    expect(find.text('270 g'), findsOneWidget); // Carbs
    expect(find.text('75 g'), findsOneWidget); // Fat
  });

  testWidgets('tapping suggested meal opens SuggestedMealDetailBottomSheet', (tester) async {
    prepareViewport(tester);
    final activePlan = NutritionPlanEntity(
      id: 'plan-123',
      professionalId: 'prof-123',
      clientId: 'client-123',
      name: 'Plan de Hipertrofia',
      objective: 'Masa magra',
      notes: '',
      createdAt: DateTime(2026, 6, 15),
      updatedAt: DateTime(2026, 6, 15),
      startsOn: DateTime(2026, 6, 15),
      endsOn: DateTime(2026, 6, 22),
      days: [],
      meals: [
        NutritionPlanMealEntity(
          id: 'meal-123',
          slot: 'lunch',
          title: 'Arroz y Pollo',
          notes: '150g pollo + 80g arroz',
          kcal: 600,
          carbs: 60,
          fat: 12,
          protein: 50,
          recipeId: null,
        ),
      ],
    );

    final summary = ProfessionalSectionSummaryEntity(
      connection: connection,
      activePlan: activePlan,
      todayTarget: null,
      weekPlan: const [],
      today: todayAdherence,
      week: weekAdherence,
      syncStatus: syncStatus,
    );

    await tester.pumpWidget(createTestWidget(summary));
    await tester.pumpAndSettle();

    // Tap meal row
    await tester.tap(find.text('Arroz y Pollo'));
    await tester.pumpAndSettle();

    // Sheet should be opened
    expect(find.text('Arroz y Pollo'), findsNWidgets(2));
    expect(find.text(S.current.professionalPlanSuggestedPlanMeal), findsOneWidget);
    expect(find.text('600 kcal'), findsNWidgets(2));
    expect(find.text('50 g'), findsOneWidget); // Protein
    expect(find.text('60 g'), findsOneWidget); // Carbs
    expect(find.text('12 g'), findsOneWidget); // Fat
    expect(find.text(S.current.professionalPlanNutritionistGuidelines), findsOneWidget);
    expect(find.text('150g pollo + 80g arroz'), findsNWidgets(2));
  });

  testWidgets('tapping log suggested meal triggers confirmation dialog and saves intake', (tester) async {
    prepareViewport(tester);
    final activePlan = NutritionPlanEntity(
      id: 'plan-123',
      professionalId: 'prof-123',
      clientId: 'client-123',
      name: 'Plan de Hipertrofia',
      objective: 'Masa magra',
      notes: '',
      createdAt: DateTime(2026, 6, 15),
      updatedAt: DateTime(2026, 6, 15),
      startsOn: DateTime(2026, 6, 15),
      endsOn: DateTime(2026, 6, 22),
      days: [],
      meals: [
        NutritionPlanMealEntity(
          id: 'meal-123',
          slot: 'lunch',
          title: 'Arroz y Pollo',
          notes: '150g pollo + 80g arroz',
          kcal: 600,
          carbs: 60,
          fat: 12,
          protein: 50,
          recipeId: null,
        ),
      ],
    );

    final summary = ProfessionalSectionSummaryEntity(
      connection: connection,
      activePlan: activePlan,
      todayTarget: null,
      weekPlan: const [],
      today: todayAdherence,
      week: weekAdherence,
      syncStatus: syncStatus,
    );

    await tester.pumpWidget(createTestWidget(summary));
    await tester.pumpAndSettle();

    // Tap "Registrar en Diario" text button
    await tester.tap(find.text(S.current.professionalPlanLogToDiary));
    await tester.pumpAndSettle();

    // Dialog should show up
    expect(find.text(S.current.professionalPlanLogSuggestedMealTitle), findsOneWidget);
    expect(find.text(S.current.professionalPlanLogSuggestedMealBody('Arroz y Pollo', 600, S.current.professionalPlanSlotLunch)), findsOneWidget);

    // Tap "Registrar" button in the dialog
    await tester.tap(find.text(S.current.professionalPlanLogMeal));
    await tester.pumpAndSettle();

    // Verification on Usecase
    expect(fakeAddIntake.added.length, 1);
    final intake = fakeAddIntake.added.first;
    expect(intake.meal.name, 'Arroz y Pollo');
    expect(intake.type, IntakeTypeEntity.lunch);
    expect(intake.amount, 1.0);

    // Tracked Day should be updated/created
    expect(fakeAddTrackedDay.dayCalories, contains(600.0));
  });

  testWidgets('view recipe button loads recipe and opens detail sheet', (tester) async {
    prepareViewport(tester);
    final activePlan = NutritionPlanEntity(
      id: 'plan-123',
      professionalId: 'prof-123',
      clientId: 'client-123',
      name: 'Plan de Hipertrofia',
      objective: 'Masa magra',
      notes: '',
      createdAt: DateTime(2026, 6, 15),
      updatedAt: DateTime(2026, 6, 15),
      startsOn: DateTime(2026, 6, 15),
      endsOn: DateTime(2026, 6, 22),
      days: [],
      meals: [
        NutritionPlanMealEntity(
          id: 'meal-123',
          slot: 'breakfast',
          title: 'Tortilla y Avena',
          notes: '3 claras de huevo + 50g avena',
          kcal: 450,
          carbs: 45,
          fat: 10,
          protein: 30,
          recipeId: 'recipe-456',
        ),
      ],
    );

    final summary = ProfessionalSectionSummaryEntity(
      connection: connection,
      activePlan: activePlan,
      todayTarget: null,
      weekPlan: const [],
      today: todayAdherence,
      week: weekAdherence,
      syncStatus: syncStatus,
    );

    fakeGetProfessionalRecipe.recipe = ProfessionalRecipeData(
      id: 'recipe-456',
      title: 'Receta de Tortilla Fit',
      description: 'Una receta rápida y proteica',
      mealType: 'breakfast',
      prepTimeMin: 10,
      cookTimeMin: 5,
      servings: 1,
      kcal: 450,
      protein: 30,
      carbs: 45,
      fat: 10,
      ingredients: const [
        {'name': 'Claras de Huevo', 'amount': '3', 'unit': 'uds'},
        {'name': 'Avena', 'amount': '50', 'unit': 'g'},
      ],
      instructions: 'Batir las claras e incorporar la avena. Cocinar a fuego lento.',
    );

    await tester.pumpWidget(createTestWidget(summary));
    await tester.pumpAndSettle();

    // Tap suggested meal to open detail sheet
    await tester.tap(find.text('Tortilla y Avena'));
    await tester.pumpAndSettle();

    // Tap "Ver Receta" in detail sheet
    await tester.tap(find.text(S.current.professionalPlanViewRecipe));

    // Wait for the async operation (fetching recipe)
    await tester.pump();
    await tester.pumpAndSettle();

    // Recipe detail sheet should show up
    expect(find.text('Receta de Tortilla Fit'), findsOneWidget);
    expect(find.text('Una receta rápida y proteica'), findsOneWidget);
    expect(find.text('10m'), findsOneWidget);
    expect(find.text('5m'), findsOneWidget);
    expect(find.text('Claras de Huevo'), findsOneWidget);
    expect(find.text('3 uds'), findsOneWidget);
    expect(find.text('Batir las claras e incorporar la avena. Cocinar a fuego lento.'), findsOneWidget);
  });
}

class _FakeAddIntakeUsecase extends Fake implements AddIntakeUsecase {
  final List<IntakeEntity> added = [];

  @override
  Future<void> addIntake(IntakeEntity intake) async {
    added.add(intake);
  }
}

class _FakeAddTrackedDayUsecase extends Fake implements AddTrackedDayUsecase {
  final List<double> dayCalories = [];

  @override
  Future<bool> hasTrackedDay(DateTime day) async => true;

  @override
  Future<void> addDayCaloriesTracked(DateTime day, double kcal) async {
    dayCalories.add(kcal);
  }

  @override
  Future<void> addDayMacrosTracked(DateTime day,
      {double? carbsTracked, double? fatTracked, double? proteinTracked}) async {}
}

class _FakeGetGymTargetsUsecase extends Fake implements GetGymTargetsUsecase {
  @override
  Future<GymTargetsEntity> getTargetsForDay(DateTime day, {dynamic userEntity, dynamic phase, dynamic dailyFocus, double? totalKcalActivities}) async {
    return const GymTargetsEntity(
      kcalGoal: 2000,
      carbsGoal: 250,
      fatGoal: 70,
      proteinGoal: 150,
    );
  }
}

class _FakeGetProfessionalRecipeUsecase extends Fake implements GetProfessionalRecipeUsecase {
  ProfessionalRecipeData? recipe;

  @override
  Future<ProfessionalRecipeData?> execute({required String recipeId}) async {
    return recipe;
  }
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
