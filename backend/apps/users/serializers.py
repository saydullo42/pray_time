from rest_framework import serializers

from .models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "email", "full_name", "avatar_url", "is_staff"]
        read_only_fields = ["id", "email", "is_staff"]


class GoogleSignInSerializer(serializers.Serializer):
    id_token = serializers.CharField()
