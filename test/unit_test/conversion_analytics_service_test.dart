import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class _FakeConversionAnalyticsClient extends Fake implements ConversionAnalyticsClient {
  bool initialized = false;
  bool enabled = false;
  String? lastEventName;
  Map<String, Object>? lastParameters;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> setEnabled(bool val) async {
    enabled = val;
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    lastEventName = name;
    lastParameters = parameters;
  }
}

class _FakeGetConfigUsecase extends Fake implements GetConfigUsecase {
  bool acceptedSendAnonymousData = true;

  @override
  Future<ConfigEntity> getConfig() async {
    return ConfigEntity(
      true,
      true,
      acceptedSendAnonymousData,
      AppThemeEntity.system,
    );
  }
}

class _FakeStoreProduct extends Fake implements StoreProduct {
  @override
  String get identifier => 'prod-123';
  @override
  double get price => 9.99;
  @override
  String get currencyCode => 'USD';
}

class _FakePackage extends Fake implements Package {
  @override
  String get identifier => 'pack-123';
  @override
  PackageType get packageType => PackageType.monthly;
  @override
  StoreProduct get storeProduct => _FakeStoreProduct();
}

void main() {
  group('ConversionAnalyticsService Tests', () {
    late _FakeConversionAnalyticsClient client;
    late _FakeGetConfigUsecase getConfigUsecase;
    late ConversionAnalyticsService service;

    setUp(() {
      client = _FakeConversionAnalyticsClient();
      getConfigUsecase = _FakeGetConfigUsecase();
      service = ConversionAnalyticsService(client, getConfigUsecase);
    });

    test('initializeFromConsent sets client status based on config consent', () async {
      getConfigUsecase.acceptedSendAnonymousData = true;
      await service.initializeFromConsent();
      expect(client.initialized, isTrue);
      expect(client.enabled, isTrue);

      getConfigUsecase.acceptedSendAnonymousData = false;
      await service.initializeFromConsent();
      expect(client.enabled, isFalse);
    });

    test('logEvent initializes automatically and cleans parameters before logging', () async {
      getConfigUsecase.acceptedSendAnonymousData = true;

      await service.logEvent('test_event', parameters: {
        'string_val': 'hello',
        'int_val': 42,
        'null_val': null,
        'other_val': const ['list'],
      });

      expect(client.initialized, isTrue);
      expect(client.lastEventName, 'test_event');
      expect(client.lastParameters?['string_val'], 'hello');
      expect(client.lastParameters?['int_val'], 42);
      expect(client.lastParameters?.containsKey('null_val'), isFalse);
      expect(client.lastParameters?['other_val'], '[list]');
    });

    test('logEvent does not log when disabled', () async {
      getConfigUsecase.acceptedSendAnonymousData = false;
      await service.logEvent('should_not_log');

      expect(client.lastEventName, isNull);
    });

    test('logPaywallViewed records onboarding or regular event correctly', () async {
      getConfigUsecase.acceptedSendAnonymousData = true;

      await service.logPaywallViewed(placement: 'onboarding', aiTrialsRemaining: 3);
      expect(client.lastEventName, 'onboarding_paywall_viewed');
      expect(client.lastParameters?['ai_trials_remaining'], 3);

      await service.logPaywallViewed(placement: 'settings');
      expect(client.lastEventName, 'paywall_viewed');
    });

    test('logPaywallPackageSelected and logPurchaseStarted map Package details correctly', () async {
      getConfigUsecase.acceptedSendAnonymousData = true;
      final package = _FakePackage();

      await service.logPaywallPackageSelected(placement: 'home', package: package);
      expect(client.lastEventName, 'paywall_package_selected');
      expect(client.lastParameters?['package_id'], 'pack-123');
      expect(client.lastParameters?['product_id'], 'prod-123');
      expect(client.lastParameters?['price'], 9.99);

      await service.logPurchaseStarted(placement: 'home', package: package);
      expect(client.lastEventName, 'purchase_started');
    });

    test('logPurchaseCompleted and logPurchaseFailed records successfully', () async {
      getConfigUsecase.acceptedSendAnonymousData = true;
      final package = _FakePackage();

      await service.logPurchaseCompleted(placement: 'home', package: package);
      expect(client.lastEventName, 'purchase_completed');
      expect(client.lastParameters?['product_id'], 'prod-123');

      await service.logPurchaseFailed(placement: 'home', package: package);
      expect(client.lastEventName, 'purchase_failed');
    });

    test('logPurchaseRestored records status', () async {
      getConfigUsecase.acceptedSendAnonymousData = true;
      await service.logPurchaseRestored(restored: true);
      expect(client.lastEventName, 'purchase_restored');
      expect(client.lastParameters?['restored'], 'true');
    });

    test('funnel and AI requests log events successfully', () async {
      getConfigUsecase.acceptedSendAnonymousData = true;

      await service.logOnboardingCompleted();
      expect(client.lastEventName, 'onboarding_completed');

      await service.logFirstAiMealCreated();
      expect(client.lastEventName, 'first_ai_meal_created');

      await service.logTrialExhausted(totalAiMealsSaved: 10);
      expect(client.lastEventName, 'trial_exhausted');
      expect(client.lastParameters?['ai_meals_saved'], 10);

      await service.logShareBonusGranted();
      expect(client.lastEventName, 'share_bonus_granted');

      await service.logReferralCodeCreated();
      expect(client.lastEventName, 'referral_code_created');

      await service.logReferralRedeemed();
      expect(client.lastEventName, 'referral_redeemed');

      await service.logAiInterpretationStarted(inputType: 'photo');
      expect(client.lastEventName, 'ai_request_started');
      expect(client.lastParameters?['input_type'], 'photo');

      await service.logAiInterpretationFailed(inputType: 'text', category: 'timeout');
      expect(client.lastEventName, 'ai_request_failed');
      expect(client.lastParameters?['failure_category'], 'timeout');

      await service.logAiInterpretationRetried(inputType: 'text', category: 'network');
      expect(client.lastEventName, 'ai_request_retried');

      await service.logAiInterpretationCompleted(
        inputType: 'photo',
        remoteMs: 100,
        edgeMs: 20,
        geminiMs: 80,
        modelAttempts: 1,
        fallbackUsed: false,
      );
      expect(client.lastEventName, 'ai_request_completed');
      expect(client.lastParameters?['gemini_ms'], 80);
      expect(client.lastParameters?['fallback_used'], 'false');
    });
  });
}
