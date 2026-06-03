import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';

/// Nudges the user to enable Google Drive backup after 14 days of usage
/// if they haven't activated it yet.
class BackupNudgeService {
  static const _boxName = 'app_metadata';
  static const _firstOpenDateKey = 'first_app_open_date';
  static const _nudgeShownKey = 'backup_nudge_shown';
  static const int _nudgeDaysThreshold = 14;

  final ConfigRepository _configRepository;
  final _log = Logger('BackupNudgeService');

  BackupNudgeService(this._configRepository);

  /// Records the first time the app is opened. Idempotent.
  Future<void> recordAppOpen() async {
    try {
      final box = await Hive.openBox(_boxName);
      if (box.get(_firstOpenDateKey) == null) {
        await box.put(_firstOpenDateKey, DateTime.now().toIso8601String());
      }
    } catch (e) {
      _log.warning('Failed to record app open for backup nudge', e);
    }
  }

  /// Returns `true` if the nudge should be shown:
  /// - App opened ≥14 days ago
  /// - Google Drive auto-backup is NOT enabled
  /// - Nudge has NOT been shown before
  Future<bool> shouldShowBackupNudge() async {
    try {
      final box = await Hive.openBox(_boxName);
      final alreadyShown =
          box.get(_nudgeShownKey, defaultValue: false) as bool;
      if (alreadyShown) return false;

      final firstOpenStr = box.get(_firstOpenDateKey) as String?;
      if (firstOpenStr == null) return false;

      final firstOpen = DateTime.tryParse(firstOpenStr);
      if (firstOpen == null) return false;

      final daysSinceFirstOpen =
          DateTime.now().difference(firstOpen).inDays;
      if (daysSinceFirstOpen < _nudgeDaysThreshold) return false;

      final config = await _configRepository.getConfig();
      if (config.googleDriveAutoBackupEnabled) return false;

      return true;
    } catch (e) {
      _log.warning('Failed to check backup nudge eligibility', e);
      return false;
    }
  }

  /// Mark the nudge as shown so it does not appear again.
  Future<void> markNudgeShown() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_nudgeShownKey, true);
    } catch (e) {
      _log.warning('Failed to mark backup nudge as shown', e);
    }
  }
}
