import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/macro_goal_mode_entity.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:macrotracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:macrotracker/generated/l10n.dart';

class CalculationsDialog extends StatefulWidget {
  final SettingsBloc settingsBloc;
  final ProfileBloc profileBloc;
  final HomeBloc homeBloc;
  final DiaryBloc diaryBloc;
  final CalendarDayBloc calendarDayBloc;

  const CalculationsDialog({
    super.key,
    required this.settingsBloc,
    required this.profileBloc,
    required this.homeBloc,
    required this.diaryBloc,
    required this.calendarDayBloc,
  });

  @override
  State<CalculationsDialog> createState() => _CalculationsDialogState();
}

class _CalculationsDialogState extends State<CalculationsDialog> {
  static const double _maxKcalAdjustment = 1000;
  static const double _minKcalAdjustment = -1000;
  static const int _kcalDivisions = 200;

  static const double _defaultCarbsPctSelection = 0.6;
  static const double _defaultFatPctSelection = 0.25;
  static const double _defaultProteinPctSelection = 0.15;

  static const double _defaultProteinGramPerKg = 1.6;
  static const double _defaultFatGramPerKg = 0.8;

  double _kcalAdjustmentSelection = 0;
  double _carbsPctSelection = _defaultCarbsPctSelection * 100;
  double _proteinPctSelection = _defaultProteinPctSelection * 100;
  double _fatPctSelection = _defaultFatPctSelection * 100;
  MacroGoalModeEntity _macroGoalMode = MacroGoalModeEntity.percentage;
  double? _userWeightKg;

  late final TextEditingController _proteinGramPerKgController;
  late final TextEditingController _fatGramPerKgController;

  @override
  void initState() {
    super.initState();
    _proteinGramPerKgController = TextEditingController();
    _fatGramPerKgController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeCalculationSettings();
  }

  @override
  void dispose() {
    _proteinGramPerKgController.dispose();
    _fatGramPerKgController.dispose();
    super.dispose();
  }

