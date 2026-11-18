import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/date_converter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../notifications/presentation/providers/notification_settings_provider.dart';
import '../../../prayer_times/data/models/custom_times_apply.dart';
import '../../../prayer_times/data/models/prayer_time_model.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';
import '../providers/tracking_provider.dart';
import '../utils/prayer_lock.dart';

/// Opens a half-page modal sheet with a checkbox per prayer (including
/// Vitr) for [date], and saves the booleans to the backend on "Saqlash".
Future<void> showDailyChecklistSheet(BuildContext context, DateTime date) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => DailyChecklistSheet(date: date),
  );
}

class DailyChecklistSheet extends ConsumerStatefulWidget {
  const DailyChecklistSheet({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<DailyChecklistSheet> createState() =>
      _DailyChecklistSheetState();
}

class _DailyChecklistSheetState extends ConsumerState<DailyChecklistSheet> {
  Map<String, bool>? _checked;
  PrayerTimeModel? _times;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final checked = {
      for (final prayer in AppConstants.dailyChecklistPrayers) prayer: false,
    };
    try {
      final daily = await ref.read(dailyTrackingProvider(widget.date).future);
      daily.statuses.forEach((prayer, done) {
        if (checked.containsKey(prayer)) {
          checked[prayer] = done;
        }
      });
    } catch (_) {
      // Fetch failed (e.g. offline) — fall back to all-unchecked so the
      // sheet is still usable; saving will simply overwrite with this.
    }
    // Today's prayers whose time hasn't come yet can't be ticked. If the times
    // can't be had (offline), nothing is locked.
    PrayerTimeModel? times;
    final now = DateTime.now();
    final isToday =
        widget.date.year == now.year &&
        widget.date.month == now.month &&
        widget.date.day == now.day;
    if (isToday) {
      try {
        var chosen = await ref.read(todayPrayerTimesProvider.future);
        // The times the person chose for their reminders: table 2 (their own
        // times) when it's selected, otherwise the computed ones.
        final settings = await ref.read(notificationSettingsProvider.future);
        if (settings.useCustomTimes) {
          final own = await ref.read(customPrayerTimeOverridesProvider.future);
          chosen = chosen.withCustomTimes(own);
        }
        times = chosen;
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _checked = checked;
        _times = times;
      });
    }
  }

  Future<void> _save() async {
    final checked = _checked;
    if (checked == null) return;
    setState(() => _isSaving = true);
    await ref
        .read(trackingActionsProvider)
        .saveDailyChecklist(date: widget.date, checklist: checked);
    ref.invalidate(dailyTrackingProvider(widget.date));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final checked = _checked;
    final locked = lockedPrayers(
      times: _times,
      date: widget.date,
      now: DateTime.now(),
    );

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.57,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: checked == null
            ? const LoadingIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      DateConverter.formatGregorian(widget.date),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashFactory: NoSplash.splashFactory,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        for (final prayer in AppConstants.dailyChecklistPrayers)
                          // A prayer whose time hasn't come yet is dimmed and
                          // can't be ticked.
                          Opacity(
                            opacity: locked.contains(prayer) ? 0.4 : 1,
                            child: ListTile(
                              dense: true,
                              enabled: !locked.contains(prayer),
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                prayer,
                                style: const TextStyle(fontSize: 20),
                              ),
                              trailing: Transform.scale(
                                scale: 1.4,
                                child: Checkbox(
                                  value: checked[prayer],
                                  activeColor: context.accentFill,
                                  checkColor: context.isLightTheme
                                      ? Colors.black
                                      : Colors.white,
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  onChanged: locked.contains(prayer)
                                      ? null
                                      : (value) => setState(
                                          () => checked[prayer] = value ?? false,
                                        ),
                                ),
                              ),
                              onTap: locked.contains(prayer)
                                  ? null
                                  : () => setState(
                                      () => checked[prayer] =
                                          !(checked[prayer] ?? false),
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.6,
                      child: CustomButton(
                        label: 'Saqlash',
                        isLoading: _isSaving,
                        onPressed: _save,
                        fontSize: 20,
                        backgroundColor: context.accentFill,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
