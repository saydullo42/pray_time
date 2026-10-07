/// One selectable notification/reminder sound. [id] doubles as the Flutter
/// asset filename (assets/sounds/$id.wav, used for in-app preview) and the
/// Android raw-resource name (android/app/src/main/res/raw/$id.wav, used by
/// the actual scheduled notification channel).
class ReminderSound {
  const ReminderSound({required this.id, required this.label});

  final String id;
  final String label;

  String get assetPath => 'assets/sounds/$id.wav';
}

const reminderSounds = <ReminderSound>[
  ReminderSound(id: 'klassik', label: 'Klassik qo\'ng\'iroq'),
  ReminderSound(id: 'yumshoq', label: 'Yumshoq ohang'),
  ReminderSound(id: 'signal', label: 'Signal'),
  ReminderSound(id: 'uygonish', label: 'Uyg\'onish'),
  ReminderSound(id: 'raqamli', label: 'Raqamli'),
];

const defaultReminderSoundId = 'klassik';

ReminderSound findReminderSound(String id) => reminderSounds.firstWhere(
      (s) => s.id == id,
      orElse: () => reminderSounds.first,
    );
