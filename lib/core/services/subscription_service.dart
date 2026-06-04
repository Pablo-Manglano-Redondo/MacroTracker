import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  final _log = Logger('SubscriptionService');

  static const _entitlementId = 'premium';
  static const _iosApiKey =
      String.fromEnvironment('REVENUECAT_IOS_API_KEY');
  static const _androidApiKey =
      String.fromEnvironment('REVENUECAT_ANDROID_API_KEY');

  bool _configured = false;

  Future<void> initialize() async {
    final apiKey = _platformApiKey;
    if (apiKey.isEmpty) {
      _log.warning(
          'RevenueCat API key is not configured. Premium purchases are disabled.');
      return;
    }

    try {
      await Purchases.setLogLevel(kReleaseMode ? LogLevel.warn : LogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _configured = true;
      _log.info('RevenueCat initialized successfully.');
    } catch (e, stackTrace) {
      _log.severe('Failed to initialize RevenueCat', e, stackTrace);
    }
  }

  bool get isConfigured => _configured;

  Future<bool> isPremiumActive() async {
    if (kDebugMode) {
      return true;
    }
    if (!_configured) {
      return false;
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    } on PlatformException catch (e) {
      _log.warning('Failed to check premium status', e);
      return false;
    }
  }

  Future<List<Offering>> getOfferings() async {
    if (!_configured) {
      return [];
    }

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      return current == null ? [] : [current];
    } on PlatformException catch (e) {
      _log.warning('Failed to fetch offerings', e);
      return [];
    }
  }

  Future<bool> purchasePackage(Package package) async {
    if (!_configured) {
      return false;
    }

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    } on PlatformException catch (e) {
      _log.warning('Failed to purchase package', e);
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    if (!_configured) {
      return false;
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    } on PlatformException catch (e) {
      _log.warning('Failed to restore purchases', e);
      return false;
    }
  }

  String get _platformApiKey {
    if (Platform.isAndroid) {
      return _androidApiKey;
    }
    if (Platform.isIOS) {
      return _iosApiKey;
    }
    return '';
  }
}
