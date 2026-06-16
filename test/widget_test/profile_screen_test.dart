import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_user_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:macrotracker/features/profile/profile_screen.dart';
import 'package:macrotracker/generated/l10n.dart';

void main() {
  late ProfileBloc bloc;
  late _FakeGetUserUsecase fakeGetUserUsecase;
  late _FakeAddUserUsecase fakeAddUserUsecase;
  late _FakeAddTrackedDayUsecase fakeAddTrackedDayUsecase;
  late _FakeGetConfigUsecase fakeGetConfigUsecase;
  late _FakeGetKcalGoalUsecase fakeGetKcalGoalUsecase;
  late _FakeGetMacroGoalUsecase fakeGetMacroGoalUsecase;
  late _FakeGetGymTargetsUsecase fakeGetGymTargetsUsecase;

  late _FakeHomeBloc fakeHomeBloc;
  late _FakeDiaryBloc fakeDiaryBloc;
  late _FakeCalendarDayBloc fakeCalendarDayBloc;

  setUp(() {
    fakeGetUserUsecase = _FakeGetUserUsecase();
    fakeAddUserUsecase = _FakeAddUserUsecase();
    fakeAddTrackedDayUsecase = _FakeAddTrackedDayUsecase();
    fakeGetConfigUsecase = _FakeGetConfigUsecase();
    fakeGetKcalGoalUsecase = _FakeGetKcalGoalUsecase();
    fakeGetMacroGoalUsecase = _FakeGetMacroGoalUsecase();
    fakeGetGymTargetsUsecase = _FakeGetGymTargetsUsecase();

    fakeHomeBloc = _FakeHomeBloc();
    fakeDiaryBloc = _FakeDiaryBloc();
    fakeCalendarDayBloc = _FakeCalendarDayBloc();

    bloc = ProfileBloc(
      fakeGetUserUsecase,
      fakeAddUserUsecase,
      fakeAddTrackedDayUsecase,
      fakeGetConfigUsecase,
      fakeGetKcalGoalUsecase,
      fakeGetMacroGoalUsecase,
      fakeGetGymTargetsUsecase,
    );

    locator.registerSingleton<ProfileBloc>(bloc);
    locator.registerSingleton<HomeBloc>(fakeHomeBloc);
    locator.registerSingleton<DiaryBloc>(fakeDiaryBloc);
    locator.registerSingleton<CalendarDayBloc>(fakeCalendarDayBloc);
  });

  tearDown(() async {
    await bloc.close();
    await fakeHomeBloc.close();
    await fakeDiaryBloc.close();
    await fakeCalendarDayBloc.close();
    await locator.reset();
  });

  Widget createTestWidget() {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const Scaffold(
        body: ProfileScreen(),
      ),
    );
  }

  Future<void> waitForLoadedState(WidgetTester tester) async {
    int retryCount = 0;
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty && retryCount < 30) {
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 10));
      });
      await tester.pump();
      retryCount++;
    }
  }

  testWidgets('renders loading state initially, then shows profile loaded content', (tester) async {
    final user = _buildUser(heightCM: 180, weightKG: 80);
    fakeGetUserUsecase.user = user;
    fakeGetConfigUsecase.config = const ConfigEntity(
      true,
      true,
      true,
      AppThemeEntity.system,
      usesImperialUnits: false,
      dailyFocus: DailyFocusEntity.upperBody,
    );
    fakeGetGymTargetsUsecase.targets = const GymTargetsEntity(
      kcalGoal: 2000,
      carbsGoal: 250,
      fatGoal: 65,
      proteinGoal: 150,
    );

    await tester.pumpWidget(createTestWidget());

    // Expect loading spinner
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the LoadProfileEvent complete
    await waitForLoadedState(tester);

    // Verify loading spinner is gone and Profile content is displayed
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('Perfil deportivo'), findsOneWidget);
    expect(find.textContaining('Tu perfil'), findsOneWidget);

    // Height & weight chips
    expect(find.text('180 cm'), findsOneWidget);
    expect(find.text('80 kg'), findsOneWidget);

    // Target cards values & labels
    expect(find.text('2000'), findsOneWidget);
    expect(find.text('Kcal'), findsOneWidget);
    expect(find.text('250 g'), findsOneWidget);
    expect(find.text('carbos'), findsOneWidget);
    expect(find.text('65 g'), findsOneWidget);
    expect(find.text('grasas'), findsOneWidget);
    expect(find.text('150 g'), findsOneWidget);
    expect(find.text('proteínas'), findsOneWidget);
  });

  testWidgets('clicking steps goal opens dialog, enters value, and saves user', (tester) async {
    final user = _buildUser(heightCM: 180, weightKG: 80, targetSteps: 8000);
    fakeGetUserUsecase.user = user;
    fakeGetConfigUsecase.config = const ConfigEntity(
      true,
      true,
      true,
      AppThemeEntity.system,
      usesImperialUnits: false,
      dailyFocus: DailyFocusEntity.upperBody,
    );
    fakeGetGymTargetsUsecase.targets = const GymTargetsEntity(
      kcalGoal: 2000,
      carbsGoal: 250,
      fatGoal: 65,
      proteinGoal: 150,
    );

    await tester.pumpWidget(createTestWidget());
    await waitForLoadedState(tester);

    // Scroll down to make tiles visible and built by the ListView
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    // Find the steps tile
    final stepsTile = find.text('Objetivo de pasos');
    expect(stepsTile, findsOneWidget);

    await tester.tap(stepsTile);
    await tester.pumpAndSettle();

    // Verify dialog opened
    expect(find.text('Objetivo de pasos diarios'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Enter a new target steps
    await tester.enterText(find.byType(TextField), '12000');
    await tester.pump();

    // Tap OK
    final acceptButton = find.text('OK');
    expect(acceptButton, findsOneWidget);
    await tester.tap(acceptButton);
    await tester.pumpAndSettle();

    // Verify update was processed and the saved user has the new steps target
    expect(fakeAddUserUsecase.addedUser, isNotNull);
    expect(fakeAddUserUsecase.addedUser!.targetSteps, 12000);
  });

  testWidgets('clicking sleep goal opens dialog, enters value, and saves user', (tester) async {
    final user = _buildUser(heightCM: 180, weightKG: 80, targetSleepHours: 8);
    fakeGetUserUsecase.user = user;
    fakeGetConfigUsecase.config = const ConfigEntity(
      true,
      true,
      true,
      AppThemeEntity.system,
      usesImperialUnits: false,
      dailyFocus: DailyFocusEntity.upperBody,
    );
    fakeGetGymTargetsUsecase.targets = const GymTargetsEntity(
      kcalGoal: 2000,
      carbsGoal: 250,
      fatGoal: 65,
      proteinGoal: 150,
    );

    await tester.pumpWidget(createTestWidget());
    await waitForLoadedState(tester);

    // Scroll down to make tiles visible and built by the ListView
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    final sleepTile = find.text('Horas de dormir objetivo');
    expect(sleepTile, findsOneWidget);

    await tester.tap(sleepTile);
    await tester.pumpAndSettle();

    expect(find.text('Objetivo de horas de sueño'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '7.5');
    await tester.pump();

    final acceptButton = find.text('OK');
    expect(acceptButton, findsOneWidget);
    await tester.tap(acceptButton);
    await tester.pumpAndSettle();

    expect(fakeAddUserUsecase.addedUser, isNotNull);
    expect(fakeAddUserUsecase.addedUser!.targetSleepHours, 7.5);
  });
}

UserEntity _buildUser({
  double heightCM = 180,
  double weightKG = 80,
  int? targetSteps = 8000,
  double? targetSleepHours = 8.0,
}) {
  return UserEntity(
    birthday: DateTime(2000, 1, 1),
    heightCM: heightCM,
    weightKG: weightKG,
    gender: UserGenderEntity.male,
    goal: UserWeightGoalEntity.maintainWeight,
    pal: UserPALEntity.active,
    targetSteps: targetSteps,
    targetSleepHours: targetSleepHours,
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

class _FakeAddUserUsecase implements AddUserUsecase {
  UserEntity? addedUser;

  @override
  Future<void> addUser(UserEntity user) {
    addedUser = user;
    return SynchronousFuture(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddTrackedDayUsecase implements AddTrackedDayUsecase {
  bool hasDay = false;
  double? updatedCalorieGoal;
  double? updatedCarbsGoal;
  double? updatedFatGoal;
  double? updatedProteinGoal;

  @override
  Future<bool> hasTrackedDay(DateTime day) => SynchronousFuture(hasDay);

  @override
  Future<void> updateDayCalorieGoal(DateTime day, double goal) {
    updatedCalorieGoal = goal;
    return SynchronousFuture(null);
  }

  @override
  Future<void> updateDayMacroGoals(
    DateTime day, {
    double? carbsGoal,
    double? fatGoal,
    double? proteinGoal,
  }) {
    updatedCarbsGoal = carbsGoal;
    updatedFatGoal = fatGoal;
    updatedProteinGoal = proteinGoal;
    return SynchronousFuture(null);
  }

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

class _FakeGetKcalGoalUsecase implements GetKcalGoalUsecase {
  double kcalGoal = 2000;

  @override
  Future<double> getKcalGoal({
    UserEntity? userEntity,
    double? totalKcalActivitiesParam,
    double? kcalUserAdjustment,
  }) => SynchronousFuture(kcalGoal);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetMacroGoalUsecase implements GetMacroGoalUsecase {
  double carbsGoal = 250;
  double fatGoal = 65;
  double proteinGoal = 150;

  @override
  Future<double> getCarbsGoal(double kcal) => SynchronousFuture(carbsGoal);

  @override
  Future<double> getFatsGoal(double kcal) => SynchronousFuture(fatGoal);

  @override
  Future<double> getProteinsGoal(double kcal) => SynchronousFuture(proteinGoal);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetGymTargetsUsecase implements GetGymTargetsUsecase {
  GymTargetsEntity targets = const GymTargetsEntity(
    kcalGoal: 2000,
    carbsGoal: 250,
    fatGoal: 65,
    proteinGoal: 150,
  );

  @override
  Future<GymTargetsEntity> getTargetsForDay(
    DateTime day, {
    UserEntity? userEntity,
    UserWeightGoalEntity? phase,
    DailyFocusEntity? dailyFocus,
    double? totalKcalActivities,
  }) => SynchronousFuture(targets);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHomeBloc extends Bloc<HomeEvent, HomeState> implements HomeBloc {
  final List<HomeEvent> addedEvents = [];

  _FakeHomeBloc() : super(HomeInitial());

  @override
  void add(HomeEvent event) {
    addedEvents.add(event);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDiaryBloc extends Bloc<DiaryEvent, DiaryState> implements DiaryBloc {
  final List<DiaryEvent> addedEvents = [];

  _FakeDiaryBloc() : super(DiaryInitial());

  @override
  void add(DiaryEvent event) {
    addedEvents.add(event);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCalendarDayBloc extends Bloc<CalendarDayEvent, CalendarDayState> implements CalendarDayBloc {
  final List<CalendarDayEvent> addedEvents = [];

  _FakeCalendarDayBloc() : super(CalendarDayInitial());

  @override
  void add(CalendarDayEvent event) {
    addedEvents.add(event);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
