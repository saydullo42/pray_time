from rest_framework.test import APITestCase

from apps.tracking.models import PrayerTrackingRecord, RozaDay
from apps.users.models import User


class TrackingParamValidationTests(APITestCase):
    def setUp(self):
        self.client.force_authenticate(User.objects.create_user(email="t@example.com"))

    def test_daily_rejects_missing_or_malformed_date(self):
        for query in ("", "?date=garbage", "?date=2026-13-45", "?date=0001-01-01"):
            with self.subTest(query=query):
                self.assertEqual(self.client.get(f"/api/v1/tracking/daily/{query}").status_code, 400)

    def test_daily_returns_statuses_for_a_valid_date(self):
        response = self.client.get("/api/v1/tracking/daily/?date=2026-10-14")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["date"], "2026-10-14")
        self.assertFalse(any(response.data["statuses"].values()))

    def test_calendar_rejects_missing_or_invalid_year_and_month(self):
        for query in ("", "?year=abc&month=1", "?year=2026", "?year=2026&month=13", "?year=2026&month=0",
                      "?year=99999999999&month=1", "?month=1"):
            with self.subTest(query=query):
                self.assertEqual(self.client.get(f"/api/v1/tracking/calendar/{query}").status_code, 400)

    def test_calendar_accepts_valid_values(self):
        response = self.client.get("/api/v1/tracking/calendar/?year=2026&month=10")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data, {"results": {}})

    def test_checklist_still_rejects_future_and_garbage_dates(self):
        for date in ("2999-01-01", "garbage"):
            response = self.client.post("/api/v1/tracking/daily-checklist/", {"date": date}, format="json")
            self.assertEqual(response.status_code, 400)

    def test_requires_authentication(self):
        self.client.force_authenticate(None)
        self.assertEqual(self.client.get("/api/v1/tracking/daily/?date=2026-10-14").status_code, 401)


class StoreOnlyMarkedPrayersTests(APITestCase):
    URL = "/api/v1/tracking/daily-checklist/"
    DAY = "2026-10-14"
    ALL_OFF = {"bomdod": False, "peshin": False, "asr": False, "shom": False, "xufton": False, "vitr": False}

    def setUp(self):
        self.user = User.objects.create_user(email="t@example.com")
        self.client.force_authenticate(self.user)

    def save(self, **marked):
        return self.client.post(self.URL, {"date": self.DAY, **{**self.ALL_OFF, **marked}}, format="json")

    def stored(self):
        return set(
            PrayerTrackingRecord.objects.filter(user=self.user, date=self.DAY).values_list("prayer_name", "done")
        )

    def test_only_marked_prayers_are_stored(self):
        self.assertEqual(self.save(bomdod=True, asr=True).status_code, 200)
        self.assertEqual(self.stored(), {("Bomdod", True), ("Asr", True)})

    def test_nothing_is_stored_when_nothing_is_marked(self):
        self.assertEqual(self.save().status_code, 200)
        self.assertEqual(PrayerTrackingRecord.objects.count(), 0)

    def test_unchecking_a_prayer_deletes_its_row(self):
        self.save(bomdod=True, asr=True)
        self.save(bomdod=True)
        self.assertEqual(self.stored(), {("Bomdod", True)})

    def test_saving_twice_does_not_duplicate(self):
        self.save(shom=True)
        self.save(shom=True)
        self.assertEqual(PrayerTrackingRecord.objects.count(), 1)

    def test_a_legacy_not_done_row_is_replaced_when_marked(self):
        PrayerTrackingRecord.objects.create(user=self.user, date=self.DAY, prayer_name="Asr", done=False)
        self.save(asr=True)
        self.assertEqual(self.stored(), {("Asr", True)})

    def test_other_days_and_users_are_untouched(self):
        other = User.objects.create_user(email="o@example.com")
        PrayerTrackingRecord.objects.create(user=other, date=self.DAY, prayer_name="Asr", done=True)
        PrayerTrackingRecord.objects.create(user=self.user, date="2026-10-13", prayer_name="Asr", done=True)
        self.save()
        self.assertEqual(PrayerTrackingRecord.objects.count(), 2)

    def test_reading_still_returns_every_prayer(self):
        self.save(bomdod=True)
        statuses = self.client.get(f"/api/v1/tracking/daily/?date={self.DAY}").data["statuses"]
        self.assertEqual(statuses["Bomdod"], True)
        self.assertEqual([name for name, done in statuses.items() if done], ["Bomdod"])
        self.assertEqual(len(statuses), 6)

    def test_calendar_counts_only_marked_prayers_and_skips_empty_days(self):
        self.save(bomdod=True, asr=True, shom=True)
        self.client.post(self.URL, {"date": "2026-10-13", **self.ALL_OFF}, format="json")
        results = self.client.get("/api/v1/tracking/calendar/?year=2026&month=10").data["results"]
        self.assertEqual(results, {self.DAY: 3})


class RozaTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(email="r@example.com")
        self.client.force_authenticate(self.user)

    def put(self, year, days):
        return self.client.put(f"/api/v1/tracking/roza/{year}/", {"days": days}, format="json")

    def test_requires_authentication(self):
        self.client.force_authenticate(None)
        self.assertEqual(self.client.get("/api/v1/tracking/roza/").status_code, 401)
        self.assertEqual(self.put(2026, [1]).status_code, 401)

    def test_empty_at_first(self):
        self.assertEqual(
            self.client.get("/api/v1/tracking/roza/").data, {"user_id": self.user.pk, "results": {}}
        )

    def test_saves_and_returns_days_by_year(self):
        self.assertEqual(self.put(2026, [3, 1, 2]).data, {"days": [1, 2, 3]})
        self.put(2025, [30])
        self.assertEqual(
            self.client.get("/api/v1/tracking/roza/").data["results"], {"2025": [30], "2026": [1, 2, 3]}
        )

    def test_put_replaces_the_year(self):
        self.put(2026, [1, 2, 3])
        self.put(2026, [2, 5])
        self.assertEqual(self.client.get("/api/v1/tracking/roza/").data["results"], {"2026": [2, 5]})

    def test_an_empty_list_clears_the_year_and_only_that_year(self):
        self.put(2026, [1, 2])
        self.put(2025, [7])
        self.put(2026, [])
        self.assertEqual(self.client.get("/api/v1/tracking/roza/").data["results"], {"2025": [7]})

    def test_duplicates_are_ignored_and_saving_twice_is_fine(self):
        self.put(2026, [4, 4, 4])
        self.put(2026, [4])
        self.assertEqual(RozaDay.objects.count(), 1)

    def test_all_thirty_days(self):
        self.assertEqual(self.put(2026, list(range(1, 31))).status_code, 200)
        self.assertEqual(RozaDay.objects.count(), 30)

    def test_invalid_input_is_rejected(self):
        for days in ([0], [31], [-1], ["a"], list(range(1, 32)), None, "1,2"):
            with self.subTest(days=days):
                self.assertEqual(self.put(2026, days).status_code, 400)
        for year in (1899, 2201):
            with self.subTest(year=year):
                self.assertEqual(self.put(year, [1]).status_code, 400)
        self.assertEqual(RozaDay.objects.count(), 0)

    def test_users_cannot_see_or_change_each_others_days(self):
        other = User.objects.create_user(email="o@example.com")
        RozaDay.objects.create(user=other, year=2026, day=9)
        self.put(2026, [1])
        self.assertEqual(self.client.get("/api/v1/tracking/roza/").data["results"], {"2026": [1]})
        self.assertEqual(RozaDay.objects.filter(user=other).count(), 1)

    def test_deleting_the_account_deletes_the_days(self):
        self.put(2026, [1, 2])
        self.assertEqual(self.client.delete("/api/v1/users/me/").status_code, 204)
        self.assertEqual(RozaDay.objects.count(), 0)
