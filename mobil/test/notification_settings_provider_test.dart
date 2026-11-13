import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobil/features/notifications/data/models/notification_settings_model.dart';
import 'package:mobil/features/notifications/data/repositories/notification_settings_repository.dart';
import 'package:mobil/features/notifications/presentation/providers/notification_settings_provider.dart';
import 'package:mobil/features/notifications/presentation/providers/reminder_sync_provider.dart';

class _FakeRepo implements NotificationSettingsRepository {
  final saved = <NotificationSettingsModel>[];

  /// While set, save() waits for it (a slow network).
  Completer<void>? gate;
  bool fail = false;

  @override
  Future<NotificationSettingsModel> get() async =>
      NotificationSettingsModel.defaults();

  @override
  Future<void> save(NotificationSettingsModel settings) async {
    await gate?.future;
    if (fail) throw Exception('offline');
    saved.add(settings);
  }
}

class _FakeSync implements ReminderSync {
  @override
  Future<bool> requestPermissionsIfNeeded() async => false;

  @override
  Future<void> sync({NotificationSettingsModel? settings}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<(ProviderContainer, _FakeRepo)> _setUp() async {
  final repo = _FakeRepo();
  final c = ProviderContainer(
    overrides: [
      notificationSettingsRepositoryProvider.overrideWithValue(repo),
      reminderSyncProvider.overrideWithValue(_FakeSync()),
    ],
  );
  addTearDown(c.dispose);
  c.listen(notificationSettingsProvider, (_, _) {});
  await c.read(notificationSettingsProvider.future);
  return (c, repo);
}

void main() {
  test('a change shows at once and never goes back to loading', () async {
    final (c, repo) = await _setUp();
    repo.gate = Completer<void>();
    final states = <AsyncValue<NotificationSettingsModel>>[];
    c.listen(notificationSettingsProvider, (_, next) => states.add(next));

    final current = c.read(notificationSettingsProvider).requireValue;
    final saving = c
        .read(notificationSettingsProvider.notifier)
        .updateSettings(current.copyWith(soundEnabled: !current.soundEnabled));

    // The save is still waiting on the network, yet the new value is shown.
    expect(
      c.read(notificationSettingsProvider).requireValue.soundEnabled,
      !current.soundEnabled,
    );
    expect(c.read(notificationSettingsProvider).isLoading, false);

    repo.gate!.complete();
    await saving;
    expect(states.any((s) => s.isLoading), false);
    expect(repo.saved.single.soundEnabled, !current.soundEnabled);
  });

  test('quick changes are saved in the order they were made', () async {
    final (c, repo) = await _setUp();
    repo.gate = Completer<void>();
    final n = c.read(notificationSettingsProvider.notifier);
    final base = c.read(notificationSettingsProvider).requireValue;

    final a = n.updateSettings(base.copyWith(soundEnabled: false));
    final b = n.updateSettings(
      base.copyWith(soundEnabled: false, useCustomTimes: true),
    );
    repo.gate!.complete();
    await Future.wait([a, b]);

    expect(repo.saved.map((s) => s.useCustomTimes), [false, true]);
    expect(c.read(notificationSettingsProvider).requireValue.useCustomTimes,
        true);
  });

  test('a failed save shows the error', () async {
    final (c, repo) = await _setUp();
    repo.fail = true;
    final base = c.read(notificationSettingsProvider).requireValue;
    await c
        .read(notificationSettingsProvider.notifier)
        .updateSettings(base.copyWith(soundEnabled: !base.soundEnabled));
    expect(c.read(notificationSettingsProvider).hasError, true);
  });
}
