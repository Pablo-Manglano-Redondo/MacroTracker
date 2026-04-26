// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_measurement_dbo.dart';

class BodyMeasurementDBOAdapter extends TypeAdapter<BodyMeasurementDBO> {
  @override
  final int typeId = 24;

  @override
  BodyMeasurementDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyMeasurementDBO(
      day: fields[0] as DateTime,
      weightKg: fields[1] as double?,
      waistCm: fields[2] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, BodyMeasurementDBO obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.weightKg)
      ..writeByte(2)
      ..write(obj.waistCm);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyMeasurementDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

BodyMeasurementDBO _$BodyMeasurementDBOFromJson(Map<String, dynamic> json) =>
    BodyMeasurementDBO(
      day: DateTime.parse(json['day'] as String),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      waistCm: (json['waistCm'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BodyMeasurementDBOToJson(BodyMeasurementDBO instance) =>
    <String, dynamic>{
      'day': instance.day.toIso8601String(),
      'weightKg': instance.weightKg,
      'waistCm': instance.waistCm,
    };
