import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/subscription_service.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonetizationService {
  static const int freeAiTrialLimit = 5;
  // Small guest allowance is intentional; reinstall-based guest abuse is an
  // accepted v1 tradeoff while the remote profile remains the source of truth.
  static const int guestAiTrialLimit = 2;
  static const int bonusAiUses = 2;
  static const int shareBonusAiUses = 3;
  static const int estimatedMinutesSavedPerAiMeal = 4;

  /// Launch-period cutoff for the "Founding Member" badge.
  static final DateTime foundingMemberCutoff = DateTime(2026, 8, 3);

  static const _aiTrialUsesKey = 'ai_trial_uses';
  static const _aiMealsSavedKey = 'ai_meals_saved';
  static const _onboardingBonusGrantedKey = 'ai_bonus_onboarding_granted';
  static const _shareBonusGrantedKey = 'ai_bonus_share_granted';
  static const _foundingMemberAtKey = 'founding_member_activated_at';
  static const _referralCodeKey = 'referral_code';
  static const _profileOwnerKey = 'ai_trial_profile_owner_user_id';
  static const _aiTrialTable = 'ai_trial_state';

  final SubscriptionService _subscriptionService;
  final Box<dynamic> _box;
  final SupabaseIdentityService _identityService;
  final AiTrialProfileStore _profileStore;
  final ConversionAnalyticsService? _analyticsService;
  final _log = Logger('MonetizationService');

  MonetizationService(
    this._subscriptionService,
    this._box,
    this._identityService,
    SupabaseClient supabaseClient, {
    AiTrialProfileStore? profileStore,
    ConversionAnalyticsService? analyticsService,
  })  : _profileStore =
            profileStore ?? SupabaseAiTrialProfileStore(supabaseClient),
        _analyticsService = analyticsService;

  // ---------------------------------------------------------------------------
  // Trial state
  // ---------------------------------------------------------------------------

  Future<AiTrialState> getAiTrialState() async {
    final isPremium = await _subscriptionService.isPremiumActive();
    try {
      final userId = await _identityService.ensureUserSession();
      final isProtectedAccount = _isProtectedAccount();
      final profile = await _getOrCreateProfile(userId);
      return _buildTrialState(
        isPremium: isPremium,
        profile: profile,
        isProtectedAccount: isProtectedAccount,
      );
    } catch (error, stackTrace) {
      _log.warning(
        'Falling back to local AI trial state because cloud trial sync is unavailable.',
        error,
        stackTrace,
      );
      return _buildTrialState(
        isPremium: isPremium,
        profile: _localProfileFallback(),
        isProtectedAccount: _isProtectedAccount(),
      );
    }
  }

  int _effectiveLimit(_AiTrialProfile profile) {
    var limit = freeAiTrialLimit;
    if (profile.hasOnboardingBonus) limit += bonusAiUses;
    if (profile.hasShareBonus) limit += shareBonusAiUses;
    return limit;
  }

  AiTrialState _buildTrialState({
    required bool isPremium,
    required _AiTrialProfile profile,
    required bool isProtectedAccount,
  }) {
    final fullLimit = _effectiveLimit(profile);
    final effectiveLimit = isProtectedAccount
        ? fullLimit
        : (fullLimit > guestAiTrialLimit ? guestAiTrialLimit : fullLimit);
    final used = profile.used > effectiveLimit ? effectiveLimit : profile.used;
    return AiTrialState(
      isPremium: isPremium,
      used: used,
      limit: effectiveLimit,
      fullLimit: fullLimit,
      aiMealsSaved: profile.aiMealsSaved < 0 ? 0 : profile.aiMealsSaved,
      hasOnboardingBonus: profile.hasOnboardingBonus,
      hasShareBonus: profile.hasShareBonus,
      isFoundingMember: profile.isFoundingMember,
      isProtectedAccount: isProtectedAccount,
    );
  }

  // ---------------------------------------------------------------------------
  // AI meal tracking
  // ---------------------------------------------------------------------------

  Future<void> recordAiMealSaved({required bool consumeTrialUse}) async {
    final userId = await _identityService.ensureUserSession();
    final profile = await _getOrCreateProfile(userId);
    final newMealsCount = profile.aiMealsSaved + 1;
    await _upsertProfile(profile.copyWith(aiMealsSaved: newMealsCount));

    if (newMealsCount == 1) {
      await _conversionAnalyticsService.logFirstAiMealCreated();
    }

    if (!consumeTrialUse) {
      return;
    }
    await consumeAiTrialUse();
  }

  Future<void> consumeAiTrialUse() async {
    final state = await getAiTrialState();
    if (state.isPremium || state.remaining <= 0) {
      return;
    }
    final userId = await _identityService.ensureUserSession();
    final profile = await _getOrCreateProfile(userId);
    await _upsertProfile(profile.copyWith(used: profile.used + 1));

    if (state.remaining == 1) {
      await _conversionAnalyticsService.logTrialExhausted(
        totalAiMealsSaved: profile.aiMealsSaved,
      );
    }
  }

  /// Returns `true` when this consume exhausted the last remaining trial use.
  Future<bool> consumeAiTrialUseAndCheckExhausted() async {
    final state = await getAiTrialState();
    if (state.isPremium || state.remaining <= 0) {
      return false;
    }
    final userId = await _identityService.ensureUserSession();
    final profile = await _getOrCreateProfile(userId);
    await _upsertProfile(profile.copyWith(used: profile.used + 1));
    final wasExhausted = state.remaining == 1; // was 1, now 0
    if (wasExhausted) {
      await _conversionAnalyticsService.logTrialExhausted(
        totalAiMealsSaved: profile.aiMealsSaved,
      );
    }
    return wasExhausted;
  }

  // ---------------------------------------------------------------------------
  // Bonuses
  // ---------------------------------------------------------------------------

  /// Grant +2 AI trial uses for completing onboarding. Idempotent.
  Future<void> grantOnboardingBonus() async {
    final userId = await _identityService.ensureUserSession();
    final profile = await _getOrCreateProfile(userId);
    if (profile.hasOnboardingBonus) return;
    await _upsertProfile(profile.copyWith(hasOnboardingBonus: true));
  }

  /// Grant +3 AI trial uses when a referral share is verified. Idempotent.
  Future<void> grantShareBonus() async {
    final userId = await _identityService.ensureUserSession();
    final profile = await _getOrCreateProfile(userId);
    if (profile.hasShareBonus) return;
    await _upsertProfile(profile.copyWith(hasShareBonus: true));
  }

  // ---------------------------------------------------------------------------
  // Founding Member
  // ---------------------------------------------------------------------------

  Future<void> markAsFoundingMember() async {
    final now = DateTime.now();
    if (!now.isBefore(foundingMemberCutoff)) {
      return;
    }
    final userId = await _identityService.ensureUserSession();
    final profile = await _getOrCreateProfile(userId);
    if (profile.isFoundingMember) return;
    await _upsertProfile(
      profile.copyWith(foundingMemberActivatedAt: now.toIso8601String()),
    );
  }

  // ---------------------------------------------------------------------------
  // Referral code
  // ---------------------------------------------------------------------------

  String? get savedReferralCode =>
      _box.get(_referralCodeKey) as String?;

  Future<void> saveReferralCode(String code) async {
    await _box.put(_referralCodeKey, code);
  }

  bool _isProtectedAccount() {
    final user = _identityService.currentUser;
    return user != null && !user.isAnonymous;
  }

  ConversionAnalyticsService get _conversionAnalyticsService =>
      _analyticsService ?? locator<ConversionAnalyticsService>();

  Future<_AiTrialProfile> _getOrCreateProfile(String userId) async {
    final existing = await _fetchProfile(userId);
    final profile = existing ?? _AiTrialProfile.empty(userId);
    final synced = await _syncLegacyLocalStateIfNeeded(userId, profile);
    if (existing == null) {
      return _upsertProfile(synced);
    }
    return synced;
  }

  Future<_AiTrialProfile?> _fetchProfile(String userId) async {
    final response = await _profileStore.fetchProfile(userId);
    if (response == null) {
      return null;
    }
    return _AiTrialProfile.fromMap(response);
  }

  Future<_AiTrialProfile> _upsertProfile(_AiTrialProfile profile) async {
    final response = await _profileStore.upsertProfile(profile.toMap());
    await _box.put(_profileOwnerKey, profile.userId);
    return _AiTrialProfile.fromMap(response);
  }

  Future<_AiTrialProfile> _syncLegacyLocalStateIfNeeded(
    String userId,
    _AiTrialProfile profile,
  ) async {
    final localUsed = (_box.get(_aiTrialUsesKey, defaultValue: 0) as num).toInt();
    final localMealsSaved =
        (_box.get(_aiMealsSavedKey, defaultValue: 0) as num).toInt();
    final localOnboardingBonus =
        _box.get(_onboardingBonusGrantedKey, defaultValue: false) == true;
    final localShareBonus =
        _box.get(_shareBonusGrantedKey, defaultValue: false) == true;
    final localFoundingMemberAt = _box.get(_foundingMemberAtKey) as String?;
    final hasLegacyState = localUsed > 0 ||
        localMealsSaved > 0 ||
        localOnboardingBonus ||
        localShareBonus ||
        localFoundingMemberAt != null;
    if (!hasLegacyState) {
      await _box.put(_profileOwnerKey, userId);
      return profile;
    }

    final legacyOwner = _box.get(_profileOwnerKey) as String?;
    if (legacyOwner != null && legacyOwner != userId) {
      _log.info(
        'Skipping legacy monetization migration for user $userId because local state belongs to $legacyOwner.',
      );
      return profile;
    }

    final merged = profile.copyWith(
      used: profile.used > localUsed ? profile.used : localUsed,
      aiMealsSaved: profile.aiMealsSaved > localMealsSaved
          ? profile.aiMealsSaved
          : localMealsSaved,
      hasOnboardingBonus:
          profile.hasOnboardingBonus || localOnboardingBonus,
      hasShareBonus: profile.hasShareBonus || localShareBonus,
      foundingMemberActivatedAt: profile.foundingMemberActivatedAt ??
          localFoundingMemberAt,
    );

    if (merged == profile) {
      await _box.put(_profileOwnerKey, userId);
      return profile;
    }
    return _upsertProfile(merged);
  }

  _AiTrialProfile _localProfileFallback() {
    final userId =
        _identityService.currentUserId ??
        (_box.get(_profileOwnerKey) as String?) ??
        'local-guest';
    return _AiTrialProfile(
      userId: userId,
      used: (_box.get(_aiTrialUsesKey, defaultValue: 0) as num).toInt(),
      aiMealsSaved: (_box.get(_aiMealsSavedKey, defaultValue: 0) as num).toInt(),
      hasOnboardingBonus:
          _box.get(_onboardingBonusGrantedKey, defaultValue: false) == true,
      hasShareBonus: _box.get(_shareBonusGrantedKey, defaultValue: false) == true,
      foundingMemberActivatedAt: _box.get(_foundingMemberAtKey) as String?,
    );
  }
}

