import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

class MarkProfessionalSectionSeenUsecase {
  final ProfessionalPlanRepository _repository;

  MarkProfessionalSectionSeenUsecase(this._repository);

  Future<void> execute({
    required ProfessionalConnectionEntity connection,
  }) {
    return _repository.markSectionSeen(connection: connection);
  }
}
