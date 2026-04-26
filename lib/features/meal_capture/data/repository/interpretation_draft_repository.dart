import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/meal_capture/data/data_source/interpretation_draft_data_source.dart';
import 'package:macrotracker/features/meal_capture/data/dbo/interpretation_draft_dbo.dart';
import 'package:macrotracker/features/meal_capture/data/dbo/interpretation_draft_item_dbo.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';

class InterpretationDraftRepository {
  final InterpretationDraftDataSource _draftDataSource;

  InterpretationDraftRepository(this._draftDataSource);

  Future<void> saveDraft(InterpretationDraftEntity draftEntity) async {
    await _draftDataSource.saveDraft(InterpretationDraftDBO.fromEntity(draftEntity));
  }

  Future<InterpretationDraftEntity?> getDraftById(String draftId) async {
    final result = await _draftDataSource.getDraftById(draftId);
    return result == null ? null : _mapDraft(result);
  }

  Future<List<InterpretationDraftEntity>> getAllDrafts() async {
    final drafts = await _draftDataSource.getAllDrafts();
    return drafts.map(_mapDraft).toList();
  }

  Future<void> deleteDraft(String draftId) async {
    await _draftDataSource.deleteDraft(draftId);
  }

  Future<void> deleteExpiredDrafts(DateTime now) async {
    await _draftDataSource.deleteExpiredDrafts(now);
  }

  InterpretationDraftEntity _mapDraft(InterpretationDraftDBO draftDBO) {
    return InterpretationDraftEntity(
      id: draftDBO.id,
      sourceType: _mapSource(draftDBO.sourceType),
      inputText: draftDBO.inputText,
      localImagePath: draftDBO.localImagePath,
      title: draftDBO.title,
      summary: draftDBO.summary,
      totalKcal: draftDBO.totalKcal,
      totalCarbs: draftDBO.totalCarbs,
      totalFat: draftDBO.totalFat,
      totalProtein: draftDBO.totalProtein,
      confidenceBand: _mapConfidence(draftDBO.confidenceBand),
      status: _mapStatus(draftDBO.status),
      createdAt: draftDBO.createdAt,
      expiresAt: draftDBO.expiresAt,
      items: draftDBO.items.map(_mapItem).toList(),
    );
  }

  InterpretationDraftItemEntity _mapItem(InterpretationDraftItemDBO itemDBO) {
    return InterpretationDraftItemEntity(
      id: itemDBO.id,
      label: itemDBO.label,
      matchedMealSnapshot: itemDBO.matchedMealSnapshot == null
          ? null
          : MealEntity.fromMealDBO(itemDBO.matchedMealSnapshot!),
      amount: itemDBO.amount,
      unit: itemDBO.unit,
      kcal: itemDBO.kcal,
      carbs: itemDBO.carbs,
      fat: itemDBO.fat,
      protein: itemDBO.protein,
      confidenceBand: _mapConfidence(itemDBO.confidenceBand),
      editable: itemDBO.editable,
      removed: itemDBO.removed,
    );
  }

  ConfidenceBandEntity _mapConfidence(ConfidenceBandDBO dbo) {
    switch (dbo) {
      case ConfidenceBandDBO.low:
        return ConfidenceBandEntity.low;
      case ConfidenceBandDBO.medium:
        return ConfidenceBandEntity.medium;
      case ConfidenceBandDBO.high:
        return ConfidenceBandEntity.high;
    }
  }

  DraftSourceEntity _mapSource(DraftSourceDBO dbo) {
    switch (dbo) {
      case DraftSourceDBO.text:
        return DraftSourceEntity.text;
      case DraftSourceDBO.photo:
        return DraftSourceEntity.photo;
    }
  }

  DraftStatusEntity _mapStatus(DraftStatusDBO dbo) {
    switch (dbo) {
      case DraftStatusDBO.pending:
        return DraftStatusEntity.pending;
      case DraftStatusDBO.ready:
        return DraftStatusEntity.ready;
      case DraftStatusDBO.failed:
        return DraftStatusEntity.failed;
      case DraftStatusDBO.expired:
        return DraftStatusEntity.expired;
    }
  }
}
