import 'package:equatable/equatable.dart';
import 'package:macrotracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';

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
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final double? potassium;
  final double? calcium;
  final double? iron;
  final double? vitaminC;
  final double? vitaminD;
  final int? novaGroup;
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
    this.fiber,
    this.sugar,
    this.sodium,
    this.potassium,
    this.calcium,
    this.iron,
    this.vitaminC,
    this.vitaminD,
    this.novaGroup,
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
    double? fiber,
    double? sugar,
    double? sodium,
    double? potassium,
    double? calcium,
    double? iron,
    double? vitaminC,
    double? vitaminD,
    int? novaGroup,
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
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      potassium: potassium ?? this.potassium,
      calcium: calcium ?? this.calcium,
      iron: iron ?? this.iron,
      vitaminC: vitaminC ?? this.vitaminC,
      vitaminD: vitaminD ?? this.vitaminD,
      novaGroup: novaGroup ?? this.novaGroup,
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
        fiber,
        sugar,
        sodium,
        potassium,
        calcium,
        iron,
        vitaminC,
        vitaminD,
        novaGroup,
        confidenceBand,
        editable,
        removed,
      ];
}
