from rest_framework import serializers

from .models import DeviceToken, NotificationSettings


# The app offers exactly these reminder lead times and prayers. Other values
# would make clients schedule an unbounded number of alarms.
ALLOWED_OFFSETS_MINUTES = (10, 15, 20)
ALLOWED_PRAYERS = ("Bomdod", "Peshin", "Asr", "Shom", "Xufton")


def _only_allowed(values, allowed, label):
    unknown = sorted({v for v in values if v not in allowed}, key=str)
    if unknown:
        raise serializers.ValidationError(f"Ruxsat etilmagan {label}: {unknown}. Mumkin: {list(allowed)}.")
    return sorted(set(values), key=allowed.index)  # no duplicates, canonical order


class NotificationSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationSettings
        fields = [
            "enabled_offsets_minutes",
            "enabled_prayers",
            "sound_enabled",
            "use_custom_times",
            "reminder_sound",
        ]

    def validate_enabled_offsets_minutes(self, value):
        return _only_allowed(value, ALLOWED_OFFSETS_MINUTES, "daqiqa")

    def validate_enabled_prayers(self, value):
        return _only_allowed(value, ALLOWED_PRAYERS, "namoz")


class DeviceTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceToken
        fields = ["id", "token", "platform"]
        read_only_fields = ["id"]
