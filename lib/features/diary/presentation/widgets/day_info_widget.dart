import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/presentation/widgets/activity_vertical_list.dart';
import 'package:macrotracker/core/presentation/widgets/copy_dialog.dart';
import 'package:macrotracker/core/presentation/widgets/delete_dialog.dart';
import 'package:macrotracker/core/domain/entity/intake_type_entity.dart';
import 'package:macrotracker/core/presentation/widgets/meal_entry_action_sheet.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/core/utils/custom_icons.dart';
import 'package:macrotracker/features/activity_detail/activity_detail_screen.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:macrotracker/features/home/presentation/widgets/intake_vertical_list.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_photo_capture_screen.dart';
import 'package:macrotracker/features/meal_capture/presentation/meal_text_capture_screen.dart';
import 'package:macrotracker/features/meal_detail/meal_detail_screen.dart';
import 'package:macrotracker/features/scanner/scanner_screen.dart';
import 'package:macrotracker/generated/l10n.dart';

class DayInfoWidget extends StatefulWidget {
  final DateTime selectedDay;
  final TrackedDayEntity? trackedDayEntity;
  final List<UserActivityEntity> userActivities;
  final List<IntakeEntity> breakfastIntake;
  final List<IntakeEntity> lunchIntake;
  final List<IntakeEntity> dinnerIntake;
  final List<IntakeEntity> snackIntake;
  final bool usesImperialUnits;
  final Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity)
      onDeleteIntake;
  final Function(UserActivityEntity userActivityEntity,
      TrackedDayEntity? trackedDayEntity) onDeleteActivity;
  final Function(IntakeEntity intake, TrackedDayEntity? trackedDayEntity,
      AddMealType? type) onCopyIntake;
  final Future<void> Function(
      IntakeEntity intake,
      TrackedDayEntity? trackedDayEntity,
      double newAmount) onAdjustIntakeAmount;
  final Function(UserActivityEntity userActivityEntity,
      TrackedDayEntity? trackedDayEntity) onCopyActivity;
  final VoidCallback? onCopyDayToToday;

  const DayInfoWidget({
    super.key,
    required this.selectedDay,
    required this.trackedDayEntity,
    required this.userActivities,
    required this.breakfastIntake,
    required this.lunchIntake,
    required this.dinnerIntake,
    required this.snackIntake,
    required this.usesImperialUnits,
    required this.onDeleteIntake,
    required this.onDeleteActivity,
    required this.onCopyIntake,
    required this.onAdjustIntakeAmount,
    required this.onCopyActivity,
    this.onCopyDayToToday,
  });

  @override
  State<DayInfoWidget> createState() => _DayInfoWidgetState();
}


