import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/features/notifications/data/models/reminder_sound.dart';

void main() {
  test('only the long sound gets a stop button', () {
    expect(findReminderSound('allohning_99_ismi').hasStopButton, true);
    for (final id in ['klassik', 'yumshoq', 'signal', 'uygonish', 'raqamli']) {
      expect(findReminderSound(id).hasStopButton, false, reason: id);
    }
  });

  test('a sound of exactly 10 seconds is short', () {
    const s = ReminderSound(id: 'x', label: 'x', seconds: 10);
    expect(s.hasStopButton, false);
    const l = ReminderSound(id: 'x', label: 'x', seconds: 11);
    expect(l.hasStopButton, true);
  });
}
