import 'package:logging/logging.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProposedRecipesDataSource {
  final _log = Logger('ProposedRecipesDataSource');
  final SupabaseClient _supabaseClient;
  final SupabaseIdentityService _identityService;

  ProposedRecipesDataSource(this._supabaseClient, this._identityService);

  Future<List<ProposedRecipeData>> fetchProposedRecipes({
    required String professionalClientId,
    required String clientId,
  }) async {
    await _identityService.ensureUserSession();
    final response = await _supabaseClient
        .from('client_proposed_recipes')
        .select(
            'id, status, note, created_at, professional_recipes(id, title, description, meal_type, prep_time_min, cook_time_min, servings, kcal, protein, carbs, fat, ingredients, instructions, image_url, source_url)')
        .eq('professional_client_id', professionalClientId)
        .eq('client_id', clientId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) =>
            ProposedRecipeData.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<void> updateProposalStatus({
    required String proposalId,
    required String status,
  }) async {
    await _identityService.ensureUserSession();
    await _supabaseClient
        .from('client_proposed_recipes')
        .update({'status': status}).eq('id', proposalId);
  }

  Future<ProfessionalRecipeData?> fetchRecipeById({
    required String recipeId,
  }) async {
    await _identityService.ensureUserSession();
    final response = await _supabaseClient
        .from('professional_recipes')
        .select(
            'id, title, description, meal_type, prep_time_min, cook_time_min, servings, kcal, protein, carbs, fat, ingredients, instructions, image_url, source_url')
        .eq('id', recipeId)
        .maybeSingle();

    if (response == null) return null;

    return ProfessionalRecipeData.fromJson(Map<String, dynamic>.from(response));
  }
}

class ProposedRecipeData {
  final String id;
  final String status;
  final String? note;
  final DateTime createdAt;
  final ProfessionalRecipeData? recipe;

  ProposedRecipeData({
    required this.id,
    required this.status,
    this.note,
    required this.createdAt,
    this.recipe,
  });

  factory ProposedRecipeData.fromJson(Map<String, dynamic> json) {
    final recipeJson = json['professional_recipes'];
    return ProposedRecipeData(
      id: json['id'] as String,
      status: json['status'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      recipe: recipeJson != null
          ? ProfessionalRecipeData.fromJson(
              Map<String, dynamic>.from(recipeJson))
          : null,
    );
  }
}

class ProfessionalRecipeData {
  final String id;
  final String title;
  final String? description;
  final String? mealType;
  final int? prepTimeMin;
  final int? cookTimeMin;
  final int? servings;
  final double? kcal;
  final double? protein;
  final double? carbs;
  final double? fat;
  final List<dynamic>? ingredients;
  final String? instructions;
  final String? imageUrl;
  final String? sourceUrl;

  ProfessionalRecipeData({
    required this.id,
    required this.title,
    this.description,
    this.mealType,
    this.prepTimeMin,
    this.cookTimeMin,
    this.servings,
    this.kcal,
    this.protein,
    this.carbs,
    this.fat,
    this.ingredients,
    this.instructions,
    this.imageUrl,
    this.sourceUrl,
  });

  factory ProfessionalRecipeData.fromJson(Map<String, dynamic> json) {
    return ProfessionalRecipeData(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      mealType: json['meal_type'] as String?,
      prepTimeMin: json['prep_time_min'] as int?,
      cookTimeMin: json['cook_time_min'] as int?,
      servings: json['servings'] as int?,
      kcal: (json['kcal'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      ingredients: json['ingredients'] as List<dynamic>?,
      instructions: json['instructions'] as String?,
      imageUrl: json['image_url'] as String?,
      sourceUrl: json['source_url'] as String?,
    );
  }
}
