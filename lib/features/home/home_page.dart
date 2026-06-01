import 'dart:io';

import 'package:flutter/material.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/food_quality_score_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/presentation/widgets/disclaimer_dialog.dart';
import 'package:macrotracker/core/presentation/widgets/shimmer_loading.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/home/presentation/widgets/body_progress_card.dart';
import 'package:macrotracker/features/home/presentation/widgets/dashboard_widget.dart';
import 'package:macrotracker/features/home/presentation/widgets/adherence_nudges_card.dart';
import 'package:macrotracker/features/home/presentation/widgets/gym_habits_card.dart';
import 'package:macrotracker/features/home_widget/domain/usecase/update_home_widget_usecase.dart';
import 'package:macrotracker/features/home/presentation/widgets/nutrition_kpi_card.dart';
import 'package:macrotracker/features/home/presentation/widgets/quick_gym_meals_card.dart';
import 'package:macrotracker/features/suggestions/presentation/macro_suggestions_card.dart';
import 'package:macrotracker/features/weekly_insights/presentation/weekly_insights_screen.dart';
import 'package:macrotracker/features/weekly_insights/domain/usecase/build_weekly_insights_usecase.dart';
import 'package:macrotracker/features/daily_habits/domain/usecase/sync_sleep_from_health_connect_usecase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final log = Logger('HomePage');

  late HomeBloc _homeBloc;
  late final GymHabitsCardController _gymHabitsCardController;
  bool _isSyncingSleep = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _homeBloc = locator<HomeBloc>();
    _gymHabitsCardController = GymHabitsCardController();
    super.initState();
    _refreshHomeWidgetSummary();
    _syncSleepFromHealthConnect();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gymHabitsCardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _homeBloc,
      builder: (context, state) {
        if (state is HomeInitial) {
          _homeBloc.add(const LoadItemsEvent());
          return _getLoadingContent();
        } else if (state is HomeLoadingState) {
          return _getLoadingContent();
        } else if (state is HomeLoadedState) {
          return _getLoadedContent(
              context,
              state.showDisclaimerDialog,
              state.nutritionPhase,
              state.dailyFocus,
              state.totalKcalDaily,
              state.totalKcalLeft,
              state.totalKcalSupplied,
              state.totalKcalBurned,
              state.totalCarbsIntake,
              state.totalFatsIntake,
              state.totalProteinsIntake,
              state.totalCarbsGoal,
              state.totalFatsGoal,
              state.totalProteinsGoal,
              state.dailyFoodQualityScore,
              state.dailyFoodQualityBand,
              state.dailyFoodQualityMealsCount,
              state.breakfastIntakeList,
              state.lunchIntakeList,
              state.dinnerIntakeList,
              state.snackIntakeList,
              state.userActivityList,
              state.usesImperialUnits);
        } else {
          return _getLoadingContent();
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log.info('App resumed');
      _refreshPageOnDayChange();
      _refreshHomeWidgetSummary();
      _syncSleepFromHealthConnect();
    }
    super.didChangeAppLifecycleState(state);
  }

  Widget _getLoadingContent() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dashboard card skeleton
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const SkeletonBox(width: 44, height: 44, borderRadius: 14),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(width: 160, height: 18, borderRadius: 6),
                      SizedBox(height: 6),
                      SkeletonBox(width: 100, height: 12, borderRadius: 6),
                    ],
                  ),
                ]),
                const SizedBox(height: 16),
                // Chips row
                Wrap(
                  spacing: 8,
                  children: const [
                    SkeletonBox(width: 90, height: 28, borderRadius: 14),
                    SkeletonBox(width: 90, height: 28, borderRadius: 14),
                    SkeletonBox(width: 90, height: 28, borderRadius: 14),
                  ],
                ),
                const SizedBox(height: 16),
                // Segmented buttons
                const SkeletonBox(
                    width: double.infinity, height: 46, borderRadius: 12),
                const SizedBox(height: 10),
                const SkeletonBox(
                    width: double.infinity, height: 46, borderRadius: 12),
                const SizedBox(height: 18),
                // Big metric headline
                const SkeletonBox(width: 200, height: 30, borderRadius: 8),
                const SizedBox(height: 12),
                // Two metric boxes
                Row(children: const [
                  Expanded(
                      child: SkeletonBox(
                          width: double.infinity,
                          height: 72,
                          borderRadius: 16)),
                  SizedBox(width: 12),
                  Expanded(
                      child: SkeletonBox(
                          width: double.infinity,
                          height: 72,
                          borderRadius: 16)),
                ]),
                const SizedBox(height: 14),
                // Progress bar
                const SkeletonBox(
                    width: double.infinity, height: 9, borderRadius: 999),
                const SizedBox(height: 14),
                // Macro rows
                const SkeletonBox(
                    width: double.infinity, height: 36, borderRadius: 10),
                const SizedBox(height: 10),
                const SkeletonBox(
                    width: double.infinity, height: 36, borderRadius: 10),
                const SizedBox(height: 10),
                const SkeletonBox(
                    width: double.infinity, height: 36, borderRadius: 10),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Secondary card skeleton
          const SkeletonBox(
              width: double.infinity, height: 110, borderRadius: 20),
          const SizedBox(height: 12),
          const SkeletonBox(
              width: double.infinity, height: 140, borderRadius: 20),
        ],
      ),
    );
  }

  Widget _getLoadedContent(
      BuildContext context,
      bool showDisclaimerDialog,
      UserWeightGoalEntity nutritionPhase,
      DailyFocusEntity dailyFocus,
      double totalKcalDaily,
      double totalKcalLeft,
      double totalKcalSupplied,
      double totalKcalBurned,
      double totalCarbsIntake,
      double totalFatsIntake,
      double totalProteinsIntake,
      double totalCarbsGoal,
      double totalFatsGoal,
      double totalProteinsGoal,
      double dailyFoodQualityScore,
      FoodQualityBandEntity dailyFoodQualityBand,
      int dailyFoodQualityMealsCount,
      List<IntakeEntity> breakfastIntakeList,
      List<IntakeEntity> lunchIntakeList,
      List<IntakeEntity> dinnerIntakeList,
      List<IntakeEntity> snackIntakeList,
      List<UserActivityEntity> userActivities,
      bool usesImperialUnits) {
    if (showDisclaimerDialog) {
      _showDisclaimerDialog(context);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth > 1220
            ? 1220.0
            : constraints.maxWidth.toDouble();
        final overviewColumns = contentWidth >= 980 ? 2 : 1;
        final overviewCardWidth = overviewColumns == 2
            ? (contentWidth - 32 - 12) / 2
            : contentWidth - 32;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DashboardWidget(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    nutritionPhase: nutritionPhase,
                    onNutritionPhaseChanged: _homeBloc.setNutritionPhase,
                    dailyFocus: dailyFocus,
                    onDailyFocusChanged: _homeBloc.setDailyFocus,
                    totalKcalDaily: totalKcalDaily,
                    totalKcalLeft: totalKcalLeft,
                    totalKcalSupplied: totalKcalSupplied,
                    totalKcalBurned: totalKcalBurned,
                    totalCarbsIntake: totalCarbsIntake,
                    totalFatsIntake: totalFatsIntake,
                    totalProteinsIntake: totalProteinsIntake,
                    totalCarbsGoal: totalCarbsGoal,
                    totalFatsGoal: totalFatsGoal,
                    totalProteinsGoal: totalProteinsGoal,
                    dailyFoodQualityScore: dailyFoodQualityScore,
                    dailyFoodQualityBand: dailyFoodQualityBand,
                    dailyFoodQualityMealsCount: dailyFoodQualityMealsCount,
                    mealsLogged: breakfastIntakeList.length +
                        lunchIntakeList.length +
                        dinnerIntakeList.length +
                        snackIntakeList.length,
                    sessionsLogged: userActivities.length,
                  ),
                  MacroSuggestionsCard(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    dailyFocus: dailyFocus,
                    nutritionPhase: nutritionPhase,
                    remainingKcal: totalKcalLeft,
                    remainingCarbs: totalCarbsGoal - totalCarbsIntake,
                    remainingFat: totalFatsGoal - totalFatsIntake,
                    remainingProtein: totalProteinsGoal - totalProteinsIntake,
                  ),
                  QuickGymMealsCard(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    dailyFocus: dailyFocus,
                    nutritionPhase: nutritionPhase,
                  ),
                  AdherenceNudgesCard(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    dailyFocus: dailyFocus,
                    totalKcalDaily: totalKcalDaily,
                    totalKcalSupplied: totalKcalSupplied,
                    totalProteinsGoal: totalProteinsGoal,
                    totalProteinsIntake: totalProteinsIntake,
                  ),
                  const NutritionKpiCard(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                  ),
                  _buildOverviewSection(
                    context: context,
                    overviewColumns: overviewColumns,
                    overviewCardWidth: overviewCardWidth,
                    usesImperialUnits: usesImperialUnits,
                    dailyFocus: dailyFocus,
                  ),
                  const SizedBox(height: 48.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show disclaimer dialog after build method
  void _showDisclaimerDialog(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dialogConfirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return const DisclaimerDialog();
          });
      if (dialogConfirmed != null) {
        _homeBloc.saveConfigData(dialogConfirmed);
        _homeBloc.add(const LoadItemsEvent());
      }
    });
  }

  /// Refresh page when day changes
  void _refreshPageOnDayChange() {
    if (!DateUtils.isSameDay(_homeBloc.currentDay, DateTime.now())) {
      _homeBloc.add(const LoadItemsEvent());
    }
  }

  Future<void> _syncSleepFromHealthConnect() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
    if (_isSyncingSleep) {
      return;
    }

    _isSyncingSleep = true;
    try {
      final didUpdate =
          await locator<SyncSleepFromHealthConnectUsecase>().syncToday(
        requestPermissionsIfNeeded: false,
      );
      if (didUpdate && mounted) {
        _gymHabitsCardController.refresh();
        _homeBloc.add(const LoadItemsEvent());
      }
    } catch (error, stackTrace) {
      log.warning(
        'Health data sync failed',
        error,
        stackTrace,
      );
    } finally {
      _isSyncingSleep = false;
    }
  }

  Future<void> _refreshHomeWidgetSummary() async {
    try {
      await locator<UpdateHomeWidgetUsecase>().refreshToday();
    } catch (error, stackTrace) {
      log.warning(
        'Home widget refresh failed',
        error,
        stackTrace,
      );
    }
  }

  Widget _buildOverviewSection({
    required BuildContext context,
    required int overviewColumns,
    required double overviewCardWidth,
    required bool usesImperialUnits,
    required DailyFocusEntity dailyFocus,
  }) {
    final bodyProgressCard = SizedBox(
      width: overviewCardWidth,
      child: BodyProgressCard(
        padding: EdgeInsets.zero,
        usesImperialUnits: usesImperialUnits,
      ),
    );
    final gymHabitsCard = SizedBox(
      width: overviewCardWidth,
      child: GymHabitsCard(
        padding: EdgeInsets.zero,
        dailyFocus: dailyFocus,
        usesImperialUnits: usesImperialUnits,
        controller: _gymHabitsCardController,
      ),
    );
    final weeklyInsightsCard = SizedBox(
      width: overviewCardWidth,
      child: _WeeklyInsightsCard(
        onTap: () {
          Navigator.of(context).pushNamed(
            NavigationOptions.weeklyInsightsRoute,
            arguments: WeeklyInsightsScreenArguments(DateTime.now()),
          );
        },
      ),
    );

    if (overviewColumns == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            bodyProgressCard,
            const SizedBox(height: 12),
            gymHabitsCard,
            const SizedBox(height: 12),
            weeklyInsightsCard,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          bodyProgressCard,
          gymHabitsCard,
          weeklyInsightsCard,
        ],
      ),
    );
  }
}

