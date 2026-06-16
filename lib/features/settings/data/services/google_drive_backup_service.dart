import 'dart:async';
import 'dart:io';

import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:macrotracker/core/utils/env.dart';
import 'package:macrotracker/features/settings/domain/usecase/backup_to_drive_usecase.dart';

class DriveBackupStatus {
  final bool isSignedIn;
  final String? accountEmail;
  final String? accountName;
  final String? errorMessage;
  final bool requiresManualConfiguration;

  const DriveBackupStatus({
    required this.isSignedIn,
    this.accountEmail,
    this.accountName,
    this.errorMessage,
    this.requiresManualConfiguration = false,
  });
}

class GoogleDriveBackupService implements DriveBackupService {
  static const _scopes = <String>[drive.DriveApi.driveFileScope];
  static final _serverClientId = Env.googleDriveServerClientId;
  static final _iosClientId = Env.googleDriveIosClientId;

  final GoogleDriveAuthClient _authClient;
  final GoogleDriveFileUploader _fileUploader;
  final bool Function() _isAndroid;
  final bool Function() _isIOS;
  final String _configuredServerClientId;
  final String _configuredIosClientId;
  GoogleDriveAccount? _activeAccount;
  bool _initialized = false;

  GoogleDriveBackupService({
    GoogleDriveAuthClient? authClient,
    GoogleDriveFileUploader? fileUploader,
    bool Function()? isAndroid,
    bool Function()? isIOS,
    String? serverClientId,
    String? iosClientId,
  })  : _authClient = authClient ?? GoogleSignInDriveAuthClient(),
        _fileUploader = fileUploader ?? GoogleDriveApiFileUploader(),
        _isAndroid = isAndroid ?? (() => Platform.isAndroid),
        _isIOS = isIOS ?? (() => Platform.isIOS),
        _configuredServerClientId = serverClientId ?? _serverClientId,
        _configuredIosClientId = iosClientId ?? _iosClientId;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    await _authClient.initialize(
      clientId: _isIOS() && _configuredIosClientId.isNotEmpty
          ? _configuredIosClientId
          : null,
      serverClientId: _configuredServerClientId.isNotEmpty
          ? _configuredServerClientId
          : null,
    );
    _initialized = true;
  }

  void _assertPlatformConfiguration() {
    if (_isAndroid() && _configuredServerClientId.isEmpty) {
      throw StateError(
        'Missing GOOGLE_DRIVE_SERVER_CLIENT_ID for Android Google Drive sign-in.',
      );
    }
    if (_isIOS() && !_hasIosClientId) {
      throw StateError(
        'Missing GOOGLE_DRIVE_IOS_CLIENT_ID for iOS Google Drive sign-in.',
      );
    }
  }

  bool get _hasIosClientId =>
      _configuredIosClientId.isNotEmpty &&
      !_configuredIosClientId.contains('YOUR_IOS_CLIENT_ID');

  Future<GoogleDriveAccount?> _restoreAccount() async {
    await _ensureInitialized();
    _activeAccount ??=
        await _authClient.attemptLightweightAuthentication() ?? _activeAccount;
    return _activeAccount;
  }

  Future<GoogleDriveAccount?> _getAccount({
    required bool interactive,
  }) async {
    final restored = await _restoreAccount();
    if (restored != null) {
      return restored;
    }

    if (!interactive) {
      return null;
    }

    if (!_authClient.supportsAuthenticate()) {
      throw UnsupportedError(
        'Google Drive sign-in is not supported on this platform.',
      );
    }

    _activeAccount = await _authClient.authenticate(scopeHint: _scopes);
    return _activeAccount;
  }

  Future<Map<String, String>?> _authorizationHeaders({
    required bool interactive,
  }) async {
    final account = await _getAccount(interactive: interactive);
    if (account == null) {
      return null;
    }

    return account.authorizationHeaders(
      _scopes,
      promptIfNecessary: interactive,
    );
  }

  @override
  Future<bool> isAuthenticated() async {
    if (_isAndroid() && _configuredServerClientId.isEmpty) {
      return false;
    }
    if (_isIOS() && !_hasIosClientId) {
      return false;
    }
    final headers = await _authorizationHeaders(interactive: false);
    return headers != null && headers['Authorization']?.isNotEmpty == true;
  }

  @override
  Future<void> authenticate() async {
    _assertPlatformConfiguration();
    final headers = await _authorizationHeaders(interactive: true);
    if (headers == null || headers['Authorization']?.isEmpty != false) {
      throw StateError('Google Drive authorization was not granted.');
    }
  }

  Future<void> disconnect() async {
    await _ensureInitialized();
    await _authClient.disconnect();
    _activeAccount = null;
  }

  Future<DriveBackupStatus> getStatus() async {
    try {
      final account = await _restoreAccount();
      if (account == null) {
        return DriveBackupStatus(
          isSignedIn: false,
          requiresManualConfiguration:
              (_isAndroid() && _configuredServerClientId.isEmpty) ||
                  (_isIOS() && !_hasIosClientId),
          errorMessage: _isAndroid() && _configuredServerClientId.isEmpty
              ? 'Set GOOGLE_DRIVE_SERVER_CLIENT_ID before using Google Drive backup on Android.'
              : _isIOS() && !_hasIosClientId
                  ? 'Set GOOGLE_DRIVE_IOS_CLIENT_ID and GOOGLE_DRIVE_IOS_REVERSED_CLIENT_ID before using Google Drive backup on iOS.'
                  : null,
        );
      }

      return DriveBackupStatus(
        isSignedIn: true,
        accountEmail: account.email,
        accountName: account.displayName,
        requiresManualConfiguration:
            (_isAndroid() && _configuredServerClientId.isEmpty) ||
                (_isIOS() && !_hasIosClientId),
      );
    } catch (error) {
      return DriveBackupStatus(
        isSignedIn: false,
        errorMessage: error.toString(),
        requiresManualConfiguration:
            (_isAndroid() && _configuredServerClientId.isEmpty) ||
                (_isIOS() && !_hasIosClientId),
      );
    }
  }

  @override
  Future<DriveBackupUploadResult> uploadBackupFile(
    File file,
    String fileName, {
    bool allowInteractiveAuthentication = true,
  }) async {
    _assertPlatformConfiguration();
    final headers = await _authorizationHeaders(
      interactive: allowInteractiveAuthentication,
    );
    if (headers == null) {
      throw StateError('Google Drive authorization was not granted.');
    }

    return _fileUploader.uploadBackupFile(
      file: file,
      fileName: fileName,
      authorizationHeaders: headers,
    );
  }
}

