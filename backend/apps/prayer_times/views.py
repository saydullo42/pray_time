from django.core.cache import cache as django_cache
from django.utils import timezone
from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.common.params import MAX_YEAR, MIN_YEAR, date_param, float_param, int_param

from . import cache
from .aladhan_client import fetch_calendar, fetch_timings
from .models import CustomPrayerTime
from .serializers import CustomPrayerTimeSerializer

DEFAULT_METHOD = 3  # Aladhan's "Muslim World League", matches the app's default

# Coordinates are rounded to 4 decimals (~11 m), the precision of the district dataset and of
# the nightly file cache keys; near-identical points then share one cache entry.
COORD_DECIMALS = 4
DAY_CACHE_SECONDS = 24 * 3600
MONTH_CACHE_SECONDS = 7 * 24 * 3600


class CustomPrayerTimeView(generics.RetrieveUpdateAPIView):
    serializer_class = CustomPrayerTimeSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ["get", "put"]

    def get_object(self):
        obj, _ = CustomPrayerTime.objects.get_or_create(user=self.request.user)
        return obj


# Aladhan calculation methods are numbered 0-23.
MAX_METHOD = 23


def _location_and_method(params):
    latitude = float_param(params, "latitude", minimum=-90, maximum=90)
    longitude = float_param(params, "longitude", minimum=-180, maximum=180)
    method = int_param(params, "method", minimum=0, maximum=MAX_METHOD, default=DEFAULT_METHOD)
    return round(latitude, COORD_DECIMALS), round(longitude, COORD_DECIMALS), method


class TodayPrayerTimeView(APIView):
    """Proxies Aladhan for a single day's computed prayer times, so the
    Flutter app only ever talks to our own backend."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        latitude, longitude, method = _location_and_method(request.query_params)
        target_date = date_param(request.query_params, "date", default=timezone.localdate())

        data = cache.lookup(latitude, longitude, target_date, method)
        if data is None:
            # Not in the nightly file cache (other coordinates/method): Aladhan,
            # remembered for a day so repeated requests don't hit it again.
            data = django_cache.get_or_set(
                f"pt:day:{latitude}:{longitude}:{method}:{target_date.isoformat()}",
                lambda: fetch_timings(latitude, longitude, target_date, method),
                DAY_CACHE_SECONDS,
            )
        return Response(data)


class MonthlyPrayerTimeView(APIView):
    """Proxies Aladhan's monthly calendar endpoint."""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        latitude, longitude, method = _location_and_method(request.query_params)
        month = int_param(request.query_params, "month", minimum=1, maximum=12)
        year = int_param(request.query_params, "year", minimum=MIN_YEAR, maximum=MAX_YEAR)

        # A month's times never change, and the app asks for them on every
        # open (reminder sync), so Aladhan is queried once per month and place.
        data = django_cache.get_or_set(
            f"pt:month:{latitude}:{longitude}:{method}:{year}-{month:02d}",
            lambda: fetch_calendar(latitude, longitude, month, year, method),
            MONTH_CACHE_SECONDS,
        )
        return Response(data)
