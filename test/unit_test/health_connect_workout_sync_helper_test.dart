import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/health_connect_workout_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/health_connect_workout_sync_helper.dart';

void main() {
  group('health_connect_workout_sync_helper', () {
    test('keeps workouts inside the last 7 days and skips duplicates', () {
      final windowEnd = DateTime(2026, 5, 6, 0, 0);
      final windowStart = windowEnd.subtract(const Duration(days: 7));

      final workouts = [
        HealthConnectWorkoutEntity(
          externalId: 'old-workout',
          activityCode: 'hc:running',
          displayName: 'Running',
          description: 'Old workout',
          startTime: DateTime(2026, 4, 28, 9),
          endTime: DateTime(2026, 4, 28, 10),
          durationMinutes: 60,
          burnedKcal: 420,
        ),
        HealthConnectWorkoutEntity(
          externalId: 'recent-workout',
          activityCode: 'hc:cycling',
          displayName: 'Cycling',
          description: 'Recent workout',
          startTime: DateTime(2026, 5, 2, 18),
          endTime: DateTime(2026, 5, 2, 19),
          durationMinutes: 60,
          burnedKcal: 510,
        ),
        HealthConnectWorkoutEntity(
          externalId: 'duplicate-workout',
          activityCode: 'hc:swimming',
          displayName: 'Swimming',
          description: 'Duplicate workout',
          startTime: DateTime(2026, 5, 4, 7),
          endTime: DateTime(2026, 5, 4, 8),
          durationMinutes: 60,
          burnedKcal: 390,
        ),
        HealthConnectWorkoutEntity(
          externalId: 'duplicate-workout',
          activityCode: 'hc:swimming',
          displayName: 'Swimming',
          description: 'Duplicate workout again',
          startTime: DateTime(2026, 5, 4, 7),
          endTime: DateTime(2026, 5, 4, 8),
          durationMinutes: 60,
          burnedKcal: 390,
        ),
      ];

      final filtered = filterHealthConnectWorkoutsToImport(
        workouts,
        existingExternalIds: {'recent-workout'},
        discardedExternalIds: {'discarded-workout'},
        windowStart: windowStart,
        windowEnd: windowEnd,
      );

      expect(filtered, hasLength(1));
      expect(filtered.single.externalId, 'duplicate-workout');
    });

    test('skips workouts outside the sync window', () {
      final windowEnd = DateTime(2026, 5, 6, 0, 0);
      final windowStart = windowEnd.subtract(const Duration(days: 7));

      final filtered = filterHealthConnectWorkoutsToImport(
        [
          HealthConnectWorkoutEntity(
            externalId: 'too-old',
            activityCode: 'hc:running',
            displayName: 'Running',
            description: 'Too old',
            startTime: DateTime(2026, 4, 27, 23, 59),
            endTime: DateTime(2026, 4, 28, 0, 59),
            durationMinutes: 60,
            burnedKcal: 400,
          ),
          HealthConnectWorkoutEntity(
            externalId: 'inside-window',
            activityCode: 'hc:running',
            displayName: 'Running',
            description: 'Inside window',
            startTime: DateTime(2026, 4, 29, 8),
            endTime: DateTime(2026, 4, 29, 9),
            durationMinutes: 60,
            burnedKcal: 410,
          ),
        ],
        existingExternalIds: const [],
        discardedExternalIds: const [],
        windowStart: windowStart,
        windowEnd: windowEnd,
      );

      expect(filtered, hasLength(1));
      expect(filtered.single.externalId, 'inside-window');
    });
  });
}