class _WeeklyInsightsCard extends StatefulWidget {
  final VoidCallback onTap;

  const _WeeklyInsightsCard({
    required this.onTap,
  });

  @override
  State<_WeeklyInsightsCard> createState() => _WeeklyInsightsCardState();
}

class _WeeklyInsightsCardState extends State<_WeeklyInsightsCard> {
  late final Future<_WeeklySnapshot?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadSnapshot();
  }

  Future<_WeeklySnapshot?> _loadSnapshot() async {
    try {
      final insights =
          await locator<BuildWeeklyInsightsUsecase>().build(DateTime.now());
      return _WeeklySnapshot(
        adherence: (insights.goalAdherenceRate * 100).round(),
        avgProtein: insights.averageProtein.toStringAsFixed(0),
        trackedDays: insights.trackedDays,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.20),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.primary.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      Icons.insights_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      S.of(context).weeklyInsightsTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
              FutureBuilder<_WeeklySnapshot?>(
                future: _future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final snap = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InsightPill(
                          icon: Icons.track_changes_outlined,
                          label: '${snap.adherence}%',
                          sublabel: isEs ? 'adherencia' : 'adherence',
                          color: colorScheme.primary,
                        ),
                        _InsightPill(
                          icon: Icons.egg_alt_outlined,
                          label: '${snap.avgProtein}g',
                          sublabel: isEs ? 'proteína' : 'protein',
                          color: colorScheme.tertiary,
                        ),
                        _InsightPill(
                          icon: Icons.calendar_today_outlined,
                          label: '${snap.trackedDays}/7',
                          sublabel: isEs ? 'días' : 'days',
                          color: colorScheme.secondary,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklySnapshot {
  final int adherence;
  final String avgProtein;
  final int trackedDays;

  const _WeeklySnapshot({
    required this.adherence,
    required this.avgProtein,
    required this.trackedDays,
  });
}

class _InsightPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;

  const _InsightPill({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
              ),
              Text(
                sublabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
