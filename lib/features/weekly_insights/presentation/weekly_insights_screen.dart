import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/core/presentation/widgets/paywall_sheet.dart';
import 'package:macrotracker/core/services/conversion_analytics_service.dart';
import 'package:macrotracker/core/services/monetization_service.dart';
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
  late Future<_WeeklyInsightsViewState> _viewStateFuture;
  WeeklyInsightsScreenArguments? _args;
  bool _isApplyingAdjustment = false;
  bool _loggedView = false;
  bool _loggedLockedAdjustment = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args != null) {
      return;
    }
    _args = ModalRoute.of(context)!.settings.arguments
        as WeeklyInsightsScreenArguments;
    _viewStateFuture = _loadViewState(_args!.focusedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).weeklyInsightsTitle),
      ),
      body: FutureBuilder<_WeeklyInsightsViewState>(
        future: _viewStateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(S.of(context).weeklyInsightsError));
          }

          final viewState = snapshot.data!;
          final insights = viewState.insights;
          final isPremium = viewState.aiTrialState.isPremium;
          _logViewed(insights, isPremium);
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
                      _buildAdjustmentSection(
                        context,
                        insights,
                        isPremium: isPremium,
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

  Future<_WeeklyInsightsViewState> _loadViewState(DateTime focusedDate) async {
    final insightsFuture =
        locator<BuildWeeklyInsightsUsecase>().build(focusedDate);
    final trialStateFuture = locator<MonetizationService>().getAiTrialState();
    return _WeeklyInsightsViewState(
      insights: await insightsFuture,
      aiTrialState: await trialStateFuture,
    );
  }

  Widget _buildAdjustmentSection(
    BuildContext context,
    WeeklyInsightsEntity insights, {
    required bool isPremium,
  }) {
    final delta = insights.recommendedKcalAdjustmentDelta;
    if (isPremium) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Text(insights.kcalAdjustmentRecommendation),
          if (delta != 0) ...[
            const SizedBox(height: 10),
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
                            '${delta > 0 ? '+' : ''}$delta',
                          ),
                    ),
            ),
          ],
        ],
      );
    }

    if (delta == 0) {
      return const SizedBox.shrink();
    }

    _logLockedAdjustmentViewed(insights);
    return _LockedWeeklyAdjustmentCard(
      deltaKcal: delta,
      onOpenPaywall: () => _openWeeklyPaywall(context),
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
      await locator<ConversionAnalyticsService>().logEvent(
        'weekly_adjustment_applied',
        parameters: {
          'delta_kcal': insights.recommendedKcalAdjustmentDelta,
          'new_adjustment': updatedAdjustment,
        },
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
      _loggedView = false;
      _loggedLockedAdjustment = false;
      _viewStateFuture = _loadViewState(args.focusedDate);
    });
  }

  Future<void> _openWeeklyPaywall(BuildContext context) async {
    await locator<ConversionAnalyticsService>()
        .logEvent('weekly_paywall_opened');
    if (!context.mounted) {
      return;
    }
    final purchased = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const PaywallSheet(
        placement: PaywallPlacement.weeklyInsights,
      ),
    );
    if (purchased == true && mounted) {
      _reloadInsights();
    }
  }

  void _logViewed(WeeklyInsightsEntity insights, bool isPremium) {
    if (_loggedView) {
      return;
    }
    _loggedView = true;
    unawaited(locator<ConversionAnalyticsService>().logEvent(
      'weekly_insights_viewed',
      parameters: {
        'is_premium': isPremium,
        'tracked_days': insights.trackedDays,
        'has_adjustment': insights.recommendedKcalAdjustmentDelta != 0,
      },
    ));
  }

  void _logLockedAdjustmentViewed(WeeklyInsightsEntity insights) {
    if (_loggedLockedAdjustment) {
      return;
    }
    _loggedLockedAdjustment = true;
    unawaited(locator<ConversionAnalyticsService>().logEvent(
      'weekly_adjustment_locked_viewed',
      parameters: {
        'delta_kcal': insights.recommendedKcalAdjustmentDelta,
        'tracked_days': insights.trackedDays,
      },
    ));
  }
}

class _WeeklyInsightsViewState {
  final WeeklyInsightsEntity insights;
  final AiTrialState aiTrialState;

  const _WeeklyInsightsViewState({
    required this.insights,
    required this.aiTrialState,
  });
}

class _LockedWeeklyAdjustmentCard extends StatelessWidget {
  final int deltaKcal;
  final VoidCallback onOpenPaywall;

  const _LockedWeeklyAdjustmentCard({
    required this.deltaKcal,
    required this.onOpenPaywall,
  });

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEs ? 'Recomendación de Ajuste Inteligente' : 'Smart Adjustment Recommendation',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              // Blurred preview of the recommendation
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEs ? 'Nuevo objetivo diario' : 'New daily target',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '+250 kcal / día',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const Icon(Icons.trending_up, size: 28),
                    ],
                  ),
                ),
              ),
              // Locked overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isEs
                ? 'Tus tendencias de peso e ingesta indican que deberías ajustar tus calorías diarias. Premium calcula el cambio exacto y lo aplica automáticamente.'
                : 'Your weight trends and intake indicate you should adjust your daily calories. Premium calculates the exact change and applies it automatically.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onOpenPaywall,
            icon: const Icon(Icons.lock_open_outlined, size: 16),
            label: Text(isEs ? 'Ver ajuste Premium' : 'Reveal recommended adjustment'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 36),
            ),
          ),
        ],
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
