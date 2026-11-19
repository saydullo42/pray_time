import 'package:flutter/material.dart';
import '../../../../core/utils/date_converter.dart';

/// Read-only year-at-a-glance Hijri calendar, opened by tapping the Hijri
/// date on the home screen: the 12 months in two columns (big enough to read),
/// scrolled to the current Hijri month, which is outlined with today's day
/// ringed within it.
class HijriYearlyCalendarDialog extends StatefulWidget {
  const HijriYearlyCalendarDialog({super.key});

  @override
  State<HijriYearlyCalendarDialog> createState() =>
      _HijriYearlyCalendarDialogState();
}

class _HijriYearlyCalendarDialogState extends State<HijriYearlyCalendarDialog> {
  final _today = DateConverter.toHijri(DateTime.now());
  late int _year = _today.hYear;
  final _currentMonthKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showCurrentMonth());
  }

  void _showCurrentMonth() {
    final context = _currentMonthKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(context, alignment: 0.1);
  }

  void _changeYear(int delta) {
    setState(() => _year += delta);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_year == _today.hYear) {
        _showCurrentMonth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          height: height * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 32),
                    onPressed: () => _changeYear(-1),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    '$_year h.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 32),
                    onPressed: () => _changeYear(1),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var row = 0; row < 6; row++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var col = 0; col < 2; col++) ...[
                                if (col == 1) const SizedBox(width: 8),
                                Expanded(
                                  child: Builder(
                                    builder: (context) {
                                      final month = row * 2 + col + 1;
                                      final isCurrent =
                                          _year == _today.hYear &&
                                          month == _today.hMonth;
                                      return _HijriMiniMonth(
                                        key: isCurrent
                                            ? _currentMonthKey
                                            : null,
                                        year: _year,
                                        month: month,
                                        isCurrentMonth: isCurrent,
                                        currentDay: _today.hDay,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Yopish', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single Hijri month: its name, then a 7-column grid of day numbers with
/// square cells (always six rows, so every month tile is the same height).
class _HijriMiniMonth extends StatelessWidget {
  const _HijriMiniMonth({
    super.key,
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
    final monthLabel = DateConverter.hijriMonthName(month);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrentMonth ? scheme.primary : scheme.outlineVariant,
          width: isCurrentMonth ? 2 : 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cell = constraints.maxWidth / 7;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    monthLabel,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isCurrentMonth ? scheme.primary : null,
                    ),
                  ),
                ),
              ),
              for (var row = 0; row < 6; row++)
                Row(
                  children: [
                    for (var col = 0; col < 7; col++)
                      SizedBox(
                        width: cell,
                        height: cell,
                        child: _dayCell(
                          row * 7 + col,
                          firstWeekday,
                          daysInMonth,
                          scheme,
                          cell,
                        ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _dayCell(
    int cellIndex,
    int firstWeekday,
    int daysInMonth,
    ColorScheme scheme,
    double cell,
  ) {
    final day = cellIndex - firstWeekday + 1;
    if (day < 1 || day > daysInMonth) {
      return const SizedBox.shrink();
    }
    final isToday = isCurrentMonth && day == currentDay;

    return Container(
      margin: const EdgeInsets.all(1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isToday ? scheme.primary : null,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: cell * 0.7,
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          color: isToday ? scheme.onPrimary : null,
        ),
      ),
    );
  }
}
