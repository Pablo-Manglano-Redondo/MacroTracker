part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}

class HomeLoadingState extends HomeState {
  @override
  List<Object?> get props => [];
}

class HomeLoadedState extends HomeState {
  final bool showDisclaimerDialog;
  final UserWeightGoalEntity nutritionPhase;
  final DailyFocusEntity dailyFocus;
  final double totalKcalDaily;
  final double totalKcalLeft;
  final double totalKcalSupplied;
  final double totalKcalBurned;
  final double totalCarbsIntake;
  final double totalFatsIntake;
  final double totalProteinsIntake;
  final double totalCarbsGoal;
  final double totalFatsGoal;
  final double totalProteinsGoal;
  final double dailyFoodQualityScore;
  final FoodQualityBandEntity dailyFoodQualityBand;
  final int dailyFoodQualityMealsCount;
  final List<UserActivityEntity> userActivityList;
  final List<IntakeEntity> breakfastIntakeList;
  final List<IntakeEntity> lunchIntakeList;
  final List<IntakeEntity> dinnerIntakeList;
  final List<IntakeEntity> snackIntakeList;
  final bool usesImperialUnits;
  final int? targetSteps;
  final double? targetSleepHours;
  final double? targetWaterLiters;
  final ProfessionalConnectionEntity? activeConnection;

  const HomeLoadedState({
    required this.showDisclaimerDialog,
    required this.nutritionPhase,
    required this.dailyFocus,
    required this.totalKcalDaily,
    required this.totalKcalLeft,
    required this.totalKcalSupplied,
    required this.totalKcalBurned,
    required this.totalCarbsIntake,
    required this.totalFatsIntake,
    required this.totalProteinsIntake,
    required this.totalCarbsGoal,
    required this.totalFatsGoal,
    required this.totalProteinsGoal,
    required this.dailyFoodQualityScore,
    required this.dailyFoodQualityBand,
    required this.dailyFoodQualityMealsCount,
    required this.userActivityList,
    required this.breakfastIntakeList,
    required this.lunchIntakeList,
    required this.dinnerIntakeList,
    required this.snackIntakeList,
    required this.usesImperialUnits,
    this.targetSteps,
    this.targetSleepHours,
    this.targetWaterLiters,
    this.activeConnection,
  });

  @override
  List<Object?> get props => [
        showDisclaimerDialog,
        nutritionPhase,
        dailyFocus,
        totalKcalDaily,
        totalKcalLeft,
        totalKcalSupplied,
        totalKcalBurned,
        totalCarbsIntake,
        totalFatsIntake,
        totalProteinsIntake,
        totalCarbsGoal,
        totalFatsGoal,
        totalProteinsGoal,
        dailyFoodQualityScore,
        dailyFoodQualityBand,
        dailyFoodQualityMealsCount,
        breakfastIntakeList,
        lunchIntakeList,
        dinnerIntakeList,
        snackIntakeList,
        userActivityList,
        usesImperialUnits,
        targetSteps,
        targetSleepHours,
        targetWaterLiters,
        activeConnection,
      ];
}
