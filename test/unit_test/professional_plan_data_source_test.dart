import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';
import 'package:macrotracker/features/professional_plan/data/dbo/pending_snapshot_sync_dbo.dart';
import 'package:macrotracker/features/professional_plan/data/data_source/professional_plan_data_source.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeIdentityService extends Fake implements SupabaseIdentityService {
  @override
  Future<String> ensureUserSession() async => 'user-123';
}

class MockPostgrestTransformBuilder<T> extends Fake
    implements PostgrestTransformBuilder<T> {
  final dynamic result;
  final bool isSingle;
  final bool isMaybeSingle;

  MockPostgrestTransformBuilder(this.result,
      {this.isSingle = false, this.isMaybeSingle = false});

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');
    if (memberName == 'then') {
      final Function onValue = invocation.positionalArguments[0];
      return Future.value(result).then((resolvedVal) {
        dynamic val = resolvedVal;
        if (isSingle || isMaybeSingle) {
          val = (resolvedVal is List)
              ? (resolvedVal.isNotEmpty ? resolvedVal.first : null)
              : resolvedVal;
        }
        return onValue(val);
      });
    }
    if (memberName == 'maybeSingle') {
      return MockPostgrestTransformBuilder<Map<String, dynamic>?>(result,
          isMaybeSingle: true);
    }
    if (memberName == 'single') {
      return MockPostgrestTransformBuilder<Map<String, dynamic>>(result,
          isSingle: true);
    }
    return this;
  }
}

class MockPostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final MockPostgrestTransformBuilder<T> transformBuilder;
  final List<String> calls = [];

  MockPostgrestFilterBuilder(this.transformBuilder);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');
    final args = invocation.positionalArguments.join(', ');
    calls.add('$memberName($args)');

    if (memberName == 'select') {
      return transformBuilder;
    }
    if (memberName == 'maybeSingle') {
      return MockPostgrestTransformBuilder<Map<String, dynamic>?>(
          transformBuilder.result,
          isMaybeSingle: true);
    }
    if (memberName == 'single') {
      return MockPostgrestTransformBuilder<Map<String, dynamic>>(
          transformBuilder.result,
          isSingle: true);
    }
    if (memberName == 'then') {
      final Function onValue = invocation.positionalArguments[0];
      return Future.value(transformBuilder.result).then((resolvedVal) {
        final listVal = (resolvedVal is List) ? resolvedVal : [resolvedVal];
        dynamic typedVal = listVal;
        final typeStr = T.toString();
        if (typeStr.contains('List<Map')) {
          typedVal = listVal.cast<Map<String, dynamic>>();
        } else if (typeStr.contains('Map')) {
          typedVal = (listVal.isNotEmpty) ? listVal.first : null;
        }
        return onValue(typedVal);
      });
    }
    return this;
  }
}

class MockSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final MockPostgrestFilterBuilder<List<Map<String, dynamic>>> filterBuilder;
  MockSupabaseQueryBuilder(this.filterBuilder);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');
    final args = invocation.positionalArguments.join(', ');
    filterBuilder.calls.add('$memberName($args)');
    return filterBuilder;
  }
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, dynamic> queries;
  final Future<dynamic> Function(String, Map<String, dynamic>?)? onRpc;

  FakeSupabaseClient({required this.queries, this.onRpc});

  @override
  SupabaseQueryBuilder from(String table) {
    final result = queries[table];
    final transform =
        MockPostgrestTransformBuilder<List<Map<String, dynamic>>>(result);
    final filter =
        MockPostgrestFilterBuilder<List<Map<String, dynamic>>>(transform);
    return MockSupabaseQueryBuilder(filter);
  }

  @override
  PostgrestFilterBuilder<T> rpc<T>(
    String fn, {
    Map<String, dynamic>? params,
    Object? get,
    dynamic headers,
    dynamic httpMethod,
  }) {
    if (onRpc != null) {
      final fut = onRpc!(fn, params);
      final transform = MockPostgrestTransformBuilder<T>(fut);
      return MockPostgrestFilterBuilder<T>(transform) as dynamic;
    }
    final transform = MockPostgrestTransformBuilder<T>(null);
    return MockPostgrestFilterBuilder<T>(transform) as dynamic;
  }
}

