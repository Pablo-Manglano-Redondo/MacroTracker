import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:macrotracker/features/weekly_insights/domain/entity/weekly_insights_entity.dart';
import 'package:macrotracker/features/weekly_insights/presentation/widgets/weekly_progress_share_sheet.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
    await initializeDateFormatting('en');
  });

  group('WeeklyProgressShareSheet Helpers Tests', () {
    final insights = WeeklyInsightsEntity(
      weekStart: DateTime(2026, 6, 1),
      weekEnd: DateTime(2026, 6, 7),
      trackedDays: 5,
      averageCalories: 2150.4,
      averageCarbs: 230.1,
      averageFat: 65.2,
      averageProtein: 140.8,
      goalAdherenceRate: 0.857, // 86%
      proteinConsistencyRate: 0.714, // 71%
      overeatingTimeSlotLabel: 'Tarde',
      topMeals: const [
        FrequentMealInsightEntity(label: 'Pollo con arroz', count: 4),
      ],
      summaryLabel: 'Buen progreso general.',
      weeklyWeightDeltaKg: -0.45,
      recommendedKcalAdjustmentDelta: -100,
      kcalAdjustmentRecommendation: 'Reducir 100 kcal',
    );

    test('formatWeeklyDateRange formats correctly for es locale', () {
      final dateRangeText = WeeklyProgressShareSheet.formatWeeklyDateRange(
        insights.weekStart,
        insights.weekEnd,
        'es',
      );
      // Depending on locale resources, it should contain jun/1/7
      expect(dateRangeText.toLowerCase(), contains('1'));
      expect(dateRangeText.toLowerCase(), contains('7'));
      expect(dateRangeText.toLowerCase(), contains('jun'));
    });

    test('formatWeeklyDateRange formats correctly for en locale', () {
      final dateRangeText = WeeklyProgressShareSheet.formatWeeklyDateRange(
        insights.weekStart,
        insights.weekEnd,
        'en',
      );
      expect(dateRangeText, contains('1'));
      expect(dateRangeText, contains('7'));
      expect(dateRangeText.toLowerCase(), contains('jun'));
    });

    test('buildWeeklyProgressTextReport formats Spanish report correctly', () {
      final report = WeeklyProgressShareSheet.buildWeeklyProgressTextReport(
        insights: insights,
        dateRangeText: '1 jun - 7 jun',
        title: 'Mi resumen semanal (MacroTracker)',
        rangeLabel: 'Rango',
        averageCaloriesLabel: 'Calorías promedio',
        averageProteinLabel: 'Proteína promedio',
        averageCarbsLabel: 'Carbohidratos promedio',
        averageFatLabel: 'Grasa promedio',
        goalAdherenceLabel: 'Adherencia al objetivo',
        proteinConsistencyLabel: 'Consistencia proteica',
        daysTrackedLabel: 'Días registrados',
        weightDeltaLabel: 'Cambio de peso',
        daysUnit: 'día',
        footer: 'Enviado desde MacroTracker.',
      );

      expect(report, contains('Mi resumen semanal (MacroTracker)'));
      expect(report, contains('Rango: 1 jun - 7 jun'));
      expect(report, contains('Calorías promedio: 2150 kcal/día'));
      expect(report, contains('Proteína promedio: 140.8 g/día'));
      expect(report, contains('Carbohidratos promedio: 230.1 g/día'));
      expect(report, contains('Grasa promedio: 65.2 g/día'));
      expect(report, contains('Adherencia al objetivo: 86%'));
      expect(report, contains('Consistencia proteica: 71%'));
      expect(report, contains('Días registrados: 5 / 7 día'));
      expect(report, contains('Cambio de peso: -0.45 kg'));
      expect(report, contains('Enviado desde MacroTracker.'));
    });

    test('buildWeeklyProgressTextReport formats English report correctly', () {
      final report = WeeklyProgressShareSheet.buildWeeklyProgressTextReport(
        insights: insights,
        dateRangeText: 'Jun 1 - Jun 7',
        title: 'My weekly progress (MacroTracker)',
        rangeLabel: 'Range',
        averageCaloriesLabel: 'Average calories',
        averageProteinLabel: 'Average protein',
        averageCarbsLabel: 'Average carbs',
        averageFatLabel: 'Average fat',
        goalAdherenceLabel: 'Goal adherence',
        proteinConsistencyLabel: 'Protein consistency',
        daysTrackedLabel: 'Days tracked',
        weightDeltaLabel: 'Weight change',
        daysUnit: 'day',
        footer: 'Sent from MacroTracker.',
      );

      expect(report, contains('My weekly progress (MacroTracker)'));
      expect(report, contains('Range: Jun 1 - Jun 7'));
      expect(report, contains('Average calories: 2150 kcal/day'));
      expect(report, contains('Average protein: 140.8 g/day'));
      expect(report, contains('Average carbs: 230.1 g/day'));
      expect(report, contains('Average fat: 65.2 g/day'));
      expect(report, contains('Goal adherence: 86%'));
      expect(report, contains('Protein consistency: 71%'));
      expect(report, contains('Days tracked: 5 / 7 day'));
      expect(report, contains('Weight change: -0.45 kg'));
      expect(report, contains('Sent from MacroTracker.'));
    });

    test('buildWeeklyProgressTextReport formats positive weight delta correctly', () {
      final positiveWeightInsights = WeeklyInsightsEntity(
        weekStart: DateTime(2026, 6, 1),
        weekEnd: DateTime(2026, 6, 7),
        trackedDays: 7,
        averageCalories: 2500,
        averageCarbs: 300,
        averageFat: 80,
        averageProtein: 150,
        goalAdherenceRate: 1.0,
        proteinConsistencyRate: 1.0,
        overeatingTimeSlotLabel: 'Ninguno',
        topMeals: const [],
        summaryLabel: 'Excelente.',
        weeklyWeightDeltaKg: 0.25,
        recommendedKcalAdjustmentDelta: 0,
        kcalAdjustmentRecommendation: 'Mantener',
      );

      final reportEs = WeeklyProgressShareSheet.buildWeeklyProgressTextReport(
        insights: positiveWeightInsights,
        dateRangeText: '1 jun - 7 jun',
        title: 'Mi resumen semanal (MacroTracker)',
        rangeLabel: 'Rango',
        averageCaloriesLabel: 'Calorías promedio',
        averageProteinLabel: 'Proteína promedio',
        averageCarbsLabel: 'Carbohidratos promedio',
        averageFatLabel: 'Grasa promedio',
        goalAdherenceLabel: 'Adherencia al objetivo',
        proteinConsistencyLabel: 'Consistencia proteica',
        daysTrackedLabel: 'Días registrados',
        weightDeltaLabel: 'Cambio de peso',
        daysUnit: 'día',
        footer: 'Enviado desde MacroTracker.',
      );
      expect(reportEs, contains('Cambio de peso: +0.25 kg'));

      final reportEn = WeeklyProgressShareSheet.buildWeeklyProgressTextReport(
        insights: positiveWeightInsights,
        dateRangeText: 'Jun 1 - Jun 7',
        title: 'My weekly progress (MacroTracker)',
        rangeLabel: 'Range',
        averageCaloriesLabel: 'Average calories',
        averageProteinLabel: 'Average protein',
        averageCarbsLabel: 'Average carbs',
        averageFatLabel: 'Average fat',
        goalAdherenceLabel: 'Goal adherence',
        proteinConsistencyLabel: 'Protein consistency',
        daysTrackedLabel: 'Days tracked',
        weightDeltaLabel: 'Weight change',
        daysUnit: 'day',
        footer: 'Sent from MacroTracker.',
      );
      expect(reportEn, contains('Weight change: +0.25 kg'));
    });
  });
}
