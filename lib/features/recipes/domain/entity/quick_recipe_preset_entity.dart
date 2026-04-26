import 'package:equatable/equatable.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';

class QuickRecipePresetEntity extends Equatable {
  final RecipeEntity recipe;
  final QuickRecipeCategoryEntity category;
  final IntakeTypeEntity defaultIntakeType;
  final double kcalPerServing;
  final double carbsPerServing;
  final double fatPerServing;
  final double proteinPerServing;

  const QuickRecipePresetEntity({
    required this.recipe,
    required this.category,
    required this.defaultIntakeType,
    required this.kcalPerServing,
    required this.carbsPerServing,
    required this.fatPerServing,
    required this.proteinPerServing,
  });

  @override
  List<Object> get props => [
        recipe,
        category,
        defaultIntakeType,
        kcalPerServing,
        carbsPerServing,
        fatPerServing,
        proteinPerServing,
      ];
}
