import 'package:flutter/material.dart';

/// Hours that make sense for [prayer] when typing its time by hand: Bomdod is
/// before noon (00-11), every other prayer is after it (12-23).
List<int> allowedHours(String prayer) =>
    List.generate(12, (i) => prayer == 'Bomdod' ? i : 12 + i);

/// [t] moved into [prayer]'s hours (e.g. an old 17:45 for Bomdod becomes 05:45),
/// keeping the minutes.
TimeOfDay fitToPrayer(String prayer, TimeOfDay t) {
  if (allowedHours(prayer).contains(t.hour)) return t;
  final hour = prayer == 'Bomdod' ? t.hour % 12 : 12 + t.hour % 12;
  return TimeOfDay(hour: hour, minute: t.minute);
}

const _defaultTimes = {
  'Bomdod': TimeOfDay(hour: 5, minute: 0),
  'Peshin': TimeOfDay(hour: 13, minute: 0),
  'Asr': TimeOfDay(hour: 16, minute: 0),
  'Shom': TimeOfDay(hour: 18, minute: 0),
  'Xufton': TimeOfDay(hour: 20, minute: 0),
};

/// Asks for [prayer]'s time with an hour list limited to its half of the day
/// (see [allowedHours]) and the minutes 00-59. Returns null if cancelled.
Future<TimeOfDay?> showPrayerTimePicker(
  BuildContext context, {
  required String prayer,
  TimeOfDay? initial,
}) {
  final start = fitToPrayer(
    prayer,
    initial ?? _defaultTimes[prayer] ?? const TimeOfDay(hour: 12, minute: 0),
  );
  return showDialog<TimeOfDay>(
    context: context,
    builder: (context) => _PrayerTimeDialog(prayer: prayer, initial: start),
  );
}

class _PrayerTimeDialog extends StatefulWidget {
  const _PrayerTimeDialog({required this.prayer, required this.initial});

  final String prayer;
  final TimeOfDay initial;

  @override
  State<_PrayerTimeDialog> createState() => _PrayerTimeDialogState();
}

class _PrayerTimeDialogState extends State<_PrayerTimeDialog> {
  static const _green = Color(0xFF4CAF17);
  static const _itemExtent = 56.0;

  late final List<int> _hours = allowedHours(widget.prayer);
  late int _hourIndex = _hours.indexOf(widget.initial.hour);
  late int _minute = widget.initial.minute;
  late final FixedExtentScrollController _hourController =
      FixedExtentScrollController(initialItem: _hourIndex);
  late final FixedExtentScrollController _minuteController =
      FixedExtentScrollController(initialItem: _minute);

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required int count,
    required String Function(int index) label,
    required int selected,
    required ValueChanged<int> onChanged,
    bool loop = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    Widget item(int index) => Center(
      child: Text(
        label(index),
        style: TextStyle(
          fontSize: index == selected ? 34 : 26,
          fontWeight: index == selected ? FontWeight.w700 : FontWeight.w400,
          color: index == selected
              ? scheme.onSurface
              : scheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );

    return SizedBox(
      width: 84,
      height: _itemExtent * 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: Container(
              height: _itemExtent,
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: _itemExtent,
            physics: const FixedExtentScrollPhysics(),
            overAndUnderCenterOpacity: 1,
            onSelectedItemChanged: (i) => setState(() => onChanged(i)),
            childDelegate: loop
                ? ListWheelChildLoopingListDelegate(
                    children: [for (var i = 0; i < count; i++) item(i)],
                  )
                : ListWheelChildBuilderDelegate(
                    childCount: count,
                    builder: (context, i) => item(i),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(widget.prayer, style: const TextStyle(fontSize: 24)),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _wheel(
            controller: _hourController,
            count: _hours.length,
            label: (i) => _hours[i].toString().padLeft(2, '0'),
            selected: _hourIndex,
            onChanged: (i) => _hourIndex = i,
          ),
          const Text(':', style: TextStyle(fontSize: 34)),
          _wheel(
            controller: _minuteController,
            count: 60,
            label: (i) => i.toString().padLeft(2, '0'),
            selected: _minute,
            onChanged: (i) => _minute = i,
            loop: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Bekor qilish',
            style: TextStyle(fontSize: 18, color: _green),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            TimeOfDay(hour: _hours[_hourIndex], minute: _minute % 60),
          ),
          child: const Text(
            'OK',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _green,
            ),
          ),
        ),
      ],
    );
  }
}
