import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';
import 'package:macrotracker/features/body_progress/domain/entity/body_measurement_entity.dart';

class BodyMeasurementDialog extends StatefulWidget {
  final BodyMeasurementEntity? initialMeasurement;
  final bool usesImperialUnits;
  final bool allowDayEditing;

  const BodyMeasurementDialog({
    super.key,
    this.initialMeasurement,
    required this.usesImperialUnits,
    this.allowDayEditing = true,
  });

  @override
  State<BodyMeasurementDialog> createState() => _BodyMeasurementDialogState();
}

class _BodyMeasurementDialogState extends State<BodyMeasurementDialog> {
  late DateTime _selectedDay;
  late final TextEditingController _weightController;
  late final TextEditingController _waistController;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialMeasurement?.day ?? DateTime.now();
    _weightController = TextEditingController(
      text: widget.initialMeasurement?.weightKg == null
          ? ''
          : _formatValue(widget.usesImperialUnits
              ? UnitCalc.kgToLbs(widget.initialMeasurement!.weightKg!)
              : widget.initialMeasurement!.weightKg!),
    );
    _waistController = TextEditingController(
      text: widget.initialMeasurement?.waistCm == null
          ? ''
          : _formatValue(widget.usesImperialUnits
              ? UnitCalc.cmToInches(widget.initialMeasurement!.waistCm!)
              : widget.initialMeasurement!.waistCm!),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log body data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.allowDayEditing) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Day'),
              subtitle: Text(DateFormat.yMMMd().format(_selectedDay)),
              onTap: _pickDay,
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText:
                  widget.usesImperialUnits ? 'Weight (lb)' : 'Weight (kg)',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _waistController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: widget.usesImperialUnits ? 'Waist (in)' : 'Waist (cm)',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSave ? _save : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  bool get _canSave =>
      _weightController.text.trim().isNotEmpty ||
      _waistController.text.trim().isNotEmpty;

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDay = picked;
      });
    }
  }

  void _save() {
    final parsedWeight =
        double.tryParse(_weightController.text.trim().replaceAll(',', '.'));
    final parsedWaist =
        double.tryParse(_waistController.text.trim().replaceAll(',', '.'));

    Navigator.of(context).pop(
      BodyMeasurementDialogResult(
        day: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day),
        weightKg: parsedWeight == null
            ? null
            : widget.usesImperialUnits
                ? UnitCalc.lbsToKg(parsedWeight)
                : parsedWeight,
        waistCm: parsedWaist == null
            ? null
            : widget.usesImperialUnits
                ? UnitCalc.inchesToCm(parsedWaist)
                : parsedWaist,
      ),
    );
  }

  String _formatValue(double value) {
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
  }
}

class BodyMeasurementDialogResult {
  final DateTime day;
  final double? weightKg;
  final double? waistCm;

  const BodyMeasurementDialogResult({
    required this.day,
    required this.weightKg,
    required this.waistCm,
  });
}
