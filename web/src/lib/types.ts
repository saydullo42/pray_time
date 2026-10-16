export interface User {
  id: number;
  email: string;
  full_name: string | null;
  avatar_url: string | null;
  is_staff?: boolean;
}

export interface AuthResponse {
  access_token: string;
  refresh_token: string;
  user: User;
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
  inline_images?: boolean;
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

export interface DailyCount {
  date: string; // YYYY-MM-DD
  count: number;
}

export interface DashboardStats {
  generated_at: string;
  days: number;
  users: {
    total: number;
    new_today: number;
    new_7d: number;
    new_30d: number;
    signups: DailyCount[];
  };
  activity: {
    dau: number;
    dau_yesterday: number;
    wau: number;
    mau: number;
    stickiness: number;
    returning_7d: number;
    platforms_30d: { mobile: number; web: number };
    daily: DailyCount[];
    tracked_since: string | null;
  };
  features: {
    users_who_marked_prayers: number;
    users_marking_7d: number;
    users_with_reminder_settings: number;
    users_with_custom_times: number;
    prayers_marked: DailyCount[];
  };
  recent_signups: { email: string; full_name: string; date_joined: string }[];
}
