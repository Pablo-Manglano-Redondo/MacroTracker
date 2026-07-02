import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckinDataSource {
  final SupabaseClient _supabaseClient;
  final SupabaseIdentityService _identityService;

  CheckinDataSource(this._supabaseClient, this._identityService);

  Future<Map<String, dynamic>?> fetchDefaultTemplate({
    required String professionalId,
  }) async {
    await _identityService.ensureUserSession();
    final response = await _supabaseClient
        .from('checkin_templates')
        .select('id, title, questions')
        .eq('professional_id', professionalId)
        .eq('is_default', true)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return Map<String, dynamic>.from(response);
  }

  Future<void> submitCheckin({
    required String professionalClientId,
    required String professionalId,
    required String clientId,
    String? requestId,
    String? templateId,
    Map<String, dynamic> answers = const {},
    int? energyLevel,
    double? sleepHours,
    String? mood,
    String? notes,
  }) async {
    await _identityService.ensureUserSession();
    await _supabaseClient.from('client_checkins').insert({
      'professional_client_id': professionalClientId,
      'professional_id': professionalId,
      'client_id': clientId,
      if (requestId != null) 'request_id': requestId,
      if (templateId != null) 'template_id': templateId,
      'answers': answers,
      if (energyLevel != null) 'energy_level': energyLevel,
      if (sleepHours != null) 'sleep_avg': sleepHours,
      if (mood != null) 'mood': mood,
      if (notes != null) 'notes': notes,
    });
  }
}
