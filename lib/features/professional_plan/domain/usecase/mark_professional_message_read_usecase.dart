import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

class MarkProfessionalMessageReadUsecase {
  final ProfessionalPlanRepository _repository;

  MarkProfessionalMessageReadUsecase(this._repository);

  Future<void> execute({
    required ProfessionalConnectionEntity connection,
    required String messageId,
  }) {
    return _repository.markMessageRead(
      connection: connection,
      messageId: messageId,
    );
  }
}
