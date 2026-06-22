import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:logging/logging.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_item_entity.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealInterpretationRemoteDataSource {
  static const _textFunctionName = 'meal-interpretations-text';
  static const _photoFunctionName = 'meal-interpretations-photo';
  static const _textTimeout = Duration(seconds: 18);
  static const _photoTimeout = Duration(seconds: 55);

  final _log = Logger('MealInterpretationRemoteDataSource');
  final SupabaseClient? _supabaseClient;
  final ConversionAnalyticsService? _analyticsService;

  MealInterpretationRemoteDataSource({
    SupabaseClient? supabaseClient,
    ConversionAnalyticsService? analyticsService,
  })  : _supabaseClient = supabaseClient,
        _analyticsService = analyticsService;

  Future<MealInterpretationRemoteResult> interpretText({
    required String text,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
    String? analysisContext,
    List<Map<String, dynamic>> personalExamples = const [],
  }) async {
    return _runInterpretation(
      inputType: 'text',
      timeout: _textTimeout,
      fallbackTitle: text,
      locale: locale,
      invoke: () async {
        final response = await _client.functions.invoke(
          _textFunctionName,
          body: {
            'text': text,
            'locale': locale,
            'unitSystem': unitSystem,
            'mealTypeHint': mealTypeHint,
            if (analysisContext != null && analysisContext.trim().isNotEmpty)
              'analysisContext': analysisContext,
            if (personalExamples.isNotEmpty)
              'personalExamples': personalExamples,
          },
        );
        return response.data;
      },
    );
  }

  Future<MealInterpretationRemoteResult> interpretPhoto({
    required Uint8List imageBytes,
    required String fileName,
    required String mimeType,
    required String locale,
    required String unitSystem,
    String? mealTypeHint,
    String? analysisContext,
    List<Map<String, dynamic>> personalExamples = const [],
  }) async {
    final copy = await _loadCopy(locale);
    return _runInterpretation(
      inputType: 'photo',
      timeout: _photoTimeout,
      fallbackTitle: copy.mealCaptureFallbackPhotoMealTitle,
      locale: locale,
      invoke: () async {
        final response = await _client.functions.invoke(
          _photoFunctionName,
          body: {
            'imageBase64': base64Encode(imageBytes),
            'fileName': fileName,
            'mimeType': mimeType,
            'locale': locale,
            'unitSystem': unitSystem,
            'mealTypeHint': mealTypeHint,
            if (analysisContext != null && analysisContext.trim().isNotEmpty)
              'analysisContext': analysisContext,
            if (personalExamples.isNotEmpty)
              'personalExamples': personalExamples,
          },
        );
        return response.data;
      },
    );
  }

  SupabaseClient get _client => _supabaseClient ?? locator<SupabaseClient>();

  ConversionAnalyticsService get _analytics =>
      _analyticsService ?? locator<ConversionAnalyticsService>();

  Future<MealInterpretationRemoteResult> _runInterpretation({
    required String inputType,
    required Duration timeout,
    required String fallbackTitle,
    required String locale,
    required Future<dynamic> Function() invoke,
  }) async {
    await _analytics.logAiInterpretationStarted(inputType: inputType);

    var attempt = 0;
    while (true) {
      attempt += 1;
      try {
        final remoteStopwatch = Stopwatch()..start();
        final rawPayload = await invoke().timeout(timeout);
        remoteStopwatch.stop();
        final payload = _normalizePayload(rawPayload);
        final diagnostics = _extractDiagnostics(payload);
        final result = MealInterpretationRemoteResult(
          draft: await mapDraftResponse(
            payload,
            fallbackTitle: fallbackTitle,
            locale: locale,
          ),
          estimatedCostUsd: _extractEstimatedCost(payload),
          diagnostics: diagnostics,
        );
        await _analytics.logAiInterpretationCompleted(
          inputType: inputType,
          remoteMs: remoteStopwatch.elapsedMilliseconds,
          edgeMs: diagnostics?.edgeTotalMs,
          geminiMs: diagnostics?.geminiFetchMs,
          modelAttempts: diagnostics?.modelAttempts,
          fallbackUsed: diagnostics?.fallbackUsed,
        );
        return result;
      } catch (error, stackTrace) {
        final failure = classifyFailure(error);
        _log.warning(
          'Meal interpretation failed for $inputType on attempt $attempt',
          error,
          stackTrace,
        );

        if (attempt == 1 &&
            failure.isTransient &&
            shouldRetryInterpretation(inputType, failure)) {
          await _analytics.logAiInterpretationRetried(
            inputType: inputType,
            category: failure.category.analyticsValue,
          );
          continue;
        }

        await _analytics.logAiInterpretationFailed(
          inputType: inputType,
          category: failure.category.analyticsValue,
        );
        if (failure.reportToSentry) {
          await Sentry.captureException(error, stackTrace: stackTrace);
        }
        throw failure;
      }
    }
  }

  @visibleForTesting
  bool shouldRetryInterpretation(
    String inputType,
    MealInterpretationRemoteException failure,
  ) {
    if (inputType == 'photo' &&
        failure.category == MealInterpretationFailureCategory.timeout) {
      return false;
    }
    return true;
  }

  @visibleForTesting
  MealInterpretationRemoteException classifyFailure(Object error) {
    if (error is MealInterpretationRemoteException) {
      return error;
    }
    if (error is TimeoutException) {
      return const MealInterpretationRemoteException(
        category: MealInterpretationFailureCategory.timeout,
      );
    }

    final raw = error.toString();
    final message = raw.toLowerCase();
    if (_containsAny(message, const [
      'socketexception',
      'failed host lookup',
      'connection closed',
      'connection reset',
      'network',
      'timed out attempting to connect',
    ])) {
      return const MealInterpretationRemoteException(
        category: MealInterpretationFailureCategory.noNetwork,
      );
    }
    if (_containsAny(message, const [
      '401',
      '403',
      'jwt',
      'auth',
      'unauthorized',
      'forbidden',
      'session',
      'invalid refresh token',
    ])) {
      return const MealInterpretationRemoteException(
        category: MealInterpretationFailureCategory.authInvalid,
      );
    }
    if (_containsAny(message, const [
      'formatexception',
      'invalid draft response format',
      'invalid draft item format',
      'unexpected end of input',
      'json',
      'invalid response',
    ])) {
      return const MealInterpretationRemoteException(
        category: MealInterpretationFailureCategory.invalidResponse,
      );
    }
    if (_containsAny(message, const [
      '429',
      '500',
      '502',
      '503',
      '504',
      'resource_exhausted',
      'quota',
      'unavailable',
      'internal',
      'payload is too large',
    ])) {
      return const MealInterpretationRemoteException(
        category: MealInterpretationFailureCategory.unavailable,
      );
    }

    return MealInterpretationRemoteException(
      category: MealInterpretationFailureCategory.unavailable,
      reportToSentry: true,
      debugMessage: raw,
    );
  }

  bool _containsAny(String message, List<String> needles) =>
      needles.any(message.contains);

  @visibleForTesting
  Future<InterpretationDraftEntity> mapDraftResponse(dynamic data,
      {required String fallbackTitle, String? locale}) async {
    final copy = await _loadCopy(locale);
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
      summary: data['summary'] as String? ??
          copy.mealCaptureFallbackEstimatedSummary,
      totalKcal: _toDouble(totals['kcal']),
      totalCarbs: _toDouble(totals['carbs']),
      totalFat: _toDouble(totals['fat']),
      totalProtein: _toDouble(totals['protein']),
      totalFiber: _toDoubleNullable(totals['fiber']),
      totalSugar: _toDoubleNullable(totals['sugar']),
      confidenceBand:
          _mapConfidence(data['confidenceBand'] as String? ?? 'medium'),
      status: DraftStatusEntity.ready,
      createdAt: DateTime.now(),
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 1)),
      items: items.map((item) => _mapItem(item, copy: copy)).toList(),
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

  MealInterpretationRemoteDiagnostics? _extractDiagnostics(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final processing = data['processing'];
    if (processing is! Map) return null;
    final diagnostics = processing['diagnostics'];
    if (diagnostics is! Map) return null;

    return MealInterpretationRemoteDiagnostics(
      edgeTotalMs: _toIntNullable(diagnostics['edgeTotalMs']),
      geminiFetchMs: _toIntNullable(diagnostics['geminiFetchMs']),
      responseParseMs: _toIntNullable(diagnostics['responseParseMs']),
      normalizeMs: _toIntNullable(diagnostics['normalizeMs']),
      promptChars: _toIntNullable(diagnostics['promptChars']),
      inputImageBytes: _toIntNullable(diagnostics['inputImageBytes']),
      personalExamplesCount:
          _toIntNullable(diagnostics['personalExamplesCount']),
      correctionExamplesCount:
          _toIntNullable(diagnostics['correctionExamplesCount']),
      modelAttempts: _toIntNullable(diagnostics['modelAttempts']),
      fallbackUsed: diagnostics['fallbackUsed'] is bool
          ? diagnostics['fallbackUsed'] as bool
          : null,
    );
  }

  InterpretationDraftItemEntity _mapItem(dynamic item, {required S copy}) {
    if (item is! Map<String, dynamic>) {
      throw const FormatException('Invalid draft item format');
    }

    return InterpretationDraftItemEntity(
      id: (item['id'] as String?) ?? IdGenerator.getUniqueID(),
      label: (item['label'] as String?) ?? copy.mealCaptureFallbackDetectedItem,
      matchedMealSnapshot: null,
      amount: _toDouble(item['amount']),
      unit: (item['unit'] as String?) ?? 'serving',
      kcal: _toDouble(item['kcal']),
      carbs: _toDouble(item['carbs']),
      fat: _toDouble(item['fat']),
      protein: _toDouble(item['protein']),
      fiber: _toDoubleNullable(item['fiber']),
      sugar: _toDoubleNullable(item['sugar']),
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

  double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      final parsed = value.toDouble();
      return parsed < 0 ? 0 : parsed;
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed == null || parsed < 0) {
        return null;
      }
      return parsed;
    }
    return null;
  }

  int? _toIntNullable(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.round();
    }
    return null;
  }

  Future<S> _loadCopy(String? locale) async {
    final localeCode = (locale?.trim().isNotEmpty == true ? locale! : 'en')
        .split(RegExp(r'[-_]'))
        .first;
    return S.load(Locale(localeCode));
  }
}

