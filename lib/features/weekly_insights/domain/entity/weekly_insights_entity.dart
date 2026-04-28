import 'package:equatable/equatable.dart';

class FrequentMealInsightEntity extends Equatable {
  final String label;
  final int count;

  const FrequentMealInsightEntity({required this.label, required this.count});

  @override
  List<Object?> get props => [label, count];
}

class WeeklyInsightsEntity extends Equatable {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int trackedDays;
  final double averageCalories;
  final double averageCarbs;
  final double averageFat;
  final double averageProtein;
  final double goalAdherenceRate;
  final double proteinConsistencyRate;
  final String overeatingTimeSlotLabel;
  final List<FrequentMealInsightEntity> topMeals;
  final String summaryLabel;
  final double weeklyWeightDeltaKg;
  final int recommendedKcalAdjustmentDelta;
  final String kcalAdjustmentRecommendation;

  const WeeklyInsightsEntity({
    required this.weekStart,
    required this.weekEnd,
    required this.trackedDays,
    required this.averageCalories,
    required this.averageCarbs,
    required this.averageFat,
    required this.averageProtein,
    required this.goalAdherenceRate,
    required this.proteinConsistencyRate,
    required this.overeatingTimeSlotLabel,
    required this.topMeals,
    required this.summaryLabel,
    required this.weeklyWeightDeltaKg,
    required this.recommendedKcalAdjustmentDelta,
    required this.kcalAdjustmentRecommendation,
  });

  @override
  List<Object?> get props => [
        weekStart,
        weekEnd,
        trackedDays,
        averageCalories,
        averageCarbs,
        averageFat,
        averageProtein,
        goalAdherenceRate,
        proteinConsistencyRate,
        overeatingTimeSlotLabel,
        topMeals,
        summaryLabel,
        weeklyWeightDeltaKg,
        recommendedKcalAdjustmentDelta,
        kcalAdjustmentRecommendation,
      ];
}
