import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../prayer_times/presentation/providers/prayer_times_provider.dart';
import '../../data/models/notification_settings_model.dart';
import '../../data/repositories/notification_settings_repository.dart';
import '../../data/services/notification_scheduler.dart';

class NotificationSettingsNotifier extends AsyncNotifier<NotificationSettingsModel> {
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
    final prayerTime = await ref.read(todayPrayerTimesProvider.future);
    await ref.read(notificationSchedulerProvider).rescheduleForToday(
          prayerTime: prayerTime,
          settings: settings,
        );
  }
}

final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettingsModel>(
  NotificationSettingsNotifier.new,
);
