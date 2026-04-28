import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final surfaceColor = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: isDark ? 0.09 : 0.04),
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.42),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.primary.withValues(alpha: 0.16),
                  ),
                  child: Icon(
                    Icons.monitor_heart_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutrición de gimnasio',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: bodyColor,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Alimentación, recuperación y adherencia del día en un solo bloque.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: mutedColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _SummaryChip(
                  icon: Icons.restaurant_outlined,
                  label: '$mealsLogged comidas registradas',
                  color: bodyColor,
                  background: subtleSurface,
                ),
                _SummaryChip(
                  icon: Icons.local_fire_department_outlined,
                  label: '${totalKcalBurned.toInt()} quemadas',
                  color: bodyColor,
                  background: subtleSurface,
                ),
                _SummaryChip(
                  icon: Icons.fitness_center_outlined,
                  label: '$sessionsLogged sesiones',
                  color: bodyColor,
                  background: subtleSurface,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 280, maxWidth: 420),
                  child: SegmentedButton<UserWeightGoalEntity>(
                    showSelectedIcon: false,
                    segments: UserWeightGoalEntity.values
                        .map((phase) => ButtonSegment<UserWeightGoalEntity>(
                              value: phase,
                              label: Text(phase.gymPhaseLabel),
                            ))
                        .toList(),
                    selected: {nutritionPhase},
                    onSelectionChanged: (selection) {
                      onNutritionPhaseChanged(selection.first);
                    },
                    style: _segmentedStyle(colorScheme),
                  ),
                ),
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 280, maxWidth: 420),
                  child: SegmentedButton<DailyFocusEntity>(
                    showSelectedIcon: false,
                    segments: DailyFocusEntity.values
                        .map((focus) => ButtonSegment<DailyFocusEntity>(
                              value: focus,
                              label: Text(focus.label),
                            ))
                        .toList(),
                    selected: {dailyFocus},
                    onSelectionChanged: (selection) {
                      onDailyFocusChanged(selection.first);
                    },
                    style: _segmentedStyle(colorScheme),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              nutritionPhase.gymHeadline,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: bodyColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              dailyFocus.headline,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: mutedColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${nutritionPhase.macroHint} ${dailyFocus.macroHint}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                  ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PrimaryMetric(
                    label: 'Proteína restante',
                    value: proteinRemaining.toInt(),
                    suffix: 'g',
                    textColor: bodyColor,
                    background: colorScheme.primary.withValues(alpha: 0.14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PrimaryMetric(
                    label: totalKcalLeft >= 0
                        ? 'Kcal restantes'
                        : 'Sobre objetivo',
                    value: totalKcalLeft.abs().toInt(),
                    suffix: 'kcal',
                    textColor: bodyColor,
                    background: totalKcalLeft >= 0
                        ? colorScheme.tertiary.withValues(alpha: 0.14)
                        : colorScheme.error.withValues(alpha: 0.14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: kcalProgress,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${totalKcalSupplied.toInt()} de ${totalKcalDaily.toInt()} kcal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                  ),
            ),
            const SizedBox(height: 18),
            _MacroTrackRow(
              label: 'Proteína',
              intake: totalProteinsIntake,
              goal: totalProteinsGoal,
              remaining: proteinRemaining,
              color: colorScheme.primary,
              emphasis: true,
            ),
            const SizedBox(height: 12),
            _MacroTrackRow(
              label: 'Carbohidratos',
              intake: totalCarbsIntake,
              goal: totalCarbsGoal,
              remaining: carbsRemaining,
              color: colorScheme.tertiary,
            ),
            const SizedBox(height: 12),
            _MacroTrackRow(
              label: 'Grasa',
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
                  color: colorScheme.outlineVariant.withValues(alpha: 0.34),
                ),
              ),
              child: Text(
                _buildStatusCopy(
                  dailyFocus: dailyFocus,
                  nutritionPhase: nutritionPhase,
                  proteinRemaining: proteinRemaining,
                  carbsRemaining: carbsRemaining,
                  kcalRemaining: totalKcalLeft,
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: bodyColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildStatusCopy({
    required DailyFocusEntity dailyFocus,
    required UserWeightGoalEntity nutritionPhase,
    required double proteinRemaining,
    required double carbsRemaining,
    required double kcalRemaining,
  }) {
    if (nutritionPhase == UserWeightGoalEntity.loseWeight &&
        kcalRemaining < 200 &&
        kcalRemaining >= 0) {
      return 'La definición va en ritmo. Mantén la última comida alta en proteína y limpia.';
    }
    if (nutritionPhase == UserWeightGoalEntity.gainWeight &&
        kcalRemaining >= 450) {
      return 'Aún tienes margen en volumen. Mete carbohidrato fácil y proteína.';
    }
    if (proteinRemaining >= 30) {
      return 'La proteína sigue siendo la principal brecha. Prioriza proteína en la siguiente comida.';
    }
    if (dailyFocus == DailyFocusEntity.lowerBody && carbsRemaining >= 45) {
      return 'Aún tienes margen de carbohidratos. Buen momento para pre o post entreno.';
    }
    if (dailyFocus == DailyFocusEntity.rest && kcalRemaining < 150) {
      return 'El día de descanso está casi en objetivo. Cierra con comida ligera y limpia.';
    }
    if (kcalRemaining < 0) {
      return 'Estás por encima del objetivo. Mantén el resto del día controlado y con proteína alta.';
    }
    return 'Buen ritmo. Mantén consistencia y cierra el día de forma limpia.';
  }

  double _positiveRemaining(double value) {
    if (value <= 0) {
      return 0;
    }
    return value;
  }

  ButtonStyle _segmentedStyle(ColorScheme colorScheme) {
    return ButtonStyle(
      visualDensity: VisualDensity.compact,
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
        return colorScheme.surfaceContainerHighest.withValues(alpha: 0.75);
      }),
    );
  }
}

class _PrimaryMetric extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final Color textColor;
  final Color background;

  const _PrimaryMetric({
    required this.label,
    required this.value,
    required this.suffix,
    required this.textColor,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor.withValues(alpha: 0.72),
                ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedFlipCounter(
                duration: const Duration(milliseconds: 700),
                value: value,
                textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  suffix,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor.withValues(alpha: 0.72),
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
  final Color color;
  final Color background;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
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
          Icon(icon, size: 14, color: color.withValues(alpha: 0.85)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color.withValues(alpha: 0.82),
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
              ? '${remaining.toInt()} g restantes'
              : 'Objetivo cumplido',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
