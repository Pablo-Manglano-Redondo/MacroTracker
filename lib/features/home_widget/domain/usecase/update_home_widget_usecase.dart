import 'dart:io';

import 'package:home_widget/home_widget.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/get_daily_habit_log_usecase.dart';

class UpdateHomeWidgetUsecase {
  static const androidWidgetProviderName = 'MacroTrackerSummaryWidgetProvider';
  static const quickActionsWidgetProviderName = 'MacroTrackerQuickActionsWidgetProvider';
  static const circularProgressWidgetProviderName = 'MacroTrackerCircularProgressWidgetProvider';
  static const habitsWidgetProviderName = 'MacroTrackerHabitsWidgetProvider';

  static const _kcalRemainingKey = 'widget_kcal_remaining';
  static const _carbsProgressKey = 'widget_carbs_progress';
  static const _fatProgressKey = 'widget_fat_progress';
  static const _proteinProgressKey = 'widget_protein_progress';
  static const _waterProgressKey = 'widget_water_progress';

  // New keys for circular calorie and habits widgets
  static const _kcalGoalKey = 'widget_kcal_goal';
  static const _kcalConsumedKey = 'widget_kcal_consumed';
  static const _stepsProgressKey = 'widget_steps_progress';
  static const _sleepProgressKey = 'widget_sleep_progress';
  static const _focusLabelKey = 'widget_focus_label';

  final _log = Logger('UpdateHomeWidgetUsecase');

  final GetTrackedDayUsecase _getTrackedDayUsecase;
  final GetDailyHabitLogUsecase _getDailyHabitLogUsecase;
  final GetGymTargetsUsecase _getGymTargetsUsecase;
  final GetConfigUsecase _getConfigUsecase;
  final GetUserUsecase _getUserUsecase;

  UpdateHomeWidgetUsecase(
    this._getTrackedDayUsecase,
    this._getDailyHabitLogUsecase,
    this._getGymTargetsUsecase,
    this._getConfigUsecase,
    this._getUserUsecase,
  );

  Future<void> refreshToday() async {
    if (!Platform.isAndroid) {
      return;
    }

    final today = _normalizeDay(DateTime.now());

    try {
      final config = await _getConfigUsecase.getConfig();
      final user = await _getUserUsecase.getUserData();
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
      final hydrationGoal = user.targetWaterLiters ?? _hydrationGoalForFocus(config.dailyFocus);

      // Steps goal and Sleep goal
      final stepsGoal = user.targetSteps ?? _stepGoalForFocus(config.dailyFocus);
      final sleepGoal = user.targetSleepHours ?? 8.0;

      // Base widget values
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

      // Circular calorie progress widget values
      await HomeWidget.saveWidgetData<String>(
        _kcalGoalKey,
        kcalGoal.round().toString(),
      );
      await HomeWidget.saveWidgetData<String>(
        _kcalConsumedKey,
        kcalTracked.round().toString(),
      );

      // Habits & Recovery widget values
      await HomeWidget.saveWidgetData<String>(
        _stepsProgressKey,
        '${habitLog.steps} / $stepsGoal',
      );
      await HomeWidget.saveWidgetData<String>(
        _sleepProgressKey,
        '${habitLog.sleepHours.toStringAsFixed(1)} / ${sleepGoal.toStringAsFixed(1)}h',
      );
      
      final isEs = Platform.localeName.startsWith('es');
      await HomeWidget.saveWidgetData<String>(
        _focusLabelKey,
        _formatFocusLabel(config.dailyFocus, isEs),
      );

      // Trigger updates for all 4 registered widgets
      await HomeWidget.updateWidget(
        androidName: androidWidgetProviderName,
      );
      await HomeWidget.updateWidget(
        androidName: quickActionsWidgetProviderName,
      );
      await HomeWidget.updateWidget(
        androidName: circularProgressWidgetProviderName,
      );
      await HomeWidget.updateWidget(
        androidName: habitsWidgetProviderName,
      );
    } catch (error, stackTrace) {
      _log.warning('Failed to refresh home widget', error, stackTrace);
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
      final trackedFlOz =
          UnitCalc.mlToFlOz(habitLog.waterLiters * 1000).round();
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

  int _stepGoalForFocus(DailyFocusEntity focus) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
      case DailyFocusEntity.upperBody:
        return 10000;
      case DailyFocusEntity.cardio:
        return 12000;
      case DailyFocusEntity.rest:
        return 8000;
    }
  }

  String _formatFocusLabel(DailyFocusEntity focus, bool isEs) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return isEs ? 'Pierna' : 'Lower Body';
      case DailyFocusEntity.upperBody:
        return isEs ? 'Torso' : 'Upper Body';
      case DailyFocusEntity.cardio:
        return isEs ? 'Cardio' : 'Cardio';
      case DailyFocusEntity.rest:
        return isEs ? 'Descanso' : 'Rest';
    }
  }
}
