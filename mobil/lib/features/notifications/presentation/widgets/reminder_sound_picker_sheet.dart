import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/reminder_sound.dart';

/// Opens a modal sheet listing [reminderSounds], highlighting the one whose
/// id is [selectedId]; tapping a row previews it and selects it. Resolves
/// with the tapped sound's id, or null if dismissed without a selection.
Future<String?> showReminderSoundPickerSheet(
  BuildContext context, {
  required String selectedId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _ReminderSoundPickerSheet(selectedId: selectedId),
  );
}

class _ReminderSoundPickerSheet extends StatefulWidget {
  const _ReminderSoundPickerSheet({required this.selectedId});

  final String selectedId;

  @override
  State<_ReminderSoundPickerSheet> createState() =>
      _ReminderSoundPickerSheetState();
}

class _ReminderSoundPickerSheetState extends State<_ReminderSoundPickerSheet> {
  final _player = AudioPlayer();
  String? _playingId;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _preview(ReminderSound sound) async {
    if (_playingId == sound.id) {
      await _player.stop();
      setState(() => _playingId = null);
      return;
    }
    setState(() => _playingId = sound.id);
    await _player.setAsset(sound.assetPath);
    await _player.play();
    if (mounted) setState(() => _playingId = null);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Eslatma tovushi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: reminderSounds.length,
                itemBuilder: (context, index) {
                  final sound = reminderSounds[index];
                  final isSelected = sound.id == widget.selectedId;
                  final isPlaying = sound.id == _playingId;
                  return ListTile(
                    leading: IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                        color: const Color(0xFF396E0D),
                      ),
                      onPressed: () => _preview(sound),
                    ),
                    title: Text(
                      sound.label,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.normal,
                        color: isSelected ? const Color(0xFF396E0D) : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF396E0D))
                        : null,
                    onTap: () => Navigator.of(context).pop(sound.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
