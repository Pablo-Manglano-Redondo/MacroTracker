import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';

enum QuickRecipeCategoryEntity {
  preWorkout,
  postWorkout,
  shake,
  leanMeal,
}

enum RecipeSaveCategoryEntity {
  breakfast,
  lunch,
  dinner,
  snack,
  preWorkout,
  postWorkout,
  shake,
  leanMeal,
}

extension RecipeSaveCategoryEntityX on RecipeSaveCategoryEntity {
  QuickRecipeCategoryEntity get quickCategory {
    switch (this) {
      case RecipeSaveCategoryEntity.breakfast:
      case RecipeSaveCategoryEntity.lunch:
      case RecipeSaveCategoryEntity.dinner:
      case RecipeSaveCategoryEntity.snack:
      case RecipeSaveCategoryEntity.leanMeal:
        return QuickRecipeCategoryEntity.leanMeal;
      case RecipeSaveCategoryEntity.preWorkout:
        return QuickRecipeCategoryEntity.preWorkout;
      case RecipeSaveCategoryEntity.postWorkout:
        return QuickRecipeCategoryEntity.postWorkout;
      case RecipeSaveCategoryEntity.shake:
        return QuickRecipeCategoryEntity.shake;
    }
  }

  IntakeTypeEntity? get explicitIntakeType {
    switch (this) {
      case RecipeSaveCategoryEntity.breakfast:
        return IntakeTypeEntity.breakfast;
      case RecipeSaveCategoryEntity.lunch:
        return IntakeTypeEntity.lunch;
      case RecipeSaveCategoryEntity.dinner:
        return IntakeTypeEntity.dinner;
      case RecipeSaveCategoryEntity.snack:
        return IntakeTypeEntity.snack;
      case RecipeSaveCategoryEntity.preWorkout:
      case RecipeSaveCategoryEntity.postWorkout:
      case RecipeSaveCategoryEntity.shake:
      case RecipeSaveCategoryEntity.leanMeal:
        return null;
    }
  }

  static RecipeSaveCategoryEntity fromIntakeType(IntakeTypeEntity intakeType) {
    switch (intakeType) {
      case IntakeTypeEntity.breakfast:
        return RecipeSaveCategoryEntity.breakfast;
      case IntakeTypeEntity.lunch:
        return RecipeSaveCategoryEntity.lunch;
      case IntakeTypeEntity.dinner:
        return RecipeSaveCategoryEntity.dinner;
      case IntakeTypeEntity.snack:
        return RecipeSaveCategoryEntity.snack;
    }
  }

  static RecipeSaveCategoryEntity inferDefault({
    required RecipeEntity recipe,
    required IntakeTypeEntity fallbackIntakeType,
  }) {
    final taggedIntakeType = QuickRecipeCategoryEntityX.inferTaggedIntakeType(
      recipe,
    );
    if (taggedIntakeType != null) {
      return fromIntakeType(taggedIntakeType);
    }

    if (fallbackIntakeType != IntakeTypeEntity.snack) {
      return fromIntakeType(fallbackIntakeType);
    }

    switch (QuickRecipeCategoryEntityX.inferFromRecipe(recipe)) {
      case QuickRecipeCategoryEntity.preWorkout:
        return RecipeSaveCategoryEntity.preWorkout;
      case QuickRecipeCategoryEntity.postWorkout:
        return RecipeSaveCategoryEntity.postWorkout;
      case QuickRecipeCategoryEntity.shake:
        return RecipeSaveCategoryEntity.shake;
      case QuickRecipeCategoryEntity.leanMeal:
        return RecipeSaveCategoryEntity.snack;
    }
  }

  static RecipeSaveCategoryEntity fromRecipe(RecipeEntity recipe) {
    final taggedIntakeType = QuickRecipeCategoryEntityX.inferTaggedIntakeType(
      recipe,
    );
    if (taggedIntakeType != null) {
      return fromIntakeType(taggedIntakeType);
    }

    switch (QuickRecipeCategoryEntityX.inferFromRecipe(recipe)) {
      case QuickRecipeCategoryEntity.preWorkout:
        return RecipeSaveCategoryEntity.preWorkout;
      case QuickRecipeCategoryEntity.postWorkout:
        return RecipeSaveCategoryEntity.postWorkout;
      case QuickRecipeCategoryEntity.shake:
        return RecipeSaveCategoryEntity.shake;
      case QuickRecipeCategoryEntity.leanMeal:
        return RecipeSaveCategoryEntity.leanMeal;
    }
  }
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
    if (recipe.quickCategory != null) {
      return recipe.quickCategory!;
    }
    return inferLegacyFromRecipe(recipe);
  }

  static QuickRecipeCategoryEntity inferLegacyFromRecipe(RecipeEntity recipe) {
    final text = '${recipe.name} ${recipe.notes ?? ''}'.toLowerCase();

    if (_containsAny(text, const [
      '#post',
      'post ',
      'post workout',
      'post-workout',
      'postworkout',
      'postentreno',
      'post entreno',
      'post-entreno',
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
      'preentreno',
      'pre entreno',
      'pre-entreno',
      'before workout',
      'before training',
      'pre gym',
    ])) {
      return QuickRecipeCategoryEntity.preWorkout;
    }

    return QuickRecipeCategoryEntity.leanMeal;
  }

  static IntakeTypeEntity? inferTaggedIntakeType(RecipeEntity recipe) {
    final text = '${recipe.name} ${recipe.notes ?? ''}'.toLowerCase();
    if (_containsAny(text, const ['#breakfast', '#desayuno'])) {
      return IntakeTypeEntity.breakfast;
    }
    if (_containsAny(text, const ['#lunch', '#comida'])) {
      return IntakeTypeEntity.lunch;
    }
    if (_containsAny(text, const ['#dinner', '#cena'])) {
      return IntakeTypeEntity.dinner;
    }
    if (_containsAny(text, const ['#snack', '#tentempie', '#tentempié'])) {
      return IntakeTypeEntity.snack;
    }
    return null;
  }

  static IntakeTypeEntity inferIntakeType(
    RecipeEntity recipe,
    QuickRecipeCategoryEntity category,
  ) {
    final taggedIntakeType = inferTaggedIntakeType(recipe);
    if (taggedIntakeType != null) {
      return taggedIntakeType;
    }

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

  static String? applyExplicitIntakeTypeTag(
    String? notes,
    IntakeTypeEntity? intakeType,
  ) {
    final cleaned = _stripExplicitIntakeTypeTags(notes);
    if (intakeType == null) {
      return cleaned;
    }

    final tag = switch (intakeType) {
      IntakeTypeEntity.breakfast => '#breakfast',
      IntakeTypeEntity.lunch => '#lunch',
      IntakeTypeEntity.dinner => '#dinner',
      IntakeTypeEntity.snack => '#snack',
    };
    if (cleaned == null || cleaned.isEmpty) {
      return tag;
    }
    return '$tag $cleaned';
  }

  static bool _containsAny(String text, List<String> patterns) {
    return patterns.any(text.contains);
  }

  static String? _stripExplicitIntakeTypeTags(String? notes) {
    if (notes == null) {
      return null;
    }

    final cleaned = notes
        .replaceAll(RegExp(r'#breakfast\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#desayuno\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#lunch\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#comida\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#dinner\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#cena\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#snack\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#tentempie\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'#tentempié\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned.isEmpty ? null : cleaned;
  }
}
