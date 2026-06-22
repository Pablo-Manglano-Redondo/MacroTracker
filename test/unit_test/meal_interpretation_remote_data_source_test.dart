import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/features/meal_capture/data/data_source/meal_interpretation_remote_data_source.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabaseFunctions extends Fake implements FunctionsClient {
  final Future<FunctionResponse> Function(
    String functionName, {
    Map<String, String>? headers,
    dynamic body,
    HttpMethod? method,
  }) invokeHandler;

  FakeSupabaseFunctions(this.invokeHandler);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #invoke) {
      final String functionName = invocation.positionalArguments[0] as String;
      final headers = invocation.namedArguments[#headers] as Map<String, String>?;
      final body = invocation.namedArguments[#body];
      final method = invocation.namedArguments[#method] as HttpMethod?;
      return invokeHandler(functionName, headers: headers, body: body, method: method);
    }
    return super.noSuchMethod(invocation);
  }
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final FakeSupabaseFunctions functionsClient;
  FakeSupabaseClient(this.functionsClient);

  @override
  FunctionsClient get functions => functionsClient;
}

class FakeConversionAnalyticsService extends Fake implements ConversionAnalyticsService {
  int startedCalls = 0;
  int completedCalls = 0;
  int failedCalls = 0;
  int retriedCalls = 0;

  @override
  Future<void> logAiInterpretationStarted({required String inputType}) async {
    startedCalls++;
  }

  @override
  Future<void> logAiInterpretationCompleted({
    required String inputType,
    int? remoteMs,
    int? edgeMs,
    int? geminiMs,
    int? modelAttempts,
    bool? fallbackUsed,
  }) async {
    completedCalls++;
  }

  @override
  Future<void> logAiInterpretationFailed({required String inputType, required String category}) async {
    failedCalls++;
  }

  @override
  Future<void> logAiInterpretationRetried({required String inputType, required String category}) async {
    retriedCalls++;
  }
}

void main() {
  setUpAll(() async {
    await Sentry.init((options) => options.dsn = '');
  });

  group('MealInterpretationRemoteDataSource Mapping & Classify Tests', () {
    late MealInterpretationRemoteDataSource dataSource;

    setUp(() {
      dataSource = MealInterpretationRemoteDataSource();
    });

    test('maps a structured text response into an editable draft', () async {
      final draft = await dataSource.mapDraftResponse({
        'draftId': 'draft-1',
        'sourceType': 'text',
        'inputText': '2 eggs and toast',
        'title': 'Eggs and toast',
        'summary': 'A breakfast plate with eggs and toast.',
        'confidenceBand': 'high',
        'expiresAt': '2026-04-23T10:00:00.000Z',
        'totals': {
          'kcal': 320,
          'carbs': 24,
          'fat': 17,
          'protein': 18,
          'fiber': 2.0,
          'sugar': 3.5,
        },
        'items': [
          {
            'id': 'item-1',
            'label': 'Eggs',
            'amount': 100,
            'unit': 'g',
            'kcal': 155,
            'carbs': 1.1,
            'fat': 10.6,
            'protein': 12.6,
            'fiber': 0.1,
            'sugar': 0.0,
            'confidenceBand': 'high',
            'editable': true,
          },
        ],
      }, fallbackTitle: 'fallback');

      expect(draft.id, 'draft-1');
      expect(draft.sourceType, DraftSourceEntity.text);
      expect(draft.inputText, '2 eggs and toast');
      expect(draft.title, 'Eggs and toast');
      expect(draft.summary, 'A breakfast plate with eggs and toast.');
      expect(draft.confidenceBand, ConfidenceBandEntity.high);
      expect(draft.status, DraftStatusEntity.ready);
      expect(draft.totalKcal, 320);
      expect(draft.totalCarbs, 24);
      expect(draft.totalFat, 17);
      expect(draft.totalProtein, 18);
      expect(draft.totalFiber, 2.0);
      expect(draft.totalSugar, 3.5);
      expect(draft.items, hasLength(1));
      expect(draft.items.single.label, 'Eggs');
      expect(draft.items.single.unit, 'g');
      expect(draft.items.single.editable, isTrue);
      expect(draft.items.single.removed, isFalse);
    });

    test('accepts a JSON string response', () async {
      final response = jsonEncode({
        'sourceType': 'photo',
        'title': 'Pasta bowl',
        'summary': 'A visible bowl of pasta.',
        'confidenceBand': 'medium',
        'totals': {
          'kcal': '480',
          'carbs': '62',
          'fat': '14',
          'protein': '18',
        },
        'items': [
          {
            'label': 'Pasta',
            'amount': '1',
            'unit': 'serving',
            'kcal': '480',
            'carbs': '62',
            'fat': '14',
            'protein': '18',
            'confidenceBand': 'medium',
          },
        ],
      });

      final draft =
          await dataSource.mapDraftResponse(response, fallbackTitle: 'Photo meal');

      expect(draft.sourceType, DraftSourceEntity.photo);
      expect(draft.title, 'Pasta bowl');
      expect(draft.totalKcal, 480);
      expect(draft.items.single.amount, 1);
      expect(draft.items.single.editable, isTrue);
    });

    test('uses safe defaults for missing optional fields and bad numbers', () async {
      final draft = await dataSource.mapDraftResponse({
        'sourceType': 'unknown',
        'totals': {
          'kcal': 'not a number',
          'carbs': null,
          'fat': -1,
          'protein': 12,
        },
        'items': [
          {
            'amount': 'bad',
            'kcal': null,
            'carbs': '5.5',
            'fat': 'bad',
            'protein': 7,
            'confidenceBand': 'unexpected',
            'removed': true,
          },
        ],
      }, fallbackTitle: 'Fallback title');

      expect(draft.sourceType, DraftSourceEntity.text);
      expect(draft.title, 'Fallback title');
      expect(draft.confidenceBand, ConfidenceBandEntity.medium);
      expect(draft.totalKcal, 0);
      expect(draft.totalCarbs, 0);
      expect(draft.totalFat, 0);
      expect(draft.totalProtein, 12);
      expect(draft.items.single.label, 'Detected item');
      expect(draft.items.single.amount, 0);
      expect(draft.items.single.unit, 'serving');
      expect(draft.items.single.carbs, 5.5);
      expect(draft.items.single.removed, isTrue);
    });

    test('uses Spanish fallback copy when locale is Spanish', () async {
      final draft = await dataSource.mapDraftResponse({
        'sourceType': 'photo',
        'totals': {
          'kcal': 0,
          'carbs': 0,
          'fat': 0,
          'protein': 0,
        },
        'items': [
          {
            'amount': 1,
            'unit': 'serving',
            'kcal': 0,
            'carbs': 0,
            'fat': 0,
            'protein': 0,
          },
        ],
      }, fallbackTitle: 'Comida por foto', locale: 'es-ES');

      expect(draft.title, 'Comida por foto');
      expect(draft.summary, 'Estimación de comida generada por IA.');
      expect(draft.items.single.label, 'Ingrediente detectado');
    });

    test('throws FormatException for non-object responses', () async {
      await expectLater(
        dataSource.mapDraftResponse(
          ['not', 'an', 'object'],
          fallbackTitle: 'fallback',
        ),
        throwsFormatException,
      );
    });

    test('classifies timeout failures as transient timeout errors', () {
      final failure = dataSource.classifyFailure(
        TimeoutException('request timed out'),
      );

      expect(failure.category, MealInterpretationFailureCategory.timeout);
      expect(failure.isTransient, isTrue);
      expect(failure.reportToSentry, isFalse);
    });

    test('does not retry photo timeouts', () {
      const failure = MealInterpretationRemoteException(
        category: MealInterpretationFailureCategory.timeout,
      );

      expect(
        dataSource.shouldRetryInterpretation('photo', failure),
        isFalse,
      );
      expect(
        dataSource.shouldRetryInterpretation('text', failure),
        isTrue,
      );
    });

    test('classifies auth failures without treating them as transient', () {
      final failure = dataSource.classifyFailure(
        Exception('401 unauthorized jwt expired'),
      );

      expect(failure.category, MealInterpretationFailureCategory.authInvalid);
      expect(failure.isTransient, isFalse);
      expect(failure.reportToSentry, isFalse);
    });

    test('classifies malformed payloads as invalid responses', () {
      final failure = dataSource.classifyFailure(
        const FormatException('Invalid draft response format'),
      );

      expect(
        failure.category,
        MealInterpretationFailureCategory.invalidResponse,
      );
      expect(failure.reportToSentry, isFalse);
    });
  });

  group('MealInterpretationRemoteDataSource Edge Functions Tests', () {
    late FakeConversionAnalyticsService analyticsService;
    late Map<String, dynamic> successPayload;

    setUp(() {
      analyticsService = FakeConversionAnalyticsService();
      successPayload = {
        'draftId': 'draft-123',
        'sourceType': 'text',
        'inputText': 'Testing text',
        'title': 'Test Meal',
        'summary': 'Test Summary',
        'confidenceBand': 'high',
        'totals': {
          'kcal': 350.0,
          'carbs': 30.0,
          'fat': 10.0,
          'protein': 35.0,
          'fiber': 2.0,
          'sugar': 1.0,
        },
        'processing': {
          'estimatedCostUsd': 0.002,
          'diagnostics': {
            'edgeTotalMs': 150,
            'geminiFetchMs': 120,
            'responseParseMs': 3,
            'normalizeMs': 1,
            'promptChars': 500,
            'inputImageBytes': 0,
            'personalExamplesCount': 0,
            'correctionExamplesCount': 0,
            'modelAttempts': 1,
            'fallbackUsed': false
          }
        },
        'items': [
          {
            'id': 'item-123',
            'label': 'Test Item',
            'amount': 1.0,
            'unit': 'serving',
            'kcal': 350.0,
            'carbs': 30.0,
            'fat': 10.0,
            'protein': 35.0,
            'fiber': 2.0,
            'sugar': 1.0,
            'confidenceBand': 'high',
            'editable': true,
          }
        ]
      };
    });

    test('interpretText calls edge function and maps result successfully', () async {
      final functions = FakeSupabaseFunctions((functionName, {headers, body, method}) async {
        expect(functionName, equals('meal-interpretations-text'));
        expect(body?['text'], equals('2 eggs'));
        expect(body?['locale'], equals('en'));
        expect(body?['unitSystem'], equals('metric'));
        expect(body?['mealTypeHint'], equals('breakfast'));
        expect(body?['analysisContext'], equals('context'));
        expect(body?['personalExamples'], isNotEmpty);

        return FunctionResponse(data: successPayload, status: 200);
      });

      final client = FakeSupabaseClient(functions);
      final dataSource = MealInterpretationRemoteDataSource(
        supabaseClient: client,
        analyticsService: analyticsService,
      );

      final result = await dataSource.interpretText(
        text: '2 eggs',
        locale: 'en',
        unitSystem: 'metric',
        mealTypeHint: 'breakfast',
        analysisContext: 'context',
        personalExamples: [{'example': '1'}],
      );

      expect(result.estimatedCostUsd, equals(0.002));
      expect(result.diagnostics?.edgeTotalMs, equals(150));
      expect(result.draft.title, equals('Test Meal'));
      expect(analyticsService.startedCalls, equals(1));
      expect(analyticsService.completedCalls, equals(1));
    });

    test('interpretPhoto calls edge function and maps result successfully', () async {
      final functions = FakeSupabaseFunctions((functionName, {headers, body, method}) async {
        expect(functionName, equals('meal-interpretations-photo'));
        expect(body?['imageBase64'], equals(base64Encode([1, 2, 3])));
        expect(body?['fileName'], equals('test.jpg'));
        expect(body?['mimeType'], equals('image/jpeg'));
        expect(body?['locale'], equals('es'));
        expect(body?['unitSystem'], equals('imperial'));

        return FunctionResponse(data: successPayload, status: 200);
      });

      final client = FakeSupabaseClient(functions);
      final dataSource = MealInterpretationRemoteDataSource(
        supabaseClient: client,
        analyticsService: analyticsService,
      );

      final result = await dataSource.interpretPhoto(
        imageBytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'test.jpg',
        mimeType: 'image/jpeg',
        locale: 'es',
        unitSystem: 'imperial',
      );

      expect(result.draft.id, equals('draft-123'));
      expect(analyticsService.startedCalls, equals(1));
      expect(analyticsService.completedCalls, equals(1));
    });

    test('interpretText retries once on transient failure and then succeeds', () async {
      int attempts = 0;
      final functions = FakeSupabaseFunctions((functionName, {headers, body, method}) async {
        attempts++;
        if (attempts == 1) {
          throw TimeoutException('Transient timeout');
        }
        return FunctionResponse(data: successPayload, status: 200);
      });

      final client = FakeSupabaseClient(functions);
      final dataSource = MealInterpretationRemoteDataSource(
        supabaseClient: client,
        analyticsService: analyticsService,
      );

      final result = await dataSource.interpretText(
        text: 'test',
        locale: 'en',
        unitSystem: 'metric',
      );

      expect(attempts, equals(2));
      expect(result.draft.title, equals('Test Meal'));
      expect(analyticsService.startedCalls, equals(1));
      expect(analyticsService.retriedCalls, equals(1));
      expect(analyticsService.completedCalls, equals(1));
    });

    test('interpretText fails on non-transient failure immediately without retry', () async {
      int attempts = 0;
      final functions = FakeSupabaseFunctions((functionName, {headers, body, method}) async {
        attempts++;
        throw Exception('401 unauthorized jwt expired');
      });

      final client = FakeSupabaseClient(functions);
      final dataSource = MealInterpretationRemoteDataSource(
        supabaseClient: client,
        analyticsService: analyticsService,
      );

      await expectLater(
        dataSource.interpretText(text: 'test', locale: 'en', unitSystem: 'metric'),
        throwsA(isA<MealInterpretationRemoteException>().having(
          (e) => e.category,
          'category',
          MealInterpretationFailureCategory.authInvalid,
        )),
      );

      expect(attempts, equals(1));
      expect(analyticsService.startedCalls, equals(1));
      expect(analyticsService.retriedCalls, equals(0));
      expect(analyticsService.failedCalls, equals(1));
    });

    test('interpretText fails after retrying once if transient error occurs twice', () async {
      int attempts = 0;
      final functions = FakeSupabaseFunctions((functionName, {headers, body, method}) async {
        attempts++;
        throw TimeoutException('Transient timeout');
      });

      final client = FakeSupabaseClient(functions);
      final dataSource = MealInterpretationRemoteDataSource(
        supabaseClient: client,
        analyticsService: analyticsService,
      );

      await expectLater(
        dataSource.interpretText(text: 'test', locale: 'en', unitSystem: 'metric'),
        throwsA(isA<MealInterpretationRemoteException>().having(
          (e) => e.category,
          'category',
          MealInterpretationFailureCategory.timeout,
        )),
      );

      expect(attempts, equals(2));
      expect(analyticsService.startedCalls, equals(1));
      expect(analyticsService.retriedCalls, equals(1));
      expect(analyticsService.failedCalls, equals(1));
    });

    test('classifyFailure categorizes various exceptions properly', () {
      final dataSource = MealInterpretationRemoteDataSource();

      expect(
        dataSource.classifyFailure(Exception('socketexception')).category,
        equals(MealInterpretationFailureCategory.noNetwork),
      );
      expect(
        dataSource.classifyFailure(Exception('403 forbidden')).category,
        equals(MealInterpretationFailureCategory.authInvalid),
      );
      expect(
        dataSource.classifyFailure(Exception('json parse error')).category,
        equals(MealInterpretationFailureCategory.invalidResponse),
      );
      expect(
        dataSource.classifyFailure(Exception('500 internal server error')).category,
        equals(MealInterpretationFailureCategory.unavailable),
      );
      expect(
        dataSource.classifyFailure(Exception('unexpected random error')).category,
        equals(MealInterpretationFailureCategory.unavailable),
      );
      expect(
        dataSource.classifyFailure(Exception('unexpected random error')).reportToSentry,
        isTrue,
      );
    });
  });
}