  void _initializeCalculationSettings() async {
    final kcalAdjustment = await widget.settingsBloc.getKcalAdjustment();
    final userCarbsPct = await widget.settingsBloc.getUserCarbGoalPct();
    final userProteinPct = await widget.settingsBloc.getUserProteinGoalPct();
    final userFatPct = await widget.settingsBloc.getUserFatGoalPct();
    final macroGoalMode = await widget.settingsBloc.getMacroGoalMode();
    final userProteinGramPerKg =
        await widget.settingsBloc.getUserProteinGoalGramPerKg();
    final userFatGramPerKg =
        await widget.settingsBloc.getUserFatGoalGramPerKg();
    final userWeightKg = await widget.settingsBloc.getUserWeightKg();

    if (!mounted) {
      return;
    }

    setState(() {
      _kcalAdjustmentSelection = kcalAdjustment;
      _carbsPctSelection = (userCarbsPct ?? _defaultCarbsPctSelection) * 100;
      _proteinPctSelection =
          (userProteinPct ?? _defaultProteinPctSelection) * 100;
      _fatPctSelection = (userFatPct ?? _defaultFatPctSelection) * 100;
      _macroGoalMode = macroGoalMode;
      _userWeightKg = userWeightKg;
      _proteinGramPerKgController.text =
          _formatDecimal(userProteinGramPerKg ?? _defaultProteinGramPerKg);
      _fatGramPerKgController.text =
          _formatDecimal(userFatGramPerKg ?? _defaultFatGramPerKg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              S.of(context).settingsCalculationsLabel,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _resetSelections,
            child: Text(S.of(context).buttonResetLabel),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                labelText: S.of(context).calculationsTDEELabel,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                prefixIcon: const Icon(Icons.functions_outlined),
              ),
              child: Text(
                '${S.of(context).calculationsTDEEIOM2006Label} ${S.of(context).calculationsRecommendedLabel}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${S.of(context).dailyKcalAdjustmentLabel} ${!_kcalAdjustmentSelection.isNegative ? "+" : ""}${_kcalAdjustmentSelection.round()} ${S.of(context).kcalLabel}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 280,
              child: Slider(
                min: _minKcalAdjustment,
                max: _maxKcalAdjustment,
                divisions: _kcalDivisions,
                value: _kcalAdjustmentSelection,
                label:
                    '${_kcalAdjustmentSelection.round()} ${S.of(context).kcalLabel}',
                onChanged: (value) {
                  setState(() {
                    _kcalAdjustmentSelection = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context).macroDistributionLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 280,
              child: SegmentedButton<MacroGoalModeEntity>(
                showSelectedIcon: true,
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: [
                  ButtonSegment(
                    value: MacroGoalModeEntity.percentage,
                    label: Text(S.of(context).calculationsMacroModePercentage),
                  ),
                  ButtonSegment(
                    value: MacroGoalModeEntity.gramsPerKg,
                    label: Text(S.of(context).calculationsMacroModeGramsPerKg),
                  ),
                ],
                selected: {_macroGoalMode},
                onSelectionChanged: (selection) {
                  setState(() {
                    _macroGoalMode = selection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_macroGoalMode == MacroGoalModeEntity.percentage) ...[
              _buildMacroSlider(
                S.of(context).carbsLabel,
                _carbsPctSelection,
                Colors.orange,
                (value) {
                  setState(() {
                    final delta = value - _carbsPctSelection;
                    _carbsPctSelection = value;

                    final proteinRatio = _proteinPctSelection /
                        (_proteinPctSelection + _fatPctSelection);
                    final fatRatio = _fatPctSelection /
                        (_proteinPctSelection + _fatPctSelection);

                    _proteinPctSelection -= delta * proteinRatio;
                    _fatPctSelection -= delta * fatRatio;

                    if (_proteinPctSelection < 5) {
                      final overflow = 5 - _proteinPctSelection;
                      _proteinPctSelection = 5;
                      _fatPctSelection -= overflow;
                    }
                    if (_fatPctSelection < 5) {
                      final overflow = 5 - _fatPctSelection;
                      _fatPctSelection = 5;
                      _proteinPctSelection -= overflow;
                    }
                  });
                },
              ),
              _buildMacroSlider(
                S.of(context).proteinLabel,
                _proteinPctSelection,
                Colors.blue,
                (value) {
                  setState(() {
                    final delta = value - _proteinPctSelection;
                    _proteinPctSelection = value;

                    final carbsRatio = _carbsPctSelection /
                        (_carbsPctSelection + _fatPctSelection);
                    final fatRatio = _fatPctSelection /
                        (_carbsPctSelection + _fatPctSelection);

                    _carbsPctSelection -= delta * carbsRatio;
                    _fatPctSelection -= delta * fatRatio;

                    if (_carbsPctSelection < 5) {
                      final overflow = 5 - _carbsPctSelection;
                      _carbsPctSelection = 5;
                      _fatPctSelection -= overflow;
                    }
                    if (_fatPctSelection < 5) {
                      final overflow = 5 - _fatPctSelection;
                      _fatPctSelection = 5;
                      _carbsPctSelection -= overflow;
                    }
                  });
                },
              ),
              _buildMacroSlider(
                S.of(context).fatLabel,
                _fatPctSelection,
                Colors.green,
                (value) {
                  setState(() {
                    final delta = value - _fatPctSelection;
                    _fatPctSelection = value;

                    final carbsRatio = _carbsPctSelection /
                        (_carbsPctSelection + _proteinPctSelection);
                    final proteinRatio = _proteinPctSelection /
                        (_carbsPctSelection + _proteinPctSelection);

                    _carbsPctSelection -= delta * carbsRatio;
                    _proteinPctSelection -= delta * proteinRatio;

                    if (_carbsPctSelection < 5) {
                      final overflow = 5 - _carbsPctSelection;
                      _carbsPctSelection = 5;
                      _proteinPctSelection -= overflow;
                    }
                    if (_proteinPctSelection < 5) {
                      final overflow = 5 - _proteinPctSelection;
                      _proteinPctSelection = 5;
                      _carbsPctSelection -= overflow;
                    }
                  });
                },
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: Text(
                  _gramPerKgHint(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                ),
              ),
              _buildGramPerKgField(
                label: S.of(context).proteinLabel,
                controller: _proteinGramPerKgController,
                color: Colors.blue,
                icon: Icons.fitness_center_outlined,
              ),
              const SizedBox(height: 12),
              _buildGramPerKgField(
                label: S.of(context).fatLabel,
                controller: _fatGramPerKgController,
                color: Colors.green,
                icon: Icons.opacity_outlined,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context).dialogCancelLabel),
        ),
        TextButton(
          onPressed: _saveCalculationSettings,
          child: Text(S.of(context).dialogOKLabel),
        )
      ],
    );
  }

  Widget _buildMacroSlider(
    String label,
    double value,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${value.round()}%'),
          ],
        ),
        SizedBox(
          width: 280,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
            ),
            child: Slider(
              min: 5,
              max: 90,
              value: value,
              divisions: 85,
              onChanged: (value) {
                final newValue = value.round().toDouble();
                if (100 - newValue >= 10) {
                  onChanged(newValue);
                  _normalizeMacros();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGramPerKgField({
    required String label,
    required TextEditingController controller,
    required Color color,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'g/kg',
        prefixIcon: Icon(icon, color: color),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _normalizeMacros() {
    setState(() {
      _carbsPctSelection = _carbsPctSelection.roundToDouble();
      _proteinPctSelection = _proteinPctSelection.roundToDouble();
      _fatPctSelection = _fatPctSelection.roundToDouble();

      final total =
          _carbsPctSelection + _proteinPctSelection + _fatPctSelection;

      if (total != 100) {
        final factor = 100 / total;
        _carbsPctSelection = (_carbsPctSelection * factor).roundToDouble();
        _proteinPctSelection = (_proteinPctSelection * factor).roundToDouble();
        _fatPctSelection = 100 - _carbsPctSelection - _proteinPctSelection;

        if (_fatPctSelection < 5) {
          _fatPctSelection = 5;
          final remaining = 95.0;
          final ratio =
              _carbsPctSelection / (_carbsPctSelection + _proteinPctSelection);
          _carbsPctSelection = (remaining * ratio).roundToDouble();
          _proteinPctSelection = remaining - _carbsPctSelection;
        }
      }
    });
  }

  void _resetSelections() {
    setState(() {
      _kcalAdjustmentSelection = 0;
      _carbsPctSelection = _defaultCarbsPctSelection * 100;
      _proteinPctSelection = _defaultProteinPctSelection * 100;
      _fatPctSelection = _defaultFatPctSelection * 100;
      _proteinGramPerKgController.text =
          _formatDecimal(_defaultProteinGramPerKg);
      _fatGramPerKgController.text = _formatDecimal(_defaultFatGramPerKg);
    });
  }

  Future<void> _saveCalculationSettings() async {
    await widget.settingsBloc
        .setKcalAdjustment(_kcalAdjustmentSelection.toInt().toDouble());
    await widget.settingsBloc.setMacroGoalMode(_macroGoalMode);

    if (_macroGoalMode == MacroGoalModeEntity.percentage) {
      widget.settingsBloc.setMacroGoals(
        _carbsPctSelection,
        _proteinPctSelection,
        _fatPctSelection,
      );
    } else {
      await widget.settingsBloc.setMacroGoalsGramPerKg(
        0,
        _parsePositiveDouble(
            _proteinGramPerKgController.text, _defaultProteinGramPerKg),
        _parsePositiveDouble(
            _fatGramPerKgController.text, _defaultFatGramPerKg),
      );
    }

    widget.settingsBloc.add(LoadSettingsEvent());
    widget.profileBloc.add(LoadProfileEvent());
    widget.homeBloc.add(LoadItemsEvent());
    widget.settingsBloc.updateTrackedDay(DateTime.now());
    widget.diaryBloc.add(LoadDiaryYearEvent());
    widget.calendarDayBloc.add(RefreshCalendarDayEvent());

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  double _parsePositiveDouble(String rawValue, double fallback) {
    final normalized = rawValue.replaceAll(',', '.').trim();
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed <= 0) {
      return fallback;
    }
    return parsed;
  }

  String _formatDecimal(double value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  }

  String _gramPerKgHint(BuildContext context) {
    final weightLabel = _userWeightKg != null
        ? '${_userWeightKg!.toStringAsFixed(1)} kg'
        : S.of(context).calculationsCurrentWeightFallback;
    return S.of(context).calculationsGramPerKgHint(weightLabel);
  }
}
