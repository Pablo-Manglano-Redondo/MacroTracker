import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/presentation/widgets/activity_vertial_list.dart';
import 'package:macrotracker/core/presentation/widgets/copy_dialog.dart';
import 'package:macrotracker/core/presentation/widgets/copy_or_delete_dialog.dart';
import 'package:macrotracker/core/presentation/widgets/delete_dialog.dart';
import 'package:macrotracker/core/utils/custom_icons.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:macrotracker/features/home/presentation/widgets/intake_vertical_list.dart';
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
    required this.onCopyActivity,
    this.onCopyDayToToday,
  });

  @override
  State<DayInfoWidget> createState() => _DayInfoWidgetState();
}

class _DayInfoWidgetState extends State<DayInfoWidget> {
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
  Widget build(BuildContext context) {
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
        if (trackedDay == null)
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
          _DaySummaryCard(
            trackedDay: trackedDay,
            mealCount: mealCount,
            activityCount: widget.userActivities.length,
            canCopyDay:
                !DateUtils.isSameDay(widget.selectedDay, DateTime.now()),
            onCopyDayToToday: widget.onCopyDayToToday,
          ),
          const SizedBox(height: 12),
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

  void _showCopyOrDeleteIntakeDialog(
      BuildContext context, IntakeEntity intakeEntity) async {
    final copyOrDelete = await showDialog<bool>(
      context: context,
      builder: (context) => const CopyOrDeleteDialog(),
    );
    if (!context.mounted) return;
    if (copyOrDelete != null && !copyOrDelete) {
      _showDeleteIntakeDialog(context, intakeEntity);
    } else if (copyOrDelete != null && copyOrDelete) {
      _showCopyDialog(context, intakeEntity);
    }
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
    if (DateUtils.isSameDay(widget.selectedDay, DateTime.now())) {
      _showDeleteIntakeDialog(context, intakeEntity);
    } else {
      _showCopyOrDeleteIntakeDialog(context, intakeEntity);
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
                    'Resumen del día',
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
                    _statusLabel(),
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
                  label: const Text('Copiar día a hoy'),
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
                        ? 'En objetivo'
                        : kcalDelta > 0
                            ? '+$kcalDelta kcal'
                            : '${kcalDelta.abs()} kcal restantes',
                    accent: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetricTile(
                    label: 'Proteína',
                    value: '$proteinTracked/$proteinGoal g',
                    helper: proteinGoal > 0 && proteinTracked >= proteinGoal
                        ? 'Objetivo cumplido'
                        : '${(proteinGoal - proteinTracked).clamp(0, 9999)} g restantes',
                    accent: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _macroTrackedDisplayString(),
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
                  label: '$mealCount comidas',
                ),
                _Pill(
                  icon: Icons.fitness_center_outlined,
                  label: '$activityCount actividades',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel() {
    final difference = trackedDay.calorieGoal - trackedDay.caloriesTracked;
    if (difference.abs() <= 150) return 'En rango';
    if (difference > 150) return 'Por debajo';
    return 'Por encima';
  }

  String _macroTrackedDisplayString() {
    final carbsTracked = trackedDay.carbsTracked?.floor().toString() ?? '?';
    final fatTracked = trackedDay.fatTracked?.floor().toString() ?? '?';
    final proteinTracked = trackedDay.proteinTracked?.floor().toString() ?? '?';
    final carbsGoal = trackedDay.carbsGoal?.floor().toString() ?? '?';
    final fatGoal = trackedDay.fatGoal?.floor().toString() ?? '?';
    final proteinGoal = trackedDay.proteinGoal?.floor().toString() ?? '?';

    return 'Carbohidratos $carbsTracked/$carbsGoal g, grasas $fatTracked/$fatGoal g, proteína $proteinTracked/$proteinGoal g';
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
            count == 0 ? 'Vacío' : '$count elementos',
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
