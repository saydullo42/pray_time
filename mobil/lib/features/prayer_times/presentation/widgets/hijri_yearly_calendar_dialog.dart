import 'package:flutter/material.dart';
import '../../../../core/utils/date_converter.dart';

/// Read-only year-at-a-glance Hijri calendar, opened by tapping the Hijri
/// date on the home screen: 12 month mini-grids, with the current Hijri
/// month outlined and today's Hijri day ringed within it.
class HijriYearlyCalendarDialog extends StatefulWidget {
  const HijriYearlyCalendarDialog({super.key});

  @override
  State<HijriYearlyCalendarDialog> createState() => _HijriYearlyCalendarDialogState();
}

class _HijriYearlyCalendarDialogState extends State<HijriYearlyCalendarDialog> {
  final _today = DateConverter.toHijri(DateTime.now());
  late int _year = _today.hYear;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          height: 460,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(() => _year--),
                  ),
                  const SizedBox(width: 24),
                  Text('$_year h.', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(() => _year++),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  children: [
                    for (var row = 0; row < 4; row++)
                      Expanded(
                        child: Row(
                          children: [
                            for (var col = 0; col < 3; col++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Builder(builder: (context) {
                                    final month = row * 3 + col + 1;
                                    return _HijriMiniMonth(
                                      year: _year,
                                      month: month,
                                      isCurrentMonth: _year == _today.hYear && month == _today.hMonth,
                                      currentDay: _today.hDay,
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Yopish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact single-Hijri-month calendar: month name header plus a 7-column
/// grid of day numbers.
class _HijriMiniMonth extends StatelessWidget {
  const _HijriMiniMonth({
    required this.year,
    required this.month,
    required this.isCurrentMonth,
    required this.currentDay,
  });

  final int year;
  final int month;
  final bool isCurrentMonth;
  final int currentDay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final daysInMonth = DateConverter.hijriDaysInMonth(year, month);
    final firstWeekday = DateConverter.hijriMonthFirstWeekday(year, month);
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final monthLabel = DateConverter.hijriMonthName(month);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentMonth ? scheme.primary : scheme.outlineVariant,
          width: isCurrentMonth ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          FittedBox(
            child: Text(
              monthLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCurrentMonth ? scheme.primary : null,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Column(
              children: [
                for (var row = 0; row < rows; row++)
                  Expanded(
                    child: Row(
                      children: [
                        for (var col = 0; col < 7; col++)
                          Expanded(
                            child: _dayCell(row * 7 + col, firstWeekday, daysInMonth, scheme),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayCell(int cellIndex, int firstWeekday, int daysInMonth, ColorScheme scheme) {
    final day = cellIndex - firstWeekday + 1;
    if (day < 1 || day > daysInMonth) {
      return const SizedBox.shrink();
    }
    final isToday = isCurrentMonth && day == currentDay;

    return Container(
      margin: const EdgeInsets.all(0.75),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isToday ? scheme.primary : null,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FittedBox(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? scheme.onPrimary : null,
          ),
        ),
      ),
    );
  }
}
