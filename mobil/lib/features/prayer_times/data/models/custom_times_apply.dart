import 'custom_prayer_time_model.dart';
import 'prayer_time_model.dart';

/// The user's own times (table 2) laid over the computed ones (table 1). A
/// prayer the user hasn't entered keeps its computed time.
extension ApplyCustomTimes on PrayerTimeModel {
  PrayerTimeModel withCustomTimes(CustomPrayerTimeModel overrides) {
    DateTime? parse(String? hhmm) {
      if (hhmm == null) return null;
      final parts = hhmm.split(':');
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

    return copyWith(
      fajr: parse(overrides.fajr),
      dhuhr: parse(overrides.dhuhr),
      asr: parse(overrides.asr),
      maghrib: parse(overrides.maghrib),
      isha: parse(overrides.isha),
      isCustom: overrides.hasAnyOverride,
    );
  }
}
