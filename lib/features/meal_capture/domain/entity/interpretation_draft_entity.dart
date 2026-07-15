import 'package:equatable/equatable.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';

enum DraftSourceEntity {
  text,
  photo,
}

enum DraftStatusEntity {
  pending,
  ready,
  failed,
  expired,
}

class InterpretationDraftEntity extends Equatable {
  final String id;
  final DraftSourceEntity sourceType;
  final String? inputText;
  final String? localImagePath;
  final String title;
  final String? summary;
  final double totalKcal;
  final double totalCarbs;
  final double totalFat;
  final double totalProtein;
  final double? totalFiber;
  final double? totalSugar;
  final double? totalSodium;
  final double? totalPotassium;
  final double? totalCalcium;
  final double? totalIron;
  final double? totalVitaminC;
  final double? totalVitaminD;
  final ConfidenceBandEntity confidenceBand;
  final DraftStatusEntity status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<InterpretationDraftItemEntity> items;

  const InterpretationDraftEntity({
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
    this.totalFiber,
    this.totalSugar,
    this.totalSodium,
    this.totalPotassium,
    this.totalCalcium,
    this.totalIron,
    this.totalVitaminC,
    this.totalVitaminD,
    required this.confidenceBand,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    required this.items,
  });

  InterpretationDraftEntity copyWith({
    String? id,
    DraftSourceEntity? sourceType,
    String? inputText,
    String? localImagePath,
    String? title,
    String? summary,
    double? totalKcal,
    double? totalCarbs,
    double? totalFat,
    double? totalProtein,
    double? totalFiber,
    double? totalSugar,
    double? totalSodium,
    double? totalPotassium,
    double? totalCalcium,
    double? totalIron,
    double? totalVitaminC,
    double? totalVitaminD,
    ConfidenceBandEntity? confidenceBand,
    DraftStatusEntity? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<InterpretationDraftItemEntity>? items,
  }) {
    return InterpretationDraftEntity(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      inputText: inputText ?? this.inputText,
      localImagePath: localImagePath ?? this.localImagePath,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      totalKcal: totalKcal ?? this.totalKcal,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalProtein: totalProtein ?? this.totalProtein,
      totalFiber: totalFiber ?? this.totalFiber,
      totalSugar: totalSugar ?? this.totalSugar,
      totalSodium: totalSodium ?? this.totalSodium,
      totalPotassium: totalPotassium ?? this.totalPotassium,
      totalCalcium: totalCalcium ?? this.totalCalcium,
      totalIron: totalIron ?? this.totalIron,
      totalVitaminC: totalVitaminC ?? this.totalVitaminC,
      totalVitaminD: totalVitaminD ?? this.totalVitaminD,
      confidenceBand: confidenceBand ?? this.confidenceBand,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sourceType,
        inputText,
        localImagePath,
        title,
        summary,
        totalKcal,
        totalCarbs,
        totalFat,
        totalProtein,
        totalFiber,
        totalSugar,
        totalSodium,
        totalPotassium,
        totalCalcium,
        totalIron,
        totalVitaminC,
        totalVitaminD,
        confidenceBand,
        status,
        createdAt,
        expiresAt,
        items,
      ];
}
