class ApiEndpoints {
  ApiEndpoints._();

  /// Base URL of the Django backend. Override via --dart-define=BACKEND_BASE_URL=...
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  // Auth (SMS OTP)
  static const String requestOtp = '/auth/otp/request/';
  static const String verifyOtp = '/auth/otp/verify/';
  static const String register = '/auth/register/';
  static const String refreshToken = '/auth/token/refresh/';
  static const String logout = '/auth/logout/';

  // Profile
  static const String profile = '/users/me/';

  // Prayer times (computed via backend-proxied Aladhan, plus custom overrides)
  static const String customPrayerTimes = '/prayer-times/custom/';
  static const String prayerTimesToday = '/prayer-times/today/';
  static const String prayerTimesMonthly = '/prayer-times/monthly/';

  // Tracking
  static const String trackingDaily = '/tracking/daily/';
  static const String trackingDailyChecklist = '/tracking/daily-checklist/';
  static const String trackingCalendar = '/tracking/calendar/';

  // Qur'an
  static const String quranSurahs = '/quran/surahs/';
  static const String quranAudio = '/quran/audio/';
  static const String quranVideo = '/quran/video/';
  static const String quranPdf = '/quran/pdf/';
  static String reciterSurahAudio(int reciterId) => '/quran/audio/$reciterId/surahs/';

  // Dua
  static const String duaCategories = '/dua/categories/';
  static const String duaList = '/dua/';

  // Notifications
  static const String notificationSettings = '/notifications/settings/';
  static const String deviceToken = '/notifications/device-token/';
}
