import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/food_quality_score_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_user_usecase.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/delete_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/delete_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/domain/usecase/update_intake_usecase.dart';
import 'package:macrotracker/core/utils/calc/calorie_goal_calc.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/domain/usecase/load_home_dashboard_usecase.dart';
import 'package:macrotracker/features/home/domain/usecase/sync_home_tracked_day_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AddConfigUsecase _addConfigUsecase;
  final GetUserUsecase _getUserUsecase;
  final AddUserUsecase _addUserUsecase;
  final GetIntakeUsecase _getIntakeUsecase;
  final DeleteIntakeUsecase _deleteIntakeUsecase;
  final UpdateIntakeUsecase _updateIntakeUsecase;
  final DeleteUserActivityUsecase _deleteUserActivityUsecase;
  final AddTrackedDayUsecase _addTrackedDayUseCase;
  final LoadHomeDashboardUsecase _loadHomeDashboardUsecase;
  final SyncHomeTrackedDayUsecase _syncHomeTrackedDayUsecase;

  DateTime currentDay = DateTime.now();

  HomeBloc(
      this._addConfigUsecase,
      this._getUserUsecase,
      this._addUserUsecase,
      this._getIntakeUsecase,
      this._deleteIntakeUsecase,
      this._updateIntakeUsecase,
      this._deleteUserActivityUsecase,
      this._addTrackedDayUseCase,
      this._loadHomeDashboardUsecase,
      this._syncHomeTrackedDayUsecase)
      : super(HomeInitial()) {
    on<LoadItemsEvent>((event, emit) async {
      final shouldShowBlockingLoader = state is! HomeLoadedState;
      if (shouldShowBlockingLoader) {
        emit(HomeLoadingState());
      }

      currentDay = DateTime.now();
      final dashboardData = await _loadHomeDashboardUsecase.execute(
        day: currentDay,
        refreshRemotePlan: event.refreshRemotePlan,
        uploadProfessionalSnapshot: event.uploadProfessionalSnapshot,
      );

      final totalKcalLeft =
          CalorieGoalCalc.getDailyKcalLeft(dashboardData.targets.kcalGoal, dashboardData.totalKcalIntake);

      emit(HomeLoadedState(
          showDisclaimerDialog: !dashboardData.config.hasAcceptedDisclaimer,
          nutritionPhase: dashboardData.user.goal,
          dailyFocus: dashboardData.config.dailyFocus,
          totalKcalDaily: dashboardData.targets.kcalGoal,
          totalKcalLeft: totalKcalLeft,
          totalKcalSupplied: dashboardData.totalKcalIntake,
          totalKcalBurned: dashboardData.totalKcalActivities,
          totalCarbsIntake: dashboardData.totalCarbsIntake,
          totalFatsIntake: dashboardData.totalFatsIntake,
          totalCarbsGoal: dashboardData.targets.carbsGoal,
          totalFatsGoal: dashboardData.targets.fatGoal,
          totalProteinsGoal: dashboardData.targets.proteinGoal,
          totalProteinsIntake: dashboardData.totalProteinsIntake,
          dailyFoodQualityScore: dashboardData.foodQualitySummary.score,
          dailyFoodQualityBand: dashboardData.foodQualitySummary.band,
          dailyFoodQualityMealsCount: dashboardData.foodQualitySummary.mealsCount,
          breakfastIntakeList: dashboardData.breakfastIntakeList,
          lunchIntakeList: dashboardData.lunchIntakeList,
          dinnerIntakeList: dashboardData.dinnerIntakeList,
          snackIntakeList: dashboardData.snackIntakeList,
          userActivityList: dashboardData.userActivities,
          usesImperialUnits: dashboardData.config.usesImperialUnits,
          targetSteps: dashboardData.user.targetSteps,
          targetSleepHours: dashboardData.user.targetSleepHours,
          targetWaterLiters: dashboardData.user.targetWaterLiters,
          activeConnection: dashboardData.professionalConnection));
    });
  }

  Future<void> setDailyFocus(DailyFocusEntity dailyFocus) async {
    final day = DateTime.now();
    await _addConfigUsecase.setConfigDailyFocus(dailyFocus);
    final didSync = await _syncHomeTrackedDayUsecase.execute(
      day: day,
      dailyFocus: dailyFocus,
    );
    if (didSync) {
      await _updateDiaryPage();
    }
    add(const LoadItemsEvent());
  }

  Future<void> setNutritionPhase(UserWeightGoalEntity nutritionPhase) async {
    final day = DateTime.now();
    final user = await _getUserUsecase.getUserData();
    user.goal = nutritionPhase;
    await _addUserUsecase.addUser(user);
    final didSync = await _syncHomeTrackedDayUsecase.execute(
      day: day,
      phase: nutritionPhase,
      user: user,
    );
    if (didSync) {
      await _updateDiaryPage();
    }
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
    await _updateDiaryPage();
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

    await _updateDiaryPage();
  }

  Future<void> deleteUserActivityItem(UserActivityEntity activityEntity) async {
    final dateTime = DateTime.now();
    await _deleteUserActivityUsecase.deleteUserActivity(activityEntity);
    final didSync = await _syncHomeTrackedDayUsecase.execute(day: dateTime);
    if (didSync) {
      await _updateDiaryPage();
      return;
    }
    await _updateDiaryPage();
  }

  Future<void> _updateDiaryPage() async {
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
  }
}
