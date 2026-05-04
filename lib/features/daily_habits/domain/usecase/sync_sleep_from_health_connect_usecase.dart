import 'dart:io';

import 'package:logging/logging.dart';
import 'package:macrotracker/features/daily_habits/data/data_source/health_connect_sleep_data_source.dart';
import 'package:macrotracker/features/daily_habits/data/repository/daily_habit_log_repository.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_sleep_session_entity.dart';

class SyncSleepFromHealthConnectUsecase {
  final _log = Logger('SyncSleepFromHealthConnectUsecase');

  final HealthConnectSleepDataSource _healthConnectSleepDataSource;
  final DailyHabitLogRepository _dailyHabitLogRepository;

  bool _authorizationRequestedThisLaunch = false;

  SyncSleepFromHealthConnectUsecase(
    this._healthConnectSleepDataSource,
    this._dailyHabitLogRepository,
  );

  Future<bool> syncToday() async {
    return syncDay(DateTime.now());
  }

  Future<bool> syncDay(DateTime day) async {
    if (!Platform.isAndroid) {
      return false;
    }

    final normalizedDay = DateTime(day.year, day.month, day.day);
    final dayEnd = normalizedDay.add(const Duration(days: 1));

    await _healthConnectSleepDataSource.configure();

    if (!await _healthConnectSleepDataSource.isAvailable()) {
      _log.fine('Health Connect is not available on this device');
      return false;
    }

    var hasPermission = await _healthConnectSleepDataSource.hasReadPermission();
    if (!hasPermission && !_authorizationRequestedThisLaunch) {
      _authorizationRequestedThisLaunch = true;
      hasPermission =
          await _healthConnectSleepDataSource.requestReadPermission();
    }

    if (!hasPermission) {
      _log.fine('Health Connect sleep permission not granted');
      return false;
    }

    final sessions = await _healthConnectSleepDataSource.readSleepSessions(
      normalizedDay.subtract(const Duration(days: 1)),
      dayEnd,
    );
    final selectedSession = _selectSessionForDay(normalizedDay, sessions);
    if (selectedSession == null) {
      _log.fine('No Health Connect sleep session found for $normalizedDay');
      return false;
    }

    final syncedSleepHours = _roundHours(selectedSession.duration);
    final currentLog = await _dailyHabitLogRepository.getLog(normalizedDay) ??
        DailyHabitLogEntity.empty(normalizedDay);

    if ((currentLog.sleepHours - syncedSleepHours).abs() < 0.01) {
      return false;
    }

    await _dailyHabitLogRepository.saveLog(
      currentLog.copyWith(
        day: normalizedDay,
        sleepHours: syncedSleepHours,
      ),
    );
    _log.info(
      'Synced $syncedSleepHours hours of sleep from Health Connect for $normalizedDay',
    );
    return true;
  }

  HealthSleepSessionEntity? _selectSessionForDay(
    DateTime normalizedDay,
    List<HealthSleepSessionEntity> sessions,
  ) {
    final dayEnd = normalizedDay.add(const Duration(days: 1));
    final sameDaySessions = sessions
        .where(
          (session) =>
              !session.endTime.isBefore(normalizedDay) &&
              session.endTime.isBefore(dayEnd) &&
              session.duration.inMinutes > 0,
        )
        .toList();

    if (sameDaySessions.isEmpty) {
      return null;
    }

    sameDaySessions.sort((left, right) {
      final byDuration = right.duration.compareTo(left.duration);
      if (byDuration != 0) {
        return byDuration;
      }
      return right.endTime.compareTo(left.endTime);
    });

    return sameDaySessions.first;
  }

  double _roundHours(Duration duration) {
    final hours = duration.inMinutes / 60;
    final normalizedHours = hours < 0
        ? 0.0
        : hours > 16
            ? 16.0
            : hours;
    return double.parse(normalizedHours.toStringAsFixed(1));
  }
}
