import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';

part 'daily_habit_log_dbo.g.dart';

@HiveType(typeId: 25)
@JsonSerializable()
class DailyHabitLogDBO extends HiveObject {
  @HiveField(0)
  DateTime day;

  @HiveField(1)
  bool creatineTaken;

  @HiveField(2)
  bool wheyTaken;

  @HiveField(3)
  bool caffeineTaken;

  @HiveField(4)
  double waterLiters;

  @HiveField(5)
  double sleepHours;

  @HiveField(6)
  int steps;

  @HiveField(7)
  int energyLevel;

  DailyHabitLogDBO({
    required this.day,
    this.creatineTaken = false,
    this.wheyTaken = false,
    this.caffeineTaken = false,
    this.waterLiters = 0,
    this.sleepHours = 0,
    this.steps = 0,
    this.energyLevel = 0,
  });

  factory DailyHabitLogDBO.fromEntity(DailyHabitLogEntity entity) {
    return DailyHabitLogDBO(
      day: entity.day,
      creatineTaken: entity.creatineTaken,
      wheyTaken: entity.wheyTaken,
      caffeineTaken: entity.caffeineTaken,
      waterLiters: entity.waterLiters,
      sleepHours: entity.sleepHours,
      steps: entity.steps,
      energyLevel: entity.energyLevel,
    );
  }

  factory DailyHabitLogDBO.fromJson(Map<String, dynamic> json) =>
      _$DailyHabitLogDBOFromJson(json);

  Map<String, dynamic> toJson() => _$DailyHabitLogDBOToJson(this);
}
