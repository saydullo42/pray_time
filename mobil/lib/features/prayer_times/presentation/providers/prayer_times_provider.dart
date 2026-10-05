import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/calculation_method.dart';
import '../../data/models/custom_prayer_time_model.dart';
import '../../data/models/prayer_time_model.dart';
import '../../data/repositories/prayer_times_repository.dart';
import 'location_provider.dart';

final calculationMethodProvider = StateProvider<CalculationMethod>(
  (ref) => CalculationMethod.muslimWorldLeague,
);

final todayPrayerTimesProvider = FutureProvider.autoDispose<PrayerTimeModel>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  final repository = ref.watch(prayerTimesRepositoryProvider);
  final method = ref.watch(calculationMethodProvider);
  return repository.getTodayTimes(
    latitude: position.latitude,
    longitude: position.longitude,
    date: DateTime.now(),
    method: method,
  );
});

final monthlyPrayerTimesProvider = FutureProvider.autoDispose
    .family<List<PrayerTimeModel>, ({int month, int year})>((ref, args) async {
  final position = await ref.watch(currentPositionProvider.future);
  final repository = ref.watch(prayerTimesRepositoryProvider);
  final method = ref.watch(calculationMethodProvider);
  return repository.getMonthlyTimes(
    latitude: position.latitude,
    longitude: position.longitude,
    month: args.month,
    year: args.year,
    method: method,
  );
});

/// Ticks every second so widgets showing a live "next prayer" countdown
/// rebuild without needing their own Timer.
final clockTickProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

/// The user's manually-entered prayer time overrides, as currently saved on
/// the backend (used to pre-fill the time picker on the home screen).
final customPrayerTimeOverridesProvider = FutureProvider.autoDispose<CustomPrayerTimeModel>((ref) {
  final repository = ref.watch(prayerTimesRepositoryProvider);
  return repository.getCustomOverrides();
});
