import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../prayer_times/data/models/prayer_time_model.dart';
import '../models/notification_settings_model.dart';
import 'local_notification_service.dart';

/// Schedules one local notification per (prayer, enabled offset) combo for
/// today's prayer times, e.g. "Peshin namoziga 15 daqiqa qoldi". Should be
/// re-run whenever prayer times or reminder settings change, and once a day
/// at midnight so the next day's times get scheduled.
class NotificationScheduler {
  NotificationScheduler(this._service);

  final LocalNotificationService _service;

  Future<void> rescheduleForToday({
    required PrayerTimeModel prayerTime,
    required NotificationSettingsModel settings,
  }) async {
    await _service.cancelAll();

    var id = 0;
    for (final entry in prayerTime.orderedPrayers) {
      if (!settings.enabledPrayers.contains(entry.key)) continue;

      for (final offset in settings.enabledOffsetsMinutes) {
        final scheduledTime = entry.value.subtract(Duration(minutes: offset));
        await _service.scheduleAt(
          id: id++,
          title: '${entry.key} namoziga $offset daqiqa qoldi',
          body: 'Namozga tayyorlaning.',
          scheduledTime: scheduledTime,
          reminderSoundId: settings.reminderSound,
        );
      }
    }
  }
}

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationScheduler(ref.watch(localNotificationServiceProvider));
});
