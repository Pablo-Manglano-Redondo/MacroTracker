import 'package:macrotracker/features/daily_habits/data/repository/daily_habit_log_repository.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';

class GetDailyHabitLogUsecase {
  final DailyHabitLogRepository _dailyHabitLogRepository;

  GetDailyHabitLogUsecase(this._dailyHabitLogRepository);

  Future<DailyHabitLogEntity> getForDay(DateTime day) async {
    return await _dailyHabitLogRepository.getLog(day) ??
        DailyHabitLogEntity.empty(day);
  }

  Future<DailyHabitLogEntity> getToday() async {
    return getForDay(DateTime.now());
  }
}
