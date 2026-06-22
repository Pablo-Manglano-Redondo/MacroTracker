import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';
import 'package:macrotracker/features/professional_plan/data/data_source/professional_plan_data_source.dart';
import 'package:macrotracker/features/professional_plan/data/dbo/pending_snapshot_sync_dbo.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabaseIdentityService extends Fake
    implements SupabaseIdentityService {
  final Object? ensureUserSessionError;

  FakeSupabaseIdentityService({this.ensureUserSessionError});

  @override
  Future<String> ensureUserSession() async {
    final error = ensureUserSessionError;
    if (error != null) {
      throw error;
    }
    return 'user-1';
  }
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final Future<void> Function(Map<String, dynamic> data) onUpsert;

  FakeSupabaseClient({required this.onUpsert});

  @override
  SupabaseQueryBuilder from(String table) {
    if (table == 'client_shared_snapshots') {
      return FakeSupabaseQueryBuilder(onUpsert: onUpsert);
    }
    throw UnimplementedError();
  }
}

class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final Future<void> Function(Map<String, dynamic> data) onUpsert;

  FakeSupabaseQueryBuilder({required this.onUpsert});

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> upsert(
    Object values, {
    Object? onConflict,
    bool ignoreDuplicates = false,
    bool defaultToNull = false,
  }) {
    if (values is Map<String, dynamic>) {
      return FakePostgrestFilterBuilder(
        future: onUpsert(values).then((_) => <Map<String, dynamic>>[]),
      );
    }
    throw UnimplementedError();
  }
}

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final Future<T> future;

  FakePostgrestFilterBuilder({required this.future});

  @override
  Future<TResult> then<TResult>(
    FutureOr<TResult> Function(T value) onValue, {
    Function? onError,
  }) {
    return future.then(onValue, onError: onError);
  }
}

class StubProfessionalPlanDataSource extends ProfessionalPlanDataSource {
  final ProfessionalMessageThreadEntity stubMessages;

  StubProfessionalPlanDataSource({
    required Box<dynamic> box,
    required Box<PendingSnapshotSyncDBO> syncQueueBox,
    required SupabaseClient supabaseClient,
    required SupabaseIdentityService identityService,
    required this.stubMessages,
  }) : super(
          box,
          syncQueueBox,
          supabaseClient,
          identityService,
        );

  @override
  Future<ProfessionalMessageThreadEntity> getMessages({
    required ProfessionalConnectionEntity connection,
  }) async {
    return stubMessages;
  }
}

