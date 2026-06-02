import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

class AcceptProfessionalInviteUsecase {
  final ProfessionalPlanRepository _repository;

  AcceptProfessionalInviteUsecase(this._repository);

  Future<ProfessionalInvitePreviewEntity?> fetchInvitePreview(String code) {
    return _repository.fetchInvitePreview(code);
  }

  Future<ProfessionalConnectionEntity> acceptInvite(String code) {
    return _repository.acceptInvite(code);
  }
}
