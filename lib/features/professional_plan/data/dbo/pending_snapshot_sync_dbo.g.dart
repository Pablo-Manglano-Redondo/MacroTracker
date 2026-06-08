// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_snapshot_sync_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingSnapshotSyncDBOAdapter
    extends TypeAdapter<PendingSnapshotSyncDBO> {
  @override
  final int typeId = 26;

  @override
  PendingSnapshotSyncDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingSnapshotSyncDBO(
      id: fields[0] as String,
      relationshipId: fields[1] as String,
      professionalId: fields[2] as String,
      clientId: fields[3] as String,
      day: fields[4] as DateTime,
      kcalActual: fields[5] as double,
      kcalTarget: fields[6] as double,
      carbsActual: fields[7] as double,
      carbsTarget: fields[8] as double,
      fatActual: fields[9] as double,
      fatTarget: fields[10] as double,
      proteinActual: fields[11] as double,
      proteinTarget: fields[12] as double,
      mealsLogged: fields[13] as int,
      createdAt: fields[14] as DateTime,
      notes: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingSnapshotSyncDBO obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.relationshipId)
      ..writeByte(2)
      ..write(obj.professionalId)
      ..writeByte(3)
      ..write(obj.clientId)
      ..writeByte(4)
      ..write(obj.day)
      ..writeByte(5)
      ..write(obj.kcalActual)
      ..writeByte(6)
      ..write(obj.kcalTarget)
      ..writeByte(7)
      ..write(obj.carbsActual)
      ..writeByte(8)
      ..write(obj.carbsTarget)
      ..writeByte(9)
      ..write(obj.fatActual)
      ..writeByte(10)
      ..write(obj.fatTarget)
      ..writeByte(11)
      ..write(obj.proteinActual)
      ..writeByte(12)
      ..write(obj.proteinTarget)
      ..writeByte(13)
      ..write(obj.mealsLogged)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingSnapshotSyncDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingSnapshotSyncDBO _$PendingSnapshotSyncDBOFromJson(
        Map<String, dynamic> json) =>
    PendingSnapshotSyncDBO(
      id: json['id'] as String,
      relationshipId: json['relationshipId'] as String,
      professionalId: json['professionalId'] as String,
      clientId: json['clientId'] as String,
      day: DateTime.parse(json['day'] as String),
      kcalActual: (json['kcalActual'] as num).toDouble(),
      kcalTarget: (json['kcalTarget'] as num).toDouble(),
      carbsActual: (json['carbsActual'] as num).toDouble(),
      carbsTarget: (json['carbsTarget'] as num).toDouble(),
      fatActual: (json['fatActual'] as num).toDouble(),
      fatTarget: (json['fatTarget'] as num).toDouble(),
      proteinActual: (json['proteinActual'] as num).toDouble(),
      proteinTarget: (json['proteinTarget'] as num).toDouble(),
      mealsLogged: (json['mealsLogged'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PendingSnapshotSyncDBOToJson(
        PendingSnapshotSyncDBO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'relationshipId': instance.relationshipId,
      'professionalId': instance.professionalId,
      'clientId': instance.clientId,
      'day': instance.day.toIso8601String(),
      'kcalActual': instance.kcalActual,
      'kcalTarget': instance.kcalTarget,
      'carbsActual': instance.carbsActual,
      'carbsTarget': instance.carbsTarget,
      'fatActual': instance.fatActual,
      'fatTarget': instance.fatTarget,
      'proteinActual': instance.proteinActual,
      'proteinTarget': instance.proteinTarget,
      'mealsLogged': instance.mealsLogged,
      'createdAt': instance.createdAt.toIso8601String(),
      'notes': instance.notes,
    };