class _DayInfoWidgetState extends State<DayInfoWidget>
    with AutomaticKeepAliveClientMixin {
  late bool _showActivity;
  late bool _showBreakfast;
  late bool _showLunch;
  late bool _showDinner;
  late bool _showSnack;

  @override
  void initState() {
    super.initState();
    _syncSectionState();
  }

  @override
  void didUpdateWidget(covariant DayInfoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DateUtils.isSameDay(oldWidget.selectedDay, widget.selectedDay)) {
      _syncSectionState();
    } else {
      if (oldWidget.userActivities.isEmpty &&
          widget.userActivities.isNotEmpty) {
        _showActivity = true;
      }
      if (oldWidget.breakfastIntake.isEmpty &&
          widget.breakfastIntake.isNotEmpty) {
        _showBreakfast = true;
      }
      if (oldWidget.lunchIntake.isEmpty && widget.lunchIntake.isNotEmpty) {
        _showLunch = true;
      }
      if (oldWidget.dinnerIntake.isEmpty && widget.dinnerIntake.isNotEmpty) {
        _showDinner = true;
      }
      if (oldWidget.snackIntake.isEmpty && widget.snackIntake.isNotEmpty) {
        _showSnack = true;
      }
    }
  }

  void _syncSectionState() {
    _showActivity = widget.userActivities.isNotEmpty;
    _showBreakfast = widget.breakfastIntake.isNotEmpty;
    _showLunch = widget.lunchIntake.isNotEmpty;
    _showDinner = widget.dinnerIntake.isNotEmpty;
    _showSnack = widget.snackIntake.isNotEmpty;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final trackedDay = widget.trackedDayEntity;
    final mealCount = widget.breakfastIntake.length +
        widget.lunchIntake.length +
        widget.dinnerIntake.length +
        widget.snackIntake.length;

    final allIntakes = [
      ...widget.breakfastIntake,
      ...widget.lunchIntake,
      ...widget.dinnerIntake,
      ...widget.snackIntake
    ];
    final totalSodium = allIntakes.fold(0.0, (sum, item) => sum + item.totalSodiumMg);
    final totalPotassium = allIntakes.fold(0.0, (sum, item) => sum + item.totalPotassiumMg);
    final totalCalcium = allIntakes.fold(0.0, (sum, item) => sum + item.totalCalciumMg);
    final totalIron = allIntakes.fold(0.0, (sum, item) => sum + item.totalIronMg);
    final totalVitaminC = allIntakes.fold(0.0, (sum, item) => sum + item.totalVitaminCMg);
    final totalVitaminD = allIntakes.fold(0.0, (sum, item) => sum + item.totalVitaminDMcg);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.yMMMMEEEEd().format(widget.selectedDay),
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12.0),
        if (trackedDay == null &&
            widget.userActivities.isEmpty &&
            widget.breakfastIntake.isEmpty &&
            widget.lunchIntake.isEmpty &&
            widget.dinnerIntake.isEmpty &&
            widget.snackIntake.isEmpty)
          _DiaryEmptyDayCard(
            day: widget.selectedDay,
            onAddMeal: () => MealEntryActionSheet.show(
              context,
              day: widget.selectedDay,
            ),
            onScanPressed: () => Navigator.of(context).pushNamed(
              NavigationOptions.scannerRoute,
              arguments: ScannerScreenArguments(
                widget.selectedDay,
                _defaultIntakeType(),
              ),
            ),
            onTextAIPressed: () => Navigator.of(context).pushNamed(
              NavigationOptions.mealTextCaptureRoute,
              arguments: MealTextCaptureScreenArguments(
                widget.selectedDay,
                _defaultIntakeType(),
              ),
            ),
            onPhotoAIPressed: () => Navigator.of(context).pushNamed(
              NavigationOptions.mealPhotoCaptureRoute,
              arguments: MealPhotoCaptureScreenArguments(
                widget.selectedDay,
                _defaultIntakeType(),
              ),
            ),
          )
        else ...[
          if (trackedDay != null) ...[
            _DaySummaryCard(
              trackedDay: trackedDay,
              mealCount: mealCount,
              activityCount: widget.userActivities.length,
              canCopyDay:
                  !DateUtils.isSameDay(widget.selectedDay, DateTime.now()),
              onCopyDayToToday: widget.onCopyDayToToday,
              totalSodium: totalSodium,
              totalPotassium: totalPotassium,
              totalCalcium: totalCalcium,
              totalIron: totalIron,
              totalVitaminC: totalVitaminC,
              totalVitaminD: totalVitaminD,
            ),
            const SizedBox(height: 18),
          ],
          _DiaryExpandableSection(
            title: S.of(context).activityLabel,
            icon: UserActivityEntity.getIconData(),
            count: widget.userActivities.length,
            trailing: null,
            initiallyExpanded: _showActivity,
            onExpansionChanged: (value) =>
                setState(() => _showActivity = value),
            child: ActivityVerticalList(
              compact: true,
              showHeader: false,
              day: widget.selectedDay,
              title: S.of(context).activityLabel,
              userActivityList: widget.userActivities,
              onItemLongPressedCallback: _onActivityItemLongPressed,
              onItemTappedCallback: _openActivityDetails,
            ),
          ),
          const SizedBox(height: 10),
          _DiaryExpandableSection(
            title: S.of(context).breakfastLabel,
            icon: Icons.bakery_dining_outlined,
            count: widget.breakfastIntake.length,
            trailing: _buildKcalBadge(widget.breakfastIntake),
            initiallyExpanded: _showBreakfast,
            onExpansionChanged: (value) =>
                setState(() => _showBreakfast = value),
            child: IntakeVerticalList(
              compact: true,
              showHeader: false,
              day: widget.selectedDay,
              title: S.of(context).breakfastLabel,
              listIcon: Icons.bakery_dining_outlined,
              addMealType: AddMealType.breakfastType,
              intakeList: widget.breakfastIntake,
              onDeleteIntakeCallback: widget.onDeleteIntake,
              onItemLongPressedCallback: _onIntakeItemLongPressed,
              onItemTappedCallback: _openIntakeDetails,
              onCopyIntakeCallback:
                  DateUtils.isSameDay(widget.selectedDay, DateTime.now())
                      ? null
                      : widget.onCopyIntake,
              usesImperialUnits: widget.usesImperialUnits,
              trackedDayEntity: trackedDay,
            ),
          ),
          const SizedBox(height: 10),
          _DiaryExpandableSection(
            title: S.of(context).lunchLabel,
            icon: Icons.lunch_dining_outlined,
            count: widget.lunchIntake.length,
            trailing: _buildKcalBadge(widget.lunchIntake),
            initiallyExpanded: _showLunch,
            onExpansionChanged: (value) => setState(() => _showLunch = value),
            child: IntakeVerticalList(
              compact: true,
              showHeader: false,
              day: widget.selectedDay,
              title: S.of(context).lunchLabel,
              listIcon: Icons.lunch_dining_outlined,
              addMealType: AddMealType.lunchType,
              intakeList: widget.lunchIntake,
              onDeleteIntakeCallback: widget.onDeleteIntake,
              onItemLongPressedCallback: _onIntakeItemLongPressed,
              onItemTappedCallback: _openIntakeDetails,
              usesImperialUnits: widget.usesImperialUnits,
              onCopyIntakeCallback:
                  DateUtils.isSameDay(widget.selectedDay, DateTime.now())
                      ? null
                      : widget.onCopyIntake,
              trackedDayEntity: trackedDay,
            ),
          ),
          const SizedBox(height: 10),
          _DiaryExpandableSection(
            title: S.of(context).dinnerLabel,
            icon: Icons.dinner_dining_outlined,
            count: widget.dinnerIntake.length,
            trailing: _buildKcalBadge(widget.dinnerIntake),
            initiallyExpanded: _showDinner,
            onExpansionChanged: (value) => setState(() => _showDinner = value),
            child: IntakeVerticalList(
              compact: true,
              showHeader: false,
              day: widget.selectedDay,
              title: S.of(context).dinnerLabel,
              listIcon: Icons.dinner_dining_outlined,
              addMealType: AddMealType.dinnerType,
              intakeList: widget.dinnerIntake,
              onDeleteIntakeCallback: widget.onDeleteIntake,
              onItemLongPressedCallback: _onIntakeItemLongPressed,
              onItemTappedCallback: _openIntakeDetails,
              onCopyIntakeCallback:
                  DateUtils.isSameDay(widget.selectedDay, DateTime.now())
                      ? null
                      : widget.onCopyIntake,
              usesImperialUnits: widget.usesImperialUnits,
              trackedDayEntity: trackedDay,
            ),
          ),
          const SizedBox(height: 10),
          _DiaryExpandableSection(
            title: S.of(context).snackLabel,
            icon: CustomIcons.food_apple_outline,
            count: widget.snackIntake.length,
            trailing: _buildKcalBadge(widget.snackIntake),
            initiallyExpanded: _showSnack,
            onExpansionChanged: (value) => setState(() => _showSnack = value),
            child: IntakeVerticalList(
              compact: true,
              showHeader: false,
              day: widget.selectedDay,
              title: S.of(context).snackLabel,
              listIcon: CustomIcons.food_apple_outline,
              addMealType: AddMealType.snackType,
              intakeList: widget.snackIntake,
              onDeleteIntakeCallback: widget.onDeleteIntake,
              onItemLongPressedCallback: _onIntakeItemLongPressed,
              onItemTappedCallback: _openIntakeDetails,
              usesImperialUnits: widget.usesImperialUnits,
              onCopyIntakeCallback:
                  DateUtils.isSameDay(widget.selectedDay, DateTime.now())
                      ? null
                      : widget.onCopyIntake,
              trackedDayEntity: trackedDay,
            ),
          ),
        ],
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget? _buildKcalBadge(List<IntakeEntity> intakeList) {
    final totalKcal =
        intakeList.fold<double>(0, (sum, item) => sum + item.totalKcal);
    if (totalKcal <= 0) return null;
    return _Pill(
      icon: Icons.local_fire_department_outlined,
      label: '${totalKcal.toInt()} kcal',
    );
  }

  void _showCopyDialog(BuildContext context, IntakeEntity intakeEntity) async {
    const copyDialog = CopyDialog();
    final selectedMealType = await showDialog<AddMealType>(
      context: context,
      builder: (context) => copyDialog,
    );
    if (selectedMealType != null) {
      widget.onCopyIntake(intakeEntity, null, selectedMealType);
    }
  }

  void _showDeleteIntakeDialog(
      BuildContext context, IntakeEntity intakeEntity) async {
    final shouldDeleteIntake = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteDialog(),
    );
    if (shouldDeleteIntake != null) {
      widget.onDeleteIntake(intakeEntity, widget.trackedDayEntity);
    }
  }

  void _onIntakeItemLongPressed(
      BuildContext context, IntakeEntity intakeEntity) async {
    final result = await showDialog<_IntakeQuickActionResult>(
      context: context,
      builder: (context) => _IntakeQuickActionDialog(
        intakeEntity: intakeEntity,
        isToday: DateUtils.isSameDay(widget.selectedDay, DateTime.now()),
      ),
    );
    if (!context.mounted || result == null) {
      return;
    }

    switch (result.action) {
      case _IntakeQuickAction.delete:
        _showDeleteIntakeDialog(context, intakeEntity);
        break;
      case _IntakeQuickAction.copy:
        _showCopyDialog(context, intakeEntity);
        break;
      case _IntakeQuickAction.updateAmount:
        await widget.onAdjustIntakeAmount(
          intakeEntity,
          widget.trackedDayEntity,
          result.amount ?? intakeEntity.amount,
        );
        break;
    }
  }

  void _onActivityItemLongPressed(
      BuildContext context, UserActivityEntity activityEntity) async {
    final shouldDeleteActivity = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteDialog(),
    );

    if (shouldDeleteActivity != null) {
      widget.onDeleteActivity(activityEntity, widget.trackedDayEntity);
    }
  }

  void _openIntakeDetails(
    BuildContext context,
    IntakeEntity intakeEntity,
    bool usesImperialUnits,
  ) {
    Navigator.of(context).pushNamed(
      NavigationOptions.mealDetailRoute,
      arguments: MealDetailScreenArguments(
        intakeEntity.meal,
        intakeEntity.type,
        widget.selectedDay,
        usesImperialUnits,
        intakeEntity: intakeEntity,
      ),
    );
  }

  void _openActivityDetails(
    BuildContext context,
    UserActivityEntity activityEntity,
  ) {
    Navigator.of(context).pushNamed(
      NavigationOptions.activityDetailRoute,
      arguments: ActivityDetailScreenArguments(
        activityEntity.physicalActivityEntity,
        widget.selectedDay,
        userActivityEntity: activityEntity,
      ),
    );
  }

  IntakeTypeEntity _defaultIntakeType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return IntakeTypeEntity.breakfast;
    if (hour < 16) return IntakeTypeEntity.lunch;
    if (hour < 20) return IntakeTypeEntity.snack;
    return IntakeTypeEntity.dinner;
  }
}

