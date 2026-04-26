import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_measurement_entity.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/get_body_progress_usecase.dart';

void main() {
  group('Body progress summary', () {
    test('returns empty summary when no measurements exist', () {
      final summary = GetBodyProgressUsecase.summarize(
        const [],
        referenceDay: DateTime(2026, 4, 26),
      );

      expect(summary.hasData, isFalse);
      expect(summary.latestWeightKg, isNull);
      expect(summary.rollingWeightAverageKg, isNull);
    });

    test('builds rolling average and weekly delta from recent entries', () {
      final summary = GetBodyProgressUsecase.summarize(
        [
          BodyMeasurementEntity(
              day: DateTime(2026, 4, 26), weightKg: 80, waistCm: 82),
          BodyMeasurementEntity(day: DateTime(2026, 4, 25), weightKg: 80.4),
          BodyMeasurementEntity(day: DateTime(2026, 4, 24), weightKg: 80.2),
          BodyMeasurementEntity(day: DateTime(2026, 4, 23), weightKg: 80.6),
          BodyMeasurementEntity(day: DateTime(2026, 4, 22), weightKg: 80.5),
          BodyMeasurementEntity(day: DateTime(2026, 4, 21), weightKg: 80.3),
          BodyMeasurementEntity(day: DateTime(2026, 4, 20), weightKg: 80.7),
          BodyMeasurementEntity(day: DateTime(2026, 4, 19), weightKg: 81),
          BodyMeasurementEntity(day: DateTime(2026, 4, 18), weightKg: 81.2),
          BodyMeasurementEntity(day: DateTime(2026, 4, 17), weightKg: 81.1),
          BodyMeasurementEntity(day: DateTime(2026, 4, 16), weightKg: 81.3),
          BodyMeasurementEntity(day: DateTime(2026, 4, 15), weightKg: 81.4),
          BodyMeasurementEntity(day: DateTime(2026, 4, 14), weightKg: 81.2),
          BodyMeasurementEntity(day: DateTime(2026, 4, 13), weightKg: 81.5),
        ],
        referenceDay: DateTime(2026, 4, 26),
      );

      expect(summary.latestWeightKg, 80);
      expect(summary.latestWaistCm, 82);
      expect(summary.rollingWeightAverageKg, closeTo(80.385, 0.001));
      expect(summary.previousRollingWeightAverageKg, closeTo(81.242, 0.001));
      expect(summary.weeklyWeightDeltaKg, closeTo(-0.857, 0.001));
      expect(summary.latestWaistDeltaCm, isNull);
    });

    test('builds waist delta from the latest two waist check-ins', () {
      final summary = GetBodyProgressUsecase.summarize(
        [
          BodyMeasurementEntity(
              day: DateTime(2026, 4, 26), weightKg: 80, waistCm: 82),
          BodyMeasurementEntity(day: DateTime(2026, 4, 25), weightKg: 80.4),
          BodyMeasurementEntity(
              day: DateTime(2026, 4, 24), weightKg: 80.2, waistCm: 83),
        ],
        referenceDay: DateTime(2026, 4, 26),
      );

      expect(summary.latestWaistCm, 82);
      expect(summary.latestWaistDeltaCm, -1);
      expect(summary.hasWaistTrend, isTrue);
    });
  });
}
