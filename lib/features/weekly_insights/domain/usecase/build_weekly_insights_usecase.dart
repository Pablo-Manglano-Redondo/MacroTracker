import 'package:collection/collection.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_usecase.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/get_body_progress_usecase.dart';
import 'package:macrotracker/features/weekly_insights/domain/entity/weekly_insights_entity.dart';
import 'package:macrotracker/generated/l10n.dart';

class BuildWeeklyInsightsUsecase {
  final GetTrackedDayUsecase _getTrackedDayUsecase;
  final GetIntakeUsecase _getIntakeUsecase;
  final GetBodyProgressUsecase _getBodyProgressUsecase;
  final GetUserUsecase _getUserUsecase;
  final GetConfigUsecase _getConfigUsecase;

  BuildWeeklyInsightsUsecase(
    this._getTrackedDayUsecase,
    this._getIntakeUsecase,
    this._getBodyProgressUsecase,
    this._getUserUsecase,
    this._getConfigUsecase,
  );

  Future<WeeklyInsightsEntity> build(DateTime focusedDate) async {
    final weekStart = _weekStart(focusedDate);
    final weekEnd = weekStart.add(const Duration(days: 6));

    final trackedDays = await _getTrackedDayUsecase.getTrackedDaysByRange(
      weekStart.subtract(const Duration(milliseconds: 1)),
      weekEnd.add(const Duration(days: 1)),
    );
    final allIntakes = await _getIntakeUsecase.getAllIntakes();
    final weekIntakes = allIntakes.where((intake) {
      final date = intake.dateTime;
      return !_isBeforeDay(date, weekStart) && !_isAfterDay(date, weekEnd);
    }).toList();

    final trackedDayCount = trackedDays.length;
    final avgCalories = trackedDayCount == 0
        ? 0.0
        : trackedDays.map((day) => day.caloriesTracked).sum / trackedDayCount;
    final avgCarbs = trackedDayCount == 0
        ? 0.0
        : trackedDays.map((day) => day.carbsTracked ?? 0).sum / trackedDayCount;
    final avgFat = trackedDayCount == 0
        ? 0.0
        : trackedDays.map((day) => day.fatTracked ?? 0).sum / trackedDayCount;
    final avgProtein = trackedDayCount == 0
        ? 0.0
        : trackedDays.map((day) => day.proteinTracked ?? 0).sum /
            trackedDayCount;

    final adherenceCount =
        trackedDays.where(_isWithinDailyGoalTolerance).length;
    final proteinConsistentCount = trackedDays
        .where((day) =>
            (day.proteinTracked ?? 0) >= ((day.proteinGoal ?? 0) * 0.9) &&
            (day.proteinGoal ?? 0) > 0)
        .length;

    final topMeals = _getTopMeals(weekIntakes);
    final overeatingSlot = _getOvereatingSlot(trackedDays, weekIntakes);
    final weeklyWeightDeltaKg = await _computeWeeklyWeightDelta(weekEnd);
    final user = await _getUserUsecase.getUserData();
    final config = await _getConfigUsecase.getConfig();
    final recommendation = _buildKcalAdjustmentRecommendation(
      goal: user.goal,
      adherenceRate:
          trackedDayCount == 0 ? 0 : adherenceCount / trackedDayCount,
      weeklyWeightDeltaKg: weeklyWeightDeltaKg,
    );

    return WeeklyInsightsEntity(
      weekStart: weekStart,
      weekEnd: weekEnd,
      trackedDays: trackedDayCount,
      averageCalories: avgCalories.toDouble(),
      averageCarbs: avgCarbs.toDouble(),
      averageFat: avgFat.toDouble(),
      averageProtein: avgProtein.toDouble(),
      goalAdherenceRate:
          trackedDayCount == 0 ? 0 : adherenceCount / trackedDayCount,
      proteinConsistencyRate:
          trackedDayCount == 0 ? 0 : proteinConsistentCount / trackedDayCount,
      overeatingTimeSlotLabel: overeatingSlot,
      topMeals: topMeals,
      summaryLabel: _buildSummaryLabel(
          adherenceCount, proteinConsistentCount, trackedDayCount),
      weeklyWeightDeltaKg: weeklyWeightDeltaKg,
      recommendedKcalAdjustmentDelta: recommendation.deltaKcal,
      kcalAdjustmentRecommendation:
          '${recommendation.label} ${S.current.weeklyInsightsCurrentAdjustment(config.userKcalAdjustment?.toStringAsFixed(0) ?? '0')}',
    );
  }

