from django.urls import path

from .views import CustomPrayerTimeView, MonthlyPrayerTimeView, TodayPrayerTimeView

app_name = "prayer_times"

urlpatterns = [
    path("custom/", CustomPrayerTimeView.as_view(), name="custom"),
    path("today/", TodayPrayerTimeView.as_view(), name="today"),
    path("monthly/", MonthlyPrayerTimeView.as_view(), name="monthly"),
]
