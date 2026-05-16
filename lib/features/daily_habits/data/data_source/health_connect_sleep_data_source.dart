import 'dart:io';

import 'package:health/health.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_connect_workout_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_sleep_session_entity.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthConnectSleepDataSource {
  final _log = Logger('HealthConnectSleepDataSource');
  static const _healthConnectChannel =
      MethodChannel('macrotracker/health_connect');

  static const _coreReadTypes = [
    HealthDataType.SLEEP_SESSION,
    HealthDataType.WORKOUT,
  ];
  static const _corePermissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];
  static const _workoutSupplementReadTypes = [
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.DISTANCE_DELTA,
  ];
  static const _workoutSupplementPermissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];
  static const _stepsReadTypes = [
    HealthDataType.STEPS,
  ];
  static const _stepsPermissions = [
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
        _coreReadTypes,
        permissions: _corePermissions,
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
        _coreReadTypes,
        permissions: _corePermissions,
      );
    } catch (error, stackTrace) {
      _log.warning('Health Connect permission request failed', error, stackTrace);
      return false;
    }
  }

  Future<bool> hasStepsReadPermission() async {
    try {
      final hasPermissions = await _health.hasPermissions(
        _stepsReadTypes,
        permissions: _stepsPermissions,
      );
      return hasPermissions ?? false;
    } catch (error, stackTrace) {
      _log.warning(
        'Health Connect steps permission check failed',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> requestStepsReadPermission() async {
    try {
      return await _health.requestAuthorization(
        _stepsReadTypes,
        permissions: _stepsPermissions,
      );
    } catch (error, stackTrace) {
      _log.warning(
        'Health Connect steps permission request failed',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> hasWorkoutSupplementReadPermission() async {
    try {
      final hasPermissions = await _health.hasPermissions(
        _workoutSupplementReadTypes,
        permissions: _workoutSupplementPermissions,
      );
      return hasPermissions ?? false;
    } catch (error, stackTrace) {
      _log.warning(
        'Health Connect workout supplement permission check failed',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> requestWorkoutSupplementReadPermission() async {
    try {
      return await _health.requestAuthorization(
        _workoutSupplementReadTypes,
        permissions: _workoutSupplementPermissions,
      );
    } catch (error, stackTrace) {
      _log.warning(
        'Health Connect workout supplement permission request failed',
        error,
        stackTrace,
      );
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
    final nativeWorkouts = await _readWorkoutsFromNativeChannel(
      startTime,
      endTime,
    );
    if (nativeWorkouts.isNotEmpty) {
      return nativeWorkouts;
    }

    try {
      final points = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: const [HealthDataType.WORKOUT],
      );
      final uniquePoints = _health.removeDuplicates(points);
      final workouts = <HealthConnectWorkoutEntity>[];
      for (final point
          in uniquePoints.where((point) => point.type == HealthDataType.WORKOUT)) {
        final workout = _tryMapWorkout(point);
        if (workout != null) {
          workouts.add(workout);
        }
      }
      workouts.sort((left, right) => left.startTime.compareTo(right.startTime));
      return workouts;
    } catch (error, stackTrace) {
      _log.warning('Reading workouts failed', error, stackTrace);
      return const [];
    }
  }

  Future<List<HealthConnectWorkoutEntity>> _readWorkoutsFromNativeChannel(
    DateTime startTime,
    DateTime endTime,
  ) async {
    if (!Platform.isAndroid) {
      return const [];
    }

    try {
      final result = await _healthConnectChannel.invokeMethod<List<dynamic>>(
        'readWorkouts',
        {
          'startTime': startTime.millisecondsSinceEpoch,
          'endTime': endTime.millisecondsSinceEpoch,
        },
      );
      if (result == null) {
        return const [];
      }

      final workouts = result
          .whereType<Map<dynamic, dynamic>>()
          .map(_mapNativeWorkout)
          .whereType<HealthConnectWorkoutEntity>()
          .toList();
      workouts.sort((left, right) => left.startTime.compareTo(right.startTime));
      return workouts;
    } on MissingPluginException {
      return const [];
    } catch (error, stackTrace) {
      _log.warning(
        'Reading workouts through native channel failed',
        error,
        stackTrace,
      );
      return const [];
    }
  }

  HealthConnectWorkoutEntity? _mapNativeWorkout(Map<dynamic, dynamic> raw) {
    final startMillis = raw['date_from'];
    final endMillis = raw['date_to'];
    if (startMillis is! int || endMillis is! int) {
      return null;
    }

    final startTime = DateTime.fromMillisecondsSinceEpoch(startMillis);
    final endTime = DateTime.fromMillisecondsSinceEpoch(endMillis);
    if (!endTime.isAfter(startTime)) {
      return null;
    }

    final workoutType =
        (raw['workoutActivityType'] as String?)?.trim().toUpperCase();
    final normalizedWorkoutType =
        workoutType == null || workoutType.isEmpty ? 'OTHER' : workoutType;
    final burnedKcal = (raw['totalEnergyBurned'] as num?)?.toDouble() ?? 0.0;
    final sourceName = (raw['source_name'] as String?)?.trim() ?? '';
    final externalId = (raw['uuid'] as String?)?.trim().isNotEmpty == true
        ? raw['uuid'] as String
        : _buildNativeWorkoutFallbackId(
            normalizedWorkoutType,
            startTime,
            endTime,
            burnedKcal,
            sourceName,
          );
    final displayName = _formatWorkoutTypeDisplayName(normalizedWorkoutType);

    return HealthConnectWorkoutEntity(
      externalId: externalId,
      activityCode: 'hc:${normalizedWorkoutType.toLowerCase()}',
      displayName: displayName,
      description: sourceName.isEmpty ? displayName : '$displayName - $sourceName',
      startTime: startTime,
      endTime: endTime,
      durationMinutes: endTime.difference(startTime).inMinutes.toDouble(),
      burnedKcal: burnedKcal,
    );
  }

  String _buildNativeWorkoutFallbackId(
    String workoutType,
    DateTime startTime,
    DateTime endTime,
    double burnedKcal,
    String sourceName,
  ) {
    return [
      'hc',
      workoutType,
      sourceName,
      startTime.millisecondsSinceEpoch,
      endTime.millisecondsSinceEpoch,
      burnedKcal.toStringAsFixed(1),
    ].join(':');
  }

  String _formatWorkoutTypeDisplayName(String workoutType) {
    return workoutType
        .toLowerCase()
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  HealthConnectWorkoutEntity? _tryMapWorkout(HealthDataPoint point) {
    try {
      return _mapWorkout(point);
    } catch (error, stackTrace) {
      _log.warning(
        'Skipping workout due to mapping failure',
        error,
        stackTrace,
      );
      return null;
    }
  }

  HealthConnectWorkoutEntity? _mapWorkout(HealthDataPoint point) {
    if (!point.dateTo.isAfter(point.dateFrom)) {
      _log.fine('Skipping workout with invalid time range: $point');
      return null;
    }
    final value = point.value;
    HealthWorkoutActivityType? activityType;
    int? burnedKcal;
    if (value is WorkoutHealthValue) {
      activityType = value.workoutActivityType;
      burnedKcal = value.totalEnergyBurned ??
          point.workoutSummary?.totalEnergyBurned.toInt();
    } else {
      activityType = _resolveWorkoutActivityType(
        point.workoutSummary?.workoutType,
      );
      burnedKcal = point.workoutSummary?.totalEnergyBurned.toInt();
      if (activityType == null) {
        _log.fine(
          'Skipping workout without activity type: ${point.value}',
        );
        return null;
      }
    }

    final normalizedBurnedKcal = burnedKcal ?? 0;
    if (normalizedBurnedKcal <= 0) {
      _log.fine(
        'Workout missing calories, defaulting to 0: '
        'type=${activityType.name}, source=${point.sourceName}',
      );
    }

    final externalId = _resolveWorkoutExternalId(
      point,
      activityType.name,
      normalizedBurnedKcal,
    );
    final displayName = _workoutDisplayName(activityType);
    return HealthConnectWorkoutEntity(
      externalId: externalId,
      activityCode: 'hc:${activityType.name.toLowerCase()}',
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
      burnedKcal: normalizedBurnedKcal.toDouble(),
    );
  }

  String _resolveWorkoutExternalId(
    HealthDataPoint point,
    String activityTypeName,
    int burnedKcal,
  ) {
    if (point.uuid.isNotEmpty) {
      return point.uuid;
    }

    final sourceId = point.sourceId.isNotEmpty ? point.sourceId : point.sourceName;
    return [
      'hc',
      activityTypeName,
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

  HealthWorkoutActivityType? _resolveWorkoutActivityType(String? workoutType) {
    if (workoutType == null || workoutType.trim().isEmpty) {
      return null;
    }

    final normalized = workoutType.trim().toUpperCase();
    if (normalized == 'CYCLING') {
      return HealthWorkoutActivityType.BIKING;
    }

    for (final type in HealthWorkoutActivityType.values) {
      if (type.name == normalized) {
        return type;
      }
    }
    return null;
  }
}
