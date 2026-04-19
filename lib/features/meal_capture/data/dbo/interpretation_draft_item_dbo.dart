import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/core/data/dbo/meal_dbo.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';

part 'interpretation_draft_item_dbo.g.dart';

@HiveType(typeId: 16)
enum ConfidenceBandDBO {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high;

  factory ConfidenceBandDBO.fromEntity(ConfidenceBandEntity entity) {
    switch (entity) {
      case ConfidenceBandEntity.low:
        return ConfidenceBandDBO.low;
      case ConfidenceBandEntity.medium:
        return ConfidenceBandDBO.medium;
      case ConfidenceBandEntity.high:
        return ConfidenceBandDBO.high;
    }
  }
}

@HiveType(typeId: 23)
@JsonSerializable()
class InterpretationDraftItemDBO extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String label;
  @HiveField(2)
  final MealDBO? matchedMealSnapshot;
  @HiveField(3)
  final double amount;
  @HiveField(4)
  final String unit;
  @HiveField(5)
  final double kcal;
  @HiveField(6)
  final double carbs;
  @HiveField(7)
  final double fat;
  @HiveField(8)
  final double protein;
  @HiveField(9)
  final ConfidenceBandDBO confidenceBand;
  @HiveField(10)
  final bool editable;
  @HiveField(11)
  bool removed;

  InterpretationDraftItemDBO({
    required this.id,
    required this.label,
    required this.matchedMealSnapshot,
    required this.amount,
    required this.unit,
    required this.kcal,
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.confidenceBand,
    required this.editable,
    required this.removed,
  });

  factory InterpretationDraftItemDBO.fromEntity(
      InterpretationDraftItemEntity entity) {
    return InterpretationDraftItemDBO(
      id: entity.id,
      label: entity.label,
      matchedMealSnapshot: entity.matchedMealSnapshot == null
          ? null
          : MealDBO.fromMealEntity(entity.matchedMealSnapshot!),
      amount: entity.amount,
      unit: entity.unit,
      kcal: entity.kcal,
      carbs: entity.carbs,
      fat: entity.fat,
      protein: entity.protein,
      confidenceBand: ConfidenceBandDBO.fromEntity(entity.confidenceBand),
      editable: entity.editable,
      removed: entity.removed,
    );
  }

  factory InterpretationDraftItemDBO.fromJson(Map<String, dynamic> json) =>
      _$InterpretationDraftItemDBOFromJson(json);

  Map<String, dynamic> toJson() => _$InterpretationDraftItemDBOToJson(this);
}
