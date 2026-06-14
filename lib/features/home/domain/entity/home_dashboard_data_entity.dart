import 'package:equatable/equatable.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/food_quality_score_entity.dart';
import 'package:macrotracker/core/domain/entity/gym_targets_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/user_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

class HomeDashboardDataEntity extends Equatable {
  final ConfigEntity config;
  final UserEntity user;
  final List<IntakeEntity> breakfastIntakeList;
  final List<IntakeEntity> lunchIntakeList;
  final List<IntakeEntity> dinnerIntakeList;
  final List<IntakeEntity> snackIntakeList;
  final List<UserActivityEntity> userActivities;
  final FoodQualityDailySummaryEntity foodQualitySummary;
  final GymTargetsEntity targets;
  final ProfessionalConnectionEntity? professionalConnection;
  final double totalKcalIntake;
  final double totalCarbsIntake;
  final double totalFatsIntake;
  final double totalProteinsIntake;
  final double totalKcalActivities;

  const HomeDashboardDataEntity({
    required this.config,
    required this.user,
    required this.breakfastIntakeList,
    required this.lunchIntakeList,
    required this.dinnerIntakeList,
    required this.snackIntakeList,
    required this.userActivities,
    required this.foodQualitySummary,
    required this.targets,
    required this.professionalConnection,
    required this.totalKcalIntake,
    required this.totalCarbsIntake,
    required this.totalFatsIntake,
    required this.totalProteinsIntake,
    required this.totalKcalActivities,
  });

  @override
  List<Object?> get props => [
        config,
        user,
        breakfastIntakeList,
        lunchIntakeList,
        dinnerIntakeList,
        snackIntakeList,
        userActivities,
        foodQualitySummary,
        targets,
        professionalConnection,
        totalKcalIntake,
        totalCarbsIntake,
        totalFatsIntake,
        totalProteinsIntake,
        totalKcalActivities,
      ];
}
