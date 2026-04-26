import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/features/meal_capture/data/dbo/interpretation_draft_dbo.dart';

class InterpretationDraftDataSource {
  final _log = Logger('InterpretationDraftDataSource');
  final Box<InterpretationDraftDBO> _draftBox;

  InterpretationDraftDataSource(this._draftBox);

  Future<void> saveDraft(InterpretationDraftDBO draftDBO) async {
    _log.fine('Saving interpretation draft ${draftDBO.id}');
    await _draftBox.put(draftDBO.id, draftDBO);
  }

  Future<InterpretationDraftDBO?> getDraftById(String draftId) async {
    return _draftBox.get(draftId);
  }

  Future<List<InterpretationDraftDBO>> getAllDrafts() async {
    final drafts = _draftBox.values.toList();
    drafts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return drafts;
  }

  Future<void> deleteDraft(String draftId) async {
    await _draftBox.delete(draftId);
  }

  Future<void> deleteExpiredDrafts(DateTime now) async {
    final expired = _draftBox.values
        .where((draft) => draft.expiresAt.isBefore(now))
        .map((draft) => draft.id)
        .toList();

    if (expired.isNotEmpty) {
      await _draftBox.deleteAll(expired);
    }
  }
}
