import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../prayer_times/data/models/custom_prayer_time_model.dart';
import '../../../prayer_times/data/models/prayer_time_model.dart';
import '../../../prayer_times/data/repositories/prayer_times_repository.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';
import '../../../prayer_times/presentation/providers/region_selection_provider.dart';
import '../../data/models/notification_settings_model.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../data/services/local_notification_service.dart';
import '../../data/services/notification_scheduler.dart';

/// Keeps the OS-level reminder alarms in step with the user's settings,
/// selected region and prayer times.
///
/// It looks [_daysAhead] days into the future and schedules every reminder
/// up front, so they keep firing with no internet and without the app being
/// opened. Run it whenever something that affects the times changes and each
/// time the app is opened, which also pushes the horizon forward.
///
/// If the times can't be fetched (offline), the alarms scheduled earlier are
/// left untouched.
class ReminderSync {
  ReminderSync(this._ref);

  final Ref _ref;

  // iOS allows at most 64 pending local notifications.
  static const _iosMaxPending = 60;
  static const _androidDaysAhead = 30;

  static const _askedExactAlarmsKey = 'asked_exact_alarm_permission';

  static const _deniedCountKey = 'notification_permission_denied_count';
  // Android stops showing its dialog after it has been declined twice.
  static const _systemDialogAttempts = 2;

  /// Asks for the notification permission (Android 13+ / iOS) every time it is
  /// called until it has been granted; once it is, this does nothing. On
  /// Android 14+ it also asks, once, for exact alarms.
  ///
  /// After the system dialog has been declined [_systemDialogAttempts] times
  /// it can't be shown again, so this returns true instead: the caller should
  /// then point the person to the app settings.
  Future<bool> requestPermissionsIfNeeded() async {
    final service = _ref.read(localNotificationServiceProvider);
    final storage = _ref.read(localStorageServiceProvider);

    var needsSettings = false;
    if (!await service.areNotificationsEnabled()) {
      final denied = storage.getInt(_deniedCountKey) ?? 0;
      if (denied >= _systemDialogAttempts ||
          await service.isPermissionDeclinedForGood()) {
        needsSettings = true;
      } else if (!await service.requestPermissions()) {
        await storage.setInt(_deniedCountKey, denied + 1);
      }
    }

    if (storage.getBool(_askedExactAlarmsKey) != true) {
      await storage.setBool(_askedExactAlarmsKey, true);
      await service.requestExactAlarmsPermission();
    }
    return needsSettings;
  }

  Future<void> _queue = Future.value();

  /// Pass [settings] right after saving them to skip re-fetching.
  Future<void> sync({NotificationSettingsModel? settings}) {
    _queue = _queue.then((_) => _run(settings));
    return _queue;
  }

  Future<void> _run(NotificationSettingsModel? settingsOverride) async {
    try {
      final settings =
          settingsOverride ??
          await _ref.read(notificationSettingsRepositoryProvider).get();
      final scheduler = _ref.read(notificationSchedulerProvider);

      final perDay =
          settings.enabledPrayers.length *
          settings.enabledOffsetsMinutes.length;
      if (perDay == 0) {
        await scheduler.cancelAll();
        return;
      }

      final daysAhead = Platform.isIOS
          ? math.max(1, _iosMaxPending ~/ perDay)
          : _androidDaysAhead;
      final now = DateTime.now();
      final first = DateTime(now.year, now.month, now.day);
      final last = first.add(Duration(days: daysAhead - 1));

      final repository = _ref.read(prayerTimesRepositoryProvider);
      final region = _ref.read(regionSelectionProvider);
      final method = _ref.read(calculationMethodProvider);

      final months = {(first.year, first.month), (last.year, last.month)};
      final times = <PrayerTimeModel>[];
      for (final (year, month) in months) {
        times.addAll(
          await repository.getMonthlyTimes(
            latitude: region.latitude,
            longitude: region.longitude,
            month: month,
            year: year,
            method: method,
          ),
        );
      }

      final overrides = settings.useCustomTimes
          ? await repository.getCustomOverrides()
          : null;

      final days =
          times
              .where((t) => !t.date.isBefore(first) && !t.date.isAfter(last))
              .map((t) => overrides == null ? t : _applyOverrides(t, overrides))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

      await scheduler.reschedule(days: days, settings: settings);
    } catch (error) {
      debugPrint('Reminder sync skipped: $error');
    }
  }

  /// Merges table-2 (manual) overrides onto the computed times, falling
  /// back to the computed time for any field the user hasn't overridden.
  PrayerTimeModel _applyOverrides(
    PrayerTimeModel base,
    CustomPrayerTimeModel overrides,
  ) {
    DateTime? parse(String? hhmm) {
      if (hhmm == null) return null;
      final parts = hhmm.split(':');
      return DateTime(
        base.date.year,
        base.date.month,
        base.date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

    return base.copyWith(
      fajr: parse(overrides.fajr),
      dhuhr: parse(overrides.dhuhr),
      asr: parse(overrides.asr),
      maghrib: parse(overrides.maghrib),
      isha: parse(overrides.isha),
      isCustom: overrides.hasAnyOverride,
    );
  }
}

final reminderSyncProvider = Provider<ReminderSync>((ref) => ReminderSync(ref));
