import 'package:macrotracker/features/professional_plan/data/repository/checkin_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

class SubmitCheckinUsecase {
  final CheckinRepository _repository;

  SubmitCheckinUsecase(this._repository);

  Future<void> execute({
    required ProfessionalConnectionEntity connection,
    String? requestId,
    String? templateId,
    Map<String, dynamic> answers = const {},
    int? energyLevel,
    double? sleepHours,
    String? mood,
    String? notes,
  }) {
    return _repository.submitCheckin(
      professionalClientId: connection.relationshipId,
      professionalId: connection.professionalId,
      clientId: connection.clientId,
      requestId: requestId,
      templateId: templateId,
      answers: answers,
      energyLevel: energyLevel,
      sleepHours: sleepHours,
      mood: mood,
      notes: notes,
    );
  }
}
