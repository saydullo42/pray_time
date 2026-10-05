import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/prayer_times_provider.dart';
import '../widgets/hijri_gregorian_date_header.dart';
import '../widgets/next_prayer_countdown.dart';
import '../widgets/prayer_time_card.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);
    final now = ref.watch(clockTickProvider).valueOrNull ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Namoz vaqtlari'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined),
            tooltip: 'Vaqtlarni qo\'lda kiritish',
            onPressed: () => context.push(RouteNames.customPrayerTimes),
          ),
        ],
      ),
      body: prayerTimesAsync.when(
        loading: () => const LoadingIndicator(message: 'Vaqtlar hisoblanmoqda...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(todayPrayerTimesProvider),
        ),
        data: (prayerTime) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(todayPrayerTimesProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              HijriGregorianDateHeader(date: prayerTime.date),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: NextPrayerCountdown(prayerTime: prayerTime),
                ),
              ),
              const SizedBox(height: 16),
              for (final entry in prayerTime.orderedPrayers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PrayerTimeCard(
                    name: entry.key,
                    time: entry.value,
                    isNext: prayerTime.nextPrayer(now)?.key == entry.key,
                    isCustom: prayerTime.isCustom,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
