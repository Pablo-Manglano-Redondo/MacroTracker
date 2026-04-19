import 'package:opennutritracker/features/meal_capture/data/repository/interpretation_draft_repository.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';

class SaveInterpretationDraftUsecase {
  final InterpretationDraftRepository _draftRepository;

  SaveInterpretationDraftUsecase(this._draftRepository);

  Future<void> saveDraft(InterpretationDraftEntity draftEntity) async {
    await _draftRepository.saveDraft(draftEntity);
  }
}
