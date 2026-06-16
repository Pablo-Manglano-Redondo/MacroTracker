import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/logger_config.dart';
import 'package:macrotracker/features/settings/domain/usecase/backup_to_drive_usecase.dart';
import 'package:workmanager/workmanager.dart';

const googleDriveDailyBackupTask = 'google-drive-daily-backup-task';
const googleDriveDailyBackupUniqueName = 'google-drive-daily-backup';

@pragma('vm:entry-point')
void driveBackupCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    LoggerConfig.intiLogger();
    final log = Logger('DriveBackupWorker');

    try {
      await initLocator();

      if (task != googleDriveDailyBackupTask) {
        log.warning('Unknown background task: $task');
        return false;
      }

      final config = await locator<ConfigRepository>().getConfig();
      if (!config.googleDriveAutoBackupEnabled) {
        log.info('Skipping disabled Google Drive daily backup task.');
        return true;
      }

      await locator<BackupToDriveUsecase>().performDailyBackup();
      return true;
    } catch (error, stackTrace) {
      log.severe('Google Drive daily backup failed', error, stackTrace);
      try {
        if (!locator.isRegistered<ConfigRepository>()) {
          await initLocator();
        }
        await locator<ConfigRepository>().setGoogleDriveBackupStatus(
          attemptedAtIso: DateTime.now().toIso8601String(),
          errorMessage: error.toString(),
        );
      } catch (_) {}
      return false;
    }
  });
}

Future<void> initializeDriveBackupWorker() async {
  if (!Platform.isAndroid) {
    return;
  }

  await Workmanager().initialize(
    driveBackupCallbackDispatcher,
  );
}

class AndroidDriveBackupScheduler {
  final Workmanager _workmanager;

  AndroidDriveBackupScheduler([Workmanager? workmanager])
      : _workmanager = workmanager ?? Workmanager();

  @visibleForTesting
  bool debugBypassPlatformCheck = false;

  Future<void> syncFromConfig(bool enabled) async {
    if (!Platform.isAndroid && !debugBypassPlatformCheck) {
      return;
    }
    if (enabled) {
      await scheduleDailyBackup();
      return;
    }
    await cancelDailyBackup();
  }

  Future<void> scheduleDailyBackup() async {
    if (!Platform.isAndroid && !debugBypassPlatformCheck) {
      return;
    }

    await _workmanager.registerPeriodicTask(
      googleDriveDailyBackupUniqueName,
      googleDriveDailyBackupTask,
      frequency: const Duration(days: 1),
      initialDelay: _nextBackupWindowDelay(),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(hours: 1),
    );
  }

  Future<void> cancelDailyBackup() async {
    if (!Platform.isAndroid && !debugBypassPlatformCheck) {
      return;
    }
    await _workmanager.cancelByUniqueName(googleDriveDailyBackupUniqueName);
  }

  Duration _nextBackupWindowDelay() {
    final now = DateTime.now();
    var nextRun = DateTime(now.year, now.month, now.day, 4);
    if (!nextRun.isAfter(now)) {
      nextRun = nextRun.add(const Duration(days: 1));
    }
    return nextRun.difference(now);
  }
}
