from rest_framework import permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.common.params import int_param

from .models import Dua, DuaCategory
from .serializers import DuaCategorySerializer, DuaSerializer


class DuaCategoryListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        categories = DuaCategory.objects.order_by("id")
        return Response({"results": DuaCategorySerializer(categories, many=True).data})


class DuaListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        category_id = int_param(request.query_params, "category_id", minimum=1, maximum=2_147_483_647)

        duas = Dua.objects.filter(category_id=category_id).order_by("order", "id")
        return Response({"results": DuaSerializer(duas, many=True, context={"request": request}).data})
