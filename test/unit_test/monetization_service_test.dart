import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
import 'package:macrotracker/core/services/subscription_service.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('MonetizationService', () {
    test('applies the guest limit until the account is protected', () async {
      final store = _FakeAiTrialProfileStore();
      final guestIdentity = _FakeSupabaseIdentityService(
        userId: 'guest-user',
        currentUser: const _FakeUser(isAnonymous: true),
      );
      final guestService = MonetizationService(
        _FakeSubscriptionService(isPremium: false),
        _FakeBox(),
        guestIdentity,
        _FakeSupabaseClient(),
        profileStore: store,
        analyticsService: _FakeConversionAnalyticsService(),
      );

      final guestState = await guestService.getAiTrialState();

      expect(guestState.isProtectedAccount, isFalse);
      expect(guestState.limit, MonetizationService.guestAiTrialLimit);
      expect(guestState.fullLimit, MonetizationService.freeAiTrialLimit);

      final protectedIdentity = _FakeSupabaseIdentityService(
        userId: 'protected-user',
        currentUser: const _FakeUser(isAnonymous: false),
      );
      final protectedService = MonetizationService(
        _FakeSubscriptionService(isPremium: false),
        _FakeBox(),
        protectedIdentity,
        _FakeSupabaseClient(),
        profileStore: store,
        analyticsService: _FakeConversionAnalyticsService(),
      );

      final protectedState = await protectedService.getAiTrialState();

      expect(protectedState.isProtectedAccount, isTrue);
      expect(protectedState.limit, MonetizationService.freeAiTrialLimit);
      expect(protectedState.fullLimit, MonetizationService.freeAiTrialLimit);
    });

    test('grants onboarding and share bonuses on the remote profile', () async {
      final store = _FakeAiTrialProfileStore();
      final service = MonetizationService(
        _FakeSubscriptionService(isPremium: false),
        _FakeBox(),
        _FakeSupabaseIdentityService(
          userId: 'protected-user',
          currentUser: const _FakeUser(isAnonymous: false),
        ),
        _FakeSupabaseClient(),
        profileStore: store,
        analyticsService: _FakeConversionAnalyticsService(),
      );

      await service.grantOnboardingBonus();
      await service.grantShareBonus();
      final state = await service.getAiTrialState();

      expect(state.hasOnboardingBonus, isTrue);
      expect(state.hasShareBonus, isTrue);
      expect(
        state.limit,
        MonetizationService.freeAiTrialLimit +
            MonetizationService.bonusAiUses +
            MonetizationService.shareBonusAiUses,
      );
    });

    test('migrates legacy local state into the remote profile', () async {
      final box = _FakeBox({
        'ai_trial_uses': 2,
        'ai_meals_saved': 3,
        'ai_bonus_onboarding_granted': true,
        'founding_member_activated_at': '2026-06-01T10:00:00.000Z',
      });
      final store = _FakeAiTrialProfileStore();
      final service = MonetizationService(
        _FakeSubscriptionService(isPremium: false),
        box,
        _FakeSupabaseIdentityService(
          userId: 'protected-user',
          currentUser: const _FakeUser(isAnonymous: false),
        ),
        _FakeSupabaseClient(),
        profileStore: store,
        analyticsService: _FakeConversionAnalyticsService(),
      );

      final state = await service.getAiTrialState();

      expect(state.used, 2);
      expect(state.aiMealsSaved, 3);
      expect(state.hasOnboardingBonus, isTrue);
      expect(state.isFoundingMember, isTrue);
      expect(store.profiles['protected-user']?['used'], 2);
      expect(
        box.get('ai_trial_profile_owner_user_id'),
        'protected-user',
      );
    });

    test('reports exhaustion when the final guest trial use is consumed',
        () async {
      final store = _FakeAiTrialProfileStore(
        initialProfiles: {
          'guest-user': {
            'user_id': 'guest-user',
            'used': 1,
            'ai_meals_saved': 4,
            'onboarding_bonus_granted': false,
            'share_bonus_granted': false,
            'founding_member_activated_at': null,
          },
        },
      );
      final analytics = _FakeConversionAnalyticsService();
      final service = MonetizationService(
        _FakeSubscriptionService(isPremium: false),
        _FakeBox(),
        _FakeSupabaseIdentityService(
          userId: 'guest-user',
          currentUser: const _FakeUser(isAnonymous: true),
        ),
        _FakeSupabaseClient(),
        profileStore: store,
        analyticsService: analytics,
      );

      final exhausted = await service.consumeAiTrialUseAndCheckExhausted();
      final state = await service.getAiTrialState();

      expect(exhausted, isTrue);
      expect(state.used, MonetizationService.guestAiTrialLimit);
      expect(
        analytics.events,
        contains('trial_exhausted:4'),
      );
    });

    test(
        'falls back to local trial state when cloud session sync is unavailable',
        () async {
      final box = _FakeBox({
        'ai_trial_uses': 2,
        'ai_meals_saved': 4,
        'ai_bonus_onboarding_granted': true,
        'ai_bonus_share_granted': true,
        'founding_member_activated_at': '2026-06-01T10:00:00.000Z',
        'ai_trial_profile_owner_user_id': 'cached-user',
      });
      final service = MonetizationService(
        _FakeSubscriptionService(isPremium: false),
        box,
        _FakeSupabaseIdentityService(
          userId: 'cached-user',
          currentUser: null,
          ensureUserSessionError: StateError('anonymous auth disabled'),
        ),
        _FakeSupabaseClient(),
        profileStore: _FakeAiTrialProfileStore(),
        analyticsService: _FakeConversionAnalyticsService(),
      );

      final state = await service.getAiTrialState();

      expect(state.used, MonetizationService.guestAiTrialLimit);
      expect(state.limit, MonetizationService.guestAiTrialLimit);
      expect(
          state.fullLimit,
          MonetizationService.freeAiTrialLimit +
              MonetizationService.bonusAiUses +
              MonetizationService.shareBonusAiUses);
      expect(state.aiMealsSaved, 4);
      expect(state.hasOnboardingBonus, isTrue);
      expect(state.hasShareBonus, isTrue);
      expect(state.isFoundingMember, isTrue);
      expect(state.isProtectedAccount, isFalse);
    });
  });
}

