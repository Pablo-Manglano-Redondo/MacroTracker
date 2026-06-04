import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CloudAccountService {
  static const authRedirectUrl = 'macrotracker://login-callback';

  final SupabaseClient _client;
  final SupabaseIdentityService _identityService;

  CloudAccountService(this._client, this._identityService);

  Future<CloudAccountStatus> getStatus() async {
    final userId = await _identityService.ensureUserSession();
    final user = _client.auth.currentUser;
    return CloudAccountStatus(
      userId: user?.id ?? userId,
      email: user?.email,
      isProtected: user != null && !user.isAnonymous,
      providerCount: user?.identities?.length ?? 0,
    );
  }

  Future<bool> protectWithGoogle() async {
    await _identityService.ensureUserSession();
    return _client.auth.linkIdentity(
      OAuthProvider.google,
      redirectTo: authRedirectUrl,
    );
  }
}

class CloudAccountStatus {
  final String userId;
  final String? email;
  final bool isProtected;
  final int providerCount;

  const CloudAccountStatus({
    required this.userId,
    required this.email,
    required this.isProtected,
    required this.providerCount,
  });
}
