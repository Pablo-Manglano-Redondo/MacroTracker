class HealthSleepSessionEntity {
  final DateTime startTime;
  final DateTime endTime;

  const HealthSleepSessionEntity({
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);
}
