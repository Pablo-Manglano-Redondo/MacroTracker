import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/domain/usecase/get_config_usecase.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';

void main() {
  group('ConversionAnalyticsService', () {
    test('does not emit events when anonymous data opt-in is disabled',
        () async {
      final client = _FakeAnalyticsClient();
      final config = _FakeGetConfigUsecase(acceptedAnonymousData: false);
      final service = ConversionAnalyticsService(client, config);

      await service.initializeFromConsent();
      await service.logEvent(
        'weekly_insights_viewed',
        parameters: {'tracked_days': 5},
      );

      expect(client.enabledValues, [false]);
      expect(client.events, isEmpty);
    });

    test('emits event names and cleaned parameters when opt-in is enabled',
        () async {
      final client = _FakeAnalyticsClient();
      final config = _FakeGetConfigUsecase(acceptedAnonymousData: true);
      final service = ConversionAnalyticsService(client, config);

      await service.initializeFromConsent();
      await service.logEvent(
        'weekly_adjustment_applied',
        parameters: {
          'delta_kcal': -100,
          'is_premium': true,
          'ignored': null,
          'custom': DateTime(2026, 6, 3),
        },
      );

      expect(client.enabledValues, [true]);
      expect(client.events, hasLength(1));
      expect(client.events.single.name, 'weekly_adjustment_applied');
      expect(client.events.single.parameters, {
        'delta_kcal': -100,
        'is_premium': true,
        'custom': '2026-06-03 00:00:00.000',
      });
    });
  });
}

class _FakeAnalyticsClient implements ConversionAnalyticsClient {
  final events = <_FakeAnalyticsEvent>[];
  final enabledValues = <bool>[];
  int initializeCount = 0;

  @override
  Future<void> initialize() async {
    initializeCount += 1;
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    events.add(_FakeAnalyticsEvent(name, parameters ?? const {}));
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    enabledValues.add(enabled);
  }
}

class _FakeAnalyticsEvent {
  final String name;
  final Map<String, Object> parameters;

  const _FakeAnalyticsEvent(this.name, this.parameters);
}

class _FakeGetConfigUsecase implements GetConfigUsecase {
  bool acceptedAnonymousData;

  _FakeGetConfigUsecase({required this.acceptedAnonymousData});

  @override
  Future<ConfigEntity> getConfig() async {
    return ConfigEntity(
      true,
      true,
      acceptedAnonymousData,
      AppThemeEntity.system,
    );
  }
}
