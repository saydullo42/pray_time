from django.urls import path

from .views import GoogleSignInView, LogoutView, MeView, SafeTokenRefreshView

app_name = "users"

urlpatterns = [
    path("auth/google/", GoogleSignInView.as_view(), name="google-sign-in"),
    path("auth/token/refresh/", SafeTokenRefreshView.as_view(), name="token-refresh"),
    path("auth/logout/", LogoutView.as_view(), name="logout"),
    path("users/me/", MeView.as_view(), name="me"),
]
