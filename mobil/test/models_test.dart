import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/features/auth/data/models/user_model.dart';
import 'package:mobil/features/notifications/data/models/notification_settings_model.dart';
import 'package:mobil/features/prayer_times/data/models/prayer_time_model.dart';

void main() {
  group('PrayerTimeModel', () {
    final json = {
      'date': '2026-10-14',
      'fajr': '04:51',
      'sunrise': '06:22',
      'dhuhr': '11:58',
      'asr': '15:06',
      'maghrib': '17:34',
      'isha': '19:00',
      'hijri_day': 3,
      'hijri_month': 'Jumada al-awwal',
      'hijri_year': 1448,
    };

    test('parses the backend response', () {
      final p = PrayerTimeModel.fromJson(json);
      expect(p.fajr, DateTime(2026, 10, 14, 4, 51));
      expect(p.isha, DateTime(2026, 10, 14, 19, 0));
      expect(p.hijriDate, '3 Jumada al-awwal 1448');
    });

    test('lists the five prayers in order, without sunrise', () {
      final names = PrayerTimeModel.fromJson(
        json,
      ).orderedPrayers.map((e) => e.key).toList();
      expect(names, ['Bomdod', 'Peshin', 'Asr', 'Shom', 'Xufton']);
    });

    test('finds the next prayer, and none after Xufton', () {
      final p = PrayerTimeModel.fromJson(json);
      expect(p.nextPrayer(DateTime(2026, 10, 14, 12, 30))!.key, 'Asr');
      expect(p.nextPrayer(DateTime(2026, 10, 14, 4, 0))!.key, 'Bomdod');
      expect(p.nextPrayer(DateTime(2026, 10, 14, 20, 0)), isNull);
    });
  });

  group('NotificationSettingsModel', () {
    test('defaults: 15 minutes before all five prayers', () {
      final s = NotificationSettingsModel.defaults();
      expect(s.enabledOffsetsMinutes, {15});
      expect(s.enabledPrayers, {'Bomdod', 'Peshin', 'Asr', 'Shom', 'Xufton'});
    });

    test('survives a JSON round trip', () {
      const original = NotificationSettingsModel(
        enabledOffsetsMinutes: {10, 20},
        enabledPrayers: {'Asr'},
        useCustomTimes: true,
        reminderSound: 'signal',
      );
      final copy = NotificationSettingsModel.fromJson(original.toJson());
      expect(copy.enabledOffsetsMinutes, {10, 20});
      expect(copy.enabledPrayers, {'Asr'});
      expect(copy.useCustomTimes, isTrue);
      expect(copy.reminderSound, 'signal');
    });

    test('fills in missing optional fields', () {
      final s = NotificationSettingsModel.fromJson({
        'enabled_offsets_minutes': [10],
        'enabled_prayers': ['Bomdod'],
      });
      expect(s.soundEnabled, isTrue);
      expect(s.useCustomTimes, isFalse);
    });
  });

  group('UserModel', () {
    test('reads the email-based user from the API', () {
      final u = UserModel.fromJson({
        'id': 7,
        'email': 'a@example.com',
        'full_name': 'Ali',
        'avatar_url': null,
      });
      expect(u.id, '7');
      expect(u.email, 'a@example.com');
      expect(u.fullName, 'Ali');
      expect(u.avatarUrl, isNull);
    });
  });
}
