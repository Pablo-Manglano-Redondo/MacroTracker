import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientNotesDataSource {
  final SupabaseClient _supabaseClient;
  final SupabaseIdentityService _identityService;

  ClientNotesDataSource(this._supabaseClient, this._identityService);

  Future<List<Map<String, dynamic>>> fetchNotes({
    required String professionalClientId,
    required String clientId,
  }) async {
    await _identityService.ensureUserSession();
    final response = await _supabaseClient
        .from('client_notes')
        .select('id, title, body, category, pinned, created_at, updated_at')
        .eq('professional_client_id', professionalClientId)
        .order('pinned', ascending: false)
        .order('created_at', ascending: false);
    return (response as List).map((r) => Map<String, dynamic>.from(r)).toList();
  }
}
