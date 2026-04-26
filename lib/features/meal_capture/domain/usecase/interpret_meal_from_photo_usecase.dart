import 'dart:typed_data';

import 'package:macrotracker/features/meal_capture/data/repository/meal_interpretation_repository.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';

class InterpretMealFromPhotoUsecase {
  final MealInterpretationRepository _repository;

  InterpretMealFromPhotoUsecase(this._repository);

  Future<InterpretationDraftEntity> interpret({
    required Uint8List imageBytes,
    required String fileName,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
  }) async {
    return _repository.interpretPhoto(
      imageBytes: imageBytes,
      fileName: fileName,
      locale: locale,
      unitSystem: unitSystem,
      mealTypeHint: mealTypeHint,
    );
  }
}
