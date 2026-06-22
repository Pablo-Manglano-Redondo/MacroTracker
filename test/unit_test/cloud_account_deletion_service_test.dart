import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/services/cloud_account_deletion_service.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('CloudAccountDeletionService', () {
    test('clears local data only after a confirmed remote deletion', () async {
      final resetter = _FakeLocalAccountDataResetter();
      final gateway = _FakeCloudAccountDeletionGateway(
        deletePayload: {
          'success': true,
          'userId': 'user-1',
        },
      );
      final service = CloudAccountDeletionService(
        _FakeSupabaseIdentityService(userId: 'user-1'),
        resetter,
        _FakeSupabaseClient(),
        gateway: gateway,
      );

      await service.deleteCurrentAccount();

      expect(resetter.clearAllCalls, 1);
      expect(gateway.signOutCalls, 1);
    });

    test('does not clear local data when remote deletion response is invalid',
        () async {
      final resetter = _FakeLocalAccountDataResetter();
      final gateway = _FakeCloudAccountDeletionGateway(
        deletePayload: {
          'success': true,
          'userId': 'other-user',
        },
      );
      final service = CloudAccountDeletionService(
        _FakeSupabaseIdentityService(userId: 'user-1'),
        resetter,
        _FakeSupabaseClient(),
        gateway: gateway,
      );

      await expectLater(
        service.deleteCurrentAccount(),
        throwsA(isA<CloudAccountDeletionException>()),
      );
      expect(resetter.clearAllCalls, 0);
      expect(gateway.signOutCalls, 0);
    });

    test('maps auth failures and preserves local data', () async {
      final resetter = _FakeLocalAccountDataResetter();
      final gateway = _FakeCloudAccountDeletionGateway(
        deleteError: Exception('401 jwt expired'),
      );
      final service = CloudAccountDeletionService(
        _FakeSupabaseIdentityService(userId: 'user-1'),
        resetter,
        _FakeSupabaseClient(),
        gateway: gateway,
      );

      await expectLater(
        service.deleteCurrentAccount(),
        throwsA(
          predicate(
            (error) =>
                error is CloudAccountDeletionException &&
                error.message ==
                    CloudAccountDeletionService.sessionInvalidErrorCode,
          ),
        ),
      );
      expect(resetter.clearAllCalls, 0);
      expect(gateway.signOutCalls, 0);
    });
  });
}

class _FakeCloudAccountDeletionGateway implements CloudAccountDeletionGateway {
  final dynamic deletePayload;
  final Object? deleteError;
  int signOutCalls = 0;

  _FakeCloudAccountDeletionGateway({
    this.deletePayload,
    this.deleteError,
  });

  @override
  Future<dynamic> deleteCurrentAccount() async {
    if (deleteError != null) {
      throw deleteError!;
    }
    return deletePayload;
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
  }
}

class _FakeLocalAccountDataResetter implements LocalAccountDataResetter {
  int clearAllCalls = 0;

  @override
  Future<void> clearAll() async {
    clearAllCalls += 1;
  }
}

class _FakeSupabaseIdentityService implements SupabaseIdentityService {
  final String userId;

  const _FakeSupabaseIdentityService({required this.userId});

  @override
  String requireActiveUserSession() => userId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
