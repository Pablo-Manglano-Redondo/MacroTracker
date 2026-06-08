import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';

class GetProfessionalUnseenSectionCountUsecase {
  final ProfessionalPlanRepository _repository;

  GetProfessionalUnseenSectionCountUsecase(this._repository);

  Future<int> execute() {
    return _repository.getUnseenSectionCount();
  }
}
