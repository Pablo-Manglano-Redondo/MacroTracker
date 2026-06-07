import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';

class ProcessPendingSyncsUsecase {
  final ProfessionalPlanRepository _repository;

  ProcessPendingSyncsUsecase(this._repository);

  Future<void> execute() {
    return _repository.processPendingSyncs();
  }
}