class AiTrialState {
  final bool isPremium;
  final int used;
  final int limit;
  final int fullLimit;
  final int aiMealsSaved;
  final bool hasOnboardingBonus;
  final bool hasShareBonus;
  final bool isFoundingMember;
  final bool isProtectedAccount;

  const AiTrialState({
    required this.isPremium,
    required this.used,
    required this.limit,
    required this.fullLimit,
    required this.aiMealsSaved,
    this.hasOnboardingBonus = false,
    this.hasShareBonus = false,
    this.isFoundingMember = false,
    this.isProtectedAccount = false,
  });

  int get remaining => isPremium ? limit : (limit - used).clamp(0, limit);

  bool get canUseAi => isPremium || remaining > 0;

  bool get requiresProtectedAccount =>
      !isPremium && !isProtectedAccount && remaining <= 0 && fullLimit > limit;

  int get lockedFreeUses =>
      isPremium ? 0 : (fullLimit - limit).clamp(0, fullLimit);

  int get estimatedMinutesSaved =>
      aiMealsSaved * MonetizationService.estimatedMinutesSavedPerAiMeal;

  /// Whether the share bonus is still available to earn.
  bool get canEarnShareBonus => !isPremium && !hasShareBonus;
}

class _AiTrialProfile {
  final String userId;
  final int used;
  final int aiMealsSaved;
  final bool hasOnboardingBonus;
  final bool hasShareBonus;
  final String? foundingMemberActivatedAt;

