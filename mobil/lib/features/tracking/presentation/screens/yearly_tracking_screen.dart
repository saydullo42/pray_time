import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/repositories/tracking_repository.dart';
import '../providers/tracking_provider.dart';
import '../utils/completion_color.dart';
import '../utils/date_utils.dart';
import '../widgets/daily_checklist_sheet.dart';
import '../widgets/tracking_calendar.dart';

/// Year overview: a 3x4 grid of mini monthly calendars, each day tinted by
/// how many of that day's prayers were marked done. Tapping a month opens a
/// bigger calendar for it; tapping a date there opens the daily checklist.
class YearlyTrackingScreen extends ConsumerStatefulWidget {
  const YearlyTrackingScreen({super.key});

  @override
  ConsumerState<YearlyTrackingScreen> createState() => _YearlyTrackingScreenState();
}

class _YearlyTrackingScreenState extends ConsumerState<YearlyTrackingScreen> {
  int _year = DateTime.now().year;

  void _openMonth(int month) {
    showDialog<void>(
      context: context,
      builder: (context) => _MonthDetailDialog(initialYear: _year, initialMonth: month),
    );
  }

  @override
  Widget build(BuildContext context) {
    final countsAsync = ref.watch(yearlyCalendarCountsProvider(_year));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
                  Text('$_year', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(() => _year++),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: countsAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (error, _) => ErrorView(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(yearlyCalendarCountsProvider(_year)),
                  ),
                  data: (countsByMonth) => Column(
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
                                      return _MiniMonthCalendar(
                                        year: _year,
                                        month: month,
                                        dayCounts: countsByMonth[month] ?? const {},
                                        onTap: () => _openMonth(month),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact single-month calendar: month name header plus a 7-column grid
/// of day numbers, each tinted green/amber/red by completed prayer count.
class _MiniMonthCalendar extends StatelessWidget {
  const _MiniMonthCalendar({
    required this.year,
    required this.month,
    required this.dayCounts,
    required this.onTap,
  });

  final int year;
  final int month;
  final Map<int, int> dayCounts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isCurrentMonth = year == now.year && month == now.month;

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = (DateTime(year, month, 1).weekday + 6) % 7; // 0=Mon..6=Sun
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final monthLabel = DateFormat.MMMM('uz').format(DateTime(year, month));

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
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
            Text(
              monthLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCurrentMonth ? scheme.primary : null,
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
                              child: _dayCell(row * 7 + col, firstWeekday, daysInMonth, isCurrentMonth, now),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(int cellIndex, int firstWeekday, int daysInMonth, bool isCurrentMonth, DateTime now) {
    final day = cellIndex - firstWeekday + 1;
    if (day < 1 || day > daysInMonth) {
      return const SizedBox.shrink();
    }
    final isToday = isCurrentMonth && day == now.day;

    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.all(0.75),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorForCompletionCount(dayCounts[day]),
          borderRadius: BorderRadius.circular(3),
          border: isToday ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1) : null,
        ),
        child: FittedBox(
          child: Text('$day', style: const TextStyle(fontSize: 10)),
        ),
      ),
    );
  }
}

/// Full-size calendar for a single month, opened from the year grid. Tapping
/// a date opens the daily prayer checklist for it.
class _MonthDetailDialog extends ConsumerStatefulWidget {
  const _MonthDetailDialog({required this.initialYear, required this.initialMonth});

  final int initialYear;
  final int initialMonth;

  @override
  ConsumerState<_MonthDetailDialog> createState() => _MonthDetailDialogState();
}

class _MonthDetailDialogState extends ConsumerState<_MonthDetailDialog> {
  late DateTime _focusedDay = DateTime(widget.initialYear, widget.initialMonth, 1);
  late DateTime _selectedDay = _focusedDay;
  bool _isBusy = false;

  /// The last day of [year]-[month] that's allowed to be marked done: today
  /// for the current month, the full month if it's entirely in the past, or
  /// 0 (nothing) if the month hasn't started yet.
  int _lastMarkableDay(int year, int month, int daysInMonth) {
    final now = DateTime.now();
    if (year > now.year || (year == now.year && month > now.month)) return 0;
    if (year == now.year && month == now.month) return now.day;
    return daysInMonth;
  }

  Future<void> _bulkSet(int upToDay, bool done) async {
    final year = _focusedDay.year;
    final month = _focusedDay.month;
    final checklist = {for (final prayer in AppConstants.dailyChecklistPrayers) prayer: done};

    setState(() => _isBusy = true);
    final repository = ref.read(trackingRepositoryProvider);
    await Future.wait([
      for (var day = 1; day <= upToDay; day++)
        repository.saveDailyChecklist(date: DateTime(year, month, day), checklist: checklist),
    ]);
    ref.invalidate(dailyTrackingProvider);
    ref.invalidate(monthCalendarCountsProvider);
    ref.invalidate(yearlyCalendarCountsProvider(year));
    if (mounted) setState(() => _isBusy = false);
  }

  Future<void> _clearAllForMonth() async {
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final upToDay = _lastMarkableDay(_focusedDay.year, _focusedDay.month, daysInMonth);
    await _bulkSet(upToDay, false);
  }

  Future<void> _markAllForMonth() async {
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final upToDay = _lastMarkableDay(_focusedDay.year, _focusedDay.month, daysInMonth);
    await _bulkSet(upToDay, true);
  }

  @override
  Widget build(BuildContext context) {
    final countsAsync = ref.watch(
      monthCalendarCountsProvider((year: _focusedDay.year, month: _focusedDay.month)),
    );
    final counts = countsAsync.valueOrNull ?? const {};

    // The calendar grid also shows a few leading/trailing days from the
    // adjacent months; fetch their counts too so those cells get colored.
    final prevMonthDate = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    final nextMonthDate = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    final prevMonthCounts = ref.watch(
          monthCalendarCountsProvider((year: prevMonthDate.year, month: prevMonthDate.month)),
        ).valueOrNull ??
        const {};
    final nextMonthCounts = ref.watch(
          monthCalendarCountsProvider((year: nextMonthDate.year, month: nextMonthDate.month)),
        ).valueOrNull ??
        const {};

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          height: 460,
          child: Column(
            children: [
              Expanded(
                child: TrackingCalendar(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onPageChanged: (focused) => setState(() => _focusedDay = focused),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                    if (!isFutureDate(selected)) {
                      showDailyChecklistSheet(context, selected);
                    }
                  },
                  dayColor: (day) {
                    if (day.year == _focusedDay.year && day.month == _focusedDay.month) {
                      return colorForCompletionCount(counts[day.day]);
                    }
                    if (day.year == prevMonthDate.year && day.month == prevMonthDate.month) {
                      return colorForCompletionCount(prevMonthCounts[day.day]);
                    }
                    if (day.year == nextMonthDate.year && day.month == nextMonthDate.month) {
                      return colorForCompletionCount(nextMonthCounts[day.day]);
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Hammasini o\'chirish',
                      outlined: true,
                      isLoading: _isBusy,
                      foregroundColor: Colors.red,
                      onPressed: _clearAllForMonth,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      label: 'Hammasini belgilash',
                      isLoading: _isBusy,
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.black,
                      onPressed: _markAllForMonth,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
