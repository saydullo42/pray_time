import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/core/utils/date_converter.dart';
import 'package:mobil/features/prayer_times/presentation/widgets/hijri_yearly_calendar_dialog.dart';

Future<void> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(body: HijriYearlyCalendarDialog()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('all twelve months are there and the day numbers are big', (
    tester,
  ) async {
    await _open(tester);
    for (var m = 1; m <= 12; m++) {
      expect(find.text(DateConverter.hijriMonthName(m)), findsOneWidget);
    }
    final dayText = tester.widget<Text>(find.text('15').first);
    // The old 3-column calendar showed them at about 10; now 14.
    expect(dayText.style!.fontSize!, greaterThan(13));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the arrows change the year', (tester) async {
    await _open(tester);
    final now = DateConverter.toHijri(DateTime.now()).hYear;
    expect(find.text('$now h.'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('${now + 1} h.'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('${now - 1} h.'), findsOneWidget);
  });

  testWidgets('Yopish closes the calendar', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const HijriYearlyCalendarDialog(),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(HijriYearlyCalendarDialog), findsOneWidget);
    await tester.tap(find.text('Yopish'));
    await tester.pumpAndSettle();
    expect(find.byType(HijriYearlyCalendarDialog), findsNothing);
  });
}
