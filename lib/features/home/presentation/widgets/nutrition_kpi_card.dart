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
    return Padding(
      padding: padding,
      child: Card(
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<WeeklyInsightsEntity>(
            future: locator<BuildWeeklyInsightsUsecase>().build(DateTime.now()),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError || snapshot.data == null) {
                return const Text('Nutrition KPI unavailable right now.');
              }
              final kpi = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nutrition performance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '10-second weekly checkpoint',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  _kpiRow(
                    context,
                    'Kcal adherence',
                    '${(kpi.goalAdherenceRate * 100).round()}%',
                  ),
                  _kpiRow(
                    context,
                    'Avg protein',
                    '${kpi.averageProtein.toStringAsFixed(0)} g/day',
                  ),
                  _kpiRow(
                    context,
                    'Protein consistency',
                    '${(kpi.proteinConsistencyRate * 100).round()}%',
                  ),
                  _kpiRow(
                    context,
                    'Tracked days',
                    '${kpi.trackedDays}/7',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _kpiRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
