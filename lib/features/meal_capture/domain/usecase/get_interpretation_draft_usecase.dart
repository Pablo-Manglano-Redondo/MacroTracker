import 'package:opennutritracker/features/meal_capture/data/repository/interpretation_draft_repository.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';

class GetInterpretationDraftUsecase {
  final InterpretationDraftRepository _draftRepository;

  GetInterpretationDraftUsecase(this._draftRepository);

  Future<InterpretationDraftEntity?> getDraftById(String draftId) async {
    return _draftRepository.getDraftById(draftId);
  }

  Future<List<InterpretationDraftEntity>> getAllDrafts() async {
    return _draftRepository.getAllDrafts();
  }
}
