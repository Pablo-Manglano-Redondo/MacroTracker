import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:macrotracker/core/data/dbo/tracked_day_dbo.dart';

class TrackedDayEntity extends Equatable {
  static const maxKcalDifferenceOverGoal = 500;
  static const maxKcalDifferenceUnderGoal = 1000;

  final DateTime day;
  final double calorieGoal;
  final double caloriesTracked;
  final double? carbsGoal;
  final double? carbsTracked;
  final double? fatGoal;
  final double? fatTracked;
  final double? proteinGoal;
  final double? proteinTracked;

  const TrackedDayEntity(
      {required this.day,
      required this.calorieGoal,
      required this.caloriesTracked,
      this.carbsGoal,
      this.carbsTracked,
      this.fatGoal,
      this.fatTracked,
      this.proteinGoal,
      this.proteinTracked});

  factory TrackedDayEntity.fromTrackedDayDBO(TrackedDayDBO trackedDayDBO) {
    return TrackedDayEntity(
        day: trackedDayDBO.day,
        calorieGoal: trackedDayDBO.calorieGoal,
        caloriesTracked: trackedDayDBO.caloriesTracked,
        carbsGoal: trackedDayDBO.carbsGoal,
        carbsTracked: trackedDayDBO.carbsTracked,
        fatGoal: trackedDayDBO.fatGoal,
        fatTracked: trackedDayDBO.fatTracked,
        proteinGoal: trackedDayDBO.proteinGoal,
        proteinTracked: trackedDayDBO.proteinTracked);
  }

  bool get isCalorieOnTarget =>
      _hasExceededMaxKcalDifferenceGoal(calorieGoal, caloriesTracked);

  bool get hasProteinGoal =>
      proteinGoal != null && proteinGoal! > 0 && proteinTracked != null;

  bool get isProteinOnTarget {
    if (!hasProteinGoal) return false;
    return proteinTracked! >= proteinGoal!;
  }

  double get calorieAdherenceScore {
    final difference = (calorieGoal - caloriesTracked).abs();
    final maxDifference = caloriesTracked > calorieGoal
        ? maxKcalDifferenceOverGoal
        : maxKcalDifferenceUnderGoal;
    final normalized = 1 - (difference / maxDifference);
    return normalized.clamp(0, 1).toDouble();
  }

  Color getCalendarDayRatingColor(BuildContext context) {
    if (isCalorieOnTarget) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  Color getRatingDayTextColor(BuildContext context) {
    if (isCalorieOnTarget) {
      return Theme.of(context).colorScheme.onSecondaryContainer;
    } else {
      return Theme.of(context).colorScheme.onErrorContainer;
    }
  }

  Color getRatingDayTextBackgroundColor(BuildContext context) {
    if (isCalorieOnTarget) {
      return Theme.of(context).colorScheme.secondaryContainer;
    } else {
      return Theme.of(context).colorScheme.errorContainer;
    }
  }

  bool _hasExceededMaxKcalDifferenceGoal(double calorieGoal, caloriesTracked) {
    double difference = calorieGoal - caloriesTracked;

    if (calorieGoal < caloriesTracked) {
      return difference.abs() < maxKcalDifferenceOverGoal;
    } else {
      return difference < maxKcalDifferenceUnderGoal;
    }
  }

  @override
  List<Object?> get props => [
        day,
        calorieGoal,
        caloriesTracked,
        carbsGoal,
        carbsTracked,
        fatGoal,
        fatTracked,
        proteinGoal,
        proteinTracked
      ];
}
