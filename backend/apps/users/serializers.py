from rest_framework import serializers

from .models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "phone_number", "full_name", "avatar_url", "is_profile_complete"]
        read_only_fields = ["id", "phone_number", "is_profile_complete"]


class RequestOtpSerializer(serializers.Serializer):
    phone_number = serializers.RegexField(r"^\+998[0-9]{9}$")


class VerifyOtpSerializer(serializers.Serializer):
    phone_number = serializers.RegexField(r"^\+998[0-9]{9}$")
    code = serializers.RegexField(r"^[0-9]{6}$")


class RegisterSerializer(serializers.Serializer):
    full_name = serializers.CharField(max_length=150)
