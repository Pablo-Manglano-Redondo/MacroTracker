import 'dart:typed_data';

import 'package:macrotracker/features/meal_capture/data/data_sources/meal_interpretation_remote_data_source.dart';
import 'package:macrotracker/features/meal_capture/data/repository/interpretation_draft_repository.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';

class MealInterpretationRepository {
  final MealInterpretationRemoteDataSource _remoteDataSource;
  final InterpretationDraftRepository _draftRepository;

  MealInterpretationRepository(this._remoteDataSource, this._draftRepository);

  Future<InterpretationDraftEntity> interpretText({
    required String text,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
  }) async {
    final draft = await _remoteDataSource.interpretText(
      text: text,
      locale: locale,
      unitSystem: unitSystem,
      mealTypeHint: mealTypeHint,
    );
    await _draftRepository.saveDraft(draft);
    return draft;
  }

  Future<InterpretationDraftEntity> interpretPhoto({
    required Uint8List imageBytes,
    required String fileName,
    required String mimeType,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
  }) async {
    final draft = await _remoteDataSource.interpretPhoto(
      imageBytes: imageBytes,
      fileName: fileName,
      mimeType: mimeType,
      locale: locale,
      unitSystem: unitSystem,
      mealTypeHint: mealTypeHint,
    );
    await _draftRepository.saveDraft(draft);
    return draft;
  }
}
