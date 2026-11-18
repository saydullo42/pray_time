/// One selectable notification/reminder sound. [id] doubles as the Android
/// raw-resource name (android/app/src/main/res/raw/$id.$extension), used by
/// the actual scheduled notification channel; [assetPath] (same basename,
/// under assets/sounds/) is used for the in-app preview.
class ReminderSound {
  const ReminderSound({
    required this.id,
    required this.label,
    this.extension = 'wav',
    this.seconds = 3,
  });

  final String id;
  final String label;
  final String extension;

  /// Length of the sound; a long one gets a "To'xtatish" button on the
  /// reminder so it can be silenced.
  final int seconds;

  /// Sounds longer than this get the stop button.
  static const stopButtonAfterSeconds = 10;

  bool get hasStopButton => seconds > stopButtonAfterSeconds;

  String get assetPath => 'assets/sounds/$id.$extension';
}

const reminderSounds = <ReminderSound>[
  ReminderSound(id: 'klassik', label: 'Klassik qo\'ng\'iroq'),
  ReminderSound(id: 'yumshoq', label: 'Yumshoq ohang'),
  ReminderSound(id: 'signal', label: 'Signal'),
  ReminderSound(id: 'uygonish', label: 'Uyg\'onish'),
  ReminderSound(id: 'raqamli', label: 'Raqamli'),
  ReminderSound(
    id: 'allohning_99_ismi',
    label: 'Allohning 99 ismi',
    extension: 'mp3',
    seconds: 240,
  ),
];

const defaultReminderSoundId = 'klassik';

ReminderSound findReminderSound(String id) => reminderSounds.firstWhere(
  (s) => s.id == id,
  orElse: () => reminderSounds.first,
);
