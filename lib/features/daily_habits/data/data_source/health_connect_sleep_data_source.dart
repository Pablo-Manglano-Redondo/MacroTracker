import 'dart:io';

import 'package:health/health.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_sleep_session_entity.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthConnectSleepDataSource {
  static const _readTypes = [
    HealthDataType.SLEEP_SESSION,
    HealthDataType.STEPS,
  ];
  static const _permissions = [HealthDataAccess.READ];

  final Health _health;

  HealthConnectSleepDataSource({Health? health}) : _health = health ?? Health();

  Future<void> configure() => _health.configure();

  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) {
      return false;
    }
    return _health.isHealthConnectAvailable();
  }

  Future<bool> hasReadPermission() async {
    final hasPermissions = await _health.hasPermissions(
      _readTypes,
      permissions: _permissions,
    );
    return hasPermissions ?? false;
  }

  Future<bool> requestReadPermission() {
    return _health.requestAuthorization(
      _readTypes,
      permissions: _permissions,
    );
  }

  Future<bool> hasActivityRecognitionPermission() async {
    if (!Platform.isAndroid) {
      return false;
    }
    return Permission.activityRecognition.status.isGranted;
  }

  Future<bool> requestActivityRecognitionPermission() async {
    if (!Platform.isAndroid) {
      return false;
    }
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  Future<List<HealthSleepSessionEntity>> readSleepSessions(
    DateTime startTime,
    DateTime endTime,
  ) async {
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
  }

  Future<int> readStepCount(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final stepCount = await _health.getTotalStepsInInterval(startTime, endTime);
    return stepCount == null || stepCount < 0 ? 0 : stepCount;
  }
}
