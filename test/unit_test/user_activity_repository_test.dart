import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/data/dbo/user_activity_dbo.dart';
import 'package:macrotracker/core/data/repository/user_activity_repository.dart';
import 'package:macrotracker/core/data/data_source/user_activity_data_source.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import '../fixture/physical_activity_entity_fixtures.dart';

class _FakeUserActivityDataSource extends Fake implements UserActivityDataSource {
  final List<UserActivityDBO> activities = [];
  bool addCalled = false;
  bool addAllCalled = false;
  bool deleteCalled = false;

  @override
  Future<void> addUserActivity(UserActivityDBO activityDBO) async {
    addCalled = true;
    activities.add(activityDBO);
  }

  @override
  Future<void> addAllUserActivities(List<UserActivityDBO> list) async {
    addAllCalled = true;
    activities.addAll(list);
  }

  @override
  Future<void> deleteIntakeFromId(String id) async {
    deleteCalled = true;
    activities.removeWhere((a) => a.id == id);
  }

  @override
  Future<List<UserActivityDBO>> getAllUserActivities() async {
    return activities;
  }

  @override
  Future<List<UserActivityDBO>> getAllUserActivitiesByDate(DateTime date) async {
    return activities.where((a) => _isSameDay(a.date, date)).toList();
  }

  @override
  Future<List<UserActivityDBO>> getRecentlyAddedUserActivity({int number = 20}) async {
    return activities;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

void main() {
  group('UserActivityRepository Tests', () {
    late _FakeUserActivityDataSource dataSource;
    late UserActivityRepository repository;

    setUp(() {
      dataSource = _FakeUserActivityDataSource();
      repository = UserActivityRepository(dataSource);
    });

    final dummyActivity = UserActivityEntity(
      'act-1',
      30.0,
      250.0,
      DateTime(2026, 6, 16),
      PhysicalActivityFixtures.vigorousRunning,
      source: UserActivitySourceEntity.manual,
    );

    test('addUserActivity converts to DBO and adds to dataSource', () async {
      await repository.addUserActivity(dummyActivity);

      expect(dataSource.addCalled, isTrue);
      expect(dataSource.activities, hasLength(1));
      expect(dataSource.activities.first.id, 'act-1');
      expect(dataSource.activities.first.duration, 30.0);
    });

    test('addAllUserActivityDBOs delegates to dataSource', () async {
      final dbo = UserActivityDBO.fromUserActivityEntity(dummyActivity);
      await repository.addAllUserActivityDBOs([dbo]);

      expect(dataSource.addAllCalled, isTrue);
      expect(dataSource.activities, hasLength(1));
    });

    test('deleteUserActivity deletes by ID from dataSource', () async {
      final dbo = UserActivityDBO.fromUserActivityEntity(dummyActivity);
      dataSource.activities.add(dbo);

      await repository.deleteUserActivity(dummyActivity);

      expect(dataSource.deleteCalled, isTrue);
      expect(dataSource.activities, isEmpty);
    });

    test('getAllUserActivityDBO returns DBO list from dataSource', () async {
      final dbo = UserActivityDBO.fromUserActivityEntity(dummyActivity);
      dataSource.activities.add(dbo);

      final results = await repository.getAllUserActivityDBO();
      expect(results, hasLength(1));
      expect(results.first.id, 'act-1');
    });

    test('getAllUserActivityByDate filters and returns entities', () async {
      final targetDate = DateTime(2026, 6, 16);
      final otherDate = DateTime(2026, 6, 15);
      
      final act1 = dummyActivity;
      final act2 = UserActivityEntity(
        'act-2', 45.0, 300.0, otherDate, PhysicalActivityFixtures.lightDancing,
      );

      dataSource.activities.addAll([
        UserActivityDBO.fromUserActivityEntity(act1),
        UserActivityDBO.fromUserActivityEntity(act2),
      ]);

      final results = await repository.getAllUserActivityByDate(targetDate);
      expect(results, hasLength(1));
      expect(results.first.id, 'act-1');
    });

    test('getRecentUserActivity maps and returns entities', () async {
      dataSource.activities.add(UserActivityDBO.fromUserActivityEntity(dummyActivity));

      final results = await repository.getRecentUserActivity();
      expect(results, hasLength(1));
      expect(results.first.id, 'act-1');
    });

    test('getAllUserActivity maps and returns all entities', () async {
      dataSource.activities.add(UserActivityDBO.fromUserActivityEntity(dummyActivity));

      final results = await repository.getAllUserActivity();
      expect(results, hasLength(1));
      expect(results.first.id, 'act-1');
    });
  });
}
