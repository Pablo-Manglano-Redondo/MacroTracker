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
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
        child: Column(
          children: [
            TableCalendar(
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                headerPadding: const EdgeInsets.only(bottom: 8),
                leftChevronIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.chevron_left,
                      color: colorScheme.primary, size: 18),
                ),
                rightChevronIcon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.chevron_right,
                      color: colorScheme.primary, size: 18),
                ),
                titleTextStyle:
                    Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                weekendStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
              ),
              daysOfWeekHeight: 28,
              rowHeight: 46,
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
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(),
                selectedDecoration: BoxDecoration(),
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
            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: colorScheme.primary, label: 'En rango'),
                const SizedBox(width: 16),
                _LegendItem(color: colorScheme.error, label: 'Desviadas'),
                const SizedBox(width: 16),
                _LegendItem(color: colorScheme.tertiary, label: 'Proteína'),
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

    Color? bgColor;
    Color textColor;
    FontWeight fontWeight;

    if (isSelected) {
      bgColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
      fontWeight = FontWeight.w700;
    } else if (isToday) {
      bgColor = colorScheme.primary.withValues(alpha: 0.12);
      textColor = colorScheme.primary;
      fontWeight = FontWeight.w700;
    } else if (isOutside) {
      bgColor = null;
      textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
      fontWeight = FontWeight.w400;
    } else if (trackedDay != null) {
      bgColor =
          trackedDay.getCalendarDayRatingColor(context).withValues(alpha: 0.08);
      textColor = colorScheme.onSurface;
      fontWeight = FontWeight.w500;
    } else {
      bgColor = null;
      textColor = colorScheme.onSurface;
      fontWeight = FontWeight.w400;
    }

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isToday && !isSelected
              ? Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.4),
                  width: 1.5,
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${day.day}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: fontWeight,
                  ),
            ),
            if (trackedDay != null)
              Positioned(
                bottom: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? colorScheme.onPrimary.withValues(alpha: 0.85)
                            : trackedDay.getCalendarDayRatingColor(context),
                      ),
                    ),
                    if (trackedDay.isProteinOnTarget) ...[
                      const SizedBox(width: 3),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? colorScheme.onPrimary.withValues(alpha: 0.85)
                              : colorScheme.tertiary,
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
