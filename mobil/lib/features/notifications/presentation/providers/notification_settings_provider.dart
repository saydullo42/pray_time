import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../prayer_times/data/models/custom_prayer_time_model.dart';
import '../../../prayer_times/data/models/prayer_time_model.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';
import '../../data/models/notification_settings_model.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../data/services/notification_scheduler.dart';

class NotificationSettingsNotifier
    extends AsyncNotifier<NotificationSettingsModel> {
  @override
  Future<NotificationSettingsModel> build() {
    return ref.watch(notificationSettingsRepositoryProvider).get();
  }

  Future<void> updateSettings(NotificationSettingsModel settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationSettingsRepositoryProvider).save(settings);
      await _reschedule(settings);
      return settings;
    });
  }

  Future<void> _reschedule(NotificationSettingsModel settings) async {
    var prayerTime = await ref.read(todayPrayerTimesProvider.future);
    if (settings.useCustomTimes) {
      final overrides = await ref.read(
        customPrayerTimeOverridesProvider.future,
      );
      prayerTime = _applyOverrides(prayerTime, overrides);
    }
    await ref
        .read(notificationSchedulerProvider)
        .rescheduleForToday(prayerTime: prayerTime, settings: settings);
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

final notificationSettingsProvider =
    AsyncNotifierProvider<
      NotificationSettingsNotifier,
      NotificationSettingsModel
    >(NotificationSettingsNotifier.new);
