import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/utils/extensions.dart';
import 'package:macrotracker/features/body_progress/data/dbo/body_measurement_dbo.dart';

class BodyMeasurementDataSource {
  final _log = Logger('BodyMeasurementDataSource');
  final Box<BodyMeasurementDBO> _bodyMeasurementBox;

  BodyMeasurementDataSource(this._bodyMeasurementBox);

  Future<void> saveMeasurement(BodyMeasurementDBO measurement) async {
    _log.fine('Saving body measurement for ${measurement.day}');
    await _bodyMeasurementBox.put(measurement.day.toParsedDay(), measurement);
  }

  Future<BodyMeasurementDBO?> getMeasurement(DateTime day) async {
    return _bodyMeasurementBox.get(day.toParsedDay());
  }

  Future<List<BodyMeasurementDBO>> getAllMeasurements() async {
    final values = _bodyMeasurementBox.values.toList();
    values.sort((a, b) => b.day.compareTo(a.day));
    return values;
  }

  Future<void> saveAllMeasurements(
      List<BodyMeasurementDBO> measurements) async {
    await _bodyMeasurementBox.putAll({
      for (final measurement in measurements)
        measurement.day.toParsedDay(): measurement,
    });
  }
}