class _ThrowingSupabaseClient extends Fake implements SupabaseClient {
  final SupabaseClient fallback;

  _ThrowingSupabaseClient(this.fallback);

  @override
  SupabaseQueryBuilder from(String table) {
    if (table == 'client_shared_snapshots') {
      throw StateError('network timeout');
    }
    return fallback.from(table);
  }
}

ProfessionalConnectionEntity _connection({
  String relationshipId = 'rel-1',
  String professionalId = 'pro-1',
  String clientId = 'cli-1',
  String professionalName = 'Dr. Test',
  DateTime? connectedAt,
  DateTime? consentAcceptedAt,
  DateTime? lastPlanSyncAt,
  DateTime? lastSnapshotSyncAt,
  int pendingSyncCount = 0,
  String sharingMode = 'detailed',
  bool messagesEnabled = true,
  String connectionStatus = 'active',
  NutritionPlanEntity? activePlan,
}) {
  final now = DateTime(2026, 6, 15);
  return ProfessionalConnectionEntity(
    relationshipId: relationshipId,
    professionalId: professionalId,
    clientId: clientId,
    professionalName: professionalName,
    connectedAt: connectedAt ?? now,
    consentAcceptedAt: consentAcceptedAt ?? now,
    lastPlanSyncAt: lastPlanSyncAt ?? now,
    lastSnapshotSyncAt: lastSnapshotSyncAt,
    pendingSyncCount: pendingSyncCount,
    sharingMode: sharingMode,
    messagesEnabled: messagesEnabled,
    connectionStatus: connectionStatus,
    activePlan: activePlan,
  );
}

