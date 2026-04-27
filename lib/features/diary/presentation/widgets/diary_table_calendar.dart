import 'package:flutter/material.dart';
import 'package:macrotracker/core/domain/entity/tracked_day_entity.dart';
import 'package:macrotracker/core/utils/extensions.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryTableCalendar extends StatefulWidget {
  final Function(DateTime, Map<String, TrackedDayEntity>) onDateSelected;
  final Duration calendarDurationDays;
  final DateTime focusedDate;
  final DateTime currentDate;
  final DateTime selectedDate;

  final Map<String, TrackedDayEntity> trackedDaysMap;

  const DiaryTableCalendar(
      {super.key,
      required this.onDateSelected,
      required this.calendarDurationDays,
      required this.focusedDate,
      required this.currentDate,
      required this.selectedDate,
      required this.trackedDaysMap});

  @override
  State<DiaryTableCalendar> createState() => _DiaryTableCalendarState();
}

class _DiaryTableCalendarState extends State<DiaryTableCalendar> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: TableCalendar(
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            leftChevronIcon:
                Icon(Icons.chevron_left, color: colorScheme.primary),
            rightChevronIcon:
                Icon(Icons.chevron_right, color: colorScheme.primary),
            titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
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
          firstDay: widget.currentDate.subtract(widget.calendarDurationDays),
          lastDay: widget.currentDate.add(widget.calendarDurationDays),
          startingDayOfWeek: StartingDayOfWeek.monday,
          onDaySelected: (selectedDay, focusedDay) {
            widget.onDateSelected(selectedDay, widget.trackedDaysMap);
          },
          calendarStyle: CalendarStyle(
              markersMaxCount: 1,
              outsideTextStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant) ??
                  const TextStyle(),
              defaultTextStyle:
                  Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
              todayTextStyle:
                  Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
              todayDecoration: BoxDecoration(
                  border: Border.all(color: colorScheme.primary, width: 1.8),
                  shape: BoxShape.circle),
              selectedTextStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colorScheme.onPrimary) ??
                  const TextStyle(),
              selectedDecoration: BoxDecoration(
                  color: colorScheme.primary, shape: BoxShape.circle)),
          selectedDayPredicate: (day) => isSameDay(widget.selectedDate, day),
          calendarBuilders:
              CalendarBuilders(markerBuilder: (context, date, events) {
            final trackedDay = widget.trackedDaysMap[date.toParsedDay()];
            if (trackedDay != null) {
              return Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: trackedDay.getCalendarDayRatingColor(context)),
                width: 5.0,
                height: 5.0,
              );
            } else {
              return const SizedBox();
            }
          }),
        ),
      ),
    );
  }
}
