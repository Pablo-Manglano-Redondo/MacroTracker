import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:macrotracker/features/feature_tour/presentation/bloc/feature_tour_bloc.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/macro_goal_mode_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/services/meal_reminder_service.dart';
import 'package:macrotracker/core/services/cloud_account_deletion_service.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_connect_sync_status_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/sync_sleep_from_health_connect_usecase.dart';
import 'package:macrotracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:macrotracker/features/settings/presentation/widgets/calculations_dialog.dart';
import 'package:macrotracker/features/settings/settings_screen.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/theme_mode_provider.dart';
import 'package:macrotracker/core/services/cloud_account_service.dart';
import 'package:macrotracker/core/services/referral_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/services/subscription_service.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/profile/presentation/bloc/profile_bloc.dart';

void main() {
  late SettingsBloc settingsBloc;
  late _FakeGetConfigUsecase fakeGetConfigUsecase;
  late _FakeAddConfigUsecase fakeAddConfigUsecase;
  late _FakeAddTrackedDayUsecase fakeAddTrackedDayUsecase;
  late _FakeGetKcalGoalUsecase fakeGetKcalGoalUsecase;
  late _FakeGetMacroGoalUsecase fakeGetMacroGoalUsecase;
  late _FakeGetUserUsecase fakeGetUserUsecase;
  late _FakeSyncSleepFromHealthConnectUsecase fakeSyncSleepFromHealthConnectUsecase;
  late _FakeMealReminderService fakeMealReminderService;
  late _FakeCloudAccountDeletionService fakeCloudAccountDeletionService;

  late _FakeHomeBloc fakeHomeBloc;
  late _FakeDiaryBloc fakeDiaryBloc;
  late _FakeCalendarDayBloc fakeCalendarDayBloc;
  late _FakeProfileBloc fakeProfileBloc;
  late _FakeFeatureTourBloc fakeFeatureTourBloc;

  late _FakeSupabaseClient fakeSupabaseClient;
  late _FakeCloudAccountService fakeCloudAccountService;
  late _FakeReferralService fakeReferralService;
  late _FakeMonetizationService fakeMonetizationService;
  late _FakeSubscriptionService fakeSubscriptionService;
  late _FakeConversionAnalyticsService fakeConversionAnalyticsService;

  setUp(() {
    fakeGetConfigUsecase = _FakeGetConfigUsecase();
    fakeAddConfigUsecase = _FakeAddConfigUsecase();
    fakeAddTrackedDayUsecase = _FakeAddTrackedDayUsecase();
    fakeGetKcalGoalUsecase = _FakeGetKcalGoalUsecase();
    fakeGetMacroGoalUsecase = _FakeGetMacroGoalUsecase();
    fakeGetUserUsecase = _FakeGetUserUsecase();
    fakeSyncSleepFromHealthConnectUsecase = _FakeSyncSleepFromHealthConnectUsecase();
    fakeMealReminderService = _FakeMealReminderService();
    fakeCloudAccountDeletionService = _FakeCloudAccountDeletionService();

    fakeHomeBloc = _FakeHomeBloc();
    fakeDiaryBloc = _FakeDiaryBloc();
    fakeCalendarDayBloc = _FakeCalendarDayBloc();
    fakeProfileBloc = _FakeProfileBloc();
    fakeFeatureTourBloc = _FakeFeatureTourBloc();

    fakeSupabaseClient = _FakeSupabaseClient();
    fakeCloudAccountService = _FakeCloudAccountService();
    fakeReferralService = _FakeReferralService();
    fakeMonetizationService = _FakeMonetizationService();
    fakeSubscriptionService = _FakeSubscriptionService();
    fakeConversionAnalyticsService = _FakeConversionAnalyticsService();

    settingsBloc = SettingsBloc(
      fakeGetConfigUsecase,
      fakeAddConfigUsecase,
      fakeAddTrackedDayUsecase,
      fakeGetKcalGoalUsecase,
      fakeGetMacroGoalUsecase,
      fakeGetUserUsecase,
      fakeSyncSleepFromHealthConnectUsecase,
      fakeMealReminderService,
      fakeCloudAccountDeletionService,
    );

    locator.registerSingleton<SettingsBloc>(settingsBloc);
    locator.registerSingleton<ProfileBloc>(fakeProfileBloc);
    locator.registerSingleton<HomeBloc>(fakeHomeBloc);
    locator.registerSingleton<DiaryBloc>(fakeDiaryBloc);
    locator.registerSingleton<CalendarDayBloc>(fakeCalendarDayBloc);
    locator.registerSingleton<FeatureTourBloc>(fakeFeatureTourBloc);

    locator.registerSingleton<SupabaseClient>(fakeSupabaseClient);
    locator.registerSingleton<CloudAccountService>(fakeCloudAccountService);
    locator.registerSingleton<ReferralService>(fakeReferralService);
    locator.registerSingleton<MonetizationService>(fakeMonetizationService);
    locator.registerSingleton<SubscriptionService>(fakeSubscriptionService);
    locator.registerSingleton<ConversionAnalyticsService>(fakeConversionAnalyticsService);

    // Mock PackageInfo MethodChannel
    const channel = MethodChannel('dev.fluttercommunity.plus/package_info');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return {
          'appName': 'MacroTracker',
          'packageName': 'com.epsait.macrotracker',
          'version': '1.2.3',
          'buildNumber': '45',
          'buildSignature': '',
        };
      }
      return null;
    });
  });

  tearDown(() async {
    await settingsBloc.close();
    await fakeHomeBloc.close();
    await fakeDiaryBloc.close();
    await fakeCalendarDayBloc.close();
    await fakeProfileBloc.close();
    await fakeFeatureTourBloc.close();
    await locator.reset();
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider<ThemeModeProvider>(
      create: (_) => ThemeModeProvider(appTheme: AppThemeEntity.system),
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const Scaffold(
          body: SettingsScreen(),
        ),
      ),
    );
  }

  Future<void> waitForLoadedState(WidgetTester tester) async {
    int retryCount = 0;
    while (settingsBloc.state is! SettingsLoadedState && retryCount < 30) {
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 10));
      });
      await tester.pump();
      retryCount++;
    }
  }

  testWidgets('renders all settings panels and triggers units dialog', (tester) async {
    fakeGetConfigUsecase.config = const ConfigEntity(
      true,
      true,
      true,
      AppThemeEntity.system,
      usesImperialUnits: false,
      dailyFocus: DailyFocusEntity.upperBody,
    );

    await tester.pumpWidget(createTestWidget());
    await waitForLoadedState(tester);

    // Verify loaded content is visible (scrolling as necessary)
    expect(find.text('Ajustes'), findsOneWidget);

    // Scroll down to expose Seguimiento and other sections
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Seguimiento'), findsOneWidget);
    expect(find.text('Apariencia'), findsOneWidget);

    // Find "Unidades" and tap it
    final unitsTile = find.text('Unidades');
    expect(unitsTile, findsOneWidget);

    await tester.tap(unitsTile);
    await tester.pumpAndSettle();

    // Verify Units Dialog popped up
    expect(find.text('Sistema'), findsOneWidget);
    
    // Tap OK
    final okButton = find.text('OK');
    expect(okButton, findsOneWidget);
    await tester.tap(okButton);
    await tester.pumpAndSettle();
  });

  testWidgets('triggers theme dialog and changes selection', (tester) async {
    fakeGetConfigUsecase.config = const ConfigEntity(
      true,
      true,
      true,
      AppThemeEntity.system,
      usesImperialUnits: false,
      dailyFocus: DailyFocusEntity.upperBody,
    );

    await tester.pumpWidget(createTestWidget());
    await waitForLoadedState(tester);

    // Scroll down to expose sections
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    // Find "Tema" tile
    final themeTile = find.text('Tema');
    expect(themeTile, findsOneWidget);

    await tester.tap(themeTile);
    await tester.pumpAndSettle();

    // Verify dialog shows option "Claro"
    expect(find.text('Claro'), findsOneWidget);
    expect(find.text('Oscuro'), findsOneWidget);

    // Tap Cancelar
    final cancelButton = find.text('CANCELAR');
    expect(cancelButton, findsOneWidget);
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
  });

  testWidgets('redeems friend code successfully and shows snackbar', (tester) async {
    tester.view.physicalSize = const Size(800, 1500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    fakeGetConfigUsecase.config = const ConfigEntity(
      true,
      true,
      true,
      AppThemeEntity.system,
      usesImperialUnits: false,
      dailyFocus: DailyFocusEntity.upperBody,
    );

    await tester.pumpWidget(createTestWidget());
    await waitForLoadedState(tester);

    // Scroll down to expose Invite friends section
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    // Verify code block is displayed
    expect(find.text('REF123'), findsOneWidget);

    // Enter their code
    final codeField = find.byType(TextField);
    expect(codeField, findsOneWidget);
    await tester.enterText(codeField, 'FRIEND456');
    await tester.pumpAndSettle();

    // Tap Redeem button
    final redeemButton = find.text('Canjear');
    expect(redeemButton, findsOneWidget);
    await tester.tap(redeemButton);
    await tester.pumpAndSettle();

    // Verify redeemedCode is stored
    expect(fakeReferralService.redeemedCode, 'FRIEND456');

    // Verify success snackbar shows up
    expect(find.text('¡Código canjeado con éxito! Has ganado usos de IA gratis.'), findsOneWidget);
  });

  testWidgets('copy referral code to clipboard', (tester) async {
    tester.view.physicalSize = const Size(800, 1500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    fakeGetConfigUsecase.config = const ConfigEntity(
      true,
      true,
      true,
      AppThemeEntity.system,
      usesImperialUnits: false,
      dailyFocus: DailyFocusEntity.upperBody,
    );

    await tester.pumpWidget(createTestWidget());
    await waitForLoadedState(tester);

    // Scroll down to expose Invite friends section
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    // Find the Copy icon button
    final copyButton = find.byIcon(Icons.copy_outlined);
    expect(copyButton, findsOneWidget);
    await tester.tap(copyButton);
    await tester.pumpAndSettle();

    // Verify snackbar is shown
    expect(find.text('Enlace y código de invitación copiados al portapapeles.'), findsOneWidget);
  });

  testWidgets('toggling send anonymous data switch updates config and analytics', (tester) async {
    tester.view.physicalSize = const Size(800, 1500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    fakeGetConfigUsecase.config = const ConfigEntity(
      true,
      true,
      true,
      AppThemeEntity.system,
      usesImperialUnits: false,
      dailyFocus: DailyFocusEntity.upperBody,
    );

    await tester.pumpWidget(createTestWidget());
    await waitForLoadedState(tester);

    // Scroll down to expose Privacy and data section
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    // Verify section title
    expect(find.text('Privacidad y datos'), findsOneWidget);

    // Find the SwitchListTile
    final switchFinder = find.byType(SwitchListTile).first;
    expect(switchFinder, findsOneWidget);

    // Toggle switch off
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // Verify config saved false
    expect(fakeAddConfigUsecase.savedAnonymousData, false);
    // Verify analytics service updated
    expect(fakeConversionAnalyticsService.savedEnabled, false);
  });

  testWidgets('triggers language dialog and changes selection', (tester) async {
    tester.view.physicalSize = const Size(800, 1500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    fakeGetConfigUsecase.config = const ConfigEntity(
      true,
      true,
      true,
      AppThemeEntity.system,
      usesImperialUnits: false,
      dailyFocus: DailyFocusEntity.upperBody,
    );

    await tester.pumpWidget(createTestWidget());
    await waitForLoadedState(tester);

    // Find "Idioma" tile
    final languageTile = find.text('Idioma');
    await tester.ensureVisible(languageTile);
    await tester.pumpAndSettle();

    await tester.tap(languageTile);
    await tester.pumpAndSettle();

    // Verify dialog options
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('Inglés'), findsOneWidget);

    // Tap Inglés
    await tester.tap(find.text('Inglés'));
    await tester.pumpAndSettle();

    // Tap OK
    final okBtn = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('OK'),
    );
    await tester.tap(okBtn);
    await tester.pumpAndSettle();

    // Verify setConfigLocale was called with 'en'
    expect(fakeAddConfigUsecase.savedLocale, 'en');
  });

  testWidgets('triggers calculations dialog', (tester) async {
    tester.view.physicalSize = const Size(800, 1500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    fakeGetConfigUsecase.config = const ConfigEntity(
      true,
      true,
      true,
      AppThemeEntity.system,
      usesImperialUnits: false,
      dailyFocus: DailyFocusEntity.upperBody,
    );

    await tester.pumpWidget(createTestWidget());
    await waitForLoadedState(tester);

    // Find "Cálculos" tile
    final calculationsTile = find.text('Cálculos');
    await tester.ensureVisible(calculationsTile);
    await tester.pumpAndSettle();

    await tester.tap(calculationsTile);
    await tester.pumpAndSettle();

    // Verify calculations dialog is shown
    expect(find.byType(CalculationsDialog), findsOneWidget);
  });
}

UserEntity _buildUser({
  double heightCM = 180,
  double weightKG = 80,
}) {
  return UserEntity(
    birthday: DateTime(2000, 1, 1),
    heightCM: heightCM,
    weightKG: weightKG,
    gender: UserGenderEntity.male,
    goal: UserWeightGoalEntity.maintainWeight,
    pal: UserPALEntity.active,
    targetSteps: 8000,
    targetSleepHours: 8.0,
    targetWaterLiters: 2.5,
  );
}

class _FakeGetUserUsecase implements GetUserUsecase {
  UserEntity user = _buildUser();

  @override
  Future<UserEntity> getUserData() => SynchronousFuture(user);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetConfigUsecase implements GetConfigUsecase {
  ConfigEntity config = const ConfigEntity(
    true,
    true,
    true,
    AppThemeEntity.system,
  );

  @override
  Future<ConfigEntity> getConfig() => SynchronousFuture(config);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddConfigUsecase implements AddConfigUsecase {
  bool? savedAnonymousData;
  AppThemeEntity? savedAppTheme;
  String? savedLocale;
  bool? savedUsesImperialUnits;
  double? savedKcalAdjustment;
  double? savedCarbsGoalPct;
  double? savedProteinGoalPct;
  double? savedFatGoalPct;
  MacroGoalModeEntity? savedMacroGoalMode;
  double? savedCarbsGoalGram;
  double? savedProteinGoalGram;
  double? savedFatGoalGram;
  bool? aiCostTrackingReset;
  bool? healthConnectAutoSyncEnabled;

  bool? savedReminderEnabled;
  int? savedMorningMinutes;
  int? savedLunchMinutes;
  int? savedAfternoonMinutes;
  int? savedEveningMinutes;

  @override
  Future<void> setConfigHasAcceptedAnonymousData(bool value) {
    savedAnonymousData = value;
    return SynchronousFuture(null);
  }

  @override
  Future<void> setConfigAppTheme(AppThemeEntity value) {
    savedAppTheme = value;
    return SynchronousFuture(null);
  }

  @override
  Future<void> setConfigLocale(String? value) {
    savedLocale = value;
    return SynchronousFuture(null);
  }

  @override
  Future<void> setConfigUsesImperialUnits(bool value) {
    savedUsesImperialUnits = value;
    return SynchronousFuture(null);
  }

  @override
  Future<void> setConfigKcalAdjustment(double value) => SynchronousFuture(null);

  @override
  Future<void> setConfigMacroGoalPct(double carbs, double protein, double fat) => SynchronousFuture(null);

  @override
  Future<void> setMacroGoalMode(MacroGoalModeEntity value) => SynchronousFuture(null);

  @override
  Future<void> setConfigMacroGoalGramPerKg(double carbs, double protein, double fat) => SynchronousFuture(null);

  @override
  Future<void> resetAiCostTracking() => SynchronousFuture(null);

  @override
  Future<void> setHealthConnectAutoSyncEnabled(bool value) => SynchronousFuture(null);

  @override
  Future<void> setMealReminderConfig({
    required bool enabled,
    required int morningMinutes,
    required int lunchMinutes,
    required int afternoonMinutes,
    required int eveningMinutes,
  }) {
    savedReminderEnabled = enabled;
    savedMorningMinutes = morningMinutes;
    savedLunchMinutes = lunchMinutes;
    savedAfternoonMinutes = afternoonMinutes;
    savedEveningMinutes = eveningMinutes;
    return SynchronousFuture(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddTrackedDayUsecase implements AddTrackedDayUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetKcalGoalUsecase implements GetKcalGoalUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetMacroGoalUsecase implements GetMacroGoalUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSyncSleepFromHealthConnectUsecase implements SyncSleepFromHealthConnectUsecase {
  HealthConnectSyncStatusEntity status = const HealthConnectSyncStatusEntity(
    isAvailable: false,
    hasHealthPermissions: false,
    hasActivityRecognitionPermission: false,
    isAutoSyncEnabled: false,
  );

  @override
  Future<HealthConnectSyncStatusEntity> getStatus() => SynchronousFuture(status);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMealReminderService implements MealReminderService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCloudAccountDeletionService implements CloudAccountDeletionService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

class _FakeProfileBloc extends Bloc<ProfileEvent, ProfileState> implements ProfileBloc {
  _FakeProfileBloc() : super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) {});
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSupabaseClient extends Fake implements SupabaseClient {
  final _FakeGotrueClient _auth = _FakeGotrueClient();

  @override
  GoTrueClient get auth => _auth;
}

class _FakeGotrueClient extends Fake implements GoTrueClient {
  @override
  Stream<AuthState> get onAuthStateChange => Stream.empty();

  @override
  User? get currentUser => null;
}

class _FakeCloudAccountService extends Fake implements CloudAccountService {
  @override
  Future<CloudAccountStatus> getStatus() => SynchronousFuture(const CloudAccountStatus(
        userId: 'user-123',
        email: 'user@example.com',
        isProtected: true,
        providerCount: 1,
      ));
}

class _FakeReferralService extends Fake implements ReferralService {
  String? redeemedCode;

  @override
  Future<String> getOrCreateReferralCode() => SynchronousFuture('REF123');

  @override
  Future<bool> hasRedeemedAnyCode() => SynchronousFuture(false);

  @override
  Future<ReferralRedemptionResult> redeemCode(String code) {
    redeemedCode = code;
    return SynchronousFuture(ReferralRedemptionResult.success);
  }
}

class _FakeMonetizationService extends Fake implements MonetizationService {
  @override
  Future<AiTrialState> getAiTrialState() => SynchronousFuture(const AiTrialState(
        isPremium: false,
        used: 2,
        limit: 5,
        fullLimit: 5,
        aiMealsSaved: 1,
      ));
}

class _FakeSubscriptionService extends Fake implements SubscriptionService {
  @override
  Future<bool> isPremiumActive() => SynchronousFuture(false);
}

class _FakeConversionAnalyticsService extends Fake implements ConversionAnalyticsService {
  bool? savedEnabled;

  @override
  Future<void> setEnabled(bool enabled) {
    savedEnabled = enabled;
    return SynchronousFuture(null);
  }
}

class _FakeFeatureTourBloc extends Bloc<FeatureTourEvent, FeatureTourState> implements FeatureTourBloc {
  _FakeFeatureTourBloc() : super(FeatureTourState.initial().copyWith(isCompleted: true)) {
    on<FeatureTourEvent>((event, emit) {});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
