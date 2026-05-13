import 'dart:io';

import 'package:macrotracker/features/settings/domain/usecase/export_data_usecase.dart';
import 'package:macrotracker/features/settings/presentation/bloc/export_import_bloc.dart';
import 'package:path_provider/path_provider.dart';

/// Abstract service to handle Google Drive authentication and upload.
/// Implementation requires `google_sign_in` and `googleapis` packages.
abstract class DriveBackupService {
  Future<bool> isAuthenticated();
  Future<void> authenticate();
  Future<void> uploadBackupFile(File file, String fileName);
}

class BackupToDriveUsecase {
  final ExportDataUsecase _exportDataUsecase;
  final DriveBackupService _driveBackupService;

  BackupToDriveUsecase(this._exportDataUsecase, this._driveBackupService);

  Future<void> performBackup() async {
    // 1. Ensure the user has authenticated with Google Drive
    if (!await _driveBackupService.isAuthenticated()) {
      // Note: In a background isolate, we cannot prompt for authentication UI.
      // The user must have authenticated in the foreground previously.
      // If the token is expired and cannot be refreshed, the backup fails.
      return;
    }

    // 2. Determine a temporary path to save the zip file without UI prompt
    final tempDir = await getTemporaryDirectory();
    final backupPath = '${tempDir.path}/MacroTracker_DailyBackup.zip';

    // 3. Export data directly to the file system
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

    if (savedPath != null) {
      final backupFile = File(savedPath);
      if (await backupFile.exists()) {
        // 4. Upload the generated zip to Google Drive
        await _driveBackupService.uploadBackupFile(
          backupFile,
          'MacroTracker_Backup_${DateTime.now().toIso8601String().split('T').first}.zip',
        );

        // 5. Clean up the local temporary file
        await backupFile.delete();
      }
    }
  }

  /// Performs a daily background backup to Google Drive.
  ///
  /// This should be called by a background worker (e.g. Workmanager) periodically.
  Future<void> performDailyBackup() async {
    await performBackup();
  }
}
