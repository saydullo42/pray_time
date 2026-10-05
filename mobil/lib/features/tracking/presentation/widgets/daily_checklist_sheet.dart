import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_converter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/tracking_provider.dart';

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
  ConsumerState<DailyChecklistSheet> createState() => _DailyChecklistSheetState();
}

class _DailyChecklistSheetState extends ConsumerState<DailyChecklistSheet> {
  Map<String, bool>? _checked;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final checked = {for (final prayer in AppConstants.dailyChecklistPrayers) prayer: false};
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
    if (mounted) setState(() => _checked = checked);
  }

  Future<void> _save() async {
    final checked = _checked;
    if (checked == null) return;
    setState(() => _isSaving = true);
    await ref.read(trackingActionsProvider).saveDailyChecklist(
          date: widget.date,
          checklist: checked,
        );
    ref.invalidate(dailyTrackingProvider(widget.date));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final checked = _checked;

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
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(prayer, style: const TextStyle(fontSize: 20)),
                            trailing: Transform.scale(
                              scale: 1.4,
                              child: Checkbox(
                                value: checked[prayer],
                                activeColor: const Color(0xFF396E0D),
                                checkColor: Colors.white,
                                overlayColor: WidgetStateProperty.all(Colors.transparent),
                                onChanged: (value) =>
                                    setState(() => checked[prayer] = value ?? false),
                              ),
                            ),
                            onTap: () =>
                                setState(() => checked[prayer] = !(checked[prayer] ?? false)),
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
                        backgroundColor: const Color(0xFF396E0D),
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
