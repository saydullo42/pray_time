from django.urls import path

from .views import DuaCategoryListView, DuaListView

app_name = "dua"

urlpatterns = [
    path("categories/", DuaCategoryListView.as_view(), name="categories"),
    path("", DuaListView.as_view(), name="list"),
]
