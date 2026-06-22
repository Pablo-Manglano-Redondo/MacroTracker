import 'package:logging/logging.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';
import 'package:macrotracker/core/utils/secure_app_storage_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CloudAccountDeletionService {
  static const sessionInvalidErrorCode = 'cloud_session_invalid';
  static const noActiveSessionErrorCode = 'cloud_no_active_session';
  static const cloudUnreachableErrorCode = 'cloud_unreachable';
  static const localDataKeptErrorCode = 'cloud_delete_local_data_kept';

  final CloudAccountDeletionGateway _gateway;
  final SupabaseIdentityService _identityService;
  final LocalAccountDataResetter _localResetter;
  final _log = Logger('CloudAccountDeletionService');

  CloudAccountDeletionService(
    this._identityService,
    this._localResetter,
    SupabaseClient client, {
    CloudAccountDeletionGateway? gateway,
  }) : _gateway = gateway ?? SupabaseCloudAccountDeletionGateway(client);

  Future<void> deleteCurrentAccount() async {
    try {
      final expectedUserId = _identityService.requireActiveUserSession();
      final payload = await _gateway.deleteCurrentAccount();
      if (payload is! Map ||
          payload['success'] != true ||
          payload['userId'] != expectedUserId) {
        throw const CloudAccountDeletionException(localDataKeptErrorCode);
      }

      await _localResetter.clearAll();
      try {
        await _gateway.signOut();
      } catch (error, stackTrace) {
        _log.warning(
          'Sign-out after remote account deletion failed',
          error,
          stackTrace,
        );
      }
    } on CloudAccountDeletionException {
      rethrow;
    } catch (error, stackTrace) {
      _log.severe('Cloud account deletion failed', error, stackTrace);
      throw CloudAccountDeletionException(_mapErrorMessage(error));
    }
  }

  String _mapErrorMessage(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('401') ||
        message.contains('403') ||
        message.contains('jwt') ||
        message.contains('auth')) {
      return sessionInvalidErrorCode;
    }
    if (message.contains('no active cloud session')) {
      return noActiveSessionErrorCode;
    }
    if (message.contains('timeout') ||
        message.contains('socket') ||
        message.contains('network')) {
      return cloudUnreachableErrorCode;
    }
    return localDataKeptErrorCode;
  }
}

abstract class LocalAccountDataResetter {
  Future<void> clearAll();
}

class HiveAndSecureStorageResetter implements LocalAccountDataResetter {
  final HiveDBProvider _hiveDBProvider;

  HiveAndSecureStorageResetter(this._hiveDBProvider);

  @override
  Future<void> clearAll() async {
    await _hiveDBProvider.clearAllData();
    await SecureAppStorageProvider.secureAppStorage.deleteAll();
  }
}

class CloudAccountDeletionException implements Exception {
  final String message;

  const CloudAccountDeletionException(this.message);

  @override
  String toString() => message;
}

abstract class CloudAccountDeletionGateway {
  Future<dynamic> deleteCurrentAccount();

  Future<void> signOut();
}

class SupabaseCloudAccountDeletionGateway
    implements CloudAccountDeletionGateway {
  static const _deleteFunctionName = 'delete-current-account';

  final SupabaseClient _client;

  const SupabaseCloudAccountDeletionGateway(this._client);

  @override
  Future<dynamic> deleteCurrentAccount() async {
    final response = await _client.functions.invoke(_deleteFunctionName);
    return response.data;
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
  }
}
