import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/features/meal_capture/data/dbo/interpretation_draft_item_dbo.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';

part 'interpretation_draft_dbo.g.dart';

@HiveType(typeId: 20)
enum DraftSourceDBO {
  @HiveField(0)
  text,
  @HiveField(1)
  photo;

  factory DraftSourceDBO.fromEntity(DraftSourceEntity entity) {
    switch (entity) {
      case DraftSourceEntity.text:
        return DraftSourceDBO.text;
      case DraftSourceEntity.photo:
        return DraftSourceDBO.photo;
    }
  }
}

@HiveType(typeId: 21)
enum DraftStatusDBO {
  @HiveField(0)
  pending,
  @HiveField(1)
  ready,
  @HiveField(2)
  failed,
  @HiveField(3)
  expired;

  factory DraftStatusDBO.fromEntity(DraftStatusEntity entity) {
    switch (entity) {
      case DraftStatusEntity.pending:
        return DraftStatusDBO.pending;
      case DraftStatusEntity.ready:
        return DraftStatusDBO.ready;
      case DraftStatusEntity.failed:
        return DraftStatusDBO.failed;
      case DraftStatusEntity.expired:
        return DraftStatusDBO.expired;
    }
  }
}

@HiveType(typeId: 22)
@JsonSerializable()
class InterpretationDraftDBO extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DraftSourceDBO sourceType;
  @HiveField(2)
  final String? inputText;
  @HiveField(3)
  final String? localImagePath;
  @HiveField(4)
  final String title;
  @HiveField(5)
  final String? summary;
  @HiveField(6)
  final double totalKcal;
  @HiveField(7)
  final double totalCarbs;
  @HiveField(8)
  final double totalFat;
  @HiveField(9)
  final double totalProtein;
  @HiveField(10)
  final ConfidenceBandDBO confidenceBand;
  @HiveField(11)
  DraftStatusDBO status;
  @HiveField(12)
  final DateTime createdAt;
  @HiveField(13)
  final DateTime expiresAt;
  @HiveField(14)
  final List<InterpretationDraftItemDBO> items;

  InterpretationDraftDBO({
    required this.id,
    required this.sourceType,
    required this.inputText,
    required this.localImagePath,
    required this.title,
    required this.summary,
    required this.totalKcal,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalProtein,
    required this.confidenceBand,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    required this.items,
  });

  factory InterpretationDraftDBO.fromEntity(InterpretationDraftEntity entity) {
    return InterpretationDraftDBO(
      id: entity.id,
      sourceType: DraftSourceDBO.fromEntity(entity.sourceType),
      inputText: entity.inputText,
      localImagePath: entity.localImagePath,
      title: entity.title,
      summary: entity.summary,
      totalKcal: entity.totalKcal,
      totalCarbs: entity.totalCarbs,
      totalFat: entity.totalFat,
      totalProtein: entity.totalProtein,
      confidenceBand: ConfidenceBandDBO.fromEntity(entity.confidenceBand),
      status: DraftStatusDBO.fromEntity(entity.status),
      createdAt: entity.createdAt,
      expiresAt: entity.expiresAt,
      items: entity.items.map(InterpretationDraftItemDBO.fromEntity).toList(),
    );
  }

  factory InterpretationDraftDBO.fromJson(Map<String, dynamic> json) =>
      _$InterpretationDraftDBOFromJson(json);

  Map<String, dynamic> toJson() => _$InterpretationDraftDBOToJson(this);
}
