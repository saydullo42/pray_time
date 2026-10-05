import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

/// Helpers to convert between Gregorian and Hijri (Islamic) calendars and
/// format both for display, e.g. in the home screen date header.
class DateConverter {
  DateConverter._();

  static bool _uzLocaleRegistered = false;

  /// Registers Uzbek Hijri month/day names with the `hijri` package (it only
  /// ships 'en'/'ar'/'tr' by default) and makes it the active language.
  static void _ensureUzLocale() {
    if (_uzLocaleRegistered) return;
    HijriCalendar.addLocale('uz', const {
      'long': {
        1: 'Muharram',
        2: 'Safar',
        3: 'Rabiul-avval',
        4: 'Rabiul-oxir',
        5: 'Jumadul-avval',
        6: 'Jumadul-oxir',
        7: 'Rajab',
        8: "Sha'bon",
        9: 'Ramazon',
        10: 'Shavvol',
        11: "Zul-Qa'da",
        12: 'Zul-Hijja',
      },
      'short': {
        1: 'Muh',
        2: 'Saf',
        3: 'Rab I',
        4: 'Rab II',
        5: 'Jum I',
        6: 'Jum II',
        7: 'Raj',
        8: 'Sha',
        9: 'Ram',
        10: 'Shaw',
        11: 'Zul-Q',
        12: 'Zul-H',
      },
      'days': {
        7: 'Yakshanba',
        1: 'Dushanba',
        2: 'Seshanba',
        3: 'Chorshanba',
        4: 'Payshanba',
        5: 'Juma',
        6: 'Shanba',
      },
      'short_days': {
        7: 'Yak',
        1: 'Du',
        2: 'Se',
        3: 'Chor',
        4: 'Pay',
        5: 'Jum',
        6: 'Shan',
      },
    });
    HijriCalendar.language = 'uz';
    _uzLocaleRegistered = true;
  }

  static HijriCalendar toHijri(DateTime date) {
    _ensureUzLocale();
    return HijriCalendar.fromDate(date);
  }

  static String formatGregorian(DateTime date, {String locale = 'uz'}) {
    return DateFormat('d MMMM, yyyy', locale).format(date);
  }

  static String formatHijri(DateTime date) {
    final hijri = toHijri(date);
    return '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}';
  }

  static String formatDayOfWeek(DateTime date, {String locale = 'uz'}) {
    return DateFormat('EEEE', locale).format(date);
  }

  static int hijriDaysInMonth(int year, int month) {
    return HijriCalendar().getDaysInMonth(year, month);
  }

  /// 0=Sun..6=Sat weekday of the 1st day of the given Hijri year/month, for
  /// laying out a month grid's leading blank cells.
  static int hijriMonthFirstWeekday(int year, int month) {
    return HijriCalendar().hijriToGregorian(year, month, 1).weekday % 7;
  }

  static String hijriMonthName(int month) {
    _ensureUzLocale();
    return HijriCalendar().getMonths()[month] ?? '';
  }
}
