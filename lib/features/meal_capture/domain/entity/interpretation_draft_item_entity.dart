import 'package:equatable/equatable.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/confidence_band_entity.dart';

class InterpretationDraftItemEntity extends Equatable {
  final String id;
  final String label;
  final MealEntity? matchedMealSnapshot;
  final double amount;
  final String unit;
  final double kcal;
  final double carbs;
  final double fat;
  final double protein;
  final ConfidenceBandEntity confidenceBand;
  final bool editable;
  final bool removed;

  const InterpretationDraftItemEntity({
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

  InterpretationDraftItemEntity copyWith({
    String? id,
    String? label,
    MealEntity? matchedMealSnapshot,
    double? amount,
    String? unit,
    double? kcal,
    double? carbs,
    double? fat,
    double? protein,
    ConfidenceBandEntity? confidenceBand,
    bool? editable,
    bool? removed,
  }) {
    return InterpretationDraftItemEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      matchedMealSnapshot: matchedMealSnapshot ?? this.matchedMealSnapshot,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      kcal: kcal ?? this.kcal,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      protein: protein ?? this.protein,
      confidenceBand: confidenceBand ?? this.confidenceBand,
      editable: editable ?? this.editable,
      removed: removed ?? this.removed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        label,
        matchedMealSnapshot,
        amount,
        unit,
        kcal,
        carbs,
        fat,
        protein,
        confidenceBand,
        editable,
        removed,
      ];
}
