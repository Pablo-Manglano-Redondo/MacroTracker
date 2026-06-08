import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';

class GetProfessionalMessagesUsecase {
  final ProfessionalPlanRepository _repository;

  GetProfessionalMessagesUsecase(this._repository);

  Future<ProfessionalMessageThreadEntity> execute({
    required ProfessionalConnectionEntity connection,
  }) {
    return _repository.getMessages(connection: connection);
  }
}
