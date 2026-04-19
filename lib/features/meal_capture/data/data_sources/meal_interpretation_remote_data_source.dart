import 'dart:convert';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:opennutritracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealInterpretationRemoteDataSource {
  static const _textFunctionName = 'meal-interpretations-text';
  static const _photoFunctionName = 'meal-interpretations-photo';

  final _log = Logger('MealInterpretationRemoteDataSource');

  Future<InterpretationDraftEntity> interpretText({
    required String text,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
  }) async {
    try {
      final supabaseClient = locator<SupabaseClient>();
      final response = await supabaseClient.functions.invoke(
        _textFunctionName,
        body: {
          'text': text,
          'locale': locale,
          'unitSystem': unitSystem,
          'mealTypeHint': mealTypeHint,
        },
      );

      return _mapDraftResponse(response.data, fallbackTitle: text);
    } catch (exception, stacktrace) {
      _log.severe('Exception while interpreting text meal $exception');
      Sentry.captureException(exception, stackTrace: stacktrace);
      return Future.error(exception);
    }
  }

  Future<InterpretationDraftEntity> interpretPhoto({
    required Uint8List imageBytes,
    required String fileName,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
  }) async {
    try {
      final supabaseClient = locator<SupabaseClient>();
      final response = await supabaseClient.functions.invoke(
        _photoFunctionName,
        body: {
          'imageBase64': base64Encode(imageBytes),
          'fileName': fileName,
          'locale': locale,
          'unitSystem': unitSystem,
          'mealTypeHint': mealTypeHint,
        },
      );

      return _mapDraftResponse(response.data, fallbackTitle: 'Photo meal');
    } catch (exception, stacktrace) {
      _log.severe('Exception while interpreting photo meal $exception');
      Sentry.captureException(exception, stackTrace: stacktrace);
      return Future.error(exception);
    }
  }

  InterpretationDraftEntity _mapDraftResponse(dynamic data,
      {required String fallbackTitle}) {
    if (data is String) {
      data = jsonDecode(data);
    }
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid draft response format');
    }

    final draftId = (data['draftId'] as String?) ?? IdGenerator.getUniqueID();
    final totals = (data['totals'] as Map?)?.cast<String, dynamic>() ?? const {};
    final items = (data['items'] as List<dynamic>? ?? const []);
    final expiresAt = DateTime.tryParse(data['expiresAt'] as String? ?? '');

    return InterpretationDraftEntity(
      id: draftId,
      sourceType: _mapSource(data['sourceType'] as String?),
      inputText: data['inputText'] as String?,
      localImagePath: null,
      title: (data['title'] as String?) ?? fallbackTitle,
      summary: data['summary'] as String?,
      totalKcal: _toDouble(totals['kcal']),
      totalCarbs: _toDouble(totals['carbs']),
      totalFat: _toDouble(totals['fat']),
      totalProtein: _toDouble(totals['protein']),
      confidenceBand:
          _mapConfidence(data['confidenceBand'] as String? ?? 'medium'),
      status: DraftStatusEntity.ready,
      createdAt: DateTime.now(),
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 1)),
      items: items.map(_mapItem).toList(),
    );
  }

  InterpretationDraftItemEntity _mapItem(dynamic item) {
    if (item is! Map<String, dynamic>) {
      throw const FormatException('Invalid draft item format');
    }

    return InterpretationDraftItemEntity(
      id: (item['id'] as String?) ?? IdGenerator.getUniqueID(),
      label: (item['label'] as String?) ?? 'Detected item',
      matchedMealSnapshot: null,
      amount: _toDouble(item['amount']),
      unit: (item['unit'] as String?) ?? 'serving',
      kcal: _toDouble(item['kcal']),
      carbs: _toDouble(item['carbs']),
      fat: _toDouble(item['fat']),
      protein: _toDouble(item['protein']),
      confidenceBand:
          _mapConfidence(item['confidenceBand'] as String? ?? 'medium'),
      editable: item['editable'] as bool? ?? true,
      removed: item['removed'] as bool? ?? false,
    );
  }

  DraftSourceEntity _mapSource(String? source) {
    switch (source) {
      case 'photo':
        return DraftSourceEntity.photo;
      case 'text':
      default:
        return DraftSourceEntity.text;
    }
  }

  ConfidenceBandEntity _mapConfidence(String confidence) {
    switch (confidence.toLowerCase()) {
      case 'low':
        return ConfidenceBandEntity.low;
      case 'high':
        return ConfidenceBandEntity.high;
      case 'medium':
      default:
        return ConfidenceBandEntity.medium;
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}
