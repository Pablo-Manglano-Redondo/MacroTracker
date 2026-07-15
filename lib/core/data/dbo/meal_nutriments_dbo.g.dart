// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_nutriments_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealNutrimentsDBOAdapter extends TypeAdapter<MealNutrimentsDBO> {
  @override
  final int typeId = 3;

  @override
  MealNutrimentsDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealNutrimentsDBO(
      energyKcal100: fields[0] as double?,
      carbohydrates100: fields[1] as double?,
      fat100: fields[2] as double?,
      proteins100: fields[3] as double?,
      sugars100: fields[4] as double?,
      saturatedFat100: fields[5] as double?,
      fiber100: fields[6] as double?,
      sodium100: fields[7] as double?,
      potassium100: fields[8] as double?,
      calcium100: fields[9] as double?,
      iron100: fields[10] as double?,
      vitaminC100: fields[11] as double?,
      vitaminD100: fields[12] as double?,
      novaGroup: fields[13] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, MealNutrimentsDBO obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.energyKcal100)
      ..writeByte(1)
      ..write(obj.carbohydrates100)
      ..writeByte(2)
      ..write(obj.fat100)
      ..writeByte(3)
      ..write(obj.proteins100)
      ..writeByte(4)
      ..write(obj.sugars100)
      ..writeByte(5)
      ..write(obj.saturatedFat100)
      ..writeByte(6)
      ..write(obj.fiber100)
      ..writeByte(7)
      ..write(obj.sodium100)
      ..writeByte(8)
      ..write(obj.potassium100)
      ..writeByte(9)
      ..write(obj.calcium100)
      ..writeByte(10)
      ..write(obj.iron100)
      ..writeByte(11)
      ..write(obj.vitaminC100)
      ..writeByte(12)
      ..write(obj.vitaminD100)
      ..writeByte(13)
      ..write(obj.novaGroup);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealNutrimentsDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealNutrimentsDBO _$MealNutrimentsDBOFromJson(Map<String, dynamic> json) =>
    MealNutrimentsDBO(
      energyKcal100: (json['energyKcal100'] as num?)?.toDouble(),
      carbohydrates100: (json['carbohydrates100'] as num?)?.toDouble(),
      fat100: (json['fat100'] as num?)?.toDouble(),
      proteins100: (json['proteins100'] as num?)?.toDouble(),
      sugars100: (json['sugars100'] as num?)?.toDouble(),
      saturatedFat100: (json['saturatedFat100'] as num?)?.toDouble(),
      fiber100: (json['fiber100'] as num?)?.toDouble(),
      sodium100: (json['sodium100'] as num?)?.toDouble(),
      potassium100: (json['potassium100'] as num?)?.toDouble(),
      calcium100: (json['calcium100'] as num?)?.toDouble(),
      iron100: (json['iron100'] as num?)?.toDouble(),
      vitaminC100: (json['vitaminC100'] as num?)?.toDouble(),
      vitaminD100: (json['vitaminD100'] as num?)?.toDouble(),
      novaGroup: (json['novaGroup'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MealNutrimentsDBOToJson(MealNutrimentsDBO instance) =>
    <String, dynamic>{
      'energyKcal100': instance.energyKcal100,
      'carbohydrates100': instance.carbohydrates100,
      'fat100': instance.fat100,
      'proteins100': instance.proteins100,
      'sugars100': instance.sugars100,
      'saturatedFat100': instance.saturatedFat100,
      'fiber100': instance.fiber100,
      'sodium100': instance.sodium100,
      'potassium100': instance.potassium100,
      'calcium100': instance.calcium100,
      'iron100': instance.iron100,
      'vitaminC100': instance.vitaminC100,
      'vitaminD100': instance.vitaminD100,
      'novaGroup': instance.novaGroup,
    };
