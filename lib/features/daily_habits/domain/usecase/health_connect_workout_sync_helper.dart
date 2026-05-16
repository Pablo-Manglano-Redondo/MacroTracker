import 'package:macrotracker/features/daily_habits/domain/entity/health_connect_workout_entity.dart';

List<HealthConnectWorkoutEntity> filterHealthConnectWorkoutsToImport(
  List<HealthConnectWorkoutEntity> workouts, {
  required Iterable<String> existingExternalIds,
  required Iterable<String> discardedExternalIds,
  required DateTime windowStart,
  required DateTime windowEnd,
}) {
  final existingIds = existingExternalIds.toSet();
  final discardedIds = discardedExternalIds.toSet();
  final importableWorkouts = <HealthConnectWorkoutEntity>[];

  for (final workout in workouts) {
    final overlapsWindow =
        workout.endTime.isAfter(windowStart) &&
            workout.startTime.isBefore(windowEnd);
    if (!overlapsWindow) {
      continue;
    }

    if (existingIds.contains(workout.externalId) ||
        discardedIds.contains(workout.externalId) ||
        importableWorkouts.any((alreadyAdded) =>
            alreadyAdded.externalId == workout.externalId)) {
      continue;
    }

    importableWorkouts.add(workout);
  }

  importableWorkouts.sort(
    (left, right) => left.startTime.compareTo(right.startTime),
  );
  return importableWorkouts;
}
