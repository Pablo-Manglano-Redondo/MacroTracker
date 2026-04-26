import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_measurement_entity.dart';

part 'body_measurement_dbo.g.dart';

@HiveType(typeId: 24)
@JsonSerializable()
class BodyMeasurementDBO extends HiveObject {
  @HiveField(0)
  DateTime day;

  @HiveField(1)
  double? weightKg;

  @HiveField(2)
  double? waistCm;

  BodyMeasurementDBO({
    required this.day,
    this.weightKg,
    this.waistCm,
  });

  factory BodyMeasurementDBO.fromEntity(BodyMeasurementEntity entity) {
    return BodyMeasurementDBO(
      day: entity.day,
      weightKg: entity.weightKg,
      waistCm: entity.waistCm,
    );
  }

  factory BodyMeasurementDBO.fromJson(Map<String, dynamic> json) =>
      _$BodyMeasurementDBOFromJson(json);

  Map<String, dynamic> toJson() => _$BodyMeasurementDBOToJson(this);
}
