/// The five daily prayer times for a single Gregorian date, plus the
/// matching Hijri date string, as returned by the backend (which proxies
/// Aladhan) or overridden by the user's custom times.
class PrayerTimeModel {
  const PrayerTimeModel({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.hijriDate,
    this.isCustom = false,
  });

  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String? hijriDate;
  final bool isCustom;

  /// Ordered list of (name, time) pairs matching AppConstants.prayerNames,
  /// i.e. Bomdod, Peshin, Asr, Shom, Xufton (sunrise is shown separately).
  List<MapEntry<String, DateTime>> get orderedPrayers => [
        MapEntry('Bomdod', fajr),
        MapEntry('Peshin', dhuhr),
        MapEntry('Asr', asr),
        MapEntry('Shom', maghrib),
        MapEntry('Xufton', isha),
      ];

  /// Returns the next upcoming prayer relative to [now], or null if all of
  /// today's prayers have passed.
  MapEntry<String, DateTime>? nextPrayer(DateTime now) {
    for (final entry in orderedPrayers) {
      if (entry.value.isAfter(now)) return entry;
    }
    return null;
  }

  /// Parses the backend's flat prayer-times response, e.g.
  /// `{"date": "2026-07-19", "fajr": "03:06", ..., "hijri_day": 5,
  /// "hijri_month": "Safar", "hijri_year": 1448}`.
  factory PrayerTimeModel.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);

    DateTime parseTime(String hhmm) {
      final parts = hhmm.split(':');
      return DateTime(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]));
    }

    return PrayerTimeModel(
      date: date,
      fajr: parseTime(json['fajr'] as String),
      sunrise: parseTime(json['sunrise'] as String),
      dhuhr: parseTime(json['dhuhr'] as String),
      asr: parseTime(json['asr'] as String),
      maghrib: parseTime(json['maghrib'] as String),
      isha: parseTime(json['isha'] as String),
      hijriDate: '${json['hijri_day']} ${json['hijri_month']} ${json['hijri_year']}',
    );
  }

  PrayerTimeModel copyWith({
    DateTime? fajr,
    DateTime? sunrise,
    DateTime? dhuhr,
    DateTime? asr,
    DateTime? maghrib,
    DateTime? isha,
    bool? isCustom,
  }) {
    return PrayerTimeModel(
      date: date,
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      hijriDate: hijriDate,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
