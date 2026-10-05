from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import LogoutView, MeView, RegisterView, RequestOtpView, VerifyOtpView

app_name = "users"

urlpatterns = [
    path("auth/otp/request/", RequestOtpView.as_view(), name="otp-request"),
    path("auth/otp/verify/", VerifyOtpView.as_view(), name="otp-verify"),
    path("auth/register/", RegisterView.as_view(), name="register"),
    path("auth/token/refresh/", TokenRefreshView.as_view(), name="token-refresh"),
    path("auth/logout/", LogoutView.as_view(), name="logout"),
    path("users/me/", MeView.as_view(), name="me"),
]
