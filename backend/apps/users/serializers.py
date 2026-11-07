from rest_framework import serializers

from .models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "email", "full_name", "avatar_url", "region", "district", "is_staff"]
        read_only_fields = ["id", "email", "is_staff"]
        extra_kwargs = {
            "region": {"required": False, "max_length": 80, "trim_whitespace": True},
            "district": {"required": False, "max_length": 80, "trim_whitespace": True},
        }


class GoogleSignInSerializer(serializers.Serializer):
    id_token = serializers.CharField()
