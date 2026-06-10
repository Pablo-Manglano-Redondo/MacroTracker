import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  final _log = Logger('PushNotificationService');
  final SupabaseClient _supabaseClient;
  final SupabaseIdentityService _identityService;
  final FlutterLocalNotificationsPlugin _localNotifications;
  FirebaseMessaging? _fcm;
  bool _initialized = false;

  PushNotificationService(
    this._supabaseClient,
    this._identityService, [
    FlutterLocalNotificationsPlugin? localNotifications,
  ]) : _localNotifications = localNotifications ?? FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _fcm = FirebaseMessaging.instance;

      // Request permission
      final permission = await _fcm!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      if (kDebugMode) {
        _log.info('FCM permission: ${permission.authorizationStatus}');
      }

      // Register token
      await _registerToken();

      // Listen for token refresh
      _fcm!.onTokenRefresh.listen((token) {
        _registerToken(token);
      });

      // Handle foreground messages via local notification
      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app was in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app was terminated
      final initialMessage = await _fcm!.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _initialized = true;
      _log.info('PushNotificationService initialized');
    } catch (e) {
      _log.warning('Failed to initialize FCM: $e');
    }
  }

  Future<void> _registerToken([String? token]) async {
    try {
      final fcmToken = token ?? await _fcm?.getToken();
      if (fcmToken == null) return;

      await _identityService.ensureUserSession();
      await _supabaseClient.rpc('upsert_device_token', params: {
        'p_token': fcmToken,
        'p_platform': defaultTargetPlatform == TargetPlatform.android ? 'android' : 'ios',
      });
    } catch (e) {
      _log.warning('Failed to register FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'push_notifications',
          'Push Notifications',
          channelDescription: 'Notifications from your nutritionist',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    // The main_screen or navigator should listen to this stream
    _onNotificationTapController.add(message.data);
  }

  final _onNotificationTapController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onNotificationTap => _onNotificationTapController.stream;

  void dispose() {
    _onNotificationTapController.close();
  }

  Future<void> unregisterToken() async {
    try {
      final fcmToken = await _fcm?.getToken();
      if (fcmToken != null) {
        await _supabaseClient.rpc('delete_device_token', params: {
          'p_token': fcmToken,
        });
      }
    } catch (e) {
      _log.warning('Failed to unregister FCM token: $e');
    }
  }
}
