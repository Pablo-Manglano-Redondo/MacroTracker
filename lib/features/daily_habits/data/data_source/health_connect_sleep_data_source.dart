import 'dart:io';

import 'package:health/health.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_sleep_session_entity.dart';

class HealthConnectSleepDataSource {
  static const _sleepTypes = [HealthDataType.SLEEP_SESSION];
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
      _sleepTypes,
      permissions: _permissions,
    );
    return hasPermissions ?? false;
  }

  Future<bool> requestReadPermission() {
    return _health.requestAuthorization(
      _sleepTypes,
      permissions: _permissions,
    );
  }

  Future<List<HealthSleepSessionEntity>> readSleepSessions(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final points = await _health.getHealthDataFromTypes(
      startTime: startTime,
      endTime: endTime,
      types: _sleepTypes,
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
}
