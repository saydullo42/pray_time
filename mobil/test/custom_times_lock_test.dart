import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/features/prayer_times/data/models/custom_prayer_time_model.dart';
import 'package:mobil/features/prayer_times/data/models/custom_times_apply.dart';
import 'package:mobil/features/prayer_times/data/models/prayer_time_model.dart';
import 'package:mobil/features/tracking/presentation/utils/prayer_lock.dart';

void main() {
  final day = DateTime(2030, 1, 10);
  DateTime at(int h, int m) => DateTime(2030, 1, 10, h, m);
  final computed = PrayerTimeModel(
    date: day,
    fajr: at(5, 0),
    sunrise: at(6, 30),
    dhuhr: at(12, 0),
    asr: at(15, 0),
    maghrib: at(17, 30),
    isha: at(18, 40),
  );

  test('own times replace the computed ones, the rest stay computed', () {
    final mine = computed.withCustomTimes(const CustomPrayerTimeModel(isha: '21:30'));
    expect(mine.isha, at(21, 30));
    expect(mine.asr, computed.asr);
    expect(mine.fajr, computed.fajr);
  });

  test('with table 2 chosen, Xufton and Vitr stay locked until its time', () {
    final mine = computed.withCustomTimes(const CustomPrayerTimeModel(isha: '21:30'));
    // 20:22 is after the computed Xufton (18:40) but before the person's 21:30.
    expect(
      lockedPrayers(times: computed, date: day, now: at(20, 22)),
      isEmpty,
    );
    expect(
      lockedPrayers(times: mine, date: day, now: at(20, 22)),
      {'Xufton', 'Vitr'},
    );
    expect(
      lockedPrayers(times: mine, date: day, now: at(21, 30)),
      isEmpty,
    );
  });
}
