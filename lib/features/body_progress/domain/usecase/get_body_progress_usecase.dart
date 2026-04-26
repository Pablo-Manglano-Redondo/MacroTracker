import 'package:flutter/foundation.dart';
import 'package:macrotracker/features/body_progress/data/repository/body_measurement_repository.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_measurement_entity.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_progress_summary_entity.dart';

class GetBodyProgressUsecase {
  final BodyMeasurementRepository _bodyMeasurementRepository;

  GetBodyProgressUsecase(this._bodyMeasurementRepository);

  Future<BodyProgressSummaryEntity> getSummary({DateTime? referenceDay}) async {
    final measurements = await _bodyMeasurementRepository.getAllMeasurements();
    return summarize(
      measurements,
      referenceDay: referenceDay ?? DateTime.now(),
    );
  }

  Future<List<BodyMeasurementEntity>> getRecentMeasurements(
      {int limit = 30}) async {
    final measurements = await _bodyMeasurementRepository.getAllMeasurements();
    return measurements.take(limit).toList(growable: false);
  }

  Future<BodyMeasurementEntity?> getMeasurementForDay(DateTime day) {
    return _bodyMeasurementRepository.getMeasurement(day);
  }

  @visibleForTesting
  static BodyProgressSummaryEntity summarize(
    List<BodyMeasurementEntity> measurements, {
    required DateTime referenceDay,
  }) {
    if (measurements.isEmpty) {
      return const BodyProgressSummaryEntity(
        latestMeasurementDay: null,
        latestWeightKg: null,
        latestWaistCm: null,
        rollingWeightAverageKg: null,
        previousRollingWeightAverageKg: null,
        weeklyWeightDeltaKg: null,
        latestWaistDeltaCm: null,
      );
    }

    BodyMeasurementEntity? latestWeight;
    BodyMeasurementEntity? latestWaist;
    BodyMeasurementEntity? previousWaist;
    for (final measurement in measurements) {
      if (latestWeight == null && measurement.weightKg != null) {
        latestWeight = measurement;
      }
      if (latestWaist == null && measurement.waistCm != null) {
        latestWaist = measurement;
      } else if (latestWaist != null &&
          previousWaist == null &&
          measurement.waistCm != null) {
        previousWaist = measurement;
      }
      if (latestWeight != null &&
          latestWaist != null &&
          previousWaist != null) {
        break;
      }
    }

    final normalizedReference =
        DateTime(referenceDay.year, referenceDay.month, referenceDay.day);
    final currentWindowStart =
        normalizedReference.subtract(const Duration(days: 6));
    final previousWindowEnd =
        normalizedReference.subtract(const Duration(days: 7));
    final previousWindowStart =
        normalizedReference.subtract(const Duration(days: 13));

    final currentWeights = measurements
        .where(
          (measurement) =>
              measurement.weightKg != null &&
              !measurement.day.isBefore(currentWindowStart) &&
              !measurement.day.isAfter(normalizedReference),
        )
        .map((measurement) => measurement.weightKg!)
        .toList(growable: false);
    final previousWeights = measurements
        .where(
          (measurement) =>
              measurement.weightKg != null &&
              !measurement.day.isBefore(previousWindowStart) &&
              !measurement.day.isAfter(previousWindowEnd),
        )
        .map((measurement) => measurement.weightKg!)
        .toList(growable: false);

    final currentAverage = currentWeights.isEmpty
        ? null
        : currentWeights.reduce((a, b) => a + b) / currentWeights.length;
    final previousAverage = previousWeights.isEmpty
        ? null
        : previousWeights.reduce((a, b) => a + b) / previousWeights.length;

    return BodyProgressSummaryEntity(
      latestMeasurementDay: measurements.first.day,
      latestWeightKg: latestWeight?.weightKg,
      latestWaistCm: latestWaist?.waistCm,
      rollingWeightAverageKg: currentAverage,
      previousRollingWeightAverageKg: previousAverage,
      weeklyWeightDeltaKg: currentAverage != null && previousAverage != null
          ? currentAverage - previousAverage
          : null,
      latestWaistDeltaCm: latestWaist != null &&
              previousWaist != null &&
              latestWaist.waistCm != null
          ? latestWaist.waistCm! - previousWaist.waistCm!
          : null,
    );
  }
}