void main() {
  group('ProfessionalPlan Sync Queue Tests', () {
    late Directory tempDir;
    late HiveDBProvider hiveProvider;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp
          .createTemp('macrotracker_sync_queue_test_');

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

    test('uploadDailySnapshot queues failed sync requests on network error',
        () async {
      final fakeSupabase = FakeSupabaseClient(
        onUpsert: (data) async {
          throw const SocketException('No internet connection');
        },
      );

      final dataSource = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        fakeSupabase,
        FakeSupabaseIdentityService(),
      );

      final connection = ProfessionalConnectionEntity(
        relationshipId: 'rel-123',
        professionalId: 'pro-456',
        clientId: 'user-789',
        professionalName: 'Dr. John Doe',
        connectedAt: DateTime.now(),
        consentAcceptedAt: DateTime.now(),
        lastPlanSyncAt: DateTime.now(),
        lastSnapshotSyncAt: null,
        pendingSyncCount: 0,
        sharingMode: 'aggregate',
        messagesEnabled: false,
        connectionStatus: 'active',
        activePlan: null,
      );

      await expectLater(
        dataSource.uploadDailySnapshot(
          connection: connection,
          day: DateTime(2026, 6, 7),
          kcalActual: 2000,
          kcalTarget: 2200,
          carbsActual: 220,
          carbsTarget: 250,
          fatActual: 60,
          fatTarget: 70,
          proteinActual: 140,
          proteinTarget: 150,
          mealsLogged: 4,
        ),
        throwsA(isA<SocketException>()),
      );

      // Verify it was written to the queue
      expect(hiveProvider.professionalPlanSyncQueueBox.length, 1);
      final queuedItem =
          hiveProvider.professionalPlanSyncQueueBox.values.single;
      expect(queuedItem.relationshipId, 'rel-123');
      expect(queuedItem.kcalActual, 2000);
      expect(queuedItem.day, DateTime(2026, 6, 7));
    });

    test(
        'processPendingSyncs uploads queued requests successfully and clears them',
        () async {
      final List<Map<String, dynamic>> uploadedData = [];

      final fakeSupabase = FakeSupabaseClient(
        onUpsert: (data) async {
          uploadedData.add(data);
        },
      );

      final dataSource = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        fakeSupabase,
        FakeSupabaseIdentityService(),
      );

      final connection = ProfessionalConnectionEntity(
        relationshipId: 'rel-123',
        professionalId: 'pro-456',
        clientId: 'user-789',
        professionalName: 'Dr. John Doe',
        connectedAt: DateTime.now(),
        consentAcceptedAt: DateTime.now(),
        lastPlanSyncAt: DateTime.now(),
        lastSnapshotSyncAt: null,
        pendingSyncCount: 1,
        sharingMode: 'aggregate',
        messagesEnabled: false,
        connectionStatus: 'active',
        activePlan: null,
      );
      await dataSource.saveActiveConnection(connection);

      // Pre-populate queue
      final pendingItem = PendingSnapshotSyncDBO(
        id: 'rel-123_2026-06-07',
        relationshipId: 'rel-123',
        professionalId: 'pro-456',
        clientId: 'user-789',
        day: DateTime(2026, 6, 7),
        kcalActual: 2000,
        kcalTarget: 2200,
        carbsActual: 220,
        carbsTarget: 250,
        fatActual: 60,
        fatTarget: 70,
        proteinActual: 140,
        proteinTarget: 150,
        mealsLogged: 4,
        createdAt: DateTime.now(),
      );
      await hiveProvider.professionalPlanSyncQueueBox
          .put(pendingItem.id, pendingItem);
      expect(hiveProvider.professionalPlanSyncQueueBox.length, 1);

      // Process pending syncs
      await dataSource.processPendingSyncs();

      // Verify it uploaded successfully and removed from queue
      expect(uploadedData, hasLength(1));
      expect(uploadedData.single['kcal_actual'], 2000);
      expect(hiveProvider.professionalPlanSyncQueueBox.length, 0);
    });

    test('processPendingSyncs keeps queued snapshots on auth failure',
        () async {
      final fakeSupabase = FakeSupabaseClient(
        onUpsert: (data) async {},
      );

      final dataSource = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        fakeSupabase,
        FakeSupabaseIdentityService(
          ensureUserSessionError: StateError('session refresh required'),
        ),
      );

      final connection = ProfessionalConnectionEntity(
        relationshipId: 'rel-123',
        professionalId: 'pro-456',
        clientId: 'user-789',
        professionalName: 'Dr. John Doe',
        connectedAt: DateTime.now(),
        consentAcceptedAt: DateTime.now(),
        lastPlanSyncAt: DateTime.now(),
        lastSnapshotSyncAt: null,
        pendingSyncCount: 1,
        sharingMode: 'aggregate',
        messagesEnabled: false,
        connectionStatus: 'active',
        activePlan: null,
      );
      await dataSource.saveActiveConnection(connection);

      final pendingItem = PendingSnapshotSyncDBO(
        id: 'rel-123_2026-06-07',
        relationshipId: 'rel-123',
        professionalId: 'pro-456',
        clientId: 'user-789',
        day: DateTime(2026, 6, 7),
        kcalActual: 2000,
        kcalTarget: 2200,
        carbsActual: 220,
        carbsTarget: 250,
        fatActual: 60,
        fatTarget: 70,
        proteinActual: 140,
        proteinTarget: 150,
        mealsLogged: 4,
        createdAt: DateTime.now(),
      );
      await hiveProvider.professionalPlanSyncQueueBox
          .put(pendingItem.id, pendingItem);

      await dataSource.processPendingSyncs();

      expect(hiveProvider.professionalPlanSyncQueueBox.length, 1);
      expect(
        hiveProvider.professionalPlanSyncQueueBox
            .get(pendingItem.id)
            ?.relationshipId,
        'rel-123',
      );
    });

    test('markSectionSeen clears unseen plan badge state', () async {
      final fakeSupabase = FakeSupabaseClient(
        onUpsert: (data) async {},
      );

      final dataSource = ProfessionalPlanDataSource(
        hiveProvider.professionalPlanBox,
        hiveProvider.professionalPlanSyncQueueBox,
        fakeSupabase,
        FakeSupabaseIdentityService(),
      );

      final connection = ProfessionalConnectionEntity(
        relationshipId: 'rel-999',
        professionalId: 'pro-999',
        clientId: 'user-999',
        professionalName: 'Coach Studio',
        connectedAt: DateTime.now(),
        consentAcceptedAt: DateTime.now(),
        lastPlanSyncAt: DateTime.now(),
        lastSnapshotSyncAt: null,
        pendingSyncCount: 0,
        sharingMode: 'aggregate',
        messagesEnabled: false,
        connectionStatus: 'active',
        activePlan: const NutritionPlanEntity(
          id: 'plan-1',
          professionalId: 'pro-999',
          clientId: 'user-999',
          name: 'Plan 1',
          objective: 'general_fitness',
          notes: null,
          createdAt: null,
          updatedAt: null,
          startsOn: null,
          endsOn: null,
          days: [],
          meals: [],
        ),
      );

      await dataSource.saveActiveConnection(connection);

      expect(await dataSource.getUnseenSectionCount(), 1);

      await dataSource.markSectionSeen(connection: connection);

      expect(await dataSource.getUnseenSectionCount(), 0);
    });

    test('unseen section count includes unread professional messages',
        () async {
      final fakeSupabase = FakeSupabaseClient(
        onUpsert: (data) async {},
      );

      final dataSource = StubProfessionalPlanDataSource(
        box: hiveProvider.professionalPlanBox,
        syncQueueBox: hiveProvider.professionalPlanSyncQueueBox,
        supabaseClient: fakeSupabase,
        identityService: FakeSupabaseIdentityService(),
        stubMessages: ProfessionalMessageThreadEntity(
          threadId: 'rel-msg',
          isSupported: true,
          messagesEnabled: true,
          messages: [
            ProfessionalMessageEntity(
              id: 'msg-1',
              authorRole: 'professional',
              body: 'Primer mensaje',
              createdAt: DateTime(2026, 6, 8, 8),
              isRead: false,
            ),
            ProfessionalMessageEntity(
              id: 'msg-2',
              authorRole: 'professional',
              body: 'Segundo mensaje',
              createdAt: DateTime(2026, 6, 8, 9),
              isRead: false,
            ),
          ],
        ),
      );

      final connection = ProfessionalConnectionEntity(
        relationshipId: 'rel-msg',
        professionalId: 'pro-msg',
        clientId: 'user-msg',
        professionalName: 'Coach Studio',
        connectedAt: DateTime.now(),
        consentAcceptedAt: DateTime.now(),
        lastPlanSyncAt: DateTime.now(),
        lastSnapshotSyncAt: null,
        pendingSyncCount: 0,
        sharingMode: 'aggregate',
        messagesEnabled: true,
        connectionStatus: 'active',
        activePlan: null,
      );

      await dataSource.saveActiveConnection(connection);

      expect(await dataSource.getUnseenSectionCount(), 2);

      await dataSource.markSectionSeen(connection: connection);

      expect(await dataSource.getUnseenSectionCount(), 0);
    });

    test('parseMessageRow maps professional_client_messages rows', () {
      final parsed = ProfessionalPlanDataSource.parseMessageRow({
        'id': 'msg-remote-1',
        'author_role': 'professional',
        'body': 'Revisa el nuevo objetivo de hoy.',
        'created_at': '2026-06-08T07:30:00Z',
        'client_read_at': null,
      });

      expect(parsed, isNotNull);
      expect(parsed!.id, 'msg-remote-1');
      expect(parsed.authorRole, 'professional');
      expect(parsed.body, 'Revisa el nuevo objetivo de hoy.');
      expect(parsed.createdAt, DateTime.parse('2026-06-08T07:30:00Z'));
      expect(parsed.isRead, false);
    });

    test('parseMessageRow treats client-authored messages as already read', () {
      final parsed = ProfessionalPlanDataSource.parseMessageRow({
        'id': 'msg-client-1',
        'author_role': 'client',
        'body': 'Gracias, lo reviso.',
        'created_at': '2026-06-08T08:00:00Z',
      });

      expect(parsed, isNotNull);
      expect(parsed!.isRead, true);
    });
  });
}
