// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserDBOAdapter extends TypeAdapter<UserDBO> {
  @override
  final int typeId = 5;

  @override
  UserDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserDBO(
      birthday: fields[0] as DateTime,
      heightCM: fields[1] as double,
      weightKG: fields[2] as double,
      profileImagePath: fields[6] as String?,
      gender: fields[3] as UserGenderDBO,
      goal: fields[4] as UserWeightGoalDBO,
      pal: fields[5] as UserPALDBO,
      targetSteps: fields[7] as int?,
      targetSleepHours: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, UserDBO obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.birthday)
      ..writeByte(1)
      ..write(obj.heightCM)
      ..writeByte(2)
      ..write(obj.weightKG)
      ..writeByte(6)
      ..write(obj.profileImagePath)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.goal)
      ..writeByte(5)
      ..write(obj.pal)
      ..writeByte(7)
      ..write(obj.targetSteps)
      ..writeByte(8)
      ..write(obj.targetSleepHours);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
