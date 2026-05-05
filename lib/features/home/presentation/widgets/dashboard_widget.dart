import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/generated/l10n.dart';

class DashboardWidget extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final UserWeightGoalEntity nutritionPhase;
  final ValueChanged<UserWeightGoalEntity> onNutritionPhaseChanged;
  final DailyFocusEntity dailyFocus;
  final ValueChanged<DailyFocusEntity> onDailyFocusChanged;
  final double totalKcalDaily;
  final double totalKcalLeft;
  final double totalKcalSupplied;
  final double totalKcalBurned;
  final double totalCarbsIntake;
  final double totalFatsIntake;
  final double totalProteinsIntake;
  final double totalCarbsGoal;
  final double totalFatsGoal;
  final double totalProteinsGoal;
  final int mealsLogged;
  final int sessionsLogged;

  const DashboardWidget({
    super.key,
    this.padding = const EdgeInsets.all(16),
    required this.nutritionPhase,
    required this.onNutritionPhaseChanged,
    required this.dailyFocus,
    required this.onDailyFocusChanged,
    required this.totalKcalSupplied,
    required this.totalKcalBurned,
    required this.totalKcalDaily,
    required this.totalKcalLeft,
    required this.totalCarbsIntake,
    required this.totalFatsIntake,
    required this.totalProteinsIntake,
    required this.totalCarbsGoal,
    required this.totalFatsGoal,
    required this.totalProteinsGoal,
    required this.mealsLogged,
    required this.sessionsLogged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 390;
    final surfaceColor = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: isDark ? 0.11 : 0.05),
      isDark ? colorScheme.surfaceContainerLow : colorScheme.surface,
    );
    final subtleSurface = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.42)
        : colorScheme.surfaceContainerHigh;
    final bodyColor = colorScheme.onSurface;
    final mutedColor = colorScheme.onSurfaceVariant;
    final proteinRemaining =
        _positiveRemaining(totalProteinsGoal - totalProteinsIntake);
    final carbsRemaining =
        _positiveRemaining(totalCarbsGoal - totalCarbsIntake);
    final fatRemaining = _positiveRemaining(totalFatsGoal - totalFatsIntake);
    final kcalProgress = totalKcalDaily <= 0
        ? 0.0
        : ((totalKcalSupplied / totalKcalDaily).clamp(0, 1)).toDouble();

    return Padding(
      padding: padding,
      child: Container(
        padding: EdgeInsets.all(isCompact ? 16 : 20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(isCompact ? 18 : 22),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isCompact ? 40 : 44,
                  height: isCompact ? 40 : 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isCompact ? 12 : 14),
                    color: colorScheme.primary.withValues(alpha: 0.14),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(
                    Icons.monitor_heart_outlined,
                    size: isCompact ? 20 : 22,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dashboardTitle(context),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: bodyColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: isCompact ? 22 : null,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dashboardSubtitle(context),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: mutedColor,
                              height: 1.3,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryChip(
                  icon: Icons.restaurant_outlined,
                  label: _mealsChip(context, mealsLogged),
                  compact: isCompact,
                  color: bodyColor,
                  background: subtleSurface,
                ),
                _SummaryChip(
                  icon: Icons.local_fire_department_outlined,
                  label: _burnedChip(context, totalKcalBurned.toInt()),
                  compact: isCompact,
                  color: bodyColor,
                  background: subtleSurface,
                ),
                _SummaryChip(
                  icon: Icons.fitness_center_outlined,
                  label: _sessionsChip(context, sessionsLogged),
                  compact: isCompact,
                  color: bodyColor,
                  background: subtleSurface,
                ),
              ],
            ),
            if (mealsLogged == 0 && sessionsLogged == 0) ...[
              const SizedBox(height: 10),
              Text(
                _emptyCopy(context),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                    ),
              ),
            ],
            const SizedBox(height: 18),
            _SelectorBlock<UserWeightGoalEntity>(
              caption: _goalLabel(context),
              colorScheme: colorScheme,
              compact: isCompact,
              selected: {nutritionPhase},
              segments: UserWeightGoalEntity.values
                  .map((phase) => ButtonSegment<UserWeightGoalEntity>(
                        value: phase,
                        label: Text(
                          _phaseLabel(context, phase),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ))
                  .toList(),
              onSelectionChanged: (selection) {
                onNutritionPhaseChanged(selection.first);
              },
            ),
            const SizedBox(height: 12),
            _SelectorBlock<DailyFocusEntity>(
              caption: _focusSelectorLabel(context),
              colorScheme: colorScheme,
              compact: isCompact,
              selected: {dailyFocus},
              segments: DailyFocusEntity.values
                  .map((focus) => ButtonSegment<DailyFocusEntity>(
                        value: focus,
                        label: Text(
                          _focusLabel(focus),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ))
                  .toList(),
              onSelectionChanged: (selection) {
                onDailyFocusChanged(selection.first);
              },
            ),
            const SizedBox(height: 18),
            Text(
              _phaseHeadline(context, nutritionPhase),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: bodyColor,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    fontSize: isCompact ? 26 : null,
                  ),
            ),
            const SizedBox(height: 7),
            Text(
              _focusHeadline(context, dailyFocus),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 5),
            Text(
              '${_phaseMacroHint(context, nutritionPhase)} ${_focusMacroHint(context, dailyFocus)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 18),
            if (isCompact) ...[
              _PrimaryMetric(
                label: _proteinRemainingLabel(context),
                value: proteinRemaining.toInt(),
                suffix: 'g',
                textColor: bodyColor,
                accentColor: colorScheme.primary,
                background: colorScheme.primary.withValues(alpha: 0.14),
                compact: true,
              ),
              const SizedBox(height: 10),
              _PrimaryMetric(
                label: totalKcalLeft >= 0
                    ? _kcalRemainingLabel(context)
                    : _overGoalLabel(context),
                value: totalKcalLeft.abs().toInt(),
                suffix: 'kcal',
                textColor: bodyColor,
                accentColor: totalKcalLeft >= 0
                    ? colorScheme.tertiary
                    : colorScheme.error,
                background: totalKcalLeft >= 0
                    ? colorScheme.tertiary.withValues(alpha: 0.14)
                    : colorScheme.error.withValues(alpha: 0.14),
                compact: true,
              ),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _PrimaryMetric(
                      label: _proteinRemainingLabel(context),
                      value: proteinRemaining.toInt(),
                      suffix: 'g',
                      textColor: bodyColor,
                      accentColor: colorScheme.primary,
                      background: colorScheme.primary.withValues(alpha: 0.14),
                      compact: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PrimaryMetric(
                      label: totalKcalLeft >= 0
                          ? _kcalRemainingLabel(context)
                          : _overGoalLabel(context),
                      value: totalKcalLeft.abs().toInt(),
                      suffix: 'kcal',
                      textColor: bodyColor,
                      accentColor: totalKcalLeft >= 0
                          ? colorScheme.tertiary
                          : colorScheme.error,
                      background: totalKcalLeft >= 0
                          ? colorScheme.tertiary.withValues(alpha: 0.14)
                          : colorScheme.error.withValues(alpha: 0.14),
                      compact: false,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 9,
                value: kcalProgress,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _kcalProgressLabel(
                context,
                totalKcalSupplied.toInt(),
                totalKcalDaily.toInt(),
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 18),
            _MacroTrackRow(
              label: localizations.proteinLabel,
              intake: totalProteinsIntake,
              goal: totalProteinsGoal,
              remaining: proteinRemaining,
              color: colorScheme.primary,
              emphasis: true,
            ),
            const SizedBox(height: 12),
            _MacroTrackRow(
              label: localizations.carbohydrateLabel,
              intake: totalCarbsIntake,
              goal: totalCarbsGoal,
              remaining: carbsRemaining,
              color: colorScheme.tertiary,
            ),
            const SizedBox(height: 12),
            _MacroTrackRow(
              label: localizations.fatLabel,
              intake: totalFatsIntake,
              goal: totalFatsGoal,
              remaining: fatRemaining,
              color: const Color(0xFFE7A83B),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: subtleSurface,
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: colorScheme.primary.withValues(alpha: 0.10),
                    ),
                    child: Icon(
                      Icons.insights_outlined,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _buildStatusCopy(
                        context: context,
                        dailyFocus: dailyFocus,
                        nutritionPhase: nutritionPhase,
                        proteinRemaining: proteinRemaining,
                        carbsRemaining: carbsRemaining,
                        kcalRemaining: totalKcalLeft,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: bodyColor,
                            height: 1.35,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildStatusCopy({
    required BuildContext context,
    required DailyFocusEntity dailyFocus,
    required UserWeightGoalEntity nutritionPhase,
    required double proteinRemaining,
    required double carbsRemaining,
    required double kcalRemaining,
  }) {
    if (nutritionPhase == UserWeightGoalEntity.loseWeight &&
        kcalRemaining < 200 &&
        kcalRemaining >= 0) {
      return _statusDefClosing(context);
    }
    if (nutritionPhase == UserWeightGoalEntity.gainWeight &&
        kcalRemaining >= 450) {
      return _statusBulkOpen(context);
    }
    if (proteinRemaining >= 30) {
      return _statusProteinGap(context);
    }
    if (dailyFocus == DailyFocusEntity.lowerBody && carbsRemaining >= 45) {
      return _statusCarbWindow(context);
    }
    if (dailyFocus == DailyFocusEntity.rest && kcalRemaining < 150) {
      return _statusRestClosing(context);
    }
    if (kcalRemaining < 0) {
      return _statusOverGoal(context);
    }
    return _statusDefault(context);
  }

  double _positiveRemaining(double value) {
    if (value <= 0) {
      return 0;
    }
    return value;
  }

  String _phaseLabel(BuildContext context, UserWeightGoalEntity phase) {
    switch (phase) {
      case UserWeightGoalEntity.loseWeight:
        return S.of(context).profileGoalLose;
      case UserWeightGoalEntity.maintainWeight:
        return S.of(context).profileGoalMaintain;
      case UserWeightGoalEntity.gainWeight:
        return S.of(context).profileGoalGain;
    }
  }

  String _phaseHeadline(BuildContext context, UserWeightGoalEntity phase) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    switch (phase) {
      case UserWeightGoalEntity.loseWeight:
        return isEs
            ? 'Protege músculo y controla calorías'
            : 'Protect muscle and control calories';
      case UserWeightGoalEntity.maintainWeight:
        return isEs ? 'Mantén el peso estable' : 'Keep weight stable';
      case UserWeightGoalEntity.gainWeight:
        return isEs
            ? 'Empuja rendimiento y recuperación'
            : 'Push performance and recovery';
    }
  }

  String _phaseMacroHint(BuildContext context, UserWeightGoalEntity phase) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    switch (phase) {
      case UserWeightGoalEntity.loseWeight:
        return isEs
            ? 'Proteína alta y energía ajustada.'
            : 'High protein and tighter energy.';
      case UserWeightGoalEntity.maintainWeight:
        return isEs
            ? 'Macros equilibrados y proteína constante.'
            : 'Balanced macros and steady protein.';
      case UserWeightGoalEntity.gainWeight:
        return isEs
            ? 'Más energía y carbohidrato para progresar.'
            : 'More energy and carbs to progress.';
    }
  }

  String _focusLabel(DailyFocusEntity focus) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return 'Pierna';
      case DailyFocusEntity.upperBody:
        return 'Torso';
      case DailyFocusEntity.cardio:
        return 'Cardio';
      case DailyFocusEntity.rest:
        return 'Desc.';
    }
  }

  String _focusHeadline(BuildContext context, DailyFocusEntity focus) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return isEs
            ? 'Pierna: prioriza energía y recuperación.'
            : 'Leg day: prioritize energy and recovery.';
      case DailyFocusEntity.upperBody:
        return isEs
            ? 'Torso: rinde y recupera bien.'
            : 'Upper body: perform and recover well.';
      case DailyFocusEntity.cardio:
        return isEs
            ? 'Cardio: energía limpia y fatiga controlada.'
            : 'Cardio: clean fuel and fatigue control.';
      case DailyFocusEntity.rest:
        return isEs
            ? 'Descanso: recupera con proteína alta.'
            : 'Rest day: recover with high protein.';
    }
  }

  String _focusMacroHint(BuildContext context, DailyFocusEntity focus) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return isEs
            ? 'Sube carbohidrato cerca del entreno.'
            : 'Raise carbs around training.';
      case DailyFocusEntity.upperBody:
        return isEs
            ? 'Mantén buen combustible todo el día.'
            : 'Keep fuel steady through the day.';
      case DailyFocusEntity.cardio:
        return isEs
            ? 'Hidratación alta y carbohidrato moderado.'
            : 'High hydration and moderate carbs.';
      case DailyFocusEntity.rest:
        return isEs ? 'Recorta algo de carbohidrato.' : 'Trim carbs a bit.';
    }
  }

  bool _isEs(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es';
  }

  String _dashboardTitle(BuildContext context) =>
      _isEs(context) ? 'Nutrición de gimnasio' : 'Gym nutrition';

  String _dashboardSubtitle(BuildContext context) =>
      _isEs(context) ? 'Lo importante de hoy.' : 'Today at a glance.';

  String _emptyCopy(BuildContext context) => _isEs(context)
      ? 'Registra una comida o un entreno para activar mejor contexto.'
      : 'Log a meal or workout to unlock better guidance.';

  String _goalLabel(BuildContext context) =>
      _isEs(context) ? 'Objetivo' : 'Goal';

  String _focusSelectorLabel(BuildContext context) =>
      _isEs(context) ? 'Enfoque' : 'Focus';

  String _mealsChip(BuildContext context, int count) =>
      _isEs(context) ? '$count comidas' : '$count meals';

  String _sessionsChip(BuildContext context, int count) =>
      _isEs(context) ? '$count sesiones' : '$count sessions';

  String _burnedChip(BuildContext context, int count) =>
      _isEs(context) ? '$count cals' : '$count burned';

  String _proteinRemainingLabel(BuildContext context) =>
      _isEs(context) ? 'Proteína restante' : 'Protein left';

  String _kcalRemainingLabel(BuildContext context) =>
      _isEs(context) ? 'Kcal restantes' : 'Kcal left';

  String _overGoalLabel(BuildContext context) =>
      _isEs(context) ? 'Sobre objetivo' : 'Over goal';

  String _kcalProgressLabel(BuildContext context, int current, int goal) =>
      _isEs(context) ? '$current de $goal kcal' : '$current of $goal kcal';

  String _statusDefClosing(BuildContext context) => _isEs(context)
      ? 'La definición va en ritmo. Cierra con proteína alta.'
      : 'Definition on track. Keep the last meal high in protein.';

  String _statusBulkOpen(BuildContext context) => _isEs(context)
      ? 'Aún tienes margen. Mete carbohidrato fácil y proteína.'
      : 'You still have room. Add easy carbs and protein.';

  String _statusProteinGap(BuildContext context) => _isEs(context)
      ? 'La principal brecha sigue siendo la proteína. Priorízala en la siguiente comida.'
      : 'Protein is still the main gap. Prioritize it next meal.';

  String _statusCarbWindow(BuildContext context) => _isEs(context)
      ? 'Aún tienes margen de carbohidratos. Buen momento para meter energía de entreno.'
      : 'You still have carb room. Good moment for training fuel.';

  String _statusRestClosing(BuildContext context) => _isEs(context)
      ? 'Día de descanso casi cerrado. Termina ligero y con proteína.'
      : 'Rest day almost closed. Finish light and protein-first.';

  String _statusOverGoal(BuildContext context) => _isEs(context)
      ? 'Vas por encima del objetivo. Mantén el resto del día más controlado.'
      : 'You are above target. Keep the rest of the day tighter.';

  String _statusDefault(BuildContext context) => _isEs(context)
      ? 'Buen ritmo. Manténlo simple y cierra limpio.'
      : 'Good pace. Keep it simple and close the day clean.';
}

