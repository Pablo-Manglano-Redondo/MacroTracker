import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseIdentityService {
  final SupabaseClient _client;

  SupabaseIdentityService(this._client);

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<String> ensureUserSession() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser != null) {
      return currentUser.id;
    }

    final response = await _client.auth.signInAnonymously();
    final user = response.user;
    if (user == null) {
      throw StateError(
        'Supabase anonymous auth did not return a user. Enable anonymous sign-ins in Supabase Auth.',
      );
    }
    return user.id;
  }
}
