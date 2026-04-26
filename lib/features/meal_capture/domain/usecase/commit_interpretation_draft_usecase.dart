import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/core/utils/meal_aggregate_factory.dart';
import 'package:macrotracker/features/meal_capture/data/repository/interpretation_draft_repository.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';

class CommitInterpretationDraftUsecase {
  final InterpretationDraftRepository _draftRepository;
  final AddIntakeUsecase _addIntakeUsecase;
  final AddTrackedDayUsecase _addTrackedDayUsecase;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;

  CommitInterpretationDraftUsecase(
    this._draftRepository,
    this._addIntakeUsecase,
    this._addTrackedDayUsecase,
    this._getKcalGoalUsecase,
    this._getMacroGoalUsecase,
  );

  Future<InterpretationDraftEntity?> getDraftById(String draftId) async {
    return _draftRepository.getDraftById(draftId);
  }

  Future<void> commitDraft(
      InterpretationDraftEntity draft,
      IntakeTypeEntity intakeType,
      DateTime day,
      {double servings = 1}) async {
    final meal = MealAggregateFactory.fromInterpretationDraft(draft);
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
    await _draftRepository.deleteDraft(draft.id);
  }

  Future<void> _updateTrackedDay(IntakeEntity intake, DateTime day) async {
    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(day);
    if (!hasTrackedDay) {
      final totalKcalGoal = await _getKcalGoalUsecase.getKcalGoal();
      final totalCarbsGoal =
          await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
      final totalFatGoal =
          await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
      final totalProteinGoal =
          await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);

      await _addTrackedDayUsecase.addNewTrackedDay(
          day, totalKcalGoal, totalCarbsGoal, totalFatGoal, totalProteinGoal);
    }

    await _addTrackedDayUsecase.addDayCaloriesTracked(day, intake.totalKcal);
    await _addTrackedDayUsecase.addDayMacrosTracked(day,
        carbsTracked: intake.totalCarbsGram,
        fatTracked: intake.totalFatsGram,
        proteinTracked: intake.totalProteinsGram);
  }
}
