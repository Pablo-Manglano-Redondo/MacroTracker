import 'dart:typed_data';

import 'package:macrotracker/features/meal_capture/data/repository/meal_interpretation_repository.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';

class InterpretMealFromPhotoUsecase {
  final MealInterpretationRepository _repository;

  InterpretMealFromPhotoUsecase(this._repository);

  Future<InterpretationDraftEntity> interpret({
    required Uint8List imageBytes,
    required String fileName,
    required String mimeType,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
    String? analysisContext,
    List<Map<String, dynamic>> personalExamples = const [],
  }) async {
    return _repository.interpretPhoto(
      imageBytes: imageBytes,
      fileName: fileName,
      mimeType: mimeType,
      locale: locale,
      unitSystem: unitSystem,
      mealTypeHint: mealTypeHint,
      analysisContext: analysisContext,
      personalExamples: personalExamples,
    );
  }
}
