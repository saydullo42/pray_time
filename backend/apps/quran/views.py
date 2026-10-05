from rest_framework import permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Reciter, SurahAudio, Surah
from .serializers import ReciterSerializer, ReciterSurahAudioSerializer, SurahSerializer


class SurahListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        surahs = Surah.objects.all()
        return Response({"results": SurahSerializer(surahs, many=True).data})


class ReciterListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        reciters = Reciter.objects.all()
        return Response({"reciters": ReciterSerializer(reciters, many=True).data})


class ReciterSurahAudioListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, reciter_id):
        audios = SurahAudio.objects.filter(reciter_id=reciter_id).select_related("surah")
        return Response({"results": ReciterSurahAudioSerializer(audios, many=True).data})