  const _AiTrialProfile({
    required this.userId,
    required this.used,
    required this.aiMealsSaved,
    required this.hasOnboardingBonus,
    required this.hasShareBonus,
    required this.foundingMemberActivatedAt,
  });

  factory _AiTrialProfile.empty(String userId) {
    return _AiTrialProfile(
      userId: userId,
      used: 0,
      aiMealsSaved: 0,
      hasOnboardingBonus: false,
      hasShareBonus: false,
      foundingMemberActivatedAt: null,
    );
  }

  factory _AiTrialProfile.fromMap(Map<String, dynamic> map) {
    return _AiTrialProfile(
      userId: map['user_id'] as String,
      used: (map['used'] as num? ?? 0).toInt(),
      aiMealsSaved: (map['ai_meals_saved'] as num? ?? 0).toInt(),
      hasOnboardingBonus: map['onboarding_bonus_granted'] == true,
      hasShareBonus: map['share_bonus_granted'] == true,
      foundingMemberActivatedAt: map['founding_member_activated_at'] as String?,
    );
  }

  bool get isFoundingMember => foundingMemberActivatedAt != null;

  _AiTrialProfile copyWith({
    int? used,
    int? aiMealsSaved,
    bool? hasOnboardingBonus,
    bool? hasShareBonus,
    String? foundingMemberActivatedAt,
  }) {
    return _AiTrialProfile(
      userId: userId,
      used: used ?? this.used,
      aiMealsSaved: aiMealsSaved ?? this.aiMealsSaved,
      hasOnboardingBonus: hasOnboardingBonus ?? this.hasOnboardingBonus,
      hasShareBonus: hasShareBonus ?? this.hasShareBonus,
      foundingMemberActivatedAt:
          foundingMemberActivatedAt ?? this.foundingMemberActivatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'used': used < 0 ? 0 : used,
      'ai_meals_saved': aiMealsSaved < 0 ? 0 : aiMealsSaved,
      'onboarding_bonus_granted': hasOnboardingBonus,
      'share_bonus_granted': hasShareBonus,
      'founding_member_activated_at': foundingMemberActivatedAt,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is _AiTrialProfile &&
        other.userId == userId &&
        other.used == used &&
        other.aiMealsSaved == aiMealsSaved &&
        other.hasOnboardingBonus == hasOnboardingBonus &&
        other.hasShareBonus == hasShareBonus &&
        other.foundingMemberActivatedAt == foundingMemberActivatedAt;
  }

  @override
  int get hashCode => Object.hash(
        userId,
        used,
        aiMealsSaved,
        hasOnboardingBonus,
        hasShareBonus,
        foundingMemberActivatedAt,
      );
}

abstract class AiTrialProfileStore {
  Future<Map<String, dynamic>?> fetchProfile(String userId);

  Future<Map<String, dynamic>> upsertProfile(Map<String, dynamic> profile);
}

class SupabaseAiTrialProfileStore implements AiTrialProfileStore {
  final SupabaseClient _supabase;

  const SupabaseAiTrialProfileStore(this._supabase);

  @override
  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    return await _supabase
        .from(MonetizationService._aiTrialTable)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  @override
  Future<Map<String, dynamic>> upsertProfile(Map<String, dynamic> profile) async {
    return await _supabase
        .from(MonetizationService._aiTrialTable)
        .upsert(profile)
        .select()
        .single();
  }
}
