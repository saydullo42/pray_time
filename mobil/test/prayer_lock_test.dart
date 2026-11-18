import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/features/prayer_times/data/models/prayer_time_model.dart';
import 'package:mobil/features/tracking/presentation/utils/prayer_lock.dart';

PrayerTimeModel _times(DateTime day) {
  DateTime at(int h, int m) => DateTime(day.year, day.month, day.day, h, m);
  return PrayerTimeModel(
    date: day,
    fajr: at(5, 0),
    sunrise: at(6, 30),
    dhuhr: at(12, 0),
    asr: at(15, 0),
    maghrib: at(17, 30),
    isha: at(19, 0),
  );
}

void main() {
  final today = DateTime(2030, 1, 10);
  DateTime at(int h, int m) => DateTime(2030, 1, 10, h, m);

  test('today: only the prayers whose time has not come are locked', () {
    final locked = lockedPrayers(
      times: _times(today),
      date: today,
      now: at(13, 0),
    );
    expect(locked, {'Asr', 'Shom', 'Xufton', 'Vitr'});
  });

  test('a prayer opens at its exact time', () {
    final locked = lockedPrayers(
      times: _times(today),
      date: today,
      now: at(15, 0),
    );
    expect(locked.contains('Asr'), false);
    expect(locked.contains('Shom'), true);
  });

  test('before Bomdod everything is locked, after Xufton nothing is', () {
    expect(
      lockedPrayers(times: _times(today), date: today, now: at(4, 0)),
      {'Bomdod', 'Peshin', 'Asr', 'Shom', 'Xufton', 'Vitr'},
    );
    expect(
      lockedPrayers(times: _times(today), date: today, now: at(23, 0)),
      isEmpty,
    );
  });

  test('Vitr follows Xufton', () {
    final locked = lockedPrayers(
      times: _times(today),
      date: today,
      now: at(18, 59),
    );
    expect(locked.contains('Xufton'), true);
    expect(locked.contains('Vitr'), true);
    final after = lockedPrayers(
      times: _times(today),
      date: today,
      now: at(19, 0),
    );
    expect(after.contains('Vitr'), false);
  });

  test('a past day is never locked', () {
    final yesterday = today.subtract(const Duration(days: 1));
    expect(
      lockedPrayers(times: _times(yesterday), date: yesterday, now: at(4, 0)),
      isEmpty,
    );
  });

  test('with no times (offline) nothing is locked', () {
    expect(lockedPrayers(times: null, date: today, now: at(4, 0)), isEmpty);
  });
}
