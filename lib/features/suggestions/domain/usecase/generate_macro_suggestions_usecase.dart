import 'dart:math';

import 'package:collection/collection.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/utils/meal_aggregate_factory.dart';
import 'package:macrotracker/features/recipes/domain/entity/quick_recipe_category_entity.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_frequent_intake_presets_usecase.dart';
import 'package:macrotracker/features/recipes/domain/usecase/get_recipe_library_usecase.dart';
import 'package:macrotracker/features/suggestions/domain/entity/macro_suggestion_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_entity.dart';
import 'package:macrotracker/features/recipes/domain/entity/recipe_ingredient_entity.dart';

class GenerateMacroSuggestionsUsecase {
  final GetRecipeLibraryUsecase _getRecipeLibraryUsecase;
  final GetFrequentIntakePresetsUsecase _getFrequentIntakePresetsUsecase;

  GenerateMacroSuggestionsUsecase(
    this._getRecipeLibraryUsecase,
    this._getFrequentIntakePresetsUsecase,
  );

  Future<List<MacroSuggestionEntity>> generate({
    required DailyFocusEntity dailyFocus,
    required UserWeightGoalEntity nutritionPhase,
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
    final frequentPresets = await _getFrequentIntakePresetsUsecase.getTopPresets();
    
    // Convert frequent presets to "virtual" recipes so we can use the same scoring logic
    final frequentAsRecipes = frequentPresets.map((preset) => RecipeEntity(
      id: 'frequent|${preset.key}',
      name: preset.title,
      notes: null,
      defaultServings: 1.0,
      yieldQuantity: 1.0,
      yieldUnit: 'serving',
      favorite: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ingredients: [
        RecipeIngredientEntity(
          id: 'preset_root',
          mealSnapshot: preset.meal,
          amount: preset.amount,
          unit: preset.unit,
          position: 0,
        ),
      ],
    ));

    final allCandidates = [...recipes, ...frequentAsRecipes];
    final suggestions = <MacroSuggestionEntity>[];

    for (final recipe in allCandidates) {
      final category = QuickRecipeCategoryEntityX.inferFromRecipe(recipe);
      final recommendedIntakeType =
          QuickRecipeCategoryEntityX.inferIntakeType(recipe, category);
      final aggregateMeal = MealAggregateFactory.fromRecipe(recipe);
      final kcalPerServing = aggregateMeal.nutriments.energyPerUnit ?? 0;
      final carbsPerServing =
          aggregateMeal.nutriments.carbohydratesPerUnit ?? 0;
      final fatPerServing = aggregateMeal.nutriments.fatPerUnit ?? 0;
      final proteinPerServing = aggregateMeal.nutriments.proteinsPerUnit ?? 0;

      if (kcalPerServing <= 0) {
        continue;
      }

      final servings = _suggestServings(
        remainingKcal: remainingKcal,
        kcalPerServing: kcalPerServing,
        category: category,
        nutritionPhase: nutritionPhase,
      );
      final predictedKcal = kcalPerServing * servings;
      final predictedCarbs = carbsPerServing * servings;
      final predictedFat = fatPerServing * servings;
      final predictedProtein = proteinPerServing * servings;
      final score = _scoreSuggestion(
        predictedKcal: predictedKcal,
        predictedCarbs: predictedCarbs,
        predictedFat: predictedFat,
        predictedProtein: predictedProtein,
        dailyFocus: dailyFocus,
        nutritionPhase: nutritionPhase,
        category: category,
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
        category: category,
        recommendedIntakeType: recommendedIntakeType,
        suggestedServings: servings,
        predictedKcal: predictedKcal,
        predictedCarbs: predictedCarbs,
        predictedFat: predictedFat,
        predictedProtein: predictedProtein,
        rationale: _buildRationale(
          dailyFocus: dailyFocus,
          nutritionPhase: nutritionPhase,
          category: category,
          remainingProtein: remainingProtein,
          remainingKcal: remainingKcal,
          predictedCarbs: predictedCarbs,
          predictedFat: predictedFat,
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

  double _suggestServings({
    required double remainingKcal,
    required double kcalPerServing,
    required QuickRecipeCategoryEntity category,
    required UserWeightGoalEntity nutritionPhase,
  }) {
    final raw = remainingKcal / max(kcalPerServing, 1);
    final (minServing, maxServing) = _servingBounds(category, nutritionPhase);
    final bounded = raw.clamp(minServing, maxServing);
    return (bounded * 4).round() / 4;
  }

  double _scoreSuggestion({
    required double predictedKcal,
    required double predictedCarbs,
    required double predictedFat,
    required double predictedProtein,
    required DailyFocusEntity dailyFocus,
    required UserWeightGoalEntity nutritionPhase,
    required QuickRecipeCategoryEntity category,
    required double remainingKcal,
    required double remainingCarbs,
    required double remainingFat,
    required double remainingProtein,
    required bool favorite,
  }) {
    final kcalGap =
        (remainingKcal - predictedKcal).abs() / max(remainingKcal, 1);
    final kcalOvershoot =
        max(0, predictedKcal - remainingKcal) / max(remainingKcal, 1);
    final proteinFit = remainingProtein <= 0
        ? 0
        : min(predictedProtein, remainingProtein) / remainingProtein;
    final carbsOvershoot = remainingCarbs <= 0
        ? 0
        : max(0, predictedCarbs - remainingCarbs) / remainingCarbs;
    final fatOvershoot = remainingFat <= 0
        ? 0
        : max(0, predictedFat - remainingFat) / remainingFat;
    final focusBonus = _focusBonus(
      dailyFocus: dailyFocus,
      nutritionPhase: nutritionPhase,
      category: category,
      remainingProtein: remainingProtein,
      remainingCarbs: remainingCarbs,
      predictedProtein: predictedProtein,
      predictedCarbs: predictedCarbs,
      predictedFat: predictedFat,
      predictedKcal: predictedKcal,
    );

    return (proteinFit * 2.0) -
        (kcalGap * 0.8) -
        (kcalOvershoot * 1.2) -
        (carbsOvershoot * 0.4) -
        (fatOvershoot * 0.4) +
        focusBonus +
        (favorite ? 0.3 : 0);
  }

  String _buildRationale({
    required DailyFocusEntity dailyFocus,
    required UserWeightGoalEntity nutritionPhase,
    required QuickRecipeCategoryEntity category,
    required double remainingProtein,
    required double remainingKcal,
    required double predictedCarbs,
    required double predictedFat,
    required double predictedProtein,
    required double predictedKcal,
  }) {
    if (nutritionPhase == UserWeightGoalEntity.loseWeight &&
        predictedProtein >= 20 &&
        predictedKcal <= max(remainingKcal, 220) &&
        predictedFat <= _remainingFatCap(predictedKcal)) {
      return 'Lean close for cut days: protein-first with calories kept tight.';
    }
    if ((dailyFocus == DailyFocusEntity.lowerBody ||
            dailyFocus == DailyFocusEntity.upperBody) &&
        category == QuickRecipeCategoryEntity.postWorkout &&
        predictedProtein >= 20 &&
        predictedCarbs >= 25) {
      return 'Post-workout recovery hit with enough carbs and protein to reload.';
    }
    if ((dailyFocus == DailyFocusEntity.lowerBody ||
            dailyFocus == DailyFocusEntity.upperBody) &&
        category == QuickRecipeCategoryEntity.preWorkout &&
        predictedCarbs >= 20 &&
        predictedFat <= 18) {
      return 'Good pre-workout fuel: useful carbs without much digestive drag.';
    }
    if (remainingProtein > 25 && predictedProtein > 20) {
      return 'Protein-first close to finish the day without guessing.';
    }
    if (category == QuickRecipeCategoryEntity.shake && predictedKcal < 260) {
      return 'Fast protein touch when you want something light and easy to log.';
    }
    if ((remainingKcal - predictedKcal).abs() < 120) {
      return 'Clean fit for the calories you still have left.';
    }
    return 'Solid gym-friendly option that keeps the day moving in the right direction.';
  }

  (double, double) _servingBounds(
    QuickRecipeCategoryEntity category,
    UserWeightGoalEntity nutritionPhase,
  ) {
    switch (category) {
      case QuickRecipeCategoryEntity.shake:
        return nutritionPhase == UserWeightGoalEntity.loseWeight
            ? (0.5, 1.0)
            : (0.5, 1.25);
      case QuickRecipeCategoryEntity.preWorkout:
        return (0.5, 1.25);
      case QuickRecipeCategoryEntity.postWorkout:
        return nutritionPhase == UserWeightGoalEntity.gainWeight
            ? (0.75, 1.5)
            : (0.5, 1.25);
      case QuickRecipeCategoryEntity.leanMeal:
        return nutritionPhase == UserWeightGoalEntity.gainWeight
            ? (0.75, 1.5)
            : (0.5, 1.25);
    }
  }

  double _focusBonus({
    required DailyFocusEntity dailyFocus,
    required UserWeightGoalEntity nutritionPhase,
    required QuickRecipeCategoryEntity category,
    required double remainingProtein,
    required double remainingCarbs,
    required double predictedProtein,
    required double predictedCarbs,
    required double predictedFat,
    required double predictedKcal,
  }) {
    double bonus = 0;

    if (remainingProtein > 25 && predictedProtein > 20) {
      bonus += 0.35;
    }

    switch (dailyFocus) {
      case DailyFocusEntity.lowerBody:
        if (category == QuickRecipeCategoryEntity.postWorkout) {
          bonus += 0.5;
        }
        if (category == QuickRecipeCategoryEntity.preWorkout &&
            remainingCarbs > 25) {
          bonus += 0.35;
        }
        if (category == QuickRecipeCategoryEntity.leanMeal &&
            predictedFat > 20) {
          bonus -= 0.15;
        }
        break;
      case DailyFocusEntity.upperBody:
        if (category == QuickRecipeCategoryEntity.postWorkout) {
          bonus += 0.45;
        }
        if (category == QuickRecipeCategoryEntity.preWorkout &&
            remainingCarbs > 25) {
          bonus += 0.3;
        }
        if (category == QuickRecipeCategoryEntity.leanMeal &&
            predictedFat > 20) {
          bonus -= 0.15;
        }
        break;
      case DailyFocusEntity.rest:
        if (category == QuickRecipeCategoryEntity.leanMeal) {
          bonus += 0.35;
        }
        if (category == QuickRecipeCategoryEntity.postWorkout) {
          bonus -= 0.1;
        }
        break;
      case DailyFocusEntity.cardio:
        if (category == QuickRecipeCategoryEntity.shake ||
            category == QuickRecipeCategoryEntity.preWorkout) {
          bonus += 0.25;
        }
        break;
    }

    switch (nutritionPhase) {
      case UserWeightGoalEntity.loseWeight:
        if (category == QuickRecipeCategoryEntity.leanMeal ||
            category == QuickRecipeCategoryEntity.shake) {
          bonus += 0.25;
        }
        if (predictedFat > 18) {
          bonus -= 0.2;
        }
        if (predictedKcal > 420) {
          bonus -= 0.2;
        }
        break;
      case UserWeightGoalEntity.maintainWeight:
        break;
      case UserWeightGoalEntity.gainWeight:
        if (category == QuickRecipeCategoryEntity.postWorkout ||
            category == QuickRecipeCategoryEntity.preWorkout) {
          bonus += 0.2;
        }
        if (predictedCarbs >= 30) {
          bonus += 0.15;
        }
        break;
    }

    return bonus;
  }

  double _remainingFatCap(double predictedKcal) {
    if (predictedKcal <= 220) {
      return 14;
    }
    if (predictedKcal <= 320) {
      return 18;
    }
    return 22;
  }
}
