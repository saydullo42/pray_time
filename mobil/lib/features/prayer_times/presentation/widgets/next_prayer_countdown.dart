import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/prayer_time_model.dart';
import '../providers/prayer_times_provider.dart';

class NextPrayerCountdown extends ConsumerWidget {
  const NextPrayerCountdown({super.key, required this.prayerTime});

  final PrayerTimeModel prayerTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockTickProvider).valueOrNull ?? DateTime.now();
    final next = prayerTime.nextPrayer(now);

    if (next == null) {
      return const Text('Bugungi barcha namoz vaqtlari o\'tdi');
    }

    final remaining = next.value.difference(now);
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Column(
      children: [
        Text(
          '${next.key} gacha',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '$hours:$minutes:$seconds',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ],
    );
  }
}
