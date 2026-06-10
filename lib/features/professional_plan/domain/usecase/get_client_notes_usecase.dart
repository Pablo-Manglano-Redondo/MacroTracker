import 'package:macrotracker/features/professional_plan/data/repository/client_notes_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';

class GetClientNotesUsecase {
  final ClientNotesRepository _repository;

  GetClientNotesUsecase(this._repository);

  Future<List<Map<String, dynamic>>> execute(ProfessionalConnectionEntity connection) {
    return _repository.fetchNotes(
      professionalClientId: connection.relationshipId,
      clientId: connection.clientId,
    );
  }
}
