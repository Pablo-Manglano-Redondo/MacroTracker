import 'package:macrotracker/features/meal_capture/data/repository/meal_interpretation_repository.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';

class InterpretMealFromTextUsecase {
  final MealInterpretationRepository _repository;

  InterpretMealFromTextUsecase(this._repository);

  Future<InterpretationDraftEntity> interpret({
    required String text,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
    String? analysisContext,
    List<Map<String, dynamic>> personalExamples = const [],
  }) async {
    return _repository.interpretText(
      text: text,
      locale: locale,
      unitSystem: unitSystem,
      mealTypeHint: mealTypeHint,
      analysisContext: analysisContext,
      personalExamples: personalExamples,
    );
  }
}
