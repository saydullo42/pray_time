"""Daily file cache of Aladhan prayer times for every Uzbekistan district.

`refresh_prayer_times_cache` (run by cron at 01:00) fetches one day's times
for all districts and writes them to CACHE_DIR/<YYYY-MM-DD>.json; the today
endpoint then answers from that file instead of calling Aladhan per request.
"""

import json
import os
import tempfile
from datetime import date
from functools import lru_cache
from pathlib import Path

from django.conf import settings

CACHE_DIR = Path(settings.BASE_DIR) / "cache" / "prayer_times"
CACHED_METHOD = 3
_REGIONS_FILE = Path(__file__).resolve().parent / "data" / "uzbekistan_regions.json"


def coord_key(latitude: float, longitude: float) -> str:
    # The app sends the dataset's own coordinates, so 4 decimals match exactly.
    return f"{latitude:.4f},{longitude:.4f}"


def all_districts() -> list[dict]:
    regions = json.loads(_REGIONS_FILE.read_text(encoding="utf-8"))
    return [
        {"region": region["name"], **district}
        for region in regions
        for district in region["districts"]
    ]


def cache_path(day: date) -> Path:
    return CACHE_DIR / f"{day.isoformat()}.json"


def write_day(day: date, times: dict[str, dict]) -> Path:
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    path = cache_path(day)
    payload = {"date": day.isoformat(), "method": CACHED_METHOD, "times": times}
    fd, tmp = tempfile.mkstemp(dir=CACHE_DIR, suffix=".tmp")
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False)
    os.replace(tmp, path)
    _load_day.cache_clear()
    return path


@lru_cache(maxsize=4)
def _load_day(path_str: str, mtime: float) -> dict:
    return json.loads(Path(path_str).read_text(encoding="utf-8"))["times"]


def lookup(latitude: float, longitude: float, day: date, method: int) -> dict | None:
    if method != CACHED_METHOD:
        return None
    path = cache_path(day)
    try:
        times = _load_day(str(path), path.stat().st_mtime)
    except (FileNotFoundError, json.JSONDecodeError, KeyError):
        return None
    return times.get(coord_key(latitude, longitude))


def prune(keep_days: int = 7) -> None:
    if not CACHE_DIR.exists():
        return
    files = sorted(CACHE_DIR.glob("*.json"))
    for old in files[:-keep_days]:
        old.unlink(missing_ok=True)
