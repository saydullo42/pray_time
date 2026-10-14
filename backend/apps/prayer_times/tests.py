from unittest.mock import patch

from django.core.cache import cache as django_cache
from rest_framework.test import APITestCase

from apps.users.models import User

from .aladhan_client import AladhanUnavailable

DAY = {"date": "2026-10-14", "fajr": "04:51", "sunrise": "06:22", "dhuhr": "11:58", "asr": "15:06",
       "maghrib": "17:34", "isha": "19:00", "hijri_day": 3, "hijri_month": "Jumada al-awwal", "hijri_year": 1448}
BASE = "latitude=41.2995&longitude=69.2401"


class PrayerTimesTestCase(APITestCase):
    def setUp(self):
        django_cache.clear()
        self.client.force_authenticate(User.objects.create_user(email="p@example.com"))


class TodayParamTests(PrayerTimesTestCase):
    def test_rejects_bad_parameters(self):
        for query in (
            "",
            "latitude=abc&longitude=1",
            "latitude=91&longitude=1",
            "latitude=1&longitude=181",
            "latitude=nan&longitude=1",
            f"{BASE}&date=garbage",
            f"{BASE}&date=0001-01-01",
            f"{BASE}&method=abc",
            f"{BASE}&method=99",
            f"{BASE}&method=-1",
        ):
            with self.subTest(query=query):
                self.assertEqual(self.client.get(f"/api/v1/prayer-times/today/?{query}").status_code, 400)

    @patch("apps.prayer_times.views.fetch_timings", return_value=DAY)
    def test_valid_request_is_answered_and_cached_for_the_day(self, fetch):
        for _ in range(3):
            response = self.client.get(f"/api/v1/prayer-times/today/?{BASE}&date=2026-10-14")
            self.assertEqual(response.status_code, 200)
            self.assertEqual(response.data["fajr"], "04:51")
        self.assertEqual(fetch.call_count, 1)

    @patch("apps.prayer_times.views.fetch_timings", return_value=DAY)
    def test_nearly_identical_coordinates_share_a_cache_entry(self, fetch):
        self.client.get("/api/v1/prayer-times/today/?latitude=41.29950001&longitude=69.24010002&date=2026-10-14")
        self.client.get("/api/v1/prayer-times/today/?latitude=41.2995&longitude=69.2401&date=2026-10-14")
        self.assertEqual(fetch.call_count, 1)

    @patch("apps.prayer_times.views.cache.lookup", return_value=DAY)
    @patch("apps.prayer_times.views.fetch_timings")
    def test_nightly_file_cache_is_used_first(self, fetch, _lookup):
        response = self.client.get(f"/api/v1/prayer-times/today/?{BASE}&date=2026-10-14")
        self.assertEqual(response.status_code, 200)
        fetch.assert_not_called()

    @patch("apps.prayer_times.views.fetch_timings", side_effect=AladhanUnavailable())
    def test_upstream_failure_is_a_502_and_not_cached(self, fetch):
        for _ in range(2):
            self.assertEqual(self.client.get(f"/api/v1/prayer-times/today/?{BASE}&date=2026-10-14").status_code, 502)
        self.assertEqual(fetch.call_count, 2)


class MonthlyParamTests(PrayerTimesTestCase):
    def test_rejects_bad_parameters(self):
        for query in (
            f"{BASE}",
            f"{BASE}&month=99&year=2026",
            f"{BASE}&month=0&year=2026",
            f"{BASE}&month=10&year=abc",
            f"{BASE}&month=10&year=1",
            f"{BASE}&month=10&year=99999",
            "latitude=abc&longitude=1&month=10&year=2026",
        ):
            with self.subTest(query=query):
                self.assertEqual(self.client.get(f"/api/v1/prayer-times/monthly/?{query}").status_code, 400)

    @patch("apps.prayer_times.views.fetch_calendar", return_value=[DAY])
    def test_a_month_is_fetched_from_aladhan_only_once(self, fetch):
        for _ in range(4):
            response = self.client.get(f"/api/v1/prayer-times/monthly/?{BASE}&month=10&year=2026")
            self.assertEqual(response.status_code, 200)
            self.assertEqual(response.data, [DAY])
        self.assertEqual(fetch.call_count, 1)

    @patch("apps.prayer_times.views.fetch_calendar", return_value=[DAY])
    def test_other_month_or_place_is_a_separate_cache_entry(self, fetch):
        self.client.get(f"/api/v1/prayer-times/monthly/?{BASE}&month=10&year=2026")
        self.client.get(f"/api/v1/prayer-times/monthly/?{BASE}&month=11&year=2026")
        self.client.get("/api/v1/prayer-times/monthly/?latitude=40&longitude=71&month=10&year=2026")
        self.assertEqual(fetch.call_count, 3)

    @patch("apps.prayer_times.views.fetch_calendar", side_effect=AladhanUnavailable())
    def test_upstream_failure_is_a_502(self, _fetch):
        self.assertEqual(self.client.get(f"/api/v1/prayer-times/monthly/?{BASE}&month=10&year=2026").status_code, 502)
