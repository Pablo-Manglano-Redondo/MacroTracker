import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/user_bmi_entity.dart';
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

  test('initial state is ProfileInitial', () {
    expect(bloc.state, isA<ProfileInitial>());
  });

  group('LoadProfileEvent', () {
    test('emits ProfileLoadingState and ProfileLoadedState with BMI & config info', () async {
      final user = _buildUser(heightCM: 180, weightKG: 80);
      fakeGetUserUsecase.user = user;

      fakeGetConfigUsecase.config = const ConfigEntity(
        true,
        true,
        true,
        AppThemeEntity.system,
        usesImperialUnits: true,
        dailyFocus: DailyFocusEntity.upperBody,
      );

      final targets = const GymTargetsEntity(
        kcalGoal: 2000,
        carbsGoal: 250,
        fatGoal: 65,
        proteinGoal: 150,
      );
      fakeGetGymTargetsUsecase.targets = targets;

      final states = <ProfileState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadProfileEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<ProfileLoadingState>(),
        isA<ProfileLoadedState>(),
      ]);

      final loadedState = states.last as ProfileLoadedState;
      expect(loadedState.userEntity, user);
      expect(loadedState.usesImperialUnits, true);
      expect(loadedState.dailyFocus, DailyFocusEntity.upperBody);
      expect(loadedState.currentTargets, targets);
      expect(loadedState.userBMI.bmiValue, closeTo(24.69, 0.01));
      expect(loadedState.userBMI.nutritionalStatus, UserNutritionalStatus.normalWeight);
    });
  });

  group('updateUser', () {
    test('adds user, triggers reloads and syncs day goals if hasTrackedDay is true', () async {
      final user = _buildUser(heightCM: 180, weightKG: 80, goal: UserWeightGoalEntity.gainWeight);
      fakeAddTrackedDayUsecase.hasDay = true;
      fakeGetConfigUsecase.config = const ConfigEntity(
        true,
        true,
        true,
        AppThemeEntity.system,
        usesImperialUnits: false,
        dailyFocus: DailyFocusEntity.lowerBody,
      );
      fakeGetKcalGoalUsecase.kcalGoal = 2500;
      fakeGetMacroGoalUsecase.carbsGoal = 300;
      fakeGetMacroGoalUsecase.fatGoal = 70;
      fakeGetMacroGoalUsecase.proteinGoal = 160;

      final states = <ProfileState>[];
      bloc.stream.listen(states.add);

      bloc.updateUser(user);
      await Future.delayed(const Duration(milliseconds: 10));

      // Check user was added to repo
      expect(fakeAddUserUsecase.addedUser, user);

      // Check day calorie goal was updated (adjusted by GymTargetCalc with DailyFocusEntity.lowerBody scale 1.1)
      expect(fakeAddTrackedDayUsecase.updatedCalorieGoal, 2750.0);
      expect(fakeAddTrackedDayUsecase.updatedCarbsGoal, 330.0);
      expect(fakeAddTrackedDayUsecase.updatedFatGoal, 77.0);
      expect(fakeAddTrackedDayUsecase.updatedProteinGoal, 176.0);

      // Checks that reloads and refresh events were fired on the blocs
      expect(states, [
        isA<ProfileLoadingState>(),
        isA<ProfileLoadedState>(),
      ]);
      expect(fakeHomeBloc.addedEvents, [const LoadItemsEvent()]);
      expect(fakeDiaryBloc.addedEvents, [const LoadDiaryYearEvent()]);
      expect(fakeCalendarDayBloc.addedEvents, [RefreshCalendarDayEvent()]);
    });

    test('adds user and triggers reloads but skips day sync if hasTrackedDay is false', () async {
      final user = _buildUser(heightCM: 180, weightKG: 80);
      fakeAddTrackedDayUsecase.hasDay = false;

      final states = <ProfileState>[];
      bloc.stream.listen(states.add);

      bloc.updateUser(user);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(fakeAddUserUsecase.addedUser, user);
      expect(fakeAddTrackedDayUsecase.updatedCalorieGoal, isNull);

      expect(states, [
        isA<ProfileLoadingState>(),
        isA<ProfileLoadedState>(),
      ]);
      expect(fakeHomeBloc.addedEvents, [const LoadItemsEvent()]);
      expect(fakeDiaryBloc.addedEvents, [const LoadDiaryYearEvent()]);
      expect(fakeCalendarDayBloc.addedEvents, [RefreshCalendarDayEvent()]);
    });
  });

  group('getDisplayHeight', () {
    test('returns metric height in cm when usesImperialUnits is false', () {
      final user = _buildUser(heightCM: 175.4);
      final heightText = bloc.getDisplayHeight(user, false);
      expect(heightText, '175');
    });

    test('returns imperial height in feet when usesImperialUnits is true', () {
      final user = _buildUser(heightCM: 180);
      final heightText = bloc.getDisplayHeight(user, true);
      // 180 cm to inches = 70.866 inches = 5.9 feet
      expect(heightText, '5.9');
    });
  });

  group('getDisplayWeight', () {
    test('returns metric weight in kg when usesImperialUnits is false', () {
      final user = _buildUser(weightKG: 72.8);
      final weightText = bloc.getDisplayWeight(user, false);
      expect(weightText, '73');
    });

    test('returns imperial weight in lbs when usesImperialUnits is true', () {
      final user = _buildUser(weightKG: 80);
      final weightText = bloc.getDisplayWeight(user, true);
      // 80 kg * 2.20462 = 176.37 lbs
      expect(weightText, '176');
    });
  });
}

UserEntity _buildUser({
  double heightCM = 180,
  double weightKG = 80,
  UserWeightGoalEntity goal = UserWeightGoalEntity.maintainWeight,
}) {
  return UserEntity(
    birthday: DateTime(2000, 1, 1),
    heightCM: heightCM,
    weightKG: weightKG,
    gender: UserGenderEntity.male,
    goal: goal,
    pal: UserPALEntity.active,
    targetSteps: 8000,
    targetSleepHours: 8,
    targetWaterLiters: 2.5,
  );
}

class _FakeGetUserUsecase implements GetUserUsecase {
  UserEntity user = _buildUser();

  @override
  Future<UserEntity> getUserData() async => user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddUserUsecase implements AddUserUsecase {
  UserEntity? addedUser;

  @override
  Future<void> addUser(UserEntity user) async {
    addedUser = user;
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
  Future<bool> hasTrackedDay(DateTime day) async => hasDay;

  @override
  Future<void> updateDayCalorieGoal(DateTime day, double goal) async {
    updatedCalorieGoal = goal;
  }

  @override
  Future<void> updateDayMacroGoals(
    DateTime day, {
    double? carbsGoal,
    double? fatGoal,
    double? proteinGoal,
  }) async {
    updatedCarbsGoal = carbsGoal;
    updatedFatGoal = fatGoal;
    updatedProteinGoal = proteinGoal;
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
  Future<ConfigEntity> getConfig() async => config;

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
  }) async => kcalGoal;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetMacroGoalUsecase implements GetMacroGoalUsecase {
  double carbsGoal = 250;
  double fatGoal = 65;
  double proteinGoal = 150;

  @override
  Future<double> getCarbsGoal(double kcal) async => carbsGoal;

  @override
  Future<double> getFatsGoal(double kcal) async => fatGoal;

  @override
  Future<double> getProteinsGoal(double kcal) async => proteinGoal;

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
  }) async => targets;

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
