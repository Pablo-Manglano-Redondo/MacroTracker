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
import 'package:macrotracker/features/weekly_insights/presentation/widgets/weekly_progress_share_sheet.dart';


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
        actions: [
          FutureBuilder<_WeeklyInsightsViewState>(
            future: _viewStateFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    WeeklyProgressShareSheet.show(
                      context,
                      snapshot.data!.insights,
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCard(context, insights, weekStart, weekEnd, isPremium),
                const SizedBox(height: 16),
                _buildAveragesCard(context, insights),
                const SizedBox(height: 16),
                _buildMetricsGrid(context, insights),
                const SizedBox(height: 16),
                _buildTopMealsCard(context, insights),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    WeeklyInsightsEntity insights,
    String weekStart,
    String weekEnd,
    bool isPremium,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final delta = insights.weeklyWeightDeltaKg;
    final Color badgeBg;
    final Color badgeText;
    final String deltaText;
    final IconData trendIcon;
    
    if (delta > 0) {
      badgeBg = const Color(0xFFEF4444).withValues(alpha: 0.12);
      badgeText = const Color(0xFFDC2626);
      deltaText = '+${delta.toStringAsFixed(2)} kg';
      trendIcon = Icons.trending_up_rounded;
    } else if (delta < 0) {
      badgeBg = const Color(0xFF10B981).withValues(alpha: 0.12);
      badgeText = const Color(0xFF059669);
      deltaText = '${delta.toStringAsFixed(2)} kg';
      trendIcon = Icons.trending_down_rounded;
    } else {
      badgeBg = colorScheme.secondaryContainer.withValues(alpha: 0.5);
      badgeText = colorScheme.onSecondaryContainer;
      deltaText = '0.00 kg';
      trendIcon = Icons.trending_flat_rounded;
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).weeklyInsightsWeeklySummary,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        '$weekStart - $weekEnd',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              insights.summaryLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 16),
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).weeklyInsightsWeightTrendLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      S.of(context).weeklyInsightsWeeklyChangeLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: badgeBg,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, size: 18, color: badgeText),
                      const SizedBox(width: 6),
                      Text(
                        deltaText,
                        style: TextStyle(
                          color: badgeText,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _buildAdjustmentSection(
              context,
              insights,
              isPremium: isPremium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAveragesCard(BuildContext context, WeeklyInsightsEntity insights) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).weeklyInsightsDailyAverages,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDark ? const Color(0xFF0F0F10) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.local_fire_department, color: Color(0xFFEF4444)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).weeklyInsightsCalorieIntake,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: insights.averageCalories.toStringAsFixed(0),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 24,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                              TextSpan(
                                text: ' kcal / ${S.of(context).weeklyInsightsPerDay}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildMacroColumn(
                    context: context,
                    label: S.of(context).weeklyInsightsProteinShort,
                    value: '${insights.averageProtein.toStringAsFixed(1)} g',
                    color: const Color(0xFF10B981),
                    icon: Icons.egg_alt_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMacroColumn(
                    context: context,
                    label: S.of(context).weeklyInsightsCarbShort,
                    value: '${insights.averageCarbs.toStringAsFixed(1)} g',
                    color: const Color(0xFFF59E0B),
                    icon: Icons.cookie_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMacroColumn(
                    context: context,
                    label: S.of(context).weeklyInsightsFatShort,
                    value: '${insights.averageFat.toStringAsFixed(1)} g',
                    color: const Color(0xFF3B82F6),
                    icon: Icons.opacity_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroColumn({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? const Color(0xFF0F0F10) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, WeeklyInsightsEntity insights) {
    final colorScheme = Theme.of(context).colorScheme;
    final adherencePercent = insights.goalAdherenceRate;
    final proteinPercent = insights.proteinConsistencyRate;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context: context,
                title: S.of(context).weeklyInsightsCoverage,
                icon: Icons.calendar_today_outlined,
                iconColor: colorScheme.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${insights.trackedDays}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                          TextSpan(
                            text: ' / 7 ${S.of(context).weeklyInsightsDaysSuffix}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: insights.trackedDays / 7,
                        minHeight: 6,
                        backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                context: context,
                title: S.of(context).weeklyInsightsOvereatingPattern,
                icon: Icons.access_time_outlined,
                iconColor: const Color(0xFF8B5CF6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insights.overeatingTimeSlotLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      S.of(context).weeklyInsightsOvereatingPeriods,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context: context,
                title: S.of(context).weeklyInsightsAdherence,
                icon: Icons.track_changes_outlined,
                iconColor: const Color(0xFFF59E0B),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(adherencePercent * 100).round()}%',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            S.of(context).weeklyInsightsDaysMet,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        value: adherencePercent,
                        strokeWidth: 4,
                        backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                context: context,
                title: S.of(context).weeklyInsightsProteinConsistencyShort,
                icon: Icons.fitness_center_outlined,
                iconColor: const Color(0xFF10B981),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(proteinPercent * 100).round()}%',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            S.of(context).weeklyInsightsConsistentDays,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        value: proteinPercent,
                        strokeWidth: 4,
                        backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTopMealsCard(BuildContext context, WeeklyInsightsEntity insights) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).weeklyInsightsTopMeals,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 14),
            if (insights.topMeals.isEmpty)
              Text(
                S.of(context).weeklyInsightsNoFrequentMeals,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              )
            else
              Column(
                children: insights.topMeals
                    .map(
                      (meal) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isDark ? const Color(0xFF0F0F10) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.primary.withValues(alpha: 0.08),
                                ),
                                alignment: Alignment.center,
                                child: Icon(Icons.restaurant_menu, size: 14, color: colorScheme.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  meal.label,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: colorScheme.secondaryContainer,
                                ),
                                child: Text(
                                  S.of(context).weeklyInsightsMealCountTimes(meal.count),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
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
                  S.of(context).weeklyInsightsSmartAdjustmentRecommendation,
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
                            S.of(context).weeklyInsightsNewDailyTarget,
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
            S.of(context).weeklyInsightsLockedAdjustmentBody,
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
            label: Text(S.of(context).weeklyInsightsRevealAdjustment),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 36),
            ),
          ),
        ],
      ),
    );
  }
}
