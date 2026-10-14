from rest_framework.test import APITestCase

from apps.users.models import User

from .models import Dua, DuaCategory


class DuaListParamTests(APITestCase):
    def setUp(self):
        self.client.force_authenticate(User.objects.create_user(email="d@example.com"))
        self.category = DuaCategory.objects.create(name="Test")
        Dua.objects.create(category=self.category, title="B", order=2)
        Dua.objects.create(category=self.category, title="A", order=1)

    def test_category_id_must_be_a_positive_integer(self):
        for query in ("", "?category_id=abc", "?category_id=0", "?category_id=-3", "?category_id=99999999999"):
            with self.subTest(query=query):
                self.assertEqual(self.client.get(f"/api/v1/dua/{query}").status_code, 400)

    def test_lists_duas_in_order(self):
        response = self.client.get(f"/api/v1/dua/?category_id={self.category.id}")
        self.assertEqual(response.status_code, 200)
        self.assertEqual([d["title"] for d in response.data["results"]], ["A", "B"])

    def test_unknown_category_is_just_empty(self):
        response = self.client.get("/api/v1/dua/?category_id=424242")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["results"], [])
