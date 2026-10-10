export interface User {
  id: number;
  phone_number: string;
  full_name: string | null;
  avatar_url: string | null;
  is_profile_complete: boolean;
}

export interface VerifyOtpResponse {
  access_token: string;
  refresh_token: string;
  user: User;
  is_new_user: boolean;
}

export interface PrayerTime {
  date: string;
  fajr: string;
  sunrise: string;
  dhuhr: string;
  asr: string;
  maghrib: string;
  isha: string;
  hijri_day: number;
  hijri_month: string;
  hijri_year: number;
}

export interface CustomPrayerTime {
  fajr: string | null;
  dhuhr: string | null;
  asr: string | null;
  maghrib: string | null;
  isha: string | null;
}

export interface DailyTracking {
  date: string;
  statuses: Record<string, boolean>;
}

export interface MonthCalendarCounts {
  results: Record<string, number>;
}

export interface Surah {
  number: number;
  name_arabic: string;
  name_latin: string;
  name_translation: string;
  ayah_count: number;
  pdf_url: string | null;
  audio_url: string | null;
}

export interface Reciter {
  id: number;
  name: string;
}

export interface ReciterSurahAudio {
  number: number;
  name_arabic: string;
  name_latin: string;
  name_translation: string;
  ayah_count: number;
  audio_url: string;
}

export interface DuaCategory {
  id: number;
  name: string;
  icon_name: string;
}

export interface Dua {
  id: number;
  title: string;
  arabic_text: string;
  transliteration: string;
  translation: string;
  image_url: string | null;
  audio_url: string | null;
  source: string | null;
}

export interface QuranAyah {
  numberInSurah: number;
  text: string;
  page: number;
}
