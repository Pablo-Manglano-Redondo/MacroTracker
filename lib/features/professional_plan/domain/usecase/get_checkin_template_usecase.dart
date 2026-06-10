import 'package:macrotracker/features/professional_plan/data/repository/checkin_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/checkin_template_entity.dart';

class GetCheckinTemplateUsecase {
  final CheckinRepository _repository;

  GetCheckinTemplateUsecase(this._repository);

  Future<CheckinTemplateEntity?> execute({required String professionalId}) {
    return _repository.fetchDefaultTemplate(professionalId: professionalId);
  }
}
