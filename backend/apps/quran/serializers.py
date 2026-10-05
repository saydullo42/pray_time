from rest_framework import serializers

from .models import Reciter, Surah


class SurahSerializer(serializers.ModelSerializer):
    class Meta:
        model = Surah
        fields = [
            "number",
            "name_arabic",
            "name_latin",
            "name_translation",
            "ayah_count",
            "pdf_url",
            "audio_url",
        ]


class ReciterSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reciter
        fields = ["id", "name"]


class ReciterSurahAudioSerializer(serializers.Serializer):
    number = serializers.IntegerField(source="surah.number")
    name_arabic = serializers.CharField(source="surah.name_arabic")
    name_latin = serializers.CharField(source="surah.name_latin")
    name_translation = serializers.CharField(source="surah.name_translation")
    ayah_count = serializers.IntegerField(source="surah.ayah_count")
    audio_url = serializers.URLField(source="url")
