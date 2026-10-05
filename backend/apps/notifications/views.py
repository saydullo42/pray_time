from rest_framework import generics, permissions

from .models import DeviceToken, NotificationSettings
from .serializers import DeviceTokenSerializer, NotificationSettingsSerializer


class NotificationSettingsView(generics.RetrieveUpdateAPIView):
    serializer_class = NotificationSettingsSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ["get", "put"]

    def get_object(self):
        obj, _ = NotificationSettings.objects.get_or_create(user=self.request.user)
        return obj


class DeviceTokenCreateView(generics.CreateAPIView):
    serializer_class = DeviceTokenSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
