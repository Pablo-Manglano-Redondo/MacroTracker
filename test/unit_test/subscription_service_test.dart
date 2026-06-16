import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/services/subscription_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Fake Package that bypasses Package.fromJson (which requires non-null pricePerPeriod).
class _FakeStoreProduct extends Fake implements StoreProduct {
  @override
  String get identifier => 'premium_monthly';
  @override
  double get price => 4.99;
  @override
  String get priceString => '\$4.99';
  @override
  String get currencyCode => 'USD';
  String get localizedDescription => 'Premium Monthly';
  @override
  String get title => 'Premium Monthly';
  @override
  PresentedOfferingContext? get presentedOfferingContext => null;
}

class _FakePackage extends Fake implements Package {
  @override
  String get identifier => '\$rc_monthly';
  @override
  PackageType get packageType => PackageType.monthly;
  @override
  StoreProduct get storeProduct => _FakeStoreProduct();
  @override
  PresentedOfferingContext get presentedOfferingContext =>
      PresentedOfferingContext.fromJson({
        'offeringIdentifier': 'default',
      });
}

const Map<String, dynamic> _emptyCustomerInfo = {
  'originalAppUserId': 'user-1',
  'firstSeen': '2026-01-01T00:00:00.000Z',
  'latestExpirationDate': null,
  'activeSubscriptions': <String>[],
  'allPurchasedProductIdentifiers': <String>[],
  'nonSubscriptionTransactions': <dynamic>[],
  'entitlements': {
    'all': <String, dynamic>{},
    'active': <String, dynamic>{},
  },
  'allExpirationDates': <String, dynamic>{},
  'allPurchaseDates': <String, dynamic>{},
  'requestDate': '2026-01-01T00:00:00.000Z',
  'managementURL': null,
  'originalPurchaseDate': null,
};

