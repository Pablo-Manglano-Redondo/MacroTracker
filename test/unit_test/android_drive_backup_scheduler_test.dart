import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/settings/data/services/android_drive_backup_scheduler.dart';
import 'package:workmanager/workmanager.dart';

class _PeriodicTaskCall {
  final String uniqueName;
  final String taskName;
  final Duration? frequency;
  final Duration? initialDelay;
  final Constraints? constraints;
  final ExistingPeriodicWorkPolicy? existingWorkPolicy;
  final BackoffPolicy? backoffPolicy;
  final Duration? backoffPolicyDelay;

  const _PeriodicTaskCall({
    required this.uniqueName,
    required this.taskName,
    required this.frequency,
    required this.initialDelay,
    required this.constraints,
    required this.existingWorkPolicy,
    required this.backoffPolicy,
    required this.backoffPolicyDelay,
  });
}

class _FakeWorkmanager extends Fake implements Workmanager {
  final periodicCalls = <_PeriodicTaskCall>[];
  final cancelledUniqueNames = <String>[];

  @override
  Future<void> registerPeriodicTask(
    String uniqueName,
    String taskName, {
    Duration? frequency,
    Duration? flexInterval,
    Map<String, dynamic>? inputData,
    Duration? initialDelay,
    Constraints? constraints,
    ExistingPeriodicWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    String? tag,
  }) async {
    periodicCalls.add(_PeriodicTaskCall(
      uniqueName: uniqueName,
      taskName: taskName,
      frequency: frequency,
      initialDelay: initialDelay,
      constraints: constraints,
      existingWorkPolicy: existingWorkPolicy,
      backoffPolicy: backoffPolicy,
      backoffPolicyDelay: backoffPolicyDelay,
    ));
  }

  @override
  Future<void> cancelByUniqueName(String uniqueName) async {
    cancelledUniqueNames.add(uniqueName);
  }
}

void main() {
  group('AndroidDriveBackupScheduler', () {
    test('returns without scheduling on non-Android hosts by default',
        () async {
      final workmanager = _FakeWorkmanager();
      final scheduler = AndroidDriveBackupScheduler(workmanager);

      await scheduler.scheduleDailyBackup();
      await scheduler.cancelDailyBackup();

      expect(workmanager.periodicCalls, isEmpty);
      expect(workmanager.cancelledUniqueNames, isEmpty);
    });

    test('scheduleDailyBackup registers the expected periodic work', () async {
      final workmanager = _FakeWorkmanager();
      final scheduler = AndroidDriveBackupScheduler(workmanager)
        ..debugBypassPlatformCheck = true;

      await scheduler.scheduleDailyBackup();

      expect(workmanager.periodicCalls, hasLength(1));
      final call = workmanager.periodicCalls.single;
      expect(call.uniqueName, googleDriveDailyBackupUniqueName);
      expect(call.taskName, googleDriveDailyBackupTask);
      expect(call.frequency, const Duration(days: 1));
      expect(call.initialDelay, isNotNull);
      expect(call.initialDelay! > Duration.zero, isTrue);
      expect(call.initialDelay! <= const Duration(days: 1), isTrue);
      expect(call.constraints?.networkType, NetworkType.connected);
      expect(call.existingWorkPolicy, ExistingPeriodicWorkPolicy.update);
      expect(call.backoffPolicy, BackoffPolicy.exponential);
      expect(call.backoffPolicyDelay, const Duration(hours: 1));
    });

    test('syncFromConfig delegates to schedule or cancel', () async {
      final workmanager = _FakeWorkmanager();
      final scheduler = AndroidDriveBackupScheduler(workmanager)
        ..debugBypassPlatformCheck = true;

      await scheduler.syncFromConfig(true);
      await scheduler.syncFromConfig(false);

      expect(workmanager.periodicCalls, hasLength(1));
      expect(
          workmanager.cancelledUniqueNames, [googleDriveDailyBackupUniqueName]);
    });
  });
}
