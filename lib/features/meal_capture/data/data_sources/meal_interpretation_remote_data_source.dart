import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:logging/logging.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealInterpretationRemoteDataSource {
  static const _textFunctionName = 'meal-interpretations-text';
  static const _photoFunctionName = 'meal-interpretations-photo';

  final _log = Logger('MealInterpretationRemoteDataSource');

  Future<MealInterpretationRemoteResult> interpretText({
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

      final payload = _normalizePayload(response.data);
      return MealInterpretationRemoteResult(
        draft: mapDraftResponse(payload, fallbackTitle: text),
        estimatedCostUsd: _extractEstimatedCost(payload),
      );
    } catch (exception, stacktrace) {
      _log.severe('Exception while interpreting text meal $exception');
      Sentry.captureException(exception, stackTrace: stacktrace);
      return Future.error(exception);
    }
  }

  Future<MealInterpretationRemoteResult> interpretPhoto({
    required Uint8List imageBytes,
    required String fileName,
    required String mimeType,
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
          'mimeType': mimeType,
          'locale': locale,
          'unitSystem': unitSystem,
          'mealTypeHint': mealTypeHint,
        },
      );

      final payload = _normalizePayload(response.data);
      return MealInterpretationRemoteResult(
        draft: mapDraftResponse(payload, fallbackTitle: 'Photo meal'),
        estimatedCostUsd: _extractEstimatedCost(payload),
      );
    } catch (exception, stacktrace) {
      _log.severe('Exception while interpreting photo meal $exception');
      Sentry.captureException(exception, stackTrace: stacktrace);
      return Future.error(exception);
    }
  }

  @visibleForTesting
  InterpretationDraftEntity mapDraftResponse(dynamic data,
      {required String fallbackTitle}) {
    final normalized = _normalizePayload(data);
    if (normalized is! Map<String, dynamic>) {
      throw const FormatException('Invalid draft response format');
    }
    data = normalized;

    final draftId = (data['draftId'] as String?) ?? IdGenerator.getUniqueID();
    final totals =
        (data['totals'] as Map?)?.cast<String, dynamic>() ?? const {};
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

  dynamic _normalizePayload(dynamic data) {
    if (data is String) {
      return jsonDecode(data);
    }
    return data;
  }

  double _extractEstimatedCost(dynamic data) {
    if (data is! Map<String, dynamic>) return 0;
    final processing = data['processing'];
    if (processing is! Map) return 0;
    return _toDouble(processing['estimatedCostUsd']);
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
      final parsed = value.toDouble();
      return parsed < 0 ? 0 : parsed;
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed == null || parsed < 0) {
        return 0;
      }
      return parsed;
    }
    return 0;
  }
}

class MealInterpretationRemoteResult {
  final InterpretationDraftEntity draft;
  final double estimatedCostUsd;

  const MealInterpretationRemoteResult({
    required this.draft,
    required this.estimatedCostUsd,
  });
}
