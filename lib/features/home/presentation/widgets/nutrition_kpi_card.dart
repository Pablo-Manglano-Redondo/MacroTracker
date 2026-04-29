import 'package:flutter/material.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/weekly_insights/domain/entity/weekly_insights_entity.dart';
import 'package:macrotracker/features/weekly_insights/domain/usecase/build_weekly_insights_usecase.dart';

class NutritionKpiCard extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const NutritionKpiCard({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<WeeklyInsightsEntity>(
            future: locator<BuildWeeklyInsightsUsecase>().build(DateTime.now()),
            builder: (context, snapshot) {
              if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError || snapshot.data == null) {
                return const Text(
                  'KPI nutricionales no disponibles ahora mismo.',
                );
              }

              final kpi = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: colorScheme.primary.withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          Icons.query_stats_outlined,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rendimiento nutricional',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Chequeo semanal en 10 segundos',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _KpiStatTile(
                    label: 'Adherencia kcal',
                    value: '${(kpi.goalAdherenceRate * 100).round()}%',
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  _KpiStatTile(
                    label: 'Proteína media',
                    value: '${kpi.averageProtein.toStringAsFixed(0)} g/día',
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(height: 10),
                  _KpiStatTile(
                    label: 'Consistencia proteica',
                    value: '${(kpi.proteinConsistencyRate * 100).round()}%',
                    color: const Color(0xFFE7A83B),
                  ),
                  const SizedBox(height: 10),
                  _KpiStatTile(
                    label: 'Días registrados',
                    value: '${kpi.trackedDays}/7',
                    color: colorScheme.secondary,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _KpiStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KpiStatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.08),
        border: Border.all(
          color: color.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
