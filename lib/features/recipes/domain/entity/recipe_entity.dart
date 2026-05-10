import 'package:equatable/equatable.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';

class RecipeEntity extends Equatable {
  final String id;
  final String name;
  final String? notes;
  final double defaultServings;
  final double? yieldQuantity;
  final String? yieldUnit;
  final bool saved;
  final bool pinned;
  final int timesUsed;
  final DateTime? lastUsedAt;
  final QuickRecipeCategoryEntity? quickCategory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RecipeIngredientEntity> ingredients;

  const RecipeEntity({
    required this.id,
    required this.name,
    required this.notes,
    required this.defaultServings,
    required this.yieldQuantity,
    required this.yieldUnit,
    required this.saved,
    required this.pinned,
    required this.timesUsed,
    required this.lastUsedAt,
    required this.quickCategory,
    required this.createdAt,
    required this.updatedAt,
    required this.ingredients,
  });

  RecipeEntity copyWith({
    String? id,
    String? name,
    String? notes,
    double? defaultServings,
    double? yieldQuantity,
    String? yieldUnit,
    bool? saved,
    bool? pinned,
    int? timesUsed,
    DateTime? lastUsedAt,
    QuickRecipeCategoryEntity? quickCategory,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<RecipeIngredientEntity>? ingredients,
  }) {
    return RecipeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      defaultServings: defaultServings ?? this.defaultServings,
      yieldQuantity: yieldQuantity ?? this.yieldQuantity,
      yieldUnit: yieldUnit ?? this.yieldUnit,
      saved: saved ?? this.saved,
      pinned: pinned ?? this.pinned,
      timesUsed: timesUsed ?? this.timesUsed,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      quickCategory: quickCategory ?? this.quickCategory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ingredients: ingredients ?? this.ingredients,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        notes,
        defaultServings,
        yieldQuantity,
        yieldUnit,
        saved,
        pinned,
        timesUsed,
        lastUsedAt,
        quickCategory,
        createdAt,
        updatedAt,
        ingredients,
      ];
}
