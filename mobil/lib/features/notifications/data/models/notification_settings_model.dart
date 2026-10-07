import 'reminder_sound.dart';

/// Per-user reminder preferences: which offsets (10/15/20 min before) are
/// enabled, and whether each individual prayer should trigger a reminder.
class NotificationSettingsModel {
  const NotificationSettingsModel({
    required this.enabledOffsetsMinutes,
    required this.enabledPrayers,
    this.soundEnabled = true,
    this.useCustomTimes = false,
    this.reminderSound = defaultReminderSoundId,
  });

  final Set<int> enabledOffsetsMinutes; // subset of {10, 15, 20}
  final Set<String> enabledPrayers; // subset of AppConstants.prayerNames
  final bool soundEnabled;

  /// false = reminders follow table 1 (computed times), true = table 2
  /// (the user's manual overrides).
  final bool useCustomTimes;

  /// Id of the selected notification sound; see [reminderSounds].
  final String reminderSound;

  factory NotificationSettingsModel.defaults() => const NotificationSettingsModel(
        enabledOffsetsMinutes: {15},
        enabledPrayers: {'Bomdod', 'Peshin', 'Asr', 'Shom', 'Xufton'},
      );

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      enabledOffsetsMinutes: (json['enabled_offsets_minutes'] as List<dynamic>)
          .map((e) => e as int)
          .toSet(),
      enabledPrayers:
          (json['enabled_prayers'] as List<dynamic>).map((e) => e as String).toSet(),
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      useCustomTimes: json['use_custom_times'] as bool? ?? false,
      reminderSound: json['reminder_sound'] as String? ?? defaultReminderSoundId,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled_offsets_minutes': enabledOffsetsMinutes.toList(),
        'enabled_prayers': enabledPrayers.toList(),
        'sound_enabled': soundEnabled,
        'use_custom_times': useCustomTimes,
        'reminder_sound': reminderSound,
      };

  NotificationSettingsModel copyWith({
    Set<int>? enabledOffsetsMinutes,
    Set<String>? enabledPrayers,
    bool? soundEnabled,
    bool? useCustomTimes,
    String? reminderSound,
  }) {
    return NotificationSettingsModel(
      enabledOffsetsMinutes: enabledOffsetsMinutes ?? this.enabledOffsetsMinutes,
      enabledPrayers: enabledPrayers ?? this.enabledPrayers,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      useCustomTimes: useCustomTimes ?? this.useCustomTimes,
      reminderSound: reminderSound ?? this.reminderSound,
    );
  }
}
