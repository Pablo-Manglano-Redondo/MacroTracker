import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/services/meal_reminder_service.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class _FakeConfigRepository extends Fake implements ConfigRepository {
  ConfigEntity config =
      const ConfigEntity(true, true, true, AppThemeEntity.system);
  bool throwsOnGet = false;

  @override
  Future<ConfigEntity> getConfig() async {
    if (throwsOnGet) {
      throw StateError('config unavailable');
    }
    return config;
  }
}

class _ScheduledReminder {
  final int id;
  final String? title;
  final String? body;
  final tz.TZDateTime scheduledDate;
  final DateTimeComponents? matchDateTimeComponents;

  const _ScheduledReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.matchDateTimeComponents,
  });
}

class _FakeNotificationsPlugin extends Fake
    implements FlutterLocalNotificationsPlugin {
  int initializeCalls = 0;
  final cancelledIds = <int>[];
  final scheduled = <_ScheduledReminder>[];
  bool throwOnCancel = false;

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
        onDidReceiveBackgroundNotificationResponse,
  }) async {
    initializeCalls++;
    return true;
  }

  @override
  Future<void> cancel({required int id, String? tag}) async {
    if (throwOnCancel) {
      throw StateError('cancel failed');
    }
    cancelledIds.add(id);
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? title,
    String? body,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    scheduled.add(_ScheduledReminder(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      matchDateTimeComponents: matchDateTimeComponents,
    ));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeConfigRepository configRepository;
  late _FakeNotificationsPlugin notifications;
  late MealReminderService service;

  setUp(() {
    tzdata.initializeTimeZones();
    configRepository = _FakeConfigRepository();
    notifications = _FakeNotificationsPlugin();
    service = MealReminderService(configRepository, notifications);
  });

  group('MealReminderService', () {
    test('initialize is idempotent on non-mobile test hosts', () async {
      await service.initialize();
      await service.initialize();

      expect(notifications.initializeCalls, 0);
    });

    test('requestPermissionIfNeeded returns true on non-mobile test hosts',
        () async {
      expect(await service.requestPermissionIfNeeded(), isTrue);
    });

    test('syncFromConfig cancels reminders when disabled', () async {
      configRepository.config = const ConfigEntity(
        true,
        true,
        true,
        AppThemeEntity.system,
        mealRemindersEnabled: false,
      );

      expect(await service.syncFromConfig(requestPermissionIfNeeded: true),
          isTrue);

      expect(notifications.scheduled, isEmpty);
      expect(notifications.cancelledIds, [9101, 9102, 9103, 9104]);
    });

    test('syncFromConfig schedules four Spanish daily reminders when enabled',
        () async {
      configRepository.config = const ConfigEntity(
        true,
        true,
        true,
        AppThemeEntity.system,
        selectedLocale: 'es',
        mealRemindersEnabled: true,
        mealReminderMorningMinutes: 8 * 60,
        mealReminderLunchMinutes: 14 * 60,
        mealReminderAfternoonMinutes: 17 * 60 + 30,
        mealReminderEveningMinutes: 21 * 60,
      );

      expect(await service.syncFromConfig(), isTrue);

      expect(notifications.cancelledIds, [9101, 9102, 9103, 9104]);
      expect(
          notifications.scheduled.map((r) => r.id), [9101, 9102, 9103, 9104]);
      expect(notifications.scheduled.first.title, 'Desayuno pendiente');
      expect(notifications.scheduled.first.body,
          'No olvides registrar tu desayuno.');
      expect(notifications.scheduled.first.scheduledDate.hour, 8);
      expect(notifications.scheduled.first.scheduledDate.minute, 0);
      expect(notifications.scheduled.first.matchDateTimeComponents,
          DateTimeComponents.time);
    });

    test('syncFromConfig returns false when repository or plugin fails',
        () async {
      configRepository.throwsOnGet = true;
      expect(await service.syncFromConfig(), isFalse);

      configRepository.throwsOnGet = false;
      notifications.throwOnCancel = true;
      expect(await service.syncFromConfig(), isFalse);
    });
  });
}
