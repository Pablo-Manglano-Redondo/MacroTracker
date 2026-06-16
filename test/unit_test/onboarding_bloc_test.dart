import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_user_usecase.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/features/onboarding/domain/entity/user_activity_selection_entity.dart';
import 'package:macrotracker/features/onboarding/domain/entity/user_gender_selection_entity.dart';
import 'package:macrotracker/features/onboarding/domain/entity/user_goal_selection_entity.dart';
import 'package:macrotracker/features/onboarding/presentation/bloc/onboarding_bloc.dart';

void main() {
  late OnboardingBloc bloc;
  late _FakeAddUserUsecase fakeAddUserUsecase;
  late _FakeAddConfigUsecase fakeAddConfigUsecase;
  late _FakeAnalyticsService fakeAnalyticsService;

  setUp(() {
    fakeAddUserUsecase = _FakeAddUserUsecase();
    fakeAddConfigUsecase = _FakeAddConfigUsecase();
    fakeAnalyticsService = _FakeAnalyticsService();

    bloc = OnboardingBloc(
      fakeAddUserUsecase,
      fakeAddConfigUsecase,
      fakeAnalyticsService,
    );
  });

  test('initial state is OnboardingInitialState', () {
    expect(bloc.state, isA<OnboardingInitialState>());
  });

  group('LoadOnboardingEvent', () {
    test('emits OnboardingLoadingState and OnboardingLoadedState', () async {
      final states = <OnboardingState>[];
      bloc.stream.listen(states.add);

      bloc.add(LoadOnboardingEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      expect(states, [
        isA<OnboardingLoadingState>(),
        isA<OnboardingLoadedState>(),
      ]);
    });
  });

  group('saveOnboardingData', () {
    test('calls add user, updates config, and sets up analytics', () async {
      final user = UserEntity(
        birthday: DateTime(2000, 1, 1),
        heightCM: 180,
        weightKG: 75,
        gender: UserGenderEntity.male,
        goal: UserWeightGoalEntity.maintainWeight,
        pal: UserPALEntity.active,
      );

      await bloc.saveOnboardingData(user, true, false);

      expect(fakeAddUserUsecase.addedUser, user);
      expect(fakeAddConfigUsecase.acceptedAnonymousData, true);
      expect(fakeAnalyticsService.enabled, true);
      expect(fakeAddConfigUsecase.usesImperialUnits, false);
    });
  });

  group('Macro Estimation Helpers', () {
    test('returns null when userSelection is incomplete', () {
      bloc.userSelection.gender = UserGenderSelectionEntity.genderMale;
      bloc.userSelection.birthday = null; // Incomplete

      expect(bloc.getOverviewCalorieGoal(), isNull);
      expect(bloc.getOverviewCarbsGoal(), isNull);
      expect(bloc.getOverviewFatGoal(), isNull);
      expect(bloc.getOverviewProteinGoal(), isNull);
    });

    test('returns calculated goals when userSelection is fully complete', () {
      bloc.userSelection.gender = UserGenderSelectionEntity.genderMale;
      bloc.userSelection.birthday = DateTime(1995, 6, 15);
      bloc.userSelection.height = 180;
      bloc.userSelection.weight = 80;
      bloc.userSelection.activity = UserActivitySelectionEntity.active;
      bloc.userSelection.goal = UserGoalSelectionEntity.maintainWeight;

      final calorieGoal = bloc.getOverviewCalorieGoal();
      final carbsGoal = bloc.getOverviewCarbsGoal();
      final fatGoal = bloc.getOverviewFatGoal();
      final proteinGoal = bloc.getOverviewProteinGoal();

      expect(calorieGoal, isNotNull);
      expect(carbsGoal, isNotNull);
      expect(fatGoal, isNotNull);
      expect(proteinGoal, isNotNull);

      // Verify that calorie goal is positive and carbs + fat + protein match total calories roughly
      // (1g carb = 4kcal, 1g protein = 4kcal, 1g fat = 9kcal)
      final computedCalories = (carbsGoal! * 4) + (proteinGoal! * 4) + (fatGoal! * 9);
      expect(computedCalories, closeTo(calorieGoal!, 20)); // close to due to rounding
    });
  });
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

class _FakeAddConfigUsecase implements AddConfigUsecase {
  bool? acceptedAnonymousData;
  bool? usesImperialUnits;

  @override
  Future<void> setConfigHasAcceptedAnonymousData(bool value) async {
    acceptedAnonymousData = value;
  }

  @override
  Future<void> setConfigUsesImperialUnits(bool value) async {
    usesImperialUnits = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAnalyticsService implements ConversionAnalyticsService {
  bool? enabled;

  @override
  Future<void> setEnabled(bool value) async {
    enabled = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
