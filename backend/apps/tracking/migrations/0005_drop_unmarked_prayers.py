from django.db import migrations


def drop_unmarked(apps, schema_editor):
    """Only prayers marked done are stored from now on; a missing row means "not done"."""
    apps.get_model("tracking", "PrayerTrackingRecord").objects.filter(done=False).delete()


class Migration(migrations.Migration):
    dependencies = [("tracking", "0004_remove_prayertrackingrecord_status_and_more")]

    operations = [migrations.RunPython(drop_unmarked, migrations.RunPython.noop)]
