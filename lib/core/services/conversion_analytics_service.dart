import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class ConversionAnalyticsClient {
  Future<void> initialize();

  Future<void> setEnabled(bool enabled);

  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  });
}

class FirebaseConversionAnalyticsClient implements ConversionAnalyticsClient {
  final _log = Logger('FirebaseConversionAnalyticsClient');
  FirebaseAnalytics? _analytics;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized || !_supportsFirebaseAnalytics) {
      _initialized = true;
      return;
    }

    try {
      await Firebase.initializeApp();
      _analytics = FirebaseAnalytics.instance;
    } catch (error, stackTrace) {
      _log.warning(
          'Firebase Analytics initialization failed', error, stackTrace);
    } finally {
      _initialized = true;
    }
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    await initialize();
    await _analytics?.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    await initialize();
    await _analytics?.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  bool get _supportsFirebaseAnalytics {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }
}

class ConversionAnalyticsService {
  final ConversionAnalyticsClient _client;
  final GetConfigUsecase _getConfigUsecase;
  bool _enabled = false;
  bool _initialized = false;

  ConversionAnalyticsService(this._client, this._getConfigUsecase);

  Future<void> initializeFromConsent() async {
    final consentEnabled =
        (await _getConfigUsecase.getConfig()).hasAcceptedSendAnonymousData;
    await _client.initialize();
    await setEnabled(consentEnabled);
    _initialized = true;
  }

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    await _client.setEnabled(enabled);
  }

  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    if (!_initialized) {
      await initializeFromConsent();
    }
    if (!_enabled) {
      return;
    }

    final consentEnabled =
        (await _getConfigUsecase.getConfig()).hasAcceptedSendAnonymousData;
    if (!consentEnabled) {
      await setEnabled(false);
      return;
    }

    await _client.logEvent(
      name,
      parameters: _cleanParameters(parameters),
    );
  }

  Future<void> logPaywallViewed({
    required String placement,
    int? aiTrialsRemaining,
  }) {
    return logEvent(
      _paywallViewedEventName(placement),
      parameters: {
        'placement': placement,
        if (aiTrialsRemaining != null) 'ai_trials_remaining': aiTrialsRemaining,
      },
    );
  }

  Future<void> logPaywallPackageSelected({
    required String placement,
    required Package package,
  }) {
    return logEvent(
      'paywall_package_selected',
      parameters: _packageParameters(placement, package),
    );
  }

  Future<void> logPurchaseStarted({
    required String placement,
    required Package package,
  }) {
    return logEvent(
      'purchase_started',
      parameters: _packageParameters(placement, package),
    );
  }

  Future<void> logPurchaseCompleted({
    required String placement,
    Package? package,
  }) {
    return logEvent(
      'purchase_completed',
      parameters: {
        'placement': placement,
        if (package != null) ..._packageParameters(placement, package),
      },
    );
  }

  Future<void> logPurchaseFailed({
    required String placement,
    Package? package,
  }) {
    return logEvent(
      'purchase_failed',
      parameters: {
        'placement': placement,
        if (package != null) ..._packageParameters(placement, package),
      },
    );
  }

  Future<void> logPurchaseRestored({required bool restored}) {
    return logEvent(
      'purchase_restored',
      parameters: {'restored': restored},
    );
  }

  // -------------------------------------------------------------------------
  // Funnel events
  // -------------------------------------------------------------------------

  Future<void> logOnboardingCompleted() {
    return logEvent('onboarding_completed');
  }

  Future<void> logFirstAiMealCreated() {
    return logEvent('first_ai_meal_created');
  }

  Future<void> logTrialExhausted({required int totalAiMealsSaved}) {
    return logEvent(
      'trial_exhausted',
      parameters: {'ai_meals_saved': totalAiMealsSaved},
    );
  }

  Future<void> logShareBonusGranted() {
    return logEvent('share_bonus_granted');
  }

  Future<void> logReferralCodeCreated() {
    return logEvent('referral_code_created');
  }

  Future<void> logReferralRedeemed() {
    return logEvent('referral_redeemed');
  }

  Map<String, Object> _cleanParameters(Map<String, Object?> parameters) {
    final cleaned = <String, Object>{};
    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }
      if (value is String || value is num || value is bool) {
        cleaned[entry.key] = value;
      } else {
        cleaned[entry.key] = value.toString();
      }
    }
    return cleaned;
  }

  Map<String, Object> _packageParameters(String placement, Package package) {
    return {
      'placement': placement,
      'package_id': package.identifier,
      'package_type': package.packageType.name,
      'product_id': package.storeProduct.identifier,
      'price': package.storeProduct.price,
      'currency': package.storeProduct.currencyCode,
    };
  }

  String _paywallViewedEventName(String placement) {
    return placement == 'onboarding'
        ? 'onboarding_paywall_viewed'
        : 'paywall_viewed';
  }
}
