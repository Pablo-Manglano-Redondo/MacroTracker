import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/settings/data/services/google_drive_backup_service.dart';
import 'package:macrotracker/features/settings/domain/usecase/backup_to_drive_usecase.dart';

void main() {
  group('GoogleDriveBackupService', () {
    test(
        'reports manual Android configuration when server client id is missing',
        () async {
      final service = GoogleDriveBackupService(
        authClient: _FakeDriveAuthClient(),
        fileUploader: _FakeDriveFileUploader(),
        isAndroid: () => true,
        isIOS: () => false,
        serverClientId: '',
      );

      expect(await service.isAuthenticated(), isFalse);

      final status = await service.getStatus();
      expect(status.isSignedIn, isFalse);
      expect(status.requiresManualConfiguration, isTrue);
      expect(status.errorMessage, contains('GOOGLE_DRIVE_SERVER_CLIENT_ID'));
    });

    test('authenticate throws when iOS client id still has placeholder value',
        () async {
      final service = GoogleDriveBackupService(
        authClient: _FakeDriveAuthClient(),
        fileUploader: _FakeDriveFileUploader(),
        isAndroid: () => false,
        isIOS: () => true,
        iosClientId: 'YOUR_IOS_CLIENT_ID',
      );

      expect(service.authenticate, throwsA(isA<StateError>()));
    });

    test('restores account and returns authenticated status without prompting',
        () async {
      final authClient = _FakeDriveAuthClient(
        restoredAccount: _account(
          email: 'user@example.com',
          displayName: 'Macro User',
          headers: {'Authorization': 'Bearer restored'},
        ),
      );
      final service = GoogleDriveBackupService(
        authClient: authClient,
        fileUploader: _FakeDriveFileUploader(),
        isAndroid: () => false,
        isIOS: () => false,
      );

      expect(await service.isAuthenticated(), isTrue);

      final status = await service.getStatus();
      expect(status.isSignedIn, isTrue);
      expect(status.accountEmail, 'user@example.com');
      expect(status.accountName, 'Macro User');
      expect(authClient.initializeCalls, 1);
      expect(authClient.authenticateCalls, 0);
    });

    test('authenticate prompts when lightweight restore has no account',
        () async {
      final authClient = _FakeDriveAuthClient(
        authenticatedAccount: _account(
          email: 'auth@example.com',
          displayName: 'Auth User',
          headers: {'Authorization': 'Bearer interactive'},
        ),
      );
      final service = GoogleDriveBackupService(
        authClient: authClient,
        fileUploader: _FakeDriveFileUploader(),
        isAndroid: () => true,
        isIOS: () => false,
        serverClientId: 'server-client-id',
      );

      await service.authenticate();

      expect(authClient.authenticateCalls, 1);
      expect(authClient.lastScopeHint, isNotEmpty);
    });

    test('uploadBackupFile uploads through Drive uploader with auth headers',
        () async {
      final tempDir =
          await Directory.systemTemp.createTemp('drive_backup_test_');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });
      final backupFile = File('${tempDir.path}${Platform.pathSeparator}b.json');
      await backupFile.writeAsString('{"ok":true}');
      final uploader = _FakeDriveFileUploader();
      final service = GoogleDriveBackupService(
        authClient: _FakeDriveAuthClient(
          restoredAccount: _account(
            email: 'user@example.com',
            displayName: 'Macro User',
            headers: {'Authorization': 'Bearer upload'},
          ),
        ),
        fileUploader: uploader,
        isAndroid: () => false,
        isIOS: () => false,
      );

      final result = await service.uploadBackupFile(backupFile, 'backup.json');

      expect(result.fileId, 'drive-file-1');
      expect(uploader.lastFile, backupFile);
      expect(uploader.lastFileName, 'backup.json');
      expect(uploader.lastHeaders?['Authorization'], 'Bearer upload');
    });

    test('disconnect clears restored account and delegates to auth client',
        () async {
      final authClient = _FakeDriveAuthClient(
        restoredAccount: _account(
          email: 'user@example.com',
          displayName: 'Macro User',
          headers: {'Authorization': 'Bearer restored'},
        ),
      );
      final service = GoogleDriveBackupService(
        authClient: authClient,
        fileUploader: _FakeDriveFileUploader(),
        isAndroid: () => false,
        isIOS: () => false,
      );

      expect(await service.isAuthenticated(), isTrue);

      await service.disconnect();
      authClient.restoredAccount = null;

      expect(authClient.disconnectCalls, 1);
      expect(await service.isAuthenticated(), isFalse);
    });
  });
}

GoogleDriveAccount _account({
  required String email,
  required String? displayName,
  required Map<String, String>? headers,
}) {
  return GoogleDriveAccount(
    email: email,
    displayName: displayName,
    authorizationHeaders: (
      scopes, {
      required bool promptIfNecessary,
    }) async =>
        headers,
  );
}

class _FakeDriveAuthClient implements GoogleDriveAuthClient {
  GoogleDriveAccount? restoredAccount;
  GoogleDriveAccount? authenticatedAccount;
  int initializeCalls = 0;
  int authenticateCalls = 0;
  int disconnectCalls = 0;
  List<String>? lastScopeHint;

  _FakeDriveAuthClient({
    this.restoredAccount,
    this.authenticatedAccount,
  });

  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
  }) async {
    initializeCalls++;
  }

  @override
  Future<GoogleDriveAccount?> attemptLightweightAuthentication() async {
    return restoredAccount;
  }

  @override
  bool supportsAuthenticate() => true;

  @override
  Future<GoogleDriveAccount> authenticate({
    required List<String> scopeHint,
  }) async {
    authenticateCalls++;
    lastScopeHint = scopeHint;
    return authenticatedAccount ??
        _account(
          email: 'interactive@example.com',
          displayName: 'Interactive User',
          headers: {'Authorization': 'Bearer interactive'},
        );
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    restoredAccount = null;
    authenticatedAccount = null;
  }
}

class _FakeDriveFileUploader implements GoogleDriveFileUploader {
  File? lastFile;
  String? lastFileName;
  Map<String, String>? lastHeaders;

  @override
  Future<DriveBackupUploadResult> uploadBackupFile({
    required File file,
    required String fileName,
    required Map<String, String> authorizationHeaders,
  }) async {
    lastFile = file;
    lastFileName = fileName;
    lastHeaders = authorizationHeaders;
    return const DriveBackupUploadResult(
      fileId: 'drive-file-1',
      fileName: 'backup.json',
      webViewLink: 'https://drive.example/backup',
    );
  }
}
