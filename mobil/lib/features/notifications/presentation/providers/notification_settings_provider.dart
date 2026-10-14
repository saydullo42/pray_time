import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_settings_model.dart';
import '../../data/repositories/notification_settings_repository.dart';
import 'reminder_sync_provider.dart';

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
      await _ensureReminderPermissions();
      await ref.read(reminderSyncProvider).sync(settings: settings);
      return settings;
    });
  }

  /// Reminders can't show without the notification permission (Android 13+).
  Future<void> _ensureReminderPermissions() =>
      ref.read(reminderSyncProvider).requestPermissionsIfNeeded();
}

final notificationSettingsProvider =
    AsyncNotifierProvider<
      NotificationSettingsNotifier,
      NotificationSettingsModel
    >(NotificationSettingsNotifier.new);
