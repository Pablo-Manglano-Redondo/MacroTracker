import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:macrotracker/core/data/dbo/physical_activity_dbo.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';

part 'user_activity_dbo.g.dart';

@HiveType(typeId: 10)
@JsonSerializable()
class UserActivityDBO extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double duration;
  @HiveField(2)
  final double burnedKcal;
  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final PhysicalActivityDBO physicalActivityDBO;
  @HiveField(5)
  final String? source;
  @HiveField(6)
  final String? externalId;

  UserActivityDBO(
    this.id,
    this.duration,
    this.burnedKcal,
    this.date,
    this.physicalActivityDBO, {
    this.source,
    this.externalId,
  });

  factory UserActivityDBO.fromUserActivityEntity(
      UserActivityEntity userActivityEntity) {
    return UserActivityDBO(
      userActivityEntity.id,
      userActivityEntity.duration,
      userActivityEntity.burnedKcal,
      userActivityEntity.date,
      PhysicalActivityDBO.fromPhysicalActivityEntity(
        userActivityEntity.physicalActivityEntity,
      ),
      source: userActivityEntity.source.name,
      externalId: userActivityEntity.externalId,
    );
  }

  UserActivitySourceEntity get sourceEntity {
    final value = source;
    if (value == UserActivitySourceEntity.healthConnect.name) {
      return UserActivitySourceEntity.healthConnect;
    }
    return UserActivitySourceEntity.manual;
  }

  factory UserActivityDBO.fromJson(Map<String, dynamic> json) =>
      _$UserActivityDBOFromJson(json);

  Map<String, dynamic> toJson() => _$UserActivityDBOToJson(this);
}
