import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/core/utils/meal_aggregate_factory.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';

class LogRecipeUsecase {
  final AddIntakeUsecase _addIntakeUsecase;
  final AddTrackedDayUsecase _addTrackedDayUsecase;
  final GetGymTargetsUsecase _getGymTargetsUsecase;

  LogRecipeUsecase(
    this._addIntakeUsecase,
    this._addTrackedDayUsecase,
    this._getGymTargetsUsecase,
  );

  Future<void> logRecipe(
    RecipeEntity recipe,
    double servings,
    IntakeTypeEntity intakeType,
    DateTime day,
  ) async {
    final meal = MealAggregateFactory.fromRecipe(recipe);
    final intake = IntakeEntity(
      id: IdGenerator.getUniqueID(),
      unit: 'serving',
      amount: servings,
      type: intakeType,
      meal: meal,
      dateTime: day,
    );

    await _addIntakeUsecase.addIntake(intake);
    await _updateTrackedDay(intake, day);
  }

  Future<void> _updateTrackedDay(IntakeEntity intake, DateTime day) async {
    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(day);
    if (!hasTrackedDay) {
      final targets = await _getGymTargetsUsecase.getTargetsForDay(day);

      await _addTrackedDayUsecase.addNewTrackedDay(
        day,
        targets.kcalGoal,
        targets.carbsGoal,
        targets.fatGoal,
        targets.proteinGoal,
      );
    }

    await _addTrackedDayUsecase.addDayCaloriesTracked(day, intake.totalKcal);
    await _addTrackedDayUsecase.addDayMacrosTracked(day,
        carbsTracked: intake.totalCarbsGram,
        fatTracked: intake.totalFatsGram,
        proteinTracked: intake.totalProteinsGram);
  }
}
