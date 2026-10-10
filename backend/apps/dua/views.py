from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

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
        category_id = request.query_params.get("category_id")
        if not category_id:
            return Response({"detail": "category_id is required"}, status=status.HTTP_400_BAD_REQUEST)

        duas = Dua.objects.filter(category_id=category_id).order_by("order", "id")
        return Response({"results": DuaSerializer(duas, many=True, context={"request": request}).data})
