import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/domain/entity/daily_focus_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';
import 'package:macrotracker/core/presentation/widgets/activity_vertial_list.dart';
import 'package:macrotracker/core/presentation/widgets/edit_dialog.dart';
import 'package:macrotracker/core/presentation/widgets/delete_dialog.dart';
import 'package:macrotracker/core/presentation/widgets/disclaimer_dialog.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:macrotracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:macrotracker/features/home/presentation/widgets/body_progress_card.dart';
import 'package:macrotracker/features/home/presentation/widgets/dashboard_widget.dart';
import 'package:macrotracker/features/home/presentation/widgets/gym_habits_card.dart';
import 'package:macrotracker/features/home/presentation/widgets/intake_vertical_list.dart';
import 'package:macrotracker/features/home/presentation/widgets/quick_gym_meals_card.dart';
import 'package:macrotracker/features/suggestions/presentation/macro_suggestions_card.dart';
import 'package:macrotracker/features/weekly_insights/presentation/weekly_insights_screen.dart';
import 'package:macrotracker/generated/l10n.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final log = Logger('HomePage');

  late HomeBloc _homeBloc;
  bool _isDragging = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _homeBloc = locator<HomeBloc>();
    super.initState();
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
    return Stack(children: [
      LayoutBuilder(
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
                  QuickGymMealsCard(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    dailyFocus: dailyFocus,
                    nutritionPhase: nutritionPhase,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                    child: Text(
                      'Performance overview',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                          ),
                        ),
                        SizedBox(
                          width: overviewCardWidth,
                          child: _WeeklyInsightsCard(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                NavigationOptions.weeklyInsightsRoute,
                                arguments: WeeklyInsightsScreenArguments(
                                    DateTime.now()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  MacroSuggestionsCard(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                  const SizedBox(height: 6),
                  ActivityVerticalList(
                    compact: true,
                    day: DateTime.now(),
                    title: S.of(context).activityLabel,
                    userActivityList: userActivities,
                    onItemLongPressedCallback: onActivityItemLongPressed,
                  ),
                  IntakeVerticalList(
                    compact: true,
                    day: DateTime.now(),
                    title: S.of(context).breakfastLabel,
                    listIcon: IntakeTypeEntity.breakfast.getIconData(),
                    addMealType: AddMealType.breakfastType,
                    intakeList: breakfastIntakeList,
                    onDeleteIntakeCallback: onDeleteIntake,
                    onItemDragCallback: onIntakeItemDrag,
                    onItemTappedCallback: onIntakeItemTapped,
                    usesImperialUnits: usesImperialUnits,
                  ),
                  IntakeVerticalList(
                    compact: true,
                    day: DateTime.now(),
                    title: S.of(context).lunchLabel,
                    listIcon: IntakeTypeEntity.lunch.getIconData(),
                    addMealType: AddMealType.lunchType,
                    intakeList: lunchIntakeList,
                    onDeleteIntakeCallback: onDeleteIntake,
                    onItemDragCallback: onIntakeItemDrag,
                    onItemTappedCallback: onIntakeItemTapped,
                    usesImperialUnits: usesImperialUnits,
                  ),
                  IntakeVerticalList(
                    compact: true,
                    day: DateTime.now(),
                    title: S.of(context).dinnerLabel,
                    addMealType: AddMealType.dinnerType,
                    listIcon: IntakeTypeEntity.dinner.getIconData(),
                    intakeList: dinnerIntakeList,
                    onDeleteIntakeCallback: onDeleteIntake,
                    onItemDragCallback: onIntakeItemDrag,
                    onItemTappedCallback: onIntakeItemTapped,
                    usesImperialUnits: usesImperialUnits,
                  ),
                  IntakeVerticalList(
                    compact: true,
                    day: DateTime.now(),
                    title: S.of(context).snackLabel,
                    listIcon: IntakeTypeEntity.snack.getIconData(),
                    addMealType: AddMealType.snackType,
                    intakeList: snackIntakeList,
                    onDeleteIntakeCallback: onDeleteIntake,
                    onItemDragCallback: onIntakeItemDrag,
                    onItemTappedCallback: onIntakeItemTapped,
                    usesImperialUnits: usesImperialUnits,
                  ),
                  const SizedBox(height: 48.0)
                ],
              ),
            ),
          );
        },
      ),
      Align(
          alignment: Alignment.bottomCenter,
          child: Visibility(
              visible: _isDragging,
              child: Container(
                height: 70,
                color: Theme.of(context).colorScheme.error
                  ..withValues(alpha: 0.3),
                child: DragTarget<IntakeEntity>(
                  onAcceptWithDetails: (data) {
                    _confirmDelete(context, data.data);
                  },
                  onLeave: (data) {
                    setState(() {
                      _isDragging = false;
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return const Center(
                      child: Icon(
                        Icons.delete_outline,
                        size: 36,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              )))
    ]);
  }

  void onActivityItemLongPressed(
      BuildContext context, UserActivityEntity activityEntity) async {
    final deleteIntake = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (deleteIntake != null) {
      _homeBloc.deleteUserActivityItem(activityEntity);
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
      }
    }
  }

  void onIntakeItemLongPressed(
      BuildContext context, IntakeEntity intakeEntity) async {
    final deleteIntake = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (deleteIntake != null) {
      _homeBloc.deleteIntakeItem(intakeEntity);
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
      }
    }
  }

  void onIntakeItemDrag(bool isDragging) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isDragging = isDragging;
      });
    });
  }

  void onIntakeItemTapped(BuildContext context, IntakeEntity intakeEntity,
      bool usesImperialUnits) async {
    final changeIntakeAmount = await showDialog<double>(
        context: context,
        builder: (context) => EditDialog(
            intakeEntity: intakeEntity, usesImperialUnits: usesImperialUnits));
    if (changeIntakeAmount != null) {
      _homeBloc
          .updateIntakeItem(intakeEntity.id, {'amount': changeIntakeAmount});
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemUpdatedSnackbar)));
      }
    }
  }

  void onDeleteIntake(IntakeEntity intake, TrackedDayEntity? trackedDayEntity) {
    _homeBloc.deleteIntakeItem(intake);
    _homeBloc.add(const LoadItemsEvent());
  }

  void _confirmDelete(BuildContext context, IntakeEntity intake) async {
    bool? delete = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (delete == true) {
      onDeleteIntake(intake, null);
    }
    setState(() {
      _isDragging = false;
    });
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
        title: const Text('Weekly insights'),
        subtitle: const Text(
          'Review averages, adherence, protein consistency and top meals',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
