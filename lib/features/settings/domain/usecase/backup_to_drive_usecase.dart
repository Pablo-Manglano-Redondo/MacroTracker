import 'dart:io';

import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/features/settings/domain/usecase/export_data_usecase.dart';
import 'package:macrotracker/features/settings/presentation/bloc/export_import_bloc.dart';
import 'package:path_provider/path_provider.dart';

/// Abstract service to handle Google Drive authentication and upload.
/// Implementation requires `google_sign_in` and `googleapis` packages.
abstract class DriveBackupService {
  Future<bool> isAuthenticated();
  Future<void> authenticate();
  Future<DriveBackupUploadResult> uploadBackupFile(
    File file,
    String fileName, {
    bool allowInteractiveAuthentication = true,
  });
}

class DriveBackupUploadResult {
  final String? fileId;
  final String? fileName;
  final String? webViewLink;

  const DriveBackupUploadResult({
    this.fileId,
    this.fileName,
    this.webViewLink,
  });
}

class BackupToDriveUsecase {
  final ExportDataUsecase _exportDataUsecase;
  final DriveBackupService _driveBackupService;
  final ConfigRepository _configRepository;

  BackupToDriveUsecase(
    this._exportDataUsecase,
    this._driveBackupService,
    this._configRepository,
  );

  Future<DriveBackupUploadResult> performBackup({
    bool allowInteractiveAuthentication = true,
  }) async {
    final attemptIso = DateTime.now().toIso8601String();
    File? backupFile;

    try {
      if (!await _driveBackupService.isAuthenticated()) {
        if (!allowInteractiveAuthentication) {
          throw StateError('Google Drive account is not connected.');
        }
        await _driveBackupService.authenticate();
      }

      final tempDir = await getTemporaryDirectory();
      final backupPath = '${tempDir.path}/MacroTracker_DailyBackup.zip';

      final savedPath = await _exportDataUsecase.exportData(
        ExportImportBloc.exportZipFileName,
        ExportImportBloc.userActivityJsonFileName,
        ExportImportBloc.userIntakeJsonFileName,
        ExportImportBloc.trackedDayJsonFileName,
        ExportImportBloc.recipeJsonFileName,
        ExportImportBloc.bodyMeasurementJsonFileName,
        ExportImportBloc.dailyHabitJsonFileName,
        ExportImportBloc.userJsonFileName,
        ExportImportBloc.configJsonFileName,
        customOutputPath: backupPath,
      );

      if (savedPath == null) {
        throw StateError('Backup export did not produce a file.');
      }

      backupFile = File(savedPath);
      if (!await backupFile.exists()) {
        throw StateError('Backup file was not created on disk.');
      }

      final result = await _driveBackupService.uploadBackupFile(
        backupFile,
        'MacroTracker_Backup_${DateTime.now().toIso8601String().split('T').first}.zip',
        allowInteractiveAuthentication: allowInteractiveAuthentication,
      );
      await _configRepository.setGoogleDriveBackupStatus(
        attemptedAtIso: attemptIso,
        successAtIso: DateTime.now().toIso8601String(),
      );
      return result;
    } catch (error) {
      await _configRepository.setGoogleDriveBackupStatus(
        attemptedAtIso: attemptIso,
        errorMessage: error.toString(),
      );
      rethrow;
    } finally {
      if (backupFile != null && await backupFile.exists()) {
        await backupFile.delete();
      }
    }
  }

  /// Performs a daily background backup to Google Drive.
  ///
  /// This should be called by a background worker (e.g. Workmanager) periodically.
  Future<void> performDailyBackup() async {
    await performBackup(allowInteractiveAuthentication: false);
  }
}
