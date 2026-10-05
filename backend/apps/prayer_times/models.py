from django.conf import settings
from django.db import models


class CustomPrayerTime(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="custom_prayer_time")
    fajr = models.TimeField(null=True, blank=True)
    dhuhr = models.TimeField(null=True, blank=True)
    asr = models.TimeField(null=True, blank=True)
    maghrib = models.TimeField(null=True, blank=True)
    isha = models.TimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.user.phone_number}'s custom prayer times"
