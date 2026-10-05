from rest_framework import serializers

from .models import CustomPrayerTime

TIME_FORMAT = "%H:%M"


class CustomPrayerTimeSerializer(serializers.ModelSerializer):
    fajr = serializers.TimeField(format=TIME_FORMAT, input_formats=[TIME_FORMAT], required=False, allow_null=True)
    dhuhr = serializers.TimeField(format=TIME_FORMAT, input_formats=[TIME_FORMAT], required=False, allow_null=True)
    asr = serializers.TimeField(format=TIME_FORMAT, input_formats=[TIME_FORMAT], required=False, allow_null=True)
    maghrib = serializers.TimeField(format=TIME_FORMAT, input_formats=[TIME_FORMAT], required=False, allow_null=True)
    isha = serializers.TimeField(format=TIME_FORMAT, input_formats=[TIME_FORMAT], required=False, allow_null=True)

    class Meta:
        model = CustomPrayerTime
        fields = ["fajr", "dhuhr", "asr", "maghrib", "isha"]
