from rest_framework import serializers

from .models import DeviceToken, NotificationSettings


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


class DeviceTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceToken
        fields = ["id", "token", "platform"]
        read_only_fields = ["id"]
