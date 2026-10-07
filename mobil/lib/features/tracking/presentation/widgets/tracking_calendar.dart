import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class TrackingCalendar extends StatelessWidget {
  const TrackingCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    this.onPageChanged,
    this.dayColor,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final void Function(DateTime focusedDay)? onPageChanged;

  /// Optional background color for a given day's cell, e.g. to reflect that
  /// day's completed-prayers count. Returning null keeps the default style.
  final Color? Function(DateTime day)? dayColor;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'uz',
      firstDay: DateTime(2020, 1, 1),
      lastDay: DateTime(2100, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      rowHeight: 42,
      daysOfWeekHeight: 20,
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        weekendStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextFormatter: (date, locale) => '${DateFormat.MMMM('uz').format(date)} ${date.year}',
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) => _DayCell(day: day, background: dayColor?.call(day)),
        outsideBuilder: (context, day, focusedDay) =>
            _DayCell(day: day, isOutside: true, background: dayColor?.call(day)),
        todayBuilder: (context, day, focusedDay) => _DayCell(day: day, background: dayColor?.call(day)),
        selectedBuilder: (context, day, focusedDay) => _DayCell(day: day, background: dayColor?.call(day)),
      ),
    );
  }
}

/// A single day cell: date number inside a square, with a small dot below
/// today's date (white on dark theme, black on light theme), and an
/// optional [background] tint (e.g. green/yellow/red completion status).
class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, this.isOutside = false, this.background});

  final DateTime day;
  final bool isOutside;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isToday = isSameDay(day, DateTime.now());
    final dotColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(6),
        color: background,
        border: Border.all(color: isToday ? scheme.primary : scheme.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: isOutside ? scheme.outline : null,
            ),
          ),
          SizedBox(
            height: 6,
            child: isToday
                ? Center(
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
