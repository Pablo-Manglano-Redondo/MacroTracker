import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';

class DisconnectProfessionalUsecase {
  final ProfessionalPlanRepository _repository;

  DisconnectProfessionalUsecase(this._repository);

  Future<void> disconnect() => _repository.disconnect();
}
