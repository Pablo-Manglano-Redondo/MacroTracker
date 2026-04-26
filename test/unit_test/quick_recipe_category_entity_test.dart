import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';

void main() {
  group('QuickRecipeCategoryEntity', () {
    test('infers categories from recipe names and notes', () {
      expect(
        QuickRecipeCategoryEntityX.inferFromRecipe(
            _recipe('Post chicken rice')),
        QuickRecipeCategoryEntity.postWorkout,
      );
      expect(
        QuickRecipeCategoryEntityX.inferFromRecipe(_recipe('Whey shake')),
        QuickRecipeCategoryEntity.shake,
      );
      expect(
        QuickRecipeCategoryEntityX.inferFromRecipe(
            _recipe('Rice cakes', notes: '#pre fuel')),
        QuickRecipeCategoryEntity.preWorkout,
      );
      expect(
        QuickRecipeCategoryEntityX.inferFromRecipe(_recipe('Lean turkey bowl')),
        QuickRecipeCategoryEntity.leanMeal,
      );
    });

    test('infers default intake type from recipe text and category', () {
      expect(
        QuickRecipeCategoryEntityX.inferIntakeType(
          _recipe('Overnight oats breakfast'),
          QuickRecipeCategoryEntity.preWorkout,
        ),
        IntakeTypeEntity.breakfast,
      );
      expect(
        QuickRecipeCategoryEntityX.inferIntakeType(
          _recipe('Greek yogurt shake'),
          QuickRecipeCategoryEntity.shake,
        ),
        IntakeTypeEntity.snack,
      );
      expect(
        QuickRecipeCategoryEntityX.inferIntakeType(
          _recipe('Chicken dinner'),
          QuickRecipeCategoryEntity.leanMeal,
        ),
        IntakeTypeEntity.dinner,
      );
    });
  });
}

RecipeEntity _recipe(String name, {String? notes}) {
  final now = DateTime(2025, 1, 1);
  return RecipeEntity(
    id: name,
    name: name,
    notes: notes,
    defaultServings: 1,
    yieldQuantity: null,
    yieldUnit: null,
    favorite: false,
    createdAt: now,
    updatedAt: now,
    ingredients: const [],
  );
}
