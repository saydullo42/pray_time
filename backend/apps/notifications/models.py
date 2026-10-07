from django.conf import settings
from django.contrib.postgres.fields import ArrayField
from django.db import models

DEFAULT_ENABLED_PRAYERS = ["Bomdod", "Peshin", "Asr", "Shom", "Xufton"]
REMINDER_SOUND_CHOICES = ["klassik", "yumshoq", "signal", "uygonish", "raqamli"]
DEFAULT_REMINDER_SOUND = "klassik"


def default_enabled_offsets():
    return [15]


def default_enabled_prayers():
    return list(DEFAULT_ENABLED_PRAYERS)


class NotificationSettings(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="notification_settings")
    enabled_offsets_minutes = ArrayField(models.IntegerField(), default=default_enabled_offsets)
    enabled_prayers = ArrayField(models.CharField(max_length=20), default=default_enabled_prayers)
    sound_enabled = models.BooleanField(default=True)
    use_custom_times = models.BooleanField(default=False)
    reminder_sound = models.CharField(
        max_length=20,
        choices=[(c, c) for c in REMINDER_SOUND_CHOICES],
        default=DEFAULT_REMINDER_SOUND,
    )

    def __str__(self):
        return f"{self.user.phone_number}'s notification settings"


class DeviceToken(models.Model):
    class Platform(models.TextChoices):
        ANDROID = "android", "Android"
        IOS = "ios", "iOS"

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="device_tokens")
    token = models.CharField(max_length=255, unique=True)
    platform = models.CharField(max_length=10, choices=Platform.choices)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.phone_number} - {self.platform}"
