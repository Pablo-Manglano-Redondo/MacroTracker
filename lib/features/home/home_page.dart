import 'package:flutter/material.dart';
import 'package:macrotracker/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/presentation/widgets/disclaimer_dialog.dart';
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
import 'package:macrotracker/features/daily_habits/domain/usecase/sync_sleep_from_health_connect_usecase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final log = Logger('HomePage');

  late HomeBloc _homeBloc;
  int _habitRefreshSeed = 0;
  bool _isSyncingSleep = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _homeBloc = locator<HomeBloc>();
    super.initState();
    _refreshHomeWidgetSummary();
    _syncSleepFromHealthConnect();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    return const Center(
      child: CircularProgressIndicator(),
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
            child: ListView(
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
                  remainingKcal: _positiveRemaining(totalKcalLeft),
                  remainingCarbs:
                      _positiveRemaining(totalCarbsGoal - totalCarbsIntake),
                  remainingFat:
                      _positiveRemaining(totalFatsGoal - totalFatsIntake),
                  remainingProtein: _positiveRemaining(
                      totalProteinsGoal - totalProteinsIntake),
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: overviewCardWidth,
                        child: BodyProgressCard(
                          padding: EdgeInsets.zero,
                          usesImperialUnits: usesImperialUnits,
                        ),
                      ),
                      SizedBox(
                        width: overviewCardWidth,
                        child: GymHabitsCard(
                          padding: EdgeInsets.zero,
                          dailyFocus: dailyFocus,
                          usesImperialUnits: usesImperialUnits,
                          refreshSeed: _habitRefreshSeed,
                        ),
                      ),
                      SizedBox(
                        width: overviewCardWidth,
                        child: _WeeklyInsightsCard(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              NavigationOptions.weeklyInsightsRoute,
                              arguments:
                                  WeeklyInsightsScreenArguments(DateTime.now()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48.0),
              ],
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
    if (_isSyncingSleep) {
      return;
    }

    _isSyncingSleep = true;
    try {
      final didUpdate =
          await locator<SyncSleepFromHealthConnectUsecase>().syncToday(
        requestPermissionsIfNeeded: true,
      );
      if (didUpdate && mounted) {
        setState(() {
          _habitRefreshSeed++;
        });
      }
    } catch (error, stackTrace) {
      log.warning(
        'Sleep sync from Health Connect failed',
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

  double _positiveRemaining(double value) {
    if (value <= 0) {
      return 0;
    }
    return value;
  }
}

class _WeeklyInsightsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _WeeklyInsightsCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: ListTile(
        leading: const Icon(Icons.insights_outlined),
        title: Text(S.of(context).weeklyInsightsTitle),
        subtitle: Text(
          S.of(context).homeWeeklyInsightsSubtitle,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
