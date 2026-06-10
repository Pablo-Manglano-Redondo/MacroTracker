import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pending_snapshot_sync_dbo.g.dart';

@HiveType(typeId: 26)
@JsonSerializable()
class PendingSnapshotSyncDBO extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String relationshipId;

  @HiveField(2)
  final String professionalId;

  @HiveField(3)
  final String clientId;

  @HiveField(4)
  final DateTime day;

  @HiveField(5)
  final double kcalActual;

  @HiveField(6)
  final double kcalTarget;

  @HiveField(7)
  final double carbsActual;

  @HiveField(8)
  final double carbsTarget;

  @HiveField(9)
  final double fatActual;

  @HiveField(10)
  final double fatTarget;

  @HiveField(11)
  final double proteinActual;

  @HiveField(12)
  final double proteinTarget;

  @HiveField(13)
  final int mealsLogged;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final String? notes;

  @HiveField(16)
  final double? weightKg;

  @HiveField(17)
  final double? waistCm;

  PendingSnapshotSyncDBO({
    required this.id,
    required this.relationshipId,
    required this.professionalId,
    required this.clientId,
    required this.day,
    required this.kcalActual,
    required this.kcalTarget,
    required this.carbsActual,
    required this.carbsTarget,
    required this.fatActual,
    required this.fatTarget,
    required this.proteinActual,
    required this.proteinTarget,
    required this.mealsLogged,
    required this.createdAt,
    this.notes,
    this.weightKg,
    this.waistCm,
  });

  factory PendingSnapshotSyncDBO.fromJson(Map<String, dynamic> json) =>
      _$PendingSnapshotSyncDBOFromJson(json);

  Map<String, dynamic> toJson() => _$PendingSnapshotSyncDBOToJson(this);
}
