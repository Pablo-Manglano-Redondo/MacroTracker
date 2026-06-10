import 'package:macrotracker/features/professional_plan/data/data_source/client_notes_data_source.dart';

class ClientNotesRepository {
  final ClientNotesDataSource _dataSource;

  ClientNotesRepository(this._dataSource);

  Future<List<Map<String, dynamic>>> fetchNotes({
    required String professionalClientId,
    required String clientId,
  }) {
    return _dataSource.fetchNotes(
      professionalClientId: professionalClientId,
      clientId: clientId,
    );
  }
}
