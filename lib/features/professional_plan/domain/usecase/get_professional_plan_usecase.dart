import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

class GetProfessionalPlanUsecase {
  final ProfessionalPlanRepository _repository;

  GetProfessionalPlanUsecase(this._repository);

  Future<ProfessionalConnectionEntity?> getActiveConnection({
    bool refreshRemotePlan = false,
  }) async {
    if (refreshRemotePlan) {
      try {
        return await _repository.refreshActivePlan();
      } catch (_) {
        return _repository.getActiveConnection();
      }
    }
    return _repository.getActiveConnection();
  }
}
