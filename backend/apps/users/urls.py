from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import GoogleSignInView, LogoutView, MeView

app_name = "users"

urlpatterns = [
    path("auth/google/", GoogleSignInView.as_view(), name="google-sign-in"),
    path("auth/token/refresh/", TokenRefreshView.as_view(), name="token-refresh"),
    path("auth/logout/", LogoutView.as_view(), name="logout"),
    path("users/me/", MeView.as_view(), name="me"),
]
