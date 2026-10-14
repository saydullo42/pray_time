from django.test import SimpleTestCase

from .serializers import NotificationSettingsSerializer


def validate(**overrides):
    data = {
        "enabled_offsets_minutes": [15],
        "enabled_prayers": ["Bomdod", "Peshin"],
        "sound_enabled": True,
        "use_custom_times": False,
        "reminder_sound": "klassik",
    }
    data.update(overrides)
    serializer = NotificationSettingsSerializer(data=data)
    return serializer, serializer.is_valid()


class NotificationSettingsValidationTests(SimpleTestCase):
    def test_accepts_the_offsets_the_app_offers(self):
        for offsets in ([10], [15], [20], [10, 20], [10, 15, 20]):
            with self.subTest(offsets=offsets):
                self.assertTrue(validate(enabled_offsets_minutes=offsets)[1])

    def test_rejects_other_offsets(self):
        for offsets in ([99999], [-5], [0], [15, 7], list(range(1, 61))):
            with self.subTest(offsets=offsets):
                serializer, ok = validate(enabled_offsets_minutes=offsets)
                self.assertFalse(ok)
                self.assertIn("enabled_offsets_minutes", serializer.errors)

    def test_at_least_one_offset_is_required(self):
        # The app always has one selected; an empty list was never accepted.
        self.assertFalse(validate(enabled_offsets_minutes=[])[1])

    def test_rejects_unknown_prayers(self):
        for prayers in (["bad"], ["Bomdod", "x" * 50], ["Vitr"], ["bomdod"]):
            with self.subTest(prayers=prayers):
                serializer, ok = validate(enabled_prayers=prayers)
                self.assertFalse(ok)
                self.assertIn("enabled_prayers", serializer.errors)

    def test_removes_duplicates_and_keeps_canonical_order(self):
        serializer, ok = validate(enabled_offsets_minutes=[20, 10, 20], enabled_prayers=["Asr", "Bomdod", "Asr"])
        self.assertTrue(ok)
        self.assertEqual(serializer.validated_data["enabled_offsets_minutes"], [10, 20])
        self.assertEqual(serializer.validated_data["enabled_prayers"], ["Bomdod", "Asr"])

    def test_rejects_unknown_reminder_sound(self):
        self.assertFalse(validate(reminder_sound="x")[1])
