import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/professional_plan/data/data_source/professional_plan_data_source.dart';
import 'package:macrotracker/features/professional_plan/data/repository/professional_plan_repository.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';

class _FakeProfessionalPlanDataSource extends Fake implements ProfessionalPlanDataSource {
  final calls = <String>[];

  @override
  Future<ProfessionalConnectionEntity?> getActiveConnection() async {
    calls.add('getActiveConnection');
    return null;
  }

  @override
  Future<ProfessionalConnectionEntity?> refreshActivePlan() async {
    calls.add('refreshActivePlan');
    return null;
  }

  @override
  Future<ProfessionalInvitePreviewEntity?> fetchInvitePreview(String code) async {
    calls.add('fetchInvitePreview:$code');
    return null;
  }

  @override
  Future<ProfessionalConnectionEntity> acceptInvite(String code) async {
    calls.add('acceptInvite:$code');
    return ProfessionalConnectionEntity(
      relationshipId: 'r-1',
      professionalId: 'p-1',
      clientId: 'c-1',
      professionalName: 'Coach A',
      connectedAt: DateTime(2026, 6, 1),
      consentAcceptedAt: DateTime(2026, 6, 1),
      lastPlanSyncAt: null,
      lastSnapshotSyncAt: null,
      pendingSyncCount: 0,
      sharingMode: 'aggregate',
      messagesEnabled: true,
      connectionStatus: 'active',
      activePlan: null,
    );
  }

  @override
  Future<void> clearActiveConnection() async {
    calls.add('clearActiveConnection');
  }

  @override
  Future<void> uploadDailySnapshot({
    required ProfessionalConnectionEntity connection,
    required DateTime day,
    required double kcalActual,
    required double kcalTarget,
    required double carbsActual,
    required double carbsTarget,
    required double fatActual,
    required double fatTarget,
    required double proteinActual,
    required double proteinTarget,
    required int mealsLogged,
    String? notes,
    double? weightKg,
    double? waistCm,
  }) async {
    calls.add('uploadDailySnapshot');
  }

  @override
  Future<void> uploadDiaryEntries({
    required ProfessionalConnectionEntity connection,
    required DateTime day,
    required List<Map<String, dynamic>> entries,
  }) async {
    calls.add('uploadDiaryEntries');
  }

  @override
  Future<void> saveDailyNote(DateTime day, String note) async {
    calls.add('saveDailyNote:$note');
  }

  @override
  Future<String?> getDailyNote(DateTime day) async {
    calls.add('getDailyNote');
    return 'note';
  }

  @override
  Future<void> processPendingSyncs() async {
    calls.add('processPendingSyncs');
  }

  @override
  Future<int> getPendingSyncCount() async {
    calls.add('getPendingSyncCount');
    return 5;
  }

  @override
  Future<ProfessionalMessageThreadEntity> getMessages({
    required ProfessionalConnectionEntity connection,
  }) async {
    calls.add('getMessages');
    return const ProfessionalMessageThreadEntity(
      threadId: 't-1',
      isSupported: true,
      messagesEnabled: true,
      messages: [],
    );
  }

  @override
  Future<void> markMessageRead({
    required ProfessionalConnectionEntity connection,
    required String messageId,
  }) async {
    calls.add('markMessageRead:$messageId');
  }

  @override
  Future<ProfessionalMessageEntity> sendMessage({
    required ProfessionalConnectionEntity connection,
    required String body,
  }) async {
    calls.add('sendMessage:$body');
    return ProfessionalMessageEntity(
      id: 'm-1',
      authorRole: 'client',
      body: body,
      createdAt: DateTime.now(),
      isRead: true,
    );
  }

  @override
  Future<ProfessionalSharingScopeEntity> getSharingScope({
    required ProfessionalConnectionEntity connection,
  }) async {
    calls.add('getSharingScope');
    return ProfessionalSharingScopeEntity(
      sharingMode: 'aggregate',
      messagesEnabled: true,
      consentAcceptedAt: DateTime.now(),
      sharedNow: const [],
      notSharedYet: const [],
      nextAvailable: const [],
    );
  }

  @override
  Future<void> updateSharingMode({
    required String relationshipId,
    required String clientId,
    required String sharingMode,
  }) async {
    calls.add('updateSharingMode:$sharingMode');
  }

  @override
  Future<int> getUnseenSectionCount() async {
    calls.add('getUnseenSectionCount');
    return 1;
  }

  @override
  Future<void> markSectionSeen({
    required ProfessionalConnectionEntity connection,
  }) async {
    calls.add('markSectionSeen');
  }
}

