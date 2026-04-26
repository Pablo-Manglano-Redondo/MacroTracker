import 'package:macrotracker/features/body_progress/data/data_source/body_measurement_data_source.dart';
import 'package:macrotracker/features/body_progress/data/dbo/body_measurement_dbo.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_measurement_entity.dart';

class BodyMeasurementRepository {
  final BodyMeasurementDataSource _bodyMeasurementDataSource;

  BodyMeasurementRepository(this._bodyMeasurementDataSource);

  Future<void> saveMeasurement(BodyMeasurementEntity measurement) async {
    await _bodyMeasurementDataSource
        .saveMeasurement(BodyMeasurementDBO.fromEntity(measurement));
  }

  Future<BodyMeasurementEntity?> getMeasurement(DateTime day) async {
    final dbo = await _bodyMeasurementDataSource.getMeasurement(day);
    return dbo == null ? null : BodyMeasurementEntity.fromDBO(dbo);
  }

  Future<List<BodyMeasurementEntity>> getAllMeasurements() async {
    final dbos = await _bodyMeasurementDataSource.getAllMeasurements();
    return dbos.map(BodyMeasurementEntity.fromDBO).toList(growable: false);
  }

  Future<List<BodyMeasurementDBO>> getAllMeasurementsDBO() async {
    return _bodyMeasurementDataSource.getAllMeasurements();
  }

  Future<void> addAllMeasurements(List<BodyMeasurementDBO> measurements) async {
    await _bodyMeasurementDataSource.saveAllMeasurements(measurements);
  }
}
