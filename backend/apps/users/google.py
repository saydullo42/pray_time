"""Verification of Google ID tokens ("Continue with Google")."""

from django.conf import settings
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token


class GoogleAuthError(Exception):
    """The ID token is missing, invalid, expired or not meant for this app."""


def verify_google_id_token(token: str) -> dict:
    """Returns the verified token claims (sub, email, name, picture, ...).

    The signature, expiry and issuer are checked by google-auth; the audience
    is checked here against every client id we accept (web, Android, iOS).
    """
    if not settings.GOOGLE_CLIENT_IDS:
        raise GoogleAuthError("Google orqali kirish sozlanmagan.")
    try:
        claims = id_token.verify_oauth2_token(token, google_requests.Request(), audience=None)
    except ValueError as exc:
        raise GoogleAuthError("Google tokeni yaroqsiz yoki muddati o'tgan.") from exc
    if claims.get("aud") not in settings.GOOGLE_CLIENT_IDS:
        raise GoogleAuthError("Google tokeni bu ilova uchun berilmagan.")
    if not claims.get("email") or not claims.get("email_verified"):
        raise GoogleAuthError("Google email manzili tasdiqlanmagan.")
    return claims
