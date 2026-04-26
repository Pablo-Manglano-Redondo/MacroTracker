import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/weekly_insights/domain/entity/weekly_insights_entity.dart';
import 'package:macrotracker/features/weekly_insights/domain/usecase/build_weekly_insights_usecase.dart';

class WeeklyInsightsScreen extends StatelessWidget {
  const WeeklyInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments
        as WeeklyInsightsScreenArguments?;
    final focusedWeek = args?.focusedWeek ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly insights')),
      body: FutureBuilder<WeeklyInsightsEntity>(
        future: locator<BuildWeeklyInsightsUsecase>().build(focusedWeek),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Weekly insights could not be loaded.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final insights = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                '${DateFormat.MMMd().format(insights.weekStart)} - ${DateFormat.MMMd().format(insights.weekEnd)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12.0),
              _InfoCard(
                title: 'Summary',
                child: Text(insights.summaryLabel),
              ),
              _InfoCard(
                title: 'Weekly averages',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${insights.averageCalories.toStringAsFixed(0)} kcal / day'),
                    Text('Carbs ${insights.averageCarbs.toStringAsFixed(1)} g'),
                    Text('Fat ${insights.averageFat.toStringAsFixed(1)} g'),
                    Text('Protein ${insights.averageProtein.toStringAsFixed(1)} g'),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      title: 'Adherence',
                      child: Text(
                          '${(insights.goalAdherenceRate * 100).round()}% of tracked days'),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _InfoCard(
                      title: 'Protein consistency',
                      child: Text(
                          '${(insights.proteinConsistencyRate * 100).round()}% of tracked days'),
                    ),
                  ),
                ],
              ),
              _InfoCard(
                title: 'Most frequent meals',
                child: insights.topMeals.isEmpty
                    ? const Text('No repeated meals detected this week.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: insights.topMeals
                            .map((meal) => Text('${meal.label} (${meal.count}x)'))
                            .toList(),
                      ),
              ),
              _InfoCard(
                title: 'Overeating pattern',
                child: Text(insights.overeatingTimeSlotLabel),
              ),
              _InfoCard(
                title: 'Coverage',
                child: Text('${insights.trackedDays} tracked days this week'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class WeeklyInsightsScreenArguments {
  final DateTime focusedWeek;

  WeeklyInsightsScreenArguments(this.focusedWeek);
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8.0),
            child,
          ],
        ),
      ),
    );
  }
}
