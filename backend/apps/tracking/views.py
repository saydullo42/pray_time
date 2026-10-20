from django.db import transaction
from rest_framework import permissions, status
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.common.params import MAX_YEAR, MIN_YEAR, date_param, int_param

from .models import PRAYER_NAMES, PrayerTrackingRecord, RozaDay
from .serializers import DailyChecklistSerializer, DailyTrackingSerializer, RozaYearSerializer

# Maps the lowercase field names used by the daily-checklist request body to
# the Uzbek prayer_name values stored on PrayerTrackingRecord.
CHECKLIST_FIELD_TO_PRAYER = {
    "bomdod": "Bomdod",
    "peshin": "Peshin",
    "asr": "Asr",
    "shom": "Shom",
    "xufton": "Xufton",
    "vitr": "Vitr",
}


class DailyTrackingView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        day = date_param(request.query_params, "date")

        records = PrayerTrackingRecord.objects.filter(user=request.user, date=day)
        statuses = {name: False for name in PRAYER_NAMES}
        for record in records:
            statuses[record.prayer_name] = record.done

        serializer = DailyTrackingSerializer({"date": day, "statuses": statuses})
        return Response(serializer.data)


class DailyChecklistView(APIView):
    """Bulk-saves a single day's Bomdod/Peshin/Asr/Shom/Xufton/Vitr checkboxes.

    Only prayers that are marked done are stored; unchecking one deletes its row.
    A prayer without a row simply reads as "not done"."""

    permission_classes = [permissions.IsAuthenticated]

    @transaction.atomic
    def post(self, request):
        serializer = DailyChecklistSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        day = data.pop("date")

        not_done = [CHECKLIST_FIELD_TO_PRAYER[field] for field, done in data.items() if not done]
        PrayerTrackingRecord.objects.filter(user=request.user, date=day, prayer_name__in=not_done).delete()
        for field, done in data.items():
            if done:
                PrayerTrackingRecord.objects.update_or_create(
                    user=request.user,
                    date=day,
                    prayer_name=CHECKLIST_FIELD_TO_PRAYER[field],
                    defaults={"done": True},
                )
        return Response(status=status.HTTP_200_OK)


class MonthCalendarView(APIView):
    """Per-day count of prayers marked done in a given month, for calendar coloring."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        year = int_param(request.query_params, "year", minimum=MIN_YEAR, maximum=MAX_YEAR)
        month = int_param(request.query_params, "month", minimum=1, maximum=12)

        records = PrayerTrackingRecord.objects.filter(
            user=request.user, date__year=year, date__month=month
        )
        counts: dict[str, int] = {}
        for record in records:
            key = record.date.isoformat()
            counts.setdefault(key, 0)
            if record.done:
                counts[key] += 1

        return Response({"results": counts})


class RozaView(APIView):
    """All the fasting days the user has marked, grouped by year."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        years: dict[str, list[int]] = {}
        for year, day in RozaDay.objects.filter(user=request.user).values_list("year", "day"):
            years.setdefault(str(year), []).append(day)
        # user_id lets a client notice that its cached days belong to another account
        return Response({"user_id": request.user.pk, "results": years})


class RozaYearView(APIView):
    """Replaces the marked days of one year with the given list (an empty list clears the year)."""

    permission_classes = [permissions.IsAuthenticated]

    @transaction.atomic
    def put(self, request, year: int):
        if not MIN_YEAR <= year <= MAX_YEAR:
            raise ValidationError({"year": f"{MIN_YEAR} dan {MAX_YEAR} gacha bo'lishi kerak."})
        serializer = RozaYearSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        days = set(serializer.validated_data["days"])

        mine = RozaDay.objects.filter(user=request.user, year=year)
        mine.exclude(day__in=days).delete()
        RozaDay.objects.bulk_create(
            [RozaDay(user=request.user, year=year, day=day) for day in days], ignore_conflicts=True
        )
        return Response({"days": sorted(days)})
