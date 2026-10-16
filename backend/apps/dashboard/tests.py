from datetime import timedelta
from unittest.mock import patch

from django.test import TestCase
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from apps.tracking.models import PrayerTrackingRecord
from apps.users.authentication import reset_activity_memory
from apps.users.models import User, UserActivity

URL = "/api/v1/dashboard/"
BROWSER = "Mozilla/5.0 (X11; Linux x86_64) Chrome/143"
APP = "Dart/3.9 (dart:io)"


def bearer(user, agent=BROWSER):
    token = RefreshToken.for_user(user).access_token
    return {"HTTP_AUTHORIZATION": f"Bearer {token}", "HTTP_USER_AGENT": agent}


class ActivityRecordingTests(TestCase):
    def setUp(self):
        reset_activity_memory()
        self.user = User.objects.create_user(email="u@example.com")
        self.client = APIClient()

    def test_a_request_records_the_day_once(self):
        for _ in range(3):
            self.assertEqual(self.client.get("/api/v1/users/me/", **bearer(self.user)).status_code, 200)
        row = UserActivity.objects.get()
        self.assertEqual((row.user, row.date, row.platform), (self.user, timezone.localdate(), "web"))

    def test_the_flutter_app_counts_as_mobile_and_both_clients_are_kept(self):
        self.client.get("/api/v1/users/me/", **bearer(self.user, APP))
        self.client.get("/api/v1/users/me/", **bearer(self.user, BROWSER))
        self.assertEqual(
            set(UserActivity.objects.values_list("platform", flat=True)), {"mobile", "web"}
        )

    def test_a_new_day_adds_a_new_row(self):
        self.client.get("/api/v1/users/me/", **bearer(self.user))
        tomorrow = timezone.localdate() + timedelta(days=1)
        with patch("apps.users.authentication.timezone.localdate", return_value=tomorrow):
            self.client.get("/api/v1/users/me/", **bearer(self.user))
        self.assertEqual(UserActivity.objects.count(), 2)

    def test_unauthenticated_requests_record_nothing(self):
        self.client.get("/api/v1/users/me/")
        self.client.get("/api/v1/users/me/", HTTP_AUTHORIZATION="Bearer garbage")
        self.assertEqual(UserActivity.objects.count(), 0)

    def test_a_failure_while_recording_never_breaks_the_request(self):
        with patch.object(UserActivity.objects, "get_or_create", side_effect=RuntimeError("db down")):
            with self.assertLogs("apps.users.authentication", level="ERROR"):
                res = self.client.get("/api/v1/users/me/", **bearer(self.user))
        self.assertEqual(res.status_code, 200)

    def test_deleting_the_account_deletes_the_activity(self):
        self.client.get("/api/v1/users/me/", **bearer(self.user))
        self.assertEqual(self.client.delete("/api/v1/users/me/", **bearer(self.user)).status_code, 204)
        self.assertEqual(UserActivity.objects.count(), 0)


class DashboardAccessTests(TestCase):
    def setUp(self):
        reset_activity_memory()
        self.client = APIClient()

    def test_anonymous_gets_401(self):
        self.assertEqual(self.client.get(URL).status_code, 401)

    def test_a_regular_user_gets_403(self):
        user = User.objects.create_user(email="u@example.com")
        self.assertEqual(self.client.get(URL, **bearer(user)).status_code, 403)

    def test_staff_gets_the_statistics(self):
        staff = User.objects.create_user(email="s@example.com", is_staff=True)
        res = self.client.get(URL, **bearer(staff))
        self.assertEqual(res.status_code, 200)
        for key in ("users", "activity", "features", "recent_signups", "days"):
            self.assertIn(key, res.data)

    def test_me_tells_the_client_whether_the_user_is_staff(self):
        staff = User.objects.create_user(email="s@example.com", is_staff=True)
        regular = User.objects.create_user(email="r@example.com")
        self.assertIs(self.client.get("/api/v1/users/me/", **bearer(staff)).data["is_staff"], True)
        self.assertIs(self.client.get("/api/v1/users/me/", **bearer(regular)).data["is_staff"], False)

    def test_a_user_cannot_make_themselves_staff(self):
        user = User.objects.create_user(email="r@example.com")
        self.client.put("/api/v1/users/me/", {"full_name": "X", "is_staff": True}, format="json", **bearer(user))
        user.refresh_from_db()
        self.assertFalse(user.is_staff)

    def test_days_is_validated(self):
        staff = User.objects.create_user(email="s@example.com", is_staff=True)
        for value in ("6", "91", "abc", "-1"):
            with self.subTest(days=value):
                self.assertEqual(self.client.get(f"{URL}?days={value}", **bearer(staff)).status_code, 400)
        self.assertEqual(len(self.client.get(f"{URL}?days=7", **bearer(staff)).data["users"]["signups"]), 7)


