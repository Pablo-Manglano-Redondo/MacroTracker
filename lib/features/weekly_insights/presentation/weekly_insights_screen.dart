import 'package:flutter/material.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/weekly_insights/domain/entity/weekly_insights_entity.dart';
import 'package:macrotracker/features/weekly_insights/domain/usecase/build_weekly_insights_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';

class WeeklyInsightsScreenArguments {
  final DateTime focusedDate;

  WeeklyInsightsScreenArguments(this.focusedDate);
}

class WeeklyInsightsScreen extends StatefulWidget {
  const WeeklyInsightsScreen({super.key});

  @override
  State<WeeklyInsightsScreen> createState() => _WeeklyInsightsScreenState();
}

class _WeeklyInsightsScreenState extends State<WeeklyInsightsScreen> {
  late Future<WeeklyInsightsEntity> _insightsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as WeeklyInsightsScreenArguments;
    _insightsFuture = locator<BuildWeeklyInsightsUsecase>().build(args.focusedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).weeklyInsightsTitle),
      ),
      body: FutureBuilder<WeeklyInsightsEntity>(
        future: _insightsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(S.of(context).weeklyInsightsError));
          }
          final insights = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _InfoCard(
                  title: S.of(context).weeklyInsightsSummary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).weeklyInsightsTrend(
                              '${insights.weeklyWeightDeltaKg >= 0 ? '+' : ''}${insights.weeklyWeightDeltaKg.toStringAsFixed(2)}',
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(insights.kcalAdjustmentRecommendation),
                      const SizedBox(height: 10),
                      if (insights.recommendedKcalAdjustmentDelta != 0)
                        FilledButton.icon(
                          onPressed: () =>
                              _applyRecommendedAdjustment(context, insights),
                          icon: const Icon(Icons.auto_fix_high_outlined),
                          label: Text(
                            S.of(context).weeklyInsightsApplyAdjustment(
                                  '${insights.recommendedKcalAdjustmentDelta > 0 ? '+' : ''}${insights.recommendedKcalAdjustmentDelta}',
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
                _InfoCard(
                  title: S.of(context).weeklyInsightsAverages,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${insights.averageCalories.toStringAsFixed(0)} kcal / ${S.of(context).dayLabel.toLowerCase()}'),
                      Text(
                          '${S.of(context).carbohydrateLabel} ${insights.averageCarbs.toStringAsFixed(1)} g'),
                      Text('${S.of(context).fatLabel} ${insights.averageFat.toStringAsFixed(1)} g'),
                      Text(
                          '${S.of(context).proteinLabel} ${insights.averageProtein.toStringAsFixed(1)} g'),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        title: S.of(context).weeklyInsightsAdherence,
                        child: Text(S.of(context).weeklyInsightsRegisteredDays(
                            (insights.goalAdherenceRate * 100).round())),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: _InfoCard(
                        title: S.of(context).weeklyInsightsProteinConsistency,
                        child: Text(S.of(context).weeklyInsightsRegisteredDays(
                            (insights.proteinConsistencyRate * 100).round())),
                      ),
                    ),
                  ],
                ),
                _InfoCard(
                  title: S.of(context).weeklyInsightsTopMeals,
                  child: insights.topMeals.isEmpty
                      ? Text(S.of(context).weeklyInsightsNoFrequentMeals)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: insights.topMeals
                              .map((meal) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text('• ${meal.label} (${meal.count})'),
                                  ))
                              .toList(),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _applyRecommendedAdjustment(
      BuildContext context, WeeklyInsightsEntity insights) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).weeklyInsightsAdjustmentSuccess(
            insights.recommendedKcalAdjustmentDelta.toString())),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12.0),
            child,
          ],
        ),
      ),
    );
  }
}
