from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager
from django.contrib.auth.models import PermissionsMixin
from django.db import models
from django.utils import timezone


class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("Email is required")
        user = self.model(email=self.normalize_email(email), **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        return self.create_user(email, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    # Nullable only so rows that predate email sign-in survive the migration;
    # every account created through the API has one.
    email = models.EmailField(unique=True, null=True)
    # Google's stable account id ("sub" claim); the email can change, this can't.
    google_sub = models.CharField(max_length=64, unique=True, null=True, blank=True)
    full_name = models.CharField(max_length=150, blank=True)
    avatar_url = models.URLField(max_length=500, blank=True, null=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)

    objects = UserManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []

    def __str__(self):
        return self.email or f"user-{self.pk}"


class UserActivity(models.Model):
    """One row per user, calendar day and kind of client on which the account was
    used. Only used for the owner's dashboard (daily/weekly/monthly active users);
    it holds no content and is deleted together with the account."""

    class Platform(models.TextChoices):
        MOBILE = "mobile", "Mobil ilova"
        WEB = "web", "Veb sayt"

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="activity")
    date = models.DateField()
    platform = models.CharField(max_length=10, choices=Platform.choices)

    class Meta:
        unique_together = ("user", "date", "platform")
        indexes = [models.Index(fields=["date"])]
        verbose_name_plural = "user activity"

    def __str__(self):
        return f"{self.user} - {self.date} - {self.platform}"
