import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/reminder_sound.dart';
import '../providers/notification_settings_provider.dart';
import '../widgets/reminder_sound_picker_sheet.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  void _showTableInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: const Text("Ma'lumot", style: TextStyle(fontSize: 24)),
        content: const Text(
          "1-jadval - tanlangan hudud bo'yicha avtomatik hisoblangan namoz vaqtlari.\n\n"
          "2-jadval - sizning qo'lda kiritgan namoz vaqtlaringiz.\n\n"
          "Eslatmalar tanlangan jadvaldagi vaqtlarga asosan yuboriladi.",
          style: TextStyle(fontSize: 18, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tushunarli', style: TextStyle(fontSize: 18, color: Color(0xFF4CAF17))),
          ),
        ],
      ),
    );
  }

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
            const SizedBox(height: 4),
            Row(
              children: [
                for (final offset in AppConstants.reminderOffsetsMinutes)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: FilterChip(
                        label: Text('$offset daqiqa', style: const TextStyle(fontSize: 14)),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        selected: settings.enabledOffsetsMinutes.contains(offset),
                        onSelected: (_) {
                          ref.read(notificationSettingsProvider.notifier).updateSettings(
                                settings.copyWith(enabledOffsetsMinutes: {offset}),
                              );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '1-jadval',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: settings.useCustomTimes ? FontWeight.normal : FontWeight.w700,
                    color: settings.useCustomTimes ? null : const Color(0xFF396E0D),
                  ),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: settings.useCustomTimes,
                  activeThumbColor: const Color(0xFF396E0D),
                  activeTrackColor: const Color(0xFFA5D493),
                  inactiveThumbColor: const Color(0xFF396E0D),
                  inactiveTrackColor: const Color(0xFFA5D493),
                  onChanged: (useCustomTimes) => ref.read(notificationSettingsProvider.notifier).updateSettings(
                        settings.copyWith(useCustomTimes: useCustomTimes),
                      ),
                ),
                const SizedBox(width: 16),
                Text(
                  '2-jadval',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: settings.useCustomTimes ? FontWeight.w700 : FontWeight.normal,
                    color: settings.useCustomTimes ? const Color(0xFF396E0D) : null,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _showTableInfo(context),
                child: const Text(
                  'Batafsil',
                  style: TextStyle(color: Color(0xFF4CAF17), fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Qaysi namozlar uchun', style: Theme.of(context).textTheme.titleMedium),
            for (final prayer in AppConstants.prayerNames)
              SwitchListTile(
                title: Text(prayer),
                value: settings.enabledPrayers.contains(prayer),
                activeThumbColor: const Color(0xFF396E0D),
                onChanged: (enabled) {
                  final updated = Set<String>.from(settings.enabledPrayers);
                  enabled ? updated.add(prayer) : updated.remove(prayer);
                  ref.read(notificationSettingsProvider.notifier).updateSettings(
                        settings.copyWith(enabledPrayers: updated),
                      );
                },
              ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Eslatma tovushi'),
              trailing: OutlinedButton(
                onPressed: () async {
                  final pickedId = await showReminderSoundPickerSheet(
                    context,
                    selectedId: settings.reminderSound,
                  );
                  if (pickedId != null) {
                    ref.read(notificationSettingsProvider.notifier).updateSettings(
                          settings.copyWith(reminderSound: pickedId),
                        );
                  }
                },
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF396E0D)),
                child: Text(findReminderSound(settings.reminderSound).label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
