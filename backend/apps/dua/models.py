from django.db import models


class DuaCategory(models.Model):
    name = models.CharField(max_length=150)
    icon_name = models.CharField(max_length=100, default="menu_book")
    inline_images = models.BooleanField(default=False)

    class Meta:
        verbose_name_plural = "Dua categories"

    def __str__(self):
        return self.name


class Dua(models.Model):
    category = models.ForeignKey(DuaCategory, on_delete=models.CASCADE, related_name="duas")
    title = models.CharField(max_length=200)
    arabic_text = models.TextField()
    transliteration = models.TextField(blank=True)
    translation = models.TextField(blank=True)
    audio_url = models.URLField(blank=True, null=True)
    image = models.ImageField(upload_to="dua_images/", blank=True, null=True)
    source = models.CharField(max_length=200, blank=True, null=True)
    order = models.PositiveIntegerField(default=0)

    def __str__(self):
        return self.title