const Map<String, dynamic> _activeCustomerInfo = {
  'originalAppUserId': 'user-1',
  'firstSeen': '2026-01-01T00:00:00.000Z',
  'latestExpirationDate': '2027-01-01T00:00:00.000Z',
  'activeSubscriptions': ['premium_monthly'],
  'allPurchasedProductIdentifiers': ['premium_monthly'],
  'nonSubscriptionTransactions': <dynamic>[],
  'entitlements': {
    'all': {
      'premium': {
        'identifier': 'premium',
        'isActive': true,
        'willRenew': true,
        'periodType': 'NORMAL',
        'latestPurchaseDate': '2026-01-01T00:00:00.000Z',
        'originalPurchaseDate': '2026-01-01T00:00:00.000Z',
        'expirationDate': '2027-01-01T00:00:00.000Z',
        'store': 'PLAY_STORE',
        'productIdentifier': 'premium_monthly',
        'isSandbox': true,
        'unsubscribeDetectedAt': null,
        'billingIssueDetectedAt': null,
        'ownershipType': 'PURCHASED',
        'verification': 'NOT_REQUESTED',
      }
    },
    'active': {
      'premium': {
        'identifier': 'premium',
        'isActive': true,
        'willRenew': true,
        'periodType': 'NORMAL',
        'latestPurchaseDate': '2026-01-01T00:00:00.000Z',
        'originalPurchaseDate': '2026-01-01T00:00:00.000Z',
        'expirationDate': '2027-01-01T00:00:00.000Z',
        'store': 'PLAY_STORE',
        'productIdentifier': 'premium_monthly',
        'isSandbox': true,
        'unsubscribeDetectedAt': null,
        'billingIssueDetectedAt': null,
        'ownershipType': 'PURCHASED',
        'verification': 'NOT_REQUESTED',
      }
    },
  },
  'allExpirationDates': {'premium_monthly': '2027-01-01T00:00:00.000Z'},
  'allPurchaseDates': {'premium_monthly': '2026-01-01T00:00:00.000Z'},
  'requestDate': '2026-01-01T00:00:00.000Z',
  'managementURL': null,
  'originalPurchaseDate': '2026-01-01T00:00:00.000Z',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Track channel method calls made by the RevenueCat plugin
  final List<String> calledMethods = [];
  dynamic channelReturnValue;
  bool shouldThrowOnNextCall = false;

  setUpAll(() {
    const channel = MethodChannel('purchases_flutter');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      calledMethods.add(methodCall.method);
      if (shouldThrowOnNextCall) {
        shouldThrowOnNextCall = false;
        throw PlatformException(code: 'ERROR', message: 'Mocked error');
      }
      return channelReturnValue;
    });
  });

  setUp(() {
    calledMethods.clear();
    channelReturnValue = null;
    shouldThrowOnNextCall = false;
  });

  group('SubscriptionService – not configured', () {
    late SubscriptionService service;

    setUp(() {
      service = SubscriptionService(
        iosApiKey: 'mock_ios_key',
        androidApiKey: 'mock_android_key',
      );
    });

    test('empty API key skips configure and stays unconfigured', () async {
      final svc = SubscriptionService(iosApiKey: '', androidApiKey: '');
      await svc.initialize();
      expect(svc.isConfigured, isFalse);
      expect(calledMethods, isEmpty);
    });

    test('getOfferings returns [] when not configured', () async {
      expect(await service.getOfferings(), isEmpty);
    });

    test('purchasePackage returns false when not configured', () async {
      expect(await service.purchasePackage(_FakePackage()), isFalse);
    });

    test('restorePurchases returns false when not configured', () async {
      expect(await service.restorePurchases(), isFalse);
    });

    test('isPremiumActive returns true in kDebugMode (normal flow)', () async {
      // In test/debug mode kDebugMode=true → early return true
      expect(await service.isPremiumActive(), isTrue);
    });

    test(
        'isPremiumActive returns false when debug bypass forced + not configured',
        () async {
      service.debugBypassPremiumForce = true;
      expect(await service.isPremiumActive(), isFalse);
    });
  });

  group('SubscriptionService – configured', () {
    late SubscriptionService service;

    setUp(() async {
      channelReturnValue = null;
      service = SubscriptionService(
        iosApiKey: 'mock_ios_key',
        androidApiKey: 'mock_android_key',
      );
      // Initialize so that configure is called without errors
      await service.initialize();
      service.debugBypassPremiumForce = true; // allow testing real paths
      calledMethods.clear();
    });

    test('isConfigured is true after successful initialize', () {
      expect(service.isConfigured, isTrue);
    });

    test('initialize handles PlatformException during configure gracefully',
        () async {
      final svc = SubscriptionService(
        iosApiKey: 'mock_ios_key',
        androidApiKey: 'mock_android_key',
      );
      shouldThrowOnNextCall = true;
      await svc.initialize();
      expect(svc.isConfigured, isFalse);
    });

    test('isPremiumActive returns true when entitlement is active', () async {
      channelReturnValue = _activeCustomerInfo;
      final isActive = await service.isPremiumActive();
      expect(isActive, isTrue);
      expect(calledMethods, contains('getCustomerInfo'));
    });

    test('isPremiumActive returns false when no entitlement', () async {
      channelReturnValue = _emptyCustomerInfo;
      final isActive = await service.isPremiumActive();
      expect(isActive, isFalse);
    });

    test('isPremiumActive returns false on PlatformException', () async {
      shouldThrowOnNextCall = true;
      final isActive = await service.isPremiumActive();
      expect(isActive, isFalse);
    });

    test('getOfferings returns [] when current offering is null', () async {
      channelReturnValue = {'all': <String, dynamic>{}, 'current': null};
      final offerings = await service.getOfferings();
      expect(offerings, isEmpty);
    });

    test('getOfferings returns [] on PlatformException', () async {
      shouldThrowOnNextCall = true;
      final offerings = await service.getOfferings();
      expect(offerings, isEmpty);
    });

    test('restorePurchases returns true when entitlement active', () async {
      channelReturnValue = _activeCustomerInfo;
      final result = await service.restorePurchases();
      expect(result, isTrue);
      expect(calledMethods, contains('restorePurchases'));
    });

    test('restorePurchases returns false on PlatformException', () async {
      shouldThrowOnNextCall = true;
      final result = await service.restorePurchases();
      expect(result, isFalse);
    });

    test('purchasePackage returns false on PlatformException', () async {
      shouldThrowOnNextCall = true;
      final result = await service.purchasePackage(_FakePackage());
      expect(result, isFalse);
    });
  });
}
