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
  PushMessagingClient? _messagingClient;
  bool _initialized = false;

  PushNotificationService(
    this._supabaseClient,
    this._identityService, [
    FlutterLocalNotificationsPlugin? localNotifications,
    PushMessagingClient? messagingClient,
  ])  : _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin(),
        _messagingClient = messagingClient;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final messagingClient =
          _messagingClient ??= FirebasePushMessagingClient();

      // Request permission
      final permission = await messagingClient.requestPermission(
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
      messagingClient.onTokenRefresh.listen((token) {
        _registerToken(token);
      });

      // Handle foreground messages via local notification
      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null || payload.isEmpty) {
            return;
          }
          try {
            final decoded = jsonDecode(payload);
            if (decoded is Map) {
              _onNotificationTapController.add(
                decoded.map(
                  (key, value) => MapEntry(key.toString(), value),
                ),
              );
            }
          } catch (_) {}
        },
      );

      messagingClient.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app was in background
      messagingClient.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app was terminated
      final initialMessage = await messagingClient.getInitialMessage();
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
      final fcmToken = token ?? await _messagingClient?.getToken();
      if (fcmToken == null) return;

      await _identityService.ensureUserSession();
      await _supabaseClient.rpc('upsert_device_token', params: {
        'p_token': fcmToken,
        'p_platform':
            defaultTargetPlatform == TargetPlatform.android ? 'android' : 'ios',
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

  final _onNotificationTapController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onNotificationTap =>
      _onNotificationTapController.stream;

  void dispose() {
    _onNotificationTapController.close();
  }

  Future<void> unregisterToken() async {
    try {
      final fcmToken = await _messagingClient?.getToken();
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

abstract class PushMessagingClient {
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  });

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  Stream<RemoteMessage> get onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage();
}

class FirebasePushMessagingClient implements PushMessagingClient {
  final FirebaseMessaging _firebaseMessaging;

  FirebasePushMessagingClient([FirebaseMessaging? firebaseMessaging])
      : _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) {
    return _firebaseMessaging.requestPermission(
      alert: alert,
      announcement: announcement,
      badge: badge,
      carPlay: carPlay,
      criticalAlert: criticalAlert,
      provisional: provisional,
      sound: sound,
    );
  }

  @override
  Future<String?> getToken() => _firebaseMessaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<RemoteMessage?> getInitialMessage() =>
      _firebaseMessaging.getInitialMessage();
}
