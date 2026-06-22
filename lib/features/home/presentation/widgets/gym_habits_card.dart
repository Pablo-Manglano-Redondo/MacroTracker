import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/utils/calc/unit_calc.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/daily_habits/domain/entity/daily_habit_log_entity.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/get_daily_habit_log_usecase.dart';
import 'package:flutter/services.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/update_daily_habit_log_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';

class GymHabitsCardController extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

class GymHabitsCard extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final DailyFocusEntity dailyFocus;
  final bool usesImperialUnits;
  final GymHabitsCardController? controller;
  final int? targetSteps;
  final double? targetSleepHours;
  final double? targetWaterLiters;

  const GymHabitsCard({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    required this.dailyFocus,
    required this.usesImperialUnits,
    this.controller,
    this.targetSteps,
    this.targetSleepHours,
    this.targetWaterLiters,
  });

  @override
  State<GymHabitsCard> createState() => _GymHabitsCardState();
}

class _GymHabitsCardState extends State<GymHabitsCard> {
  DailyHabitLogEntity? _log;
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleExternalRefresh);
    _loadLog();
  }

  @override
  void didUpdateWidget(covariant GymHabitsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleExternalRefresh);
      widget.controller?.addListener(_handleExternalRefresh);
    }
    _loadLog();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleExternalRefresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hydrationGoalLiters = widget.targetWaterLiters ?? _hydrationGoalForFocus(widget.dailyFocus);
    final sleepGoalHours = widget.targetSleepHours ?? _sleepGoalForFocus(widget.dailyFocus);
    final stepGoal = widget.targetSteps ?? _stepGoalForFocus(widget.dailyFocus);

    return RepaintBoundary(
      child: Padding(
        padding: widget.padding,
        child: Card(
          elevation: 0.5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading && _log == null
                ? const SizedBox(
                    height: 168,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Builder(
                    builder: (context) {
                      final colorScheme = Theme.of(context).colorScheme;
                      final log =
                          _log ?? DailyHabitLogEntity.empty(DateTime.now());
                      final completedCount = log.completedCount(
                        hydrationGoalLiters: hydrationGoalLiters,
                        sleepGoalHours: sleepGoalHours,
                        stepGoal: stepGoal,
                      );
                      final readinessTone = _readinessTone(
                        completedCount: completedCount,
                        hydrationMet:
                            log.meetsHydrationGoal(hydrationGoalLiters),
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
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              Text(
                                _completedToday(context, completedCount),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              if (_isRefreshing) ...[
                                const SizedBox(width: 8),
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _HabitStatusPill(
                                  label: readinessTone.localizedLabel(context),
                                  icon: readinessTone.icon,
                                  foreground: readinessTone.foreground(context),
                                  background: readinessTone.background(context),
                                ),
                                const SizedBox(width: 8),
                                _HabitStatusPill(
                                  label:
                                      _focusLabel(context, widget.dailyFocus),
                                  icon: _focusIcon(widget.dailyFocus),
                                  foreground: const Color(0xFF10B981),
                                  background: const Color(0xFF10B981).withValues(alpha: 0.12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.start,
                              children: [
                                _HabitChip(
                                  label: S.of(context).gymHabitsCreatineShort,
                                  icon: Icons.bolt_outlined,
                                  selected: log.creatineTaken,
                                  onSelected: (value) =>
                                      _setHabit(creatineTaken: value),
                                ),
                                _HabitChip(
                                  label: S.of(context).gymHabitsProteinShort,
                                  icon: Icons.link,
                                  selected: log.wheyTaken,
                                  onSelected: (value) =>
                                      _setHabit(wheyTaken: value),
                                ),
                                _HabitChip(
                                  label: S.of(context).gymHabitsCaffeineShort,
                                  icon: Icons.local_cafe_outlined,
                                  selected: log.caffeineTaken,
                                  onSelected: (value) =>
                                      _setHabit(caffeineTaken: value),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Icon(
                                Icons.water_drop_outlined,
                                size: 18,
                                color: Color(0xFF3B82F6),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _hydrationTitle(context),
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _adjustWater(-0.25),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Text(
                                    '-',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '${_formatWater(log.waterLiters)} / ${_formatWater(hydrationGoalLiters)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              GestureDetector(
                                onTap: () => _adjustWater(0.25),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Text(
                                    '+',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: log.hydrationProgress(hydrationGoalLiters),
                              backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _hydrationHint(
                              context,
                              widget.dailyFocus,
                              hydrationGoalLiters,
                            ),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _MetricAdjuster(
                                  label: _sleepTitle(context),
                                  valueText: log.sleepHours.toStringAsFixed(log.sleepHours % 1 == 0 ? 0 : 1),
                                  targetText: '/ ${sleepGoalHours.toStringAsFixed(sleepGoalHours % 1 == 0 ? 0 : 1)} h',
                                  icon: Icons.nightlight_round,
                                  onDecrease: () => _adjustSleep(-0.5),
                                  onIncrease: () => _adjustSleep(0.5),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricAdjuster(
                                  label: _stepsTitle(context),
                                  valueText: '${log.steps}',
                                  targetText: '/ $stepGoal',
                                  icon: Icons.directions_walk_outlined,
                                  onDecrease: () => _adjustSteps(-1000),
                                  onIncrease: () => _adjustSteps(1000),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _energyTitle(context),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              5,
                              (index) {
                                final val = index + 1;
                                final isSelected = log.energyLevel == val;
                                final isDark = colorScheme.brightness == Brightness.dark;

                                final Color bgColor = isSelected
                                    ? colorScheme.primaryContainer
                                    : (isDark ? Colors.white.withValues(alpha: 0.03) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45));
                                final Color textColor = isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant;
                                final Border border = Border.all(
                                  color: isSelected
                                      ? colorScheme.primaryContainer
                                      : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.15 : 0.35),
                                );

                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: index < 4 ? 8.0 : 0.0),
                                    child: GestureDetector(
                                      onTap: () => _setEnergy(val),
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.circular(12),
                                          border: border,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$val',
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadLog() async {
    final log = await locator<GetDailyHabitLogUsecase>().getToday();
    if (!mounted) {
      return;
    }
    setState(() {
      _log = log;
      _isLoading = false;
      _isRefreshing = false;
    });
  }

  Future<void> _setHabit({
    bool? creatineTaken,
    bool? wheyTaken,
    bool? caffeineTaken,
  }) async {
    HapticFeedback.selectionClick();
    final current = _log ?? DailyHabitLogEntity.empty(DateTime.now());
    setState(() {
      _log = current.copyWith(
        day: DateTime.now(),
        creatineTaken: creatineTaken,
        wheyTaken: wheyTaken,
        caffeineTaken: caffeineTaken,
      );
    });
    final updated = await locator<UpdateDailyHabitLogUsecase>().saveForDay(
      day: DateTime.now(),
      creatineTaken: creatineTaken,
      wheyTaken: wheyTaken,
      caffeineTaken: caffeineTaken,
    );
    _applyPersistedLog(updated);
  }

  Future<void> _adjustWater(double deltaLiters) async {
    HapticFeedback.lightImpact();
    final current = _log ?? DailyHabitLogEntity.empty(DateTime.now());
    setState(() {
      _log = current.copyWith(
        day: DateTime.now(),
        waterLiters: (current.waterLiters + deltaLiters).clamp(0.0, 12.0),
      );
    });
    final updated = await locator<UpdateDailyHabitLogUsecase>().adjustWater(
      day: DateTime.now(),
      deltaLiters: deltaLiters,
    );
    _applyPersistedLog(updated);
  }

  Future<void> _adjustSleep(double deltaHours) async {
    HapticFeedback.lightImpact();
    final current = _log ?? DailyHabitLogEntity.empty(DateTime.now());
    setState(() {
      _log = current.copyWith(
        day: DateTime.now(),
        sleepHours: (current.sleepHours + deltaHours).clamp(0.0, 16.0),
        sleepSyncedFromHealthConnect: false,
      );
    });
    final updated = await locator<UpdateDailyHabitLogUsecase>().adjustSleep(
      day: DateTime.now(),
      deltaHours: deltaHours,
    );
    _applyPersistedLog(updated);
  }

  Future<void> _adjustSteps(int deltaSteps) async {
    HapticFeedback.lightImpact();
    final current = _log ?? DailyHabitLogEntity.empty(DateTime.now());
    setState(() {
      _log = current.copyWith(
        day: DateTime.now(),
        steps: (current.steps + deltaSteps).clamp(0, 100000),
        stepsSyncedFromHealthConnect: false,
      );
    });
    final updated = await locator<UpdateDailyHabitLogUsecase>().adjustSteps(
      day: DateTime.now(),
      deltaSteps: deltaSteps,
    );
    _applyPersistedLog(updated);
  }

  Future<void> _setEnergy(int energyLevel) async {
    HapticFeedback.selectionClick();
    final current = _log ?? DailyHabitLogEntity.empty(DateTime.now());
    setState(() {
      _log = current.copyWith(
        day: DateTime.now(),
        energyLevel: energyLevel,
      );
    });
    final updated = await locator<UpdateDailyHabitLogUsecase>().saveForDay(
      day: DateTime.now(),
      energyLevel: energyLevel,
    );
    _applyPersistedLog(updated);
  }

  void _refreshLog({bool showLoading = false}) {
    setState(() {
      _isLoading = showLoading && _log == null;
      _isRefreshing = !showLoading;
    });
    _loadLog();
  }

  void _handleExternalRefresh() {
    if (!mounted) {
      return;
    }
    _refreshLog(showLoading: false);
  }

  void _applyPersistedLog(DailyHabitLogEntity updated) {
    if (!mounted) {
      return;
    }
    setState(() {
      _log = updated;
      _isLoading = false;
      _isRefreshing = false;
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
        return S.of(context).gymHabitsFocusLowerBody;
      case DailyFocusEntity.upperBody:
        return S.of(context).gymHabitsFocusUpperBody;
      case DailyFocusEntity.cardio:
        return S.of(context).gymHabitsFocusCardio;
      case DailyFocusEntity.rest:
        return S.of(context).gymHabitsFocusRest;
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
        return S.of(context).gymHabitsHydrationHintLowerBody(goal);
      case DailyFocusEntity.upperBody:
        return S.of(context).gymHabitsHydrationHintUpperBody(goal);
      case DailyFocusEntity.cardio:
        return S.of(context).gymHabitsHydrationHintCardio(goal);
      case DailyFocusEntity.rest:
        return S.of(context).gymHabitsHydrationHintRest(goal);
    }
  }

  String _formatWater(double liters) {
    if (widget.usesImperialUnits) {
      final flOz = UnitCalc.mlToFlOz(liters * 1000);
      return '${flOz.toStringAsFixed(flOz % 1 == 0 ? 0 : 1)} ${S.of(context).fluidOunceUnitLabel}';
    }
    return '${liters.toStringAsFixed(liters % 1 == 0 ? 0 : 1)} ${S.of(context).literUnitLabel}';
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

  String _title(BuildContext context) =>
      S.of(context).gymHabitsTitle;

  String _completedToday(BuildContext context, int count) =>
      S.of(context).gymHabitsCompletedToday(count);

  String _hydrationTitle(BuildContext context) =>
      S.of(context).hydrationTitle;

  String _sleepTitle(BuildContext context) =>
      S.of(context).gymHabitsSleepTitle;

  String _stepsTitle(BuildContext context) =>
      S.of(context).gymHabitsStepsTitle;

  String _energyTitle(BuildContext context) =>
      S.of(context).gymHabitsEnergyTitle;
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final Color bgColor = selected
        ? colorScheme.secondaryContainer
        : (isDark ? Colors.transparent : Colors.transparent);
    final Color contentColor = selected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;
    final Border border = Border.all(
      color: selected
          ? colorScheme.secondaryContainer
          : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.20 : 0.45),
    );

    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: bgColor,
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: contentColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: contentColor,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricAdjuster extends StatelessWidget {
  final String label;
  final String valueText;
  final String targetText;
  final IconData icon;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _MetricAdjuster({
    required this.label,
    required this.valueText,
    required this.targetText,
    required this.icon,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? const Color(0xFF0D0D0D)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Icon(
                icon,
                size: 16,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: valueText,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                      ),
                ),
                TextSpan(
                  text: ' $targetText',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onDecrease,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.06 : 0.50),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.15 : 0.40),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.remove, size: 14, color: colorScheme.onSurface),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onIncrease,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.06 : 0.50),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.15 : 0.40),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.add, size: 14, color: colorScheme.onSurface),
                ),
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
            'gymHabitsReadinessOnTarget', Icons.check_circle_outline, _ReadinessToneKind.good);
  const _ReadinessTone.caution()
      : this._('gymHabitsReadinessImproving', Icons.adjust, _ReadinessToneKind.caution);
  const _ReadinessTone.bad()
      : this._(
            'gymHabitsReadinessOffTarget', Icons.error_outline, _ReadinessToneKind.bad);

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

  String localizedLabel(BuildContext context) {
    switch (label) {
      case 'gymHabitsReadinessOnTarget':
        return S.of(context).gymHabitsReadinessOnTarget;
      case 'gymHabitsReadinessImproving':
        return S.of(context).gymHabitsReadinessImproving;
      case 'gymHabitsReadinessOffTarget':
        return S.of(context).gymHabitsReadinessOffTarget;
      default:
        return label;
    }
  }
}

enum _ReadinessToneKind { good, caution, bad }