class _SelectorBlock<T> extends StatelessWidget {
  final String caption;
  final ColorScheme colorScheme;
  final bool compact;
  final Set<T> selected;
  final List<ButtonSegment<T>> segments;
  final ValueChanged<Set<T>> onSelectionChanged;

  const _SelectorBlock({
    required this.caption,
    required this.colorScheme,
    required this.compact,
    required this.selected,
    required this.segments,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            caption,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        SegmentedButton<T>(
          showSelectedIcon: false,
          multiSelectionEnabled: false,
          expandedInsets: EdgeInsets.zero,
          segments: segments,
          selected: selected,
          onSelectionChanged: onSelectionChanged,
          style: ButtonStyle(
            visualDensity: VisualDensity.standard,
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(
                horizontal: compact ? 8 : 14,
                vertical: compact ? 11 : 12,
              ),
            ),
            minimumSize: WidgetStatePropertyAll(Size(0, compact ? 42 : 46)),
            textStyle: WidgetStatePropertyAll(
              TextStyle(
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.18),
                );
              }
              return BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.50),
              );
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.onPrimary;
              }
              return colorScheme.onSurface;
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colorScheme.primary;
              }
              return colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.82);
            }),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return colorScheme.primary.withValues(alpha: 0.10);
              }
              return null;
            }),
          ),
        ),
      ],
    );
  }
}

