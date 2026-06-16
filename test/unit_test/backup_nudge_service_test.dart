import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:macrotracker/core/domain/entity/app_theme_entity.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';
import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/services/backup_nudge_service.dart';

class _FakeConfigRepository implements ConfigRepository {
  ConfigEntity _config = const ConfigEntity(
    true,
    true,
    true,
    AppThemeEntity.system,
    googleDriveAutoBackupEnabled: false,
  );

  set config(ConfigEntity c) => _config = c;

  @override
  Future<ConfigEntity> getConfig() async => _config;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory tempDir;
  late _FakeConfigRepository fakeConfigRepo;
  late BackupNudgeService service;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('backup_nudge_test_');
    Hive.init(tempDir.path);
    fakeConfigRepo = _FakeConfigRepository();
    service = BackupNudgeService(fakeConfigRepo);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('BackupNudgeService.recordAppOpen', () {
    test('records first open date when box is empty', () async {
      await service.recordAppOpen();
      final box = await Hive.openBox('app_metadata');
      expect(box.get('first_app_open_date'), isNotNull);
    });

    test('does not overwrite an existing first open date', () async {
      final box = await Hive.openBox('app_metadata');
      const existing = '2026-01-01T00:00:00.000Z';
      await box.put('first_app_open_date', existing);

      await service.recordAppOpen();

      // Should still be the original value
      expect(box.get('first_app_open_date'), equals(existing));
    });
  });

  group('BackupNudgeService.shouldShowBackupNudge', () {
    test('returns false when nudge already shown', () async {
      final box = await Hive.openBox('app_metadata');
      await box.put('backup_nudge_shown', true);

      final result = await service.shouldShowBackupNudge();
      expect(result, isFalse);
    });

    test('returns false when no first open date is recorded', () async {
      final result = await service.shouldShowBackupNudge();
      expect(result, isFalse);
    });

    test('returns false when first open date is invalid string', () async {
      final box = await Hive.openBox('app_metadata');
      await box.put('first_app_open_date', 'not-a-date');

      final result = await service.shouldShowBackupNudge();
      expect(result, isFalse);
    });

    test('returns false when first open is fewer than 14 days ago', () async {
      final box = await Hive.openBox('app_metadata');
      final recent = DateTime.now().subtract(const Duration(days: 5));
      await box.put('first_app_open_date', recent.toIso8601String());

      final result = await service.shouldShowBackupNudge();
      expect(result, isFalse);
    });

    test('returns false when Google Drive backup is already enabled', () async {
      final box = await Hive.openBox('app_metadata');
      final old = DateTime.now().subtract(const Duration(days: 20));
      await box.put('first_app_open_date', old.toIso8601String());

      fakeConfigRepo.config = const ConfigEntity(
        true,
        true,
        true,
        AppThemeEntity.system,
        googleDriveAutoBackupEnabled: true,
      );

      final result = await service.shouldShowBackupNudge();
      expect(result, isFalse);
    });

    test('returns true when conditions are met: 14+ days, no backup, not shown', () async {
      final box = await Hive.openBox('app_metadata');
      final old = DateTime.now().subtract(const Duration(days: 20));
      await box.put('first_app_open_date', old.toIso8601String());

      // Drive backup disabled by default
      final result = await service.shouldShowBackupNudge();
      expect(result, isTrue);
    });

    test('returns true exactly at 14 days threshold', () async {
      final box = await Hive.openBox('app_metadata');
      // 14 days ago exactly (rounded down by inDays)
      final old = DateTime.now().subtract(const Duration(days: 14, seconds: 1));
      await box.put('first_app_open_date', old.toIso8601String());

      final result = await service.shouldShowBackupNudge();
      expect(result, isTrue);
    });
  });

  group('BackupNudgeService.markNudgeShown', () {
    test('marks nudge as shown in Hive', () async {
      await service.markNudgeShown();
      final box = await Hive.openBox('app_metadata');
      expect(box.get('backup_nudge_shown'), isTrue);
    });

    test('after marking shown, shouldShowBackupNudge returns false', () async {
      final box = await Hive.openBox('app_metadata');
      final old = DateTime.now().subtract(const Duration(days: 20));
      await box.put('first_app_open_date', old.toIso8601String());

      // Verify initially true
      expect(await service.shouldShowBackupNudge(), isTrue);

      // Mark as shown
      await service.markNudgeShown();

      // Now should be false
      expect(await service.shouldShowBackupNudge(), isFalse);
    });
  });
}
