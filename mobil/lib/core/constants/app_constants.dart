class AppConstants {
  AppConstants._();

  static const String appName = 'Namoz Vaqtlari';

  /// Canonical order of the five daily prayers used across the app.
  static const List<String> prayerNames = [
    'Bomdod',
    'Peshin',
    'Asr',
    'Shom',
    'Xufton',
  ];

  /// Prayers tracked by the home screen's daily checklist (adds Vitr, which
  /// has no calculated prayer time of its own).
  static const List<String> dailyChecklistPrayers = [
    'Bomdod',
    'Peshin',
    'Asr',
    'Shom',
    'Xufton',
    'Vitr',
  ];

  static const List<int> reminderOffsetsMinutes = [10, 15, 20];

  // Storage keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyOnboardingSeen = 'onboarding_seen';
  static const String keySelectedCity = 'selected_city';
  static const String keyCalculationMethod = 'calculation_method';
  static const String keyLatitude = 'latitude';
  static const String keyLongitude = 'longitude';
}
