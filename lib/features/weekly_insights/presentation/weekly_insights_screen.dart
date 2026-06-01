import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/weekly_insights/domain/entity/weekly_insights_entity.dart';
import 'package:macrotracker/features/weekly_insights/domain/usecase/apply_weekly_kcal_adjustment_usecase.dart';
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
  WeeklyInsightsScreenArguments? _args;
  bool _isApplyingAdjustment = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args ??= ModalRoute.of(context)!.settings.arguments
        as WeeklyInsightsScreenArguments;
    _insightsFuture =
        locator<BuildWeeklyInsightsUsecase>().build(_args!.focusedDate);
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
          final locale = Localizations.localeOf(context).toLanguageTag();
          final weekStart = DateFormat.MMMd(locale).format(insights.weekStart);
          final weekEnd = DateFormat.MMMd(locale).format(insights.weekEnd);

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
                        '$weekStart - $weekEnd',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(insights.summaryLabel),
                      const SizedBox(height: 10),
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
                          onPressed: _isApplyingAdjustment
                              ? null
                              : () => _applyRecommendedAdjustment(
                                    context,
                                    insights,
                                  ),
                          icon: const Icon(Icons.auto_fix_high_outlined),
                          label: _isApplyingAdjustment
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
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
                        '${insights.averageCalories.toStringAsFixed(0)} kcal / ${S.of(context).dayLabel.toLowerCase()}',
                      ),
                      Text(
                        '${S.of(context).carbohydrateLabel} ${insights.averageCarbs.toStringAsFixed(1)} g',
                      ),
                      Text(
                        '${S.of(context).fatLabel} ${insights.averageFat.toStringAsFixed(1)} g',
                      ),
                      Text(
                        '${S.of(context).proteinLabel} ${insights.averageProtein.toStringAsFixed(1)} g',
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        title: S.of(context).weeklyInsightsCoverage,
                        child: Text(
                          S
                              .of(context)
                              .weeklyInsightsTrackedDays(insights.trackedDays),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: _InfoCard(
                        title: S.of(context).weeklyInsightsOvereatingPattern,
                        child: Text(insights.overeatingTimeSlotLabel),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        title: S.of(context).weeklyInsightsAdherence,
                        child: Text(
                          S.of(context).weeklyInsightsRegisteredDays(
                                (insights.goalAdherenceRate * 100).round(),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: _InfoCard(
                        title: S.of(context).weeklyInsightsProteinConsistency,
                        child: Text(
                          S.of(context).weeklyInsightsRegisteredDays(
                                (insights.proteinConsistencyRate * 100).round(),
                              ),
                        ),
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
                              .map(
                                (meal) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    '- ${meal.label} (${meal.count})',
                                  ),
                                ),
                              )
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

  Future<void> _applyRecommendedAdjustment(
    BuildContext context,
    WeeklyInsightsEntity insights,
  ) async {
    setState(() {
      _isApplyingAdjustment = true;
    });

    try {
      final updatedAdjustment =
          await locator<ApplyWeeklyKcalAdjustmentUsecase>().apply(
        day: DateTime.now(),
        deltaKcal: insights.recommendedKcalAdjustmentDelta,
      );

      locator<HomeBloc>().add(const LoadItemsEvent());
      locator<DiaryBloc>().add(const LoadDiaryYearEvent());
      locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

      if (!context.mounted) {
        return;
      }

      _reloadInsights();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).weeklyInsightsAdjustmentSuccess(
                  updatedAdjustment.toStringAsFixed(0),
                ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingAdjustment = false;
        });
      }
    }
  }

  void _reloadInsights() {
    final args = _args;
    if (args == null) {
      return;
    }

    setState(() {
      _insightsFuture =
          locator<BuildWeeklyInsightsUsecase>().build(args.focusedDate);
    });
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
