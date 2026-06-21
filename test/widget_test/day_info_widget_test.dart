import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/physical_activity_entity.dart';
import 'package:macrotracker/features/diary/presentation/widgets/day_info_widget.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/meal_detail/presentation/bloc/meal_detail_bloc.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/generated/l10n.dart';

void main() {
  late _FakeHomeBloc fakeHomeBloc;
  late _FakeDiaryBloc fakeDiaryBloc;
  late _FakeCalendarDayBloc fakeCalendarDayBloc;
  late _FakeMealDetailBloc fakeMealDetailBloc;

  setUp(() async {
    await locator.reset();

    fakeHomeBloc = _FakeHomeBloc();
    fakeDiaryBloc = _FakeDiaryBloc();
    fakeCalendarDayBloc = _FakeCalendarDayBloc();
    fakeMealDetailBloc = _FakeMealDetailBloc();

    locator.registerSingleton<HomeBloc>(fakeHomeBloc);
    locator.registerSingleton<DiaryBloc>(fakeDiaryBloc);
    locator.registerSingleton<CalendarDayBloc>(fakeCalendarDayBloc);
    locator.registerSingleton<MealDetailBloc>(fakeMealDetailBloc);
  });

  tearDown(() async {
    await fakeHomeBloc.close();
    await fakeDiaryBloc.close();
    await fakeCalendarDayBloc.close();
    await fakeMealDetailBloc.close();
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
  final selectedDay = DateTime(2026, 6, 16);

  const mockPhysicalActivity = PhysicalActivityEntity(
    'hc:ciclismo',
    'Ciclismo general',
    'General biking',
    8.0,
    ['cardio'],
    PhysicalActivityTypeEntity.bicycling,
  );

  final mockUserActivity = UserActivityEntity(
    'act-123',
    30.0,
    240.0,
    selectedDay,
    mockPhysicalActivity,
    source: UserActivitySourceEntity.manual,
  );

  const mockMeal = MealEntity(
    code: 'meal-123',
    name: 'Egg and toast',
    brands: 'Homemade',
    thumbnailImageUrl: null,
    mainImageUrl: null,
    url: null,
    mealQuantity: '100',
    mealUnit: 'g',
    servingQuantity: 100.0,
    servingUnit: 'g',
    servingSize: '1 serving',
    nutriments: MealNutrimentsEntity(
      energyKcal100: 400.0,
      carbohydrates100: 30.0,
      fat100: 15.0,
      proteins100: 25.0,
      sugars100: 2.0,
      saturatedFat100: 4.0,
      fiber100: 1.0,
    ),
    source: MealSourceEntity.custom,
  );

  final mockIntake = IntakeEntity(
    id: 'intake-123',
    unit: 'g',
    amount: 100.0,
    type: IntakeTypeEntity.breakfast,
    meal: mockMeal,
    dateTime: selectedDay,
  );

  final mockTrackedDay = TrackedDayEntity(
    day: selectedDay,
    calorieGoal: 2000,
    caloriesTracked: 1200,
    carbsGoal: 250,
    carbsTracked: 150,
    fatGoal: 70,
    fatTracked: 45,
    proteinGoal: 150,
    proteinTracked: 110,
  );

  Widget createTestWidget({
    required DateTime day,
    required TrackedDayEntity? trackedDayEntity,
    required List<UserActivityEntity> userActivities,
    required List<IntakeEntity> breakfastIntake,
    required List<IntakeEntity> lunchIntake,
    required List<IntakeEntity> dinnerIntake,
    required List<IntakeEntity> snackIntake,
    required _MockNavigatorObserver navObserver,
    Function(IntakeEntity, TrackedDayEntity?)? onDeleteIntake,
    Function(UserActivityEntity, TrackedDayEntity?)? onDeleteActivity,
    Function(IntakeEntity, TrackedDayEntity?, AddMealType?)? onCopyIntake,
    Future<void> Function(IntakeEntity, TrackedDayEntity?, double)? onAdjustIntakeAmount,
    Function(UserActivityEntity, TrackedDayEntity?)? onCopyActivity,
    VoidCallback? onCopyDayToToday,
  }) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      navigatorObservers: [navObserver],
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DayInfoWidget(
              selectedDay: day,
              trackedDayEntity: trackedDayEntity,
              userActivities: userActivities,
              breakfastIntake: breakfastIntake,
              lunchIntake: lunchIntake,
              dinnerIntake: dinnerIntake,
              snackIntake: snackIntake,
              usesImperialUnits: false,
              onDeleteIntake: onDeleteIntake ?? (_, __) {},
              onDeleteActivity: onDeleteActivity ?? (_, __) {},
              onCopyIntake: onCopyIntake ?? (_, __, ___) {},
              onAdjustIntakeAmount: onAdjustIntakeAmount ?? (_, __, ___) async {},
              onCopyActivity: onCopyActivity ?? (_, __) {},
              onCopyDayToToday: onCopyDayToToday,
            ),
          ),
        ),
      ),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => Scaffold(
            body: Center(child: Text('Route: ${settings.name}')),
          ),
        );
      },
    );
  }

  testWidgets('renders EmptyDayCard and handles navigation button clicks', (tester) async {
    final navObserver = _MockNavigatorObserver();

    await tester.pumpWidget(createTestWidget(
      day: selectedDay,
      trackedDayEntity: null,
      userActivities: const [],
      breakfastIntake: const [],
      lunchIntake: const [],
      dinnerIntake: const [],
      snackIntake: const [],
      navObserver: navObserver,
    ));
    await tester.pumpAndSettle();

    // Verify Empty Day info is displayed
    expect(find.text(S.current.diaryEmptyDayTitle), findsOneWidget);

    // Click Scan AI button
    final scanBtn = find.byTooltip(S.current.scanProductLabel);
    expect(scanBtn, findsOneWidget);
    await tester.tap(scanBtn);
    await tester.pumpAndSettle();
    expect(navObserver.pushedRouteNames, contains(NavigationOptions.scannerRoute));

    // Pop back to day info screen
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    // Reset observer
    navObserver.pushedRouteNames.clear();

    // Click Text AI button
    final textAiBtn = find.byTooltip(S.current.addMealText);
    expect(textAiBtn, findsOneWidget);
    await tester.tap(textAiBtn);
    await tester.pumpAndSettle();
    expect(navObserver.pushedRouteNames, contains(NavigationOptions.mealTextCaptureRoute));

    // Pop back to day info screen
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    // Reset observer
    navObserver.pushedRouteNames.clear();

    // Click Photo AI button
    final photoAiBtn = find.byTooltip(S.current.addMealPhoto);
    expect(photoAiBtn, findsOneWidget);
    await tester.tap(photoAiBtn);
    await tester.pumpAndSettle();
    expect(navObserver.pushedRouteNames, contains(NavigationOptions.mealPhotoCaptureRoute));
  });

  testWidgets('renders DaySummaryCard when trackedDayEntity is present', (tester) async {
    final navObserver = _MockNavigatorObserver();

    await tester.pumpWidget(createTestWidget(
      day: selectedDay,
      trackedDayEntity: mockTrackedDay,
      userActivities: const [],
      breakfastIntake: const [],
      lunchIntake: const [],
      dinnerIntake: const [],
      snackIntake: const [],
      navObserver: navObserver,
    ));
    await tester.pumpAndSettle();

    // Verify summary details are displayed
    expect(find.text(S.current.diarySummaryTitle), findsOneWidget);
    expect(find.text(S.current.diaryStatusBelow), findsOneWidget);
    expect(find.text('1200 / 2000 kcal'), findsOneWidget);
    expect(find.text('800 kcal restantes'), findsOneWidget);
    
    // Macros
    expect(find.text(S.current.carbsLabel), findsOneWidget);
    expect(find.text(S.current.fatLabel), findsOneWidget);
    expect(find.text(S.current.proteinLabel), findsOneWidget);
    expect(find.text('150/250g'), findsOneWidget);
    expect(find.text('45/70g'), findsOneWidget);
    expect(find.text('110/150g'), findsOneWidget);
  });

  testWidgets('renders sections with intakes and activities and handles expand/collapse', (tester) async {
    prepareViewport(tester);
    final navObserver = _MockNavigatorObserver();

    await tester.pumpWidget(createTestWidget(
      day: selectedDay,
      trackedDayEntity: mockTrackedDay,
      userActivities: [mockUserActivity],
      breakfastIntake: [mockIntake],
      lunchIntake: const [],
      dinnerIntake: const [],
      snackIntake: const [],
      navObserver: navObserver,
    ));
    await tester.pumpAndSettle();

    // Verify list items are visible
    expect(find.text('Egg and toast'), findsOneWidget);
    expect(find.text('Ciclismo general'), findsOneWidget);

    // Kcal badge for Breakfast section (one in section header, one in food card)
    expect(find.text('400 kcal'), findsNWidgets(2));

    // Tap header of Breakfast section to collapse it
    await tester.tap(find.text(S.current.breakfastLabel));
    await tester.pumpAndSettle();

    // Intake item should now be hidden/collapsed
    expect(find.text('Egg and toast'), findsNothing);

    // Tap it again to expand
    await tester.tap(find.text(S.current.breakfastLabel));
    await tester.pumpAndSettle();
    expect(find.text('Egg and toast'), findsOneWidget);
  });

  testWidgets('long press on intake triggers action sheet and delete dialog', (tester) async {
    prepareViewport(tester);
    final navObserver = _MockNavigatorObserver();
    IntakeEntity? deletedIntake;
    TrackedDayEntity? deletedIntakeDay;

    await tester.pumpWidget(createTestWidget(
      day: selectedDay,
      trackedDayEntity: mockTrackedDay,
      userActivities: const [],
      breakfastIntake: [mockIntake],
      lunchIntake: const [],
      dinnerIntake: const [],
      snackIntake: const [],
      navObserver: navObserver,
      onDeleteIntake: (intake, day) {
        deletedIntake = intake;
        deletedIntakeDay = day;
      },
    ));
    await tester.pumpAndSettle();

    // Long press on Egg and toast card
    await tester.longPress(find.text('Egg and toast'));
    await tester.pumpAndSettle();

    // Bottom sheet dialog action should be displayed
    expect(find.text(S.current.diaryQuickAmountTitle), findsOneWidget);
    
    // Tap delete action
    await tester.tap(find.text(S.current.dialogDeleteLabel));
    await tester.pumpAndSettle();

    // Delete confirmation dialog should be shown
    expect(find.text(S.current.deleteTimeDialogTitle), findsOneWidget);
    
    // Confirm delete
    await tester.tap(find.text(S.current.dialogOKLabel));
    await tester.pumpAndSettle();

    expect(deletedIntake, mockIntake);
    expect(deletedIntakeDay, mockTrackedDay);
  });

  testWidgets('long press on activity triggers delete confirmation dialog', (tester) async {
    prepareViewport(tester);
    final navObserver = _MockNavigatorObserver();
    UserActivityEntity? deletedActivity;
    TrackedDayEntity? deletedActivityDay;

    await tester.pumpWidget(createTestWidget(
      day: selectedDay,
      trackedDayEntity: mockTrackedDay,
      userActivities: [mockUserActivity],
      breakfastIntake: const [],
      lunchIntake: const [],
      dinnerIntake: const [],
      snackIntake: const [],
      navObserver: navObserver,
      onDeleteActivity: (activity, day) {
        deletedActivity = activity;
        deletedActivityDay = day;
      },
    ));
    await tester.pumpAndSettle();

    // Long press on Bicycling card
    await tester.longPress(find.text('Ciclismo general'));
    await tester.pumpAndSettle();

    // Delete confirmation dialog should be shown directly
    expect(find.text(S.current.deleteTimeDialogTitle), findsOneWidget);
    
    // Confirm delete
    await tester.tap(find.text(S.current.dialogOKLabel));
    await tester.pumpAndSettle();

    expect(deletedActivity, mockUserActivity);
    expect(deletedActivityDay, mockTrackedDay);
  });
}

class _MockNavigatorObserver extends NavigatorObserver {
  final List<String?> pushedRouteNames = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRouteNames.add(route.settings.name);
    super.didPush(route, previousRoute);
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

class _FakeMealDetailBloc extends Bloc<MealDetailEvent, MealDetailState> implements MealDetailBloc {
  _FakeMealDetailBloc() : super(const MealDetailInitial(totalQuantityConverted: '100', selectedUnit: 'g/ml')) {
    on<MealDetailEvent>((event, emit) {});
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
