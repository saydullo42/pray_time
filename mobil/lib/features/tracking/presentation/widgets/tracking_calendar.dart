import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/date_utils.dart';

/// The month calendar, styled like the one on the website: a framed card with a
/// centered "‹ Oktabr 2026 ›" header, bold weekday names, square day cells with
/// no border (a tint shows the completed prayers; today and the selected day
/// get an outline), days of other months hidden and future days dimmed.
class TrackingCalendar extends StatelessWidget {
  const TrackingCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    this.onPageChanged,
    this.dayColor,
    this.framed = true,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final void Function(DateTime focusedDay)? onPageChanged;

  /// Optional background color for a given day's cell, e.g. to reflect that
  /// day's completed-prayers count. Returning null keeps the default style.
  final Color? Function(DateTime day)? dayColor;

  /// Wraps the calendar in a bordered card (leave off inside a dialog).
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;

    final calendar = LayoutBuilder(
      builder: (context, constraints) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            focusedDay: focusedDay,
            onChanged: (month) => onPageChanged?.call(month),
          ),
          const SizedBox(height: 8),
          TableCalendar(
            locale: 'uz',
            headerVisible: false,
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2100, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            onDaySelected: onDaySelected,
            onPageChanged: onPageChanged,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            // Square cells, like on the website.
            rowHeight: constraints.maxWidth / 7,
            daysOfWeekHeight: 28,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: muted,
              ),
              weekendStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: muted,
              ),
            ),
            calendarStyle: const CalendarStyle(outsideDaysVisible: false),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) =>
                  _DayCell(day: day, background: dayColor?.call(day)),
              todayBuilder: (context, day, focusedDay) => _DayCell(
                day: day,
                isToday: true,
                background: dayColor?.call(day),
              ),
              selectedBuilder: (context, day, focusedDay) => _DayCell(
                day: day,
                isToday: isSameDay(day, DateTime.now()),
                background: dayColor?.call(day),
              ),
            ),
          ),
        ],
      ),
    );

    if (!framed) return calendar;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: calendar,
    );
  }
}

/// "‹  Oktabr 2026  ›": the chevrons sit right next to the centered title.
class _Header extends StatelessWidget {
  const _Header({required this.focusedDay, required this.onChanged});

  final DateTime focusedDay;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    Widget chevron(String glyph, int months, String label) => InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () =>
          onChanged(DateTime(focusedDay.year, focusedDay.month + months, 1)),
      child: Semantics(
        label: label,
        button: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: Text(
            glyph,
            style: TextStyle(
              fontSize: 30,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: muted,
            ),
          ),
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        chevron('‹', -1, 'Oldingi oy'),
        const SizedBox(width: 12),
        Text(
          '${DateFormat.MMMM('uz').format(focusedDay)} ${focusedDay.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 12),
        chevron('›', 1, 'Keyingi oy'),
      ],
    );
  }
}

/// A single day: the date number in a rounded square with an optional
/// [background] tint (green/amber/red completion status). Today gets a green
/// outline (a tapped day gets none), future days are dimmed.
class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, this.isToday = false, this.background});

  final DateTime day;
  final bool isToday;
  final Color? background;

  static const _todayOutline = Color(
    0xFF4CAF17,
  ); // same green as "Ko'proq o'qish"

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isFutureDate(day) ? 0.35 : 1,
      child: Container(
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: background,
          border: Border.all(
            color: isToday ? _todayOutline : Colors.transparent,
          ),
        ),
        child: Text('${day.day}', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
