import 'package:equatable/equatable.dart';

class HealthConnectWorkoutEntity extends Equatable {
  final String externalId;
  final String activityCode;
  final String displayName;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final double durationMinutes;
  final double burnedKcal;

  const HealthConnectWorkoutEntity({
    required this.externalId,
    required this.activityCode,
    required this.displayName,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.burnedKcal,
  });

  @override
  List<Object?> get props => [
        externalId,
        activityCode,
        displayName,
        description,
        startTime,
        endTime,
        durationMinutes,
        burnedKcal,
      ];
}