class DashboardNumbersTests(TestCase):
    def setUp(self):
        reset_activity_memory()
        self.today = timezone.localdate()
        self.staff = User.objects.create_user(email="staff@example.com", is_staff=True)
        self.client = APIClient()

    def make_user(self, email, joined_days_ago=0, active_days_ago=(), platform="web"):
        user = User.objects.create_user(email=email)
        User.objects.filter(pk=user.pk).update(date_joined=timezone.now() - timedelta(days=joined_days_ago))
        for ago in active_days_ago:
            UserActivity.objects.create(user=user, date=self.today - timedelta(days=ago), platform=platform)
        return user

    def stats(self, query=""):
        # the staff account's own request is recorded as activity today, as in production
        return self.client.get(URL + query, **bearer(self.staff)).data

    def test_user_counts(self):
        self.make_user("today@example.com")
        self.make_user("lastweek@example.com", joined_days_ago=5)
        self.make_user("lastmonth@example.com", joined_days_ago=20)
        self.make_user("old@example.com", joined_days_ago=200)
        users = self.stats()["users"]
        self.assertEqual(users["total"], 5)  # four above + the staff account
        self.assertEqual(users["new_today"], 2)  # "today" + the staff account
        self.assertEqual(users["new_7d"], 3)
        self.assertEqual(users["new_30d"], 4)
        self.assertEqual(sum(day["count"] for day in users["signups"]), 4)
        self.assertEqual(len(users["signups"]), 30)

    def test_active_users(self):
        self.make_user("a@example.com", joined_days_ago=50, active_days_ago=[0, 1, 2])
        self.make_user("b@example.com", joined_days_ago=50, active_days_ago=[0], platform="mobile")
        self.make_user("c@example.com", joined_days_ago=50, active_days_ago=[10])
        self.make_user("d@example.com", joined_days_ago=50, active_days_ago=[40])
        activity = self.stats()["activity"]
        self.assertEqual(activity["dau"], 3)  # a, b and the staff request itself
        self.assertEqual(activity["dau_yesterday"], 1)
        self.assertEqual(activity["wau"], 3)
        self.assertEqual(activity["mau"], 4)  # a, b, c, staff
        self.assertEqual(activity["stickiness"], 75)
        self.assertEqual(activity["returning_7d"], 2)  # a and b joined long ago and came back
        self.assertEqual(activity["platforms_30d"], {"mobile": 1, "web": 3})
        daily = {day["date"]: day["count"] for day in activity["daily"]}
        self.assertEqual(daily[self.today.isoformat()], 3)
        self.assertEqual(daily[(self.today - timedelta(days=1)).isoformat()], 1)
        self.assertEqual(daily[(self.today - timedelta(days=10)).isoformat()], 1)
        self.assertNotIn((self.today - timedelta(days=40)).isoformat(), daily)

    def test_a_new_user_is_not_counted_as_returning(self):
        self.make_user("new@example.com", joined_days_ago=1, active_days_ago=[0, 1])
        self.assertEqual(self.stats()["activity"]["returning_7d"], 0)

    def test_nobody_active_does_not_divide_by_zero(self):
        # force_authenticate skips the activity recording, so there is no activity at all
        self.client.force_authenticate(self.staff)
        activity = self.client.get(URL).data["activity"]
        self.assertEqual((activity["dau"], activity["mau"], activity["stickiness"]), (0, 0, 0))
        self.assertIsNone(activity["tracked_since"])

    def test_feature_use(self):
        a = self.make_user("a@example.com")
        b = self.make_user("b@example.com")
        PrayerTrackingRecord.objects.create(user=a, date=self.today, prayer_name="Bomdod", done=True)
        PrayerTrackingRecord.objects.create(user=a, date=self.today, prayer_name="Asr", done=True)
        PrayerTrackingRecord.objects.create(user=b, date=self.today - timedelta(days=20), prayer_name="Asr", done=True)
        PrayerTrackingRecord.objects.create(user=b, date=self.today, prayer_name="Shom", done=False)
        # NotificationSettings uses a PostgreSQL ArrayField, which the SQLite test database lacks
        with patch("apps.dashboard.views.NotificationSettings") as settings:
            settings.objects.count.return_value = 2
            settings.objects.filter.return_value.count.return_value = 1
            features = self.stats()["features"]
        self.assertEqual(features["users_who_marked_prayers"], 2)
        self.assertEqual(features["users_marking_7d"], 1)
        self.assertEqual(features["users_with_reminder_settings"], 2)
        self.assertEqual(features["users_with_custom_times"], 1)
        marked = {day["date"]: day["count"] for day in features["prayers_marked"]}
        self.assertEqual(marked[self.today.isoformat()], 2)
        self.assertEqual(marked[(self.today - timedelta(days=20)).isoformat()], 1)

    def test_recent_signups_are_newest_first_and_limited_to_ten(self):
        for i in range(12):
            self.make_user(f"u{i}@example.com", joined_days_ago=i + 1)
        recent = self.stats()["recent_signups"]
        self.assertEqual(len(recent), 10)
        self.assertEqual(recent[0]["email"], "staff@example.com")
        self.assertEqual(recent[1]["email"], "u0@example.com")
