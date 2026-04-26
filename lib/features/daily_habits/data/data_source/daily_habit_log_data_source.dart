import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/utils/extensions.dart';
import 'package:macrotracker/features/daily_habits/data/dbo/daily_habit_log_dbo.dart';

class DailyHabitLogDataSource {
  final _log = Logger('DailyHabitLogDataSource');
  final Box<DailyHabitLogDBO> _dailyHabitLogBox;

  DailyHabitLogDataSource(this._dailyHabitLogBox);

  Future<void> saveLog(DailyHabitLogDBO log) async {
    _log.fine('Saving daily habits for ${log.day}');
    await _dailyHabitLogBox.put(log.day.toParsedDay(), log);
  }

  Future<DailyHabitLogDBO?> getLog(DateTime day) async {
    return _dailyHabitLogBox.get(day.toParsedDay());
  }

  Future<List<DailyHabitLogDBO>> getAllLogs() async {
    final values = _dailyHabitLogBox.values.toList();
    values.sort((a, b) => b.day.compareTo(a.day));
    return values;
  }

  Future<void> saveAllLogs(List<DailyHabitLogDBO> logs) async {
    await _dailyHabitLogBox.putAll({
      for (final log in logs) log.day.toParsedDay(): log,
    });
  }
}
