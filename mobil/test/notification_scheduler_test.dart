import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/features/notifications/data/models/notification_settings_model.dart';
import 'package:mobil/features/notifications/data/services/local_notification_service.dart';
import 'package:mobil/features/notifications/data/services/notification_scheduler.dart';
import 'package:mobil/features/prayer_times/data/models/prayer_time_model.dart';

class _Scheduled {
  _Scheduled(this.id, this.title, this.time, this.sound, this.mode);
  final int id;
  final String title;
  final DateTime time;
  final String sound;
  final AndroidScheduleMode mode;
}

class _FakeService extends Fake implements LocalNotificationService {
  final List<String> events = [];
  final List<_Scheduled> scheduled = [];

  @override
  Future<void> cancelAll() async => events.add('cancelAll');

  @override
  Future<AndroidScheduleMode> scheduleMode() async =>
      AndroidScheduleMode.inexactAllowWhileIdle;

  @override
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String reminderSoundId = 'klassik',
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.exactAllowWhileIdle,
  }) async {
    events.add('schedule');
    scheduled.add(
      _Scheduled(id, title, scheduledTime, reminderSoundId, scheduleMode),
    );
  }
}

PrayerTimeModel _day(DateTime date) {
  DateTime at(int h, int m) => DateTime(date.year, date.month, date.day, h, m);
  return PrayerTimeModel(
    date: date,
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
  final days = [_day(today), _day(today.add(const Duration(days: 1)))];

  late _FakeService service;
  late NotificationScheduler scheduler;

  setUp(() {
    service = _FakeService();
    scheduler = NotificationScheduler(service);
  });

  test(
    'clears old reminders first, then schedules every day x prayer x offset',
    () async {
      const settings = NotificationSettingsModel(
        enabledOffsetsMinutes: {10, 20},
        enabledPrayers: {'Bomdod', 'Peshin', 'Asr', 'Shom', 'Xufton'},
      );
      await scheduler.reschedule(days: days, settings: settings);

      expect(service.events.first, 'cancelAll');
      expect(service.scheduled.length, 2 * 5 * 2);
      expect(
        service.scheduled.map((s) => s.id).toSet().length,
        20,
        reason: 'ids must be unique',
      );
    },
  );

  test(
    'reminders fire the chosen number of minutes before each prayer',
    () async {
      const settings = NotificationSettingsModel(
        enabledOffsetsMinutes: {15},
        enabledPrayers: {'Peshin'},
      );
      await scheduler.reschedule(days: days, settings: settings);

      expect(service.scheduled.map((s) => s.time).toList(), [
        DateTime(2030, 1, 10, 11, 45),
        DateTime(2030, 1, 11, 11, 45),
      ]);
      expect(service.scheduled.first.title, 'Peshin namoziga 15 daqiqa qoldi');
    },
  );

  test('only the enabled prayers get a reminder', () async {
    const settings = NotificationSettingsModel(
      enabledOffsetsMinutes: {10},
      enabledPrayers: {'Bomdod', 'Xufton'},
    );
    await scheduler.reschedule(days: [days.first], settings: settings);

    expect(service.scheduled.map((s) => s.title).toList(), [
      'Bomdod namoziga 10 daqiqa qoldi',
      'Xufton namoziga 10 daqiqa qoldi',
    ]);
  });

  test(
    'the selected sound and the schedule mode reach every reminder',
    () async {
      const settings = NotificationSettingsModel(
        enabledOffsetsMinutes: {10},
        enabledPrayers: {'Asr'},
        reminderSound: 'allohning_99_ismi',
      );
      await scheduler.reschedule(days: days, settings: settings);

      expect(
        service.scheduled.every((s) => s.sound == 'allohning_99_ismi'),
        isTrue,
      );
      expect(
        service.scheduled.every(
          (s) => s.mode == AndroidScheduleMode.inexactAllowWhileIdle,
        ),
        isTrue,
      );
    },
  );

  test(
    'nothing enabled means nothing scheduled, but old reminders are still cleared',
    () async {
      const settings = NotificationSettingsModel(
        enabledOffsetsMinutes: {15},
        enabledPrayers: {},
      );
      await scheduler.reschedule(days: days, settings: settings);

      expect(service.events, ['cancelAll']);
    },
  );
}
