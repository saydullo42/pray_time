import '../../../prayer_times/data/models/prayer_time_model.dart';

/// The prayers of [date] that can't be ticked yet: only for today, those whose
/// time hasn't come. Vitr has no time of its own, so it follows Xufton. With
/// no [times] (not loaded, or offline) nothing is locked.
Set<String> lockedPrayers({
  required PrayerTimeModel? times,
  required DateTime date,
  required DateTime now,
}) {
  final isToday =
      date.year == now.year && date.month == now.month && date.day == now.day;
  if (times == null || !isToday) return const {};

  final startOf = <String, DateTime>{
    'Bomdod': times.fajr,
    'Peshin': times.dhuhr,
    'Asr': times.asr,
    'Shom': times.maghrib,
    'Xufton': times.isha,
    'Vitr': times.isha,
  };
  return {
    for (final e in startOf.entries)
      if (now.isBefore(e.value)) e.key,
  };
}
