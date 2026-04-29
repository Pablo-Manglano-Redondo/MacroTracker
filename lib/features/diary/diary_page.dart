import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:macrotracker/core/domain/usecase/add_user_activity_usercase.dart';
import 'package:macrotracker/core/domain/usecase/get_gym_targets_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:macrotracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:macrotracker/core/utils/locator.dart';
import 'package:macrotracker/core/utils/calc/macro_calc.dart';
import 'package:macrotracker/core/utils/id_generator.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:macrotracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:macrotracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:macrotracker/features/diary/presentation/widgets/diary_table_calendar.dart';
import 'package:macrotracker/features/diary/presentation/widgets/day_info_widget.dart';
import 'package:macrotracker/features/meal_detail/presentation/bloc/meal_detail_bloc.dart';
import 'package:macrotracker/features/weekly_insights/domain/entity/weekly_insights_entity.dart';
import 'package:macrotracker/features/weekly_insights/domain/usecase/build_weekly_insights_usecase.dart';
import 'package:macrotracker/generated/l10n.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> with WidgetsBindingObserver {
  final log = Logger('DiaryPage');

  late DiaryBloc _diaryBloc;
  late CalendarDayBloc _calendarDayBloc;
  late MealDetailBloc _mealDetailBloc;
  late AddUserActivityUsecase _addUserActivityUsecase;
  late AddTrackedDayUsecase _addTrackedDayUsecase;
  late GetGymTargetsUsecase _getGymTargetsUsecase;
  late GetIntakeUsecase _getIntakeUsecase;
  late GetUserActivityUsecase _getUserActivityUsecase;
  late BuildWeeklyInsightsUsecase _buildWeeklyInsightsUsecase;

  static const _calendarDurationDays = Duration(days: 356);
  final _currentDate = DateTime.now();
  var _selectedDate = DateTime.now();
  var _focusedDate = DateTime.now();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _diaryBloc = locator<DiaryBloc>();
    _calendarDayBloc = locator<CalendarDayBloc>();
    _mealDetailBloc = locator<MealDetailBloc>();
    _addUserActivityUsecase = locator<AddUserActivityUsecase>();
    _addTrackedDayUsecase = locator<AddTrackedDayUsecase>();
    _getGymTargetsUsecase = locator<GetGymTargetsUsecase>();
    _getIntakeUsecase = locator<GetIntakeUsecase>();
    _getUserActivityUsecase = locator<GetUserActivityUsecase>();
    _buildWeeklyInsightsUsecase = locator<BuildWeeklyInsightsUsecase>();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiaryBloc, DiaryState>(
      bloc: _diaryBloc,
      builder: (context, state) {
        if (state is DiaryInitial) {
          _diaryBloc.add(const LoadDiaryYearEvent());
        } else if (state is DiaryLoadingState) {
          return _getLoadingContent();
        } else if (state is DiaryLoadedState) {
          return _getLoadedContent(
              context, state.trackedDayMap, state.usesImperialUnits);
        }
        return const SizedBox();
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

  Widget _getLoadingContent() =>
      const Center(child: CircularProgressIndicator());

  Widget _getLoadedContent(BuildContext context,
      Map<String, TrackedDayEntity> trackedDaysMap, bool usesImperialUnits) {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _DiaryWeeklyStrip(
          buildWeeklyInsightsUsecase: _buildWeeklyInsightsUsecase,
          focusedDate: _selectedDate,
        ),
        const SizedBox(height: 12),
        DiaryTableCalendar(
          trackedDaysMap: trackedDaysMap,
          onDateSelected: _onDateSelected,
          onPageChanged: _onCalendarPageChanged,
          calendarDurationDays: _calendarDurationDays,
          currentDate: _currentDate,
          selectedDate: _selectedDate,
          focusedDate: _focusedDate,
        ),
        const SizedBox(height: 10),
        _DiaryQuickNavigationBar(
          selectedDate: _selectedDate,
          isToday: isToday,
          onPreviousDay: _goToPreviousDay,
          onNextDay: _goToNextDay,
          onToday: _goToToday,
        ),
        const SizedBox(height: 18.0),
        BlocBuilder<CalendarDayBloc, CalendarDayState>(
          bloc: _calendarDayBloc,
          builder: (context, state) {
            if (state is CalendarDayInitial) {
              _calendarDayBloc.add(LoadCalendarDayEvent(_selectedDate));
            } else if (state is CalendarDayLoading) {
              return _getLoadingContent();
            } else if (state is CalendarDayLoaded) {
              return DayInfoWidget(
                trackedDayEntity: state.trackedDayEntity,
                selectedDay: _selectedDate,
                userActivities: state.userActivityList,
                breakfastIntake: state.breakfastIntakeList,
                lunchIntake: state.lunchIntakeList,
                dinnerIntake: state.dinnerIntakeList,
                snackIntake: state.snackIntakeList,
                onDeleteIntake: _onDeleteIntakeItem,
                onDeleteActivity: _onDeleteActivityItem,
                onCopyIntake: _onCopyIntakeItem,
                onCopyActivity: _onCopyActivityItem,
                onCopyDayToToday: _copySelectedDayToToday,
                usesImperialUnits: usesImperialUnits,
              );
            }
            return const SizedBox();
          },
        )
      ],
    );
  }

  void _onDeleteIntakeItem(
      IntakeEntity intakeEntity, TrackedDayEntity? trackedDayEntity) async {
    await _calendarDayBloc.deleteIntakeItem(
        context, intakeEntity, trackedDayEntity?.day ?? DateTime.now());
    _diaryBloc.add(const LoadDiaryYearEvent());
    _calendarDayBloc.add(LoadCalendarDayEvent(_selectedDate));
    _diaryBloc.updateHomePage();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
    }
  }

  void _onDeleteActivityItem(UserActivityEntity userActivityEntity,
      TrackedDayEntity? trackedDayEntity) async {
    await _calendarDayBloc.deleteUserActivityItem(
        context, userActivityEntity, trackedDayEntity?.day ?? DateTime.now());
    _diaryBloc.add(const LoadDiaryYearEvent());
    _calendarDayBloc.add(LoadCalendarDayEvent(_selectedDate));
    _diaryBloc.updateHomePage();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
    }
  }

  void _onCopyIntakeItem(IntakeEntity intakeEntity,
      TrackedDayEntity? trackedDayEntity, AddMealType? type) async {
    IntakeTypeEntity finalType;
    if (type == null) {
      finalType = intakeEntity.type;
    } else {
      finalType = type.getIntakeType();
    }
    _mealDetailBloc.addIntake(
        context,
        intakeEntity.unit,
        intakeEntity.amount.toString(),
        finalType,
        intakeEntity.meal,
        DateTime.now());
    _diaryBloc.updateHomePage();
  }

  void _onCopyActivityItem(UserActivityEntity userActivityEntity,
      TrackedDayEntity? trackedDayEntity) async {
    log.info("Should copy activity");
  }

  Future<void> _copySelectedDayToToday() async {
    if (DateUtils.isSameDay(_selectedDate, DateTime.now())) {
      return;
    }

    final today = DateTime.now();
    final breakfastIntake =
        await _getIntakeUsecase.getBreakfastIntakeByDay(_selectedDate);
    final lunchIntake =
        await _getIntakeUsecase.getLunchIntakeByDay(_selectedDate);
    final dinnerIntake =
        await _getIntakeUsecase.getDinnerIntakeByDay(_selectedDate);
    final snackIntake =
        await _getIntakeUsecase.getSnackIntakeByDay(_selectedDate);
    final activities = await _getUserActivityUsecase.getUserActivityByDay(
      _selectedDate,
    );

    if (!mounted) {
      return;
    }

    for (final intake in [
      ...breakfastIntake,
      ...lunchIntake,
      ...dinnerIntake,
      ...snackIntake,
    ]) {
      _mealDetailBloc.addIntake(
        context,
        intake.unit,
        intake.amount.toString(),
        intake.type,
        intake.meal,
        today,
      );
    }

    await _ensureTodayTrackedDay();
    for (final activity in activities) {
      final copied = UserActivityEntity(
        IdGenerator.getUniqueID(),
        activity.duration,
        activity.burnedKcal,
        today,
        activity.physicalActivityEntity,
      );
      await _addUserActivityUsecase.addUserActivity(copied);
      await _addTrackedDayUsecase.increaseDayCalorieGoal(
        today,
        copied.burnedKcal,
      );
      await _addTrackedDayUsecase.increaseDayMacroGoals(
        today,
        carbsAmount: MacroCalc.getTotalCarbsGoal(copied.burnedKcal),
        fatAmount: MacroCalc.getTotalFatsGoal(copied.burnedKcal),
        proteinAmount: MacroCalc.getTotalProteinsGoal(copied.burnedKcal),
      );
    }

    _setSelectedDate(today);
    _diaryBloc.add(const LoadDiaryYearEvent());
    _diaryBloc.updateHomePage();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).diaryDayCopied),
        ),
      );
    }
  }

  Future<void> _ensureTodayTrackedDay() async {
    final today = DateTime.now();
    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(today);
    if (hasTrackedDay) return;
    final targets = await _getGymTargetsUsecase.getTargetsForDay(today);
    await _addTrackedDayUsecase.addNewTrackedDay(
      today,
      targets.kcalGoal,
      targets.carbsGoal,
      targets.fatGoal,
      targets.proteinGoal,
    );
  }

  void _onDateSelected(
      DateTime newDate, Map<String, TrackedDayEntity> trackedDaysMap) {
    _setSelectedDate(newDate);
  }

  void _onCalendarPageChanged(DateTime newFocusedDate) {
    setState(() {
      _focusedDate = newFocusedDate;
    });
  }

  void _goToPreviousDay() {
    _setSelectedDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  void _goToNextDay() {
    _setSelectedDate(_selectedDate.add(const Duration(days: 1)));
  }

  void _goToToday() {
    _setSelectedDate(DateTime.now());
  }

  void _setSelectedDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _focusedDate = newDate;
    });
    _calendarDayBloc.add(LoadCalendarDayEvent(newDate));
  }

  void _refreshPageOnDayChange() {
    if (DateUtils.isSameDay(_selectedDate, DateTime.now())) {
      _calendarDayBloc.add(LoadCalendarDayEvent(_selectedDate));
      _diaryBloc.add(const LoadDiaryYearEvent());
    }
  }
}

