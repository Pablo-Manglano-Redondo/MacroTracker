// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_ingredient_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeIngredientDBOAdapter extends TypeAdapter<RecipeIngredientDBO> {
  @override
  final int typeId = 19;

  @override
  RecipeIngredientDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeIngredientDBO(
      id: fields[0] as String,
      mealSnapshot: fields[1] as MealDBO,
      amount: fields[2] as double,
      unit: fields[3] as String,
      position: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeIngredientDBO obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mealSnapshot)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.position);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeIngredientDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeIngredientDBO _$RecipeIngredientDBOFromJson(Map<String, dynamic> json) =>
    RecipeIngredientDBO(
      id: json['id'] as String,
      mealSnapshot:
          MealDBO.fromJson(json['mealSnapshot'] as Map<String, dynamic>),
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      position: (json['position'] as num).toInt(),
    );

Map<String, dynamic> _$RecipeIngredientDBOToJson(
        RecipeIngredientDBO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mealSnapshot': instance.mealSnapshot,
      'amount': instance.amount,
      'unit': instance.unit,
      'position': instance.position,
    };
