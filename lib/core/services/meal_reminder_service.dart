import 'dart:io';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MealReminderService {
  static const _channelId = 'meal_reminders';

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
    if (!Platform.isAndroid && !Platform.isIOS) {
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
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _notificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
    );

    if (Platform.isAndroid) {
      final strings = await S.load(
        Locale(PlatformDispatcher.instance.locale.languageCode),
      );
      final channel = AndroidNotificationChannel(
        _channelId,
        strings.mealReminderChannelName,
        description: strings.mealReminderChannelDescription,
        importance: Importance.defaultImportance,
      );
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    _initialized = true;
  }

  Future<bool> requestPermissionIfNeeded() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final status = await Permission.notification.status;
      var notificationsGranted = status.isGranted;
      if (!notificationsGranted) {
        notificationsGranted =
            await androidPlugin?.requestNotificationsPermission() ?? false;
      }
      return notificationsGranted;
    } else if (Platform.isIOS) {
      final iosPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      final status = await Permission.notification.request();
      return status.isGranted;
    }

    return true;
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
    final strings = await S.load(Locale(_languageCode(config)));

    await _scheduleDailyReminder(
      id: _morningId,
      title: strings.mealReminderBreakfastTitle,
      body: strings.mealReminderBreakfastBody,
      channelName: strings.mealReminderChannelName,
      channelDescription: strings.mealReminderChannelDescription,
      minutesOfDay: config.mealReminderMorningMinutes,
    );
    await _scheduleDailyReminder(
      id: _lunchId,
      title: strings.mealReminderLunchTitle,
      body: strings.mealReminderLunchBody,
      channelName: strings.mealReminderChannelName,
      channelDescription: strings.mealReminderChannelDescription,
      minutesOfDay: config.mealReminderLunchMinutes,
    );
    await _scheduleDailyReminder(
      id: _afternoonId,
      title: strings.mealReminderSnackTitle,
      body: strings.mealReminderSnackBody,
      channelName: strings.mealReminderChannelName,
      channelDescription: strings.mealReminderChannelDescription,
      minutesOfDay: config.mealReminderAfternoonMinutes,
    );
    await _scheduleDailyReminder(
      id: _eveningId,
      title: strings.mealReminderDinnerTitle,
      body: strings.mealReminderDinnerBody,
      channelName: strings.mealReminderChannelName,
      channelDescription: strings.mealReminderChannelDescription,
      minutesOfDay: config.mealReminderEveningMinutes,
    );
  }

  Future<void> _scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required String channelName,
    required String channelDescription,
    required int minutesOfDay,
  }) async {
    final scheduledDate = _nextInstanceOfTime(minutesOfDay);
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
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

  String _languageCode(ConfigEntity config) {
    final configuredLocale = config.selectedLocale;
    if (configuredLocale != null && configuredLocale.isNotEmpty) {
      return configuredLocale.split('_').first.toLowerCase();
    }

    final deviceLocale = PlatformDispatcher.instance.locale.languageCode;
    return deviceLocale.toLowerCase();
  }
}
