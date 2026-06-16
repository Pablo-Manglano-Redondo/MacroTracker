import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:logging/logging.dart';

/// Centralized service that decides when to request an in-app review.
///
/// Two triggers:
/// 1. **5+ consecutive days** of app usage.
/// 2. **10+ AI meals** committed.
///
/// The review prompt is shown at most once.
class AppReviewService {
  static const _boxName = 'app_metadata';
  static const _consecutiveDaysKey = 'consecutive_days';
  static const _lastActiveDateKey = 'last_active_date';
  static const _aiMealsCommittedKey = 'committed_meals_count';
  static const _reviewPromptedKey = 'review_prompted';

  static const int _consecutiveDaysThreshold = 5;
  static const int _aiMealsThreshold = 10;

  final _log = Logger('AppReviewService');
  final InAppReview _inAppReview;

  AppReviewService([InAppReview? inAppReview])
      : _inAppReview = inAppReview ?? InAppReview.instance;

  /// Call once per app session (e.g. in MainScreen initState).
  Future<void> recordDailyUsage() async {
    try {
      final box = await Hive.openBox(_boxName);
      final todayStr = _todayString();
      final lastActiveDate = box.get(_lastActiveDateKey) as String?;

      if (lastActiveDate == todayStr) {
        // Already recorded today.
        return;
      }

      int consecutive =
          (box.get(_consecutiveDaysKey, defaultValue: 0) as num).toInt();

      if (lastActiveDate != null && _isConsecutive(lastActiveDate, todayStr)) {
        consecutive += 1;
      } else {
        consecutive = 1;
      }

      await box.put(_lastActiveDateKey, todayStr);
      await box.put(_consecutiveDaysKey, consecutive);

      if (consecutive >= _consecutiveDaysThreshold) {
        await _tryRequestReview(box);
      }
    } catch (e) {
      _log.warning('Failed to record daily usage for review', e);
    }
  }

  /// Call after each AI meal is committed.
  Future<void> recordAiMealCommitted() async {
    try {
      final box = await Hive.openBox(_boxName);
      final current =
          (box.get(_aiMealsCommittedKey, defaultValue: 0) as num).toInt();
      final newCount = current + 1;
      await box.put(_aiMealsCommittedKey, newCount);

      if (newCount >= _aiMealsThreshold) {
        await _tryRequestReview(box);
      }
    } catch (e) {
      _log.warning('Failed to record AI meal for review', e);
    }
  }

  Future<void> _tryRequestReview(Box box) async {
    final alreadyPrompted =
        box.get(_reviewPromptedKey, defaultValue: false) as bool;
    if (alreadyPrompted) return;

    final inAppReview = _inAppReview;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
      await box.put(_reviewPromptedKey, true);
    }
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool _isConsecutive(String previousDate, String todayDate) {
    try {
      final prev = DateTime.parse(previousDate);
      final today = DateTime.parse(todayDate);
      return today.difference(prev).inDays == 1;
    } catch (_) {
      return false;
    }
  }
}
