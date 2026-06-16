import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/features/settings/domain/usecase/backup_to_drive_usecase.dart';
import 'package:macrotracker/features/settings/domain/usecase/export_data_usecase.dart';

class _FakeExportDataUsecase extends Fake implements ExportDataUsecase {
  String? returnPath;

  @override
  Future<String?> exportData(
    String zipFileName,
    String userActivityName,
    String userIntakeName,
    String trackedDayName,
    String recipeName,
    String bodyMeasurementName,
    String dailyHabitName,
    String userName,
    String configName, {
    String? customOutputPath,
  }) async {
    if (returnPath != null) {
      final file = File(returnPath!);
      await file.parent.create(recursive: true);
      await file.writeAsString('dummy zip');
      return returnPath;
    }
    return null;
  }
}

class _FakeDriveBackupService extends Fake implements DriveBackupService {
  bool authenticated = false;
  int authCalls = 0;
  int uploadCalls = 0;
  bool shouldThrowOnUpload = false;

  @override
  Future<bool> isAuthenticated() async => authenticated;

  @override
  Future<void> authenticate() async {
    authCalls++;
    authenticated = true;
  }

  @override
  Future<DriveBackupUploadResult> uploadBackupFile(
    File file,
    String fileName, {
    bool allowInteractiveAuthentication = true,
  }) async {
    uploadCalls++;
    if (shouldThrowOnUpload) {
      throw Exception('Upload failed');
    }
    return DriveBackupUploadResult(
      fileId: 'drive-file-id',
      fileName: fileName,
    );
  }
}

class _FakeConfigRepository extends Fake implements ConfigRepository {
  String? lastAttemptedAt;
  String? lastSuccessAt;
  String? lastErrorMessage;

  @override
  Future<void> setGoogleDriveBackupStatus({
    required String attemptedAtIso,
    String? successAtIso,
    String? errorMessage,
  }) async {
    lastAttemptedAt = attemptedAtIso;
    lastSuccessAt = successAtIso;
    lastErrorMessage = errorMessage;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late _FakeExportDataUsecase exportDataUsecase;
  late _FakeDriveBackupService driveBackupService;
  late _FakeConfigRepository configRepository;
  late BackupToDriveUsecase usecase;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('macrotracker_backup_usecase_test_');

    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return tempDir.path;
    });

    exportDataUsecase = _FakeExportDataUsecase();
    driveBackupService = _FakeDriveBackupService();
    configRepository = _FakeConfigRepository();
    
    usecase = BackupToDriveUsecase(
      exportDataUsecase,
      driveBackupService,
      configRepository,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('BackupToDriveUsecase Tests', () {
    test('performs successful backup when already authenticated', () async {
      driveBackupService.authenticated = true;
      exportDataUsecase.returnPath = '${tempDir.path}/MacroTracker_DailyBackup.zip';

      final result = await usecase.performBackup();

      expect(result.fileId, 'drive-file-id');
      expect(driveBackupService.authCalls, 0);
      expect(driveBackupService.uploadCalls, 1);
      
      expect(configRepository.lastAttemptedAt, isNotNull);
      expect(configRepository.lastSuccessAt, isNotNull);
      expect(configRepository.lastErrorMessage, isNull);

      // Verify the backup file was cleaned up (deleted) from tempDir
      final file = File(exportDataUsecase.returnPath!);
      expect(await file.exists(), isFalse);
    });

    test('authenticates first when not authenticated', () async {
      driveBackupService.authenticated = false;
      exportDataUsecase.returnPath = '${tempDir.path}/MacroTracker_DailyBackup.zip';

      final result = await usecase.performBackup();

      expect(result.fileId, 'drive-file-id');
      expect(driveBackupService.authCalls, 1);
      expect(driveBackupService.uploadCalls, 1);
    });

    test('throws StateError when not authenticated and allowInteractiveAuthentication is false', () async {
      driveBackupService.authenticated = false;

      await expectLater(
        usecase.performBackup(allowInteractiveAuthentication: false),
        throwsStateError,
      );

      expect(configRepository.lastErrorMessage, contains('Google Drive account is not connected'));
    });

    test('throws StateError when exportData returns null', () async {
      driveBackupService.authenticated = true;
      exportDataUsecase.returnPath = null;

      await expectLater(
        usecase.performBackup(),
        throwsStateError,
      );

      expect(configRepository.lastErrorMessage, contains('Backup export did not produce a file'));
    });

    test('throws StateError when exported file does not exist on disk', () async {
      driveBackupService.authenticated = true;
      // Return a path but do not let exportData write it (we modify returnPath to point to a non-existent file path directly)
      final fakeExport = _FakeExportDataUsecaseWithoutWriting();
      fakeExport.returnPath = '${tempDir.path}/non_existent.zip';

      final localUsecase = BackupToDriveUsecase(
        fakeExport,
        driveBackupService,
        configRepository,
      );

      await expectLater(
        localUsecase.performBackup(),
        throwsStateError,
      );

      expect(configRepository.lastErrorMessage, contains('Backup file was not created on disk'));
    });

    test('rethrows exception and logs status when upload fails', () async {
      driveBackupService.authenticated = true;
      driveBackupService.shouldThrowOnUpload = true;
      exportDataUsecase.returnPath = '${tempDir.path}/MacroTracker_DailyBackup.zip';

      await expectLater(
        usecase.performBackup(),
        throwsException,
      );

      expect(configRepository.lastErrorMessage, contains('Upload failed'));
    });

    test('performDailyBackup executes backup without interactive auth', () async {
      driveBackupService.authenticated = true;
      exportDataUsecase.returnPath = '${tempDir.path}/MacroTracker_DailyBackup.zip';

      await expectLater(
        usecase.performDailyBackup(),
        completes,
      );

      expect(driveBackupService.uploadCalls, 1);
    });
  });
}

class _FakeExportDataUsecaseWithoutWriting extends Fake implements ExportDataUsecase {
  String? returnPath;

  @override
  Future<String?> exportData(
    String zipFileName,
    String userActivityName,
    String userIntakeName,
    String trackedDayName,
    String recipeName,
    String bodyMeasurementName,
    String dailyHabitName,
    String userName,
    String configName, {
    String? customOutputPath,
  }) async {
    return returnPath; // Return path but do not write the file
  }
}
