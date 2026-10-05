from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import PRAYER_NAMES, PrayerTrackingRecord
from .serializers import DailyChecklistSerializer, DailyTrackingSerializer

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
        day = request.query_params.get("date")
        if not day:
            return Response({"detail": "date is required"}, status=status.HTTP_400_BAD_REQUEST)

        records = PrayerTrackingRecord.objects.filter(user=request.user, date=day)
        statuses = {name: False for name in PRAYER_NAMES}
        for record in records:
            statuses[record.prayer_name] = record.done

        serializer = DailyTrackingSerializer({"date": day, "statuses": statuses})
        return Response(serializer.data)


class DailyChecklistView(APIView):
    """Bulk-saves a single day's Bomdod/Peshin/Asr/Shom/Xufton/Vitr checkboxes."""

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = DailyChecklistSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        day = data.pop("date")

        for field, done in data.items():
            PrayerTrackingRecord.objects.update_or_create(
                user=request.user,
                date=day,
                prayer_name=CHECKLIST_FIELD_TO_PRAYER[field],
                defaults={"done": done},
            )
        return Response(status=status.HTTP_200_OK)


class MonthCalendarView(APIView):
    """Per-day count of prayers marked done in a given month, for calendar coloring."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        year = int(request.query_params.get("year"))
        month = int(request.query_params.get("month"))

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
