import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';

class GetProfessionalSharingScopeUsecase {
  final ProfessionalPlanRepository _repository;

  GetProfessionalSharingScopeUsecase(this._repository);

  Future<ProfessionalSharingScopeEntity> execute({
    required ProfessionalConnectionEntity connection,
  }) {
    return _repository.getSharingScope(connection: connection);
  }
}
