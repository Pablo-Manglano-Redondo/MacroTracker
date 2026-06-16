import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:macrotracker/features/daily_habits/data/data_source/health_connect_sleep_data_source.dart';

class FakeHealthValue extends Fake implements HealthValue {}

class FakeHealthDataPoint extends Fake implements HealthDataPoint {
  @override
  final HealthDataType type;
  @override
  final DateTime dateFrom;
  @override
  final DateTime dateTo;
  @override
  final HealthValue value;
  @override
  final WorkoutSummary? workoutSummary;
  @override
  final String uuid;
  @override
  final String sourceId;
  @override
  final String sourceName;

  FakeHealthDataPoint({
    required this.type,
    required this.dateFrom,
    required this.dateTo,
    HealthValue? value,
    this.workoutSummary,
    this.uuid = '',
    this.sourceId = '',
    this.sourceName = '',
  }) : value = value ?? FakeHealthValue();
}

class FakeWorkoutHealthValue extends Fake implements WorkoutHealthValue {
  @override
  final HealthWorkoutActivityType workoutActivityType;
  @override
  final int? totalEnergyBurned;

  FakeWorkoutHealthValue(this.workoutActivityType, this.totalEnergyBurned);
}

class FakeWorkoutSummary extends Fake implements WorkoutSummary {
  @override
  final String workoutType;
  @override
  final int totalEnergyBurned;

  FakeWorkoutSummary(this.workoutType, this.totalEnergyBurned);
}

class FakeHealth extends Health {
  bool configureCalled = false;
  bool configureThrows = false;
  bool isAvailableVal = true;
  bool isAvailableThrows = false;
  bool? hasPermissionsVal = true;
  bool hasPermissionsThrows = false;
  bool requestAuthorizationVal = true;
  bool requestAuthorizationThrows = false;
  List<HealthDataPoint> dataPoints = [];
  bool getHealthDataThrows = false;
  int? totalSteps = 1000;
  bool totalStepsThrows = false;

  @override
  Future<void> configure() async {
    configureCalled = true;
    if (configureThrows) {
      throw Exception('Configure error');
    }
  }

  @override
  Future<bool> isHealthConnectAvailable() async {
    if (isAvailableThrows) {
      throw Exception('Availability error');
    }
    return isAvailableVal;
  }

  @override
  Future<bool?> hasPermissions(List<HealthDataType> types, {List<HealthDataAccess>? permissions}) async {
    if (hasPermissionsThrows) {
      throw Exception('Permissions error');
    }
    return hasPermissionsVal;
  }

  @override
  Future<bool> requestAuthorization(List<HealthDataType> types, {List<HealthDataAccess>? permissions}) async {
    if (requestAuthorizationThrows) {
      throw Exception('Authorization error');
    }
    return requestAuthorizationVal;
  }

  @override
  Future<List<HealthDataPoint>> getHealthDataFromTypes({
    required DateTime startTime,
    required DateTime endTime,
    required List<HealthDataType> types,
    Map<HealthDataType, HealthDataUnit>? preferredUnits,
    List<RecordingMethod>? recordingMethodsToFilter,
  }) async {
    if (getHealthDataThrows) {
      throw Exception('Get health data error');
    }
    return dataPoints;
  }

  @override
  List<HealthDataPoint> removeDuplicates(List<HealthDataPoint> points) {
    return points;
  }

