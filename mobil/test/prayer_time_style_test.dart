import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/core/theme/prayer_time_style.dart';

void main() {
  testWidgets('the prayer times use Geist at weight 500, size 16', (
    tester,
  ) async {
    late TextStyle style;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            style = prayerTimeStyle(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(style.fontFamily, 'Geist');
    expect(style.fontSize, 16);
    expect(style.fontWeight, FontWeight.w500);
    expect(style.fontVariations, contains(const FontVariation('wght', 500)));
  });

  testWidgets(
    'the bundled Geist font file is valid and narrower than the fallback',
    (tester) async {
      // Load the font from the app's bundled asset, as the app does.
      await tester.runAsync(() async {
        final loader = FontLoader('Geist')
          ..addFont(rootBundle.load('assets/fonts/Geist.ttf'));
        await loader.load();
      });
      late TextStyle style;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              style = prayerTimeStyle(context);
              return const SizedBox();
            },
          ),
        ),
      );
      final geist = TextPainter(
        text: TextSpan(text: '05:30', style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      // Without the font, tests fall back to Ahem, where every character is as
      // wide as the font size: 5 * 16 = 80. Geist's digits and colon are narrower.
      expect(geist.width, lessThan(60));
    },
  );
}
