"""Statistics for the owner's private dashboard (staff accounts only)."""

from datetime import date, timedelta

from django.db.models import Count
from django.db.models.functions import TruncDate
from django.utils import timezone
from rest_framework import permissions
from rest_framework.response import Response
from rest_framework.throttling import UserRateThrottle
from rest_framework.views import APIView

from apps.common.params import int_param
from apps.notifications.models import NotificationSettings
from apps.tracking.models import PrayerTrackingRecord
from apps.users.models import User, UserActivity


def _daily_series(start: date, end: date, counts: dict[date, int]) -> list[dict]:
    """One {date, count} item for every day from start to end, zeros included."""
    return [
        {"date": (day := start + timedelta(days=i)).isoformat(), "count": counts.get(day, 0)}
        for i in range((end - start).days + 1)
    ]


def _active_users_since(day: date) -> int:
    return UserActivity.objects.filter(date__gte=day).values("user").distinct().count()


class DashboardView(APIView):
    permission_classes = [permissions.IsAdminUser]
    throttle_classes = [UserRateThrottle]

    def get(self, request):
        days = int_param(request.query_params, "days", minimum=7, maximum=90, default=30)
        today = timezone.localdate()
        start = today - timedelta(days=days - 1)

        # --- users -----------------------------------------------------------
        signups = {
            row["day"]: row["n"]
            for row in User.objects.filter(date_joined__date__gte=start)
            .annotate(day=TruncDate("date_joined"))
            .values("day")
            .annotate(n=Count("id"))
        }
        users = {
            "total": User.objects.count(),
            "new_today": signups.get(today, 0),
            "new_7d": User.objects.filter(date_joined__date__gte=today - timedelta(days=6)).count(),
            "new_30d": User.objects.filter(date_joined__date__gte=today - timedelta(days=29)).count(),
            "signups": _daily_series(start, today, signups),
        }

        # --- activity --------------------------------------------------------
        active_per_day = {
            row["date"]: row["n"]
            for row in UserActivity.objects.filter(date__gte=start)
            .values("date")
            .annotate(n=Count("user", distinct=True))
        }
        dau = active_per_day.get(today, 0)
        wau = _active_users_since(today - timedelta(days=6))
        mau = _active_users_since(today - timedelta(days=29))
        week_ago = today - timedelta(days=6)
        returning = (
            UserActivity.objects.filter(date__gte=week_ago, user__date_joined__date__lt=week_ago)
            .values("user")
            .distinct()
            .count()
        )
        platforms = {p.value: 0 for p in UserActivity.Platform}
        for row in (
            UserActivity.objects.filter(date__gte=today - timedelta(days=29))
            .values("platform")
            .annotate(n=Count("user", distinct=True))
        ):
            platforms[row["platform"]] = row["n"]
        first_tracked = UserActivity.objects.order_by("date").values_list("date", flat=True).first()
        activity = {
            "dau": dau,
            "dau_yesterday": active_per_day.get(today - timedelta(days=1), 0),
            "wau": wau,
            "mau": mau,
            # share of the monthly users who show up on an average day
            "stickiness": round(dau / mau * 100) if mau else 0,
            "returning_7d": returning,
            "platforms_30d": platforms,
            "daily": _daily_series(start, today, active_per_day),
            "tracked_since": first_tracked.isoformat() if first_tracked else None,
        }

        # --- feature use -----------------------------------------------------
        marks = PrayerTrackingRecord.objects.filter(done=True)
        features = {
            "users_who_marked_prayers": marks.values("user").distinct().count(),
            "users_marking_7d": marks.filter(date__gte=week_ago).values("user").distinct().count(),
            "users_with_reminder_settings": NotificationSettings.objects.count(),
            "users_with_custom_times": NotificationSettings.objects.filter(use_custom_times=True).count(),
        }

        recent = [
            {
                "email": u.email,
                "full_name": u.full_name,
                "date_joined": timezone.localtime(u.date_joined).isoformat(),
            }
            for u in User.objects.order_by("-date_joined")[:10]
        ]

        return Response(
            {
                "generated_at": timezone.now().isoformat(),
                "days": days,
                "users": users,
                "activity": activity,
                "features": features,
                "recent_signups": recent,
            }
        )
