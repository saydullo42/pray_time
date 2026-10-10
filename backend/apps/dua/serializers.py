from rest_framework import serializers

from .models import Dua, DuaCategory


class DuaCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = DuaCategory
        fields = ["id", "name", "icon_name", "inline_images"]


class DuaSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Dua
        fields = [
            "id",
            "title",
            "arabic_text",
            "transliteration",
            "translation",
            "audio_url",
            "image_url",
            "source",
        ]

    def get_image_url(self, obj):
        if not obj.image:
            return None
        request = self.context.get("request")
        return request.build_absolute_uri(obj.image.url) if request else obj.image.url
