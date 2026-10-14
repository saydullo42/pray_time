from rest_framework.test import APITestCase

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
