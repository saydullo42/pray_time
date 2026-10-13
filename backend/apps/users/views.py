import logging

from django.db import transaction

from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.token_blacklist.models import OutstandingToken
from rest_framework_simplejwt.tokens import RefreshToken

from .google import GoogleAuthError, verify_google_id_token
from .models import User
from .serializers import GoogleSignInSerializer, UserSerializer

logger = logging.getLogger(__name__)


class GoogleSignInView(APIView):
    """Exchanges a Google ID token for our own JWT pair, creating the account
    on first sign-in."""

    # No authentication at all: a stale/expired bearer token left over from a
    # previous session must never block signing in again.
    authentication_classes = []
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = GoogleSignInSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        try:
            claims = verify_google_id_token(serializer.validated_data["id_token"])
        except GoogleAuthError as exc:
            return Response({"detail": str(exc)}, status=status.HTTP_401_UNAUTHORIZED)

        sub = claims["sub"]
        email = claims["email"].lower()
        with transaction.atomic():
            user = User.objects.filter(google_sub=sub).first()
            if user is None:
                # An account created earlier with the same (Google-verified)
                # email, e.g. by an admin, gets linked instead of duplicated.
                user = User.objects.filter(email__iexact=email).first()
            if user is None:
                user = User.objects.create_user(
                    email=email,
                    google_sub=sub,
                    full_name=claims.get("name", "")[:150],
                    avatar_url=claims.get("picture"),
                )
            elif user.google_sub != sub:
                user.google_sub = sub
                user.save(update_fields=["google_sub"])

        if not user.is_active:
            return Response({"detail": "Akkaunt faol emas."}, status=status.HTTP_403_FORBIDDEN)

        refresh = RefreshToken.for_user(user)
        return Response(
            {
                "access_token": str(refresh.access_token),
                "refresh_token": str(refresh),
                "user": UserSerializer(user).data,
            }
        )


class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        tokens = OutstandingToken.objects.filter(user=request.user)
        for token in tokens:
            RefreshToken(token.token).blacklist()
        return Response(status=status.HTTP_205_RESET_CONTENT)


class MeView(generics.RetrieveUpdateDestroyAPIView):
    """The signed-in user's profile. DELETE removes the account and all of its
    data (prayer tracking, reminder settings, custom times, device tokens)."""

    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

    @transaction.atomic
    def perform_destroy(self, instance):
        OutstandingToken.objects.filter(user=instance).delete()
        instance.delete()
