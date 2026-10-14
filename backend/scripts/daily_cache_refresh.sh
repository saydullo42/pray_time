#!/bin/sh
# Daily housekeeping: refreshes the prayer-times file cache once right away,
# then every day at 01:00 in the container's time zone (TZ=Asia/Tashkent in
# docker-compose.yml), and deletes expired JWT refresh tokens so that table
# doesn't grow forever.
# Failures are logged and retried at the next run; the API falls back to
# Aladhan when the cache for today is missing.

python manage.py refresh_prayer_times_cache || true
python manage.py flushexpiredtokens || true

while true; do
  now=$(date +%s)
  target=$(date -d "today 01:00" +%s)
  if [ "$target" -le "$now" ]; then
    target=$(date -d "tomorrow 01:00" +%s)
  fi
  sleep $((target - now))
  python manage.py refresh_prayer_times_cache || true
  python manage.py flushexpiredtokens || true
done
