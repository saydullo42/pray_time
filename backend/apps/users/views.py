import logging

from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.token_blacklist.models import OutstandingToken
from rest_framework_simplejwt.tokens import RefreshToken

from .models import OTP, User
from .serializers import RegisterSerializer, RequestOtpSerializer, UserSerializer, VerifyOtpSerializer

logger = logging.getLogger(__name__)


class RequestOtpView(APIView):
    # No authentication at all: a stale/expired bearer token left over from a
    # previous session must never block starting a fresh login.
    authentication_classes = []
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = RequestOtpSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone_number = serializer.validated_data["phone_number"]

        if OTP.rate_limit_exceeded(phone_number):
            return Response(
                {"detail": "Juda ko'p urinish. Iltimos, 10 daqiqadan so'ng qayta urining."},
                status=status.HTTP_429_TOO_MANY_REQUESTS,
            )

        otp = OTP.generate(phone_number)
        logger.info("OTP for %s: %s", phone_number, otp.code)

        return Response(status=status.HTTP_200_OK)


class VerifyOtpView(APIView):
    authentication_classes = []
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = VerifyOtpSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone_number = serializer.validated_data["phone_number"]
        code = serializer.validated_data["code"]

        otp = (
            OTP.objects.filter(phone_number=phone_number, code=code, is_used=False)
            .order_by("-created_at")
            .first()
        )
        if otp is None or otp.is_expired:
            return Response({"detail": "Kod noto'g'ri yoki muddati o'tgan."}, status=status.HTTP_400_BAD_REQUEST)

        otp.is_used = True
        otp.save(update_fields=["is_used"])

        user, is_new_user = User.objects.get_or_create(phone_number=phone_number)
        refresh = RefreshToken.for_user(user)

        return Response(
            {
                "access_token": str(refresh.access_token),
                "refresh_token": str(refresh),
                "user": UserSerializer(user).data,
                "is_new_user": is_new_user,
            }
        )


class RegisterView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = request.user
        user.full_name = serializer.validated_data["full_name"]
        user.is_profile_complete = True
        user.save(update_fields=["full_name", "is_profile_complete"])

        return Response(UserSerializer(user).data)


class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        tokens = OutstandingToken.objects.filter(user=request.user)
        for token in tokens:
            RefreshToken(token.token).blacklist()
        return Response(status=status.HTTP_205_RESET_CONTENT)


class MeView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user
