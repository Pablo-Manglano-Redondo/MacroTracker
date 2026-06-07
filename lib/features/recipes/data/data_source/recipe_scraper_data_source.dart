import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:macrotracker/core/utils/locator.dart';

class ScrapedRecipeIngredient {
  final String name;
  final double amount;
  final String unit;
  final double kcal100;
  final double carbs100;
  final double fat100;
  final double protein100;

  const ScrapedRecipeIngredient({
    required this.name,
    required this.amount,
    required this.unit,
    required this.kcal100,
    required this.carbs100,
    required this.fat100,
    required this.protein100,
  });

  factory ScrapedRecipeIngredient.fromJson(Map<String, dynamic> json) {
    return ScrapedRecipeIngredient(
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'g',
      kcal100: (json['kcal100'] as num?)?.toDouble() ?? 0.0,
      carbs100: (json['carbs100'] as num?)?.toDouble() ?? 0.0,
      fat100: (json['fat100'] as num?)?.toDouble() ?? 0.0,
      protein100: (json['protein100'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ScrapedRecipeEntity {
  final String title;
  final double servings;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final List<ScrapedRecipeIngredient> ingredients;
  final List<String> instructions;
  final double kcal;
  final double carbs;
  final double fat;
  final double protein;

  const ScrapedRecipeEntity({
    required this.title,
    required this.servings,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.ingredients,
    required this.instructions,
    required this.kcal,
    required this.carbs,
    required this.fat,
    required this.protein,
  });

  factory ScrapedRecipeEntity.fromJson(Map<String, dynamic> json) {
    final macros = json['estimatedMacros'] as Map<String, dynamic>? ?? const {};
    final list = json['ingredients'] as List<dynamic>? ?? const [];
    final steps = json['instructions'] as List<dynamic>? ?? const [];

    return ScrapedRecipeEntity(
      title: json['title'] as String? ?? '',
      servings: (json['servings'] as num?)?.toDouble() ?? 1.0,
      prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 0,
      cookTimeMinutes: json['cookTimeMinutes'] as int? ?? 0,
      ingredients: list
          .map((i) => ScrapedRecipeIngredient.fromJson(i as Map<String, dynamic>))
          .toList(),
      instructions: steps.map((s) => s.toString()).toList(),
      kcal: (macros['kcal'] as num?)?.toDouble() ?? 0.0,
      carbs: (macros['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (macros['fat'] as num?)?.toDouble() ?? 0.0,
      protein: (macros['protein'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RecipeScraperResult {
  final ScrapedRecipeEntity recipe;
  final double estimatedCostUsd;

  const RecipeScraperResult({
    required this.recipe,
    required this.estimatedCostUsd,
  });
}

class RecipeScraperDataSource {
  static const _functionName = 'recipe-scraper';
  static const _timeout = Duration(seconds: 25);

  final SupabaseClient? _supabaseClient;

  RecipeScraperDataSource({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient;

  SupabaseClient get _client => _supabaseClient ?? locator<SupabaseClient>();

  Future<RecipeScraperResult> scrapeRecipe({
    required String url,
    required String locale,
  }) async {
    try {
      final response = await _client.functions.invoke(
        _functionName,
        body: {
          'url': url,
          'locale': locale,
        },
      ).timeout(_timeout);

      final data = response.data;
      final decoded = data is String ? jsonDecode(data) : data;

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid scraper response format');
      }

      if (decoded.containsKey('error')) {
        throw Exception(decoded['error']);
      }

      final recipeJson = decoded['recipe'] as Map<String, dynamic>?;
      if (recipeJson == null) {
        throw const FormatException('Missing recipe payload in response');
      }

      final estimatedCost = (decoded['estimatedCostUsd'] as num?)?.toDouble() ?? 0.0;

      return RecipeScraperResult(
        recipe: ScrapedRecipeEntity.fromJson(recipeJson),
        estimatedCostUsd: estimatedCost,
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      throw Exception('Scraper failed: $e');
    }
  }
}
