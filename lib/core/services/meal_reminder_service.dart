import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MealReminderService {
  static const _channelId = 'meal_reminders';
  static const _channelName = 'Meal reminders';
  static const _channelDescription = 'Daily reminders to log your meals.';

  static const _morningId = 9101;
  static const _lunchId = 9102;
  static const _afternoonId = 9103;
  static const _eveningId = 9104;

  final _log = Logger('MealReminderService');
  final ConfigRepository _configRepository;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  bool _initialized = false;

  MealReminderService(
    this._configRepository, [
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  ]) : _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    if (!Platform.isAndroid) {
      _initialized = true;
      return;
    }

    tz.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (error, stackTrace) {
      _log.warning('Unable to resolve device timezone', error, stackTrace);
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notificationsPlugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.defaultImportance,
    );
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  Future<bool> requestPermissionIfNeeded() async {
    if (!Platform.isAndroid) {
      return true;
    }
    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final status = await Permission.notification.status;
    var notificationsGranted = status.isGranted;
    if (!notificationsGranted) {
      notificationsGranted =
          await androidPlugin?.requestNotificationsPermission() ?? false;
    }

    if (!notificationsGranted) {
      return false;
    }

    final exactAlarmsGranted =
        await androidPlugin?.requestExactAlarmsPermission();
    return exactAlarmsGranted ?? true;
  }

  Future<bool> syncFromConfig({
    bool requestPermissionIfNeeded = false,
  }) async {
    try {
      await initialize();
      final config = await _configRepository.getConfig();

      if (!config.mealRemindersEnabled) {
        await cancelAllMealReminders();
        return true;
      }

      if (requestPermissionIfNeeded &&
          !await this.requestPermissionIfNeeded()) {
        return false;
      }

      await _scheduleFromConfig(config);
      return true;
    } catch (error, stackTrace) {
      _log.severe('Failed to sync meal reminders', error, stackTrace);
      return false;
    }
  }

  Future<void> cancelAllMealReminders() async {
    await initialize();
    await _notificationsPlugin.cancel(id: _morningId);
    await _notificationsPlugin.cancel(id: _lunchId);
    await _notificationsPlugin.cancel(id: _afternoonId);
    await _notificationsPlugin.cancel(id: _eveningId);
  }

  Future<void> _scheduleFromConfig(ConfigEntity config) async {
    await cancelAllMealReminders();

    await _scheduleDailyReminder(
      id: _morningId,
      title: _isEs(config) ? 'Desayuno pendiente' : 'Breakfast reminder',
      body: _isEs(config)
          ? 'No olvides registrar tu desayuno.'
          : 'Do not forget to log your breakfast.',
      minutesOfDay: config.mealReminderMorningMinutes,
    );
    await _scheduleDailyReminder(
      id: _lunchId,
      title: _isEs(config) ? 'Comida pendiente' : 'Lunch reminder',
      body: _isEs(config)
          ? 'Registra la comida cuando termines.'
          : 'Log your lunch when you are done.',
      minutesOfDay: config.mealReminderLunchMinutes,
    );
    await _scheduleDailyReminder(
      id: _afternoonId,
      title: _isEs(config) ? 'Snack pendiente' : 'Snack reminder',
      body: _isEs(config)
          ? 'Aún puedes registrar tu snack o merienda.'
          : 'You can still log your snack.',
      minutesOfDay: config.mealReminderAfternoonMinutes,
    );
    await _scheduleDailyReminder(
      id: _eveningId,
      title: _isEs(config) ? 'Cena pendiente' : 'Dinner reminder',
      body: _isEs(config)
          ? 'Cierra el día registrando la cena.'
          : 'Close the day by logging dinner.',
      minutesOfDay: config.mealReminderEveningMinutes,
    );
  }

  Future<void> _scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int minutesOfDay,
  }) async {
    final scheduledDate = _nextInstanceOfTime(minutesOfDay);
    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (error, stackTrace) {
      _log.warning(
        'Exact scheduling failed for reminder $id. Falling back to inexact.',
        error,
        stackTrace,
      );
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int minutesOfDay) {
    final now = tz.TZDateTime.now(tz.local);
    final hour = minutesOfDay ~/ 60;
    final minute = minutesOfDay % 60;
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  bool _isEs(ConfigEntity config) {
    final configuredLocale = config.selectedLocale;
    if (configuredLocale != null && configuredLocale.isNotEmpty) {
      return configuredLocale.toLowerCase().startsWith('es');
    }

    final deviceLocale = PlatformDispatcher.instance.locale.languageCode;
    return deviceLocale.toLowerCase().startsWith('es');
  }
}