void main() {
  group('ProfessionalPlanRepository Tests', () {
    late _FakeProfessionalPlanDataSource dataSource;
    late ProfessionalPlanRepository repository;

    setUp(() {
      dataSource = _FakeProfessionalPlanDataSource();
      repository = ProfessionalPlanRepository(dataSource);
    });

    final conn = ProfessionalConnectionEntity(
      relationshipId: 'r-1',
      professionalId: 'p-1',
      clientId: 'c-1',
      professionalName: 'Coach A',
      connectedAt: DateTime(2026, 6, 1),
      consentAcceptedAt: DateTime(2026, 6, 1),
      lastPlanSyncAt: null,
      lastSnapshotSyncAt: null,
      pendingSyncCount: 0,
      sharingMode: 'aggregate',
      messagesEnabled: true,
      connectionStatus: 'active',
      activePlan: null,
    );

    test('getActiveConnection calls data source', () async {
      await repository.getActiveConnection();
      expect(dataSource.calls, contains('getActiveConnection'));
    });

    test('refreshActivePlan calls data source', () async {
      await repository.refreshActivePlan();
      expect(dataSource.calls, contains('refreshActivePlan'));
    });

    test('fetchInvitePreview calls data source', () async {
      await repository.fetchInvitePreview('code123');
      expect(dataSource.calls, contains('fetchInvitePreview:code123'));
    });

    test('acceptInvite calls data source', () async {
      await repository.acceptInvite('code123');
      expect(dataSource.calls, contains('acceptInvite:code123'));
    });

    test('disconnect calls data source', () async {
      await repository.disconnect();
      expect(dataSource.calls, contains('clearActiveConnection'));
    });

    test('uploadDailySnapshot calls data source', () async {
      await repository.uploadDailySnapshot(
        connection: conn,
        day: DateTime.now(),
        kcalActual: 2000,
        kcalTarget: 2000,
        carbsActual: 200,
        carbsTarget: 200,
        fatActual: 70,
        fatTarget: 70,
        proteinActual: 150,
        proteinTarget: 150,
        mealsLogged: 3,
      );
      expect(dataSource.calls, contains('uploadDailySnapshot'));
    });

    test('uploadDiaryEntries calls data source', () async {
      await repository.uploadDiaryEntries(
        connection: conn,
        day: DateTime.now(),
        entries: [],
      );
      expect(dataSource.calls, contains('uploadDiaryEntries'));
    });

    test('saveDailyNote calls data source', () async {
      await repository.saveDailyNote(DateTime.now(), 'felt great');
      expect(dataSource.calls, contains('saveDailyNote:felt great'));
    });

    test('getDailyNote calls data source', () async {
      final note = await repository.getDailyNote(DateTime.now());
      expect(note, 'note');
      expect(dataSource.calls, contains('getDailyNote'));
    });

    test('processPendingSyncs calls data source', () async {
      await repository.processPendingSyncs();
      expect(dataSource.calls, contains('processPendingSyncs'));
    });

    test('getPendingSyncCount calls data source', () async {
      final count = await repository.getPendingSyncCount();
      expect(count, 5);
      expect(dataSource.calls, contains('getPendingSyncCount'));
    });

    test('getMessages calls data source', () async {
      await repository.getMessages(connection: conn);
      expect(dataSource.calls, contains('getMessages'));
    });

    test('markMessageRead calls data source', () async {
      await repository.markMessageRead(connection: conn, messageId: 'm-1');
      expect(dataSource.calls, contains('markMessageRead:m-1'));
    });

    test('sendMessage calls data source', () async {
      await repository.sendMessage(connection: conn, body: 'hello');
      expect(dataSource.calls, contains('sendMessage:hello'));
    });

    test('getSharingScope calls data source', () async {
      await repository.getSharingScope(connection: conn);
      expect(dataSource.calls, contains('getSharingScope'));
    });

    test('updateSharingMode calls data source', () async {
      await repository.updateSharingMode(
        relationshipId: 'r-1',
        clientId: 'c-1',
        sharingMode: 'full',
      );
      expect(dataSource.calls, contains('updateSharingMode:full'));
    });

    test('getUnseenSectionCount calls data source', () async {
      final count = await repository.getUnseenSectionCount();
      expect(count, 1);
      expect(dataSource.calls, contains('getUnseenSectionCount'));
    });

    test('markSectionSeen calls data source', () async {
      await repository.markSectionSeen(connection: conn);
      expect(dataSource.calls, contains('markSectionSeen'));
    });
  });
}
