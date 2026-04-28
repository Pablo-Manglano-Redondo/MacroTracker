import 'package:collection/collection.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/utils/calc/gym_target_calc.dart';

class GetGymTargetsUsecase {
  final GetConfigUsecase _getConfigUsecase;
  final GetUserUsecase _getUserUsecase;
  final GetUserActivityUsecase _getUserActivityUsecase;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;

  GetGymTargetsUsecase(
    this._getConfigUsecase,
    this._getUserUsecase,
    this._getUserActivityUsecase,
    this._getKcalGoalUsecase,
    this._getMacroGoalUsecase,
  );

  Future<GymTargetsEntity> getTargetsForDay(
    DateTime day, {
    UserEntity? userEntity,
    UserWeightGoalEntity? phase,
    DailyFocusEntity? dailyFocus,
    double? totalKcalActivities,
  }) async {
    final config = await _getConfigUsecase.getConfig();
    final user = userEntity ?? await _getUserUsecase.getUserData();
    final activityKcal = totalKcalActivities ??
        (await _getUserActivityUsecase.getUserActivityByDay(day))
            .map((activity) => activity.burnedKcal)
            .toList()
            .sum;

    final baseKcalGoal = await _getKcalGoalUsecase.getKcalGoal(
      userEntity: user,
      totalKcalActivitiesParam: activityKcal,
    );
    final baseCarbsGoal = await _getMacroGoalUsecase.getCarbsGoal(baseKcalGoal);
    final baseFatGoal = await _getMacroGoalUsecase.getFatsGoal(baseKcalGoal);
    final baseProteinGoal =
        await _getMacroGoalUsecase.getProteinsGoal(baseKcalGoal);

    return GymTargetCalc.buildTargets(
      phase: phase ?? user.goal,
      dailyFocus: dailyFocus ?? config.dailyFocus,
      baseKcalGoal: baseKcalGoal,
      baseCarbsGoal: baseCarbsGoal,
      baseFatGoal: baseFatGoal,
      baseProteinGoal: baseProteinGoal,
      userWeightKg: user.weightKG,
      userHeightCm: user.heightCM,
      trainingTemplate: config.trainingDayTemplate,
    );
  }
}