class MealInterpretationRemoteResult {
  final InterpretationDraftEntity draft;
  final double estimatedCostUsd;
  final MealInterpretationRemoteDiagnostics? diagnostics;

  const MealInterpretationRemoteResult({
    required this.draft,
    required this.estimatedCostUsd,
    this.diagnostics,
  });
}

class MealInterpretationRemoteDiagnostics {
  final int? edgeTotalMs;
  final int? geminiFetchMs;
  final int? responseParseMs;
  final int? normalizeMs;
  final int? promptChars;
  final int? inputImageBytes;
  final int? personalExamplesCount;
  final int? correctionExamplesCount;
  final int? modelAttempts;
  final bool? fallbackUsed;

  const MealInterpretationRemoteDiagnostics({
    this.edgeTotalMs,
    this.geminiFetchMs,
    this.responseParseMs,
    this.normalizeMs,
    this.promptChars,
    this.inputImageBytes,
    this.personalExamplesCount,
    this.correctionExamplesCount,
    this.modelAttempts,
    this.fallbackUsed,
  });
}

enum MealInterpretationFailureCategory {
  timeout,
  noNetwork,
  authInvalid,
  invalidResponse,
  unavailable,
}

extension on MealInterpretationFailureCategory {
  String get analyticsValue {
    switch (this) {
      case MealInterpretationFailureCategory.timeout:
        return 'timeout';
      case MealInterpretationFailureCategory.noNetwork:
        return 'no_network';
      case MealInterpretationFailureCategory.authInvalid:
        return 'auth_invalid';
      case MealInterpretationFailureCategory.invalidResponse:
        return 'invalid_response';
      case MealInterpretationFailureCategory.unavailable:
        return 'unavailable';
    }
  }
}

class MealInterpretationRemoteException implements Exception {
  final MealInterpretationFailureCategory category;
  final bool reportToSentry;
  final String? debugMessage;

  const MealInterpretationRemoteException({
    required this.category,
    this.reportToSentry = false,
    this.debugMessage,
  });

  bool get isTransient =>
      category == MealInterpretationFailureCategory.timeout ||
      category == MealInterpretationFailureCategory.noNetwork ||
      category == MealInterpretationFailureCategory.unavailable;

  @override
  String toString() => debugMessage ?? category.analyticsValue;
}
