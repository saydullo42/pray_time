import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/features/prayer_times/presentation/widgets/prayer_time_picker.dart';

void main() {
  test('Bomdod has the hours 00-11, every other prayer 12-23', () {
    expect(allowedHours('Bomdod'), [for (var h = 0; h <= 11; h++) h]);
    for (final p in ['Peshin', 'Asr', 'Shom', 'Xufton']) {
      expect(allowedHours(p), [for (var h = 12; h <= 23; h++) h], reason: p);
    }
  });

  test('an old time outside the prayer\'s hours is moved into them', () {
    expect(
      fitToPrayer('Bomdod', const TimeOfDay(hour: 17, minute: 45)),
      const TimeOfDay(hour: 5, minute: 45),
    );
    expect(
      fitToPrayer('Peshin', const TimeOfDay(hour: 7, minute: 10)),
      const TimeOfDay(hour: 19, minute: 10),
    );
    expect(
      fitToPrayer('Asr', const TimeOfDay(hour: 15, minute: 30)),
      const TimeOfDay(hour: 15, minute: 30),
    );
  });

  /// Opens the picker for [prayer], flings the hour wheel [offset] far, taps OK
  /// and returns what was chosen.
  Future<TimeOfDay?> flingHours(
    WidgetTester tester,
    String prayer,
    TimeOfDay initial,
    Offset offset,
  ) async {
    TimeOfDay? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async => result = await showPrayerTimePicker(
              context,
              prayer: prayer,
              initial: initial,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListWheelScrollView).first, offset, 8000);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('Bomdod: the hour wheel only goes from 00 to 11', (tester) async {
    const start = TimeOfDay(hour: 5, minute: 20);
    final up = await flingHours(tester, 'Bomdod', start, const Offset(0, 3000));
    expect(up, const TimeOfDay(hour: 0, minute: 20));
    final down = await flingHours(
      tester,
      'Bomdod',
      start,
      const Offset(0, -3000),
    );
    expect(down, const TimeOfDay(hour: 11, minute: 20));
  });

  testWidgets('Asr: the hour wheel only goes from 12 to 23', (tester) async {
    const start = TimeOfDay(hour: 16, minute: 0);
    final up = await flingHours(tester, 'Asr', start, const Offset(0, 3000));
    expect(up, const TimeOfDay(hour: 12, minute: 0));
    final down = await flingHours(tester, 'Asr', start, const Offset(0, -3000));
    expect(down, const TimeOfDay(hour: 23, minute: 0));
  });

  testWidgets('OK returns the chosen time, an old out-of-range one fitted',
      (tester) async {
    TimeOfDay? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async => result = await showPrayerTimePicker(
              context,
              prayer: 'Peshin',
              initial: const TimeOfDay(hour: 7, minute: 10),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(result, const TimeOfDay(hour: 19, minute: 10));
  });

  testWidgets('Bekor qilish returns nothing', (tester) async {
    TimeOfDay? result = const TimeOfDay(hour: 1, minute: 1);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async => result = await showPrayerTimePicker(
              context,
              prayer: 'Asr',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bekor qilish'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });
}
