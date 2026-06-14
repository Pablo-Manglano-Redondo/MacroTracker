import 'package:collection/collection.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/utils/calc/gym_target_calc.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/usecase/get_professional_plan_usecase.dart';

class SyncHomeTrackedDayUsecase {
  final AddTrackedDayUsecase _addTrackedDayUsecase;
  final GetConfigUsecase _getConfigUsecase;
  final GetUserUsecase _getUserUsecase;
  final GetUserActivityUsecase _getUserActivityUsecase;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;
  final GetProfessionalPlanUsecase _getProfessionalPlanUsecase;

  SyncHomeTrackedDayUsecase(
    this._addTrackedDayUsecase,
    this._getConfigUsecase,
    this._getUserUsecase,
    this._getUserActivityUsecase,
    this._getKcalGoalUsecase,
    this._getMacroGoalUsecase,
    this._getProfessionalPlanUsecase,
  );

  Future<bool> execute({
    required DateTime day,
    UserWeightGoalEntity? phase,
    DailyFocusEntity? dailyFocus,
    UserEntity? user,
    ProfessionalConnectionEntity? professionalConnection,
  }) async {
    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(day);
    if (!hasTrackedDay) {
      return false;
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

    final appTargets = GymTargetCalc.buildTargets(
      phase: phase ?? currentUser.goal,
      dailyFocus: dailyFocus ?? config.dailyFocus,
      macroGoalMode: config.macroGoalMode,
      baseKcalGoal: baseKcalGoal,
      baseCarbsGoal: baseCarbsGoal,
      baseFatGoal: baseFatGoal,
      baseProteinGoal: baseProteinGoal,
      userWeightKg: currentUser.weightKG,
      userHeightCm: currentUser.heightCM,
    );

    final activeConnection = professionalConnection ??
        await _getProfessionalPlanUsecase.getActiveConnection();
    final targets = _resolveTargetsForDay(
      date: day,
      appTargets: appTargets,
      connection: activeConnection,
    );

    await _addTrackedDayUsecase.updateDayCalorieGoal(day, targets.kcalGoal);
    await _addTrackedDayUsecase.updateDayMacroGoals(
      day,
      carbsGoal: targets.carbsGoal,
      fatGoal: targets.fatGoal,
      proteinGoal: targets.proteinGoal,
    );

    return true;
  }

  GymTargetsEntity _resolveTargetsForDay({
    required DateTime date,
    required GymTargetsEntity appTargets,
    required ProfessionalConnectionEntity? connection,
  }) {
    final dayTarget = connection?.activePlan?.targetForDate(date);
    if (dayTarget == null || dayTarget.kcalGoal <= 0) {
      return appTargets;
    }

    return GymTargetsEntity(
      kcalGoal: dayTarget.kcalGoal,
      carbsGoal: dayTarget.carbsGoal,
      fatGoal: dayTarget.fatGoal,
      proteinGoal: dayTarget.proteinGoal,
    );
  }
}
