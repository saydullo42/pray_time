/// A user-defined override for one or more daily prayer times, stored on
/// the backend so it syncs across the user's devices. Any field left null
/// falls back to the Aladhan-computed time for that prayer.
class CustomPrayerTimeModel {
  const CustomPrayerTimeModel({
    this.fajr,
    this.dhuhr,
    this.asr,
    this.maghrib,
    this.isha,
  });

  final String? fajr; // stored as "HH:mm"
  final String? dhuhr;
  final String? asr;
  final String? maghrib;
  final String? isha;

  bool get hasAnyOverride =>
      fajr != null || dhuhr != null || asr != null || maghrib != null || isha != null;

  factory CustomPrayerTimeModel.fromJson(Map<String, dynamic> json) {
    return CustomPrayerTimeModel(
      fajr: json['fajr'] as String?,
      dhuhr: json['dhuhr'] as String?,
      asr: json['asr'] as String?,
      maghrib: json['maghrib'] as String?,
      isha: json['isha'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'fajr': fajr,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
      };

  CustomPrayerTimeModel copyWith({
    String? fajr,
    String? dhuhr,
    String? asr,
    String? maghrib,
    String? isha,
  }) {
    return CustomPrayerTimeModel(
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }
}
