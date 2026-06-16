import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/services/supabase_identity_service.dart';
import 'package:macrotracker/features/professional_plan/data/data_source/proposed_recipes_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockPostgrestTransformBuilder<T> extends Fake
    implements PostgrestTransformBuilder<T> {
  final dynamic result;
  final bool isSingle;
  final bool isMaybeSingle;

  MockPostgrestTransformBuilder(this.result,
      {this.isSingle = false, this.isMaybeSingle = false});

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');
    if (memberName == 'then') {
      final Function onValue = invocation.positionalArguments[0];
      final Function? onError = invocation.namedArguments[Symbol('onError')];
      return Future.value(result).then(
        (resolvedVal) {
          dynamic val = resolvedVal;
          if (isSingle || isMaybeSingle) {
            val = (resolvedVal is List)
                ? (resolvedVal.isNotEmpty ? resolvedVal.first : null)
                : resolvedVal;
          }
          return onValue(val);
        },
        onError: onError,
      );
    }
    if (memberName == 'maybeSingle') {
      return MockPostgrestTransformBuilder<Map<String, dynamic>?>(result,
          isMaybeSingle: true);
    }
    if (memberName == 'single') {
      return MockPostgrestTransformBuilder<Map<String, dynamic>>(result,
          isSingle: true);
    }
    return this;
  }
}

class MockPostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final MockPostgrestTransformBuilder<T> transformBuilder;
  final List<String> calls = [];

  MockPostgrestFilterBuilder(this.transformBuilder);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');
    final args = invocation.positionalArguments.join(', ');
    calls.add('$memberName($args)');

    if (memberName == 'select') {
      return transformBuilder;
    }
    if (memberName == 'maybeSingle') {
      return MockPostgrestTransformBuilder<Map<String, dynamic>?>(
          transformBuilder.result,
          isMaybeSingle: true);
    }
    if (memberName == 'single') {
      return MockPostgrestTransformBuilder<Map<String, dynamic>>(
          transformBuilder.result,
          isSingle: true);
    }
    if (memberName == 'then') {
      final Function onValue = invocation.positionalArguments[0];
      final Function? onError = invocation.namedArguments[Symbol('onError')];
      return Future.value(transformBuilder.result).then(
        (resolvedVal) {
          dynamic typedVal = resolvedVal;
          final typeStr = T.toString();
          if (typeStr.contains('List<Map')) {
            final listVal = (resolvedVal is List) ? resolvedVal : [resolvedVal];
            typedVal = listVal.cast<Map<String, dynamic>>();
          } else if (typeStr.contains('Map')) {
            final listVal = (resolvedVal is List) ? resolvedVal : [resolvedVal];
            typedVal = (listVal.isNotEmpty) ? listVal.first : null;
          }
          return onValue(typedVal);
        },
        onError: onError,
      );
    }
    return this;
  }
}

class MockSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final MockPostgrestFilterBuilder<List<Map<String, dynamic>>> filterBuilder;
  MockSupabaseQueryBuilder(this.filterBuilder);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');
    final args = invocation.positionalArguments.join(', ');
    filterBuilder.calls.add('$memberName($args)');
    return filterBuilder;
  }
}

class _FakeSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, dynamic> queries = {};

  @override
  SupabaseQueryBuilder from(String table) {
    final result = queries[table];
    final transform =
        MockPostgrestTransformBuilder<List<Map<String, dynamic>>>(result);
    final filter =
        MockPostgrestFilterBuilder<List<Map<String, dynamic>>>(transform);
    return MockSupabaseQueryBuilder(filter);
  }
}

class _FakeSupabaseIdentityService extends Fake
    implements SupabaseIdentityService {
  @override
  Future<String> ensureUserSession() async {
    return 'user-123';
  }
}

void main() {
  group('ProposedRecipesDataSource Tests', () {
    late _FakeSupabaseClient supabase;
    late _FakeSupabaseIdentityService identity;
    late ProposedRecipesDataSource dataSource;

    setUp(() {
      supabase = _FakeSupabaseClient();
      identity = _FakeSupabaseIdentityService();
      dataSource = ProposedRecipesDataSource(supabase, identity);
    });

    final dummyRecipeJson = {
      'id': 'rec-1',
      'title': 'Healthy Oatmeal',
      'description': 'Delicious oats',
      'meal_type': 'breakfast',
      'prep_time_min': 5,
      'cook_time_min': 10,
      'servings': 1,
      'kcal': 350.5,
      'protein': 15.2,
      'carbs': 55.0,
      'fat': 6.1,
      'ingredients': ['oats', 'milk', 'honey'],
      'instructions': 'Mix and cook',
      'image_url': 'http://example.com/image.png',
      'source_url': 'http://example.com'
    };

    final dummyProposedJson = [
      {
        'id': 'prop-1',
        'status': 'pending',
        'note': 'Try this for breakfast',
        'created_at': '2026-06-16T12:00:00Z',
        'professional_recipes': dummyRecipeJson
      }
    ];

    test('fetchProposedRecipes retrieves and parses proposed recipes correctly',
        () async {
      supabase.queries['client_proposed_recipes'] = dummyProposedJson;

      final results = await dataSource.fetchProposedRecipes(
        professionalClientId: 'pro-client-123',
        clientId: 'client-456',
      );

      expect(results, hasLength(1));
      final proposal = results.first;
      expect(proposal.id, 'prop-1');
      expect(proposal.status, 'pending');
      expect(proposal.note, 'Try this for breakfast');
      expect(proposal.createdAt, DateTime.utc(2026, 6, 16, 12, 0, 0));

      expect(proposal.recipe, isNotNull);
      final recipe = proposal.recipe!;
      expect(recipe.id, 'rec-1');
      expect(recipe.title, 'Healthy Oatmeal');
      expect(recipe.description, 'Delicious oats');
      expect(recipe.mealType, 'breakfast');
      expect(recipe.prepTimeMin, 5);
      expect(recipe.cookTimeMin, 10);
      expect(recipe.servings, 1);
      expect(recipe.kcal, 350.5);
      expect(recipe.protein, 15.2);
      expect(recipe.carbs, 55.0);
      expect(recipe.fat, 6.1);
      expect(recipe.ingredients, contains('oats'));
      expect(recipe.instructions, 'Mix and cook');
      expect(recipe.imageUrl, 'http://example.com/image.png');
      expect(recipe.sourceUrl, 'http://example.com');
    });

    test('updateProposalStatus completes without throwing', () async {
      // Stub the table to return an empty list or null, since update is void/ignored in response
      supabase.queries['client_proposed_recipes'] = null;

      await expectLater(
        dataSource.updateProposalStatus(
            proposalId: 'prop-1', status: 'accepted'),
        completes,
      );
    });

    test('fetchRecipeById returns recipe when it exists', () async {
      supabase.queries['professional_recipes'] = dummyRecipeJson;

      final recipe = await dataSource.fetchRecipeById(recipeId: 'rec-1');
      expect(recipe, isNotNull);
      expect(recipe!.id, 'rec-1');
      expect(recipe.title, 'Healthy Oatmeal');
    });

    test('fetchRecipeById returns null when recipe does not exist', () async {
      supabase.queries['professional_recipes'] = null;

      final recipe = await dataSource.fetchRecipeById(recipeId: 'rec-1');
      expect(recipe, isNull);
    });
  });
}
