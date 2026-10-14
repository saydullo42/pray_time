import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../prayer_times/data/models/prayer_time_model.dart';
import '../models/notification_settings_model.dart';
import 'local_notification_service.dart';

/// Schedules one local notification per (day, prayer, enabled offset), e.g.
/// "Peshin namoziga 15 daqiqa qoldi", for every day in [days]. The alarms are
/// handed to the OS, so they fire with no internet connection and without
/// the app being open; the app only has to top them up now and then (see
/// ReminderSync).
class NotificationScheduler {
  NotificationScheduler(this._service);

  final LocalNotificationService _service;

  Future<void> reschedule({
    required List<PrayerTimeModel> days,
    required NotificationSettingsModel settings,
  }) async {
    await _service.cancelAll();

    final mode = await _service.scheduleMode();
    final offsets = settings.enabledOffsetsMinutes.toList()..sort();
    var id = 0;
    for (final day in days) {
      for (final entry in day.orderedPrayers) {
        if (!settings.enabledPrayers.contains(entry.key)) continue;

        for (final offset in offsets) {
          await _service.scheduleAt(
            id: id++,
            title: '${entry.key} namoziga $offset daqiqa qoldi',
            body: 'Namozga tayyorlaning.',
            scheduledTime: entry.value.subtract(Duration(minutes: offset)),
            reminderSoundId: settings.reminderSound,
            scheduleMode: mode,
          );
        }
      }
    }
  }

  Future<void> cancelAll() => _service.cancelAll();
}

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationScheduler(ref.watch(localNotificationServiceProvider));
});