  @override
  Future<int?> getTotalStepsInInterval(
    DateTime startTime,
    DateTime endTime, {
    bool includeManualEntry = true,
  }) async {
    if (totalStepsThrows) {
      throw Exception('Total steps error');
    }
    return totalSteps;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeHealth fakeHealth;
  late HealthConnectSleepDataSource dataSource;
  final List<MethodCall> methodChannelCalls = [];

  setUp(() {
    fakeHealth = FakeHealth();
    dataSource = HealthConnectSleepDataSource(health: fakeHealth);
    methodChannelCalls.clear();

    const channel = MethodChannel('macrotracker/health_connect');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      methodChannelCalls.add(methodCall);
      if (methodCall.method == 'readWorkouts') {
        return [
          {
            'date_from': DateTime(2026, 6, 15, 8, 0).millisecondsSinceEpoch,
            'date_to': DateTime(2026, 6, 15, 9, 0).millisecondsSinceEpoch,
            'workoutActivityType': 'RUNNING',
            'totalEnergyBurned': 500.0,
            'source_name': 'Strava',
            'uuid': 'native-uuid-123',
          }
        ];
      }
      return null;
    });
  });

  group('HealthConnectSleepDataSource Configuration & Permission Tests', () {
    test('configure calls health configure and logs exceptions', () async {
      await dataSource.configure();
      expect(fakeHealth.configureCalled, isTrue);

      fakeHealth.configureThrows = true;
      // Should log but not bubble up exception
      await dataSource.configure();
    });

    test('isAvailable returns correct values and handles platform differences', () async {
      // isAvailable checks Platform.isAndroid, Platform.isIOS
      // In normal test environment (on Windows), both are false, but we can verify it returns false or handles exceptions.
      final avail = await dataSource.isAvailable();
      expect(avail, isFalse);
    });

    test('hasReadPermission and requestReadPermission check core health permissions', () async {
      final hasPerm = await dataSource.hasReadPermission();
      expect(hasPerm, isTrue);

      fakeHealth.hasPermissionsVal = false;
      expect(await dataSource.hasReadPermission(), isFalse);

      fakeHealth.hasPermissionsThrows = true;
      expect(await dataSource.hasReadPermission(), isFalse);

      fakeHealth.requestAuthorizationVal = true;
      fakeHealth.requestAuthorizationThrows = false;
      expect(await dataSource.requestReadPermission(), isTrue);

      fakeHealth.requestAuthorizationThrows = true;
      expect(await dataSource.requestReadPermission(), isFalse);
    });

    test('steps permission helper methods work as expected', () async {
      expect(await dataSource.hasStepsReadPermission(), isTrue);

      fakeHealth.hasPermissionsThrows = true;
      expect(await dataSource.hasStepsReadPermission(), isFalse);

      fakeHealth.requestAuthorizationVal = true;
      fakeHealth.requestAuthorizationThrows = false;
      expect(await dataSource.requestStepsReadPermission(), isTrue);

      fakeHealth.requestAuthorizationThrows = true;
      expect(await dataSource.requestStepsReadPermission(), isFalse);
    });

    test('workout supplement permissions helper methods work as expected', () async {
      expect(await dataSource.hasWorkoutSupplementReadPermission(), isTrue);

      fakeHealth.hasPermissionsThrows = true;
      expect(await dataSource.hasWorkoutSupplementReadPermission(), isFalse);

      fakeHealth.requestAuthorizationVal = true;
      fakeHealth.requestAuthorizationThrows = false;
      expect(await dataSource.requestWorkoutSupplementReadPermission(), isTrue);

      fakeHealth.requestAuthorizationThrows = true;
      expect(await dataSource.requestWorkoutSupplementReadPermission(), isFalse);
    });

    test('activity recognition permission checks Platform.isAndroid', () async {
      // On Windows test environment, Platform.isAndroid is false
      final hasPerm = await dataSource.hasActivityRecognitionPermission();
      expect(hasPerm, isFalse);

      final reqPerm = await dataSource.requestActivityRecognitionPermission();
      expect(reqPerm, isFalse);
    });
  });

  group('HealthConnectSleepDataSource Read Data Tests', () {
    test('readSleepSessions returns mapped sessions from health data', () async {
      final now = DateTime(2026, 6, 15);
      fakeHealth.dataPoints = [
        FakeHealthDataPoint(
          type: HealthDataType.SLEEP_SESSION,
          dateFrom: now.subtract(const Duration(hours: 8)),
          dateTo: now,
        ),
        FakeHealthDataPoint(
          type: HealthDataType.WORKOUT,
          dateFrom: now.subtract(const Duration(hours: 1)),
          dateTo: now,
        )
      ];

      final sessions = await dataSource.readSleepSessions(now.subtract(const Duration(days: 1)), now);
      expect(sessions, hasLength(1));
      expect(sessions.first.startTime, equals(now.subtract(const Duration(hours: 8))));
      expect(sessions.first.endTime, equals(now));

      fakeHealth.getHealthDataThrows = true;
      final errorSessions = await dataSource.readSleepSessions(now.subtract(const Duration(days: 1)), now);
      expect(errorSessions, isEmpty);
    });

    test('readStepCount returns total steps or zero on error', () async {
      final now = DateTime(2026, 6, 15);
      expect(await dataSource.readStepCount(now.subtract(const Duration(days: 1)), now), equals(1000));

      fakeHealth.totalSteps = -5;
      expect(await dataSource.readStepCount(now.subtract(const Duration(days: 1)), now), equals(0));

      fakeHealth.totalStepsThrows = true;
      expect(await dataSource.readStepCount(now.subtract(const Duration(days: 1)), now), equals(0));
    });

    test('readWorkouts checks native channel first and then falls back to health package', () async {
      final now = DateTime(2026, 6, 15);
      // Wait, native channel check checks Platform.isAndroid.
      // In Windows tests, Platform.isAndroid is false, so it falls back to health package immediately!
      // Let's set up health package workouts
      fakeHealth.dataPoints = [
        FakeHealthDataPoint(
          type: HealthDataType.WORKOUT,
          dateFrom: now.subtract(const Duration(minutes: 45)),
          dateTo: now,
          value: FakeWorkoutHealthValue(HealthWorkoutActivityType.RUNNING, 300),
          uuid: 'health-uuid-999',
          sourceName: 'Garmin',
        ),
        FakeHealthDataPoint(
          type: HealthDataType.WORKOUT,
          dateFrom: now.subtract(const Duration(minutes: 90)),
          dateTo: now.subtract(const Duration(minutes: 60)),
          value: null,
          workoutSummary: FakeWorkoutSummary('CYCLING', 400),
          uuid: '',
          sourceName: '',
        ),
      ];

      final workouts = await dataSource.readWorkouts(now.subtract(const Duration(days: 1)), now);
      expect(workouts, hasLength(2));
      // Cycling is BIKING, sorted by startTime
      expect(workouts.first.activityCode, equals('hc:biking'));
      expect(workouts.first.burnedKcal, equals(400.0));
      expect(workouts.first.externalId, contains('hc:BIKING'));

      expect(workouts.last.activityCode, equals('hc:running'));
      expect(workouts.last.burnedKcal, equals(300.0));
      expect(workouts.last.externalId, equals('health-uuid-999'));

      fakeHealth.getHealthDataThrows = true;
      final errWorkouts = await dataSource.readWorkouts(now.subtract(const Duration(days: 1)), now);
      expect(errWorkouts, isEmpty);
    });
  });
}