void main() {
  group('ProfessionalPlanDataSource Tests', () {
    late Directory tempDir;
    late HiveDBProvider hiveProvider;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp
          .createTemp('macrotracker_plan_datasource_test_');

      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return tempDir.path;
      });

      hiveProvider = HiveDBProvider();
      final key = Hive.generateSecureKey();
      await hiveProvider.initHiveDB(Uint8List.fromList(key));
    });

    tearDown(() async {
      await hiveProvider.clearAllData();
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
        'getActiveConnection returns null when empty, and saves connection correctly',
        () async {
      final queries = <String, dynamic>{};
      final client = FakeSupabaseClient(queries: queries);
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      expect(await ds.getActiveConnection(), isNull);

      final connection = _connection(
        relationshipId: 'rel-1',
        professionalName: 'Dr. Test',
      );

      await ds.saveActiveConnection(connection);
      final active = await ds.getActiveConnection();
      expect(active, isNotNull);
      expect(active!.relationshipId, 'rel-1');
      expect(active.professionalName, 'Dr. Test');
    });

    test(
        'clearActiveConnection deletes local keys and updates status to revoked in remote db',
        () async {
      final queries = <String, dynamic>{
        'professional_clients': {
          'id': 'rel-1',
          'status': 'revoked',
        },
      };
      final client = FakeSupabaseClient(queries: queries);
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final connection = _connection(
        relationshipId: 'rel-1',
        clientId: 'cli-1',
      );

      await ds.saveActiveConnection(connection);
      expect(await ds.getActiveConnection(), isNotNull);

      await ds.clearActiveConnection();
      expect(await ds.getActiveConnection(), isNull);
    });

    test('fetchInvitePreview calls supabase preview_client_invite RPC',
        () async {
      final queries = <String, dynamic>{};
      final client = FakeSupabaseClient(
        queries: queries,
        onRpc: (fn, params) async {
          expect(fn, 'preview_client_invite');
          expect(params?['p_invite_code'], 'CODE123');
          return {
            'id': 'invite-1',
            'code': 'CODE123',
            'professional_id': 'pro-1',
            'professionals': {
              'display_name': 'Dr. Test Preview',
            },
            'status': 'pending',
            'expires_at': '2026-07-15T00:00:00Z',
          };
        },
      );

      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final preview = await ds.fetchInvitePreview('code 123 ');
      expect(preview, isNotNull);
      expect(preview!.professionalName, 'Dr. Test Preview');
      expect(preview.inviteId, 'invite-1');
    });

    test('debug invite preview and acceptInvite use local debug data',
        () async {
      final client = FakeSupabaseClient(queries: const {});
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final preview = await ds.fetchInvitePreview(' debug ');
      expect(preview, isNotNull);
      expect(preview!.code, ProfessionalPlanDataSource.debugInviteCode);
      expect(preview.professionalName, 'Nutricionista Debug');

      final connection = await ds.acceptInvite('debug');
      expect(connection.relationshipId, 'debug-relationship');
      expect(connection.activePlan, isNotNull);
      expect((await ds.getActiveConnection())?.relationshipId,
          'debug-relationship');
    });

    test('acceptInvite accepts client invite and returns connection entity',
        () async {
      final queries = <String, dynamic>{
        'nutrition_plans': {
          'id': 'plan-1',
          'client_id': 'cli-123',
          'name': 'Active Plan',
          'status': 'active',
        },
      };
      final client = FakeSupabaseClient(
        queries: queries,
        onRpc: (fn, params) async {
          expect(fn, 'accept_client_invite');
          return {
            'relationship_id': 'rel-1',
            'professional_id': 'pro-1',
            'client_id': 'cli-123',
            'professional_name': 'Dr. Test',
            'connected_at': '2026-06-15T12:00:00Z',
            'consent_accepted_at': '2026-06-15T12:00:00Z',
            'sharing_mode': 'detailed',
            'status': 'active',
          };
        },
      );

      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final conn = await ds.acceptInvite('CODE123');
      expect(conn.relationshipId, 'rel-1');
      expect(conn.clientId, 'cli-123');
      expect(conn.activePlan, isNotNull);
      expect(conn.activePlan!.name, 'Active Plan');
    });

    test('refreshActivePlan fetches latest connection status and active plan',
        () async {
      final queries = <String, dynamic>{
        'professional_clients': {
          'id': 'rel-1',
          'professional_id': 'pro-1',
          'client_id': 'cli-1',
          'status': 'active',
          'connected_at': '2026-06-15T12:00:00Z',
          'consent_accepted_at': '2026-06-15T12:00:00Z',
          'sharing_mode': 'detailed',
          'messages_enabled': true,
          'professionals': {
            'display_name': 'Dr. Test Display',
            'business_name': 'Wellness Studio',
          },
        },
        'nutrition_plans': {
          'id': 'plan-1',
          'client_id': 'cli-1',
          'name': 'Refreshed Plan',
          'status': 'active',
        },
      };
      final client = FakeSupabaseClient(queries: queries);
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final connection = _connection(
        relationshipId: 'rel-1',
        professionalId: 'pro-1',
        clientId: 'cli-1',
        professionalName: 'Dr. Old',
        sharingMode: 'aggregate',
      );
      await ds.saveActiveConnection(connection);

      final refreshed = await ds.refreshActivePlan();
      expect(refreshed, isNotNull);
      expect(refreshed!.professionalName,
          'Wellness Studio'); // Prefers business name
      expect(refreshed.sharingMode, 'detailed');
      expect(refreshed.activePlan, isNotNull);
      expect(refreshed.activePlan!.name, 'Refreshed Plan');
    });

    test(
        'uploadDiaryEntries deletes existing and inserts new entries when mode is detailed',
        () async {
      final queries = <String, dynamic>{
        'client_diary_entries': null,
      };
      final client = FakeSupabaseClient(queries: queries);
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final connection = _connection(
        relationshipId: 'rel-1',
        professionalId: 'pro-1',
        clientId: 'cli-1',
        sharingMode: 'detailed',
      );

      await ds.uploadDiaryEntries(
        connection: connection,
        day: DateTime(2026, 6, 15),
        entries: [
          {'name': 'Apple', 'kcal': 95.0},
        ],
      );
    });

    test('uploadDiaryEntries does not upload if sharingMode is aggregate',
        () async {
      final queries = <String, dynamic>{
        'client_diary_entries': null,
      };
      final client = FakeSupabaseClient(queries: queries);
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final connection = _connection(
        relationshipId: 'rel-1',
        sharingMode: 'aggregate',
      );

      await ds.uploadDiaryEntries(
        connection: connection,
        day: DateTime(2026, 6, 15),
        entries: [
          {'name': 'Apple', 'kcal': 95.0},
        ],
      );
    });

    test('saveDailyNote and getDailyNote write and read daily notes locally',
        () async {
      final queries = <String, dynamic>{};
      final client = FakeSupabaseClient(queries: queries);
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final day = DateTime(2026, 6, 15);
      expect(await ds.getDailyNote(day), isNull);

      await ds.saveDailyNote(day, 'Had a great leg workout today.');
      expect(await ds.getDailyNote(day), 'Had a great leg workout today.');
    });

    test('uploadDailySnapshot queues failed uploads and updates pending count',
        () async {
      final client = FakeSupabaseClient(
        queries: const {},
        onRpc: (fn, params) async => null,
      );
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );
      final connection = _connection(
        relationshipId: 'rel-queue',
        professionalId: 'pro-queue',
        clientId: 'cli-queue',
      );
      await ds.saveActiveConnection(connection);

      final throwingClient = FakeSupabaseClient(
        queries: const {},
        onRpc: (fn, params) async => null,
      );
      final throwingDs = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        _ThrowingSupabaseClient(throwingClient),
        FakeIdentityService(),
      );

      await expectLater(
        throwingDs.uploadDailySnapshot(
          connection: connection,
          day: DateTime(2026, 6, 15),
          kcalActual: 2100,
          kcalTarget: 2200,
          carbsActual: 250,
          carbsTarget: 260,
          fatActual: 70,
          fatTarget: 75,
          proteinActual: 160,
          proteinTarget: 165,
          mealsLogged: 4,
          notes: 'Queued note',
          weightKg: 80,
          waistCm: 82,
        ),
        throwsStateError,
      );

      expect(await ds.getPendingSyncCount(), 1);
      final active = await ds.getActiveConnection();
      expect(active!.pendingSyncCount, 1);
      expect(await ds.getDailyNote(DateTime(2026, 6, 15)), 'Queued note');
    });

    test('processPendingSyncs clears queued snapshot after successful upload',
        () async {
      final client = FakeSupabaseClient(queries: const {});
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );
      final connection = _connection(relationshipId: 'rel-pending');
      await ds.saveActiveConnection(connection);

      await hiveProvider.professionalPlanSyncQueueBox.put(
        'pending-1',
        PendingSnapshotSyncDBO(
          id: 'pending-1',
          relationshipId: 'rel-pending',
          professionalId: 'pro-1',
          clientId: 'cli-1',
          day: DateTime(2026, 6, 15),
          kcalActual: 2100,
          kcalTarget: 2200,
          carbsActual: 250,
          carbsTarget: 260,
          fatActual: 70,
          fatTarget: 75,
          proteinActual: 160,
          proteinTarget: 165,
          mealsLogged: 4,
          createdAt: DateTime(2026, 6, 15, 12),
          notes: 'Pending note',
          weightKg: 80,
          waistCm: 82,
        ),
      );

      await ds.processPendingSyncs();

      expect(await ds.getPendingSyncCount(), 0);
      expect((await ds.getActiveConnection())!.pendingSyncCount, 0);
      expect((await ds.getActiveConnection())!.lastSnapshotSyncAt, isNotNull);
    });

    test('getMessages fetches remote message rows and sorts them', () async {
      final queries = <String, dynamic>{
        'professional_client_messages': [
          {
            'id': 'msg-1',
            'author_role': 'professional',
            'body': 'Hello Client',
            'created_at': '2026-06-15T10:00:00Z',
            'client_read_at': null,
          },
          {
            'id': 'msg-2',
            'author_role': 'client',
            'body': 'Hello Coach',
            'created_at': '2026-06-15T11:00:00Z',
            'client_read_at': '2026-06-15T11:01:00Z',
          }
        ],
      };
      final client = FakeSupabaseClient(queries: queries);
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final connection = _connection(
        relationshipId: 'rel-1',
      );

      final thread = await ds.getMessages(connection: connection);
      expect(thread.isSupported, isTrue);
      expect(thread.messages, hasLength(2));
      // Sorted newest first: msg-2, then msg-1
      expect(thread.messages[0].id, 'msg-2');
      expect(thread.messages[0].isRead, isTrue); // Client authored
      expect(thread.messages[1].id, 'msg-1');
      expect(thread.messages[1].isRead,
          isFalse); // Professional authored and client_read_at is null
    });

    test(
        'getUnseenSectionCount and markSectionSeen track debug plan and messages',
        () async {
      final client = FakeSupabaseClient(queries: const {});
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final connection = await ds.acceptInvite('debug');

      expect(await ds.getUnseenSectionCount(), 2);

      await ds.markSectionSeen(connection: connection);
      expect(await ds.getUnseenSectionCount(), 0);

      await ds.markMessageRead(
        connection: connection,
        messageId: 'debug-message-2',
      );
      final thread = await ds.getMessages(connection: connection);
      expect(thread.unreadCount, 0);
    });

    test(
        'markMessageRead sends read timestamp to database and keeps local flag override',
        () async {
      final queries = <String, dynamic>{
        'professional_client_messages': {
          'id': 'msg-1',
          'client_read_at': '2026-06-15T12:00:00Z',
        },
      };
      final client = FakeSupabaseClient(queries: queries);
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final connection = _connection(
        relationshipId: 'rel-1',
      );

      await ds.markMessageRead(connection: connection, messageId: 'msg-1');

      // Verify it persists in local box under message reads
      final localReadKey = 'professional_client_message_reads_rel-1';
      final readIds =
          hiveProvider.professionalPlanBox.get(localReadKey) as List?;
      expect(readIds, isNotNull);
      expect(readIds, contains('msg-1'));
    });

    test('sendMessage inserts client message row into supabase', () async {
      final queries = <String, dynamic>{
        'professional_client_messages': {
          'id': 'new-msg-1',
          'author_role': 'client',
          'body': 'Ate oats',
          'created_at': '2026-06-15T12:00:00Z',
        },
      };
      final client = FakeSupabaseClient(queries: queries);
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final connection = _connection(
        relationshipId: 'rel-1',
        professionalId: 'pro-1',
        clientId: 'cli-1',
      );

      final msg =
          await ds.sendMessage(connection: connection, body: ' Ate oats ');
      expect(msg.id, 'new-msg-1');
      expect(msg.body, 'Ate oats'); // Trimmed
      expect(msg.authorRole, 'client');
    });

    test('sendMessage throws ArgumentError when message body is empty',
        () async {
      final queries = <String, dynamic>{};
      final client = FakeSupabaseClient(queries: queries);
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final connection = _connection(
        relationshipId: 'rel-1',
      );

      expect(() => ds.sendMessage(connection: connection, body: '  '),
          throwsArgumentError);
    });

    test('getSharingScope returns sharing mode features correctly', () async {
      final queries = <String, dynamic>{};
      final client = FakeSupabaseClient(queries: queries);
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final connectionDetailed = _connection(
        relationshipId: 'rel-1',
        sharingMode: 'detailed',
      );

      final scopeDetailed =
          await ds.getSharingScope(connection: connectionDetailed);
      expect(scopeDetailed.sharingMode, 'detailed');
      expect(scopeDetailed.sharedNow, contains('per_meal_detail'));

      final connectionAggregate = _connection(
        relationshipId: 'rel-1',
        sharingMode: 'aggregate',
      );

      final scopeAggregate =
          await ds.getSharingScope(connection: connectionAggregate);
      expect(scopeAggregate.sharingMode, 'aggregate');
      expect(scopeAggregate.notSharedYet, contains('per_meal_detail'));
    });

    test(
        'updateSharingMode updates remote database status and local active connection cache',
        () async {
      final queries = <String, dynamic>{
        'professional_clients': {
          'id': 'rel-1',
          'sharing_mode': 'detailed',
        },
      };
      final client = FakeSupabaseClient(queries: queries);
      final ds = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        client,
        FakeIdentityService(),
      );

      final connection = _connection(
        relationshipId: 'rel-1',
        clientId: 'cli-1',
        sharingMode: 'aggregate',
      );

      await ds.saveActiveConnection(connection);
      expect((await ds.getActiveConnection())!.sharingMode, 'aggregate');

      await ds.updateSharingMode(
          relationshipId: 'rel-1', clientId: 'cli-1', sharingMode: 'detailed');

      expect((await ds.getActiveConnection())!.sharingMode, 'detailed');
    });
  });
}
