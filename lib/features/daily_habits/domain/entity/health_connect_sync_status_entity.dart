class HealthConnectSyncStatusEntity {
  final bool isAvailable;
  final bool hasHealthPermissions;
  final bool hasActivityRecognitionPermission;
  final bool isAutoSyncEnabled;

  const HealthConnectSyncStatusEntity({
    required this.isAvailable,
    required this.hasHealthPermissions,
    required this.hasActivityRecognitionPermission,
    required this.isAutoSyncEnabled,
  });

  bool get canSync =>
      isAvailable && hasHealthPermissions && hasActivityRecognitionPermission;
}
