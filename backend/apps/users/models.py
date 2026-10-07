import random
from datetime import timedelta

from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager
from django.contrib.auth.models import PermissionsMixin
from django.db import models
from django.utils import timezone

OTP_VALIDITY_MINUTES = 5
OTP_RATE_LIMIT_WINDOW_MINUTES = 10
OTP_RATE_LIMIT_MAX_ATTEMPTS = 3


class UserManager(BaseUserManager):
    def create_user(self, phone_number, password=None, **extra_fields):
        if not phone_number:
            raise ValueError("Phone number is required")
        user = self.model(phone_number=phone_number, **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, phone_number, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        return self.create_user(phone_number, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    phone_number = models.CharField(max_length=20, unique=True)
    full_name = models.CharField(max_length=150, blank=True)
    avatar_url = models.URLField(blank=True, null=True)
    is_profile_complete = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)

    objects = UserManager()

    USERNAME_FIELD = "phone_number"
    REQUIRED_FIELDS = []

    def __str__(self):
        return self.phone_number


class OTP(models.Model):
    phone_number = models.CharField(max_length=20)
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    is_used = models.BooleanField(default=False)

    class Meta:
        ordering = ["-created_at"]

    @classmethod
    def generate(cls, phone_number: str) -> "OTP":
        code = f"{random.randint(0, 999999):06d}"
        return cls.objects.create(phone_number=phone_number, code=code)

    @classmethod
    def rate_limit_exceeded(cls, phone_number: str) -> bool:
        window_start = timezone.now() - timedelta(minutes=OTP_RATE_LIMIT_WINDOW_MINUTES)
        recent_count = cls.objects.filter(phone_number=phone_number, created_at__gte=window_start).count()
        return recent_count >= OTP_RATE_LIMIT_MAX_ATTEMPTS

    @property
    def is_expired(self) -> bool:
        return timezone.now() > self.created_at + timedelta(minutes=OTP_VALIDITY_MINUTES)

    def __str__(self):
        return f"{self.phone_number} - {self.code}"
