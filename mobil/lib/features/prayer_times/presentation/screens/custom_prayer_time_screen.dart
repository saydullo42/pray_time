import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/custom_prayer_time_model.dart';
import '../../data/repositories/prayer_times_repository.dart';

/// Lets the user manually override any of the five prayer times, e.g. to
/// follow their local mosque's schedule instead of the calculated times.
class CustomPrayerTimeScreen extends ConsumerStatefulWidget {
  const CustomPrayerTimeScreen({super.key});

  @override
  ConsumerState<CustomPrayerTimeScreen> createState() =>
      _CustomPrayerTimeScreenState();
}

class _CustomPrayerTimeScreenState extends ConsumerState<CustomPrayerTimeScreen> {
  final Map<String, TimeOfDay?> _selected = {
    'Bomdod': null,
    'Peshin': null,
    'Asr': null,
    'Shom': null,
    'Xufton': null,
  };
  bool _isSaving = false;

  Future<void> _pickTime(String prayer) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selected[prayer] ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selected[prayer] = picked);
  }

  String? _fmt(TimeOfDay? t) => t == null
      ? null
      : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final overrides = CustomPrayerTimeModel(
      fajr: _fmt(_selected['Bomdod']),
      dhuhr: _fmt(_selected['Peshin']),
      asr: _fmt(_selected['Asr']),
      maghrib: _fmt(_selected['Shom']),
      isha: _fmt(_selected['Xufton']),
    );
    await ref.read(prayerTimesRepositoryProvider).saveCustomOverrides(overrides);
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vaqtlarni qo\'lda kiritish')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final prayer in _selected.keys)
            Card(
              child: ListTile(
                title: Text(prayer),
                trailing: Text(_fmt(_selected[prayer]) ?? 'Belgilanmagan'),
                onTap: () => _pickTime(prayer),
              ),
            ),
          const SizedBox(height: 24),
          CustomButton(label: 'Saqlash', isLoading: _isSaving, onPressed: _save),
        ],
      ),
    );
  }
}
