import 'package:equatable/equatable.dart';

class BodyProgressSummaryEntity extends Equatable {
  static const stableWeightDeltaKg = 0.15;
  static const stableWaistDeltaCm = 0.5;

  final DateTime? latestMeasurementDay;
  final double? latestWeightKg;
  final double? latestWaistCm;
  final double? rollingWeightAverageKg;
  final double? previousRollingWeightAverageKg;
  final double? weeklyWeightDeltaKg;
  final double? latestWaistDeltaCm;

  const BodyProgressSummaryEntity({
    required this.latestMeasurementDay,
    required this.latestWeightKg,
    required this.latestWaistCm,
    required this.rollingWeightAverageKg,
    required this.previousRollingWeightAverageKg,
    required this.weeklyWeightDeltaKg,
    required this.latestWaistDeltaCm,
  });

  bool get hasData =>
      latestWeightKg != null ||
      latestWaistCm != null ||
      rollingWeightAverageKg != null;

  bool get hasWeightTrend => weeklyWeightDeltaKg != null;

  bool get hasWaistTrend => latestWaistDeltaCm != null;

  bool get isWeightStable =>
      weeklyWeightDeltaKg != null &&
      weeklyWeightDeltaKg!.abs() <= stableWeightDeltaKg;

  bool get isWaistStable =>
      latestWaistDeltaCm != null &&
      latestWaistDeltaCm!.abs() <= stableWaistDeltaCm;

  @override
  List<Object?> get props => [
        latestMeasurementDay,
        latestWeightKg,
        latestWaistCm,
        rollingWeightAverageKg,
        previousRollingWeightAverageKg,
        weeklyWeightDeltaKg,
        latestWaistDeltaCm,
      ];
}
