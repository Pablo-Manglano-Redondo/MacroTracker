import 'package:equatable/equatable.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';

class MacroSuggestionEntity extends Equatable {
  final RecipeEntity recipe;
  final double suggestedServings;
  final double predictedKcal;
  final double predictedCarbs;
  final double predictedFat;
  final double predictedProtein;
  final String rationale;
  final double score;

  const MacroSuggestionEntity({
    required this.recipe,
    required this.suggestedServings,
    required this.predictedKcal,
    required this.predictedCarbs,
    required this.predictedFat,
    required this.predictedProtein,
    required this.rationale,
    required this.score,
  });

  @override
  List<Object?> get props => [
        recipe,
        suggestedServings,
        predictedKcal,
        predictedCarbs,
        predictedFat,
        predictedProtein,
        rationale,
        score,
      ];
}
