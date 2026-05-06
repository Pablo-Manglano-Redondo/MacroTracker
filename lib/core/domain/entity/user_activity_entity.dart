import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:macrotracker/core/data/data_source/user_activity_dbo.dart';
import 'package:macrotracker/core/domain/entity/physical_activity_entity.dart';

enum UserActivitySourceEntity {
  manual,
  healthConnect,
}

class UserActivityEntity extends Equatable {
  final String id;
  final double duration;
  final double burnedKcal;
  final DateTime date;
  final UserActivitySourceEntity source;
  final String? externalId;

  final PhysicalActivityEntity physicalActivityEntity;

  const UserActivityEntity(
    this.id,
    this.duration,
    this.burnedKcal,
    this.date,
    this.physicalActivityEntity, {
    this.source = UserActivitySourceEntity.manual,
    this.externalId,
  });

  factory UserActivityEntity.fromUserActivityDBO(UserActivityDBO activityDBO) {
    return UserActivityEntity(
      activityDBO.id,
      activityDBO.duration,
      activityDBO.burnedKcal,
      activityDBO.date,
      PhysicalActivityEntity.fromPhysicalActivityDBO(
        activityDBO.physicalActivityDBO,
      ),
      source: activityDBO.sourceEntity,
      externalId: activityDBO.externalId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        duration,
        burnedKcal,
        date,
        source,
        externalId,
        physicalActivityEntity,
      ];

  static getIconData() => Icons.directions_run_outlined;
}
