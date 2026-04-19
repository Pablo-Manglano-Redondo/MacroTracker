import 'package:opennutritracker/features/meal_capture/data/repository/meal_interpretation_repository.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';

class InterpretMealFromTextUsecase {
  final MealInterpretationRepository _repository;

  InterpretMealFromTextUsecase(this._repository);

  Future<InterpretationDraftEntity> interpret({
    required String text,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
  }) async {
    return _repository.interpretText(
      text: text,
      locale: locale,
      unitSystem: unitSystem,
      mealTypeHint: mealTypeHint,
    );
  }
}
