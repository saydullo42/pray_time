/// True if [date] (ignoring time-of-day) is after today — i.e. a day that
/// hasn't happened yet, so its prayers can't be tracked.
bool isFutureDate(DateTime date) {
  final now = DateTime.now();
  final day = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  return day.isAfter(today);
}
