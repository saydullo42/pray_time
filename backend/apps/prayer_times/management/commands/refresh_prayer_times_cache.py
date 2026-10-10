import time
from datetime import date

from django.core.management.base import BaseCommand
from django.utils import timezone

from apps.prayer_times import cache
from apps.prayer_times.aladhan_client import AladhanUnavailable, fetch_timings


class Command(BaseCommand):
    help = "Fetches one day's prayer times for every district and writes them to the file cache."

    def add_arguments(self, parser):
        parser.add_argument("--date", help="YYYY-MM-DD (default: today, Asia/Tashkent)")
        parser.add_argument("--delay", type=float, default=0.2, help="Seconds between Aladhan requests")

    def handle(self, *args, **options):
        day = date.fromisoformat(options["date"]) if options["date"] else timezone.localdate()
        districts = cache.all_districts()
        times: dict[str, dict] = {}
        failed: list[str] = []

        for district in districts:
            key = cache.coord_key(district["latitude"], district["longitude"])
            if key in times:
                continue
            try:
                times[key] = fetch_timings(district["latitude"], district["longitude"], day, cache.CACHED_METHOD)
            except AladhanUnavailable:
                failed.append(f"{district['region']} / {district['name']}")
            time.sleep(options["delay"])

        if not times:
            self.stderr.write(self.style.ERROR(f"{day}: no prayer times fetched, cache left unchanged"))
            return

        path = cache.write_day(day, times)
        cache.prune()
        self.stdout.write(self.style.SUCCESS(f"{day}: cached {len(times)} districts -> {path}"))
        for name in failed:
            self.stderr.write(self.style.WARNING(f"failed: {name}"))