class GoogleDriveAccount {
  final String email;
  final String? displayName;
  final Future<Map<String, String>?> Function(
    List<String> scopes, {
    required bool promptIfNecessary,
  }) _authorizationHeaders;

  const GoogleDriveAccount({
    required this.email,
    required this.displayName,
    required Future<Map<String, String>?> Function(
      List<String> scopes, {
      required bool promptIfNecessary,
    }) authorizationHeaders,
  }) : _authorizationHeaders = authorizationHeaders;

  Future<Map<String, String>?> authorizationHeaders(
    List<String> scopes, {
    required bool promptIfNecessary,
  }) {
    return _authorizationHeaders(scopes, promptIfNecessary: promptIfNecessary);
  }
}

abstract class GoogleDriveAuthClient {
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
  });

  Future<GoogleDriveAccount?> attemptLightweightAuthentication();

  bool supportsAuthenticate();

  Future<GoogleDriveAccount> authenticate({
    required List<String> scopeHint,
  });

  Future<void> disconnect();
}

class GoogleSignInDriveAuthClient implements GoogleDriveAuthClient {
  final GoogleSignIn _googleSignIn;

  GoogleSignInDriveAuthClient([GoogleSignIn? googleSignIn])
      : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
  }) {
    return _googleSignIn.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );
  }

  @override
  Future<GoogleDriveAccount?> attemptLightweightAuthentication() async {
    final account = await _googleSignIn.attemptLightweightAuthentication();
    return account == null ? null : _GoogleSignInDriveAccount(account);
  }

  @override
  bool supportsAuthenticate() => _googleSignIn.supportsAuthenticate();

  @override
  Future<GoogleDriveAccount> authenticate({
    required List<String> scopeHint,
  }) async {
    final account = await _googleSignIn.authenticate(scopeHint: scopeHint);
    return _GoogleSignInDriveAccount(account);
  }

  @override
  Future<void> disconnect() => _googleSignIn.disconnect();
}

class _GoogleSignInDriveAccount extends GoogleDriveAccount {
  _GoogleSignInDriveAccount(GoogleSignInAccount account)
      : super(
          email: account.email,
          displayName: account.displayName,
          authorizationHeaders: (
            scopes, {
            required bool promptIfNecessary,
          }) {
            return account.authorizationClient.authorizationHeaders(
              scopes,
              promptIfNecessary: promptIfNecessary,
            );
          },
        );
}

abstract class GoogleDriveFileUploader {
  Future<DriveBackupUploadResult> uploadBackupFile({
    required File file,
    required String fileName,
    required Map<String, String> authorizationHeaders,
  });
}

class GoogleDriveApiFileUploader implements GoogleDriveFileUploader {
  @override
  Future<DriveBackupUploadResult> uploadBackupFile({
    required File file,
    required String fileName,
    required Map<String, String> authorizationHeaders,
  }) async {
    final client = _GoogleAuthHttpClient(authorizationHeaders);
    try {
      final driveApi = drive.DriveApi(client);
      final media = commons.Media(file.openRead(), await file.length());
      final metadata = drive.File()
        ..name = fileName
        ..description =
            'MacroTracker backup created on ${DateTime.now().toIso8601String()}';

      final uploadedFile = await driveApi.files.create(
        metadata,
        uploadMedia: media,
        $fields: 'id,name,webViewLink',
      );
      return DriveBackupUploadResult(
        fileId: uploadedFile.id,
        fileName: uploadedFile.name,
        webViewLink: uploadedFile.webViewLink,
      );
    } finally {
      client.close();
    }
  }
}

class _GoogleAuthHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _GoogleAuthHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
