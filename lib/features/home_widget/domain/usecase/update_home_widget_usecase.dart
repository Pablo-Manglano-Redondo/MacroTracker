import 'dart:io';

import 'package:home_widget/home_widget.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/get_daily_habit_log_usecase.dart';

class UpdateHomeWidgetUsecase {
  static const androidWidgetProviderName = 'MacroTrackerSummaryWidgetProvider';

  static const _kcalRemainingKey = 'widget_kcal_remaining';
  static const _carbsProgressKey = 'widget_carbs_progress';
  static const _fatProgressKey = 'widget_fat_progress';
  static const _proteinProgressKey = 'widget_protein_progress';
  static const _waterProgressKey = 'widget_water_progress';

  final _log = Logger('UpdateHomeWidgetUsecase');

  final GetTrackedDayUsecase _getTrackedDayUsecase;
  final GetDailyHabitLogUsecase _getDailyHabitLogUsecase;
  final GetGymTargetsUsecase _getGymTargetsUsecase;
  final GetConfigUsecase _getConfigUsecase;

  UpdateHomeWidgetUsecase(
    this._getTrackedDayUsecase,
    this._getDailyHabitLogUsecase,
    this._getGymTargetsUsecase,
    this._getConfigUsecase,
  );

  Future<void> refreshToday() async {
    if (!Platform.isAndroid) {
      return;
    }

    final today = _normalizeDay(DateTime.now());

    try {
      final config = await _getConfigUsecase.getConfig();
      final trackedDay = await _getTrackedDayUsecase.getTrackedDay(today);
      final needsFallbackTargets = trackedDay == null ||
          trackedDay.carbsGoal == null ||
          trackedDay.fatGoal == null ||
          trackedDay.proteinGoal == null;
      final targets = needsFallbackTargets
          ? await _getGymTargetsUsecase.getTargetsForDay(today)
          : null;
      final habitLog = await _getDailyHabitLogUsecase.getForDay(today);

      final kcalGoal = trackedDay?.calorieGoal ?? targets!.kcalGoal;
      final kcalTracked = trackedDay?.caloriesTracked ?? 0;
      final carbsGoal = trackedDay?.carbsGoal ?? targets!.carbsGoal;
      final carbsTracked = trackedDay?.carbsTracked ?? 0;
      final fatGoal = trackedDay?.fatGoal ?? targets!.fatGoal;
      final fatTracked = trackedDay?.fatTracked ?? 0;
      final proteinGoal = trackedDay?.proteinGoal ?? targets!.proteinGoal;
      final proteinTracked = trackedDay?.proteinTracked ?? 0;
      final hydrationGoal = _hydrationGoalForFocus(config.dailyFocus);

      await HomeWidget.saveWidgetData<String>(
        _kcalRemainingKey,
        _formatKcalRemaining(kcalGoal - kcalTracked),
      );
      await HomeWidget.saveWidgetData<String>(
        _carbsProgressKey,
        _formatMacroProgress(carbsTracked, carbsGoal),
      );
      await HomeWidget.saveWidgetData<String>(
        _fatProgressKey,
        _formatMacroProgress(fatTracked, fatGoal),
      );
      await HomeWidget.saveWidgetData<String>(
        _proteinProgressKey,
        _formatMacroProgress(proteinTracked, proteinGoal),
      );
      await HomeWidget.saveWidgetData<String>(
        _waterProgressKey,
        _formatWaterProgress(
          habitLog: habitLog,
          hydrationGoal: hydrationGoal,
          usesImperialUnits: config.usesImperialUnits,
        ),
      );

      await HomeWidget.updateWidget(androidName: androidWidgetProviderName);
    } catch (error, stackTrace) {
      _log.warning('Failed to refresh Android home widget', error, stackTrace);
    }
  }

  DateTime _normalizeDay(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  String _formatKcalRemaining(double value) {
    return value.round().toString();
  }

  String _formatMacroProgress(double? tracked, double? goal) {
    final trackedValue = (tracked ?? 0).round();
    final goalValue = (goal ?? 0).round();
    return '$trackedValue/$goalValue';
  }

  String _formatWaterProgress({
    required DailyHabitLogEntity habitLog,
    required double hydrationGoal,
    required bool usesImperialUnits,
  }) {
    if (usesImperialUnits) {
      final trackedFlOz = UnitCalc.mlToFlOz(habitLog.waterLiters * 1000).round();
      final goalFlOz = UnitCalc.mlToFlOz(hydrationGoal * 1000).round();
      return '$trackedFlOz/$goalFlOz oz';
    }

    return '${habitLog.waterLiters.toStringAsFixed(1)}/${hydrationGoal.toStringAsFixed(1)}L';
  }

  double _hydrationGoalForFocus(DailyFocusEntity focus) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return 3.8;
      case DailyFocusEntity.upperBody:
        return 3.5;
      case DailyFocusEntity.cardio:
        return 3.75;
      case DailyFocusEntity.rest:
        return 2.75;
    }
  }
}
