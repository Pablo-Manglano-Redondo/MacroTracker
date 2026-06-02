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
import 'package:macrotracker/features/home/presentation/widgets/gym_habits_card.dart';
import 'package:macrotracker/features/home_widget/domain/usecase/update_home_widget_usecase.dart';
import 'package:macrotracker/features/professional_plan/domain/entity/professional_connection_entity.dart';
import 'package:macrotracker/features/professional_plan/presentation/widgets/professional_plan_card.dart';
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
  late final GymHabitsCardController _gymHabitsCardController;
  bool _isSyncingSleep = false;
  bool _didQueueDeferredStartupWork = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _homeBloc = locator<HomeBloc>();
    _gymHabitsCardController = GymHabitsCardController();
    super.initState();
    _queueDeferredStartupWork();
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
              state.usesImperialUnits,
              state.professionalPlanSummary);
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
      bool usesImperialUnits,
      ProfessionalPlanSummaryEntity? professionalPlanSummary) {
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
        final actionColumns = contentWidth >= 920 ? 2 : 1;
        final actionCardWidth = actionColumns == 2
            ? (contentWidth - 32 - 12) / 2
            : contentWidth - 32;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _HomeContextHeader(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    dailyFocus: dailyFocus,
                    nutritionPhase: nutritionPhase,
                    onDailyFocusChanged: _homeBloc.setDailyFocus,
                    onNutritionPhaseChanged: _homeBloc.setNutritionPhase,
                  ),
                  DashboardWidget(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
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
                  if (professionalPlanSummary != null)
                    ProfessionalPlanCard(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      summary: professionalPlanSummary,
                      onOpenPlan: () => Navigator.of(context).pushNamed(
                        NavigationOptions.professionalPlanRoute,
                      ),
                    ),
                  _HomeSectionHeader(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                    title: _homeCopy(
                      context,
                      es: 'Acciones de hoy',
                      en: 'Today actions',
                    ),
                    subtitle: _homeCopy(
                      context,
                      es: 'Sugerencias y comidas listas para cerrar macros sin perder tiempo.',
                      en: 'Suggestions and ready meals to close macros without friction.',
                    ),
                  ),
                  _ResponsiveHomeGroup(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    columns: actionColumns,
                    cardWidth: actionCardWidth,
                    children: [
                      MacroSuggestionsCard(
                        padding: EdgeInsets.zero,
                        dailyFocus: dailyFocus,
                        nutritionPhase: nutritionPhase,
                        remainingKcal: totalKcalLeft,
                        remainingCarbs: totalCarbsGoal - totalCarbsIntake,
                        remainingFat: totalFatsGoal - totalFatsIntake,
                        remainingProtein:
                            totalProteinsGoal - totalProteinsIntake,
                      ),
                      QuickGymMealsCard(
                        padding: EdgeInsets.zero,
                        dailyFocus: dailyFocus,
                        nutritionPhase: nutritionPhase,
                      ),
                    ],
                  ),
                  _HomeSectionHeader(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    title: _homeCopy(
                      context,
                      es: 'Seguimiento',
                      en: 'Tracking',
                    ),
                    subtitle: _homeCopy(
                      context,
                      es: 'Adherencia, progreso y tendencias para ajustar con criterio.',
                      en: 'Adherence, progress, and trends for better adjustments.',
                    ),
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

  void _queueDeferredStartupWork() {
    if (_didQueueDeferredStartupWork) {
      return;
    }
    _didQueueDeferredStartupWork = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted) {
        return;
      }
      _refreshHomeWidgetSummary();
      _syncSleepFromHealthConnect();
      _homeBloc.add(const LoadItemsEvent(
        refreshRemotePlan: true,
        uploadProfessionalSnapshot: true,
      ));
    });
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

class _HomeContextHeader extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final DailyFocusEntity dailyFocus;
  final UserWeightGoalEntity nutritionPhase;
  final ValueChanged<DailyFocusEntity>? onDailyFocusChanged;
  final ValueChanged<UserWeightGoalEntity>? onNutritionPhaseChanged;

  const _HomeContextHeader({
    required this.padding,
    required this.dailyFocus,
    required this.nutritionPhase,
    this.onDailyFocusChanged,
    this.onNutritionPhaseChanged,
  });

  bool _isEs(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'es';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formattedToday(context),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          _homeCopy(
            context,
            es: 'Panel diario',
            en: 'Daily board',
          ),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
        ),
      ],
    );
    final chips = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: [
        PopupMenuButton<DailyFocusEntity>(
          tooltip: _isEs(context) ? 'Cambiar enfoque' : 'Change focus',
          onSelected: onDailyFocusChanged,
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          itemBuilder: (BuildContext context) =>
              DailyFocusEntity.values.map((focus) {
            return PopupMenuItem<DailyFocusEntity>(
              value: focus,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_focusIcon(focus),
                      size: 18, color: const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Text(_focusLabel(context, focus)),
                ],
              ),
            );
          }).toList(),
          child: _HomeContextChip(
            icon: _focusIcon(dailyFocus),
            label: _focusLabel(context, dailyFocus),
            isFocus: true,
          ),
        ),
        PopupMenuButton<UserWeightGoalEntity>(
          tooltip: _isEs(context) ? 'Cambiar objetivo' : 'Change goal',
          onSelected: onNutritionPhaseChanged,
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          itemBuilder: (BuildContext context) =>
              UserWeightGoalEntity.values.map((phase) {
            return PopupMenuItem<UserWeightGoalEntity>(
              value: phase,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_goalIcon(phase),
                      size: 18, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(phase.getName(context)),
                ],
              ),
            );
          }).toList(),
          child: _HomeContextChip(
            icon: _goalIcon(nutritionPhase),
            label: nutritionPhase.getName(context),
            isFocus: false,
          ),
        ),
      ],
    );

    return Padding(
      padding: padding,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleBlock,
            const SizedBox(height: 10),
            chips,
          ],
        ),
      ),
    );
  }

  IconData _focusIcon(DailyFocusEntity focus) {
    switch (focus) {
      case DailyFocusEntity.lowerBody:
      case DailyFocusEntity.upperBody:
        return Icons.fitness_center_outlined;
      case DailyFocusEntity.cardio:
        return Icons.directions_run_outlined;
      case DailyFocusEntity.rest:
        return Icons.hotel_outlined;
    }
  }

  String _focusLabel(BuildContext context, DailyFocusEntity focus) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    switch (focus) {
      case DailyFocusEntity.lowerBody:
        return isEs ? 'Pierna' : 'Legs';
      case DailyFocusEntity.upperBody:
        return isEs ? 'Torso' : 'Upper';
      case DailyFocusEntity.cardio:
        return isEs ? 'Cardio' : 'Cardio';
      case DailyFocusEntity.rest:
        return isEs ? 'Descanso' : 'Rest';
    }
  }

  IconData _goalIcon(UserWeightGoalEntity goal) {
    switch (goal) {
      case UserWeightGoalEntity.loseWeight:
        return Icons.trending_down_outlined;
      case UserWeightGoalEntity.gainWeight:
        return Icons.trending_up_outlined;
      case UserWeightGoalEntity.maintainWeight:
        return Icons.trending_flat_outlined;
    }
  }

  String _formattedToday(BuildContext context) {
    final now = DateTime.now();
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final weekdays = isEs
        ? const ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom']
        : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = isEs
        ? const [
            'ene',
            'feb',
            'mar',
            'abr',
            'may',
            'jun',
            'jul',
            'ago',
            'sep',
            'oct',
            'nov',
            'dic',
          ]
        : const [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}

class _HomeContextChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isFocus;

  const _HomeContextChip({
    required this.icon,
    required this.label,
    required this.isFocus,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final Color textColor = isFocus
        ? const Color(0xFF10B981) // Vibrant green
        : colorScheme.onSurfaceVariant;
    final Color iconColor = textColor;
    final Color bgColor = isFocus
        ? const Color(0xFF10B981).withValues(alpha: 0.08)
        : (isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03));
    final Border border = isFocus
        ? Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.16))
        : Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          );

    return Container(
      constraints: const BoxConstraints(maxWidth: 142),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: bgColor,
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final String title;
  final String subtitle;

  const _HomeSectionHeader({
    required this.padding,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveHomeGroup extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final int columns;
  final double cardWidth;
  final List<Widget> children;

  const _ResponsiveHomeGroup({
    required this.padding,
    required this.columns,
    required this.cardWidth,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (columns == 1) {
      return Padding(
        padding: padding,
        child: Column(
          children: _spacedChildren(
            children
                .map((child) => SizedBox(width: double.infinity, child: child))
                .toList(),
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: children
            .map((child) => SizedBox(width: cardWidth, child: child))
            .toList(),
      ),
    );
  }

  List<Widget> _spacedChildren(List<Widget> widgets) {
    final spaced = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      if (i > 0) {
        spaced.add(const SizedBox(height: 12));
      }
      spaced.add(widgets[i]);
    }
    return spaced;
  }
}

String _homeCopy(BuildContext context,
    {required String es, required String en}) {
  return Localizations.localeOf(context).languageCode == 'es' ? es : en;
}

class _WeeklyInsightsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _WeeklyInsightsCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF121212) : Colors.white;
    final borderColor = isDark
        ? colorScheme.outlineVariant.withValues(alpha: 0.22)
        : const Color(0xFFE5E7EB);

    return Card(
      elevation: 0.0,
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: borderColor,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  size: 18,
                  color: Color(0xFF10B981),
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
        ),
      ),
    );
  }
}
