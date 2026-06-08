import 'package:flutter/material.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/nutrition_plan_entity.dart';
import 'dart:math';

class TrackingTab extends StatelessWidget {
  final ProfessionalSectionSummaryEntity summary;

  const TrackingTab({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final todayPercent = (summary.today.kcalAdherence * 100).round();
    final weekPercent = summary.week.kcalTarget <= 0
        ? 0
        : ((summary.week.kcalActual / summary.week.kcalTarget).clamp(0, 1) * 100)
            .round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          accent: Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.10),
            colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: uiText(context, es: 'Seguimiento diario', en: 'Daily follow-up'),
                title: S.of(context).professionalTrackingTodayTitle,
                subtitle: uiText(
                  context,
                  es: 'Lectura rápida de adherencia para que sepas cómo va el día frente al plan.',
                  en: 'Quick adherence read so you know how the day is going against the plan.',
                ),
              ),
              const SizedBox(height: 14),
              _TrackingScoreCard(
                label: 'Kcal',
                actual: summary.today.kcalActual,
                target: summary.today.kcalTarget,
                adherence: summary.today.kcalAdherence,
              ),
              const SizedBox(height: 12),
              _TrackingFactsRow(
                leftLabel: S.of(context).professionalTrackingMealsLogged,
                leftValue: summary.today.mealsLogged.toString(),
                rightLabel: S.of(context).professionalTrackingTrackedDays,
                rightValue: summary.today.trackedDays.toString(),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  StatusPill(
                    icon: Icons.bolt_outlined,
                    label: uiText(
                      context,
                      es: '$todayPercent% del objetivo kcal hoy',
                      en: '$todayPercent% of today kcal target',
                    ),
                  ),
                  StatusPill(
                    icon: Icons.event_note_outlined,
                    label: uiText(
                      context,
                      es: '${summary.today.mealsLogged} comidas registradas',
                      en: '${summary.today.mealsLogged} meals logged',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _CalorieAdherenceBarChart(summary: summary),
        const SizedBox(height: 16),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: uiText(context, es: 'Perspectiva semanal', en: 'Weekly perspective'),
                title: S.of(context).professionalTrackingWeekTitle,
                subtitle: uiText(
                  context,
                  es: 'Aquí ves si la semana mantiene dirección, no solo si un día salió perfecto.',
                  en: 'This shows whether the week keeps its direction, not only whether a single day was perfect.',
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  CompactStat(
                    label: uiText(context, es: 'Semana kcal', en: 'Week kcal'),
                    value: '$weekPercent%',
                  ),
                  CompactStat(
                    label: S.of(context).professionalTrackingFollowUpDays,
                    value: summary.week.trackedDays.toString(),
                  ),
                  CompactStat(
                    label: S.of(context).professionalTrackingMealsLogged,
                    value: summary.week.mealsLogged.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ProgressSummaryRow(
                label: 'Kcal',
                actual: summary.week.kcalActual,
                target: summary.week.kcalTarget,
              ),
              const SizedBox(height: 10),
              _ProgressSummaryRow(
                label: S.of(context).professionalMacroProtein,
                actual: summary.week.proteinActual,
                target: summary.week.proteinTarget,
                unit: 'g',
              ),
              const SizedBox(height: 10),
              _ProgressSummaryRow(
                label: S.of(context).professionalMacroCarbs,
                actual: summary.week.carbsActual,
                target: summary.week.carbsTarget,
                unit: 'g',
              ),
              const SizedBox(height: 10),
              _ProgressSummaryRow(
                label: S.of(context).professionalMacroFat,
                actual: summary.week.fatActual,
                target: summary.week.fatTarget,
                unit: 'g',
              ),
              const SizedBox(height: 12),
              _TrackingFactsRow(
                leftLabel: S.of(context).professionalTrackingMealsLogged,
                leftValue: summary.week.mealsLogged.toString(),
                rightLabel: S.of(context).professionalTrackingFollowUpDays,
                rightValue: summary.week.trackedDays.toString(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrackingScoreCard extends StatelessWidget {
  final String label;
  final double actual;
  final double target;
  final double adherence;

  const _TrackingScoreCard({
    required this.label,
    required this.actual,
    required this.target,
    required this.adherence,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (adherence * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$label ${actual.round()} / ${target.round()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              StatusPill(
                icon: Icons.insights_outlined,
                label: '$percent%',
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: adherence,
              minHeight: 9,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).professionalTrackingEstimatedAdherence(percent),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _TrackingFactsRow extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  const _TrackingFactsRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _FactTile(label: leftLabel, value: leftValue)),
        const SizedBox(width: 10),
        Expanded(child: _FactTile(label: rightLabel, value: rightValue)),
      ],
    );
  }
}

class _FactTile extends StatelessWidget {
  final String label;
  final String value;

  const _FactTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSummaryRow extends StatelessWidget {
  final String label;
  final double actual;
  final double target;
  final String unit;

  const _ProgressSummaryRow({
    required this.label,
    required this.actual,
    required this.target,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = target <= 0 ? 0.0 : (actual / target).clamp(0, 1).toDouble();
    final suffix = unit.isEmpty ? '' : unit;
    final delta = (actual - target).round();
    final deltaLabel = delta == 0
        ? uiText(context, es: 'En objetivo', en: 'On target')
        : delta > 0
            ? uiText(context, es: '+$delta$suffix vs objetivo', en: '+$delta$suffix vs target')
            : uiText(context, es: '$delta$suffix vs objetivo', en: '$delta$suffix vs target');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Text(
                '${actual.round()}$suffix / ${target.round()}$suffix',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            deltaLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Calorie Adherence Bar Chart Widgets
// -------------------------------------------------------------

class _CalorieAdherenceBarChart extends StatefulWidget {
  final ProfessionalSectionSummaryEntity summary;

  const _CalorieAdherenceBarChart({required this.summary});

  @override
  State<_CalorieAdherenceBarChart> createState() => _CalorieAdherenceBarChartState();
}

class _CalorieAdherenceBarChartState extends State<_CalorieAdherenceBarChart> {
  int _selectedBarIndex = -1;

  @override
  void initState() {
    super.initState();
    final weekPlan = widget.summary.weekPlan;
    for (int i = 0; i < weekPlan.length; i++) {
      if (weekPlan[i].isToday) {
        _selectedBarIndex = i;
        break;
      }
    }
  }

  String _dateKey(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  String _weekdayName(BuildContext context, int weekday) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    switch (weekday) {
      case 1: return isEs ? 'Lunes' : 'Monday';
      case 2: return isEs ? 'Martes' : 'Tuesday';
      case 3: return isEs ? 'Miércoles' : 'Wednesday';
      case 4: return isEs ? 'Jueves' : 'Thursday';
      case 5: return isEs ? 'Viernes' : 'Friday';
      case 6: return isEs ? 'Sábado' : 'Saturday';
      case 7: return isEs ? 'Domingo' : 'Sunday';
      default: return '';
    }
  }

  String _weekdayInitial(BuildContext context, int weekday) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    switch (weekday) {
      case 1: return 'L';
      case 2: return 'M';
      case 3: return isEs ? 'X' : 'W';
      case 4: return 'J';
      case 5: return 'V';
      case 6: return 'S';
      case 7: return 'D';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final weekPlan = widget.summary.weekPlan;
    final weekTrackedDays = widget.summary.weekTrackedDays;

    if (weekPlan.isEmpty) {
      return const SizedBox.shrink();
    }

    final dailyData = <Map<String, dynamic>>[];
    double maxCal = 1500.0;

    for (final day in weekPlan) {
      final target = day.target?.kcalGoal ?? 0.0;
      double actual = 0.0;
      for (final td in weekTrackedDays) {
        if (_dateKey(td.day) == _dateKey(day.effectiveDate)) {
          actual = td.caloriesTracked;
          break;
        }
      }

      if (target > maxCal) maxCal = target;
      if (actual > maxCal) maxCal = actual;

      dailyData.add({
        'day': day,
        'actual': actual,
        'target': target,
      });
    }

    maxCal = maxCal * 1.1;

    String detailText = isEs ? 'Toca una columna para ver detalle' : 'Tap a column to view detail';
    if (_selectedBarIndex >= 0 && _selectedBarIndex < dailyData.length) {
      final selected = dailyData[_selectedBarIndex];
      final day = selected['day'] as NutritionPlanResolvedDayEntity;
      final actual = selected['actual'] as double;
      final target = selected['target'] as double;
      
      final dayName = _weekdayName(context, day.effectiveDate.weekday);
      final pct = target <= 0 ? 0 : ((actual / target) * 100).round();
      detailText = isEs
          ? '$dayName: ${actual.round()} kcal / ${target.round()} kcal ($pct%)'
          : '$dayName: ${actual.round()} kcal / ${target.round()} kcal ($pct%)';
    }

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: isEs ? 'Historial de adherencia' : 'Adherence History',
            title: isEs ? 'Consumo vs Objetivo Semanal' : 'Weekly Calories vs Target',
            subtitle: isEs
                ? 'Comparativa visual diaria de calorías consumidas frente al objetivo propuesto.'
                : 'Daily visual comparison of calories consumed vs nutritionist targets.',
          ),
          const SizedBox(height: 12),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    detailText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(dailyData.length, (index) {
              final item = dailyData[index];
              final day = item['day'] as NutritionPlanResolvedDayEntity;
              final actual = item['actual'] as double;
              final target = item['target'] as double;
              
              final isSelected = _selectedBarIndex == index;
              final isToday = day.isToday;

              final actualHeight = max(4.0, (actual / maxCal) * 110);
              final targetHeight = max(4.0, (target / maxCal) * 110);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBarIndex = index;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Opacity(
                  opacity: (_selectedBarIndex == -1 || isSelected) ? 1.0 : 0.55,
                  child: Column(
                    children: [
                      Container(
                        height: 120,
                        width: 40,
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 10,
                              height: actualHeight,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 10,
                              height: targetHeight,
                              decoration: BoxDecoration(
                                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday
                              ? colorScheme.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                        ),
                        child: Text(
                          _weekdayInitial(context, day.effectiveDate.weekday),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(label: isEs ? 'Consumido' : 'Consumed', color: colorScheme.primary),
              const SizedBox(width: 20),
              _LegendItem(label: isEs ? 'Objetivo Plan' : 'Plan Target', color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
