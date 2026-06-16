import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:macrotracker/core/services/app_review_service.dart';
import 'package:macrotracker/core/utils/hive_db_provider.dart';

class _FakeInAppReview extends Fake implements InAppReview {
  bool isAvailableVal = true;
  int requestReviewCalls = 0;

  @override
  Future<bool> isAvailable() async => isAvailableVal;

  @override
  Future<void> requestReview() async {
    requestReviewCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late HiveDBProvider hiveProvider;
  late _FakeInAppReview fakeInAppReview;
  late AppReviewService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('macrotracker_app_review_test_');

    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return tempDir.path;
    });

    hiveProvider = HiveDBProvider();
    final key = Hive.generateSecureKey();
    await hiveProvider.initHiveDB(Uint8List.fromList(key));

    fakeInAppReview = _FakeInAppReview();
    service = AppReviewService(fakeInAppReview);
  });

  tearDown(() async {
    await hiveProvider.clearAllData();
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AppReviewService Tests', () {
    test('recordDailyUsage increments consecutive days and triggers review at 5 days', () async {
      final box = await Hive.openBox('app_metadata');

      // Day 1
      await service.recordDailyUsage();
      expect(box.get('consecutive_days'), 1);
      expect(fakeInAppReview.requestReviewCalls, 0);

      // Re-recording today should be ignored
      await service.recordDailyUsage();
      expect(box.get('consecutive_days'), 1);

      // Simulate Day 2 (consecutive)
      final yesterdayStr = _dateString(DateTime.now().subtract(const Duration(days: 1)));
      await box.put('last_active_date', yesterdayStr);
      await service.recordDailyUsage();
      expect(box.get('consecutive_days'), 2);
      expect(fakeInAppReview.requestReviewCalls, 0);

      // Simulate Day 3 (consecutive)
      await box.put('last_active_date', _dateString(DateTime.now().subtract(const Duration(days: 1))));
      await service.recordDailyUsage();
      expect(box.get('consecutive_days'), 3);

      // Simulate Day 4 (consecutive)
      await box.put('last_active_date', _dateString(DateTime.now().subtract(const Duration(days: 1))));
      await service.recordDailyUsage();
      expect(box.get('consecutive_days'), 4);

      // Simulate Day 5 (consecutive) -> threshold met
      await box.put('last_active_date', _dateString(DateTime.now().subtract(const Duration(days: 1))));
      await service.recordDailyUsage();
      expect(box.get('consecutive_days'), 5);
      expect(fakeInAppReview.requestReviewCalls, 1);
      expect(box.get('review_prompted'), true);
    });

    test('recordDailyUsage resets consecutive count on gap', () async {
      final box = await Hive.openBox('app_metadata');

      // Set consecutive days to 3 but last active date to 3 days ago (gap)
      await box.put('consecutive_days', 3);
      final threeDaysAgoStr = _dateString(DateTime.now().subtract(const Duration(days: 3)));
      await box.put('last_active_date', threeDaysAgoStr);

      await service.recordDailyUsage();
      expect(box.get('consecutive_days'), 1);
      expect(fakeInAppReview.requestReviewCalls, 0);
    });

    test('recordAiMealCommitted triggers review at 10 meals', () async {
      final box = await Hive.openBox('app_metadata');

      // Commit 9 meals
      for (int i = 0; i < 9; i++) {
        await service.recordAiMealCommitted();
      }
      expect(box.get('committed_meals_count'), 9);
      expect(fakeInAppReview.requestReviewCalls, 0);

      // Commit 10th meal -> threshold met
      await service.recordAiMealCommitted();
      expect(box.get('committed_meals_count'), 10);
      expect(fakeInAppReview.requestReviewCalls, 1);
      expect(box.get('review_prompted'), true);

      // Subsequent commits do not trigger again
      await service.recordAiMealCommitted();
      expect(box.get('committed_meals_count'), 11);
      expect(fakeInAppReview.requestReviewCalls, 1);
    });
  });
}

String _dateString(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
