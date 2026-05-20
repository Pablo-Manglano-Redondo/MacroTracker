class HealthConnectSyncStatusEntity {
  final bool isAvailable;
  final bool hasHealthPermissions;
  final bool hasActivityRecognitionPermission;
  final bool hasStepsPermission;
  final bool hasWorkoutSupplementPermission;
  final bool isAutoSyncEnabled;

  const HealthConnectSyncStatusEntity({
    required this.isAvailable,
    required this.hasHealthPermissions,
    required this.hasActivityRecognitionPermission,
    this.hasStepsPermission = false,
    this.hasWorkoutSupplementPermission = false,
    required this.isAutoSyncEnabled,
  });

  bool get canSync =>
      isAvailable &&
      hasHealthPermissions &&
      hasActivityRecognitionPermission &&
      hasStepsPermission &&
      hasWorkoutSupplementPermission;

  bool get canSyncCore =>
      isAvailable && hasHealthPermissions && hasActivityRecognitionPermission;
}
