import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/get_daily_habit_log_usecase.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/update_daily_habit_log_usecase.dart';

class GymHabitsCard extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final DailyFocusEntity dailyFocus;
  final bool usesImperialUnits;
  final int refreshSeed;

  const GymHabitsCard({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    required this.dailyFocus,
    required this.usesImperialUnits,
    this.refreshSeed = 0,
  });

  @override
  State<GymHabitsCard> createState() => _GymHabitsCardState();
}

class _GymHabitsCardState extends State<GymHabitsCard> {
  int _refreshSeed = 0;

  @override
  Widget build(BuildContext context) {
    final hydrationGoalLiters = _hydrationGoalForFocus(widget.dailyFocus);
    final sleepGoalHours = _sleepGoalForFocus(widget.dailyFocus);
    final stepGoal = _stepGoalForFocus(widget.dailyFocus);

    return Padding(
      padding: widget.padding,
      child: Card(
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<DailyHabitLogEntity>(
            future: _loadLog(_refreshSeed + widget.refreshSeed),
            builder: (context, snapshot) {
              if (!snapshot.hasData &&
                  snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 168,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final log =
                  snapshot.data ?? DailyHabitLogEntity.empty(DateTime.now());
              final completedCount = log.completedCount(
                hydrationGoalLiters: hydrationGoalLiters,
                sleepGoalHours: sleepGoalHours,
                stepGoal: stepGoal,
              );
              final readinessTone = _readinessTone(
                completedCount: completedCount,
                hydrationMet: log.meetsHydrationGoal(hydrationGoalLiters),
                sleepMet: log.meetsSleepGoal(sleepGoalHours),
                stepsMet: log.meetsStepGoal(stepGoal),
                energyLevel: log.energyLevel,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Suplementos y hábitos',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completedCount/7 completados hoy',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      _HabitStatusPill(
                        label: readinessTone.label,
                        icon: readinessTone.icon,
                        foreground: readinessTone.foreground(context),
                        background: readinessTone.background(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _focusLabel(widget.dailyFocus),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HabitChip(
                        label: 'Creatine',
                        icon: Icons.bolt_outlined,
                        selected: log.creatineTaken,
                        onSelected: (value) => _setHabit(creatineTaken: value),
                      ),
                      _HabitChip(
                        label: 'Whey',
                        icon: Icons.fitness_center_outlined,
                        selected: log.wheyTaken,
                        onSelected: (value) => _setHabit(wheyTaken: value),
                      ),
                      _HabitChip(
                        label: 'Caffeine',
                        icon: Icons.coffee_outlined,
                        selected: log.caffeineTaken,
                        onSelected: (value) => _setHabit(caffeineTaken: value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).hydrationTitle,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatWater(log.waterLiters)} / ${_formatWater(hydrationGoalLiters)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _adjustWater(-0.25),
                        icon: const Icon(Icons.remove),
                        tooltip: S.of(context).hydrationRemoveWater,
                      ),
                      IconButton(
                        onPressed: () => _adjustWater(0.25),
                        icon: const Icon(Icons.add),
                        tooltip: S.of(context).hydrationAddWater,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: log.hydrationProgress(hydrationGoalLiters),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _goalTone(log.meetsHydrationGoal(hydrationGoalLiters),
                            context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hydrationHint(widget.dailyFocus, hydrationGoalLiters),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricAdjuster(
                          label: 'Sueño',
                          value:
                              '${log.sleepHours.toStringAsFixed(log.sleepHours % 1 == 0 ? 0 : 1)} h',
                          target:
                              'Objetivo ${sleepGoalHours.toStringAsFixed(sleepGoalHours % 1 == 0 ? 0 : 1)} h',
                          onDecrease: () => _adjustSleep(-0.5),
                          onIncrease: () => _adjustSleep(0.5),
                          accentColor: _goalTone(
                              log.meetsSleepGoal(sleepGoalHours), context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricAdjuster(
                          label: 'Pasos',
                          value: _formatSteps(log.steps),
                          target: 'Objetivo ${_formatSteps(stepGoal)}',
                          onDecrease: () => _adjustSteps(-1000),
                          onIncrease: () => _adjustSteps(1000),
                          accentColor:
                              _goalTone(log.meetsStepGoal(stepGoal), context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Energía',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      5,
                      (index) => ChoiceChip(
                        label: Text('${index + 1}'),
                        selected: log.energyLevel == index + 1,
                        selectedColor: _energyTone(index + 1, context)
                            .withValues(alpha: 0.18),
                        onSelected: (_) => _setEnergy(index + 1),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<DailyHabitLogEntity> _loadLog(int _) {
    return locator<GetDailyHabitLogUsecase>().getToday();
  }

  Future<void> _setHabit({
    bool? creatineTaken,
    bool? wheyTaken,
    bool? caffeineTaken,
  }) async {
    await locator<UpdateDailyHabitLogUsecase>().saveForDay(
      day: DateTime.now(),
      creatineTaken: creatineTaken,
      wheyTaken: wheyTaken,
      caffeineTaken: caffeineTaken,
    );
    if (mounted) {
      setState(() {
        _refreshSeed++;
      });
    }
  }

  Future<void> _adjustWater(double deltaLiters) async {
    await locator<UpdateDailyHabitLogUsecase>().adjustWater(
      day: DateTime.now(),
      deltaLiters: deltaLiters,
    );
    if (mounted) {
      setState(() {
        _refreshSeed++;
      });
    }
  }

  Future<void> _adjustSleep(double deltaHours) async {
    await locator<UpdateDailyHabitLogUsecase>().adjustSleep(
      day: DateTime.now(),
      deltaHours: deltaHours,
    );
    if (mounted) {
      setState(() {
        _refreshSeed++;
      });
    }
  }

  Future<void> _adjustSteps(int deltaSteps) async {
    await locator<UpdateDailyHabitLogUsecase>().adjustSteps(
      day: DateTime.now(),
      deltaSteps: deltaSteps,
    );
    if (mounted) {
      setState(() {
        _refreshSeed++;
      });
    }
  }

  Future<void> _setEnergy(int energyLevel) async {
    await locator<UpdateDailyHabitLogUsecase>().saveForDay(
      day: DateTime.now(),
      energyLevel: energyLevel,
    );
    if (mounted) {
      setState(() {
        _refreshSeed++;
      });
    }
  }

  double _hydrationGoalForFocus(DailyFocusEntity focus) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return 3.8;
      case DailyFocusEntity.upperBody:
        return 3.5;
      case DailyFocusEntity.cardio:
        return 3.75;
      case DailyFocusEntity.rest:
        return 2.75;
    }
  }

  double _sleepGoalForFocus(DailyFocusEntity focus) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
      case DailyFocusEntity.upperBody:
        return 8;
      case DailyFocusEntity.cardio:
        return 8;
      case DailyFocusEntity.rest:
        return 7.5;
    }
  }

  int _stepGoalForFocus(DailyFocusEntity focus) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
      case DailyFocusEntity.upperBody:
        return 8000;
      case DailyFocusEntity.cardio:
        return 10000;
      case DailyFocusEntity.rest:
        return 7000;
    }
  }

  String _focusLabel(DailyFocusEntity focus) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return 'Día de pierna';
      case DailyFocusEntity.upperBody:
        return 'Día de torso';
      case DailyFocusEntity.cardio:
        return 'Día de cardio';
      case DailyFocusEntity.rest:
        return 'Día de descanso';
    }
  }

  String _hydrationHint(DailyFocusEntity focus, double hydrationGoalLiters) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return 'En pierna sube hidratación: objetivo ${_formatWater(hydrationGoalLiters)}.';
      case DailyFocusEntity.upperBody:
        return 'En torso mantén hidratación alta: objetivo ${_formatWater(hydrationGoalLiters)}.';
      case DailyFocusEntity.cardio:
        return 'En cardio prioriza líquidos: objetivo ${_formatWater(hydrationGoalLiters)}.';
      case DailyFocusEntity.rest:
        return 'En descanso mantén hidratación estable: objetivo ${_formatWater(hydrationGoalLiters)}.';
    }
  }

  String _formatWater(double liters) {
    if (widget.usesImperialUnits) {
      final flOz = UnitCalc.mlToFlOz(liters * 1000);
      return '${flOz.toStringAsFixed(flOz % 1 == 0 ? 0 : 1)} fl oz';
    }
    return '${liters.toStringAsFixed(liters % 1 == 0 ? 0 : 1)} L';
  }

  String _formatSteps(int steps) {
    return '${steps.toString()} pasos';
  }

  _ReadinessTone _readinessTone({
    required int completedCount,
    required bool hydrationMet,
    required bool sleepMet,
    required bool stepsMet,
    required int energyLevel,
  }) {
    if (completedCount >= 6 && energyLevel >= 4) {
      return const _ReadinessTone.good();
    }
    if (completedCount <= 2 || (!hydrationMet && !sleepMet && !stepsMet)) {
      return const _ReadinessTone.bad();
    }
    return const _ReadinessTone.caution();
  }

  Color _goalTone(bool met, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return met ? scheme.primary : scheme.tertiary;
  }

  Color _energyTone(int energyLevel, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (energyLevel >= 4) {
      return scheme.primary;
    }
    if (energyLevel == 3) {
      return scheme.tertiary;
    }
    return scheme.error;
  }
}

class _HabitChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _HabitChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      avatar: Icon(
        icon,
        size: 18,
        color: selected
            ? Theme.of(context).colorScheme.onSecondaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      label: Text(label),
      onSelected: onSelected,
    );
  }
}

class _MetricAdjuster extends StatelessWidget {
  final String label;
  final String value;
  final String target;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final Color accentColor;

  const _MetricAdjuster({
    required this.label,
    required this.value,
    required this.target,
    required this.onDecrease,
    required this.onIncrease,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: accentColor.withValues(alpha: 0.10),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accentColor,
                ),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(target, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: Icon(Icons.remove, color: accentColor),
                tooltip: 'Reducir $label',
              ),
              IconButton(
                onPressed: onIncrease,
                icon: Icon(Icons.add, color: accentColor),
                tooltip: 'Aumentar $label',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitStatusPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;

  const _HabitStatusPill({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: background,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foreground,
                ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessTone {
  final String label;
  final IconData icon;
  final _ReadinessToneKind kind;

  const _ReadinessTone._(this.label, this.icon, this.kind);

  const _ReadinessTone.good()
      : this._(
            'En objetivo', Icons.check_circle_outline, _ReadinessToneKind.good);
  const _ReadinessTone.caution()
      : this._('Mejorable', Icons.adjust, _ReadinessToneKind.caution);
  const _ReadinessTone.bad()
      : this._(
            'Fuera de objetivo', Icons.error_outline, _ReadinessToneKind.bad);

  Color foreground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (kind) {
      case _ReadinessToneKind.good:
        return scheme.primary;
      case _ReadinessToneKind.caution:
        return scheme.tertiary;
      case _ReadinessToneKind.bad:
        return scheme.error;
    }
  }

  Color background(BuildContext context) {
    return foreground(context).withValues(alpha: 0.12);
  }
}

enum _ReadinessToneKind { good, caution, bad }
