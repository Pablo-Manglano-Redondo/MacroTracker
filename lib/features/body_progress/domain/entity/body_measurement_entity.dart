import 'package:equatable/equatable.dart';
import 'package:macrotracker/features/body_progress/data/dbo/body_measurement_dbo.dart';

class BodyMeasurementEntity extends Equatable {
  final DateTime day;
  final double? weightKg;
  final double? waistCm;
  final double? bodyFatPct;

  const BodyMeasurementEntity({
    required this.day,
    this.weightKg,
    this.waistCm,
    this.bodyFatPct,
  });

  factory BodyMeasurementEntity.fromDBO(BodyMeasurementDBO dbo) {
    return BodyMeasurementEntity(
      day: dbo.day,
      weightKg: dbo.weightKg,
      waistCm: dbo.waistCm,
      bodyFatPct: dbo.bodyFatPct,
    );
  }

  @override
  List<Object?> get props => [day, weightKg, waistCm, bodyFatPct];
}
