import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/domain/entity/user_bmi_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_user_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/utils/calc/bmi_calc.dart';
import 'package:macrotracker/core/utils/calc/gym_target_calc.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserUsecase _getUserUsecase;
  final AddUserUsecase _addUserUsecase;
  final AddTrackedDayUsecase _addTrackedDayUsecase;
  final GetConfigUsecase _getConfigUsecase;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;

  ProfileBloc(
      this._getUserUsecase,
      this._addUserUsecase,
      this._addTrackedDayUsecase,
      this._getConfigUsecase,
      this._getKcalGoalUsecase,
      this._getMacroGoalUsecase)
      : super(ProfileInitial()) {
    on<LoadProfileEvent>((event, emit) async {
      emit(ProfileLoadingState());

      final user = await _getUserUsecase.getUserData();
      final userBMIValue = BMICalc.getBMI(user);
      final userBMIEntity = UserBMIEntity(
          bmiValue: userBMIValue,
          nutritionalStatus: BMICalc.getNutritionalStatus(userBMIValue));
      final userConfig = await _getConfigUsecase.getConfig();

      emit(ProfileLoadedState(
          userBMI: userBMIEntity,
          userEntity: user,
          usesImperialUnits: userConfig.usesImperialUnits));
    });
  }

  void updateUser(UserEntity userEntity) async {
    // Update user in DB
    await _addUserUsecase.addUser(userEntity);

    // Update Tracked Day
    await _updateTrackedDayCalorieGoal(userEntity, DateTime.now());

    // Refresh Profile
    add(LoadProfileEvent());
    // Refresh Home Page
    locator<HomeBloc>().add(const LoadItemsEvent());
    // Refresh Diary Page
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
  }

  Future<void> _updateTrackedDayCalorieGoal(
      UserEntity user, DateTime day) async {
    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(day);
    if (hasTrackedDay) {
      final config = await _getConfigUsecase.getConfig();
      final baseKcalGoal =
          await _getKcalGoalUsecase.getKcalGoal(userEntity: user);
      final baseCarbsGoal =
          await _getMacroGoalUsecase.getCarbsGoal(baseKcalGoal);
      final baseFatGoal = await _getMacroGoalUsecase.getFatsGoal(baseKcalGoal);
      final baseProteinGoal =
          await _getMacroGoalUsecase.getProteinsGoal(baseKcalGoal);
      final targets = GymTargetCalc.buildTargets(
        phase: user.goal,
        dailyFocus: config.dailyFocus,
        baseKcalGoal: baseKcalGoal,
        baseCarbsGoal: baseCarbsGoal,
        baseFatGoal: baseFatGoal,
        baseProteinGoal: baseProteinGoal,
        userWeightKg: user.weightKG,
        userHeightCm: user.heightCM,
      );

      await _addTrackedDayUsecase.updateDayCalorieGoal(day, targets.kcalGoal);
      await _addTrackedDayUsecase.updateDayMacroGoals(
        day,
        carbsGoal: targets.carbsGoal,
        fatGoal: targets.fatGoal,
        proteinGoal: targets.proteinGoal,
      );
    }
  }

  /// Returns the user's height in cm or ft/in based on the user's config
  String getDisplayHeight(UserEntity user, bool usesImperialUnits) {
    if (usesImperialUnits) {
      // Convert cm to feet and inches
      return UnitCalc.cmToFeet(user.heightCM).toStringAsFixed(1);
    } else {
      return user.heightCM.roundToDouble().toStringAsFixed(0);
    }
  }

  /// Returns the user's weight in kg or lbs based on the user's config
  String getDisplayWeight(UserEntity user, bool usesImperialUnits) {
    if (usesImperialUnits) {
      return UnitCalc.kgToLbs(user.weightKG).toStringAsFixed(0);
    } else {
      return user.weightKG.roundToDouble().toStringAsFixed(0);
    }
  }
}
