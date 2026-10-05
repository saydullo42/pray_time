from django.urls import path

from .views import DailyChecklistView, DailyTrackingView, MonthCalendarView

app_name = "tracking"

urlpatterns = [
    path("daily/", DailyTrackingView.as_view(), name="daily"),
    path("daily-checklist/", DailyChecklistView.as_view(), name="daily-checklist"),
    path("calendar/", MonthCalendarView.as_view(), name="calendar"),
]
