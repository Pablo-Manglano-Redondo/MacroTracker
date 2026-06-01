import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrotracker/core/services/subscription_service.dart';

class MonetizationService {
  static const int freeAiTrialLimit = 3;
  static const int estimatedMinutesSavedPerAiMeal = 4;

  static const _aiTrialUsesKey = 'ai_trial_uses';
  static const _aiMealsSavedKey = 'ai_meals_saved';

  final SubscriptionService _subscriptionService;
  final Box<dynamic> _box;

  MonetizationService(this._subscriptionService, this._box);

  Future<AiTrialState> getAiTrialState() async {
    final isPremium = await _subscriptionService.isPremiumActive();
    final used = (_box.get(_aiTrialUsesKey, defaultValue: 0) as num).toInt();
    final mealsSaved =
        (_box.get(_aiMealsSavedKey, defaultValue: 0) as num).toInt();
    return AiTrialState(
      isPremium: isPremium,
      used: used.clamp(0, freeAiTrialLimit),
      limit: freeAiTrialLimit,
      aiMealsSaved: mealsSaved < 0 ? 0 : mealsSaved,
    );
  }

  Future<void> recordAiMealSaved({required bool consumeTrialUse}) async {
    final currentMeals =
        (_box.get(_aiMealsSavedKey, defaultValue: 0) as num).toInt();
    await _box.put(_aiMealsSavedKey, currentMeals + 1);

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
    await _box.put(_aiTrialUsesKey, state.used + 1);
  }
}

class AiTrialState {
  final bool isPremium;
  final int used;
  final int limit;
  final int aiMealsSaved;

  const AiTrialState({
    required this.isPremium,
    required this.used,
    required this.limit,
    required this.aiMealsSaved,
  });

  int get remaining => isPremium ? limit : (limit - used).clamp(0, limit);

  bool get canUseAi => isPremium || remaining > 0;

  int get estimatedMinutesSaved =>
      aiMealsSaved * MonetizationService.estimatedMinutesSavedPerAiMeal;
}
