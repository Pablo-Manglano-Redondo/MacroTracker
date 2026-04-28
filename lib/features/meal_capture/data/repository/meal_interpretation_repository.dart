import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'dart:typed_data';

import 'package:macrotracker/features/meal_capture/data/data_sources/meal_interpretation_remote_data_source.dart';
import 'package:macrotracker/features/meal_capture/data/repository/interpretation_draft_repository.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';

class MealInterpretationRepository {
  final MealInterpretationRemoteDataSource _remoteDataSource;
  final InterpretationDraftRepository _draftRepository;
  final ConfigRepository _configRepository;

  MealInterpretationRepository(
      this._remoteDataSource, this._draftRepository, this._configRepository);

  Future<InterpretationDraftEntity> interpretText({
    required String text,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
  }) async {
    final result = await _remoteDataSource.interpretText(
      text: text,
      locale: locale,
      unitSystem: unitSystem,
      mealTypeHint: mealTypeHint,
    );
    await _configRepository.addAiEstimatedCost(
      isPhoto: false,
      usdCost: result.estimatedCostUsd,
    );
    final draft = result.draft;
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
    final result = await _remoteDataSource.interpretPhoto(
      imageBytes: imageBytes,
      fileName: fileName,
      mimeType: mimeType,
      locale: locale,
      unitSystem: unitSystem,
      mealTypeHint: mealTypeHint,
    );
    await _configRepository.addAiEstimatedCost(
      isPhoto: true,
      usdCost: result.estimatedCostUsd,
    );
    final draft = result.draft;
    await _draftRepository.saveDraft(draft);
    return draft;
  }
}
