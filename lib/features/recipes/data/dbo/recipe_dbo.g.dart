// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeDBOAdapter extends TypeAdapter<RecipeDBO> {
  @override
  final int typeId = 18;

  @override
  RecipeDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeDBO(
      id: fields[0] as String,
      name: fields[1] as String,
      notes: fields[2] as String?,
      defaultServings: fields[3] as double,
      yieldQuantity: fields[4] as double?,
      yieldUnit: fields[5] as String?,
      saved: fields[6] as bool,
      pinned: fields[11] as bool,
      timesUsed: fields[12] as int,
      lastUsedAt: fields[13] as DateTime?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      ingredients: (fields[9] as List).cast<RecipeIngredientDBO>(),
      quickCategory: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeDBO obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.defaultServings)
      ..writeByte(4)
      ..write(obj.yieldQuantity)
      ..writeByte(5)
      ..write(obj.yieldUnit)
      ..writeByte(6)
      ..write(obj.saved)
      ..writeByte(11)
      ..write(obj.pinned)
      ..writeByte(12)
      ..write(obj.timesUsed)
      ..writeByte(13)
      ..write(obj.lastUsedAt)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.ingredients)
      ..writeByte(10)
      ..write(obj.quickCategory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeDBO _$RecipeDBOFromJson(Map<String, dynamic> json) => RecipeDBO(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: json['notes'] as String?,
      defaultServings: (json['defaultServings'] as num).toDouble(),
      yieldQuantity: (json['yieldQuantity'] as num?)?.toDouble(),
      yieldUnit: json['yieldUnit'] as String?,
      saved: json['favorite'] as bool,
      pinned: json['pinned'] as bool? ?? false,
      timesUsed: (json['timesUsed'] as num?)?.toInt() ?? 0,
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => RecipeIngredientDBO.fromJson(e as Map<String, dynamic>))
          .toList(),
      quickCategory: json['quickCategory'] as String?,
    );

Map<String, dynamic> _$RecipeDBOToJson(RecipeDBO instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'notes': instance.notes,
      'defaultServings': instance.defaultServings,
      'yieldQuantity': instance.yieldQuantity,
      'yieldUnit': instance.yieldUnit,
      'favorite': instance.saved,
      'pinned': instance.pinned,
      'timesUsed': instance.timesUsed,
      'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'ingredients': instance.ingredients,
      'quickCategory': instance.quickCategory,
    };
