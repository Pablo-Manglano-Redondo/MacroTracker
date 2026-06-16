import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/services/push_notification_service.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('PushNotificationService', () {
    test('initialize registers current token and handles initial tap',
        () async {
      final messaging = _FakePushMessagingClient(
        token: 'fcm-token-1',
        initialMessage: const RemoteMessage(data: {'route': 'messages'}),
      );
      final supabase = _FakeSupabaseClient();
      final service = PushNotificationService(
        supabase,
        _FakeIdentityService(),
        _FakeLocalNotificationsPlugin(),
        messaging,
      );

      final tapFuture = service.onNotificationTap.first;
      await service.initialize();

      expect(messaging.requestPermissionCalls, 1);
      expect(supabase.calls, hasLength(1));
      expect(supabase.calls.single.fn, 'upsert_device_token');
      expect(supabase.calls.single.params?['p_token'], 'fcm-token-1');
      expect(await tapFuture, {'route': 'messages'});

      service.dispose();
    });

    test('token refresh registers refreshed token', () async {
      final messaging = _FakePushMessagingClient(token: 'initial-token');
      final supabase = _FakeSupabaseClient();
      final service = PushNotificationService(
        supabase,
        _FakeIdentityService(),
        _FakeLocalNotificationsPlugin(),
        messaging,
      );

      await service.initialize();
      messaging.emitTokenRefresh('refreshed-token');
      await Future<void>.delayed(Duration.zero);

      expect(
        supabase.calls.map((call) => call.params?['p_token']),
        containsAll(['initial-token', 'refreshed-token']),
      );

      service.dispose();
    });

    test('foreground notification shows local notification with JSON payload',
        () async {
      final messaging = _FakePushMessagingClient(token: null);
      final localNotifications = _FakeLocalNotificationsPlugin();
      final service = PushNotificationService(
        _FakeSupabaseClient(),
        _FakeIdentityService(),
        localNotifications,
        messaging,
      );

      await service.initialize();
      messaging.emitMessage(const RemoteMessage(
        data: {'threadId': 'thread-1'},
        notification: RemoteNotification(
          title: 'Nuevo mensaje',
          body: 'Tu nutricionista respondió',
        ),
      ));
      await Future<void>.delayed(Duration.zero);

      expect(localNotifications.initializeCalls, 1);
      expect(localNotifications.shown, hasLength(1));
      expect(localNotifications.shown.single.title, 'Nuevo mensaje');
      expect(
          localNotifications.shown.single.body, 'Tu nutricionista respondió');
      expect(
          localNotifications.shown.single.payload, '{"threadId":"thread-1"}');

      service.dispose();
    });

    test('message opened stream publishes notification tap payload', () async {
      final messaging = _FakePushMessagingClient(token: null);
      final service = PushNotificationService(
        _FakeSupabaseClient(),
        _FakeIdentityService(),
        _FakeLocalNotificationsPlugin(),
        messaging,
      );

      await service.initialize();
      final tapFuture = service.onNotificationTap.first;
      messaging.emitMessageOpened(const RemoteMessage(data: {'id': 'p1'}));

      expect(await tapFuture, {'id': 'p1'});

      service.dispose();
    });

    test('initialize swallows token registration failures', () async {
      final messaging = _FakePushMessagingClient(token: 'fcm-token-1');
      final supabase = _FakeSupabaseClient();
      final service = PushNotificationService(
        supabase,
        _FakeIdentityService(shouldThrow: true),
        _FakeLocalNotificationsPlugin(),
        messaging,
      );

      await service.initialize();

      expect(messaging.requestPermissionCalls, 1);
      expect(supabase.calls, isEmpty);

      service.dispose();
    });

    test('unregisterToken deletes current token when present', () async {
      final messaging = _FakePushMessagingClient(token: 'fcm-token-1');
      final supabase = _FakeSupabaseClient();
      final service = PushNotificationService(
        supabase,
        _FakeIdentityService(),
        _FakeLocalNotificationsPlugin(),
        messaging,
      );

      await service.initialize();
      await service.unregisterToken();

      expect(supabase.calls.last.fn, 'delete_device_token');
      expect(supabase.calls.last.params?['p_token'], 'fcm-token-1');

      service.dispose();
    });
  });
}

class _FakePushMessagingClient implements PushMessagingClient {
  final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();
  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _messageOpenedController =
      StreamController<RemoteMessage>.broadcast();

  String? token;
  RemoteMessage? initialMessage;
  int requestPermissionCalls = 0;

  _FakePushMessagingClient({
    required this.token,
    this.initialMessage,
  });

  void emitTokenRefresh(String token) {
    _tokenRefreshController.add(token);
  }

  void emitMessage(RemoteMessage message) {
    _messageController.add(message);
  }

  void emitMessageOpened(RemoteMessage message) {
    _messageOpenedController.add(message);
  }

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) async {
    requestPermissionCalls++;
    return const NotificationSettings(
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.disabled,
      authorizationStatus: AuthorizationStatus.authorized,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.disabled,
      criticalAlert: AppleNotificationSetting.disabled,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      timeSensitive: AppleNotificationSetting.disabled,
      sound: AppleNotificationSetting.enabled,
      providesAppNotificationSettings: AppleNotificationSetting.disabled,
    );
  }

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Stream<RemoteMessage> get onMessage => _messageController.stream;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      _messageOpenedController.stream;

  @override
  Future<RemoteMessage?> getInitialMessage() async => initialMessage;
}

class _FakeLocalNotificationsPlugin extends Fake
    implements FlutterLocalNotificationsPlugin {
  int initializeCalls = 0;
  final List<_ShownNotification> shown = <_ShownNotification>[];

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
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) async {
    shown.add(_ShownNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    ));
  }
}

class _ShownNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  const _ShownNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}

class _FakeIdentityService extends Fake implements SupabaseIdentityService {
  final bool shouldThrow;

  _FakeIdentityService({this.shouldThrow = false});

  @override
  Future<String> ensureUserSession() async {
    if (shouldThrow) {
      throw StateError('session unavailable');
    }
    return 'user-1';
  }
}

class _FakeSupabaseClient extends Fake implements SupabaseClient {
  final List<_RpcCall> calls = <_RpcCall>[];

  @override
  PostgrestFilterBuilder<T> rpc<T>(
    String fn, {
    Map<String, dynamic>? params,
    Object? get,
    dynamic headers,
    dynamic httpMethod,
  }) {
    calls.add(_RpcCall(fn, params));
    return _FakePostgrestFilterBuilder<T>() as PostgrestFilterBuilder<T>;
  }
}

class _FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');
    if (memberName == 'then') {
      final Function onValue = invocation.positionalArguments[0];
      final Function? onError = invocation.namedArguments[#onError];
      return Future<void>.value().then(
        (_) => onValue(null),
        onError: onError,
      );
    }
    return this;
  }
}

class _RpcCall {
  final String fn;
  final Map<String, dynamic>? params;

  const _RpcCall(this.fn, this.params);
}
