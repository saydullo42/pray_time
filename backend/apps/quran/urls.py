from django.urls import path

from .views import ReciterListView, ReciterSurahAudioListView, SurahListView

app_name = "quran"

urlpatterns = [
    path("surahs/", SurahListView.as_view(), name="surahs"),
    path("audio/", ReciterListView.as_view(), name="reciters"),
    path("audio/<int:reciter_id>/surahs/", ReciterSurahAudioListView.as_view(), name="reciter-surahs"),
]
