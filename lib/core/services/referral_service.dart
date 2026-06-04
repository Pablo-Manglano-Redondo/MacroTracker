import 'dart:math';

import 'package:logging/logging.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages the referral code lifecycle: creation, sharing, and redemption.
///
/// Each authenticated user gets a unique 6-character alphanumeric code stored
/// in Supabase. When another user redeems that code, both users earn rewards.
class ReferralService {
  final SupabaseClient _supabase;
  final SupabaseIdentityService _identityService;
  final MonetizationService _monetizationService;
  final ConversionAnalyticsService _analyticsService;
  final _log = Logger('ReferralService');

  ReferralService(
    this._supabase,
    this._identityService,
    this._monetizationService,
    this._analyticsService,
  );

  // ---------------------------------------------------------------------------
  // Get or create the current user's referral code
  // ---------------------------------------------------------------------------

  /// Returns the user's referral code. Creates one if it doesn't exist.
  /// Creates an anonymous Supabase session when the app has no cloud identity.
  Future<String?> getOrCreateReferralCode() async {
    // Check local cache first.
    final cached = _monetizationService.savedReferralCode;
    if (cached != null) return cached;

    try {
      final userId = await _identityService.ensureUserSession();

      // Try to fetch existing code from Supabase.
      final response = await _supabase
          .from('referral_codes')
          .select('code')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        final code = response['code'] as String;
        await _monetizationService.saveReferralCode(code);
        return code;
      }

      // Generate a new unique code.
      final newCode = _generateCode();
      await _supabase.from('referral_codes').insert({
        'user_id': userId,
        'code': newCode,
      });
      await _monetizationService.saveReferralCode(newCode);
      await _analyticsService.logReferralCodeCreated();
      return newCode;
    } catch (e) {
      _log.warning('Failed to get/create referral code', e);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Redeem a referral code
  // ---------------------------------------------------------------------------

  /// Redeems a referral code. Returns the result of the redemption.
  Future<ReferralRedemptionResult> redeemCode(String code) async {
    try {
      await _identityService.ensureUserSession();

      final response = await _supabase
          .rpc('redeem_referral_code', params: {'p_code': code});

      if (response is List && response.isNotEmpty) {
        // Grant share bonus to the redeemer.
        await _monetizationService.grantShareBonus();
        await _analyticsService.logReferralRedeemed();
        return ReferralRedemptionResult.success;
      }

      return ReferralRedemptionResult.unknownError;
    } on PostgrestException catch (e) {
      _log.warning('Referral redemption failed', e);
      if (e.message.contains('not found')) {
        return ReferralRedemptionResult.codeNotFound;
      }
      if (e.message.contains('own referral')) {
        return ReferralRedemptionResult.selfReferral;
      }
      if (e.message.contains('duplicate') ||
          e.message.contains('unique') ||
          e.code == '23505') {
        return ReferralRedemptionResult.alreadyRedeemed;
      }
      return ReferralRedemptionResult.unknownError;
    } catch (e) {
      _log.warning('Referral redemption failed', e);
      return ReferralRedemptionResult.unknownError;
    }
  }

  /// Checks if the current user has already redeemed any referral code.
  Future<bool> hasRedeemedAnyCode() async {
    try {
      final userId = await _identityService.ensureUserSession();

      final response = await _supabase
          .from('referral_redemptions')
          .select('id')
          .eq('redeemer_user_id', userId)
          .limit(1)
          .maybeSingle();
      return response != null;
    } catch (e) {
      _log.warning('Failed to check if user redeemed any code', e);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Check referral stats
  // ---------------------------------------------------------------------------

  /// Returns the number of people who have redeemed the current user's code.
  Future<int> getReferralCount() async {
    try {
      await _identityService.ensureUserSession();

      final count = await _supabase.rpc('get_referral_count');
      return (count as num?)?.toInt() ?? 0;
    } catch (e) {
      _log.warning('Failed to get referral count', e);
      return 0;
    }
  }

  /// Checks if anyone has redeemed our code and grants share bonus if so.
  Future<void> checkAndGrantShareBonus() async {
    if (_monetizationService.savedReferralCode == null) return;
    final state = await _monetizationService.getAiTrialState();
    if (state.hasShareBonus) return;

    final count = await getReferralCount();
    if (count > 0) {
      await _monetizationService.grantShareBonus();
      await _analyticsService.logShareBonusGranted();
    }
  }

  // ---------------------------------------------------------------------------
  // Share link
  // ---------------------------------------------------------------------------

  /// Build a shareable text message containing the referral code.
  String buildShareMessage(String code, {bool isEs = false}) {
    if (isEs) {
      return '¡Prueba MacroTracker! Registra comidas con IA en segundos. '
          'Usa mi código de invitación: $code '
          'y ambos obtenemos usos extra de IA gratis. '
          'https://macrotracker.app/referral?code=$code';
    }
    return 'Try MacroTracker! Log meals with AI in seconds. '
        'Use my referral code: $code '
        'and we both get extra free AI uses. '
        'https://macrotracker.app/referral?code=$code';
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No I/O/0/1 ambiguity
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}

enum ReferralRedemptionResult {
  success,
  codeNotFound,
  selfReferral,
  alreadyRedeemed,
  notAuthenticated,
  unknownError,
}
