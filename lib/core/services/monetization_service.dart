import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/subscription_service.dart';
import 'package:macrotracker/core/utils/locator.dart';

class MonetizationService {
  static const int freeAiTrialLimit = 5;
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

  final SubscriptionService _subscriptionService;
  final Box<dynamic> _box;

  MonetizationService(this._subscriptionService, this._box);

  // ---------------------------------------------------------------------------
  // Trial state
  // ---------------------------------------------------------------------------

  Future<AiTrialState> getAiTrialState() async {
    final isPremium = await _subscriptionService.isPremiumActive();
    final used = (_box.get(_aiTrialUsesKey, defaultValue: 0) as num).toInt();
    final mealsSaved =
        (_box.get(_aiMealsSavedKey, defaultValue: 0) as num).toInt();
    final effectiveLimit = _effectiveLimit;
    return AiTrialState(
      isPremium: isPremium,
      used: used.clamp(0, effectiveLimit),
      limit: effectiveLimit,
      aiMealsSaved: mealsSaved < 0 ? 0 : mealsSaved,
      hasOnboardingBonus: _hasOnboardingBonus,
      hasShareBonus: _hasShareBonus,
      isFoundingMember: isFoundingMember,
    );
  }

  int get _effectiveLimit {
    var limit = freeAiTrialLimit;
    if (_hasOnboardingBonus) limit += bonusAiUses;
    if (_hasShareBonus) limit += shareBonusAiUses;
    return limit;
  }

  // ---------------------------------------------------------------------------
  // AI meal tracking
  // ---------------------------------------------------------------------------

  Future<void> recordAiMealSaved({required bool consumeTrialUse}) async {
    final currentMeals =
        (_box.get(_aiMealsSavedKey, defaultValue: 0) as num).toInt();
    final newMealsCount = currentMeals + 1;
    await _box.put(_aiMealsSavedKey, newMealsCount);

    if (newMealsCount == 1) {
      await locator<ConversionAnalyticsService>().logFirstAiMealCreated();
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
    final newUsed = state.used + 1;
    await _box.put(_aiTrialUsesKey, newUsed);

    if (state.remaining == 1) {
      final mealsSaved =
          (_box.get(_aiMealsSavedKey, defaultValue: 0) as num).toInt();
      await locator<ConversionAnalyticsService>().logTrialExhausted(
        totalAiMealsSaved: mealsSaved,
      );
    }
  }

  /// Returns `true` when this consume exhausted the last remaining trial use.
  Future<bool> consumeAiTrialUseAndCheckExhausted() async {
    final state = await getAiTrialState();
    if (state.isPremium || state.remaining <= 0) {
      return false;
    }
    final newUsed = state.used + 1;
    await _box.put(_aiTrialUsesKey, newUsed);
    final wasExhausted = state.remaining == 1; // was 1, now 0
    if (wasExhausted) {
      final mealsSaved =
          (_box.get(_aiMealsSavedKey, defaultValue: 0) as num).toInt();
      await locator<ConversionAnalyticsService>().logTrialExhausted(
        totalAiMealsSaved: mealsSaved,
      );
    }
    return wasExhausted;
  }

  // ---------------------------------------------------------------------------
  // Bonuses
  // ---------------------------------------------------------------------------

  bool get _hasOnboardingBonus =>
      _box.get(_onboardingBonusGrantedKey, defaultValue: false) == true;

  bool get _hasShareBonus =>
      _box.get(_shareBonusGrantedKey, defaultValue: false) == true;

  /// Grant +2 AI trial uses for completing onboarding. Idempotent.
  Future<void> grantOnboardingBonus() async {
    if (_hasOnboardingBonus) return;
    await _box.put(_onboardingBonusGrantedKey, true);
  }

  /// Grant +3 AI trial uses when a referral share is verified. Idempotent.
  Future<void> grantShareBonus() async {
    if (_hasShareBonus) return;
    await _box.put(_shareBonusGrantedKey, true);
  }

  // ---------------------------------------------------------------------------
  // Founding Member
  // ---------------------------------------------------------------------------

  bool get isFoundingMember =>
      _box.get(_foundingMemberAtKey) != null;

  Future<void> markAsFoundingMember() async {
    if (isFoundingMember) return;
    final now = DateTime.now();
    if (now.isBefore(foundingMemberCutoff)) {
      await _box.put(_foundingMemberAtKey, now.toIso8601String());
    }
  }

  // ---------------------------------------------------------------------------
  // Referral code
  // ---------------------------------------------------------------------------

  String? get savedReferralCode =>
      _box.get(_referralCodeKey) as String?;

  Future<void> saveReferralCode(String code) async {
    await _box.put(_referralCodeKey, code);
  }
}

class AiTrialState {
  final bool isPremium;
  final int used;
  final int limit;
  final int aiMealsSaved;
  final bool hasOnboardingBonus;
  final bool hasShareBonus;
  final bool isFoundingMember;

  const AiTrialState({
    required this.isPremium,
    required this.used,
    required this.limit,
    required this.aiMealsSaved,
    this.hasOnboardingBonus = false,
    this.hasShareBonus = false,
    this.isFoundingMember = false,
  });

  int get remaining => isPremium ? limit : (limit - used).clamp(0, limit);

  bool get canUseAi => isPremium || remaining > 0;

  int get estimatedMinutesSaved =>
      aiMealsSaved * MonetizationService.estimatedMinutesSavedPerAiMeal;

  /// Whether the share bonus is still available to earn.
  bool get canEarnShareBonus => !isPremium && !hasShareBonus;
}
