import 'package:equatable/equatable.dart';

enum FoodQualityBandEntity {
  excellent,
  good,
  fair,
  poor,
}

enum FoodQualityReasonCode {
  highFiber,
  goodProtein,
  balancedProfile,
  lowSugar,
  highSugar,
  highEnergyDensity,
  lowEnergyDensity,
  highSaturatedFat,
  partialData,
}

class FoodQualityScoreEntity extends Equatable {
  final int score;
  final FoodQualityBandEntity band;
  final List<FoodQualityReasonCode> reasons;
  final bool isPartial;

  const FoodQualityScoreEntity({
    required this.score,
    required this.band,
    required this.reasons,
    required this.isPartial,
  });

  @override
  List<Object?> get props => [score, band, reasons, isPartial];
}

class FoodQualityDailySummaryEntity extends Equatable {
  final double score;
  final FoodQualityBandEntity band;
  final int mealsCount;

  const FoodQualityDailySummaryEntity({
    required this.score,
    required this.band,
    required this.mealsCount,
  });

  bool get hasData => mealsCount > 0;

  @override
  List<Object?> get props => [score, band, mealsCount];
}
