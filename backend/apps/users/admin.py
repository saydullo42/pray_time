from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DjangoUserAdmin

from .models import OTP, User


class UserAdmin(DjangoUserAdmin):
    ordering = ["phone_number"]
    list_display = ["phone_number", "full_name", "is_profile_complete", "is_staff"]
    search_fields = ["phone_number", "full_name"]
    fieldsets = (
        (None, {"fields": ("phone_number", "password")}),
        ("Profile", {"fields": ("full_name", "avatar_url", "is_profile_complete")}),
        ("Permissions", {"fields": ("is_active", "is_staff", "is_superuser", "groups", "user_permissions")}),
    )
    add_fieldsets = (
        (None, {"classes": ("wide",), "fields": ("phone_number", "password1", "password2")}),
    )


admin.site.register(User, UserAdmin)
admin.site.register(OTP)
