import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/meal_capture/data/data_sources/meal_interpretation_remote_data_source.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/confidence_band_entity.dart';
import 'package:macrotracker/features/meal_capture/domain/entity/interpretation_draft_entity.dart';

void main() {
  group('MealInterpretationRemoteDataSource', () {
    late MealInterpretationRemoteDataSource dataSource;

    setUp(() {
      dataSource = MealInterpretationRemoteDataSource();
    });

    test('maps a structured text response into an editable draft', () {
      final draft = dataSource.mapDraftResponse({
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
      expect(draft.items, hasLength(1));
      expect(draft.items.single.label, 'Eggs');
      expect(draft.items.single.unit, 'g');
      expect(draft.items.single.editable, isTrue);
      expect(draft.items.single.removed, isFalse);
    });

    test('accepts a JSON string response', () {
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
          dataSource.mapDraftResponse(response, fallbackTitle: 'Photo meal');

      expect(draft.sourceType, DraftSourceEntity.photo);
      expect(draft.title, 'Pasta bowl');
      expect(draft.totalKcal, 480);
      expect(draft.items.single.amount, 1);
      expect(draft.items.single.editable, isTrue);
    });

    test('uses safe defaults for missing optional fields and bad numbers', () {
      final draft = dataSource.mapDraftResponse({
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

    test('throws FormatException for non-object responses', () {
      expect(
        () => dataSource.mapDraftResponse(['not', 'an', 'object'],
            fallbackTitle: 'fallback'),
        throwsFormatException,
      );
    });
  });
}
