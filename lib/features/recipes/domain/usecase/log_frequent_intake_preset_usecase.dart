import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/features/recipes/domain/entity/frequent_intake_preset_entity.dart';

class LogFrequentIntakePresetUsecase {
  final AddIntakeUsecase _addIntakeUsecase;
  final AddTrackedDayUsecase _addTrackedDayUsecase;
  final GetGymTargetsUsecase _getGymTargetsUsecase;

  LogFrequentIntakePresetUsecase(
    this._addIntakeUsecase,
    this._addTrackedDayUsecase,
    this._getGymTargetsUsecase,
  );

  Future<void> logPreset(
    FrequentIntakePresetEntity preset, {
    DateTime? day,
  }) async {
    final date = day ?? DateTime.now();
    final intake = IntakeEntity(
      id: IdGenerator.getUniqueID(),
      unit: preset.unit,
      amount: preset.amount,
      type: preset.intakeType,
      meal: preset.meal,
      dateTime: date,
    );

    await _addIntakeUsecase.addIntake(intake);

    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(date);
    if (!hasTrackedDay) {
      final targets = await _getGymTargetsUsecase.getTargetsForDay(date);
      await _addTrackedDayUsecase.addNewTrackedDay(
        date,
        targets.kcalGoal,
        targets.carbsGoal,
        targets.fatGoal,
        targets.proteinGoal,
      );
    }

    await _addTrackedDayUsecase.addDayCaloriesTracked(date, intake.totalKcal);
    await _addTrackedDayUsecase.addDayMacrosTracked(
      date,
      carbsTracked: intake.totalCarbsGram,
      fatTracked: intake.totalFatsGram,
      proteinTracked: intake.totalProteinsGram,
    );
  }
}
