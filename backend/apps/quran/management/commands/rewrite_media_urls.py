from django.core.management.base import BaseCommand, CommandError

from apps.dua.models import Dua
from apps.quran.models import Surah, SurahAudio

# (model, field) pairs that hold absolute URLs written while developing locally.
URL_FIELDS = [
    (SurahAudio, "url"),
    (Surah, "audio_url"),
    (Surah, "pdf_url"),
    (Dua, "audio_url"),
]


class Command(BaseCommand):
    help = (
        "Replaces a URL prefix in the stored absolute URLs, e.g. after moving to a server: "
        "--old http://localhost:8000 --new https://api.pray-time.uz. Dry run unless --apply."
    )

    def add_arguments(self, parser):
        parser.add_argument("--old", required=True, help="URL prefix to replace")
        parser.add_argument("--new", required=True, help="Replacement prefix")
        parser.add_argument("--apply", action="store_true", help="Write the changes (default: only report)")

    def handle(self, *args, **options):
        old = options["old"].rstrip("/")
        new = options["new"].rstrip("/")
        if not old or not new or old == new:
            raise CommandError("--old and --new must be different, non-empty prefixes")

        total = 0
        for model, field in URL_FIELDS:
            rows = model.objects.filter(**{f"{field}__startswith": old})
            count = rows.count()
            total += count
            self.stdout.write(f"{model.__name__}.{field}: {count} to change")
            if options["apply"]:
                for row in rows:
                    setattr(row, field, new + getattr(row, field)[len(old):])
                    row.save(update_fields=[field])

        if options["apply"]:
            self.stdout.write(self.style.SUCCESS(f"Updated {total} URLs."))
        else:
            self.stdout.write(self.style.WARNING(f"Dry run: {total} URLs would change. Re-run with --apply."))
