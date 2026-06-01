import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/presentation/widgets/activity_vertial_list.dart';
import 'package:macrotracker/core/presentation/widgets/copy_dialog.dart';
import 'package:macrotracker/core/presentation/widgets/delete_dialog.dart';
import 'package:macrotracker/core/utils/navigation_options.dart';
import 'package:macrotracker/core/utils/custom_icons.dart';
import 'package:macrotracker/features/activity_detail/activity_detail_screen.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:macrotracker/features/home/presentation/widgets/intake_vertical_list.dart';
import 'package:macrotracker/features/meal_detail/meal_detail_screen.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final mealCount = widget.breakfastIntake.length +
        widget.lunchIntake.length +
        widget.dinnerIntake.length +
        widget.snackIntake.length;

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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
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
                    child: Text(
                      S.of(context).nothingAddedLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
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
            ),
            const SizedBox(height: 12),
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
}

class _DaySummaryCard extends StatelessWidget {
  final TrackedDayEntity trackedDay;
  final int mealCount;
  final int activityCount;
  final bool canCopyDay;
  final VoidCallback? onCopyDayToToday;

  const _DaySummaryCard({
    required this.trackedDay,
    required this.mealCount,
    required this.activityCount,
    required this.canCopyDay,
    required this.onCopyDayToToday,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final kcalTracked = trackedDay.caloriesTracked.isNegative
        ? 0
        : trackedDay.caloriesTracked.toInt();
    final kcalGoal = trackedDay.calorieGoal.toInt();
    final kcalDelta = kcalTracked - kcalGoal;
    final proteinTracked = trackedDay.proteinTracked?.floor() ?? 0;
    final proteinGoal = trackedDay.proteinGoal?.floor() ?? 0;

    return Card(
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
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
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
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: trackedDay.getRatingDayTextColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            if (canCopyDay && onCopyDayToToday != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onCopyDayToToday,
                  icon: const Icon(Icons.content_copy_outlined, size: 18),
                  label: Text(S.of(context).diaryCopyDayToToday),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetricTile(
                    label: 'Kcal',
                    value: '$kcalTracked/$kcalGoal',
                    helper: kcalDelta == 0
                        ? S.of(context).diaryInGoal
                        : kcalDelta > 0
                            ? S.of(context).diaryKcalOver(kcalDelta)
                            : S.of(context).diaryKcalRemaining(kcalDelta.abs()),
                    accent: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetricTile(
                    label: 'Proteína',
                    value: '$proteinTracked/$proteinGoal g',
                    helper: proteinGoal > 0 && proteinTracked >= proteinGoal
                        ? S.of(context).diaryGoalReached
                        : S.of(context).diaryGramsRemaining(
                            (proteinGoal - proteinTracked).clamp(0, 9999)),
                    accent: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _macroTrackedDisplayString(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(
                  icon: Icons.restaurant_outlined,
                  label: S.of(context).diaryMealsPill(mealCount),
                ),
                _Pill(
                  icon: Icons.fitness_center_outlined,
                  label: S.of(context).diaryActivitiesPill(activityCount),
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

  String _macroTrackedDisplayString(BuildContext context) {
    final carbsTracked = trackedDay.carbsTracked?.floor().toString() ?? '?';
    final fatTracked = trackedDay.fatTracked?.floor().toString() ?? '?';
    final proteinTracked = trackedDay.proteinTracked?.floor().toString() ?? '?';
    final carbsGoal = trackedDay.carbsGoal?.floor().toString() ?? '?';
    final fatGoal = trackedDay.fatGoal?.floor().toString() ?? '?';
    final proteinGoal = trackedDay.proteinGoal?.floor().toString() ?? '?';

    return S.of(context).diaryMacrosSummary(carbsTracked, carbsGoal, fatTracked,
        fatGoal, proteinTracked, proteinGoal);
  }
}

class _SummaryMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String helper;
  final Color accent;

  const _SummaryMetricTile({
    required this.label,
    required this.value,
    required this.helper,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: accent.withValues(alpha: 0.08),
        border: Border.all(
          color: accent.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: Theme.of(context).textTheme.bodySmall,
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

  const _Pill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.45),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
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
