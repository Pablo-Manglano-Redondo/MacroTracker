import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/utils/extensions.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryTableCalendar extends StatefulWidget {
  final Function(DateTime, Map<String, TrackedDayEntity>) onDateSelected;
  final ValueChanged<DateTime>? onPageChanged;
  final Duration calendarDurationDays;
  final DateTime focusedDate;
  final DateTime currentDate;
  final DateTime selectedDate;
  final Map<String, TrackedDayEntity> trackedDaysMap;

  const DiaryTableCalendar({
    super.key,
    required this.onDateSelected,
    this.onPageChanged,
    required this.calendarDurationDays,
    required this.focusedDate,
    required this.currentDate,
    required this.selectedDate,
    required this.trackedDaysMap,
  });

  @override
  State<DiaryTableCalendar> createState() => _DiaryTableCalendarState();
}

class _DiaryTableCalendarState extends State<DiaryTableCalendar> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          children: [
            TableCalendar(
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: colorScheme.primary),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: colorScheme.primary),
                titleTextStyle:
                    Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                weekendStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              focusedDay: widget.focusedDate,
              firstDay:
                  widget.currentDate.subtract(widget.calendarDurationDays),
              lastDay: widget.currentDate.add(widget.calendarDurationDays),
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (selectedDay, focusedDay) {
                widget.onDateSelected(selectedDay, widget.trackedDaysMap);
              },
              onPageChanged: (focusedDay) {
                widget.onPageChanged?.call(focusedDay);
              },
              calendarStyle: CalendarStyle(
                outsideTextStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant) ??
                    const TextStyle(),
                defaultTextStyle:
                    Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
                todayTextStyle:
                    Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
                selectedTextStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colorScheme.onPrimary) ??
                    const TextStyle(),
                todayDecoration: const BoxDecoration(),
                selectedDecoration: const BoxDecoration(),
                markersMaxCount: 0,
              ),
              selectedDayPredicate: (day) =>
                  isSameDay(widget.selectedDate, day),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) =>
                    _buildDayCell(context, day),
                todayBuilder: (context, day, focusedDay) =>
                    _buildDayCell(context, day, isToday: true),
                selectedBuilder: (context, day, focusedDay) =>
                    _buildDayCell(context, day, isSelected: true),
                outsideBuilder: (context, day, focusedDay) =>
                    _buildDayCell(context, day, isOutside: true),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _LegendChip(
                  color: colorScheme.primary,
                  label: 'Kcal en rango',
                ),
                _LegendChip(
                  color: colorScheme.error,
                  label: 'Kcal desviadas',
                ),
                _LegendChip(
                  color: colorScheme.tertiary,
                  label: 'Proteína cumplida',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
    bool isOutside = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final trackedDay = widget.trackedDaysMap[day.toParsedDay()];
    final backgroundColor = isSelected
        ? colorScheme.primary
        : trackedDay == null
            ? Colors.transparent
            : trackedDay.getCalendarDayRatingColor(context).withValues(
                  alpha: 0.10 + (trackedDay.calorieAdherenceScore * 0.10),
                );
    final borderColor = isSelected
        ? colorScheme.primary
        : isToday
            ? colorScheme.primary
            : trackedDay == null
                ? colorScheme.outlineVariant.withValues(alpha: 0.10)
                : trackedDay.getCalendarDayRatingColor(context).withValues(
                      alpha: 0.30,
                    );
    final textColor = isSelected
        ? colorScheme.onPrimary
        : isOutside
            ? colorScheme.onSurfaceVariant.withValues(alpha: 0.55)
            : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isToday || isSelected ? 1.6 : 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${day.day}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
            ),
            if (trackedDay != null)
              Positioned(
                bottom: 5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: trackedDay.getCalendarDayRatingColor(context),
                      ),
                    ),
                    if (trackedDay.isProteinOnTarget) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendChip({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.10),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
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
