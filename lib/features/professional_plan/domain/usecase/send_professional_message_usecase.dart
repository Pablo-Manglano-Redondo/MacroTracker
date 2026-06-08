import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';

class SendProfessionalMessageUsecase {
  final ProfessionalPlanRepository _repository;

  SendProfessionalMessageUsecase(this._repository);

  Future<ProfessionalMessageEntity> execute({
    required ProfessionalConnectionEntity connection,
    required String body,
  }) {
    return _repository.sendMessage(
      connection: connection,
      body: body,
    );
  }
}
