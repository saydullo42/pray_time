import logging

from django.utils import timezone
from rest_framework_simplejwt.authentication import JWTAuthentication

from .models import UserActivity

logger = logging.getLogger(__name__)

# (user id, day, platform) triples already written today by this worker, so a
# busy user costs one query per day instead of one per request. A worker that
# restarts just checks the database once more.
_seen: set[tuple[int, object, str]] = set()
_seen_day = None


def platform_of(request) -> str:
    """The Flutter app (Dart's HTTP client) vs. a browser."""
    agent = request.META.get("HTTP_USER_AGENT", "")
    return UserActivity.Platform.MOBILE if agent.startswith("Dart/") else UserActivity.Platform.WEB


def record_activity(user, request) -> None:
    """Notes that [user] used the app today. Never raises: statistics must not
    be able to break a request."""
    global _seen_day
    try:
        today = timezone.localdate()
        if _seen_day != today:
            _seen.clear()
            _seen_day = today
        key = (user.pk, today, platform_of(request))
        if key in _seen:
            return
        UserActivity.objects.get_or_create(user=user, date=today, platform=key[2])
        _seen.add(key)
    except Exception:
        logger.exception("Could not record user activity")


def reset_activity_memory() -> None:
    _seen.clear()


class ActivityJWTAuthentication(JWTAuthentication):
    """JWT authentication that also records the day on which each user was active."""

    def authenticate(self, request):
        result = super().authenticate(request)
        if result is not None:
            record_activity(result[0], request)
        return result
