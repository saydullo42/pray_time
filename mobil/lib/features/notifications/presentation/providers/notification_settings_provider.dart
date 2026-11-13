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

  // Saves run one after another, in the order the person made the changes.
  Future<void> _saving = Future.value();

  /// Shows the new settings at once (no loading screen, so the buttons and
  /// switches stay where they are) and saves them and reschedules the
  /// reminders in the background. If that fails the screen shows the error.
  Future<void> updateSettings(NotificationSettingsModel settings) {
    state = AsyncData(settings);
    final save = _saving.then((_) async {
      try {
        await ref.read(notificationSettingsRepositoryProvider).save(settings);
        await _ensureReminderPermissions();
        await ref.read(reminderSyncProvider).sync(settings: settings);
      } catch (error, stack) {
        state = AsyncError(error, stack);
      }
    });
    _saving = save;
    return save;
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
