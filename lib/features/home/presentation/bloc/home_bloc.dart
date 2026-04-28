import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_user_usecase.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/delete_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/delete_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/domain/usecase/update_intake_usecase.dart';
import 'package:macrotracker/core/utils/calc/calorie_goal_calc.dart';
import 'package:macrotracker/core/utils/calc/gym_target_calc.dart';
import 'package:macrotracker/core/utils/calc/macro_calc.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetConfigUsecase _getConfigUsecase;
  final AddConfigUsecase _addConfigUsecase;
  final GetUserUsecase _getUserUsecase;
  final AddUserUsecase _addUserUsecase;
  final GetIntakeUsecase _getIntakeUsecase;
  final DeleteIntakeUsecase _deleteIntakeUsecase;
  final UpdateIntakeUsecase _updateIntakeUsecase;
  final GetUserActivityUsecase _getUserActivityUsecase;
  final DeleteUserActivityUsecase _deleteUserActivityUsecase;
  final AddTrackedDayUsecase _addTrackedDayUseCase;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;

  DateTime currentDay = DateTime.now();

  HomeBloc(
      this._getConfigUsecase,
      this._addConfigUsecase,
      this._getUserUsecase,
      this._addUserUsecase,
      this._getIntakeUsecase,
      this._deleteIntakeUsecase,
      this._updateIntakeUsecase,
      this._getUserActivityUsecase,
      this._deleteUserActivityUsecase,
      this._addTrackedDayUseCase,
      this._getKcalGoalUsecase,
      this._getMacroGoalUsecase)
      : super(HomeInitial()) {
    on<LoadItemsEvent>((event, emit) async {
      emit(HomeLoadingState());

      currentDay = DateTime.now();
      final configData = await _getConfigUsecase.getConfig();
      final user = await _getUserUsecase.getUserData();
      final usesImperialUnits = configData.usesImperialUnits;
      final showDisclaimerDialog = !configData.hasAcceptedDisclaimer;
      final dailyFocus = configData.dailyFocus;
      final nutritionPhase = user.goal;

      final breakfastIntakeList =
          await _getIntakeUsecase.getTodayBreakfastIntake();
      final totalBreakfastKcal = getTotalKcal(breakfastIntakeList);
      final totalBreakfastCarbs = getTotalCarbs(breakfastIntakeList);
      final totalBreakfastFats = getTotalFats(breakfastIntakeList);
      final totalBreakfastProteins = getTotalProteins(breakfastIntakeList);

      final lunchIntakeList = await _getIntakeUsecase.getTodayLunchIntake();
      final totalLunchKcal = getTotalKcal(lunchIntakeList);
      final totalLunchCarbs = getTotalCarbs(lunchIntakeList);
      final totalLunchFats = getTotalFats(lunchIntakeList);
      final totalLunchProteins = getTotalProteins(lunchIntakeList);

      final dinnerIntakeList = await _getIntakeUsecase.getTodayDinnerIntake();
      final totalDinnerKcal = getTotalKcal(dinnerIntakeList);
      final totalDinnerCarbs = getTotalCarbs(dinnerIntakeList);
      final totalDinnerFats = getTotalFats(dinnerIntakeList);
      final totalDinnerProteins = getTotalProteins(dinnerIntakeList);

      final snackIntakeList = await _getIntakeUsecase.getTodaySnackIntake();
      final totalSnackKcal = getTotalKcal(snackIntakeList);
      final totalSnackCarbs = getTotalCarbs(snackIntakeList);
      final totalSnackFats = getTotalFats(snackIntakeList);
      final totalSnackProteins = getTotalProteins(snackIntakeList);

      final totalKcalIntake = totalBreakfastKcal +
          totalLunchKcal +
          totalDinnerKcal +
          totalSnackKcal;
      final totalCarbsIntake = totalBreakfastCarbs +
          totalLunchCarbs +
          totalDinnerCarbs +
          totalSnackCarbs;
      final totalFatsIntake = totalBreakfastFats +
          totalLunchFats +
          totalDinnerFats +
          totalSnackFats;
      final totalProteinsIntake = totalBreakfastProteins +
          totalLunchProteins +
          totalDinnerProteins +
          totalSnackProteins;

      final userActivities =
          await _getUserActivityUsecase.getTodayUserActivity();
      final totalKcalActivities =
          userActivities.map((activity) => activity.burnedKcal).toList().sum;

      final baseKcalGoal = await _getKcalGoalUsecase.getKcalGoal(
        userEntity: user,
        totalKcalActivitiesParam: totalKcalActivities,
      );
      final baseCarbsGoal =
          await _getMacroGoalUsecase.getCarbsGoal(baseKcalGoal);
      final baseFatsGoal = await _getMacroGoalUsecase.getFatsGoal(baseKcalGoal);
      final baseProteinsGoal =
          await _getMacroGoalUsecase.getProteinsGoal(baseKcalGoal);

      final targets = GymTargetCalc.buildTargets(
        phase: nutritionPhase,
        dailyFocus: dailyFocus,
        baseKcalGoal: baseKcalGoal,
        baseCarbsGoal: baseCarbsGoal,
        baseFatGoal: baseFatsGoal,
        baseProteinGoal: baseProteinsGoal,
        userWeightKg: user.weightKG,
        userHeightCm: user.heightCM,
      );

      final totalKcalLeft =
          CalorieGoalCalc.getDailyKcalLeft(targets.kcalGoal, totalKcalIntake);

      emit(HomeLoadedState(
          showDisclaimerDialog: showDisclaimerDialog,
          nutritionPhase: nutritionPhase,
          dailyFocus: dailyFocus,
          totalKcalDaily: targets.kcalGoal,
          totalKcalLeft: totalKcalLeft,
          totalKcalSupplied: totalKcalIntake,
          totalKcalBurned: totalKcalActivities,
          totalCarbsIntake: totalCarbsIntake,
          totalFatsIntake: totalFatsIntake,
          totalCarbsGoal: targets.carbsGoal,
          totalFatsGoal: targets.fatGoal,
          totalProteinsGoal: targets.proteinGoal,
          totalProteinsIntake: totalProteinsIntake,
          breakfastIntakeList: breakfastIntakeList,
          lunchIntakeList: lunchIntakeList,
          dinnerIntakeList: dinnerIntakeList,
          snackIntakeList: snackIntakeList,
          userActivityList: userActivities,
          usesImperialUnits: usesImperialUnits));
    });
  }

  Future<void> setDailyFocus(DailyFocusEntity dailyFocus) async {
    await _addConfigUsecase.setConfigDailyFocus(dailyFocus);
    await _syncTodayTrackedDay(dailyFocus: dailyFocus);
    add(const LoadItemsEvent());
  }

  Future<void> setNutritionPhase(UserWeightGoalEntity nutritionPhase) async {
    final user = await _getUserUsecase.getUserData();
    user.goal = nutritionPhase;
    await _addUserUsecase.addUser(user);
    await _syncTodayTrackedDay(phase: nutritionPhase, user: user);
    add(const LoadItemsEvent());
  }

  double getTotalKcal(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalKcal).toList().sum;

  double getTotalCarbs(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalCarbsGram).toList().sum;

  double getTotalFats(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalFatsGram).toList().sum;

  double getTotalProteins(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalProteinsGram).toList().sum;

  void saveConfigData(bool acceptedDisclaimer) async {
    _addConfigUsecase.setConfigDisclaimer(acceptedDisclaimer);
  }

  Future<void> updateIntakeItem(
      String intakeId, Map<String, dynamic> fields) async {
    final dateTime = DateTime.now();
    // Get old intake values
    final oldIntakeObject = await _getIntakeUsecase.getIntakeById(intakeId);
    assert(oldIntakeObject != null);
    final newIntakeObject =
        await _updateIntakeUsecase.updateIntake(intakeId, fields);
    assert(newIntakeObject != null);
    if (oldIntakeObject!.amount > newIntakeObject!.amount) {
      // Amounts shrunk
      await _addTrackedDayUseCase.removeDayCaloriesTracked(
          dateTime, oldIntakeObject.totalKcal - newIntakeObject.totalKcal);
      await _addTrackedDayUseCase.removeDayMacrosTracked(dateTime,
          carbsTracked:
              oldIntakeObject.totalCarbsGram - newIntakeObject.totalCarbsGram,
          fatTracked:
              oldIntakeObject.totalFatsGram - newIntakeObject.totalFatsGram,
          proteinTracked: oldIntakeObject.totalProteinsGram -
              newIntakeObject.totalProteinsGram);
    } else if (newIntakeObject.amount > oldIntakeObject.amount) {
      // Amounts gained
      await _addTrackedDayUseCase.addDayCaloriesTracked(
          dateTime, newIntakeObject.totalKcal - oldIntakeObject.totalKcal);
      await _addTrackedDayUseCase.addDayMacrosTracked(dateTime,
          carbsTracked:
              newIntakeObject.totalCarbsGram - oldIntakeObject.totalCarbsGram,
          fatTracked:
              newIntakeObject.totalFatsGram - oldIntakeObject.totalFatsGram,
          proteinTracked: newIntakeObject.totalProteinsGram -
              oldIntakeObject.totalProteinsGram);
    }
    _updateDiaryPage(dateTime);
  }

  Future<void> deleteIntakeItem(IntakeEntity intakeEntity) async {
    final dateTime = DateTime.now();
    await _deleteIntakeUsecase.deleteIntake(intakeEntity);
    await _addTrackedDayUseCase.removeDayCaloriesTracked(
        dateTime, intakeEntity.totalKcal);
    await _addTrackedDayUseCase.removeDayMacrosTracked(dateTime,
        carbsTracked: intakeEntity.totalCarbsGram,
        fatTracked: intakeEntity.totalFatsGram,
        proteinTracked: intakeEntity.totalProteinsGram);

    _updateDiaryPage(dateTime);
  }

  Future<void> deleteUserActivityItem(UserActivityEntity activityEntity) async {
    final dateTime = DateTime.now();
    await _deleteUserActivityUsecase.deleteUserActivity(activityEntity);
    _addTrackedDayUseCase.reduceDayCalorieGoal(
        dateTime, activityEntity.burnedKcal);

    final carbsAmount = MacroCalc.getTotalCarbsGoal(activityEntity.burnedKcal);
    final fatAmount = MacroCalc.getTotalFatsGoal(activityEntity.burnedKcal);
    final proteinAmount =
        MacroCalc.getTotalProteinsGoal(activityEntity.burnedKcal);

    _addTrackedDayUseCase.reduceDayMacroGoals(dateTime,
        carbsAmount: carbsAmount,
        fatAmount: fatAmount,
        proteinAmount: proteinAmount);
    _updateDiaryPage(dateTime);
  }

  Future<void> _updateDiaryPage(DateTime day) async {
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
  }

  Future<void> _syncTodayTrackedDay({
    UserWeightGoalEntity? phase,
    DailyFocusEntity? dailyFocus,
    UserEntity? user,
  }) async {
    final day = DateTime.now();
    final hasTrackedDay = await _addTrackedDayUseCase.hasTrackedDay(day);
    if (!hasTrackedDay) {
      return;
    }

    final config = await _getConfigUsecase.getConfig();
    final currentUser = user ?? await _getUserUsecase.getUserData();
    final userActivities =
        await _getUserActivityUsecase.getUserActivityByDay(day);
    final totalKcalActivities =
        userActivities.map((activity) => activity.burnedKcal).toList().sum;

    final baseKcalGoal = await _getKcalGoalUsecase.getKcalGoal(
      userEntity: currentUser,
      totalKcalActivitiesParam: totalKcalActivities,
    );
    final baseCarbsGoal = await _getMacroGoalUsecase.getCarbsGoal(baseKcalGoal);
    final baseFatGoal = await _getMacroGoalUsecase.getFatsGoal(baseKcalGoal);
    final baseProteinGoal =
        await _getMacroGoalUsecase.getProteinsGoal(baseKcalGoal);

    final targets = GymTargetCalc.buildTargets(
      phase: phase ?? currentUser.goal,
      dailyFocus: dailyFocus ?? config.dailyFocus,
      baseKcalGoal: baseKcalGoal,
      baseCarbsGoal: baseCarbsGoal,
      baseFatGoal: baseFatGoal,
      baseProteinGoal: baseProteinGoal,
      userWeightKg: currentUser.weightKG,
      userHeightCm: currentUser.heightCM,
    );

    await _addTrackedDayUseCase.updateDayCalorieGoal(day, targets.kcalGoal);
    await _addTrackedDayUseCase.updateDayMacroGoals(
      day,
      carbsGoal: targets.carbsGoal,
      fatGoal: targets.fatGoal,
      proteinGoal: targets.proteinGoal,
    );
    await _updateDiaryPage(day);
  }
}
