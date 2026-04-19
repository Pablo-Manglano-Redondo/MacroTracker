// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interpretation_draft_item_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InterpretationDraftItemDBOAdapter
    extends TypeAdapter<InterpretationDraftItemDBO> {
  @override
  final int typeId = 23;

  @override
  InterpretationDraftItemDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterpretationDraftItemDBO(
      id: fields[0] as String,
      label: fields[1] as String,
      matchedMealSnapshot: fields[2] as MealDBO?,
      amount: fields[3] as double,
      unit: fields[4] as String,
      kcal: fields[5] as double,
      carbs: fields[6] as double,
      fat: fields[7] as double,
      protein: fields[8] as double,
      confidenceBand: fields[9] as ConfidenceBandDBO,
      editable: fields[10] as bool,
      removed: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, InterpretationDraftItemDBO obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.matchedMealSnapshot)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.kcal)
      ..writeByte(6)
      ..write(obj.carbs)
      ..writeByte(7)
      ..write(obj.fat)
      ..writeByte(8)
      ..write(obj.protein)
      ..writeByte(9)
      ..write(obj.confidenceBand)
      ..writeByte(10)
      ..write(obj.editable)
      ..writeByte(11)
      ..write(obj.removed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterpretationDraftItemDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConfidenceBandDBOAdapter extends TypeAdapter<ConfidenceBandDBO> {
  @override
  final int typeId = 16;

  @override
  ConfidenceBandDBO read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConfidenceBandDBO.low;
      case 1:
        return ConfidenceBandDBO.medium;
      case 2:
        return ConfidenceBandDBO.high;
      default:
        return ConfidenceBandDBO.low;
    }
  }

  @override
  void write(BinaryWriter writer, ConfidenceBandDBO obj) {
    switch (obj) {
      case ConfidenceBandDBO.low:
        writer.writeByte(0);
        break;
      case ConfidenceBandDBO.medium:
        writer.writeByte(1);
        break;
      case ConfidenceBandDBO.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfidenceBandDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InterpretationDraftItemDBO _$InterpretationDraftItemDBOFromJson(
        Map<String, dynamic> json) =>
    InterpretationDraftItemDBO(
      id: json['id'] as String,
      label: json['label'] as String,
      matchedMealSnapshot: json['matchedMealSnapshot'] == null
          ? null
          : MealDBO.fromJson(
              json['matchedMealSnapshot'] as Map<String, dynamic>),
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      kcal: (json['kcal'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      confidenceBand:
          $enumDecode(_$ConfidenceBandDBOEnumMap, json['confidenceBand']),
      editable: json['editable'] as bool,
      removed: json['removed'] as bool,
    );

Map<String, dynamic> _$InterpretationDraftItemDBOToJson(
        InterpretationDraftItemDBO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'matchedMealSnapshot': instance.matchedMealSnapshot,
      'amount': instance.amount,
      'unit': instance.unit,
      'kcal': instance.kcal,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'protein': instance.protein,
      'confidenceBand': _$ConfidenceBandDBOEnumMap[instance.confidenceBand]!,
      'editable': instance.editable,
      'removed': instance.removed,
    };

const _$ConfidenceBandDBOEnumMap = {
  ConfidenceBandDBO.low: 'low',
  ConfidenceBandDBO.medium: 'medium',
  ConfidenceBandDBO.high: 'high',
};
