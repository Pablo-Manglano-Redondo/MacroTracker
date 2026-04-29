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
                        'Nutrición de gimnasio',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: bodyColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: isCompact ? 22 : null,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Alimentación, recuperación y adherencia del día en un solo bloque.',
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
                  value: mealsLogged.toString(),
                  label: 'comidas',
                  compact: isCompact,
                  color: bodyColor,
                  background: subtleSurface,
                ),
                _SummaryChip(
                  icon: Icons.local_fire_department_outlined,
                  value: totalKcalBurned.toInt().toString(),
                  label: 'kcal quemadas',
                  compact: isCompact,
                  color: bodyColor,
                  background: subtleSurface,
                ),
                _SummaryChip(
                  icon: Icons.fitness_center_outlined,
                  value: sessionsLogged.toString(),
                  label: 'sesiones',
                  compact: isCompact,
                  color: bodyColor,
                  background: subtleSurface,
                ),
              ],
            ),
            if (mealsLogged == 0 && sessionsLogged == 0) ...[
              const SizedBox(height: 10),
              Text(
                'Empieza el día registrando una comida o una sesión para activar recomendaciones más precisas.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                    ),
              ),
            ],
            const SizedBox(height: 18),
            _SelectorBlock<UserWeightGoalEntity>(
              caption: 'Objetivo',
              colorScheme: colorScheme,
              compact: isCompact,
              selected: {nutritionPhase},
              segments: UserWeightGoalEntity.values
                  .map((phase) => ButtonSegment<UserWeightGoalEntity>(
                        value: phase,
                        label: Text(
                          phase.gymPhaseLabel,
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
              caption: 'Enfoque',
              colorScheme: colorScheme,
              compact: isCompact,
              selected: {dailyFocus},
              segments: DailyFocusEntity.values
                  .map((focus) => ButtonSegment<DailyFocusEntity>(
                        value: focus,
                        label: Text(
                          focus.label,
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
              nutritionPhase.gymHeadline,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: bodyColor,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    fontSize: isCompact ? 26 : null,
                  ),
            ),
            const SizedBox(height: 7),
            Text(
              dailyFocus.headline,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 5),
            Text(
              '${nutritionPhase.macroHint} ${dailyFocus.macroHint}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 18),
            if (isCompact) ...[
              _PrimaryMetric(
                label: 'Proteína restante',
                value: proteinRemaining.toInt(),
                suffix: 'g',
                textColor: bodyColor,
                accentColor: colorScheme.primary,
                background: colorScheme.primary.withValues(alpha: 0.14),
                compact: true,
              ),
              const SizedBox(height: 10),
              _PrimaryMetric(
                label: totalKcalLeft >= 0 ? 'Kcal restantes' : 'Sobre objetivo',
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
                      label: 'Proteína restante',
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
                          ? 'Kcal restantes'
                          : 'Sobre objetivo',
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
              '${totalKcalSupplied.toInt()} de ${totalKcalDaily.toInt()} kcal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
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
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 6,
                  children: [
                    AnimatedFlipCounter(
                      duration: const Duration(milliseconds: 700),
                      value: value,
                      textStyle:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w800,
                                fontSize: compact ? 28 : null,
                              ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        suffix,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textColor.withValues(alpha: 0.72),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
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
  final String value;
  final String label;
  final bool compact;
  final Color color;
  final Color background;

  const _SummaryChip({
    required this.icon,
    required this.value,
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
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color.withValues(alpha: 0.90),
                ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color.withValues(alpha: 0.75),
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
