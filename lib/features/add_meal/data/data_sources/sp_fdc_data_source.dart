import 'dart:io';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/supported_language.dart';
import 'package:macrotracker/features/add_meal/data/dto/fdc_sp/sp_const.dart';
import 'package:macrotracker/features/add_meal/data/dto/fdc_sp/sp_fdc_food_dto.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpFdcDataSource {
  final log = Logger('SPBackendDataSource');

  static const _spanishPhraseFallbacks = {
    'aceite de coco': 'coconut oil',
    'pechuga de pollo': 'chicken breast',
    'pechuga de pavo': 'turkey breast',
    'aceite de oliva': 'olive oil',
    'carne picada': 'ground beef',
    'carne molida': 'ground beef',
    'arroz integral': 'brown rice',
    'arroz blanco': 'white rice',
    'yogur griego': 'greek yogurt',
    'patata cocida': 'boiled potato',
    'patata asada': 'baked potato',
  };

  static const _spanishWordFallbacks = {
    'aceite': 'oil',
    'arroz': 'rice',
    'atun': 'tuna',
    'avena': 'oats',
    'banana': 'banana',
    'batata': 'sweet potato',
    'carne': 'meat',
    'cebolla': 'onion',
    'cerdo': 'pork',
    'fresa': 'strawberry',
    'frijoles': 'beans',
    'garbanzos': 'chickpeas',
    'grasa': 'fat',
    'huevo': 'egg',
    'huevos': 'eggs',
    'judias': 'beans',
    'leche': 'milk',
    'lentejas': 'lentils',
    'maiz': 'corn',
    'manzana': 'apple',
    'mantequilla': 'butter',
    'naranja': 'orange',
    'nueces': 'nuts',
    'pan': 'bread',
    'papa': 'potato',
    'papas': 'potatoes',
    'pasta': 'pasta',
    'patata': 'potato',
    'patatas': 'potatoes',
    'pavo': 'turkey',
    'pera': 'pear',
    'platano': 'banana',
    'pollo': 'chicken',
    'proteina': 'protein',
    'queso': 'cheese',
    'salmon': 'salmon',
    'ternera': 'beef',
    'tomate': 'tomato',
    'uva': 'grape',
    'yogur': 'yogurt',
    'yogurt': 'yogurt',
    'zanahoria': 'carrot',
  };

  Future<List<SpFdcFoodDTO>> fetchSearchWordResults(String searchString) async {
    try {
      log.fine('Fetching Supabase FDC results');
      final supaBaseClient = locator<SupabaseClient>();
      final language = SupportedLanguage.fromCode(Platform.localeName);
      final preferredColumn = SPConst.getFdcFoodDescriptionColumnName(language);
      final candidateQueries = _buildCandidateQueries(searchString);
      final allItems = <SpFdcFoodDTO>[];

      for (final query in candidateQueries) {
        final response = await supaBaseClient
            .from(SPConst.fdcFoodTableName)
            .select(
                '''fdc_id, ${SPConst.fdcFoodDescriptionEn}, ${SPConst.fdcFoodDescriptionDe}, fdc_portions ( measure_unit_id, amount, gram_weight ), fdc_nutrients ( nutrient_id, amount )''')
            .textSearch(preferredColumn, query, type: TextSearchType.websearch)
            .limit(SPConst.maxNumberOfItems);

        allItems.addAll(
          response.map((fdcFood) => SpFdcFoodDTO.fromJson(fdcFood)),
        );
        if (allItems.length >= SPConst.maxNumberOfItems) {
          break;
        }
      }

      if (allItems.isEmpty && preferredColumn != SPConst.fdcFoodDescriptionEn) {
        for (final query in candidateQueries) {
          final response = await supaBaseClient
              .from(SPConst.fdcFoodTableName)
              .select(
                  '''fdc_id, ${SPConst.fdcFoodDescriptionEn}, ${SPConst.fdcFoodDescriptionDe}, fdc_portions ( measure_unit_id, amount, gram_weight ), fdc_nutrients ( nutrient_id, amount )''')
              .textSearch(SPConst.fdcFoodDescriptionEn, query,
                  type: TextSearchType.websearch)
              .limit(SPConst.maxNumberOfItems);

          allItems.addAll(
            response.map((fdcFood) => SpFdcFoodDTO.fromJson(fdcFood)),
          );
          if (allItems.length >= SPConst.maxNumberOfItems) {
            break;
          }
        }
      }

      if (allItems.isEmpty) {
        for (final query in candidateQueries) {
          final ilikePattern = '%${query.replaceAll('%', '')}%';
          final response = await supaBaseClient
              .from(SPConst.fdcFoodTableName)
              .select(
                  '''fdc_id, ${SPConst.fdcFoodDescriptionEn}, ${SPConst.fdcFoodDescriptionDe}, fdc_portions ( measure_unit_id, amount, gram_weight ), fdc_nutrients ( nutrient_id, amount )''')
              .or(
                  '${SPConst.fdcFoodDescriptionEn}.ilike.$ilikePattern,${SPConst.fdcFoodDescriptionDe}.ilike.$ilikePattern')
              .limit(SPConst.maxNumberOfItems);

          allItems.addAll(
            response.map((fdcFood) => SpFdcFoodDTO.fromJson(fdcFood)),
          );
          if (allItems.length >= SPConst.maxNumberOfItems) {
            break;
          }
        }
      }

      final fdcFoodItems = allItems
          .where((item) => item.fdcId != null)
          .groupListsBy((item) => item.fdcId!)
          .values
          .map((items) => items.first)
          .toList(growable: false);

      final rankedItems = _rankFoodItems(
        items: fdcFoodItems,
        rawSearch: searchString,
        language: language,
      );

      log.fine('Successful response from Supabase');
      return rankedItems.take(SPConst.maxNumberOfItems).toList(growable: false);
    } catch (exception, stacktrace) {
      log.severe('Exception while getting FDC word search $exception');
      Sentry.captureException(exception, stackTrace: stacktrace);
      return Future.error(exception);
    }
  }

  List<String> _buildCandidateQueries(String searchString) {
    final trimmed = searchString.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final lowered = trimmed.toLowerCase();
    final normalized = _normalizeSpanish(lowered);
    final translated = _translateSpanishQuery(normalized);

    return [trimmed, normalized, translated]
        .where((query) => query.trim().isNotEmpty)
        .map((query) => query.trim())
        .toSet()
        .toList(growable: false);
  }

  String _normalizeSpanish(String input) {
    return input
        .replaceAll(RegExp(r'[.,;:!?()\[\]{}]'), ' ')
        .replaceAll('\u00E1', 'a')
        .replaceAll('\u00E9', 'e')
        .replaceAll('\u00ED', 'i')
        .replaceAll('\u00F3', 'o')
        .replaceAll('\u00FA', 'u')
        .replaceAll('\u00FC', 'u')
        .replaceAll('\u00F1', 'n')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _translateSpanishQuery(String input) {
    var query = input;

    final sortedPhrases = _spanishPhraseFallbacks.keys.toList()
      ..sort((left, right) => right.length.compareTo(left.length));
    for (final phrase in sortedPhrases) {
      query = query.replaceAll(phrase, _spanishPhraseFallbacks[phrase]!);
    }

    final translatedWords = query
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => _spanishWordFallbacks[word] ?? word)
        .toList(growable: false);

    return translatedWords.join(' ').trim();
  }

  List<SpFdcFoodDTO> _rankFoodItems({
    required List<SpFdcFoodDTO> items,
    required String rawSearch,
    required SupportedLanguage language,
  }) {
    if (items.length < 2) {
      return items;
    }

    final normalizedSearch = _normalizeSpanish(rawSearch.toLowerCase());
    final translatedSearch = language == SupportedLanguage.es
        ? _translateSpanishQuery(normalizedSearch)
        : normalizedSearch;
    final searchTokens = translatedSearch
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList(growable: false);

    final ranked = items.toList(growable: false)
      ..sort((left, right) {
        final rightScore = _scoreFoodMatch(
          item: right,
          normalizedSearch: normalizedSearch,
          translatedSearch: translatedSearch,
          searchTokens: searchTokens,
          language: language,
        );
        final leftScore = _scoreFoodMatch(
          item: left,
          normalizedSearch: normalizedSearch,
          translatedSearch: translatedSearch,
          searchTokens: searchTokens,
          language: language,
        );

        final scoreComparison = rightScore.compareTo(leftScore);
        if (scoreComparison != 0) {
          return scoreComparison;
        }

        final rightDescription =
            _normalizedDescription(right, language: language);
        final leftDescription = _normalizedDescription(left, language: language);
        return leftDescription.length.compareTo(rightDescription.length);
      });

    return ranked;
  }

  int _scoreFoodMatch({
    required SpFdcFoodDTO item,
    required String normalizedSearch,
    required String translatedSearch,
    required List<String> searchTokens,
    required SupportedLanguage language,
  }) {
    final localizedDescription = _normalizedDescription(item, language: language);
    final englishDescription = _normalizeSpanish(
      (item.descriptionEn ?? '').toLowerCase(),
    );
    final descriptions = <String>{
      localizedDescription,
      englishDescription,
    }.where((description) => description.isNotEmpty).toList(growable: false);

    var score = 0;
    for (final description in descriptions) {
      final descriptionScore = _scoreDescription(
        description: description,
        normalizedSearch: normalizedSearch,
        translatedSearch: translatedSearch,
        searchTokens: searchTokens,
      );
      if (descriptionScore > score) {
        score = descriptionScore;
      }
    }

    return score;
  }

  int _scoreDescription({
    required String description,
    required String normalizedSearch,
    required String translatedSearch,
    required List<String> searchTokens,
  }) {
    if (description.isEmpty) {
      return -1000;
    }

    var score = 0;
    if (description == translatedSearch || description == normalizedSearch) {
      score += 400;
    }
    if (translatedSearch.isNotEmpty && description.startsWith(translatedSearch)) {
      score += 220;
    }
    if (normalizedSearch.isNotEmpty && description.startsWith(normalizedSearch)) {
      score += 180;
    }
    if (translatedSearch.isNotEmpty &&
        _containsWholePhrase(description, translatedSearch)) {
      score += 140;
    }
    if (normalizedSearch.isNotEmpty &&
        _containsWholePhrase(description, normalizedSearch)) {
      score += 100;
    }

    for (final token in searchTokens) {
      if (_containsWholeWord(description, token)) {
        score += 32;
      } else if (description.contains(token)) {
        score += 12;
      }
    }

    score -= description.length ~/ 12;
    return score;
  }

  String _normalizedDescription(
    SpFdcFoodDTO item, {
    required SupportedLanguage language,
  }) {
    return _normalizeSpanish(
      (item.getLocaleDescription(language) ?? item.descriptionEn ?? '')
          .toLowerCase(),
    );
  }

  bool _containsWholePhrase(String text, String phrase) {
    return (' $text ').contains(' $phrase ');
  }

  bool _containsWholeWord(String text, String word) {
    return (' $text ').contains(' $word ');
  }
}
