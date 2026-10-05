import requests
from django.conf import settings
from rest_framework.exceptions import APIException


class AladhanUnavailable(APIException):
    status_code = 502
    default_detail = "Namoz vaqtlarini olishda xatolik yuz berdi."
    default_code = "aladhan_unavailable"


def _clean_time(raw: str) -> str:
    """Strips Aladhan's " (TZ)" suffix, e.g. "04:10 (+05)" -> "04:10"."""
    return raw.split(" ")[0]


def _get(path: str, params: dict) -> dict:
    try:
        response = requests.get(f"{settings.ALADHAN_BASE_URL}{path}", params=params, timeout=10)
        response.raise_for_status()
    except requests.RequestException as exc:
        raise AladhanUnavailable() from exc
    return response.json()["data"]


def _to_flat(timings: dict, hijri: dict, date_str: str) -> dict:
    return {
        "date": date_str,
        "fajr": _clean_time(timings["Fajr"]),
        "sunrise": _clean_time(timings["Sunrise"]),
        "dhuhr": _clean_time(timings["Dhuhr"]),
        "asr": _clean_time(timings["Asr"]),
        "maghrib": _clean_time(timings["Maghrib"]),
        "isha": _clean_time(timings["Isha"]),
        "hijri_day": int(hijri["day"]),
        "hijri_month": hijri["month"]["en"],
        "hijri_year": int(hijri["year"]),
    }


def fetch_timings(latitude: float, longitude: float, date, method: int) -> dict:
    data = _get(
        f"/timings/{date.strftime('%d-%m-%Y')}",
        {"latitude": latitude, "longitude": longitude, "method": method},
    )
    return _to_flat(data["timings"], data["date"]["hijri"], date.isoformat())


def fetch_calendar(latitude: float, longitude: float, month: int, year: int, method: int) -> list[dict]:
    days = _get(
        f"/calendar/{year}/{month}",
        {"latitude": latitude, "longitude": longitude, "method": method},
    )
    results = []
    for day in days:
        gregorian = day["date"]["gregorian"]["date"]  # "DD-MM-YYYY"
        d, m, y = gregorian.split("-")
        results.append(_to_flat(day["timings"], day["date"]["hijri"], f"{y}-{m}-{d}"))
    return results
