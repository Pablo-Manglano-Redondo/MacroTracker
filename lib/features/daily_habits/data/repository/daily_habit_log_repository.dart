import 'package:macrotracker/features/daily_habits/data/data_source/daily_habit_log_data_source.dart';
import 'package:macrotracker/features/daily_habits/data/dbo/daily_habit_log_dbo.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';

class DailyHabitLogRepository {
  final DailyHabitLogDataSource _dailyHabitLogDataSource;

  DailyHabitLogRepository(this._dailyHabitLogDataSource);

  Future<void> saveLog(DailyHabitLogEntity log) async {
    await _dailyHabitLogDataSource.saveLog(DailyHabitLogDBO.fromEntity(log));
  }

  Future<DailyHabitLogEntity?> getLog(DateTime day) async {
    final dbo = await _dailyHabitLogDataSource.getLog(day);
    return dbo == null ? null : DailyHabitLogEntity.fromDBO(dbo);
  }

  Future<List<DailyHabitLogEntity>> getAllLogs() async {
    final dbos = await _dailyHabitLogDataSource.getAllLogs();
    return dbos.map(DailyHabitLogEntity.fromDBO).toList(growable: false);
  }

  Future<List<DailyHabitLogDBO>> getAllLogsDBO() async {
    return _dailyHabitLogDataSource.getAllLogs();
  }

  Future<void> addAllLogs(List<DailyHabitLogDBO> logs) async {
    await _dailyHabitLogDataSource.saveAllLogs(logs);
  }
}
