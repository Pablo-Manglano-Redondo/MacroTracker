import 'dart:io';

import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_connect_workout_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_sleep_session_entity.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthConnectSleepDataSource {
  final _log = Logger('HealthConnectSleepDataSource');

  static const _readTypes = [
    HealthDataType.SLEEP_SESSION,
    HealthDataType.STEPS,
    HealthDataType.WORKOUT,
  ];
  static const _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  final Health _health;

  HealthConnectSleepDataSource({Health? health}) : _health = health ?? Health();

  Future<void> configure() async {
    try {
      await _health.configure();
    } catch (error, stackTrace) {
      _log.warning('Health Connect configure failed', error, stackTrace);
    }
  }

  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      return await _health.isHealthConnectAvailable();
    } catch (error, stackTrace) {
      _log.warning('Health Connect availability check failed', error, stackTrace);
      return false;
    }
  }

  Future<bool> hasReadPermission() async {
    try {
      final hasPermissions = await _health.hasPermissions(
        _readTypes,
        permissions: _permissions,
      );
      return hasPermissions ?? false;
    } catch (error, stackTrace) {
      _log.warning('Health Connect permission check failed', error, stackTrace);
      return false;
    }
  }

  Future<bool> requestReadPermission() async {
    try {
      return await _health.requestAuthorization(
        _readTypes,
        permissions: _permissions,
      );
    } catch (error, stackTrace) {
      _log.warning('Health Connect permission request failed', error, stackTrace);
      return false;
    }
  }

  Future<bool> hasActivityRecognitionPermission() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final status = await Permission.activityRecognition.status;
      return status.isGranted;
    } catch (error, stackTrace) {
      _log.warning(
        'Activity Recognition permission check failed',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> requestActivityRecognitionPermission() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final status = await Permission.activityRecognition.request();
      return status.isGranted;
    } catch (error, stackTrace) {
      _log.warning(
        'Activity Recognition permission request failed',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<List<HealthSleepSessionEntity>> readSleepSessions(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final points = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: const [HealthDataType.SLEEP_SESSION],
      );
      final uniquePoints = _health.removeDuplicates(points);
      return uniquePoints
          .where((point) => point.type == HealthDataType.SLEEP_SESSION)
          .map(
            (point) => HealthSleepSessionEntity(
              startTime: point.dateFrom,
              endTime: point.dateTo,
            ),
          )
          .toList(growable: false);
    } catch (error, stackTrace) {
      _log.warning('Reading sleep sessions failed', error, stackTrace);
      return const [];
    }
  }

  Future<int> readStepCount(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final stepCount = await _health.getTotalStepsInInterval(startTime, endTime);
      return stepCount == null || stepCount < 0 ? 0 : stepCount;
    } catch (error, stackTrace) {
      _log.warning('Reading step count failed', error, stackTrace);
      return 0;
    }
  }

  Future<List<HealthConnectWorkoutEntity>> readWorkouts(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final points = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: const [HealthDataType.WORKOUT],
      );
      final uniquePoints = _health.removeDuplicates(points);
      final workouts = uniquePoints
          .where((point) => point.type == HealthDataType.WORKOUT)
          .map(_mapWorkout)
          .whereType<HealthConnectWorkoutEntity>()
          .toList();
      workouts.sort((left, right) => left.startTime.compareTo(right.startTime));
      return workouts;
    } catch (error, stackTrace) {
      _log.warning('Reading workouts failed', error, stackTrace);
      return const [];
    }
  }

  HealthConnectWorkoutEntity? _mapWorkout(HealthDataPoint point) {
    if (!point.dateTo.isAfter(point.dateFrom)) {
      _log.fine('Skipping workout with invalid time range: $point');
      return null;
    }
    final value = point.value;
    if (value is! WorkoutHealthValue) {
      _log.fine('Skipping workout with unexpected value type: ${point.value}');
      return null;
    }

    final burnedKcal =
        value.totalEnergyBurned ?? point.workoutSummary?.totalEnergyBurned.toInt();
    if (burnedKcal == null || burnedKcal <= 0) {
      _log.fine(
        'Skipping workout without calories: '
        'type=${value.workoutActivityType.name}, source=${point.sourceName}',
      );
      return null;
    }

    final externalId = _resolveWorkoutExternalId(point, value, burnedKcal);
    final displayName = _workoutDisplayName(value.workoutActivityType);
    return HealthConnectWorkoutEntity(
      externalId: externalId,
      activityCode: 'hc:${value.workoutActivityType.name.toLowerCase()}',
      displayName: displayName,
      description: point.sourceName.isEmpty
          ? displayName
          : '$displayName - ${point.sourceName}',
      startTime: point.dateFrom,
      endTime: point.dateTo,
      durationMinutes: point.dateTo
          .difference(point.dateFrom)
          .inMinutes
          .toDouble(),
      burnedKcal: burnedKcal.toDouble(),
    );
  }

  String _resolveWorkoutExternalId(
    HealthDataPoint point,
    WorkoutHealthValue value,
    int burnedKcal,
  ) {
    if (point.uuid.isNotEmpty) {
      return point.uuid;
    }

    final sourceId = point.sourceId.isNotEmpty ? point.sourceId : point.sourceName;
    return [
      'hc',
      value.workoutActivityType.name,
      sourceId,
      point.dateFrom.millisecondsSinceEpoch,
      point.dateTo.millisecondsSinceEpoch,
      burnedKcal,
    ].join(':');
  }

  String _workoutDisplayName(HealthWorkoutActivityType type) {
    return type.name
        .toLowerCase()
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
