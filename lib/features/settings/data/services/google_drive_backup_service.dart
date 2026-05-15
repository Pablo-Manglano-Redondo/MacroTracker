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

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  GoogleSignInAccount? _activeAccount;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    await _googleSignIn.initialize(
      clientId: Platform.isIOS && _iosClientId.isNotEmpty ? _iosClientId : null,
      serverClientId: _serverClientId.isNotEmpty ? _serverClientId : null,
    );
    _initialized = true;
  }

  void _assertPlatformConfiguration() {
    if (Platform.isAndroid && _serverClientId.isEmpty) {
      throw StateError(
        'Missing GOOGLE_DRIVE_SERVER_CLIENT_ID for Android Google Drive sign-in.',
      );
    }
    if (Platform.isIOS && !_hasIosClientId) {
      throw StateError(
        'Missing GOOGLE_DRIVE_IOS_CLIENT_ID for iOS Google Drive sign-in.',
      );
    }
  }

  bool get _hasIosClientId =>
      _iosClientId.isNotEmpty && !_iosClientId.contains('YOUR_IOS_CLIENT_ID');

  Future<GoogleSignInAccount?> _restoreAccount() async {
    await _ensureInitialized();
    _activeAccount ??= await _googleSignIn.attemptLightweightAuthentication() ??
        _activeAccount;
    return _activeAccount;
  }

  Future<GoogleSignInAccount?> _getAccount({
    required bool interactive,
  }) async {
    final restored = await _restoreAccount();
    if (restored != null) {
      return restored;
    }

    if (!interactive) {
      return null;
    }

    if (!_googleSignIn.supportsAuthenticate()) {
      throw UnsupportedError(
        'Google Drive sign-in is not supported on this platform.',
      );
    }

    _activeAccount = await _googleSignIn.authenticate(scopeHint: _scopes);
    return _activeAccount;
  }

  Future<Map<String, String>?> _authorizationHeaders({
    required bool interactive,
  }) async {
    final account = await _getAccount(interactive: interactive);
    if (account == null) {
      return null;
    }

    return account.authorizationClient.authorizationHeaders(
      _scopes,
      promptIfNecessary: interactive,
    );
  }

  @override
  Future<bool> isAuthenticated() async {
    if (Platform.isAndroid && _serverClientId.isEmpty) {
      return false;
    }
    if (Platform.isIOS && !_hasIosClientId) {
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
    await _googleSignIn.disconnect();
    _activeAccount = null;
  }

  Future<DriveBackupStatus> getStatus() async {
    try {
      final account = await _restoreAccount();
      if (account == null) {
        return DriveBackupStatus(
          isSignedIn: false,
          requiresManualConfiguration:
              (Platform.isAndroid && _serverClientId.isEmpty) ||
                  (Platform.isIOS && !_hasIosClientId),
          errorMessage: Platform.isAndroid && _serverClientId.isEmpty
              ? 'Set GOOGLE_DRIVE_SERVER_CLIENT_ID before using Google Drive backup on Android.'
              : Platform.isIOS && !_hasIosClientId
                  ? 'Set GOOGLE_DRIVE_IOS_CLIENT_ID and GOOGLE_DRIVE_IOS_REVERSED_CLIENT_ID before using Google Drive backup on iOS.'
                  : null,
        );
      }

      return DriveBackupStatus(
        isSignedIn: true,
        accountEmail: account.email,
        accountName: account.displayName,
        requiresManualConfiguration:
            (Platform.isAndroid && _serverClientId.isEmpty) ||
                (Platform.isIOS && !_hasIosClientId),
      );
    } catch (error) {
      return DriveBackupStatus(
        isSignedIn: false,
        errorMessage: error.toString(),
        requiresManualConfiguration:
            (Platform.isAndroid && _serverClientId.isEmpty) ||
                (Platform.isIOS && !_hasIosClientId),
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

    final client = _GoogleAuthHttpClient(headers);
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
