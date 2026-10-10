from datetime import date as date_cls

from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from . import cache
from .aladhan_client import fetch_calendar, fetch_timings
from .models import CustomPrayerTime
from .serializers import CustomPrayerTimeSerializer

DEFAULT_METHOD = 3  # Aladhan's "Muslim World League", matches the app's default


class CustomPrayerTimeView(generics.RetrieveUpdateAPIView):
    serializer_class = CustomPrayerTimeSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ["get", "put"]

    def get_object(self):
        obj, _ = CustomPrayerTime.objects.get_or_create(user=self.request.user)
        return obj


class TodayPrayerTimeView(APIView):
    """Proxies Aladhan for a single day's computed prayer times, so the
    Flutter app only ever talks to our own backend."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        try:
            latitude = float(request.query_params["latitude"])
            longitude = float(request.query_params["longitude"])
        except (KeyError, ValueError):
            return Response(
                {"detail": "latitude va longitude talab qilinadi"}, status=status.HTTP_400_BAD_REQUEST
            )

        date_param = request.query_params.get("date")
        target_date = date_cls.fromisoformat(date_param) if date_param else date_cls.today()
        method = int(request.query_params.get("method", DEFAULT_METHOD))

        data = cache.lookup(latitude, longitude, target_date, method)
        if data is None:
            data = fetch_timings(latitude, longitude, target_date, method)
        return Response(data)


class MonthlyPrayerTimeView(APIView):
    """Proxies Aladhan's monthly calendar endpoint."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        try:
            latitude = float(request.query_params["latitude"])
            longitude = float(request.query_params["longitude"])
            month = int(request.query_params["month"])
            year = int(request.query_params["year"])
        except (KeyError, ValueError):
            return Response(
                {"detail": "latitude, longitude, month, year talab qilinadi"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        method = int(request.query_params.get("method", DEFAULT_METHOD))
        data = fetch_calendar(latitude, longitude, month, year, method)
        return Response(data)