class _DiaryWeeklyStrip extends StatelessWidget {
  final BuildWeeklyInsightsUsecase buildWeeklyInsightsUsecase;
  final DateTime focusedDate;

  const _DiaryWeeklyStrip({
    required this.buildWeeklyInsightsUsecase,
    required this.focusedDate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<WeeklyInsightsEntity>(
      future: buildWeeklyInsightsUsecase.build(focusedDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final weekly = snapshot.data!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).diaryCurrentWeek,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _WeeklyPill(
                      icon: Icons.track_changes_outlined,
                      label: S.of(context).diaryAdherencePill((weekly.goalAdherenceRate * 100).round()),
                      color: colorScheme.primary,
                    ),
                    _WeeklyPill(
                      icon: Icons.egg_alt_outlined,
                      label: S.of(context).diaryProteinPill(weekly.averageProtein.toStringAsFixed(0)),
                      color: colorScheme.tertiary,
                    ),
                    _WeeklyPill(
                      icon: Icons.calendar_view_week_outlined,
                      label: S.of(context).diaryDaysPill(weekly.trackedDays),
                      color: colorScheme.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WeeklyPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _WeeklyPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.10),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DiaryQuickNavigationBar extends StatelessWidget {
  final DateTime selectedDate;
  final bool isToday;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onToday;

  const _DiaryQuickNavigationBar({
    required this.selectedDate,
    required this.isToday,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = DateUtils.isSameDay(selectedDate, DateTime.now())
        ? S.of(context).todayLabel
        : MaterialLocalizations.of(context).formatMediumDate(selectedDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            IconButton.filledTonal(
              onPressed: onPreviousDay,
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: S.of(context).diaryPreviousDayTooltip,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.45),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).diarySelectedDayLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: isToday ? null : onToday,
              child: Text(S.of(context).todayLabel),
            ),
            IconButton.filledTonal(
              onPressed: onNextDay,
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: S.of(context).diaryNextDayTooltip,
            ),
          ],
        ),
      ),
    );
  }
}
