import 'package:flutter_test/flutter_test.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_measurement_entity.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_progress_summary_entity.dart';
import 'package:macrotracker/features/body_progress/domain/usecase/get_body_progress_usecase.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

BodyMeasurementEntity _m(DateTime day, {double? weight, double? waist}) =>
    BodyMeasurementEntity(day: day, weightKg: weight, waistCm: waist);

void main() {
  // Reference day used across tests
  final ref = DateTime(2024, 6, 15);

  group('GetBodyProgressUsecase.summarize - empty measurements', () {
    test('returns summary with all nulls for empty list', () {
      final summary = GetBodyProgressUsecase.summarize([], referenceDay: ref);
      expect(summary.latestMeasurementDay, isNull);
      expect(summary.latestWeightKg, isNull);
      expect(summary.latestWaistCm, isNull);
      expect(summary.rollingWeightAverageKg, isNull);
      expect(summary.previousRollingWeightAverageKg, isNull);
      expect(summary.weeklyWeightDeltaKg, isNull);
      expect(summary.latestWaistDeltaCm, isNull);
    });
  });

  group('GetBodyProgressUsecase.summarize - single measurement', () {
    test('returns latest weight from single measurement', () {
      final measurements = [_m(ref, weight: 80.0)];
      final summary =
          GetBodyProgressUsecase.summarize(measurements, referenceDay: ref);

      expect(summary.latestWeightKg, 80.0);
      expect(summary.latestMeasurementDay, ref);
    });

    test('rolling average equals that single weight in the current window', () {
      final measurements = [_m(ref, weight: 80.0)];
      final summary =
          GetBodyProgressUsecase.summarize(measurements, referenceDay: ref);

      // The measurement is on ref => within current 7-day window
      expect(summary.rollingWeightAverageKg, closeTo(80.0, 0.001));
      // No previous window data => null
      expect(summary.previousRollingWeightAverageKg, isNull);
      expect(summary.weeklyWeightDeltaKg, isNull);
    });
  });

  group('GetBodyProgressUsecase.summarize - rolling average', () {
    test('computes correct weekly delta when both windows have data', () {
      // Current window: ref-6 to ref
      final currentWeek = [
        _m(ref, weight: 81.0),
        _m(ref.subtract(const Duration(days: 2)), weight: 80.0),
      ];
      // Previous window: ref-13 to ref-7
      final previousWeek = [
        _m(ref.subtract(const Duration(days: 8)), weight: 79.0),
        _m(ref.subtract(const Duration(days: 10)), weight: 78.0),
      ];
      final measurements = [...currentWeek, ...previousWeek];

      final summary =
          GetBodyProgressUsecase.summarize(measurements, referenceDay: ref);

      // currentAverage = (81 + 80) / 2 = 80.5
      expect(summary.rollingWeightAverageKg, closeTo(80.5, 0.001));
      // previousAverage = (79 + 78) / 2 = 78.5
      expect(summary.previousRollingWeightAverageKg, closeTo(78.5, 0.001));
      // delta = 80.5 - 78.5 = 2.0
      expect(summary.weeklyWeightDeltaKg, closeTo(2.0, 0.001));
    });

    test('measurements outside both windows do not affect rolling averages', () {
      // Old measurement outside the 14-day range
      final measurements = [
        _m(ref, weight: 80.0),
        _m(ref.subtract(const Duration(days: 30)), weight: 100.0),
      ];

      final summary =
          GetBodyProgressUsecase.summarize(measurements, referenceDay: ref);

      // Only the current window entry should count
      expect(summary.rollingWeightAverageKg, closeTo(80.0, 0.001));
      expect(summary.previousRollingWeightAverageKg, isNull);
    });

    test('measurement on boundary day (ref-6) is included in current window',
        () {
      final boundaryDay = ref.subtract(const Duration(days: 6));
      final measurements = [_m(boundaryDay, weight: 75.0)];

      final summary = GetBodyProgressUsecase.summarize(
        measurements,
        referenceDay: ref,
      );

      expect(summary.rollingWeightAverageKg, closeTo(75.0, 0.001));
    });

    test('measurement on boundary day (ref-7) is in the previous window', () {
      final prevBoundaryDay = ref.subtract(const Duration(days: 7));
      final measurements = [_m(prevBoundaryDay, weight: 72.0)];

      final summary = GetBodyProgressUsecase.summarize(
        measurements,
        referenceDay: ref,
      );

      // ref-7 is the previousWindowEnd, which should be included
      expect(summary.previousRollingWeightAverageKg, closeTo(72.0, 0.001));
    });
  });

  group('GetBodyProgressUsecase.summarize - waist tracking', () {
    test('captures latest and previous waist measurements', () {
      final measurements = [
        _m(ref, waist: 85.0),
        _m(ref.subtract(const Duration(days: 14)), waist: 88.0),
      ];

      final summary =
          GetBodyProgressUsecase.summarize(measurements, referenceDay: ref);

      expect(summary.latestWaistCm, 85.0);
      expect(summary.latestWaistDeltaCm, closeTo(-3.0, 0.001));
    });

    test('waist delta is null when only one waist measurement exists', () {
      final measurements = [_m(ref, waist: 85.0)];
      final summary =
          GetBodyProgressUsecase.summarize(measurements, referenceDay: ref);

      expect(summary.latestWaistCm, 85.0);
      expect(summary.latestWaistDeltaCm, isNull);
    });
  });

  group('GetBodyProgressUsecase.summarize - weight-only vs waist-only', () {
    test('latestWeightKg ignores measurements without weight', () {
      final measurements = [
        _m(ref, waist: 85.0), // no weight
        _m(ref.subtract(const Duration(days: 1)), weight: 79.0),
      ];

      final summary =
          GetBodyProgressUsecase.summarize(measurements, referenceDay: ref);

      expect(summary.latestWeightKg, 79.0);
    });
  });

  group('BodyProgressSummaryEntity', () {
    test('hasData is true when latestWeightKg is set', () {
      const s = BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: 80.0,
        latestWaistCm: null,
        rollingWeightAverageKg: null,
        previousRollingWeightAverageKg: null,
        weeklyWeightDeltaKg: null,
        latestWaistDeltaCm: null,
      );
      expect(s.hasData, isTrue);
    });

    test('hasData is false when all values are null', () {
      const s = BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: null,
        latestWaistCm: null,
        rollingWeightAverageKg: null,
        previousRollingWeightAverageKg: null,
        weeklyWeightDeltaKg: null,
        latestWaistDeltaCm: null,
      );
      expect(s.hasData, isFalse);
    });

    test('isWeightStable returns true when delta <= threshold', () {
      const s = BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: 80.0,
        latestWaistCm: null,
        rollingWeightAverageKg: 80.0,
        previousRollingWeightAverageKg: 79.9,
        weeklyWeightDeltaKg: 0.1,
        latestWaistDeltaCm: null,
      );
      expect(s.isWeightStable, isTrue);
    });

    test('isWeightStable returns false when delta > threshold', () {
      const s = BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: 80.0,
        latestWaistCm: null,
        rollingWeightAverageKg: 80.0,
        previousRollingWeightAverageKg: 79.0,
        weeklyWeightDeltaKg: 1.0,
        latestWaistDeltaCm: null,
      );
      expect(s.isWeightStable, isFalse);
    });

    test('isWeightStable returns false when weeklyWeightDeltaKg is null', () {
      const s = BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: null,
        latestWaistCm: null,
        rollingWeightAverageKg: null,
        previousRollingWeightAverageKg: null,
        weeklyWeightDeltaKg: null,
        latestWaistDeltaCm: null,
      );
      expect(s.isWeightStable, isFalse);
    });

    test('isWaistStable returns true when delta is within threshold', () {
      const s = BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: null,
        latestWaistCm: 85.0,
        rollingWeightAverageKg: null,
        previousRollingWeightAverageKg: null,
        weeklyWeightDeltaKg: null,
        latestWaistDeltaCm: 0.3,
      );
      expect(s.isWaistStable, isTrue);
    });

    test('isWaistStable returns false when delta exceeds threshold', () {
      const s = BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: null,
        latestWaistCm: 85.0,
        rollingWeightAverageKg: null,
        previousRollingWeightAverageKg: null,
        weeklyWeightDeltaKg: null,
        latestWaistDeltaCm: 2.0,
      );
      expect(s.isWaistStable, isFalse);
    });

    test('hasWeightTrend and hasWaistTrend return correct booleans', () {
      const s1 = BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: null,
        latestWaistCm: null,
        rollingWeightAverageKg: null,
        previousRollingWeightAverageKg: null,
        weeklyWeightDeltaKg: 0.5,
        latestWaistDeltaCm: 1.0,
      );
      expect(s1.hasWeightTrend, isTrue);
      expect(s1.hasWaistTrend, isTrue);

      const s2 = BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: null,
        latestWaistCm: null,
        rollingWeightAverageKg: null,
        previousRollingWeightAverageKg: null,
        weeklyWeightDeltaKg: null,
        latestWaistDeltaCm: null,
      );
      expect(s2.hasWeightTrend, isFalse);
      expect(s2.hasWaistTrend, isFalse);
    });
  });
}
