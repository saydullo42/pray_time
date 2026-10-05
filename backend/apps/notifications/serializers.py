from rest_framework import serializers

from .models import DeviceToken, NotificationSettings


class NotificationSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationSettings
        fields = ["enabled_offsets_minutes", "enabled_prayers", "sound_enabled"]


class DeviceTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceToken
        fields = ["id", "token", "platform"]
        read_only_fields = ["id"]
