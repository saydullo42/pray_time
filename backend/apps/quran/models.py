from django.db import models



class Reciter(models.Model):
    name = models.CharField(max_length=150)

    class Meta:
        ordering = ["name"]

    def __str__(self):
        return self.name



class Surah(models.Model):
    number = models.PositiveSmallIntegerField(unique=True)
    name_arabic = models.CharField(max_length=100)
    name_latin = models.CharField(max_length=100)
    name_translation = models.CharField(max_length=150, blank=True)
    ayah_count = models.PositiveSmallIntegerField()
    pdf_url = models.URLField()
    audio_url = models.URLField(blank=True, null=True)

    class Meta:
        ordering = ["number"]

    def __str__(self):
        return f"{self.number}. {self.name_latin}"


class SurahAudio(models.Model):
    surah = models.ForeignKey(Surah, related_name="audios", on_delete=models.CASCADE)
    reciter = models.ForeignKey(Reciter, related_name="surah_audios", on_delete=models.CASCADE)
    url = models.URLField()

    class Meta:
        unique_together = ("surah", "reciter")
        ordering = ["surah__number"]

    def __str__(self):
        return f"{self.reciter.name} - {self.surah.number}"