class _FakeAiTrialProfileStore implements AiTrialProfileStore {
  final Map<String, Map<String, dynamic>> profiles;

  _FakeAiTrialProfileStore({
    Map<String, Map<String, dynamic>> initialProfiles = const {},
  }) : profiles = {
          for (final entry in initialProfiles.entries)
            entry.key: Map<String, dynamic>.from(entry.value),
        };

  @override
  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    final profile = profiles[userId];
    return profile == null ? null : Map<String, dynamic>.from(profile);
  }

  @override
  Future<Map<String, dynamic>> upsertProfile(
      Map<String, dynamic> profile) async {
    final userId = profile['user_id'] as String;
    profiles[userId] = Map<String, dynamic>.from(profile);
    return Map<String, dynamic>.from(profiles[userId]!);
  }
}

class _FakeSubscriptionService implements SubscriptionService {
  final bool isPremium;

  const _FakeSubscriptionService({required this.isPremium});

  @override
  Future<bool> isPremiumActive() async => isPremium;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSupabaseIdentityService implements SupabaseIdentityService {
  final String userId;
  @override
  final User? currentUser;
  final Object? ensureUserSessionError;

  const _FakeSupabaseIdentityService({
    required this.userId,
    required this.currentUser,
    this.ensureUserSessionError,
  });

  @override
  String? get currentUserId => currentUser?.id;

  @override
  Future<String> ensureUserSession() async {
    final error = ensureUserSessionError;
    if (error != null) {
      throw error;
    }
    return userId;
  }

  @override
  String requireActiveUserSession() => userId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConversionAnalyticsService implements ConversionAnalyticsService {
  final List<String> events = <String>[];

  @override
  Future<void> logFirstAiMealCreated() async {
    events.add('first_ai_meal_created');
  }

  @override
  Future<void> logTrialExhausted({required int totalAiMealsSaved}) async {
    events.add('trial_exhausted:$totalAiMealsSaved');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBox implements Box<dynamic> {
  final Map<dynamic, dynamic> _values;

  _FakeBox([Map<dynamic, dynamic> initialValues = const {}])
      : _values = Map<dynamic, dynamic>.from(initialValues);

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) =>
      _values.containsKey(key) ? _values[key] : defaultValue;

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUser implements User {
  @override
  final bool isAnonymous;

  const _FakeUser({required this.isAnonymous});

  @override
  String get id => isAnonymous ? 'guest-user' : 'protected-user';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
