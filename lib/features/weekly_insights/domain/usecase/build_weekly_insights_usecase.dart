import 'package:collection/collection.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:macrotracker/features/weekly_insights/domain/entity/weekly_insights_entity.dart';

class BuildWeeklyInsightsUsecase {
  final GetTrackedDayUsecase _getTrackedDayUsecase;
  final GetIntakeUsecase _getIntakeUsecase;

  BuildWeeklyInsightsUsecase(this._getTrackedDayUsecase, this._getIntakeUsecase);

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
        : trackedDays.map((day) => day.proteinTracked ?? 0).sum / trackedDayCount;

    final adherenceCount =
        trackedDays.where(_isWithinDailyGoalTolerance).length;
    final proteinConsistentCount = trackedDays
        .where((day) =>
            (day.proteinTracked ?? 0) >= ((day.proteinGoal ?? 0) * 0.9) &&
            (day.proteinGoal ?? 0) > 0)
        .length;

    final topMeals = _getTopMeals(weekIntakes);
    final overeatingSlot = _getOvereatingSlot(trackedDays, weekIntakes);

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
      return 'No clear overeating pattern';
    }

    final slotCalories = <String, double>{
      'Morning': 0,
      'Afternoon': 0,
      'Evening': 0,
      'Late night': 0,
    };

    for (final intake in weekIntakes) {
      final intakeDay =
          DateTime(intake.dateTime.year, intake.dateTime.month, intake.dateTime.day);
      if (!overGoalDays.contains(intakeDay)) {
        continue;
      }
      final slot = _hourToSlot(intake.dateTime.hour);
      slotCalories[slot] = (slotCalories[slot] ?? 0) + intake.totalKcal;
    }

    final top = slotCalories.entries.sorted((a, b) => b.value.compareTo(a.value)).first;
    if (top.value <= 0) {
      return 'No clear overeating pattern';
    }
    return top.key;
  }

  String _hourToSlot(int hour) {
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    if (hour < 22) {
      return 'Evening';
    }
    return 'Late night';
  }

  String _buildSummaryLabel(
      int adherenceCount, int proteinConsistentCount, int trackedDayCount) {
    if (trackedDayCount == 0) {
      return 'No logged days this week yet.';
    }
    if (adherenceCount >= 5 && proteinConsistentCount >= 5) {
      return 'Strong week: good calorie adherence and solid protein consistency.';
    }
    if (adherenceCount <= 2) {
      return 'Calorie adherence was inconsistent this week.';
    }
    if (proteinConsistentCount <= 2) {
      return 'Protein target consistency was the main gap this week.';
    }
    return 'This week was fairly steady, with room to tighten consistency.';
  }
}
