import 'dart:math';

import 'package:collection/collection.dart';
import 'package:macrotracker/core/utils/meal_aggregate_factory.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_recipe_library_usecase.dart';
import 'package:macrotracker/features/suggestions/domain/entity/macro_suggestion_entity.dart';

class GenerateMacroSuggestionsUsecase {
  final GetRecipeLibraryUsecase _getRecipeLibraryUsecase;

  GenerateMacroSuggestionsUsecase(this._getRecipeLibraryUsecase);

  Future<List<MacroSuggestionEntity>> generate({
    required double remainingKcal,
    required double remainingCarbs,
    required double remainingFat,
    required double remainingProtein,
    int limit = 3,
  }) async {
    if (remainingKcal <= 0 && remainingProtein <= 0) {
      return const [];
    }

    final recipes = await _getRecipeLibraryUsecase.getAllRecipes();
    final suggestions = <MacroSuggestionEntity>[];

    for (final recipe in recipes) {
      final aggregateMeal = MealAggregateFactory.fromRecipe(recipe);
      final kcalPerServing = aggregateMeal.nutriments.energyPerUnit ?? 0;
      final carbsPerServing =
          aggregateMeal.nutriments.carbohydratesPerUnit ?? 0;
      final fatPerServing = aggregateMeal.nutriments.fatPerUnit ?? 0;
      final proteinPerServing =
          aggregateMeal.nutriments.proteinsPerUnit ?? 0;

      if (kcalPerServing <= 0) {
        continue;
      }

      final servings = _suggestServings(remainingKcal, kcalPerServing);
      final predictedKcal = kcalPerServing * servings;
      final predictedCarbs = carbsPerServing * servings;
      final predictedFat = fatPerServing * servings;
      final predictedProtein = proteinPerServing * servings;
      final score = _scoreSuggestion(
        predictedKcal: predictedKcal,
        predictedCarbs: predictedCarbs,
        predictedFat: predictedFat,
        predictedProtein: predictedProtein,
        remainingKcal: remainingKcal,
        remainingCarbs: remainingCarbs,
        remainingFat: remainingFat,
        remainingProtein: remainingProtein,
        favorite: recipe.favorite,
      );
      if (score < -0.35) {
        continue;
      }

      suggestions.add(MacroSuggestionEntity(
        recipe: recipe,
        suggestedServings: servings,
        predictedKcal: predictedKcal,
        predictedCarbs: predictedCarbs,
        predictedFat: predictedFat,
        predictedProtein: predictedProtein,
        rationale: _buildRationale(
          remainingProtein: remainingProtein,
          remainingKcal: remainingKcal,
          predictedProtein: predictedProtein,
          predictedKcal: predictedKcal,
        ),
        score: score,
      ));
    }

    return suggestions
        .sorted((a, b) => b.score.compareTo(a.score))
        .take(limit)
        .toList();
  }

  double _suggestServings(double remainingKcal, double kcalPerServing) {
    final raw = remainingKcal / kcalPerServing;
    final bounded = raw.clamp(0.5, 1.5);
    return (bounded * 4).round() / 4;
  }

  double _scoreSuggestion({
    required double predictedKcal,
    required double predictedCarbs,
    required double predictedFat,
    required double predictedProtein,
    required double remainingKcal,
    required double remainingCarbs,
    required double remainingFat,
    required double remainingProtein,
    required bool favorite,
  }) {
    final kcalGap = (remainingKcal - predictedKcal).abs() / max(remainingKcal, 1);
    final kcalOvershoot = max(0, predictedKcal - remainingKcal) / max(remainingKcal, 1);
    final proteinFit = remainingProtein <= 0
        ? 0
        : min(predictedProtein, remainingProtein) / remainingProtein;
    final carbsOvershoot =
        remainingCarbs <= 0 ? 0 : max(0, predictedCarbs - remainingCarbs) / remainingCarbs;
    final fatOvershoot =
        remainingFat <= 0 ? 0 : max(0, predictedFat - remainingFat) / remainingFat;

    return (proteinFit * 2.0) -
        (kcalGap * 0.8) -
        (kcalOvershoot * 1.2) -
        (carbsOvershoot * 0.4) -
        (fatOvershoot * 0.4) +
        (favorite ? 0.3 : 0);
  }

  String _buildRationale({
    required double remainingProtein,
    required double remainingKcal,
    required double predictedProtein,
    required double predictedKcal,
  }) {
    if (remainingProtein > 25 && predictedProtein > 20) {
      return 'Good fit to close your remaining protein.';
    }
    if (predictedKcal < 220) {
      return 'Light option that keeps the rest of the day flexible.';
    }
    if ((remainingKcal - predictedKcal).abs() < 120) {
      return 'Close match for your remaining calories.';
    }
    return 'A simple saved meal that fits the rest of your day reasonably well.';
  }
}
