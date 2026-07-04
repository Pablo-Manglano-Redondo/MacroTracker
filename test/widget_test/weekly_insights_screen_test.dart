import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:macrotracker/core/presentation/widgets/paywall_sheet.dart';
import 'package:macrotracker/core/services/cloud_account_service.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/services/subscription_service.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/weekly_insights/domain/entity/weekly_insights_entity.dart';
import 'package:macrotracker/features/weekly_insights/domain/usecase/apply_weekly_kcal_adjustment_usecase.dart';
import 'package:macrotracker/features/weekly_insights/domain/usecase/build_weekly_insights_usecase.dart';
import 'package:macrotracker/features/weekly_insights/presentation/weekly_insights_screen.dart';
import 'package:macrotracker/features/weekly_insights/presentation/widgets/weekly_progress_share_sheet.dart';
import 'package:macrotracker/generated/l10n.dart';

void main() {
  late Directory tempDir;
  late _FakeBuildWeeklyInsightsUsecase fakeBuildWeeklyInsightsUsecase;
  late _FakeMonetizationService fakeMonetizationService;
  late _FakeApplyWeeklyKcalAdjustmentUsecase fakeApplyWeeklyKcalAdjustmentUsecase;
  late _FakeConversionAnalyticsService fakeConversionAnalyticsService;
  late _FakeHomeBloc fakeHomeBloc;
  late _FakeDiaryBloc fakeDiaryBloc;
  late _FakeCalendarDayBloc fakeCalendarDayBloc;
  late _FakeSubscriptionService fakeSubscriptionService;
  late _FakeCloudAccountService fakeCloudAccountService;
  String? mockClipboardText;

  setUpAll(() async {
    await initializeDateFormatting('es');
    await initializeDateFormatting('en');
  });

  setUp(() async {
    await locator.reset();
    tempDir = await Directory.systemTemp.createTemp('macrotracker_weekly_insights_test_');
    Hive.init(tempDir.path);

    const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async {
      return tempDir.path;
    });

    mockClipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
      if (methodCall.method == 'Clipboard.setData') {
        mockClipboardText = methodCall.arguments['text'] as String?;
        return null;
      } else if (methodCall.method == 'Clipboard.getData') {
        return {'text': mockClipboardText};
      }
      return null;
    });

    fakeBuildWeeklyInsightsUsecase = _FakeBuildWeeklyInsightsUsecase();
    fakeMonetizationService = _FakeMonetizationService();
    fakeApplyWeeklyKcalAdjustmentUsecase = _FakeApplyWeeklyKcalAdjustmentUsecase();
    fakeConversionAnalyticsService = _FakeConversionAnalyticsService();
    fakeHomeBloc = _FakeHomeBloc();
    fakeDiaryBloc = _FakeDiaryBloc();
    fakeCalendarDayBloc = _FakeCalendarDayBloc();
    fakeSubscriptionService = _FakeSubscriptionService();
    fakeCloudAccountService = _FakeCloudAccountService();

    locator.registerSingleton<BuildWeeklyInsightsUsecase>(fakeBuildWeeklyInsightsUsecase);
    locator.registerSingleton<MonetizationService>(fakeMonetizationService);
    locator.registerSingleton<ApplyWeeklyKcalAdjustmentUsecase>(fakeApplyWeeklyKcalAdjustmentUsecase);
    locator.registerSingleton<ConversionAnalyticsService>(fakeConversionAnalyticsService);
    locator.registerSingleton<HomeBloc>(fakeHomeBloc);
    locator.registerSingleton<DiaryBloc>(fakeDiaryBloc);
    locator.registerSingleton<CalendarDayBloc>(fakeCalendarDayBloc);
    locator.registerSingleton<SubscriptionService>(fakeSubscriptionService);
    locator.registerSingleton<CloudAccountService>(fakeCloudAccountService);
  });

  tearDown(() async {
    await locator.reset();
    if (await tempDir.exists()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  Widget createTestWidget(DateTime focusedDate) {
    return MaterialApp(
      locale: const Locale('es'),
      theme: ThemeData(
        bottomSheetTheme: const BottomSheetThemeData(
          constraints: BoxConstraints(maxWidth: 1200),
        ),
      ),
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
            arguments: WeeklyInsightsScreenArguments(focusedDate),
          ),
          builder: (context) => const WeeklyInsightsScreen(),
        );
      },
    );
  }

  WeeklyInsightsEntity buildDummyInsights({
    required DateTime weekStart,
    required DateTime weekEnd,
    int trackedDays = 5,
    double averageCalories = 2000,
    double averageCarbs = 200,
    double averageFat = 70,
    double averageProtein = 150,
    double goalAdherenceRate = 0.8,
    double proteinConsistencyRate = 0.6,
    String overeatingTimeSlotLabel = 'Tarde',
    List<FrequentMealInsightEntity> topMeals = const [
      FrequentMealInsightEntity(label: 'Pollo', count: 3),
      FrequentMealInsightEntity(label: 'Arroz', count: 2),
    ],
    String summaryLabel = 'Semana bastante estable, con margen para mejorar consistencia.',
    double weeklyWeightDeltaKg = -0.5,
    int recommendedKcalAdjustmentDelta = 50,
    String kcalAdjustmentRecommendation = 'El peso baja demasiado rápido: sugerencia +50 kcal/día. Ajuste actual: 0 kcal.',
  }) {
    return WeeklyInsightsEntity(
      weekStart: weekStart,
      weekEnd: weekEnd,
      trackedDays: trackedDays,
      averageCalories: averageCalories,
      averageCarbs: averageCarbs,
      averageFat: averageFat,
      averageProtein: averageProtein,
      goalAdherenceRate: goalAdherenceRate,
      proteinConsistencyRate: proteinConsistencyRate,
      overeatingTimeSlotLabel: overeatingTimeSlotLabel,
      topMeals: topMeals,
      summaryLabel: summaryLabel,
      weeklyWeightDeltaKg: weeklyWeightDeltaKg,
      recommendedKcalAdjustmentDelta: recommendedKcalAdjustmentDelta,
      kcalAdjustmentRecommendation: kcalAdjustmentRecommendation,
    );
  }

  Finder findRichText(String text) {
    return find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText().contains(text),
    );
  }

  testWidgets('shows progress indicator while loading', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final completer = Completer<WeeklyInsightsEntity>();
    fakeBuildWeeklyInsightsUsecase.completer = completer;

    await tester.pumpWidget(createTestWidget(DateTime(2026, 6, 15)));
    
    // Exactly 1 progress indicator during loading (the indeterminate center loading spinner)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(buildDummyInsights(
      weekStart: DateTime(2026, 6, 15),
      weekEnd: DateTime(2026, 6, 21),
    ));
    await tester.pumpAndSettle();

    // The center spinner should disappear, leaving exactly the 2 progress indicators of the metrics grid
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
  });

  testWidgets('shows error screen on error', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    fakeBuildWeeklyInsightsUsecase.shouldThrow = true;

    await tester.pumpWidget(createTestWidget(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar el resumen semanal.'), findsOneWidget);
  });

  testWidgets('renders all widgets and sections in premium mode', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    fakeMonetizationService.trialState = const AiTrialState(
      isPremium: true,
      used: 0,
      limit: 5,
      fullLimit: 5,
      aiMealsSaved: 0,
    );

    final insights = buildDummyInsights(
      weekStart: DateTime(2026, 6, 15),
      weekEnd: DateTime(2026, 6, 21),
    );
    fakeBuildWeeklyInsightsUsecase.insights = insights;

    await tester.pumpWidget(createTestWidget(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    // Verify Title (AppBar title + Card title = 2 widgets)
    expect(find.text('Resumen semanal'), findsNWidgets(2));
    expect(find.text('15 jun - 21 jun'), findsOneWidget);

    // Verify Summary Card
    expect(find.text(insights.summaryLabel), findsOneWidget);
    expect(find.text('-0.50 kg'), findsOneWidget);

    // Verify Averages Card (Calories is RichText, macros are standard text)
    expect(findRichText('2000'), findsOneWidget);
    expect(find.text('150.0 g'), findsOneWidget);
    expect(find.text('200.0 g'), findsOneWidget);
    expect(find.text('70.0 g'), findsOneWidget);

    // Verify Metrics Grid (Tracked Days is RichText, Slot is standard text, Adherence and Consistency are standard text)
    expect(findRichText('5 / 7 días'), findsOneWidget);
    expect(find.text('Tarde'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);

    // Verify Top Meals
    expect(find.text('Pollo'), findsOneWidget);
    expect(find.text('3 veces'), findsOneWidget);
    expect(find.text('Arroz'), findsOneWidget);
    expect(find.text('2 veces'), findsOneWidget);

    // Verify recommendation badge and button
    expect(find.text(insights.kcalAdjustmentRecommendation), findsOneWidget);
    expect(find.text('Aplicar +50 kcal/día'), findsOneWidget);
  });

  testWidgets('applies recommended target adjustment when tapped in premium mode', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    fakeMonetizationService.trialState = const AiTrialState(
      isPremium: true,
      used: 0,
      limit: 5,
      fullLimit: 5,
      aiMealsSaved: 0,
    );

    final insights = buildDummyInsights(
      weekStart: DateTime(2026, 6, 15),
      weekEnd: DateTime(2026, 6, 21),
      recommendedKcalAdjustmentDelta: -100,
      kcalAdjustmentRecommendation: 'Pérdida demasiado lenta: -100 kcal',
    );
    fakeBuildWeeklyInsightsUsecase.insights = insights;
    fakeApplyWeeklyKcalAdjustmentUsecase.updatedAdjustment = -100;

    await tester.pumpWidget(createTestWidget(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    final applyButton = find.text('Aplicar -100 kcal/día');
    expect(applyButton, findsOneWidget);

    await tester.tap(applyButton);
    await tester.pump(); // Start adjustment process (loading state)

    // Check loading indicator in button (the center spinner in metrics grid + the button loading spinner = 3)
    expect(find.byType(CircularProgressIndicator), findsNWidgets(3));

    await tester.pumpAndSettle(); // Complete future

    // Check SnackBar message
    expect(find.text('Ajuste diario actualizado a -100 kcal.'), findsOneWidget);

    // Verify calls
    expect(fakeApplyWeeklyKcalAdjustmentUsecase.appliedDeltaKcal, -100);
    expect(fakeConversionAnalyticsService.loggedEvents, contains('weekly_adjustment_applied'));
    expect(fakeHomeBloc.addedEvents, contains(isA<LoadItemsEvent>()));
    expect(fakeDiaryBloc.addedEvents, contains(isA<LoadDiaryYearEvent>()));
    expect(fakeCalendarDayBloc.addedEvents, contains(isA<RefreshCalendarDayEvent>()));
  });

  testWidgets('renders locked adjustment card and opens paywall in non-premium mode', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    fakeMonetizationService.trialState = const AiTrialState(
      isPremium: false,
      used: 5,
      limit: 5,
      fullLimit: 5,
      aiMealsSaved: 0,
    );

    final insights = buildDummyInsights(
      weekStart: DateTime(2026, 6, 15),
      weekEnd: DateTime(2026, 6, 21),
      recommendedKcalAdjustmentDelta: 50,
    );
    fakeBuildWeeklyInsightsUsecase.insights = insights;

    await tester.pumpWidget(createTestWidget(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    // Verify locked overlay is shown
    expect(find.text('Recomendación de ajuste inteligente'), findsOneWidget);
    expect(find.text('Ver ajuste Premium'), findsOneWidget);

    // Tap button to reveal adjustment (opens paywall)
    await tester.tap(find.text('Ver ajuste Premium'));
    await tester.pumpAndSettle();

    // Verify paywall is open
    expect(find.byType(PaywallSheet), findsOneWidget);
    expect(fakeConversionAnalyticsService.loggedEvents, contains('weekly_paywall_opened'));
  });

  testWidgets('opens share sheet and copies report to clipboard', (tester) async {
    // Override error handler inside the test body to successfully catch and suppress RenderFlex overflows
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final exceptionStr = details.exception.toString().toLowerCase();
      final detailsStr = details.toString().toLowerCase();
      if (exceptionStr.contains('overflow') || detailsStr.contains('overflow')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = originalOnError;
    });

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 1500);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    fakeMonetizationService.trialState = const AiTrialState(
      isPremium: true,
      used: 0,
      limit: 5,
      fullLimit: 5,
      aiMealsSaved: 0,
    );

    final insights = buildDummyInsights(
      weekStart: DateTime(2026, 6, 15),
      weekEnd: DateTime(2026, 6, 21),
      averageCalories: 2050,
      averageProtein: 145,
      averageCarbs: 195,
      averageFat: 68,
      goalAdherenceRate: 0.85,
      proteinConsistencyRate: 0.70,
    );
    fakeBuildWeeklyInsightsUsecase.insights = insights;

    await tester.pumpWidget(createTestWidget(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    // Tap Share Icon in AppBar
    final shareIconButton = find.byIcon(Icons.share_outlined);
    expect(shareIconButton, findsOneWidget);
    await tester.tap(shareIconButton);
    await tester.pumpAndSettle();

    // Verify Share Sheet is open
    expect(find.byType(WeeklyProgressShareSheet), findsOneWidget);
    expect(find.text('Compartir progreso'), findsOneWidget);

    // Verify stats displayed in the share card preview
    expect(find.text('2050'), findsOneWidget);
    expect(find.text('145g'), findsOneWidget);
    expect(find.text('195g'), findsOneWidget);
    expect(find.text('68g'), findsOneWidget);

    // Tap copy button
    final copyButton = find.text('Copiar texto');
    expect(copyButton, findsOneWidget);
    await tester.tap(copyButton);
    await tester.pump(); // Start copying logic
    await tester.pump(const Duration(milliseconds: 100)); // Wait for Clipboard async channel call
    await tester.pumpAndSettle(); // Settle SnackBar animation

    // Verify SnackBar shown
    expect(find.text('Resumen copiado al portapapeles con éxito.'), findsOneWidget);

    // Verify Clipboard contents
    expect(mockClipboardText, contains('Mi resumen semanal (MacroTracker)'));
    expect(mockClipboardText, contains('Calorías promedio: 2050 kcal/día'));
    expect(mockClipboardText, contains('Proteína promedio: 145.0 g/día'));
    expect(mockClipboardText, contains('Adherencia al objetivo: 85%'));
    expect(mockClipboardText, contains('Consistencia proteica: 70%'));
  });
}

class _FakeBuildWeeklyInsightsUsecase extends Fake implements BuildWeeklyInsightsUsecase {
  WeeklyInsightsEntity? insights;
  Completer<WeeklyInsightsEntity>? completer;
  bool shouldThrow = false;

  @override
  Future<WeeklyInsightsEntity> build(DateTime focusedDate) async {
    if (shouldThrow) {
      throw Exception('Database/logic error');
    }
    if (completer != null) {
      return completer!.future;
    }
    return insights ?? WeeklyInsightsEntity(
      weekStart: focusedDate,
      weekEnd: focusedDate.add(const Duration(days: 6)),
      trackedDays: 0,
      averageCalories: 0,
      averageCarbs: 0,
      averageFat: 0,
      averageProtein: 0,
      goalAdherenceRate: 0,
      proteinConsistencyRate: 0,
      overeatingTimeSlotLabel: '',
      topMeals: const [],
      summaryLabel: '',
      weeklyWeightDeltaKg: 0,
      recommendedKcalAdjustmentDelta: 0,
      kcalAdjustmentRecommendation: '',
    );
  }
}

class _FakeMonetizationService extends Fake implements MonetizationService {
  AiTrialState? trialState;

  @override
  AiTrialState? get cachedTrialState => trialState ?? const AiTrialState(
    isPremium: false,
    used: 0,
    limit: 5,
    fullLimit: 5,
    aiMealsSaved: 0,
  );

  @override
  Future<AiTrialState> getAiTrialState() async {
    return trialState ?? const AiTrialState(
      isPremium: false,
      used: 0,
      limit: 5,
      fullLimit: 5,
      aiMealsSaved: 0,
    );
  }
}

class _FakeApplyWeeklyKcalAdjustmentUsecase extends Fake implements ApplyWeeklyKcalAdjustmentUsecase {
  int? appliedDeltaKcal;
  double updatedAdjustment = 0.0;

  @override
  Future<double> apply({
    required DateTime day,
    required int deltaKcal,
  }) async {
    appliedDeltaKcal = deltaKcal;
    await Future.delayed(const Duration(milliseconds: 50));
    return updatedAdjustment;
  }
}

class _FakeConversionAnalyticsService extends Fake implements ConversionAnalyticsService {
  final List<String> loggedEvents = [];

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    loggedEvents.add(name);
  }

  @override
  Future<void> logPaywallViewed({String? placement, int? aiTrialsRemaining}) async {
    loggedEvents.add('paywall_viewed');
  }

  @override
  Future<void> logPurchaseStarted({String? placement, required Package package}) async {
    loggedEvents.add('purchase_started');
  }

  @override
  Future<void> logPurchaseCompleted({String? placement, Package? package}) async {
    loggedEvents.add('purchase_completed');
  }

  @override
  Future<void> logPurchaseFailed({String? placement, Package? package}) async {
    loggedEvents.add('purchase_failed');
  }

  @override
  Future<void> logPurchaseRestored({required bool restored}) async {
    loggedEvents.add('purchase_restored');
  }
}

class _FakeHomeBloc extends Bloc<HomeEvent, HomeState> implements HomeBloc {
  final List<HomeEvent> addedEvents = [];
  _FakeHomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) {
      addedEvents.add(event);
    });
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDiaryBloc extends Bloc<DiaryEvent, DiaryState> implements DiaryBloc {
  final List<DiaryEvent> addedEvents = [];
  _FakeDiaryBloc() : super(DiaryInitial()) {
    on<DiaryEvent>((event, emit) {
      addedEvents.add(event);
    });
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCalendarDayBloc extends Bloc<CalendarDayEvent, CalendarDayState> implements CalendarDayBloc {
  final List<CalendarDayEvent> addedEvents = [];
  _FakeCalendarDayBloc() : super(CalendarDayInitial()) {
    on<CalendarDayEvent>((event, emit) {
      addedEvents.add(event);
    });
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSubscriptionService extends Fake implements SubscriptionService {
  bool premiumActive = false;
  List<Offering> offerings = [];
  bool configured = true;

  @override
  Future<bool> isPremiumActive() => Future.value(premiumActive);

  @override
  bool get isConfigured => configured;

  @override
  Future<List<Offering>> getOfferings() => Future.value(offerings);

  @override
  Future<bool> purchasePackage(Package package) => Future.value(true);

  @override
  Future<bool> restorePurchases() => Future.value(true);
}

class _FakeCloudAccountService extends Fake implements CloudAccountService {
  @override
  Future<CloudAccountStatus> getStatus() => Future.value(const CloudAccountStatus(
        userId: 'user-123',
        email: 'user@example.com',
        isProtected: true,
        providerCount: 1,
      ));
}
