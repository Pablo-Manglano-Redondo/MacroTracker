// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_habit_log_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyHabitLogDBOAdapter extends TypeAdapter<DailyHabitLogDBO> {
  @override
  final int typeId = 25;

  @override
  DailyHabitLogDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyHabitLogDBO(
      day: fields[0] as DateTime,
      creatineTaken: fields[1] as bool,
      wheyTaken: fields[2] as bool,
      caffeineTaken: fields[3] as bool,
      waterLiters: fields[4] as double,
      sleepHours: fields[5] as double,
      steps: fields[6] as int,
      energyLevel: fields[7] as int,
      sleepSyncedFromHealthConnect: fields[8] as bool? ?? false,
      stepsSyncedFromHealthConnect: fields[9] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, DailyHabitLogDBO obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.creatineTaken)
      ..writeByte(2)
      ..write(obj.wheyTaken)
      ..writeByte(3)
      ..write(obj.caffeineTaken)
      ..writeByte(4)
      ..write(obj.waterLiters)
      ..writeByte(5)
      ..write(obj.sleepHours)
      ..writeByte(6)
      ..write(obj.steps)
      ..writeByte(7)
      ..write(obj.energyLevel)
      ..writeByte(8)
      ..write(obj.sleepSyncedFromHealthConnect)
      ..writeByte(9)
      ..write(obj.stepsSyncedFromHealthConnect);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyHabitLogDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyHabitLogDBO _$DailyHabitLogDBOFromJson(Map<String, dynamic> json) =>
    DailyHabitLogDBO(
      day: DateTime.parse(json['day'] as String),
      creatineTaken: json['creatineTaken'] as bool? ?? false,
      wheyTaken: json['wheyTaken'] as bool? ?? false,
      caffeineTaken: json['caffeineTaken'] as bool? ?? false,
      waterLiters: (json['waterLiters'] as num?)?.toDouble() ?? 0,
      sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 0,
      steps: (json['steps'] as num?)?.toInt() ?? 0,
      energyLevel: (json['energyLevel'] as num?)?.toInt() ?? 0,
      sleepSyncedFromHealthConnect:
          json['sleepSyncedFromHealthConnect'] as bool? ?? false,
      stepsSyncedFromHealthConnect:
          json['stepsSyncedFromHealthConnect'] as bool? ?? false,
    );

Map<String, dynamic> _$DailyHabitLogDBOToJson(DailyHabitLogDBO instance) =>
    <String, dynamic>{
      'day': instance.day.toIso8601String(),
      'creatineTaken': instance.creatineTaken,
      'wheyTaken': instance.wheyTaken,
      'caffeineTaken': instance.caffeineTaken,
      'waterLiters': instance.waterLiters,
      'sleepHours': instance.sleepHours,
      'steps': instance.steps,
      'energyLevel': instance.energyLevel,
      'sleepSyncedFromHealthConnect': instance.sleepSyncedFromHealthConnect,
      'stepsSyncedFromHealthConnect': instance.stepsSyncedFromHealthConnect,
    };