class _DaySummaryCard extends StatelessWidget {
  final TrackedDayEntity trackedDay;
  final int mealCount;
  final int activityCount;
  final bool canCopyDay;
  final VoidCallback? onCopyDayToToday;
  final double totalSodium;
  final double totalPotassium;
  final double totalCalcium;
  final double totalIron;
  final double totalVitaminC;
  final double totalVitaminD;

  const _DaySummaryCard({
    required this.trackedDay,
    required this.mealCount,
    required this.activityCount,
    required this.canCopyDay,
    required this.onCopyDayToToday,
    this.totalSodium = 0,
    this.totalPotassium = 0,
    this.totalCalcium = 0,
    this.totalIron = 0,
    this.totalVitaminC = 0,
    this.totalVitaminD = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final kcalTracked = trackedDay.caloriesTracked.isNegative
        ? 0
        : trackedDay.caloriesTracked.toInt();
    final kcalGoal = trackedDay.calorieGoal.toInt();
    final kcalDelta = kcalTracked - kcalGoal;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    S.of(context).diarySummaryTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: trackedDay.getRatingDayTextBackgroundColor(context),
                  ),
                  child: Text(
                    _statusLabel(context),
                    style: theme.textTheme.labelMedium?.copyWith(
                          color: trackedDay.getRatingDayTextColor(context),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            if (canCopyDay && onCopyDayToToday != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onCopyDayToToday,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.content_copy_outlined, size: 16),
                label: Text(
                  S.of(context).diaryCopyDayToToday,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Primary Calorie Progress Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: colorScheme.primary.withValues(alpha: 0.05),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).professionalMacroCalories,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '$kcalTracked / $kcalGoal kcal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: kcalGoal <= 0 ? 0.0 : (kcalTracked / kcalGoal).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    kcalDelta == 0
                        ? S.of(context).diaryInGoal
                        : kcalDelta > 0
                            ? S.of(context).diaryKcalOver(kcalDelta)
                            : S.of(context).diaryKcalRemaining(kcalDelta.abs()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Macronutrients row
            Row(
              children: [
                Expanded(
                  child: _MacroDetailTile(
                    label: S.of(context).proteinLabel,
                    tracked: trackedDay.proteinTracked ?? 0,
                    goal: trackedDay.proteinGoal ?? 0,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MacroDetailTile(
                    label: S.of(context).carbsLabel,
                    tracked: trackedDay.carbsTracked ?? 0,
                    goal: trackedDay.carbsGoal ?? 0,
                    color: const Color(0xFFE7A83B),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MacroDetailTile(
                    label: S.of(context).fatLabel,
                    tracked: trackedDay.fatTracked ?? 0,
                    goal: trackedDay.fatGoal ?? 0,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            if (totalSodium > 0 || totalPotassium > 0 || totalCalcium > 0 || totalIron > 0 || totalVitaminC > 0 || totalVitaminD > 0) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (totalSodium > 0) _MicroDetailPill(label: S.of(context).sodiumLabel, value: '${totalSodium.round()}mg'),
                  if (totalPotassium > 0) _MicroDetailPill(label: S.of(context).potassiumLabel, value: '${totalPotassium.round()}mg'),
                  if (totalCalcium > 0) _MicroDetailPill(label: S.of(context).calciumLabel, value: '${totalCalcium.round()}mg'),
                  if (totalIron > 0) _MicroDetailPill(label: S.of(context).ironLabel, value: '${totalIron.round()}mg'),
                  if (totalVitaminC > 0) _MicroDetailPill(label: S.of(context).vitaminCLabel, value: '${totalVitaminC.round()}mg'),
                  if (totalVitaminD > 0) _MicroDetailPill(label: S.of(context).vitaminDLabel, value: '${totalVitaminD.round()}µg'),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(
                  icon: Icons.restaurant_outlined,
                  label: S.of(context).diaryMealsPill(mealCount),
                  color: colorScheme.primary,
                ),
                _Pill(
                  icon: Icons.fitness_center_outlined,
                  label: S.of(context).diaryActivitiesPill(activityCount),
                  color: colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(BuildContext context) {
    final difference = trackedDay.calorieGoal - trackedDay.caloriesTracked;
    if (difference.abs() <= 150) return S.of(context).diaryStatusInRange;
    if (difference > 150) return S.of(context).diaryStatusBelow;
    return S.of(context).diaryStatusAbove;
  }
}

class _DiaryEmptyDayCard extends StatelessWidget {
  final DateTime day;
  final VoidCallback onAddMeal;
  final VoidCallback onScanPressed;
  final VoidCallback onTextAIPressed;
  final VoidCallback onPhotoAIPressed;

  const _DiaryEmptyDayCard({
    required this.day,
    required this.onAddMeal,
    required this.onScanPressed,
    required this.onTextAIPressed,
    required this.onPhotoAIPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: colorScheme.surfaceContainerHigh,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).diaryEmptyDayTitle,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        S.of(context).diaryEmptyDaySubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onAddMeal,
                  icon: const Icon(Icons.restaurant_outlined),
                  label: Text(S.of(context).diaryAddMealAction),
                ),
                IconButton.filledTonal(
                  onPressed: onScanPressed,
                  icon: const Icon(Icons.qr_code_scanner_outlined),
                  tooltip: S.of(context).scanProductLabel,
                ),
                IconButton.filledTonal(
                  onPressed: onTextAIPressed,
                  icon: const Icon(Icons.edit_note_outlined),
                  tooltip: S.of(context).addMealText,
                ),
                IconButton.filledTonal(
                  onPressed: onPhotoAIPressed,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  tooltip: S.of(context).addMealPhoto,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroDetailTile extends StatelessWidget {
  final String label;
  final double tracked;
  final double goal;
  final Color color;

  const _MacroDetailTile({
    required this.label,
    required this.tracked,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = goal <= 0 ? 0.0 : (tracked / goal).clamp(0.0, 1.0);
    final remaining = (goal - tracked).clamp(0.0, 9999.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.05),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${tracked.round()}/${goal.round()}g',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: color.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            remaining <= 0
                ? S.of(context).diaryGoalReached
                : S.of(context).diaryGramsRemaining(remaining.round()),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaryExpandableSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Widget? trailing;
  final bool initiallyExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final Widget child;

  const _DiaryExpandableSection({
    required this.title,
    required this.icon,
    required this.count,
    required this.trailing,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          maintainState: true,
          initiallyExpanded: initiallyExpanded,
          onExpansionChanged: onExpansionChanged,
          leading: Icon(icon, color: colorScheme.primary),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          subtitle: Text(
            count == 0
                ? S.of(context).diaryEmptySection
                : S.of(context).diaryElementsSection(count),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          trailing: Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Pill(
                icon: Icons.grid_view_rounded,
                label: '$count',
                color: colorScheme.onSurfaceVariant,
              ),
              if (trailing != null) trailing!,
              Icon(
                initiallyExpanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          children: [child],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _Pill({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeColor = color ?? colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: activeColor.withValues(alpha: 0.08),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: activeColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

enum _IntakeQuickAction {
  updateAmount,
  copy,
  delete,
}

class _IntakeQuickActionResult {
  final _IntakeQuickAction action;
  final double? amount;

  const _IntakeQuickActionResult(this.action, {this.amount});
}

class _IntakeQuickActionDialog extends StatefulWidget {
  final IntakeEntity intakeEntity;
  final bool isToday;

  const _IntakeQuickActionDialog({
    required this.intakeEntity,
    required this.isToday,
  });

  @override
  State<_IntakeQuickActionDialog> createState() =>
      _IntakeQuickActionDialogState();
}

class _IntakeQuickActionDialogState extends State<_IntakeQuickActionDialog> {
  late double _amount;
  late final double _step;

  @override
  void initState() {
    super.initState();
    _amount = widget.intakeEntity.amount;
    _step = _stepForUnit(widget.intakeEntity.unit);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(S.of(context).diaryQuickAmountTitle),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.intakeEntity.meal.name ?? '',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              S.of(context).diaryQuickAmountSubtitle(
                    _formatAmount(_step),
                    widget.intakeEntity.unit,
                  ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  IconButton.outlined(
                    onPressed: _decrease,
                    icon: const Icon(Icons.remove),
                    tooltip: S.of(context).diaryQuickAmountDecrease,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _formatAmount(_amount),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.intakeEntity.unit,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: _increase,
                    icon: const Icon(Icons.add),
                    tooltip: S.of(context).diaryQuickAmountIncrease,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (!widget.isToday)
          TextButton(
            onPressed: () => Navigator.of(context).pop(
              const _IntakeQuickActionResult(_IntakeQuickAction.copy),
            ),
            child: Text(S.of(context).dialogCopyLabel),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            const _IntakeQuickActionResult(_IntakeQuickAction.delete),
          ),
          child: Text(S.of(context).dialogDeleteLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _IntakeQuickActionResult(
              _IntakeQuickAction.updateAmount,
              amount: _amount,
            ),
          ),
          child: Text(S.of(context).buttonSaveLabel),
        ),
      ],
    );
  }

  void _increase() {
    setState(() {
      _amount += _step;
    });
  }

  void _decrease() {
    setState(() {
      final minAmount = _minimumAmountForUnit(widget.intakeEntity.unit);
      final next = _amount - _step;
      _amount = next < minAmount ? minAmount : next;
    });
  }

  double _stepForUnit(String unit) {
    switch (unit) {
      case 'serving':
      case 'oz':
      case 'fl.oz':
      case 'fl oz':
        return 0.5;
      case 'g':
      case 'ml':
      case 'g/ml':
      default:
        return 25;
    }
  }

  double _minimumAmountForUnit(String unit) {
    switch (unit) {
      case 'serving':
      case 'oz':
      case 'fl.oz':
      case 'fl oz':
        return 0.5;
      case 'g':
      case 'ml':
      case 'g/ml':
      default:
        return 25;
    }
  }

  String _formatAmount(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}

class _MicroDetailPill extends StatelessWidget {
  final String label;
  final String value;

  const _MicroDetailPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeColor = colorScheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: activeColor.withValues(alpha: 0.08),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
