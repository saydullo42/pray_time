from django.urls import path

from .views import DeviceTokenCreateView, NotificationSettingsView

app_name = "notifications"

urlpatterns = [
    path("settings/", NotificationSettingsView.as_view(), name="settings"),
    path("device-token/", DeviceTokenCreateView.as_view(), name="device-token"),
]
