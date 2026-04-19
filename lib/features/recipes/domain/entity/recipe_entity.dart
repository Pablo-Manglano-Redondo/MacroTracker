import 'package:equatable/equatable.dart';
import 'package:opennutritracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';

class RecipeEntity extends Equatable {
  final String id;
  final String name;
  final String? notes;
  final double defaultServings;
  final double? yieldQuantity;
  final String? yieldUnit;
  final bool favorite;
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
    required this.favorite,
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
    bool? favorite,
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
      favorite: favorite ?? this.favorite,
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
        favorite,
        createdAt,
        updatedAt,
        ingredients,
      ];
}
