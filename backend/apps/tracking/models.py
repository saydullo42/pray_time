from django.conf import settings
from django.db import models

PRAYER_NAMES = ["Bomdod", "Peshin", "Asr", "Shom", "Xufton", "Vitr"]


class PrayerTrackingRecord(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="tracking_records")
    date = models.DateField()
    prayer_name = models.CharField(max_length=20, choices=[(n, n) for n in PRAYER_NAMES])
    done = models.BooleanField(default=False)

    class Meta:
        unique_together = ("user", "date", "prayer_name")
        ordering = ["date"]

    def __str__(self):
        return f"{self.user.phone_number} - {self.date} - {self.prayer_name}: {'done' if self.done else 'not done'}"