  DateTime _weekStart(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  bool _isBeforeDay(DateTime value, DateTime day) {
    final normalized = DateTime(value.year, value.month, value.day);
    return normalized.isBefore(DateTime(day.year, day.month, day.day));
  }

  bool _isAfterDay(DateTime value, DateTime day) {
    final normalized = DateTime(value.year, value.month, value.day);
    return normalized.isAfter(DateTime(day.year, day.month, day.day));
  }

  bool _isWithinDailyGoalTolerance(TrackedDayEntity day) {
    final difference = (day.caloriesTracked - day.calorieGoal).abs();
    return difference <= 250;
  }

  List<FrequentMealInsightEntity> _getTopMeals(List<IntakeEntity> weekIntakes) {
    final counts = <String, int>{};
    for (final intake in weekIntakes) {
      final label = intake.meal.name?.trim();
      if (label == null || label.isEmpty) {
        continue;
      }
      counts[label] = (counts[label] ?? 0) + 1;
    }

    return counts.entries
        .map((entry) =>
            FrequentMealInsightEntity(label: entry.key, count: entry.value))
        .sorted((a, b) => b.count.compareTo(a.count))
        .take(3)
        .toList();
  }

  String _getOvereatingSlot(
      List<TrackedDayEntity> trackedDays, List<IntakeEntity> weekIntakes) {
    final overGoalDays = trackedDays
        .where((day) => day.caloriesTracked > day.calorieGoal)
        .map((day) => DateTime(day.day.year, day.day.month, day.day.day))
        .toSet();
    if (overGoalDays.isEmpty) {
      return S.current.weeklyInsightsNoOvereatingPattern;
    }

    final slotCalories = <String, double>{
      S.current.weeklyInsightsSlotMorning: 0,
      S.current.weeklyInsightsSlotAfternoon: 0,
      S.current.weeklyInsightsSlotEvening: 0,
      S.current.weeklyInsightsSlotLateNight: 0,
    };

    for (final intake in weekIntakes) {
      final intakeDay = DateTime(
          intake.dateTime.year, intake.dateTime.month, intake.dateTime.day);
      if (!overGoalDays.contains(intakeDay)) {
        continue;
      }
      final slot = _hourToSlot(intake.dateTime.hour);
      slotCalories[slot] = (slotCalories[slot] ?? 0) + intake.totalKcal;
    }

    final top =
        slotCalories.entries.sorted((a, b) => b.value.compareTo(a.value)).first;
    if (top.value <= 0) {
      return S.current.weeklyInsightsNoOvereatingPattern;
    }
    return top.key;
  }

  String _hourToSlot(int hour) {
    if (hour < 12) {
      return S.current.weeklyInsightsSlotMorning;
    }
    if (hour < 17) {
      return S.current.weeklyInsightsSlotAfternoon;
    }
    if (hour < 22) {
      return S.current.weeklyInsightsSlotEvening;
    }
    return S.current.weeklyInsightsSlotLateNight;
  }

  String _buildSummaryLabel(
      int adherenceCount, int proteinConsistentCount, int trackedDayCount) {
    if (trackedDayCount == 0) {
      return S.current.weeklyInsightsSummaryNoDays;
    }
    if (adherenceCount >= 5 && proteinConsistentCount >= 5) {
      return S.current.weeklyInsightsSummarySolid;
    }
    if (adherenceCount <= 2) {
      return S.current.weeklyInsightsSummaryIrregular;
    }
    if (proteinConsistentCount <= 2) {
      return S.current.weeklyInsightsSummaryProteinGap;
    }
    return S.current.weeklyInsightsSummaryStable;
  }

  Future<double> _computeWeeklyWeightDelta(DateTime referenceDay) async {
    final summary =
        await _getBodyProgressUsecase.getSummary(referenceDay: referenceDay);
    return summary.weeklyWeightDeltaKg ?? 0;
  }

  _KcalAdjustmentRecommendation _buildKcalAdjustmentRecommendation({
    required UserWeightGoalEntity goal,
    required double adherenceRate,
    required double weeklyWeightDeltaKg,
  }) {
    if (adherenceRate < 0.6) {
      return _KcalAdjustmentRecommendation(
        0,
        S.current.weeklyInsightsRecAdherenceLow,
      );
    }

    switch (goal) {
      case UserWeightGoalEntity.loseWeight:
        if (weeklyWeightDeltaKg > -0.05) {
          return _KcalAdjustmentRecommendation(
            -100,
            S.current.weeklyInsightsRecLoseWeightStalled,
          );
        }
        if (weeklyWeightDeltaKg > -0.12) {
          return _KcalAdjustmentRecommendation(
            -50,
            S.current.weeklyInsightsRecLoseWeightSlow,
          );
        }
        if (weeklyWeightDeltaKg < -0.45) {
          return _KcalAdjustmentRecommendation(
            50,
            S.current.weeklyInsightsRecLoseWeightFast,
          );
        }
        return _KcalAdjustmentRecommendation(
          0,
          S.current.weeklyInsightsRecLoseWeightCorrect,
        );
      case UserWeightGoalEntity.maintainWeight:
        if (weeklyWeightDeltaKg > 0.25) {
          return _KcalAdjustmentRecommendation(
            -50,
            S.current.weeklyInsightsRecMaintainUp,
          );
        }
        if (weeklyWeightDeltaKg < -0.25) {
          return _KcalAdjustmentRecommendation(
            50,
            S.current.weeklyInsightsRecMaintainDown,
          );
        }
        return _KcalAdjustmentRecommendation(
          0,
          S.current.weeklyInsightsRecMaintainStable,
        );
      case UserWeightGoalEntity.gainWeight:
        if (weeklyWeightDeltaKg < 0.05) {
          return _KcalAdjustmentRecommendation(
            100,
            S.current.weeklyInsightsRecGainSlow,
          );
        }
        if (weeklyWeightDeltaKg < 0.12) {
          return _KcalAdjustmentRecommendation(
            50,
            S.current.weeklyInsightsRecGainSoft,
          );
        }
        if (weeklyWeightDeltaKg > 0.45) {
          return _KcalAdjustmentRecommendation(
            -50,
            S.current.weeklyInsightsRecGainFast,
          );
        }
        return _KcalAdjustmentRecommendation(
          0,
          S.current.weeklyInsightsRecGainCorrect,
        );
    }
  }
}

class _KcalAdjustmentRecommendation {
  final int deltaKcal;
  final String label;

  const _KcalAdjustmentRecommendation(this.deltaKcal, this.label);
}
