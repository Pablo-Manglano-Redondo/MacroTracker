import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';

enum QuickRecipeCategoryEntity {
  preWorkout,
  postWorkout,
  shake,
  leanMeal,
}

extension QuickRecipeCategoryEntityX on QuickRecipeCategoryEntity {
  String get label {
    switch (this) {
      case QuickRecipeCategoryEntity.preWorkout:
        return 'Pre';
      case QuickRecipeCategoryEntity.postWorkout:
        return 'Post';
      case QuickRecipeCategoryEntity.shake:
        return 'Shake';
      case QuickRecipeCategoryEntity.leanMeal:
        return 'Lean';
    }
  }

  IconData get icon {
    switch (this) {
      case QuickRecipeCategoryEntity.preWorkout:
        return Icons.bolt_outlined;
      case QuickRecipeCategoryEntity.postWorkout:
        return Icons.fitness_center_outlined;
      case QuickRecipeCategoryEntity.shake:
        return Icons.local_drink_outlined;
      case QuickRecipeCategoryEntity.leanMeal:
        return Icons.restaurant_outlined;
    }
  }

  static QuickRecipeCategoryEntity inferFromRecipe(RecipeEntity recipe) {
    final text = '${recipe.name} ${recipe.notes ?? ''}'.toLowerCase();

    if (_containsAny(text, const [
      '#post',
      'post ',
      'post workout',
      'post-workout',
      'postworkout',
      'after workout',
      'after training',
      'post gym',
    ])) {
      return QuickRecipeCategoryEntity.postWorkout;
    }

    if (_containsAny(text, const [
      '#shake',
      'shake',
      'smoothie',
      'whey',
      'protein yogurt',
      'protein pudding',
    ])) {
      return QuickRecipeCategoryEntity.shake;
    }

    if (_containsAny(text, const [
      '#pre',
      'pre ',
      'pre workout',
      'pre-workout',
      'preworkout',
      'before workout',
      'before training',
      'pre gym',
    ])) {
      return QuickRecipeCategoryEntity.preWorkout;
    }

    return QuickRecipeCategoryEntity.leanMeal;
  }

  static IntakeTypeEntity inferIntakeType(
    RecipeEntity recipe,
    QuickRecipeCategoryEntity category,
  ) {
    final text = '${recipe.name} ${recipe.notes ?? ''}'.toLowerCase();
    if (_containsAny(
        text, const ['breakfast', 'desayuno', 'oats', 'overnight'])) {
      return IntakeTypeEntity.breakfast;
    }
    if (_containsAny(text, const ['dinner', 'cena'])) {
      return IntakeTypeEntity.dinner;
    }
    if (_containsAny(
        text, const ['lunch', 'comida', 'rice bowl', 'meal prep'])) {
      return IntakeTypeEntity.lunch;
    }

    switch (category) {
      case QuickRecipeCategoryEntity.preWorkout:
      case QuickRecipeCategoryEntity.postWorkout:
      case QuickRecipeCategoryEntity.shake:
        return IntakeTypeEntity.snack;
      case QuickRecipeCategoryEntity.leanMeal:
        return IntakeTypeEntity.lunch;
    }
  }

  static bool _containsAny(String text, List<String> patterns) {
    return patterns.any(text.contains);
  }
}
