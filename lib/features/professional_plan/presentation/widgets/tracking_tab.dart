import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_section_entities.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_ui_helpers.dart';
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
    final weekPercent = summary.week.kcalTarget <= 0
        ? 0
        : ((summary.week.kcalActual / summary.week.kcalTarget).clamp(0, 1) *
                100)
            .round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                eyebrow: S.of(context).professionalTrackingWeeklyEyebrow,
                title: S.of(context).professionalTrackingWeekTitle,
                subtitle: S.of(context).professionalTrackingWeeklySubtitle,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  CompactStat(
                    label: S.of(context).professionalTrackingWeekKcal,
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
              const SizedBox(height: 24),
              _CalorieAdherenceBarChart(summary: summary),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              _WeeklyMacrosRow(
                proteinActual: summary.week.proteinActual,
                proteinTarget: summary.week.proteinTarget,
                carbsActual: summary.week.carbsActual,
                carbsTarget: summary.week.carbsTarget,
                fatActual: summary.week.fatActual,
                fatTarget: summary.week.fatTarget,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyMacrosRow extends StatelessWidget {
  final double proteinActual;
  final double proteinTarget;
  final double carbsActual;
  final double carbsTarget;
  final double fatActual;
  final double fatTarget;

  const _WeeklyMacrosRow({
    required this.proteinActual,
    required this.proteinTarget,
    required this.carbsActual,
    required this.carbsTarget,
    required this.fatActual,
    required this.fatTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _WeeklyMacroRingItem(
            label: S.of(context).professionalMacroProtein,
            actual: proteinActual,
            target: proteinTarget,
            color: const Color(0xFF10B981), // Emerald Green
            unit: 'g',
          ),
        ),
        Expanded(
          child: _WeeklyMacroRingItem(
            label: S.of(context).professionalMacroCarbs,
            actual: carbsActual,
            target: carbsTarget,
            color: const Color(0xFFE7A83B), // Amber/Orange
            unit: 'g',
          ),
        ),
        Expanded(
          child: _WeeklyMacroRingItem(
            label: S.of(context).professionalMacroFat,
            actual: fatActual,
            target: fatTarget,
            color: const Color(0xFF3B82F6), // Blue
            unit: 'g',
          ),
        ),
      ],
    );
  }
}

class _WeeklyMacroRingItem extends StatelessWidget {
  final String label;
  final double actual;
  final double target;
  final Color color;
  final String unit;

  const _WeeklyMacroRingItem({
    required this.label,
    required this.actual,
    required this.target,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = target <= 0 ? 0.0 : (actual / target).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: 32.0,
          lineWidth: 6.0,
          animation: true,
          percent: percent,
          center: Text(
            '${(percent * 100).round()}%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                ),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: color,
          backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          '${actual.round()}$unit / ${target.round()}$unit',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 9,
              ),
        ),
      ],
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
  State<_CalorieAdherenceBarChart> createState() =>
      _CalorieAdherenceBarChartState();
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
    switch (weekday) {
      case 1:
        return S.of(context).professionalWeekdayMonday;
      case 2:
        return S.of(context).professionalWeekdayTuesday;
      case 3:
        return S.of(context).professionalWeekdayWednesday;
      case 4:
        return S.of(context).professionalWeekdayThursday;
      case 5:
        return S.of(context).professionalWeekdayFriday;
      case 6:
        return S.of(context).professionalWeekdaySaturday;
      case 7:
        return S.of(context).professionalWeekdaySunday;
      default:
        return '';
    }
  }

  String _weekdayInitial(BuildContext context, int weekday) {
    switch (weekday) {
      case 1:
        return S.of(context).professionalWeekdayInitialMonday;
      case 2:
        return S.of(context).professionalWeekdayInitialTuesday;
      case 3:
        return S.of(context).professionalWeekdayInitialWednesday;
      case 4:
        return S.of(context).professionalWeekdayInitialThursday;
      case 5:
        return S.of(context).professionalWeekdayInitialFriday;
      case 6:
        return S.of(context).professionalWeekdayInitialSaturday;
      case 7:
        return S.of(context).professionalWeekdayInitialSunday;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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

    final weekPercent = widget.summary.week.kcalTarget <= 0
        ? 0
        : ((widget.summary.week.kcalActual / widget.summary.week.kcalTarget).clamp(0, 1) *
                100)
            .round();
    String detailText = S.of(context).professionalTrackingWeeklyTotal(
          widget.summary.week.kcalActual.round(),
          widget.summary.week.kcalTarget.round(),
          weekPercent,
        );
    if (_selectedBarIndex >= 0 && _selectedBarIndex < dailyData.length) {
      final selected = dailyData[_selectedBarIndex];
      final day = selected['day'] as NutritionPlanResolvedDayEntity;
      final actual = selected['actual'] as double;
      final target = selected['target'] as double;

      final dayName = _weekdayName(context, day.effectiveDate.weekday);
      final pct = target <= 0 ? 0 : ((actual / target) * 100).round();
      detailText =
          '$dayName: ${actual.round()} kcal / ${target.round()} kcal ($pct%)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colorScheme.surfaceContainerLow,
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
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
          const SizedBox(height: 24),
          Stack(
            children: [
              // Background Gridlines
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                height: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (index) {
                    return Container(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.12),
                    );
                  }),
                ),
              ),
              // Chart Columns Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(dailyData.length, (index) {
                    final item = dailyData[index];
                    final day = item['day'] as NutritionPlanResolvedDayEntity;
                    final actual = item['actual'] as double;
                    final target = item['target'] as double;

                    final isSelected = _selectedBarIndex == index;
                    final isToday = day.isToday;

                    // Bar heights mapping to 110 pixels maximum
                    final actualHeight = max(4.0, (actual / maxCal) * 110);
                    final targetHeight = max(4.0, (target / maxCal) * 110);
                    final isExceeded = actual > target && target > 0;
                    const barWidth = 16.0;

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
                              width: 38,
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  // 1. Target capsule background
                                  Container(
                                    height: targetHeight,
                                    width: barWidth,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  // 2. Actual progress filled bar
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: min(actualHeight, targetHeight),
                                    width: barWidth,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  // 3. Exceeded overflow bar (red)
                                  if (isExceeded)
                                    Positioned(
                                      bottom: targetHeight - 2,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        height: actualHeight - targetHeight + 2,
                                        width: barWidth,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                        ),
                                      ),
                                    ),
                                  // 4. Target limit line marker
                                  Positioned(
                                    bottom: targetHeight - 1,
                                    child: Container(
                                      width: barWidth + 4,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                  // 5. Highlight selection indicator border
                                  if (isSelected)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: colorScheme.primary.withValues(alpha: 0.3),
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: isToday
                                    ? colorScheme.primary
                                    : isSelected
                                        ? colorScheme.primary.withValues(alpha: 0.15)
                                        : Colors.transparent,
                              ),
                              child: Text(
                                _weekdayInitial(context, day.effectiveDate.weekday),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isToday
                                          ? colorScheme.onPrimary
                                          : isSelected
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                label: S.of(context).professionalTrackingConsumed,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 20),
              _LegendItem(
                label: S.of(context).professionalTrackingPlanTarget,
                color: colorScheme.outlineVariant.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 20),
              _LegendItem(
                label: S.of(context).professionalTrackingExceeded,
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
        ],
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
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
