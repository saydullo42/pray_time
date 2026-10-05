from django.contrib import admin

from .models import DeviceToken, NotificationSettings

admin.site.register(NotificationSettings)
admin.site.register(DeviceToken)
