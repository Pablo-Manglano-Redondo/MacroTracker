// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interpretation_draft_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InterpretationDraftDBOAdapter
    extends TypeAdapter<InterpretationDraftDBO> {
  @override
  final int typeId = 22;

  @override
  InterpretationDraftDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterpretationDraftDBO(
      id: fields[0] as String,
      sourceType: fields[1] as DraftSourceDBO,
      inputText: fields[2] as String?,
      localImagePath: fields[3] as String?,
      title: fields[4] as String,
      summary: fields[5] as String?,
      totalKcal: fields[6] as double,
      totalCarbs: fields[7] as double,
      totalFat: fields[8] as double,
      totalProtein: fields[9] as double,
      confidenceBand: fields[10] as ConfidenceBandDBO,
      status: fields[11] as DraftStatusDBO,
      createdAt: fields[12] as DateTime,
      expiresAt: fields[13] as DateTime,
      items: (fields[14] as List).cast<InterpretationDraftItemDBO>(),
    );
  }

  @override
  void write(BinaryWriter writer, InterpretationDraftDBO obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sourceType)
      ..writeByte(2)
      ..write(obj.inputText)
      ..writeByte(3)
      ..write(obj.localImagePath)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.summary)
      ..writeByte(6)
      ..write(obj.totalKcal)
      ..writeByte(7)
      ..write(obj.totalCarbs)
      ..writeByte(8)
      ..write(obj.totalFat)
      ..writeByte(9)
      ..write(obj.totalProtein)
      ..writeByte(10)
      ..write(obj.confidenceBand)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.expiresAt)
      ..writeByte(14)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterpretationDraftDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DraftSourceDBOAdapter extends TypeAdapter<DraftSourceDBO> {
  @override
  final int typeId = 20;

  @override
  DraftSourceDBO read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DraftSourceDBO.text;
      case 1:
        return DraftSourceDBO.photo;
      default:
        return DraftSourceDBO.text;
    }
  }

  @override
  void write(BinaryWriter writer, DraftSourceDBO obj) {
    switch (obj) {
      case DraftSourceDBO.text:
        writer.writeByte(0);
        break;
      case DraftSourceDBO.photo:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DraftSourceDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DraftStatusDBOAdapter extends TypeAdapter<DraftStatusDBO> {
  @override
  final int typeId = 21;

  @override
  DraftStatusDBO read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DraftStatusDBO.pending;
      case 1:
        return DraftStatusDBO.ready;
      case 2:
        return DraftStatusDBO.failed;
      case 3:
        return DraftStatusDBO.expired;
      default:
        return DraftStatusDBO.pending;
    }
  }

  @override
  void write(BinaryWriter writer, DraftStatusDBO obj) {
    switch (obj) {
      case DraftStatusDBO.pending:
        writer.writeByte(0);
        break;
      case DraftStatusDBO.ready:
        writer.writeByte(1);
        break;
      case DraftStatusDBO.failed:
        writer.writeByte(2);
        break;
      case DraftStatusDBO.expired:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DraftStatusDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InterpretationDraftDBO _$InterpretationDraftDBOFromJson(
        Map<String, dynamic> json) =>
    InterpretationDraftDBO(
      id: json['id'] as String,
      sourceType: $enumDecode(_$DraftSourceDBOEnumMap, json['sourceType']),
      inputText: json['inputText'] as String?,
      localImagePath: json['localImagePath'] as String?,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      totalKcal: (json['totalKcal'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalFat: (json['totalFat'] as num).toDouble(),
      totalProtein: (json['totalProtein'] as num).toDouble(),
      confidenceBand:
          $enumDecode(_$ConfidenceBandDBOEnumMap, json['confidenceBand']),
      status: $enumDecode(_$DraftStatusDBOEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) =>
              InterpretationDraftItemDBO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InterpretationDraftDBOToJson(
        InterpretationDraftDBO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceType': _$DraftSourceDBOEnumMap[instance.sourceType]!,
      'inputText': instance.inputText,
      'localImagePath': instance.localImagePath,
      'title': instance.title,
      'summary': instance.summary,
      'totalKcal': instance.totalKcal,
      'totalCarbs': instance.totalCarbs,
      'totalFat': instance.totalFat,
      'totalProtein': instance.totalProtein,
      'confidenceBand': _$ConfidenceBandDBOEnumMap[instance.confidenceBand]!,
      'status': _$DraftStatusDBOEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'items': instance.items,
    };

const _$DraftSourceDBOEnumMap = {
  DraftSourceDBO.text: 'text',
  DraftSourceDBO.photo: 'photo',
};

const _$ConfidenceBandDBOEnumMap = {
  ConfidenceBandDBO.low: 'low',
  ConfidenceBandDBO.medium: 'medium',
  ConfidenceBandDBO.high: 'high',
};

const _$DraftStatusDBOEnumMap = {
  DraftStatusDBO.pending: 'pending',
  DraftStatusDBO.ready: 'ready',
  DraftStatusDBO.failed: 'failed',
  DraftStatusDBO.expired: 'expired',
};
