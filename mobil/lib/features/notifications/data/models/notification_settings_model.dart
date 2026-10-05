/// Per-user reminder preferences: which offsets (10/15/20 min before) are
/// enabled, and whether each individual prayer should trigger a reminder.
class NotificationSettingsModel {
  const NotificationSettingsModel({
    required this.enabledOffsetsMinutes,
    required this.enabledPrayers,
    this.soundEnabled = true,
  });

  final Set<int> enabledOffsetsMinutes; // subset of {10, 15, 20}
  final Set<String> enabledPrayers; // subset of AppConstants.prayerNames
  final bool soundEnabled;

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
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled_offsets_minutes': enabledOffsetsMinutes.toList(),
        'enabled_prayers': enabledPrayers.toList(),
        'sound_enabled': soundEnabled,
      };

  NotificationSettingsModel copyWith({
    Set<int>? enabledOffsetsMinutes,
    Set<String>? enabledPrayers,
    bool? soundEnabled,
  }) {
    return NotificationSettingsModel(
      enabledOffsetsMinutes: enabledOffsetsMinutes ?? this.enabledOffsetsMinutes,
      enabledPrayers: enabledPrayers ?? this.enabledPrayers,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}
