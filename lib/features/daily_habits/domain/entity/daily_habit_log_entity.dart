import 'package:equatable/equatable.dart';
import 'package:macrotracker/features/daily_habits/data/dbo/daily_habit_log_dbo.dart';

class DailyHabitLogEntity extends Equatable {
  final DateTime day;
  final bool creatineTaken;
  final bool wheyTaken;
  final bool caffeineTaken;
  final double waterLiters;
  final double sleepHours;
  final int steps;
  final int energyLevel;

  const DailyHabitLogEntity({
    required this.day,
    this.creatineTaken = false,
    this.wheyTaken = false,
    this.caffeineTaken = false,
    this.waterLiters = 0,
    this.sleepHours = 0,
    this.steps = 0,
    this.energyLevel = 0,
  });

  factory DailyHabitLogEntity.empty(DateTime day) {
    return DailyHabitLogEntity(
      day: DateTime(day.year, day.month, day.day),
    );
  }

  factory DailyHabitLogEntity.fromDBO(DailyHabitLogDBO dbo) {
    return DailyHabitLogEntity(
      day: dbo.day,
      creatineTaken: dbo.creatineTaken,
      wheyTaken: dbo.wheyTaken,
      caffeineTaken: dbo.caffeineTaken,
      waterLiters: dbo.waterLiters,
      sleepHours: dbo.sleepHours,
      steps: dbo.steps,
      energyLevel: dbo.energyLevel,
    );
  }

  DailyHabitLogEntity copyWith({
    DateTime? day,
    bool? creatineTaken,
    bool? wheyTaken,
    bool? caffeineTaken,
    double? waterLiters,
    double? sleepHours,
    int? steps,
    int? energyLevel,
  }) {
    return DailyHabitLogEntity(
      day: day ?? this.day,
      creatineTaken: creatineTaken ?? this.creatineTaken,
      wheyTaken: wheyTaken ?? this.wheyTaken,
      caffeineTaken: caffeineTaken ?? this.caffeineTaken,
      waterLiters: waterLiters ?? this.waterLiters,
      sleepHours: sleepHours ?? this.sleepHours,
      steps: steps ?? this.steps,
      energyLevel: energyLevel ?? this.energyLevel,
    );
  }

  bool get hasAnyData =>
      creatineTaken ||
      wheyTaken ||
      caffeineTaken ||
      waterLiters > 0 ||
      sleepHours > 0 ||
      steps > 0 ||
      energyLevel > 0;

  bool meetsHydrationGoal(double hydrationGoalLiters) =>
      waterLiters >= hydrationGoalLiters;

  bool meetsSleepGoal(double sleepGoalHours) => sleepHours >= sleepGoalHours;

  bool meetsStepGoal(int stepGoal) => steps >= stepGoal;

  double hydrationProgress(double hydrationGoalLiters) {
    if (hydrationGoalLiters <= 0) {
      return 0;
    }
    return (waterLiters / hydrationGoalLiters).clamp(0.0, 1.0);
  }

  int completedCount({
    required double hydrationGoalLiters,
    required double sleepGoalHours,
    required int stepGoal,
  }) {
    var total = 0;
    if (creatineTaken) {
      total++;
    }
    if (wheyTaken) {
      total++;
    }
    if (caffeineTaken) {
      total++;
    }
    if (meetsHydrationGoal(hydrationGoalLiters)) {
      total++;
    }
    if (meetsSleepGoal(sleepGoalHours)) {
      total++;
    }
    if (meetsStepGoal(stepGoal)) {
      total++;
    }
    if (energyLevel > 0) {
      total++;
    }
    return total;
  }

  @override
  List<Object?> get props => [
        day,
        creatineTaken,
        wheyTaken,
        caffeineTaken,
        waterLiters,
        sleepHours,
        steps,
        energyLevel,
      ];
}
