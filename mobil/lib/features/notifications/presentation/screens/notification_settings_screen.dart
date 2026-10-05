import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Eslatma sozlamalari')),
      body: settingsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(notificationSettingsProvider),
        ),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Necha daqiqa oldin eslatilsin', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: [
                for (final offset in AppConstants.reminderOffsetsMinutes)
                  FilterChip(
                    label: Text('$offset daqiqa'),
                    selected: settings.enabledOffsetsMinutes.contains(offset),
                    onSelected: (selected) {
                      final updated = Set<int>.from(settings.enabledOffsetsMinutes);
                      selected ? updated.add(offset) : updated.remove(offset);
                      ref.read(notificationSettingsProvider.notifier).updateSettings(
                            settings.copyWith(enabledOffsetsMinutes: updated),
                          );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Qaysi namozlar uchun', style: Theme.of(context).textTheme.titleMedium),
            for (final prayer in AppConstants.prayerNames)
              SwitchListTile(
                title: Text(prayer),
                value: settings.enabledPrayers.contains(prayer),
                onChanged: (enabled) {
                  final updated = Set<String>.from(settings.enabledPrayers);
                  enabled ? updated.add(prayer) : updated.remove(prayer);
                  ref.read(notificationSettingsProvider.notifier).updateSettings(
                        settings.copyWith(enabledPrayers: updated),
                      );
                },
              ),
            SwitchListTile(
              title: const Text('Ovozli signal'),
              value: settings.soundEnabled,
              onChanged: (enabled) => ref.read(notificationSettingsProvider.notifier).updateSettings(
                    settings.copyWith(soundEnabled: enabled),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