class _PrimaryMetric extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final Color textColor;
  final Color accentColor;
  final Color background;
  final bool compact;

  const _PrimaryMetric({
    required this.label,
    required this.value,
    required this.suffix,
    required this.textColor,
    required this.accentColor,
    required this.background,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: background,
        border: Border.all(
          color: textColor.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: compact ? 8 : 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 4,
                height: compact ? 24 : 28,
                margin: const EdgeInsets.only(right: 10, bottom: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: accentColor,
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedFlipCounter(
                        duration: const Duration(milliseconds: 700),
                        value: value,
                        textStyle: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w800,
                              fontSize: compact ? 28 : null,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          suffix,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: textColor.withValues(alpha: 0.72),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool compact;
  final Color color;
  final Color background;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.compact,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 10,
        vertical: compact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: background.withValues(alpha: 0.92),
        border: Border.all(
          color: color.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: compact ? 13 : 14, color: color.withValues(alpha: 0.85)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color.withValues(alpha: 0.85),
                ),
          ),
        ],
      ),
    );
  }
}

class _MacroTrackRow extends StatelessWidget {
  final String label;
  final double intake;
  final double goal;
  final double remaining;
  final Color color;
  final bool emphasis;

  const _MacroTrackRow({
    required this.label,
    required this.intake,
    required this.goal,
    required this.remaining,
    required this.color,
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    final progress = goal <= 0 ? 0.0 : ((intake / goal).clamp(0, 1)).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: emphasis ? FontWeight.w700 : FontWeight.w600,
                    ),
              ),
            ),
            Text(
              '${intake.toInt()}/${goal.toInt()} g',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: progress,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          remaining > 0
              ? (Localizations.localeOf(context).languageCode == 'es'
                  ? '${remaining.toInt()} g restantes'
                  : '${remaining.toInt()} g left')
              : localizations.homeDashboardMacroDone,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
