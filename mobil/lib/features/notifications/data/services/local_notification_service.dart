import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_sound.dart';

/// Runs when the "To'xtatish" button of a reminder is tapped. The button
/// removes the notification, which makes Android stop its sound; nothing else
/// has to happen here, but the plugin needs a callback for such buttons.
@pragma('vm:entry-point')
void reminderActionTapped(NotificationResponse response) {}

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
  ///
  /// The `_v2` channels replace the first ones, which release builds created
  /// with a sound that had been stripped from the app (so they stayed silent
  /// and Android never lets a channel's sound be changed afterwards).
  static String _channelId(String soundId) => 'prayer_reminders_v2_$soundId';

  static String _oldChannelId(String soundId) => 'prayer_reminders_$soundId';

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveBackgroundNotificationResponse: reminderActionTapped,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    for (final sound in reminderSounds) {
      await androidPlugin?.deleteNotificationChannel(_oldChannelId(sound.id));
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

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Whether reminders are currently allowed to show.
  Future<bool> areNotificationsEnabled() async {
    final android = _android;
    if (android != null) return await android.areNotificationsEnabled() ?? true;
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) return (await ios.checkPermissions())?.isEnabled ?? true;
    return true;
  }

  /// True once the system won't show its permission dialog any more (it was
  /// declined for good); the permission can then only be given in the app's
  /// system settings.
  Future<bool> isPermissionDeclinedForGood() async =>
      (await Permission.notification.status).isPermanentlyDenied;

  /// Opens this app's page in the system settings.
  Future<void> openAppSettingsPage() => openAppSettings();

  /// Asks for the notification permission (Android 13+ / iOS). Returns
  /// whether reminders are allowed to show.
  Future<bool> requestPermissions() async {
    final androidGranted = await _android?.requestNotificationsPermission();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  /// Android 14+ doesn't grant exact alarms by default. Without them the
  /// reminders still fire, but the system may delay them by several minutes.
  /// Opens the system "Alarms & reminders" page when not yet allowed.
  Future<void> requestExactAlarmsPermission() async {
    final android = _android;
    if (android == null) return;
    if (await android.canScheduleExactNotifications() ?? true) return;
    await android.requestExactAlarmsPermission();
  }

  /// Exact alarms when allowed, otherwise the closest thing Android permits.
  Future<AndroidScheduleMode> scheduleMode() async {
    final canExact = await _android?.canScheduleExactNotifications() ?? true;
    return canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String reminderSoundId = defaultReminderSoundId,
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.exactAllowWhileIdle,
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
          importance: Importance.high,
          priority: Priority.high,
          // A long sound can be silenced: removing the notification stops it.
          actions: findReminderSound(reminderSoundId).hasStopButton
              ? const [
                  AndroidNotificationAction(
                    'stop',
                    "To'xtatish",
                    cancelNotification: true,
                  ),
                ]
              : null,
        ),
        iOS: DarwinNotificationDetails(sound: '$reminderSoundId.wav'),
      ),
      androidScheduleMode: scheduleMode,
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
