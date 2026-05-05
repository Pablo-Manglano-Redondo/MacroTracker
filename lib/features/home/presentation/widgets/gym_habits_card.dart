import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/get_daily_habit_log_usecase.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/update_daily_habit_log_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';

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
  DailyHabitLogEntity? _cachedLog;
  late Future<DailyHabitLogEntity> _logFuture;

  @override
  void initState() {
    super.initState();
    _logFuture = _loadLog(0);
  }

  @override
  void didUpdateWidget(covariant GymHabitsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshSeed != widget.refreshSeed) {
      _logFuture = _loadLog(_refreshSeed + widget.refreshSeed);
    }
  }

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
            future: _logFuture,
            builder: (context, snapshot) {
              final log = snapshot.data ??
                  _cachedLog ??
                  DailyHabitLogEntity.empty(DateTime.now());
              if (snapshot.hasData && snapshot.data != null) {
                _cachedLog = snapshot.data;
              }

              if (_cachedLog == null &&
                  snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 168,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

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
                        child: Text(
                          _title(context),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        _completedToday(context, completedCount),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _HabitStatusPill(
                          label: readinessTone.label,
                          icon: readinessTone.icon,
                          foreground: readinessTone.foreground(context),
                          background: readinessTone.background(context),
                        ),
                        const SizedBox(width: 8),
                        _HabitStatusPill(
                          label: _focusLabel(context, widget.dailyFocus),
                          icon: _focusIcon(widget.dailyFocus),
                          foreground: Theme.of(context).colorScheme.tertiary,
                          background: Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withValues(alpha: 0.12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _HabitChip(
                          label: 'Creat.',
                          icon: Icons.bolt_outlined,
                          selected: log.creatineTaken,
                          onSelected: (value) =>
                              _setHabit(creatineTaken: value),
                        ),
                        _HabitChip(
                          label: 'Prot.',
                          icon: Icons.fitness_center_outlined,
                          selected: log.wheyTaken,
                          onSelected: (value) => _setHabit(wheyTaken: value),
                        ),
                        _HabitChip(
                          label: 'Caf.',
                          icon: Icons.coffee_outlined,
                          selected: log.caffeineTaken,
                          onSelected: (value) =>
                              _setHabit(caffeineTaken: value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _hydrationTitle(context),
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
                        tooltip: _removeWaterTooltip(context),
                      ),
                      IconButton(
                        onPressed: () => _adjustWater(0.25),
                        icon: const Icon(Icons.add),
                        tooltip: _addWaterTooltip(context),
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
                    _hydrationHint(
                      context,
                      widget.dailyFocus,
                      hydrationGoalLiters,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricAdjuster(
                          label: _sleepTitle(context),
                          value:
                              '${log.sleepHours.toStringAsFixed(log.sleepHours % 1 == 0 ? 0 : 1)} h',
                          target: _sleepTarget(context, sleepGoalHours),
                          sourceLabel: log.sleepHours > 0
                              ? _sourceLabel(
                                  context, log.sleepSyncedFromHealthConnect)
                              : null,
                          sourceDetail: log.sleepHours > 0
                              ? _sourceDetail(
                                  context, log.sleepSyncedFromHealthConnect)
                              : null,
                          onDecrease: () => _adjustSleep(-0.5),
                          onIncrease: () => _adjustSleep(0.5),
                          accentColor: _goalTone(
                            log.meetsSleepGoal(sleepGoalHours),
                            context,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricAdjuster(
                          label: _stepsTitle(context),
                          value: _formatSteps(context, log.steps),
                          target: _stepsTarget(context, stepGoal),
                          sourceLabel: log.steps > 0
                              ? _sourceLabel(
                                  context, log.stepsSyncedFromHealthConnect)
                              : null,
                          sourceDetail: log.steps > 0
                              ? _sourceDetail(
                                  context, log.stepsSyncedFromHealthConnect)
                              : null,
                          onDecrease: () => _adjustSteps(-1000),
                          onIncrease: () => _adjustSteps(1000),
                          accentColor: _goalTone(
                            log.meetsStepGoal(stepGoal),
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _energyTitle(context),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index < 4 ? 8 : 0),
                          child: ChoiceChip(
                            showCheckmark: false,
                            label: SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (log.energyLevel == index + 1) ...[
                                    const Icon(Icons.check, size: 16),
                                    const SizedBox(width: 4),
                                  ],
                                  Text('${index + 1}'),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            selected: log.energyLevel == index + 1,
                            selectedColor: _energyTone(index + 1, context)
                                .withValues(alpha: 0.18),
                            onSelected: (_) => _setEnergy(index + 1),
                          ),
                        ),
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
      _refreshLog();
    }
  }

  Future<void> _adjustWater(double deltaLiters) async {
    await locator<UpdateDailyHabitLogUsecase>().adjustWater(
      day: DateTime.now(),
      deltaLiters: deltaLiters,
    );
    if (mounted) {
      _refreshLog();
    }
  }

  Future<void> _adjustSleep(double deltaHours) async {
    await locator<UpdateDailyHabitLogUsecase>().adjustSleep(
      day: DateTime.now(),
      deltaHours: deltaHours,
    );
    if (mounted) {
      _refreshLog();
    }
  }

  Future<void> _adjustSteps(int deltaSteps) async {
    await locator<UpdateDailyHabitLogUsecase>().adjustSteps(
      day: DateTime.now(),
      deltaSteps: deltaSteps,
    );
    if (mounted) {
      _refreshLog();
    }
  }

  Future<void> _setEnergy(int energyLevel) async {
    await locator<UpdateDailyHabitLogUsecase>().saveForDay(
      day: DateTime.now(),
      energyLevel: energyLevel,
    );
    if (mounted) {
      _refreshLog();
    }
  }

  void _refreshLog() {
    setState(() {
      _refreshSeed++;
      _logFuture = _loadLog(_refreshSeed + widget.refreshSeed);
    });
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

  String _focusLabel(BuildContext context, DailyFocusEntity focus) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return _isEs(context) ? 'Día de pierna' : 'Leg day';
      case DailyFocusEntity.upperBody:
        return _isEs(context) ? 'Día de torso' : 'Upper body day';
      case DailyFocusEntity.cardio:
        return _isEs(context) ? 'Día de cardio' : 'Cardio day';
      case DailyFocusEntity.rest:
        return _isEs(context) ? 'Día de descanso' : 'Rest day';
    }
  }

  IconData _focusIcon(DailyFocusEntity focus) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return Icons.directions_walk_outlined;
      case DailyFocusEntity.upperBody:
        return Icons.fitness_center_outlined;
      case DailyFocusEntity.cardio:
        return Icons.directions_run_outlined;
      case DailyFocusEntity.rest:
        return Icons.hotel_outlined;
    }
  }

  String _hydrationHint(
    BuildContext context,
    DailyFocusEntity focus,
    double hydrationGoalLiters,
  ) {
    final goal = _formatWater(hydrationGoalLiters);
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return _isEs(context)
            ? 'En pierna sube hidratación: objetivo $goal.'
            : 'Higher hydration target for leg day: $goal.';
      case DailyFocusEntity.upperBody:
        return _isEs(context)
            ? 'En torso mantén hidratación alta: objetivo $goal.'
            : 'Keep hydration high today: $goal.';
      case DailyFocusEntity.cardio:
        return _isEs(context)
            ? 'En cardio prioriza líquidos: objetivo $goal.'
            : 'Prioritize fluids today: $goal.';
      case DailyFocusEntity.rest:
        return _isEs(context)
            ? 'En descanso mantén hidratación: objetivo $goal.'
            : 'Keep hydration steady today: $goal.';
    }
  }

  String _formatWater(double liters) {
    if (widget.usesImperialUnits) {
      final flOz = UnitCalc.mlToFlOz(liters * 1000);
      return '${flOz.toStringAsFixed(flOz % 1 == 0 ? 0 : 1)} fl oz';
    }
    return '${liters.toStringAsFixed(liters % 1 == 0 ? 0 : 1)} L';
  }

  String _formatSteps(BuildContext context, int steps) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    return isEs ? '$steps pasos' : '$steps steps';
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

  String _sourceLabel(BuildContext context, bool synced) {
    if (synced) {
      return S.of(context).habitSourceSynced;
    }
    return S.of(context).habitSourceManualAdjust;
  }

  String _sourceDetail(BuildContext context, bool synced) {
    if (synced) {
      return S.of(context).gymHabitsSourceHealthConnectDetail;
    }
    return S.of(context).gymHabitsSourceManualDetail;
  }

  bool _isEs(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es';
  }

  String _title(BuildContext context) =>
      _isEs(context) ? 'Hábitos y recuperación' : 'Habits and recovery';

  String _completedToday(BuildContext context, int count) =>
      _isEs(context) ? '$count/7 hoy' : '$count/7 today';

  String _hydrationTitle(BuildContext context) =>
      _isEs(context) ? 'Hidratación' : 'Hydration';

  String _addWaterTooltip(BuildContext context) =>
      _isEs(context) ? 'Añadir agua' : 'Add water';

  String _removeWaterTooltip(BuildContext context) =>
      _isEs(context) ? 'Reducir agua' : 'Remove water';

  String _sleepTitle(BuildContext context) =>
      _isEs(context) ? 'Sueño' : 'Sleep';

  String _stepsTitle(BuildContext context) =>
      _isEs(context) ? 'Pasos' : 'Steps';

  String _energyTitle(BuildContext context) =>
      _isEs(context) ? 'Energía' : 'Energy';

  String _sleepTarget(BuildContext context, double hours) {
    final amount = hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1);
    return _isEs(context) ? 'Objetivo $amount h' : 'Goal $amount h';
  }

  String _stepsTarget(BuildContext context, int steps) {
    return _isEs(context)
        ? 'Objetivo ${_formatSteps(context, steps)}'
        : 'Goal ${_formatSteps(context, steps)}';
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
  final String? sourceLabel;
  final String? sourceDetail;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final Color accentColor;

  const _MetricAdjuster({
    required this.label,
    required this.value,
    required this.target,
    this.sourceLabel,
    this.sourceDetail,
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
          if (sourceLabel != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.75),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sourceLabel!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (sourceDetail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sourceDetail!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            S.of(context).gymHabitsManualAdjustHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: Icon(Icons.remove, color: accentColor),
                tooltip: Localizations.localeOf(context).languageCode == 'es'
                    ? 'Reducir $label'
                    : 'Reduce $label',
              ),
              IconButton(
                onPressed: onIncrease,
                icon: Icon(Icons.add, color: accentColor),
                tooltip: Localizations.localeOf(context).languageCode == 'es'
                    ? 'Aumentar $label'
                    : 'Increase $label',
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
