import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';

class ApplyWeeklyKcalAdjustmentUsecase {
  final GetConfigUsecase _getConfigUsecase;
  final AddConfigUsecase _addConfigUsecase;
  final GetGymTargetsUsecase _getGymTargetsUsecase;
  final AddTrackedDayUsecase _addTrackedDayUsecase;

  ApplyWeeklyKcalAdjustmentUsecase(
    this._getConfigUsecase,
    this._addConfigUsecase,
    this._getGymTargetsUsecase,
    this._addTrackedDayUsecase,
  );

  Future<double> apply({
    required DateTime day,
    required int deltaKcal,
  }) async {
    final config = await _getConfigUsecase.getConfig();
    final currentAdjustment = config.userKcalAdjustment ?? 0;
    final updatedAdjustment = currentAdjustment + deltaKcal;

    await _addConfigUsecase.setConfigKcalAdjustment(updatedAdjustment);

    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(day);
    if (!hasTrackedDay) {
      return updatedAdjustment;
    }

    final targets = await _getGymTargetsUsecase.getTargetsForDay(day);
    await _addTrackedDayUsecase.updateDayCalorieGoal(day, targets.kcalGoal);
    await _addTrackedDayUsecase.updateDayMacroGoals(
      day,
      carbsGoal: targets.carbsGoal,
      fatGoal: targets.fatGoal,
      proteinGoal: targets.proteinGoal,
    );

    return updatedAdjustment;
  }
}
