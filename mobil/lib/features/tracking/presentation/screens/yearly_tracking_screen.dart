import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/repositories/tracking_repository.dart';
import '../providers/roza_provider.dart';
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
  ConsumerState<YearlyTrackingScreen> createState() =>
      _YearlyTrackingScreenState();
}

enum _TrackingMode { namoz, roza }

class _YearlyTrackingScreenState extends ConsumerState<YearlyTrackingScreen> {
  static const _oldestRozaYear = 1940;
  static const _rozaYearsPerPage = 12;

  int _year = DateTime.now().year;
  _TrackingMode _mode = _TrackingMode.namoz;

  /// Ro'za view: 0 = the current year and the 11 before it, 1 = the next 12
  /// older years, and so on back to [_oldestRozaYear].
  int _rozaPage = 0;

  int get _rozaTopYear => DateTime.now().year - _rozaPage * _rozaYearsPerPage;

  bool get _canGoOlder => _rozaTopYear - _rozaYearsPerPage >= _oldestRozaYear;

  void _openRozaYear(int year) {
    showDialog<void>(
      context: context,
      builder: (context) => _RozaYearDialog(year: year),
    );
  }

  void _openMonth(int month) {
    showDialog<void>(
      context: context,
      builder: (context) =>
          _MonthDetailDialog(initialYear: _year, initialMonth: month),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNamoz = _mode == _TrackingMode.namoz;
    final rozaBottomYear = (_rozaTopYear - _rozaYearsPerPage + 1).clamp(
      _oldestRozaYear,
      _rozaTopYear,
    );

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
                  _ModeButton(
                    mode: _mode,
                    onSelected: (mode) => setState(() => _mode = mode),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: isNamoz
                        ? () => setState(() => _year--)
                        : (_canGoOlder
                              ? () => setState(() => _rozaPage++)
                              : null),
                  ),
                  // In Namoz mode the year is narrow, so the arrows sit close
                  // to it; the trailing spacer below keeps the whole row as
                  // wide as in Ro'za mode, so the mode button doesn't move.
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 64),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isNamoz
                              ? '$_year'
                              : '$rozaBottomYear - $_rozaTopYear',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: isNamoz
                        ? () => setState(() => _year++)
                        : (_rozaPage > 0
                              ? () => setState(() => _rozaPage--)
                              : null),
                  ),
                  if (isNamoz) const SizedBox(width: 76),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: isNamoz ? _buildNamozGrid() : _buildRozaGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNamozGrid() {
    final countsAsync = ref.watch(yearlyCalendarCountsProvider(_year));
    return countsAsync.when(
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
                        child: Builder(
                          builder: (context) {
                            final month = row * 3 + col + 1;
                            return _MiniMonthCalendar(
                              year: _year,
                              month: month,
                              dayCounts: countsByMonth[month] ?? const {},
                              onTap: () => _openMonth(month),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// The twelve month slots hold years in reverse order: the last slot
  /// (Dekabr) is the newest year of the page, the first (Yanvar) the oldest.
  Widget _buildRozaGrid() {
    return Column(
      children: [
        for (var row = 0; row < 4; row++)
          Expanded(
            child: Row(
              children: [
                for (var col = 0; col < 3; col++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Builder(
                        builder: (context) {
                          final slot =
                              row * 3 + col; // 0 = Yanvar .. 11 = Dekabr
                          final year =
                              _rozaTopYear - (_rozaYearsPerPage - 1 - slot);
                          if (year < _oldestRozaYear) {
                            return const SizedBox.shrink();
                          }
                          return _RozaYearCard(
                            year: year,
                            onTap: () => _openRozaYear(year),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Dropdown-style button that switches between the Namoz and Ro'za views.
class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.mode, required this.onSelected});

  final _TrackingMode mode;
  final ValueChanged<_TrackingMode> onSelected;

  static String _label(_TrackingMode mode) =>
      mode == _TrackingMode.namoz ? 'Namoz' : "Ro'za";

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // MenuAnchor (unlike PopupMenuButton) sizes the menu to its content
    // instead of snapping to 56dp steps, so it can be narrow.
    return MenuAnchor(
      style: const MenuStyle(minimumSize: WidgetStatePropertyAll(Size(0, 0))),
      menuChildren: [
        for (var i = 0; i < _TrackingMode.values.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withValues(alpha: 0.6),
            ),
          MenuItemButton(
            onPressed: () => onSelected(_TrackingMode.values[i]),
            style: ButtonStyle(
              minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12),
              ),
              backgroundColor: WidgetStatePropertyAll(
                _TrackingMode.values[i] == mode
                    ? Colors.grey.withValues(alpha: 0.28)
                    : null,
              ),
            ),
            trailingIcon: _TrackingMode.values[i] == mode
                ? const Icon(Icons.check, size: 20, color: Colors.green)
                : null,
            child: Text(_label(_TrackingMode.values[i])),
          ),
        ],
      ],
      builder: (context, controller, child) => InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _label(mode),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// One year in the Ro'za view: the year as a title and 30 plain day boxes
/// (no weekday alignment) for the 30 days of fasting. Days marked as kept
/// are green; tapping the card opens that year in a bigger dialog.
class _RozaYearCard extends ConsumerWidget {
  const _RozaYearCard({required this.year, required this.onTap});

  final int year;
  final VoidCallback onTap;

  static const _days = 30;
  static const _columns = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isCurrentYear = year == DateTime.now().year;
    final doneDays = ref.watch(rozaProvider)[year] ?? const <int>{};
    const rows = _days ~/ _columns;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentYear ? scheme.primary : scheme.outlineVariant,
            width: isCurrentYear ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$year',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isCurrentYear ? scheme.primary : null,
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
                          for (var col = 0; col < _columns; col++)
                            Expanded(
                              child: _RozaDayBox(
                                day: row * _columns + col + 1,
                                done: doneDays.contains(
                                  row * _columns + col + 1,
                                ),
                                fontSize: 10,
                              ),
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
}

/// A single numbered day box, green when the day is marked as kept.
class _RozaDayBox extends StatelessWidget {
  const _RozaDayBox({
    required this.day,
    required this.done,
    required this.fontSize,
  });

  final int day;
  final bool done;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0.75),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done ? colorForCompletionCount(6) : null,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FittedBox(
        child: Text('$day', style: TextStyle(fontSize: fontSize)),
      ),
    );
  }
}

/// A year's 30 fasting days in a bigger grid. Tapping a day opens a small
/// dialog where it can be marked as kept.
class _RozaYearDialog extends ConsumerWidget {
  const _RozaYearDialog({required this.year});

  final int year;

  static const _days = 30;
  static const _columns = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final doneDays = ref.watch(rozaProvider)[year] ?? const <int>{};

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$year', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _columns,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [
                for (var day = 1; day <= _days; day++)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (context) =>
                          _RozaDayDialog(year: year, day: day),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: doneDays.contains(day)
                            ? colorForCompletionCount(6)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Text('$day', style: const TextStyle(fontSize: 16)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Hammasini o\'chirish',
                    outlined: true,
                    foregroundColor: Colors.red,
                    onPressed: () =>
                        ref.read(rozaProvider.notifier).setYear(year, {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    label: 'Hammasini belgilash',
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.black,
                    onPressed: () => ref.read(rozaProvider.notifier).setYear(
                      year,
                      {for (var day = 1; day <= _days; day++) day},
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Marks one fasting day as kept: the year centered on top, below it a
/// right-aligned "day - kun" row with a checkbox, and a "Saqlash" button. The
/// checkbox only takes effect when "Saqlash" is pressed.
class _RozaDayDialog extends ConsumerStatefulWidget {
  const _RozaDayDialog({required this.year, required this.day});

  final int year;
  final int day;

  @override
  ConsumerState<_RozaDayDialog> createState() => _RozaDayDialogState();
}

class _RozaDayDialogState extends ConsumerState<_RozaDayDialog> {
  late bool _done =
      ref.read(rozaProvider)[widget.year]?.contains(widget.day) ?? false;

  Future<void> _save() async {
    await ref
        .read(rozaProvider.notifier)
        .setDone(widget.year, widget.day, _done);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.year}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${widget.day} - kun',
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(width: 52),
                Transform.scale(
                  scale: 1.6,
                  child: Checkbox(
                    value: _done,
                    onChanged: (value) =>
                        setState(() => _done = value ?? false),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
            const SizedBox(height: 24),
            FractionallySizedBox(
              widthFactor: 0.6,
              child: CustomButton(
                label: 'Saqlash',
                onPressed: _save,
                fontSize: 20,
                backgroundColor: const Color(0xFF396E0D),
                foregroundColor: Colors.black,
              ),
            ),
          ],
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
    final firstWeekday =
        (DateTime(year, month, 1).weekday + 6) % 7; // 0=Mon..6=Sun
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
                              child: _dayCell(
                                row * 7 + col,
                                firstWeekday,
                                daysInMonth,
                                isCurrentMonth,
                                now,
                              ),
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

  Widget _dayCell(
    int cellIndex,
    int firstWeekday,
    int daysInMonth,
    bool isCurrentMonth,
    DateTime now,
  ) {
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
          border: isToday
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1,
                )
              : null,
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
  const _MonthDetailDialog({
    required this.initialYear,
    required this.initialMonth,
  });

  final int initialYear;
  final int initialMonth;

  @override
  ConsumerState<_MonthDetailDialog> createState() => _MonthDetailDialogState();
}

class _MonthDetailDialogState extends ConsumerState<_MonthDetailDialog> {
  late DateTime _focusedDay = DateTime(
    widget.initialYear,
    widget.initialMonth,
    1,
  );
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
    final checklist = {
      for (final prayer in AppConstants.dailyChecklistPrayers) prayer: done,
    };

    setState(() => _isBusy = true);
    final repository = ref.read(trackingRepositoryProvider);
    await Future.wait([
      for (var day = 1; day <= upToDay; day++)
        repository.saveDailyChecklist(
          date: DateTime(year, month, day),
          checklist: checklist,
        ),
    ]);
    ref.invalidate(dailyTrackingProvider);
    ref.invalidate(monthCalendarCountsProvider);
    ref.invalidate(yearlyCalendarCountsProvider(year));
    if (mounted) setState(() => _isBusy = false);
  }

  Future<void> _clearAllForMonth() async {
    final daysInMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    ).day;
    final upToDay = _lastMarkableDay(
      _focusedDay.year,
      _focusedDay.month,
      daysInMonth,
    );
    await _bulkSet(upToDay, false);
  }

  Future<void> _markAllForMonth() async {
    final daysInMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    ).day;
    final upToDay = _lastMarkableDay(
      _focusedDay.year,
      _focusedDay.month,
      daysInMonth,
    );
    await _bulkSet(upToDay, true);
  }

  @override
  Widget build(BuildContext context) {
    final countsAsync = ref.watch(
      monthCalendarCountsProvider((
        year: _focusedDay.year,
        month: _focusedDay.month,
      )),
    );
    final counts = countsAsync.valueOrNull ?? const {};

    // The calendar grid also shows a few leading/trailing days from the
    // adjacent months; fetch their counts too so those cells get colored.
    final prevMonthDate = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    final nextMonthDate = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    final prevMonthCounts =
        ref
            .watch(
              monthCalendarCountsProvider((
                year: prevMonthDate.year,
                month: prevMonthDate.month,
              )),
            )
            .valueOrNull ??
        const {};
    final nextMonthCounts =
        ref
            .watch(
              monthCalendarCountsProvider((
                year: nextMonthDate.year,
                month: nextMonthDate.month,
              )),
            )
            .valueOrNull ??
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
                  onPageChanged: (focused) =>
                      setState(() => _focusedDay = focused),
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
                    if (day.year == _focusedDay.year &&
                        day.month == _focusedDay.month) {
                      return colorForCompletionCount(counts[day.day]);
                    }
                    if (day.year == prevMonthDate.year &&
                        day.month == prevMonthDate.month) {
                      return colorForCompletionCount(prevMonthCounts[day.day]);
                    }
                    if (day.year == nextMonthDate.year &&
                        day.month == nextMonthDate.month) {
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
