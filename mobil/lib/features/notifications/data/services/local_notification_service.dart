import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_sound.dart';

/// Thin wrapper around flutter_local_notifications, responsible only for
/// initialization and scheduling a single notification. Deciding *which*
/// notifications to schedule (based on prayer times + user settings) lives
/// in [NotificationScheduler].
class LocalNotificationService {
  LocalNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelName = 'Namoz vaqti eslatmalari';

  /// Android notification channel sounds are fixed once created, so each
  /// selectable [ReminderSound] gets its own channel; scheduling just picks
  /// the channel matching the user's current choice.
  static String _channelId(String soundId) => 'prayer_reminders_$soundId';

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    for (final sound in reminderSounds) {
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          _channelId(sound.id),
          _channelName,
          description: 'Namoz vaqti yaqinlashganda eslatma',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound(sound.id),
        ),
      );
    }
  }

  Future<bool> requestPermissions() async {
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String reminderSoundId = defaultReminderSoundId,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId(reminderSoundId),
          _channelName,
        ),
        iOS: DarwinNotificationDetails(sound: '$reminderSoundId.wav'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return LocalNotificationService(FlutterLocalNotificationsPlugin());
});
