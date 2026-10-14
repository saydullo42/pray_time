from datetime import timedelta
from unittest.mock import patch

from django.core.management import call_command
from django.test import SimpleTestCase, TestCase, override_settings
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework_simplejwt.token_blacklist.models import OutstandingToken
from rest_framework_simplejwt.tokens import RefreshToken

from .google import GoogleAuthError, verify_google_id_token
from .models import User

CLAIMS = {
    "sub": "google-sub-123",
    "email": "Person@Example.com",
    "email_verified": True,
    "name": "Test Person",
    "picture": "https://example.com/p.png",
    "aud": "client-web",
    "iss": "https://accounts.google.com",
}
URL = "/api/v1/auth/google/"


class GoogleSignInViewTests(TestCase):
    def setUp(self):
        self.client = APIClient()

    @patch("apps.users.views.verify_google_id_token", return_value=CLAIMS)
    def test_first_sign_in_creates_account(self, _verify):
        res = self.client.post(URL, {"id_token": "t"}, format="json")
        self.assertEqual(res.status_code, 200)
        self.assertIn("access_token", res.data)
        self.assertIn("refresh_token", res.data)
        self.assertEqual(res.data["user"]["email"], "person@example.com")
        self.assertEqual(res.data["user"]["full_name"], "Test Person")
        user = User.objects.get(email="person@example.com")
        self.assertEqual(user.google_sub, "google-sub-123")
        self.assertEqual(user.avatar_url, "https://example.com/p.png")
        self.assertFalse(user.has_usable_password())

    @patch("apps.users.views.verify_google_id_token", return_value=CLAIMS)
    def test_second_sign_in_reuses_account(self, _verify):
        self.client.post(URL, {"id_token": "t"}, format="json")
        self.client.post(URL, {"id_token": "t"}, format="json")
        self.assertEqual(User.objects.count(), 1)

    @patch("apps.users.views.verify_google_id_token", return_value=CLAIMS)
    def test_links_existing_account_with_same_email(self, _verify):
        existing = User.objects.create_user(email="person@example.com", full_name="Kept")
        res = self.client.post(URL, {"id_token": "t"}, format="json")
        self.assertEqual(res.status_code, 200)
        existing.refresh_from_db()
        self.assertEqual(existing.google_sub, "google-sub-123")
        self.assertEqual(existing.full_name, "Kept")
        self.assertEqual(User.objects.count(), 1)

    @patch("apps.users.views.verify_google_id_token", side_effect=GoogleAuthError("bad"))
    def test_invalid_token_is_rejected(self, _verify):
        res = self.client.post(URL, {"id_token": "t"}, format="json")
        self.assertEqual(res.status_code, 401)
        self.assertEqual(User.objects.count(), 0)

    def test_missing_token_is_a_bad_request(self):
        res = self.client.post(URL, {}, format="json")
        self.assertEqual(res.status_code, 400)

    @patch("apps.users.views.verify_google_id_token", return_value=CLAIMS)
    def test_inactive_account_cannot_sign_in(self, _verify):
        User.objects.create_user(email="person@example.com", google_sub="google-sub-123", is_active=False)
        res = self.client.post(URL, {"id_token": "t"}, format="json")
        self.assertEqual(res.status_code, 403)

    @patch("apps.users.views.verify_google_id_token", return_value=CLAIMS)
    def test_signed_in_user_can_delete_account(self, _verify):
        res = self.client.post(URL, {"id_token": "t"}, format="json")
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {res.data['access_token']}")
        self.assertEqual(self.client.delete("/api/v1/users/me/").status_code, 204)
        self.assertEqual(User.objects.count(), 0)
        self.assertEqual(self.client.get("/api/v1/users/me/").status_code, 401)

    def test_old_otp_endpoints_are_gone(self):
        self.assertEqual(self.client.post("/api/v1/auth/otp/request/", {}, format="json").status_code, 404)
        self.assertEqual(self.client.post("/api/v1/auth/otp/verify/", {}, format="json").status_code, 404)


@override_settings(GOOGLE_CLIENT_IDS=["client-web", "client-ios"])
class VerifyGoogleIdTokenTests(SimpleTestCase):
    def _verify(self, claims):
        with patch("apps.users.google.id_token.verify_oauth2_token", return_value=claims):
            return verify_google_id_token("t")

    def test_accepts_valid_token(self):
        self.assertEqual(self._verify(CLAIMS)["sub"], "google-sub-123")

    def test_accepts_any_configured_client(self):
        self.assertEqual(self._verify({**CLAIMS, "aud": "client-ios"})["sub"], "google-sub-123")

    def test_rejects_other_audience(self):
        with self.assertRaises(GoogleAuthError):
            self._verify({**CLAIMS, "aud": "someone-elses-app"})

    def test_rejects_unverified_email(self):
        with self.assertRaises(GoogleAuthError):
            self._verify({**CLAIMS, "email_verified": False})

    def test_rejects_missing_email(self):
        with self.assertRaises(GoogleAuthError):
            self._verify({k: v for k, v in CLAIMS.items() if k != "email"})

    def test_rejects_bad_signature_or_expired(self):
        with patch("apps.users.google.id_token.verify_oauth2_token", side_effect=ValueError("expired")):
            with self.assertRaises(GoogleAuthError):
                verify_google_id_token("t")

    @override_settings(GOOGLE_CLIENT_IDS=[])
    def test_rejects_everything_when_not_configured(self):
        with self.assertRaises(GoogleAuthError):
            self._verify(CLAIMS)


class LogoutAndTokenCleanupTests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def _sign_in(self):
        with patch("apps.users.views.verify_google_id_token", return_value=CLAIMS):
            return self.client.post(URL, {"id_token": "t"}, format="json").data

    def test_logout_blacklists_every_refresh_token_of_the_user(self):
        first = self._sign_in()
        second = self._sign_in()  # a second device
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {second['access_token']}")
        self.assertEqual(self.client.post("/api/v1/auth/logout/").status_code, 205)

        self.client.credentials()
        for tokens in (first, second):
            response = self.client.post("/api/v1/auth/token/refresh/", {"refresh": tokens["refresh_token"]}, format="json")
            self.assertEqual(response.status_code, 401)

    def test_logging_out_twice_is_fine(self):
        tokens = self._sign_in()
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {tokens['access_token']}")
        self.assertEqual(self.client.post("/api/v1/auth/logout/").status_code, 205)
        self.assertEqual(self.client.post("/api/v1/auth/logout/").status_code, 205)

    def test_logout_does_not_touch_other_users_tokens(self):
        mine = self._sign_in()
        other_user = User.objects.create_user(email="other@example.com")
        other_refresh = str(RefreshToken.for_user(other_user))

        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {mine['access_token']}")
        self.client.post("/api/v1/auth/logout/")

        self.client.credentials()
        response = self.client.post("/api/v1/auth/token/refresh/", {"refresh": other_refresh}, format="json")
        self.assertEqual(response.status_code, 200)

    def test_flushexpiredtokens_removes_only_expired_tokens(self):
        self._sign_in()
        OutstandingToken.objects.update(expires_at=timezone.now() - timedelta(days=1))
        fresh = RefreshToken.for_user(User.objects.get())
        call_command("flushexpiredtokens")
        remaining = list(OutstandingToken.objects.values_list("jti", flat=True))
        self.assertEqual(remaining, [fresh["jti"]])
