from rest_framework import serializers

from .models import Dua, DuaCategory


class DuaCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = DuaCategory
        fields = ["id", "name", "icon_name"]


class DuaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Dua
        fields = ["id", "title", "arabic_text", "transliteration", "translation", "audio_url", "source"]
