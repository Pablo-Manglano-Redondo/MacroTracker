import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macrotracker/core/domain/entity/intake_entity.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/presentation/widgets/activity_vertial_list.dart';
import 'package:macrotracker/core/presentation/widgets/copy_or_delete_dialog.dart';
import 'package:macrotracker/core/presentation/widgets/copy_dialog.dart';
import 'package:macrotracker/core/presentation/widgets/delete_dialog.dart';
import 'package:macrotracker/core/utils/custom_icons.dart';
import 'package:macrotracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:macrotracker/features/home/presentation/widgets/intake_vertical_list.dart';
import 'package:macrotracker/generated/l10n.dart';

class DayInfoWidget extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    final trackedDay = trackedDayEntity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DateFormat.yMMMMEEEEd().format(selectedDay),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            trackedDay == null
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.calendar_today_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              S.of(context).nothingAddedLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
            trackedDay != null
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Day summary',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: trackedDayEntity
                                      ?.getRatingDayTextBackgroundColor(
                                          context),
                                ),
                                child: Text(
                                  _getCaloriesTrackedDisplayString(trackedDay),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                          color: trackedDayEntity
                                              ?.getRatingDayTextColor(context),
                                          fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(_getMacroTrackedDisplayString(trackedDay),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _SummaryPill(
                                label:
                                    '${breakfastIntake.length + lunchIntake.length + dinnerIntake.length + snackIntake.length} meals',
                                icon: Icons.restaurant_outlined,
                              ),
                              _SummaryPill(
                                label: '${userActivities.length} activities',
                                icon: Icons.fitness_center_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 10.0),
            ActivityVerticalList(
                compact: true,
                day: selectedDay,
                title: S.of(context).activityLabel,
                userActivityList: userActivities,
                onItemLongPressedCallback: onActivityItemLongPressed),
            IntakeVerticalList(
              compact: true,
              day: selectedDay,
              title: S.of(context).breakfastLabel,
              listIcon: Icons.bakery_dining_outlined,
              addMealType: AddMealType.breakfastType,
              intakeList: breakfastIntake,
              onDeleteIntakeCallback: onDeleteIntake,
              onItemLongPressedCallback: onIntakeItemLongPressed,
              onCopyIntakeCallback:
                  DateUtils.isSameDay(selectedDay, DateTime.now())
                      ? null
                      : onCopyIntake,
              usesImperialUnits: usesImperialUnits,
              trackedDayEntity: trackedDay,
            ),
            IntakeVerticalList(
              compact: true,
              day: selectedDay,
              title: S.of(context).lunchLabel,
              listIcon: Icons.lunch_dining_outlined,
              addMealType: AddMealType.lunchType,
              intakeList: lunchIntake,
              onDeleteIntakeCallback: onDeleteIntake,
              onItemLongPressedCallback: onIntakeItemLongPressed,
              usesImperialUnits: usesImperialUnits,
              onCopyIntakeCallback:
                  DateUtils.isSameDay(selectedDay, DateTime.now())
                      ? null
                      : onCopyIntake,
              trackedDayEntity: trackedDay,
            ),
            IntakeVerticalList(
              compact: true,
              day: selectedDay,
              title: S.of(context).dinnerLabel,
              listIcon: Icons.dinner_dining_outlined,
              addMealType: AddMealType.dinnerType,
              intakeList: dinnerIntake,
              onDeleteIntakeCallback: onDeleteIntake,
              onItemLongPressedCallback: onIntakeItemLongPressed,
              onCopyIntakeCallback:
                  DateUtils.isSameDay(selectedDay, DateTime.now())
                      ? null
                      : onCopyIntake,
              usesImperialUnits: usesImperialUnits,
            ),
            IntakeVerticalList(
              compact: true,
              day: selectedDay,
              title: S.of(context).snackLabel,
              listIcon: CustomIcons.food_apple_outline,
              addMealType: AddMealType.snackType,
              intakeList: snackIntake,
              onDeleteIntakeCallback: onDeleteIntake,
              onItemLongPressedCallback: onIntakeItemLongPressed,
              usesImperialUnits: usesImperialUnits,
              onCopyIntakeCallback:
                  DateUtils.isSameDay(selectedDay, DateTime.now())
                      ? null
                      : onCopyIntake,
              trackedDayEntity: trackedDay,
            ),
            const SizedBox(height: 16.0)
          ],
        )
      ],
    );
  }

  String _getCaloriesTrackedDisplayString(TrackedDayEntity trackedDay) {
    int caloriesTracked;
    if (trackedDay.caloriesTracked.isNegative) {
      caloriesTracked = 0;
    } else {
      caloriesTracked = trackedDay.caloriesTracked.toInt();
    }

    return '$caloriesTracked/${trackedDay.calorieGoal.toInt()} kcal';
  }

  String _getMacroTrackedDisplayString(TrackedDayEntity trackedDay) {
    final carbsTracked = trackedDay.carbsTracked?.floor().toString() ?? '?';
    final fatTracked = trackedDay.fatTracked?.floor().toString() ?? '?';
    final proteinTracked = trackedDay.proteinTracked?.floor().toString() ?? '?';

    final carbsGoal = trackedDay.carbsGoal?.floor().toString() ?? '?';
    final fatGoal = trackedDay.fatGoal?.floor().toString() ?? '?';
    final proteinGoal = trackedDay.proteinGoal?.floor().toString() ?? '?';

    return 'Carbs: $carbsTracked/${carbsGoal}g, Fat: $fatTracked/${fatGoal}g, Protein: $proteinTracked/${proteinGoal}g';
  }

  void showCopyOrDeleteIntakeDialog(
      BuildContext context, IntakeEntity intakeEntity) async {
    final copyOrDelete = await showDialog<bool>(
        context: context, builder: (context) => const CopyOrDeleteDialog());
    if (context.mounted) {
      if (copyOrDelete != null && !copyOrDelete) {
        showDeleteIntakeDialog(context, intakeEntity);
      } else if (copyOrDelete != null && copyOrDelete) {
        showCopyDialog(context, intakeEntity);
      }
    }
  }

  void showCopyDialog(BuildContext context, IntakeEntity intakeEntity) async {
    const copyDialog = CopyDialog();
    final selectedMealType = await showDialog<AddMealType>(
        context: context, builder: (context) => copyDialog);
    if (selectedMealType != null) {
      onCopyIntake(intakeEntity, null, selectedMealType);
    }
  }

  void showDeleteIntakeDialog(
      BuildContext context, IntakeEntity intakeEntity) async {
    final shouldDeleteIntake = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());
    if (shouldDeleteIntake != null) {
      onDeleteIntake(intakeEntity, trackedDayEntity);
    }
  }

  void onIntakeItemLongPressed(
      BuildContext context, IntakeEntity intakeEntity) async {
    if (DateUtils.isSameDay(selectedDay, DateTime.now())) {
      showDeleteIntakeDialog(context, intakeEntity);
    } else {
      showCopyOrDeleteIntakeDialog(context, intakeEntity);
    }
  }

  void onActivityItemLongPressed(
      BuildContext context, UserActivityEntity activityEntity) async {
    final shouldDeleteActivity = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (shouldDeleteActivity != null) {
      onDeleteActivity(activityEntity, trackedDayEntity);
    }
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SummaryPill({
    required this.label,
    required this.icon,
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
