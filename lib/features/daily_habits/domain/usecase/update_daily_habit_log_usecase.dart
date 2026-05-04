import 'package:macrotracker/features/daily_habits/data/repository/daily_habit_log_repository.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';

class UpdateDailyHabitLogUsecase {
  final DailyHabitLogRepository _dailyHabitLogRepository;

  UpdateDailyHabitLogUsecase(this._dailyHabitLogRepository);

  Future<DailyHabitLogEntity> saveForDay({
    required DateTime day,
    bool? creatineTaken,
    bool? wheyTaken,
    bool? caffeineTaken,
    double? waterLiters,
    double? sleepHours,
    int? steps,
    int? energyLevel,
    bool? sleepSyncedFromHealthConnect,
    bool? stepsSyncedFromHealthConnect,
  }) async {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final existing = await _dailyHabitLogRepository.getLog(normalizedDay) ??
        DailyHabitLogEntity.empty(normalizedDay);
    final updated = existing.copyWith(
      day: normalizedDay,
      creatineTaken: creatineTaken,
      wheyTaken: wheyTaken,
      caffeineTaken: caffeineTaken,
      waterLiters: waterLiters?.clamp(0.0, 8.0).toDouble(),
      sleepHours: sleepHours?.clamp(0.0, 16.0).toDouble(),
      steps: steps?.clamp(0, 50000),
      energyLevel: energyLevel?.clamp(0, 5),
      sleepSyncedFromHealthConnect: sleepSyncedFromHealthConnect,
      stepsSyncedFromHealthConnect: stepsSyncedFromHealthConnect,
    );
    await _dailyHabitLogRepository.saveLog(updated);
    return updated;
  }

  Future<DailyHabitLogEntity> adjustWater({
    required DateTime day,
    required double deltaLiters,
  }) async {
    final current = await saveForDay(day: day);
    final nextWater = (current.waterLiters + deltaLiters).clamp(0.0, 8.0);
    return saveForDay(day: day, waterLiters: nextWater.toDouble());
  }

  Future<DailyHabitLogEntity> adjustSleep({
    required DateTime day,
    required double deltaHours,
  }) async {
    final current = await saveForDay(day: day);
    final nextSleep = (current.sleepHours + deltaHours).clamp(0.0, 16.0);
    return saveForDay(
      day: day,
      sleepHours: nextSleep.toDouble(),
      sleepSyncedFromHealthConnect: false,
    );
  }

  Future<DailyHabitLogEntity> adjustSteps({
    required DateTime day,
    required int deltaSteps,
  }) async {
    final current = await saveForDay(day: day);
    final nextSteps = (current.steps + deltaSteps).clamp(0, 50000);
    return saveForDay(
      day: day,
      steps: nextSteps,
      stepsSyncedFromHealthConnect: false,
    );
  }
}
