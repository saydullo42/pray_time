import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../prayer_times/data/models/custom_prayer_time_model.dart';
import '../../../prayer_times/data/models/prayer_time_model.dart';
import '../../../prayer_times/data/repositories/prayer_times_repository.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';
import '../../../prayer_times/presentation/widgets/hijri_gregorian_date_header.dart';
import '../../../prayer_times/presentation/widgets/hijri_yearly_calendar_dialog.dart';
import '../../../prayer_times/presentation/widgets/location_selector_buttons.dart';
import '../../../tracking/presentation/providers/tracking_provider.dart';
import '../../../tracking/presentation/utils/completion_color.dart';
import '../../../tracking/presentation/utils/date_utils.dart';
import '../../../tracking/presentation/widgets/daily_checklist_sheet.dart';
import '../../../tracking/presentation/widgets/tracking_calendar.dart';

/// Maps each editable prayer's display name to its field on
/// [CustomPrayerTimeModel] (sunrise has no override, so it's excluded).
const _overrideFieldByPrayer = {
  'Bomdod': 'fajr',
  'Peshin': 'dhuhr',
  'Asr': 'asr',
  'Shom': 'maghrib',
  'Xufton': 'isha',
};

/// Dashboard tab: today's date, today's prayer times, quick manual-entry
/// buttons for each prayer, and a monthly calendar.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  String? _fieldValue(CustomPrayerTimeModel overrides, String prayer) {
    switch (_overrideFieldByPrayer[prayer]) {
      case 'fajr':
        return overrides.fajr;
      case 'dhuhr':
        return overrides.dhuhr;
      case 'asr':
        return overrides.asr;
      case 'maghrib':
        return overrides.maghrib;
      case 'isha':
        return overrides.isha;
      default:
        return null;
    }
  }

  CustomPrayerTimeModel _withFieldValue(CustomPrayerTimeModel overrides, String prayer, String value) {
    switch (_overrideFieldByPrayer[prayer]) {
      case 'fajr':
        return overrides.copyWith(fajr: value);
      case 'dhuhr':
        return overrides.copyWith(dhuhr: value);
      case 'asr':
        return overrides.copyWith(asr: value);
      case 'maghrib':
        return overrides.copyWith(maghrib: value);
      case 'isha':
        return overrides.copyWith(isha: value);
      default:
        return overrides;
    }
  }

  void _showManualEntryInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: const Text("Ma'lumot", style: TextStyle(fontSize: 24)),
        content: const Text(
          "Pastda joylashgan namoz vaqtlarini o'zingiz kiritishingiz mumkin. "
          "O'zingizga eng yaqin joylashgan masjidning namoz vaqtlarini kiriting.\n\n"
          "Eslatma! Masjiddagi namoz vaqtlari haftaning har Juma kuni o'zgaradi.\n\n"
          "Eslatma! Agar namoz vaqtlarini o'zingiz kiritsangiz,\n"
          "'Profil -> Eslatma sozlamalari' bo'limiga o'tib 2-jadvalni tanlab qo'ying.",
          style: TextStyle(fontSize: 18, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Tushunarli',
              style: TextStyle(fontSize: 18, color: Color(0xFF4CAF17)),
            ),
          ),
        ],
      ),
    );
  }

  void _showCalendarInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: const Text("Ma'lumot", style: TextStyle(fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pastdagi kalendardan istalgan sanani bosib, o'sha kun uchun "
              "o'qilgan namozlaringizni belgilashingiz mumkin.",
              style: TextStyle(fontSize: 18, height: 1.4),
            ),
            const SizedBox(height: 12),
            _LegendRow(color: Colors.green, label: 'Yashil - barcha namoz o\'qilgan'),
            const SizedBox(height: 6),
            _LegendRow(color: Colors.amber, label: 'Sariq - qisman o\'qilgan'),
            const SizedBox(height: 6),
            _LegendRow(color: Colors.red, label: 'Qizil - kam yoki umuman o\'qilmagan'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Tushunarli',
              style: TextStyle(fontSize: 18, color: Color(0xFF4CAF17)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickManualTime(String prayer) async {
    CustomPrayerTimeModel overrides;
    try {
      overrides = await ref.read(customPrayerTimeOverridesProvider.future);
    } catch (_) {
      overrides = const CustomPrayerTimeModel();
    }

    var initial = TimeOfDay.now();
    final existing = _fieldValue(overrides, prayer);
    if (existing != null) {
      final parts = existing.split(':');
      initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    if (!mounted) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: '',
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            timePickerTheme: theme.timePickerTheme.copyWith(
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF17),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF17),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              dialHandColor: const Color(0xFF396E0D),
              hourMinuteColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF396E0D);
                }
                return theme.colorScheme.onSurface.withValues(alpha: 0.12);
              }),
              dialTextColor: WidgetStateColor.resolveWith(
                (states) => theme.colorScheme.onSurface,
              ),
            ),
          ),
          child: Stack(
            children: [
              child!,
              Positioned(
                top: 130,
                left: 16,
                right: 16,
                child: IgnorePointer(
                  child: Text(
                    prayer,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (picked == null) return;

    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    final updated = _withFieldValue(overrides, prayer, formatted);

    await ref.read(prayerTimesRepositoryProvider).saveCustomOverrides(updated);
    ref.invalidate(customPrayerTimeOverridesProvider);
    ref.invalidate(todayPrayerTimesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);
    final monthCountsAsync = ref.watch(
      monthCalendarCountsProvider((year: _focusedDay.year, month: _focusedDay.month)),
    );
    final monthCounts = monthCountsAsync.valueOrNull ?? const {};

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

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const LocationSelectorButtons(),
      ),
      body: ListView(
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: HijriGregorianDateHeader(
              onHijriTap: () => showDialog<void>(
                context: context,
                builder: (context) => const HijriYearlyCalendarDialog(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: prayerTimesAsync.when(
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(todayPrayerTimesProvider),
              ),
              data: (prayerTime) => _PrayerTimesBar(prayerTime: prayerTime),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _ManualPrayerTimesBar(
              computedTimes: prayerTimesAsync.valueOrNull,
              onTapPrayer: _pickManualTime,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '* Namoz vaqtini ustiga bosing...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showManualEntryInfo(context),
                  child: Text(
                    'Ko\'proq o\'qish',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF4CAF17),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '* Kalendardagi sanalar ustiga bosing...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showCalendarInfo(context),
                  child: Text(
                    'Ko\'proq o\'qish',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF4CAF17),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TrackingCalendar(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                    if (!isFutureDate(selected)) {
                      showDailyChecklistSheet(context, selected);
                    }
                  },
                  onPageChanged: (focused) => setState(() => _focusedDay = focused),
                  dayColor: (day) {
                    if (day.year == _focusedDay.year && day.month == _focusedDay.month) {
                      return colorForCompletionCount(monthCounts[day.day]);
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 18, height: 1.4))),
      ],
    );
  }
}

class _PrayerTimesBar extends StatelessWidget {
  const _PrayerTimesBar({required this.prayerTime});

  final PrayerTimeModel prayerTime;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entries = <(String, DateTime)>[
      ('Bomdod', prayerTime.fajr),
      ('Quyosh', prayerTime.sunrise),
      ('Peshin', prayerTime.dhuhr),
      ('Asr', prayerTime.asr),
      ('Shom', prayerTime.maghrib),
      ('Xufton', prayerTime.isha),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final entry in entries)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      entry.$1,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      DateFormat.Hm().format(entry.$2),
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Full-width bar of manually-editable prayer times (Bomdod/Peshin/Asr/
/// Shom/Xufton). Tapping a prayer opens a time picker to set/edit its
/// override; the displayed value falls back to the computed time when no
/// override has been saved yet.
class _ManualPrayerTimesBar extends ConsumerWidget {
  const _ManualPrayerTimesBar({required this.computedTimes, required this.onTapPrayer});

  final PrayerTimeModel? computedTimes;
  final ValueChanged<String> onTapPrayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final overrides = ref.watch(customPrayerTimeOverridesProvider).valueOrNull ??
        const CustomPrayerTimeModel();

    String displayValue(String? override, DateTime? computed) {
      if (override != null) return override;
      if (computed != null) return DateFormat.Hm().format(computed);
      return '--:--';
    }

    final entries = <(String, String)>[
      ('Bomdod', displayValue(overrides.fajr, computedTimes?.fajr)),
      ('Peshin', displayValue(overrides.dhuhr, computedTimes?.dhuhr)),
      ('Asr', displayValue(overrides.asr, computedTimes?.asr)),
      ('Shom', displayValue(overrides.maghrib, computedTimes?.maghrib)),
      ('Xufton', displayValue(overrides.isha, computedTimes?.isha)),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final entry in entries)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onTapPrayer(entry.$1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        entry.$1,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        entry.$2,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
