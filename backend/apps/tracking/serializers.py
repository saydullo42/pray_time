from django.utils import timezone
from rest_framework import serializers


def _reject_future_date(value):
    if value > timezone.localdate():
        raise serializers.ValidationError("Kelajakdagi sana uchun namoz belgilab bo'lmaydi.")
    return value


class DailyTrackingSerializer(serializers.Serializer):
    date = serializers.DateField()
    statuses = serializers.DictField(child=serializers.BooleanField())


class DailyChecklistSerializer(serializers.Serializer):
    date = serializers.DateField(validators=[_reject_future_date])
    bomdod = serializers.BooleanField()
    peshin = serializers.BooleanField()
    asr = serializers.BooleanField()
    shom = serializers.BooleanField()
    xufton = serializers.BooleanField()
    vitr = serializers.BooleanField()
