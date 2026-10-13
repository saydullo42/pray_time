from rest_framework import serializers

from .models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "email", "full_name", "avatar_url"]
        read_only_fields = ["id", "email"]


class GoogleSignInSerializer(serializers.Serializer):
    id_token = serializers.CharField()
