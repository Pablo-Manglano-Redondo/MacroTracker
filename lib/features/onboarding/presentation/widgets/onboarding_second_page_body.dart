import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';
import 'package:macrotracker/generated/l10n.dart';

class OnboardingSecondPageBody extends StatefulWidget {
  final Function(bool active, double? selectedHeight, double? selectedWeight,
      bool usesImperialUnits) setButtonContent;

  const OnboardingSecondPageBody({super.key, required this.setButtonContent});

  @override
  State<OnboardingSecondPageBody> createState() =>
      _OnboardingSecondPageBodyState();
}

class _OnboardingSecondPageBodyState extends State<OnboardingSecondPageBody> {
  final _heightFormKey = GlobalKey<FormState>();
  final _weightFormKey = GlobalKey<FormState>();
  final _isUnitSelected = [true, false];
  
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  double? _parsedHeight;
  double? _parsedWeight;

  bool get _isImperialSelected => _isUnitSelected[1];

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _updateHeightFromText(String text) {
    if (_heightFormKey.currentState?.validate() ?? false) {
      _parsedHeight = double.tryParse(text.replaceAll(',', '.'));
    } else {
      _parsedHeight = null;
    }
    checkCorrectInput();
  }

  void _updateWeightFromText(String text) {
    if (_weightFormKey.currentState?.validate() ?? false) {
      _parsedWeight = double.tryParse(text);
    } else {
      _parsedWeight = null;
    }
    checkCorrectInput();
  }

  void _toggleUnits(int index) {
    setState(() {
      final oldIsImperial = _isImperialSelected;
      for (int i = 0; i < _isUnitSelected.length; i++) {
        _isUnitSelected[i] = i == index;
      }
      final newIsImperial = _isImperialSelected;

      if (oldIsImperial != newIsImperial) {
        if (_parsedHeight != null) {
          if (newIsImperial) {
            final feet = UnitCalc.cmToFeet(_parsedHeight!);
            _parsedHeight = feet;
            _heightController.text = feet.toString();
          } else {
            final cm = UnitCalc.feetToCm(_parsedHeight!).roundToDouble();
            _parsedHeight = cm;
            _heightController.text = cm.round().toString();
          }
        }
        
        if (_parsedWeight != null) {
          if (newIsImperial) {
            final lbs = UnitCalc.kgToLbs(_parsedWeight!).roundToDouble();
            _parsedWeight = lbs;
            _weightController.text = lbs.round().toString();
          } else {
            final kg = UnitCalc.lbsToKg(_parsedWeight!).roundToDouble();
            _parsedWeight = kg;
            _weightController.text = kg.round().toString();
          }
        }
      }
      
      _heightFormKey.currentState?.validate();
      _weightFormKey.currentState?.validate();
      checkCorrectInput();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24.0),
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text(
                      S.of(context).settingsMetricLabel.split(' ')[0], // "Métrico"
                    ),
                    icon: const Icon(Icons.straighten_outlined),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text(
                      S.of(context).settingsImperialLabel.split(' ')[0], // "Imperial"
                    ),
                    icon: const Icon(Icons.explore_outlined),
                  ),
                ],
                selected: {_isImperialSelected},
                onSelectionChanged: (Set<bool> newSelection) {
                  final isImperial = newSelection.first;
                  _toggleUnits(isImperial ? 1 : 0);
                },
              ),
            ),
          ),
          Text(S.of(context).heightLabel,
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4.0),
          Text(S.of(context).onboardingHeightQuestionSubtitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 16.0),
          Form(
            key: _heightFormKey,
            child: TextFormField(
                controller: _heightController,
                onChanged: _updateHeightFromText,
                validator: validateHeight,
                decoration: InputDecoration(
                  labelText: _isImperialSelected ? 'ft' : 'cm',
                  hintText: _isImperialSelected
                      ? S.of(context).onboardingHeightExampleHintFt
                      : S.of(context).onboardingHeightExampleHintCm,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  !_isImperialSelected
                      ? FilteringTextInputFormatter.digitsOnly
                      : FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+([.,]\d{0,1})?$'))
                ]),
          ),
          const SizedBox(height: 24.0),
          Text(S.of(context).weightLabel,
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4.0),
          Text(S.of(context).onboardingWeightQuestionSubtitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 16.0),
          Form(
            key: _weightFormKey,
            child: TextFormField(
                controller: _weightController,
                onChanged: _updateWeightFromText,
                validator: validateWeight,
                decoration: InputDecoration(
                  labelText: _isImperialSelected
                      ? S.of(context).lbsLabel
                      : S.of(context).kgLabel,
                  hintText: _isImperialSelected
                      ? S.of(context).onboardingWeightExampleHintLbs
                      : S.of(context).onboardingWeightExampleHintKg,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          ),
        ],
      ),
    );
  }

  String? validateHeight(String? value) {
    if (value == null) return S.of(context).onboardingWrongHeightLabel;
    final parsedValue = double.tryParse(value.replaceAll(',', '.'));

    if (_isImperialSelected) {
      if (value.isEmpty ||
          !RegExp(r'^[0-9]+([.,][0-9])?$').hasMatch(value) ||
          parsedValue == null ||
          parsedValue < 2.7 ||
          parsedValue > 8.2) {
        return S.of(context).onboardingWrongHeightLabel;
      } else {
        return null;
      }
    } else {
      if (value.isEmpty ||
          !RegExp(r'^[0-9]+$').hasMatch(value) ||
          parsedValue == null ||
          parsedValue < 80 ||
          parsedValue > 250) {
        return S.of(context).onboardingWrongHeightLabel;
      } else {
        return null;
      }
    }
  }

  String? validateWeight(String? value) {
    if (value == null) return S.of(context).onboardingWrongWeightLabel;
    final parsedValue = double.tryParse(value);
    final minWeight = _isImperialSelected ? 55 : 25;
    final maxWeight = _isImperialSelected ? 770 : 350;
    if (value.isEmpty ||
        !RegExp(r'^[0-9]+$').hasMatch(value) ||
        parsedValue == null ||
        parsedValue < minWeight ||
        parsedValue > maxWeight) {
      return S.of(context).onboardingWrongWeightLabel;
    } else {
      return null;
    }
  }

  void checkCorrectInput() {
    final isHeightValid = _heightFormKey.currentState?.validate() ?? false;
    final isWeightValid = _weightFormKey.currentState?.validate() ?? false;

    if (isHeightValid && isWeightValid) {
      if (_parsedHeight != null && _parsedWeight != null) {
        final heightCm = _isImperialSelected
            ? UnitCalc.feetToCm(_parsedHeight!)
            : _parsedHeight!;
        final weightKg = _isImperialSelected
            ? UnitCalc.lbsToKg(_parsedWeight!)
            : _parsedWeight!;

        widget.setButtonContent(true, heightCm, weightKg, _isImperialSelected);
      } else {
        widget.setButtonContent(false, null, null, _isImperialSelected);
      }
    } else {
      widget.setButtonContent(false, null, null, _isImperialSelected);
    }
  }
}
